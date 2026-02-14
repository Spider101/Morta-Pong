-- class definition
class = {
    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, { __index = self })
        return tbl
    end
}

entity = class:new({
    x = 0,
    y = 0
})