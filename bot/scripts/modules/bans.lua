--[[
	Этот модуль позволяет выдавать бан пользователям.
	ООП:
		user:checkBan() -- Если пользователь забанен,то вернет true.
		user:banUser(time or -1) -- Забанить пользователя
]]
local module = {}

function module.check_install ()
	assert(db, "Отсутствие модуля db.lua")
	db.check_column ('bans', db.acctable, 'ban', 'INT NOT NULL')
end

function module.start ()
	function db.oop:checkBan () return self.ban == -1 or os.time() <= self.ban end
	function db.oop:banUser (t) self:set('ban', t and (t + os.time()) or -1) end

	if bot then
		bot.add_pre(function (msg, other, user) if user:checkBan() then return false end end)
	end
end

return module
