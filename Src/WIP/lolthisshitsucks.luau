--!nocheck

local raw = getrawmetatable(game)

oth.hook(raw.__namecall, function(...)
    local self = select(1, ...)

    local caller = checkcaller()
    local method = getnamecallmethod()

    if not caller then
        if self == workspace then
            if method == "Raycast"
        end
    end

    return oth.get_root_callback()(...)
end)