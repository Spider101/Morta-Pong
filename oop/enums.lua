-- enum

Enum = {
    init = function(_, ...)
        local enum_tbl = {}
        local tbl = { ... }
        for i, v in pairs(tbl) do
            enum_tbl[v] = i - 1 // enums are 0-indexed by convention
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