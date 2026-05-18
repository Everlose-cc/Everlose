--!nocheck

local Games = {
	["Blackout"] = {
		15432890326, -- Main
		18243214051, -- Begineer
		86962919018787, -- Tutorial
	},
	["BlackoutTesting"] = {
		75512559571634, -- Blackout Testing Place
	},
	["Testing"] = {
		137172677882615, -- Testing Place
	},
	["SCPDemo"] = {
		6495459333,
	}
}

local Loader = {}

function Loader.GetLoader()
	for LoaderName, Places in Games do
		if table.find(Places, game.PlaceId) then
			return LoaderName
		end
	end
	return "Universal"
end

const LoadSettingsTab = function(ThemeManager, SaveManager, Library: Library, Window: Window)
	local Options = Library.Options

	--// UI Settings
    ----------------

	local UISettings = Window:AddTab({
		Name = "UISettings",
		Icon = "settings",
		Description = "UI Settings such as Theme, Menu Bind, etc.",
	})
	wax.shared.Tabs["UISettings"] = UISettings

    --// Setup
    ----------

	local MenuGroup = UISettings:AddLeftGroupbox("Menu", "wrench")

	MenuGroup:AddToggle("KeybindMenuOpen", {
		Default = false,
		Text = "Open Keybind Menu",
		Callback = function(Value: boolean)
			Library.KeybindFrame.Visible = Value
		end,
	})
	MenuGroup:AddToggle("ShowCustomCursor", {
		Default = true,
		Text = "Custom Cursor",
		Callback = function(Value: boolean)
			Library.ShowCustomCursor = Value
		end,
	})
	MenuGroup:AddDropdown("NotificationSide", {
		Values = { "Left", "Right" },
		Default = "Right",
		Text = "Notification Side",
		Callback = function(Value: string)
			Library:SetNotifySide(Value)
		end,
	})
	MenuGroup:AddDropdown("DPIDropdown", {
		Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
		Default = "100%",

		Text = "DPI Scale",

		Callback = function(Value: string | number)
			Value = Value:gsub("%%", "")
			local DPI = tonumber(Value)

			Library:SetDPIScale(DPI)
		end,
	})

	MenuGroup:AddDivider()

	local MenuBind = MenuGroup:AddLabel("Menu Bind")
	MenuBind:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
	MenuGroup:AddButton("Unload", shared.EverloseInternalUnload)

	Library.ToggleKeybind = Options.MenuKeybind

    --// Functions
    --------------

	ThemeManager:SetLibrary(Library)
	SaveManager:SetLibrary(Library)

	SaveManager:IgnoreThemeSettings()

	-- SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

	ThemeManager:SetFolder("EverloseReborn")
	SaveManager:SetFolder("EverloseReborn/" .. tostring(game.GameId))
	SaveManager:SetSubFolder(tostring(game.PlaceId))

	SaveManager:BuildConfigSection(UISettings)

	ThemeManager:ApplyToTab(UISettings)

	SaveManager:LoadAutoloadConfig()
end

function Loader.Setup()
	local LoaderToUse = Loader.GetLoader()
	local Info = table.pack(require("Loaders/" .. LoaderToUse .. "/Setup")())

	local ThemeManager = wax.shared.ThemeManager
	local SaveManager = wax.shared.SaveManager

	local Library: Library = wax.shared.Library
	local Window: Window = wax.shared.Window

	LoadSettingsTab(ThemeManager, SaveManager, Library, Window)

	return LoaderToUse, table.unpack(Info)
end

return Loader
