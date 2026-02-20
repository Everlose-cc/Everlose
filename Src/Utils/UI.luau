--!nocheck

local Library: Library = wax.shared.Library

local Window: Window = Library:CreateWindow({
    Title = 'Everlose',
	Footer = `Version: {'Alpha'}: {'1.0.0'}`,
	Icon = 89401785954152,
	NotifySide = 'Right',
	ShowCustomCursor = true,
})
local Tabs = {
    Main = Window:AddTab({
        Name = 'Main',
        Icon = 'circle-user-round',
        Description = 'Main features such as Speed, Jump, and more.',
    }),
    Visuals = Window:AddTab({
        Name = 'Visuals',
        Icon = 'eye',
        Description = 'Visual features such as ESP and Chams.',
    }),
    UISettings = Window:AddTab({
        Name = 'UI Settings',
        Icon = 'settings',
        Description = 'UI settings such as theme and layout.',
    }),
}

local SupportedGames = require('./SupportedGames')

wax.shared.Window = Window
wax.shared.Tabs = Tabs

for GameName, PlaceIds in SupportedGames do
    local LoaderToUse = PlaceIds[game.PlaceId]
    if LoaderToUse then
        require('Loaders/'..LoaderToUse)()
    end
end

return {
    Window = Window,
    Tabs = Tabs,
    Library = Library,
}