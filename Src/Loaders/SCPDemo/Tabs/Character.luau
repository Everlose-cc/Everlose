return function()
    local Window: Window = wax.shared.Window

    local CharacterTab = Window:AddTab({
		Name = "Character",
		Icon = "bug",
		Description = "Character Modifications",
	})
	wax.shared.Tabs["CharacterTab"] = CharacterTab

    local Movimentation = CharacterTab:AddLeftGroupbox("Movimentation")

    Movimentation:AddToggle("ISTAM", {
        Text = "Infinite Stamina",
        Default = false,
    })
end