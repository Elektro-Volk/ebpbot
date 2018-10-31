--[[
    Наипростейшая команда, которая всегда выводит одно и то же.
    botcmd.create("команда", "описание", "смайл"[, { ... }])
]]
local command = botcmd.create("тест", "проверка бота", "✅")

function command.exe (msg, args, other, rmsg, user)
    return "✅ Бот работает."
end

return command
