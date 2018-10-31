local module = { class = {} }

function module.get()
    local rmsg = {}
    setmetatable(rmsg, { __index = module.class })
    return rmsg
end

-- Class --
function module.class:line (...)
    local str = string.format(...)
    addline(self, str)
    if not self.keyboard and str:starts '➡' and not str:find '<' then
        oneb(self, string.sub(str, 5))
    end
end

function module.class:lines (...)
    local lines = { ... }
    for i = 1,#lines do
        if type(lines[i]) == 'string' then
            self:line(lines[i])
        else
            if type(lines[i][1]) == 'table' then
                self:ltable(lines[i][1], lines[i][2], lines[i][3])
            else
                self:line(table.unpack(lines[i]))
            end
        end
    end
end

function module.class:ltable (t, str, count)
    for i = 1,(count or #t) do
        local line = str:gsub('@', i)
        for s in line:gmatch(':!.+:') do line = line:gsub(s, comma_value(t[i][s:sub(3, #s - 1)])) end
        for s in line:gmatch(':[^ ]+:') do line = line:gsub(s, t[i][s:sub(2, #s - 1)]) end
        self:line(line)
    end
end

function module.class:tip (...)
    self:line ('➡ ' .. string.format(...))
end

return module
