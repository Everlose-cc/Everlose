local Stats = wax.shared.Services.Stats

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

function ClientUtils.FindFirstChildOr(Parent, ...)
	for _, Name in { ... } do
		local Found = Parent:FindFirstChild(Name)
		if Found then
			return Found
		end
	end
	return nil
end

function ClientUtils.RandomStr(Length: number): string
	local Result = ""
	for _ = 1, Length do
		Result = Result .. string.char(math.random(65, 122))
	end
	return Result
end

function ClientUtils.GetPing(): number
	local Set = 8
	local Old = getthreadidentity()
	setthreadidentity(Set)
	local Ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
	if Set ~= Old then
		setthreadidentity(Old)
	end
	return Ping
end

function ClientUtils.ServerTick(): number
	return workspace:GetServerTimeNow()
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
