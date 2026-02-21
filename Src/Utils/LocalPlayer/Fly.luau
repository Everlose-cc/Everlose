--!nocheck

local FlyModule = {
	Instances = {},
}
FlyModule.__index = FlyModule

local RunningSelf = nil

function FlyModule.Setup()
	FlyModule:Cleanup()

	local Character: Model? = wax.shared.LocalCharacter

	local Library: Library = wax.shared.Library
	local Options = Library.Options

	local Services = wax.shared.Services
	local ConnectionsHandler = wax.shared.ConnectionsHandler

	local RunService: RunService = Services:GetService("RunService")
	local UserInputService: UserInputService = Services:GetService("UserInputService")

	local Humanoid: Humanoid? = wax.shared.WaitForChildOfClass(Character, "Humanoid", 5)
	local HumanoidRootPart: BasePart? = Character:FindFirstChild("HumanoidRootPart")

	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.P = 9e4
	BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	BodyGyro.CFrame = HumanoidRootPart.CFrame

	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Velocity = Vector3.new(0, 0, 0)
	BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	local Directions = {
        Left = 0,
        Right = 0,

        Front = 0,
        Back = 0,

        Up = 0,
        Down = 0,
    }

	local self = setmetatable({
		Connections = {
            ConnectionsHandler:GiveSignal(UserInputService.InputBegan, function(Input: InputObject, GameProcessed: boolean)
                if GameProcessed then return end
                if Input.KeyCode == Enum.KeyCode.A then
                    Directions.Left = -1
                elseif Input.KeyCode == Enum.KeyCode.D then
                    Directions.Right = 1
                elseif Input.KeyCode == Enum.KeyCode.W then
                    Directions.Front = 1
                elseif Input.KeyCode == Enum.KeyCode.S then
                    Directions.Back = -1
                elseif Input.KeyCode == Enum.KeyCode.Space then
                    Directions.Up = 1
                elseif Input.KeyCode == Enum.KeyCode.LeftControl then
                    Directions.Down = -1
                end
            end),
            ConnectionsHandler:GiveSignal(UserInputService.InputEnded, function(Input: InputObject, GameProcessed: boolean)
                if GameProcessed then return end
                if Input.KeyCode == Enum.KeyCode.A then
                    Directions.Left = 0
                elseif Input.KeyCode == Enum.KeyCode.D then
                    Directions.Right = 0
                elseif Input.KeyCode == Enum.KeyCode.W then
                    Directions.Front = 0
                elseif Input.KeyCode == Enum.KeyCode.S then
                    Directions.Back = 0
                elseif Input.KeyCode == Enum.KeyCode.Space then
                    Directions.Up = 0
                elseif Input.KeyCode == Enum.KeyCode.LeftControl then
                    Directions.Down = 0
                end
            end),
			ConnectionsHandler:GiveSignal(RunService.Heartbeat, function(dt: number)
				if not Humanoid or not HumanoidRootPart then
					return
				end
				local Camera = workspace.CurrentCamera
				if
					(Directions.Left + Directions.Right) ~= 0
					or (Directions.Front + Directions.Back) ~= 0
					or (Directions.Down + Directions.Up) ~= 0
				then
					BodyVelocity.Velocity = (
						(Camera.CFrame.LookVector * (Directions.Front + Directions.Back))
						+ (
							(
								Camera.CFrame
								* CFrame.new(
									Directions.Left + Directions.Right,
									(Directions.Front + Directions.Back + Directions.Down + Directions.Up) * 0.2,
									0
								).Position
							) - Camera.CFrame.Position
						)
					) * Options.FlySpeedSlider.Value
				else
					BodyVelocity.Velocity = Vector3.new(0, 0, 0)
				end

				local NormalizedPos, NormalizedLV =
					Vector3.new(Camera.CFrame.Position.X, 0, Camera.CFrame.Position.Z),
					Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
				BodyGyro.CFrame = CFrame.lookAt(NormalizedPos, NormalizedPos + NormalizedLV)
			end),
		},
	}, FlyModule)

	function self:Enable()
		if not HumanoidRootPart then
			return
		end
		if BodyGyro then
			BodyGyro.Parent = HumanoidRootPart
		end
		if BodyVelocity then
			BodyVelocity.Parent = HumanoidRootPart
		end
	end

	function self:Disable()
		if BodyGyro then
			BodyGyro.Parent = nil
		end
		if BodyVelocity then
			BodyVelocity.Parent = nil
		end
	end

	function self:Destroy()
		BodyGyro:Destroy()
		BodyVelocity:Destroy()
		self.FlyConnection:Disconnect()
	end

	if Character then
		if Humanoid and HumanoidRootPart then
			ConnectionsHandler:GiveSignal(RunService.Heartbeat, function()
				if not Humanoid or not HumanoidRootPart then
					return
				end

				local MoveDirection: Vector3 = Humanoid.MoveDirection

				BodyGyro.CFrame = HumanoidRootPart.CFrame + MoveDirection
				BodyVelocity.Velocity = MoveDirection * (Options.FlySpeedSlider.Value or 10)
			end)
		end
	end

	RunningSelf = self
	return self
end

function FlyModule.Cleanup()
	if RunningSelf then
		for _, Connection in RunningSelf.Connections do
            Connection:Disconnect()
        end
	end
	for _, Instance: Instance in FlyModule.Instances do
		Instance:Destroy()
	end
end

return FlyModule
