local module = {}

function module.check_install ()
    check_module 'db'
    db.check_column('role', db.acctable, 'role', 'TEXT NOT NULL')
end

function module.start ()
    function db.oop:isRight (right) return module.is_right(self.role, right) end
    function db.oop:getValue (value) return module.get_value(self.role, value) end
    function db.oop:getRole () return module.get_type(self.role) end
    function db.oop:getRoleName () return self:getRight ().screenname end

    module.roles = dofile(root .. '/settings/roles.lua')

    if botcmd then
        botcmd.reg_pre(function (msg, args, other, command, user)
    		return command.right and not user:isRight (command.right) and { message = command.rerror or 'У вас нет прав.' }
    	end)
    end
end

function module.get_type (typename)
    return module.roles[typename == '' and 'default' or typename]
end

function module.is_right (typename, right)
    local type = module.get_type(typename)
    return type['full'] or type['right.'..right] or (type['include'] and module.is_right(type["include"], right))
end

function module.get_value (typename, val)
    local type = module.get_type(typename)
    return type['value.'..val] or (type['include'] and module.get_value(type["include"], val))
end

return module
