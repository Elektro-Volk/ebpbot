--[[
	Функции:
		db.find_table(table_name) -- возвращает её имя или nil, если таблица не найдена
		db.find_column(table_name, column_name) -- вернет колонку или nil, если колонка не найдена
		db.check_column (module_name, table_name, column_name, args) -- создает колонку, если она не найдена
		db.check_table (module_name, table_name, command) -- создает таблицу, если она не найдена
		db.connect(ip, username, password, database) -- подключиться к БД
		db.get_user_safe(vkid) -- ищет пользователя в БД или nil, если он не найден
		db.get_user_from_url(url) -- ищет пользователя по url или nil, если ссылка некорретна
		db.get_user(vkid) -- найдет или создаст пользователя в БД
]]
local module = {}
module.acctable = "accounts"
module.oop = {}

function module.check_install ()
	assert(module.connection, "MySql подключение не существует")

	module.check_table ('db', module.acctable, [[(
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`vkid` int(11) NOT NULL,
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;]]
	);
end

function module.start()
	-- OOP
	function module.oop:set (field, value)
		self[field] = value
		module("UPDATE `%s` SET `%s`='%s' WHERE `vkid`=%i", module.acctable, field, value, self.vkid)
	end

	function module.oop:add (field, value)
		self[field] = self[field] + value
		module("UPDATE `%s` SET `%s`=`%s`+'%s' WHERE `vkid`=%i", module.acctable, field, field, value, self.vkid)
	end

	-- Modules tools
	if botcmd then
		botcmd.arg_types['U'] = function (args, arg, offset)
			if arg:find("%[(.-)|.-%]") then arg = arg:gsub("%[(.-)|.-%]", "%1") end
			return ca (module.get_user(getId(arg)), "пользователь не найден")
		end
	end
end

function module.find_table (table_name)
	local index = "Tables_in_"..db.settings.database
	local tables = module("SHOW TABLES")
	for i = 1,#tables do
		if tables[i][index] == table_name then
			return tables[i][index]
		end
	end
end

function module.find_column (table_name, column_name)
	local columns = module("SHOW COLUMNS FROM `%s`", table_name)
	for i = 1, #columns do
		if columns[i].Field == column_name then
			return columns[i]
		end
	end
end

function module.check_column (module_name, table_name, column_name, args)
	if module.find_column(table_name, column_name) then return true end
	console.log(module_name, "Создаю поле %s в %s...", column_name, table_name)
	module("ALTER TABLE `%s` ADD `%s` %s", table_name, column_name, args)
	console.log(module_name, "Поле %s в было успешно создано.", column_name)
end

function module.check_table (module_name, table_name, command)
	if module.find_table(table_name) then return true end
	console.log(module_name, "Таблица %s не найдена.", table_name)
	console.log(module_name, "Создание таблицы %s...", table_name)
	module("CREATE TABLE `%s` " .. command, table_name)
	console.log(module_name, "Таблица %s успешно создана!", table_name)
	relua()
end

function module.connect(ip, username, password, database)
	module.connection = mysql(ip, username, password, database)
	module("SET NAMES utf8mb4")
	module.settings = { ip = ip, username = username, password = password, database = database }
end

function module.get_user_safe(vkid)
	if not vkid then return end
	local user = module('SELECT * FROM `%s` WHERE vkid=%i', module.acctable, vkid)[1]
	if not user then return false end
	setmetatable(user, { __index = module.oop })
	return user
end

function module.get_user_from_url(url)
	if not url then return end
	if url:find("%[(.-)|.-%]") then url = url:gsub("%[(.-)|.-%]", "%1") end
	return url and module.get_user_safe(getId(url))
end

function module.get_user(vkid)
	if not vkid then return end
	local user = module.get_user_safe(vkid)
	if not user then
		module("INSERT INTO `%s` (`vkid`) VALUES (%i)", module.acctable, vkid)
		user = module.get_user_safe(vkid)
	end
	return user;
end

function module.select(what, table, where, ...)
	return module("SELECT %s FROM `%s` " .. (where and "WHERE "..where or ''), what, table, ...)
end

function module.select_one(what, table, where, ...)
	return module("SELECT %s FROM `%s` " .. (where and "WHERE "..where or ''), what, table, ...)[1]
end

function module.get_count(table, where, ...)
	return tonumber(module("SELECT COUNT(id) FROM `%s` " .. (where and "WHERE "..where or ''), table, ...)[1]['COUNT(id)']) or 0
end

setmetatable(module, { __call = function (_, query, ...) return module.connection(query, ...) end })
return module
