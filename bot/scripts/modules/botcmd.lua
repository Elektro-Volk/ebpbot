local module = { commands = { }, pre_list = { }, post_list = { }, cmd_count = 0 }

function module.start()
	module.load_commands()
	console.log('botcmd', "Загружено %i команд.", module.cmd_count)
end

function module.load_commands (dir)
	dir = dir or ''
	local files = fs.dir_list("scripts/commands"..dir)

	for i,file in ipairs(files) do
		if file:ends '.lua' then
			local path = string.format("%s/scripts/commands/%s/%s", root, dir, files[i])
			module.load_command(path, string.sub(dir,2))
		else
			module.load_commands(dir..'/'..files[i])
		end
	end
end

function module.load_command(file, type)
	local command = dofile(file)
	if not command then return console.error('botcmd', "Error loading "..file) end

	command.file = file;
	command.type = type;
	module.commands[command[1]] = command;
	module.cmd_count = module.cmd_count + 1;
	return command;
end

function module.execute(msg, other, user)
	if not msg.text then return end
	local args = cmd.parse(msg.text, ' ');
	if #args == 0 then return end
	local command_name = args[1]:lower();

	local command = module.commands[command_name];
	if not command then return end

	-- Проверяем условия выполнения команды.
	for key,value in ipairs(module.pre_list) do
		local resp = value(msg, args, other, command, user);
		if resp then return resp end
	end

	-- Перезагружаем команду, если dev = true
	if command.dev then command = module.load_command(command.file, command.type) end

	local rmsg = rmsgclass.get()

	local success, result = pcall(function (msg, args, other, rmsg, user)
		local exported = {};

		local cmd_func = args[2] and command.sub and (command.sub[args[2]] or command.help) or command.exe;

		if command.args and cmd_func == command.exe then exported = exportArgs(command, args, command.args, user) end
		if type(cmd_func) == 'table' then
			exported = exportSubArgs(command[1]..' '..cmd_func[1], args, cmd_func[2], user);
			cmd_func = cmd_func[3];
		end

		return cmd_func(msg, args, other, rmsg, user, table.unpack(exported));
	end, msg, args, other, rmsg, user);

	if not success then
		if not result:starts 'err:' then error(result, 0) end
	else
		if result and type(result) == 'string' and result:starts 'err:' then success = false end
	end

	if success then
		-- Пост функции вызываются при успешном выполнении комманд.
		for key,value in ipairs(module.post_list) do
			value(msg, args, other, command, user)
		end
	else
		result = string.sub(result, 5)
		other.sendname = true
		-- Подсказка при ошибке
		if result:find '`' then
			rmsg = { message = result:split('`')[1] }
			oneb(rmsg, result:split('`')[2])
			result = nil
		end
	end

	rmsg = result and (type(result) == "table" and result or { message = result }) or rmsg;

	return rmsg;
end

function module.reg_pre (f) table.insert(module.pre_list,   f) end
function module.reg_post (f) table.insert(module.post_list, f) end

-- Tools
module.arg_types = {
		i = function (args, arg, offset) return toint(arg) end,
		f = function (args, arg, offset) return tonumber(arg) end,
		s = function (args, arg, offset) return arg end,
		d = function (args, arg, offset) return cmd.data(args, offset + 1) end
};

function exportArgs(com, args, params, user, offset)
	if not offset then offset = 0 end
	ca(#params < #args, useerr(com));
	local resp = { };

	for i = 1, #params do
	    local c = params:sub(i,i)
		ca(module.arg_types[c], useerr(com));
		local d = module.arg_types[c](args, args[1 + i + offset], offset + i, user);
		ca(d, useerr(com));
		table.insert(resp, d);
	end

	return resp;
end

function exportSubArgs(use, args, params, user) return exportArgs(use, args, params, user, 1) end

function useerr(com)
	if type(com) == 'string' then return "используйте: "..com end
	return "используйте: "..com[1]..' '..(com.use or '')
end
function ca(u, err, kb, ...) if not u then error('err:'..err.. (kb and '`'..string.format(kb, ...) or ''), 0) end return u end
function cmd_error(str, ...) error('err:'..string.format(str, ...), 0) end

function module.create(name, desc, smile, params)
	local command = params or { }
	command[1] = name
	command[2] = desc
	command['smile'] = smile

	setmetatable(command, { __index = {
		addsub = function (self, name, func)
			if not self.sub then self.sub = {} end
			self.sub[name] = func
		end,

		addmsub = function (self, name, help, args, func) self:addsub(name, { help, args, func }) end
	}})

	return command
end

function module.mcreate(name, desc, usage, args, smile, params)
	local _params = params or { }
	_params.args = args
	_params.usage = usage
	return module.create(name, desc, smile, _params)
end

return module
