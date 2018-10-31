local module = {}
module.bcon = cvars.get'vk_groupid'

function module.check_install ()
	assert(db, "требуется модуль db.lua")
	db.check_column('names', db.acctable, 'first_name', 'TEXT NOT NULL')
	db.check_column('names', db.acctable, 'last_name', 'TEXT NOT NULL')
	db.check_column('names', db.acctable, 'nickname',  'TEXT NOT NULL')
end

function module.start ()
    function db.oop:setName (name) self:set('nickname', name) end
    function db.oop:getName () return self.nickname ~= '' and self.nickname or module.setup_name(self) end
    function db.oop:r () return string.format('[id%s|%s]', self.vkid, self:getName()) end
	function db.oop:fullName ()
		if self.nickname == '' then module.setup_name(self) end
		return self.first_name .. ' ' .. self.last_name
	end

	bot.add_check(function (msg)
		local body = string.lower(msg.text or '')
		for i = 1, #module.bot_names, 1 do
			if body:starts(module.bot_names[i]) then
				msg.text = string.sub(msg.text or '', #module.bot_names[i] + 1)
				module.clear(msg)
				return true
			end
		end
		if not ischat(msg) then module.clear(msg) return true end
		if body:find("%[club" .. module.bcon .. "|.-%]") then module.clear(msg); return true end
		if msg.fwd_messages[1] and msg.fwd_messages[1].from_id == -module.bcon then module.clear(msg); return true end
		return false
	end)

	bot.add_post(function (msg, other, user, rmsg)
		if other.sendname then
			rmsg.message = user:getName()..", "..rmsg.message
		end
	end)
end

function module.clear (msg)
	msg.text = string.gsub(msg.text,"%[club" .. module.bcon .. "|.-%]",'')
	while msg.text:starts ' ' or msg.text:starts ',' do
		msg.text = string.sub(msg.text, 2)
	end
end

function module.setup_name (user)
	local userdata = VK.users.get { user_ids = user.vkid }["response"][1]

	db(
		"UPDATE `%s` SET `first_name`='%s', `last_name`='%s', `nickname`='%s' WHERE `vkid`=%i",
		db.acctable, userdata.first_name, userdata.last_name, userdata.first_name, user.vkid
	)

	return userdata.first_name
end

function module.r (userid)
	 return db.get_user(userid):r()
end

function module.dbr (user)
	 return string.format('[id%s|%s]', user.vkid, (user.nickname ~= '' and user.nickname or module.setup_name(user)))
end

return module
