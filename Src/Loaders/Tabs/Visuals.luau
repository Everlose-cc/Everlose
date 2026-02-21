--!nocheck

return function()
	wax.shared.ESPCache = {
		Players = {},
	}

    local ESPLibrary = wax.shared.EspLibrary

	-- local Library: Library = wax.shared.Library
	-- local Window: Window = wax.shared.Window
	local Tabs: { [string]: Tab } = wax.shared.Tabs

	local Services = wax.shared.Services
	local Visuals = Tabs["Visuals"]

    local Players: Players = Services:GetService("Players")
	local TextChatService: TextChatService = Services:GetService("TextChatService")

	local LeftTabBox = Visuals:AddLeftTabbox({
		Title = "ESP",
	})
	local RightGroupbox = Visuals:AddRightGroupbox("Misc")

	local ESP, EspSettings = LeftTabBox:AddTab("ESP"), LeftTabBox:AddTab("Settings")

	local PlayerEsp = ESP:AddToggle("PlayerEsp", {
		Text = "Player",
		Default = false,
		Callback = function(Value: boolean)
			for _, ESP in wax.shared.ESPCache.Players do
				if Value then
					ESP:Show()
				else
					ESP:Hide()
				end
			end
		end,
	})
	PlayerEsp:AddColorPicker("PlayerEspColor", {
		Default = Color3.new(1, 1, 1),
		Title = "Player Esp Color",
		Callback = function(Color: Color3)
			for _, ESP in wax.shared.ESPCache.Players do
				local S, E = pcall(function()
					local PlrFromChar = Players:GetPlayerFromCharacter(ESP.CurrentSettings.Model)
					if PlrFromChar then
						local FinalColor: Color3 = (PlrFromChar.Team == nil and Color or PlrFromChar.TeamColor.Color)
						ESP:SetEveryColor(FinalColor, true)
					end
				end)
				if not S then
					warn(E)
				end
			end
		end,
	})

	EspSettings:AddDropdown("EspType", {
		Values = { "Text", "SphereAdornment", "CylinderAdornment", "Adornment", "SelectionBox", "Highlight" },
		Default = "Highlight",
		Multi = false,
		Text = "Esp Type",
		Searchable = true,
	})
	EspSettings:AddSlider("TextSize", {
		Text = "Text Size",
		Default = 16,
		Min = 16,
		Max = 26,
		Rounding = 1,
		Compact = true,
		Callback = function(Value: number)
			for _, ESP in wax.shared.ESPCache.Players do
				ESP.CurrentSettings.TextSize = Value
			end
		end,
	})
	EspSettings:AddToggle("RainbowEsp", {
		Text = "Rainbow Esp",
		Default = false,
		Callback = function(Value: boolean)
			ESPLibrary.GlobalConfig.Rainbow = Value
		end,
	})
	local Tracers = EspSettings:AddToggle("Tracers", {
		Text = "Tracers",
		Default = false,
		Callback = function(Value: boolean)
			ESPLibrary.GlobalConfig.Tracers = Value
			for _, ESP in ESPLibrary.ESP do
				ESP.CurrentSettings.Tracer.Enabled = Value
			end
		end,
	})
	EspSettings:AddDropdown("TracerStartPos", {
		Values = { "Bottom", "Center", "Top", "Mouse" },
		Default = "Bottom",
		Multi = false,
		Text = "Tracer Start Position",
		Searchable = true,
		Callback = function(Value: string)
			for _, ESP in ESPLibrary.ESP do
				ESP.CurrentSettings.Tracer.From = Value:lower()
			end
		end,
	})
	local Arrows = EspSettings:AddToggle("Arrows", {
		Text = "Arrows",
		Default = false,
		Callback = function(Value: boolean)
			ESPLibrary.GlobalConfig.Arrows = Value
			for _, ESP in ESPLibrary.ESP do
				ESP.CurrentSettings.Arrow.Enabled = Value
			end
		end,
	})
	local Fonts = Enum.Font:GetEnumItems()
	EspSettings:AddDropdown("EspFont", {
		Values = Fonts,
		Default = Fonts[1],
		Multi = false,
		Text = "Font",
		Searchable = true,
		Callback = function(Value: Enum.Font)
			ESPLibrary.GlobalConfig.Font = Value
		end,
	})

	ESPLibrary.GlobalConfig.Arrows = Arrows.Value
	ESPLibrary.GlobalConfig.Tracers = Tracers.Value
	ESPLibrary.GlobalConfig.Boxes2D = false
	ESPLibrary.GlobalConfig.Boxes3D = false
	ESPLibrary.GlobalConfig.Skeleton = false

	RightGroupbox:AddToggle("ChatWindow", {
		Text = "Chat Window",
		Default = false,
		Callback = function(Value: boolean)
			TextChatService.ChatWindowConfiguration.Enabled = Value
		end,
	})
end