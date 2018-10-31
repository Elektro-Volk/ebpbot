--[[
    Пример команды с аргументами.
    botcmd.mcreate("команда", "описание", "инструкция", "аргументы", "смайл"[, { ... }])
]]
local command = botcmd.mcreate("обнять", "Обнимашки ^-^", "<цель>", "U", "💖")


function command.exe(msg, args, other, rmsg, user, target)
    rmsg:line ("💖 %s обнял %s %s", user:r(), target:r(), trand{'сзади', 'спереди', 'слева', 'справа', 'снизу', 'сверху'})
end

return command
