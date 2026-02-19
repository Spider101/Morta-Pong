-- enum

Enum = {
    init = function(_, ...)
        local enum_tbl = {}
        local tbl = { ... }
        for i, v in ipairs(tbl) do
            enum_tbl[v] = i
        end
        -- printh(enum_tbl, "log")
        return enum_tbl
    end
}

setmetatable(
    Enum, {
        __call = function(_, ...) return Enum:init(...) end
    }
)