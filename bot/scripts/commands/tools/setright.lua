--[[
    Принудительная смена роли.
    botcmd.mcreate("команда", "описание", "инструкция", "аргументы", "смайл"[, { ... }])
]]
local command = botcmd.mcreate("сетроль", "изменить роль пользователя", "<цель> [роль]", "U", "🎫", {right="setrole"})

function command.exe(msg, args, other, rmsg, user, target)
	local newrole = args[3] or 'default'
	ca (rights.roles[newrole], "такого права не бывает")
	ca (user:isRight ('setrole.'..newrole), "вы не можете ставить такое право")
	ca (user:isRight ('setrole.'..target.role), "вы не можете снимать с такого права")

	rmsg:lines(
		{ "🎫 %s", target:r() },
		{ "📝 %s » %s", target:getRoleName(), rights.roles[newrole].screenname }
	)
	target:set('role', newrole=='default' and '' or newrole)
end

return command
