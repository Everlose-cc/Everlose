local LocalPlayer: Player = wax.shared.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local MouseModule = {}

function MouseModule.GetPositionOnScreen(Vector: Vector3)
    local Camera = workspace.CurrentCamera

	local Vec3, OnScreen = Camera:WorldToScreenPoint(Vector)
	return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

function MouseModule.GetMouseRay()
    return Mouse.UnitRay.Origin, Mouse.UnitRay.Direction
end

return MouseModule