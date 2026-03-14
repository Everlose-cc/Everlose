local LocalPlayer: Player = wax.shared.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

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
    return wax.shared.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end

function ClientUtils.GetFPS()
    return wax.shared.Stats.FrameRateManager["AverageFPS"]:GetValue()
end

return ClientUtils