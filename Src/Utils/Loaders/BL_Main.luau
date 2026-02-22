return function()
	local Window: Window = wax.shared.Window
	require("./Default")()

	local BlackoutTabs = {
		['GunMods'] = Window:AddTab({
			Name = "Gun Mods",
			Icon = "circle-user-round",
            Description = "Gun Modifiers",
		}),
	}
    for TabName,Tab in BlackoutTabs do
        wax.shared.Tabs[TabName] = Tab
    end

	wax.shared.Load("Tabs", "Blackout", "Main")()
	wax.shared.Load("Tabs", "Blackout", "GunMods")()

	wax.shared.Load("Functions", "Blackout", "Main")()
	wax.shared.Load("Functions", "Blackout", "GunMods")()
end
