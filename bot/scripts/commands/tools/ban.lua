--[[
    Бот не обрабатывает сообщение забаненного пользователя.
    botcmd.mcreate("команда", "описание", "инструкция", "аргументы", "смайл"[, { ... }])
]]
local command = botcmd.mcreate("бан", "забанить пользователя", "<цель> [время в секундах]", "U", "🚷", {right="ban"})

function command.exe(msg, args, other, rmsg, user, target)
    ca(user:isRight('ban.'..target.right), "ты не можешь его забанить")
	local limit = user:getValue 'maxbantime'

	if tonumber(args[3]) then -- Если указано время
		local bantime = tonumber(args[3])
        ca(limit == -1 or bantime <= limit, "максимальный лимит бана "..limit.." секунд.")
        target:banUser(bantime)
		rmsg:line("🚷 %s забанен на %s", target:r(), os.date("!%D дней %H часов %M минут %S секунд", bantime))
	else
        ca(limit == -1, "максимальный лимит бана "..limit.." секунд.")
		target:banUser()
		rmsg:line("🚷 %s забанен навсегда", target:r())
	end
end

return command
