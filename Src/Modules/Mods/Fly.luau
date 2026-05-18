--!nocheck

local RunService: RunService = wax.shared.Services.RunService

local InputModule = wax.shared.InputModule

local Active = false
local Speed = 1

local FlyModule = {}

local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.MaxForce = vector.one * 1000000000
BodyVelocity.P = 1250

local BodyGyro = Instance.new("BodyGyro")
BodyGyro.MaxTorque = vector.one * 1000000000
BodyGyro.D = 500
BodyGyro.P = 90000

RunService:BindToRenderStep("Fly", Enum.RenderPriority.Character.Value, function(dt: number)
	local Camera = workspace.CurrentCamera

	local CameraCF = Camera.CFrame
	local CameraDir = CameraCF.LookVector

	local Character: Model = wax.shared.Character
	local HumanoidRootPart: Part = Character ~= nil and Character:FindFirstChild("HumanoidRootPart") or nil

	local StartFlight = HumanoidRootPart ~= nil and Active

	if not StartFlight then
		BodyVelocity.Parent = nil
		BodyGyro.Parent = nil
	else
		BodyVelocity.Parent = HumanoidRootPart
		BodyGyro.Parent = HumanoidRootPart

		local FrontVelo = InputModule.IsKeyDown(Enum.KeyCode.W) and 1 or 0
		local RightVelo = InputModule.IsKeyDown(Enum.KeyCode.D) and 1 or 0
		local Top = InputModule.IsKeyDown(Enum.KeyCode.Space) and 1 or 0

		local BackVelo = InputModule.IsKeyDown(Enum.KeyCode.S) and -1 or 0
		local LeftVelo = InputModule.IsKeyDown(Enum.KeyCode.A) and -1 or 0
		local Bottom = InputModule.IsKeyDown(Enum.KeyCode.LeftControl) and -1 or 0

		local Can = FrontVelo + BackVelo ~= 0 or RightVelo + LeftVelo ~= 0 or Top + Bottom ~= 0

		if Can then
			BodyVelocity.Velocity = (
				CameraDir * (FrontVelo + BackVelo)
				+ (CameraCF * CFrame.new(LeftVelo + RightVelo, (FrontVelo + BackVelo + Bottom + Top) * 0.2, 0).Position)
				- CameraCF.Position
			) * Speed
		else
			BodyVelocity.Velocity = vector.zero
		end
	end
end)

function FlyModule:Start()
	Active = true
end

function FlyModule:Stop()
	Active = false
end

function FlyModule:Toggle()
	Active = not Active
end

function FlyModule:ChangeSpeed(Value: number)
    Speed = Value
end

function FlyModule:Destroy()
	BodyVelocity:Destroy()
	BodyGyro:Destroy()

	RunService:UnbindFromRenderStep("Fly")
end

return FlyModule