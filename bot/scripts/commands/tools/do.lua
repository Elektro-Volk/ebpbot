--[[
    Песочница луа.
    botcmd.mcreate("команда", "описание", "инструкция", "аргументы", "смайл"[, { ... }])
]]
local command = botcmd.mcreate("do", "выполнить луа код", "<код>", "d", "🔧", {right="do"})

function command.exe(msg, args, other, rmsg, user, code)
	local status, err = pcall(function(msg, args, other, rmsg, user, code)
		if not (code:find'=' or code:find'return' or code:find'\n') then code = 'return ' .. code end
        local func, err = load("return function(msg, args, other, rmsg, user) " .. code .. " end")
        if not func and err then error(err, 0) end -- произошла ошибка
		return func()(msg, args, other, rmsg, user)
	end, msg, args, other, rmsg, user, code)
	if not status and err then return "⛔️ " .. err end -- произошла ошибка

	rmsg:line("🔧 %s", tostring(status))
end

return command
