local LocalPlayer = wax.shared.LocalPlayer
local ConnectionsHandler = wax.shared.ConnectionsHandler

local Library: Library = wax.shared.Library

local Toggles = Library.Toggles
local Options = Library.Options

return function(Character: Model)
	local FlyModule = wax.shared.FlyModule

	assert(Character == LocalPlayer.Character, "Expected Local Player's Character.")

	wax.shared.LocalCharacter = Character
	local Humanoid = wax.shared.WaitForChildOfClass(Character, "Humanoid", 5)
	if Humanoid then
		wax.shared.LocalHumanoid = Humanoid
		wax.shared.CurrentFly = FlyModule.Setup()

		ConnectionsHandler:GiveSignal(Humanoid:GetPropertyChangedSignal("WalkSpeed"), function()
			local IsWalkSpeedDown: boolean = (Options.WalkSpeedToggleBind:GetState() and Toggles.WalkSpeedToggle.Value)
				or false
			if IsWalkSpeedDown then
				Humanoid.WalkSpeed = Options.WalkSpeedSlider.Value / 1
			end
		end)
		ConnectionsHandler:GiveSignal(Humanoid:GetPropertyChangedSignal("JumpPower"), function()
			local IsJumpPowerDown: boolean = (Options.JumpPowerToggleBind:GetState() and Toggles.JumpPowerToggle.Value)
				or false
			if IsJumpPowerDown then
				Humanoid.JumpPower = Options.JumpPowerSlider.Value / 1
			end
		end)
		ConnectionsHandler:GiveSignal(Humanoid:GetPropertyChangedSignal("JumpHeight"), function()
			local IsJumpHeightDown: boolean = (
				Options.JumpHeightToggleBind:GetState() and Toggles.JumpHeightToggle.Value
			) or false
			if IsJumpHeightDown then
				Humanoid.JumpHeight = Options.JumpHeightSlider.Value / 6.944444444444444
			end
		end)
	end
end
