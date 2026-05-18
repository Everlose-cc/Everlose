local Janitor: Janitor = wax.shared.Janitor

local LocalPlayer: Player = wax.shared.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function HandleCharAdded(Char: Model)
	wax.shared.Character = Char
	wax.shared.HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")
	wax.shared.Head = Char:WaitForChild("Head")
	wax.shared.Humanoid = Char:WaitForChild("Humanoid")
end

local ClientUtils = {}

function ClientUtils.GetPositionOnScreen(Vector: Vector3)
	local Camera = workspace.CurrentCamera

	local Vec3, OnScreen = Camera:WorldToScreenPoint(Vector)
	return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

function ClientUtils.GetMouseRay()
	return Mouse.UnitRay.Origin, Mouse.UnitRay.Direction
end

function ClientUtils.GetPing()
	return wax.shared.Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end

function ClientUtils.GetFPS()
	-- return wax.shared.Services.Stats.FrameRateManager["AverageFPS"]:GetValue()
	return wax.shared.Services.Stats.Workspace["Heartbeat"]:GetValue()
end

if LocalPlayer.Character then
	HandleCharAdded(LocalPlayer.Character)
end
Janitor:Add(LocalPlayer.CharacterAdded:Connect(HandleCharAdded))
Janitor:Add(LocalPlayer.CharacterRemoving:Connect(function(Char: Model)
	wax.shared.Character = nil
	wax.shared.HumanoidRootPart = nil
	wax.shared.Head = nil
	wax.shared.Humanoid = nil
end))

--[[
local fps = ClientUtils.GetFPS()
local str = "%.1"
local form = string.format(str, fps)
warn(form)
]]

return ClientUtils
