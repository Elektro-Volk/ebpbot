--[[
    Здесь производится настройка системы прав вашего чудесного бота.
]]
return {
    creator = {
        screenname = 'Создатель',
        full = true,
        include = 'mainadmin'
    },

    mainadmin = {
        screenname = 'Главный администратор',
        ["right.ban.admin"] = true,
		["right.setrole.admin"] = true,
		include = 'admin'
    },

    admin = {
        screenname = 'Администратор',
        ["value.maxbantime"] = -1,
        ["right.ban.moderator"] = true,
        ["right.setrole"] = true,
        ["right.setrole.moderator"] = true,
        ["right.setrole.donat_moderator"] = true,
        ["right.setrole.vip"] = true,
        ["right.setrole."] = true,
        include = 'moderator'
    },

    moderator = {
        screenname = 'Модератор',
		["right.nick.other"] = true,
		["right.ban"] = true,
		["right.ban."] = true,
		["right.ban.vip"] = true,
		["right.ban.donat_moderator"] = true,
		["value.maxbantime"] = 86400,
        include = 'vip'
    },

    vip = {
        screenname = "VIP пользователь",
		include = 'default'
    },

    default = {
        screenname = 'Обычный пользователь'
    },
};
