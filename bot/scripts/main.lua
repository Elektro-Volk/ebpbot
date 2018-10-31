connect "scripts/tokens"

names.bot_names = { 'атб' }
admin = 169494689
lasts = { }

-- TOEBP
function check_module(module) if not _ENV[module] then error("требуется модуль "..module, 2) end end

function menu_execute(msg, other, user)
    --return { message = "сам "..msg.text }
end

bot.executes = { numcmd.execute, botcmd.execute, menu_execute }
bot.add_check(function (msg) if not msg.text or msg.text == '' then return false end end)
