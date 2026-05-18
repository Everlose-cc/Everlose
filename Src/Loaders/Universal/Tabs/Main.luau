return function()
	wax.shared.DefaultValues = {
		["Humanoid"] = {
			WalkSpeed = 16,
		},
	}

	local Library: Library = wax.shared.Library
	local Window: Window = wax.shared.Window

	local Toggles = Library.Toggles
	local Options = Library.Options

	local MainTab = Window:AddTab({
		Name = "Main",
		Icon = "circle-user-round",
		Description = "Main features such as Speed, Jump, and more.",
	})
	wax.shared.Tabs["MainTab"] = MainTab

	local function ResetWalkSpeed()
		local IsWalkSpeedDown: boolean = (Options.SpeedKeybind:GetState() and Toggles.SpeedToggle.Value) or false
		local Humanoid: Humanoid = wax.shared.Humanoid
		if Humanoid then
			if IsWalkSpeedDown then
				Humanoid.WalkSpeed = Options.SpeedSlider.Value
			else
				Humanoid.WalkSpeed = wax.shared.DefaultValues.Humanoid.WalkSpeed
			end
		end
	end

	local CharMods = MainTab:AddLeftGroupbox("Char Mods")

	local SpeedToggle = CharMods:AddToggle("SpeedToggle", {
		Text = "WalkSpeed Toggle",
		Default = false,
		Callback = ResetWalkSpeed,
	})
	SpeedToggle:AddKeyPicker("SpeedKeybind", {
		Text = "WalkSpeed Keybind",
		Default = "V",
		Mode = "Toggle",
		Modes = { "Hold", "Toggle", "Always", "Press" },
		Callback = ResetWalkSpeed,
	})

	CharMods:AddSlider("SpeedSlider", {
		Text = "Speed Slider",
		Default = 16,
		Min = 16,
		Max = 500,
		Rounding = 0,
		Compact = true,
		Callback = ResetWalkSpeed,
	})

	CharMods:AddDivider()

	CharMods:AddToggle("AntiAfk", {
		Text = "Anti Afk",
		Default = false,
	})
	CharMods:AddToggle("InstantPP", {
		Text = "Instant Interact",
		Default = false,
	})
end
