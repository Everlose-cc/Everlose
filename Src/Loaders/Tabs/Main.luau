--!nocheck

return function()
	local Library: Library = wax.shared.Library
	local Options = Library.Options
	local Toggles = Library.Toggles
	local MainTab: Tab = wax.shared.Tabs["Main"]

	local PlayerGroupbox = MainTab:AddLeftGroupbox("Player")
	local CharacterGroupbox = MainTab:AddLeftGroupbox("Character")

	local ThreadsHandler = wax.shared.ThreadsHandler

	PlayerGroupbox:AddToggle("AntiAfk", {
		Text = "Anti Afk",
		Default = false,
		Tooltip = "Prevents you from being kicked for being idle.",
	})
    PlayerGroupbox:AddToggle("InstantPP", {
		Text = "Instant Proximity Prompt",
		Default = false,
		Tooltip = "Makes all proximity prompts trigger instantly.",
	})

	local function ResetWalkSpeed()
		local Humanoid: Humanoid = wax.shared.LocalHumanoid
		local IsWalkSpeedDown: boolean = (Options.WalkSpeedToggleBind:GetState() and Toggles.WalkSpeedToggle.Value)
			or false
		if Humanoid then
			if not IsWalkSpeedDown then
				if Humanoid then
					ThreadsHandler:GiveThread(task.defer(function()
						Humanoid.WalkSpeed = wax.shared.DefaultValues["Humanoid"]["WalkSpeed"]
					end))
				end
			else
				Humanoid.WalkSpeed = Options.WalkSpeedSlider.Value
			end
		end
	end

	local WalkSpeedToggle = CharacterGroupbox:AddToggle("WalkSpeedToggle", {
		Text = "WalkSpeed",
		Default = false,
		Callback = ResetWalkSpeed,
	})
	WalkSpeedToggle:AddKeyPicker("WalkSpeedToggleBind", {
		Text = "Toggle Keybind",
		Default = "V",
		Mode = "Toggle",
		Modes = { "Hold", "Toggle", "Always", "Press" },
		Callback = ResetWalkSpeed,
	})
	CharacterGroupbox:AddSlider("WalkSpeedSlider", {
		Text = "WalkSpeed",
		Default = 16,
		Min = 16,
		Max = 500,
		Rounding = 1,
		Compact = true,
		Callback = ResetWalkSpeed,
	})
end
