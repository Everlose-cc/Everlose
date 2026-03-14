local TweenService = cloneref(game:GetService("TweenService"))

local DefaultInfo = {
	Duration = 5,
	TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

local InstanceCache = wax.shared.InstanceCache

local Template = (function()
	local Folder = Instance.new("Folder")

	local A0 = Instance.new("Attachment")
	A0.Name = "A0"
	A0.Position = vector.zero
	A0.Parent = Folder

	local A1 = Instance.new("Attachment")
	A1.Name = "A1"
	A1.Position = vector.zero
	A1.Parent = Folder

	local NB = Instance.new("Beam")
	NB.Texture = "rbxassetid://446111271"
	NB.Brightness = 1
	NB.LightEmission = 1
	NB.LightInfluence = 0
	NB.TextureLength = 14
	NB.Width0 = 1
	NB.Width1 = 1
	NB.TextureSpeed = 2
	NB.ZOffset = 0
	NB.Segments = 10
	NB.CurveSize0 = 0
	NB.CurveSize1 = 0
	NB.Transparency = NumberSequence.new(0)

	NB.TextureMode = Enum.TextureMode.Wrap
	NB.Color = ColorSequence.new(Color3.new(1, 1, 1))
	NB.FaceCamera = true
	NB.Enabled = false

	NB.Attachment0 = A0
	NB.Attachment1 = A1

	NB.Parent = Folder

	return Folder
end)()

local BeamCache = InstanceCache(Template, 100, gethui())
wax.shared.Janitor:Add(BeamCache)

return function(From: Vector3, To: Vector3)
	local Inst: Folder = BeamCache:GetInstance()

	local A0 = Inst:FindFirstChild("A0")
	local A1 = Inst:FindFirstChild("A1")
	local Beam = Inst:FindFirstChild("Beam")

	Beam.Width0 = 1
	Beam.Width1 = 1

	local Tween = Inst:FindFirstChild("Tween")
		or TweenService:Create(Beam, DefaultInfo.TweenInfo, { Width0 = 0, Width1 = 0 })
	Tween.Parent = Inst

	A0.Position = From
	A1.Position = To
	Beam.Enabled = true

	Inst.Parent = workspace.Terrain

	local UID = newproxy(false)
	local Promise = wax.shared.Promise
		.new(function(resolve, reject, onCancel)
			task.wait(DefaultInfo.Duration)
			wax.shared.Janitor:Add(Tween.Completed:Once(resolve))
			Tween:Play()
			wax.shared.Janitor:RemoveNoClean(UID)
		end)
		:finally(function()
			wax.shared.Janitor:Remove(UID)
			Beam.Enabled = false
			BeamCache:ReturnInstance(Inst)
		end)
	wax.shared.Janitor:Add(Promise, "cancel", UID)
end
