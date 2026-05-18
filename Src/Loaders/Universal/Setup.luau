local ThisLoader = "Universal"

local function Load(Module: string)
    wax.shared.Load(ThisLoader, "Tabs", Module)
    wax.shared.Load(ThisLoader, "Functions", Module)
end

return function()
    Load("Main")
end