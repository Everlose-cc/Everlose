--!nocheck

return function()
    local Library: Library = wax.shared.Library

    local Tabs = wax.shared.Tabs

    local ThemeManager = wax.shared.ThemeManager
    local SaveManager = wax.shared.SaveManager

	ThemeManager:SetLibrary(Library)
	SaveManager:SetLibrary(Library)

	SaveManager:IgnoreThemeSettings()

	-- SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

	ThemeManager:SetFolder('EverloseObsidian')
	SaveManager:SetFolder('EverloseObsidian/'..tostring(game.GameId))
	SaveManager:SetSubFolder(tostring(game.PlaceId))

	SaveManager:BuildConfigSection(Tabs['UISettings'])

	ThemeManager:ApplyToTab(Tabs['UISettings'])

	SaveManager:LoadAutoloadConfig()
end