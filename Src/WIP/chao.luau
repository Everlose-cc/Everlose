--!nocheck

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

repeat
	task.wait(1 / 60)
until game:IsLoaded()

local player = Players.LocalPlayer

local superconnections: { RBXScriptConnection } = {}
local connections: { RBXScriptConnection } = {}
local running = false

local rotationAngle = CFrame.Angles(math.rad(90), 0, 0)

local function loadAnimation(humanoid: Humanoid): AnimationTrack
	local Anim = Instance.new("Animation")
	Anim.AnimationId = "rbxassetid://215384594"

	local AnimTrack: AnimationTrack = humanoid:WaitForChild("Animator"):LoadAnimation(Anim)
	AnimTrack.Looped = true
	AnimTrack.Priority = Enum.AnimationPriority.Action4

	return AnimTrack
end

local isfp = function(): boolean
	local camera = workspace.CurrentCamera

	local distance = (camera.Focus.Position - camera.CFrame.Position).Magnitude
	-- local transparency = (distance < 1) and 1 or 0.5

	return (distance < 1)
end

local function disconnect(t: { RBXScriptConnection })
	for _, conn in t do
		conn:Disconnect()
	end
	table.clear(t)
end

local function stop()
	running = false
	for i = 1, 10 do
		RunService.Heartbeat:Wait()
	end
end

local function start()
	if not player.Character or not player.Character.Parent then
		return
	end

	stop()
	running = true

	local CamPos = Instance.new("Part")
	CamPos.Anchored = true
	CamPos.CanQuery = false
	CamPos.CanCollide = false
	CamPos.CanTouch = false
	CamPos.Transparency = 1
	CamPos.Size = Vector3.one
	CamPos.Name = "campos"

	local parts: { BasePart } = {}
	local accessories: { BasePart } = {}

	local character = player.Character
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	local humanoidRootPart: Part = character:WaitForChild("HumanoidRootPart")

	local AnimTrack = loadAnimation(humanoid)

	local function handleInstance(c: Instance)
		if c:IsA("BasePart") then
			if not c.Parent:IsA("Accessory") then
				table.insert(parts, c)
			else
				table.insert(accessories, c)
			end
		end
	end

	for _, c in character:GetDescendants() do
		task.spawn(handleInstance, c)
	end

	local dsc = character.DescendantAdded:Connect(handleInstance)
	local rsc = RunService.Heartbeat:Connect(function(dt: number)
		local camera = workspace.CurrentCamera

		if not player.Character or player.Character ~= character or not running then
			disconnect(connections)
			if AnimTrack then
				AnimTrack:Stop()
			end
			for _, part in parts do
				part.LocalTransparencyModifier = 0
			end
			for _, acc in accessories do
				acc.LocalTransparencyModifier = 0
			end
			camera.CameraSubject = humanoid
			return
		end

		local oldcf = humanoidRootPart.CFrame

		local _, y, _ = oldcf:ToOrientation()
		humanoidRootPart.CFrame = CFrame.new(oldcf.Position) * CFrame.Angles(0, y, 0)
		humanoidRootPart.CFrame *= rotationAngle

		AnimTrack:Play(0, 1e17, 0)
		AnimTrack.TimePosition = 0.3

		CamPos.CFrame = oldcf * CFrame.new(Vector3.yAxis * (humanoidRootPart.Size.Y / 1.5))
		camera.CameraSubject = CamPos

		RunService.RenderStepped:Wait()

		AnimTrack:Stop(0)

		humanoidRootPart.CFrame = oldcf
		camera.CameraSubject = humanoid

		local fp = isfp()
		for _, part in parts do
			local transparency = (part.Name == "Head" and fp and 1) or 0.5
			part.LocalTransparencyModifier = transparency
		end
		for _, acc in accessories do
			local transparency = (fp and 1) or 0.5
			acc.LocalTransparencyModifier = transparency
		end
	end)

	table.insert(connections, dsc)
	table.insert(connections, rsc)
	table.insert(superconnections, dsc)
	table.insert(superconnections, rsc)
end

if player.Character then
	start()
end
local charadded
charadded = player.CharacterAdded:Connect(start)
table.insert(superconnections, charadded)

_G.pls = true
shared.start = start

repeat
	task.wait(1 / 60)
until not _G.pls

stop()

shared.start = nil
disconnect(superconnections)
disconnect(connections)
