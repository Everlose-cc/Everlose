local function Load(a: string, Module: string)
    wax.shared.Load(a, "Tabs", Module)
    wax.shared.Load(a, "Functions", Module)
end

return function()
    Load("Universal", "Main")
    Load("Testing", "Exploits")
end