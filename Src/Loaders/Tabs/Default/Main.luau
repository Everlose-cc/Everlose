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

	local function ResetJumpPower()
		local Humanoid: Humanoid = wax.shared.LocalHumanoid
		local IsJumpPowerDown: boolean = (Options.JumpPowerToggleBind:GetState() and Toggles.JumpPowerToggle.Value)
			or false
		if Humanoid then
			if not IsJumpPowerDown then
				if Humanoid then
					ThreadsHandler:GiveThread(task.defer(function()
						Humanoid.JumpPower = wax.shared.DefaultValues["Humanoid"]["JumpPower"]
						Humanoid.JumpHeight = wax.shared.DefaultValues["Humanoid"]["JumpHeight"]
					end))
				end
			else
				Humanoid.JumpPower = Options.JumpPowerSlider.Value
				Humanoid.JumpHeight = Options.JumpPowerSlider.Value / 6.944444444444444
			end
		end
	end

	local function ResetFly()
		local IsFlyDown: boolean = (Options.FlyToggleBind:GetState() and Toggles.FlyToggle.Value) or false
		if not IsFlyDown then
			wax.shared.CurrentFly:Disable()
		else
			wax.shared.CurrentFly:Enable()
		end
	end

	CharacterGroupbox:AddDivider("WalkSpeed")

	local WalkSpeedToggle = CharacterGroupbox:AddToggle("WalkSpeedToggle", {
		Text = "WalkSpeed",
		Default = false,
		Callback = ResetWalkSpeed,
	})
	WalkSpeedToggle:AddKeyPicker("WalkSpeedToggleBind", {
		Text = "WalkSpeed Keybind",
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

	CharacterGroupbox:AddDivider("JumpPower")

	local JumpPowerToggle = CharacterGroupbox:AddToggle("JumpPowerToggle", {
		Text = "JumpPower",
		Default = false,
		Callback = ResetJumpPower,
	})
	JumpPowerToggle:AddKeyPicker("JumpPowerToggleBind", {
		Text = "JumpPower Keybind",
		Default = "J",
		Mode = "Toggle",
		Modes = { "Hold", "Toggle", "Always" },
		Callback = ResetJumpPower,
	})
	CharacterGroupbox:AddSlider("JumpPowerSlider", {
		Text = "JumpPower",
		Default = 50,
		Min = 50,
		Max = 200,
		Rounding = 1,
		Compact = true,
		Callback = ResetJumpPower,
	})

	CharacterGroupbox:AddDivider("Fly")

	local FlyToggle = CharacterGroupbox:AddToggle("FlyToggle", {
		Text = "Fly",
		Default = false,
		Callback = ResetFly,
	})
	FlyToggle:AddKeyPicker("FlyToggleBind", {
		Text = "Fly Keybind",
		Default = "F",
		Mode = "Toggle",
		Modes = { "Hold", "Toggle", "Always" },
		Callback = ResetFly,
	})
	CharacterGroupbox:AddSlider("FlySpeedSlider", {
		Text = "Fly Speed",
		Default = 10,
		Min = 10,
		Max = 500,
		Rounding = 1,
		Compact = true,
		Callback = ResetFly,
	})
end
