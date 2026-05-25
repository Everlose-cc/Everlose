--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local Remotes = {
	Gun_Shoot = Events.GNX_S,
	Gun_Reload = Events.GNX_R,
	Gun_Hit = Events.ZFKLF_H,
}

local rayHandler = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RayHandler"))

--[=[
	Remotes.Gun_Shoot:FireServer(
		SaltC, --Salt
		Shootcode, --ShootCode
		Tool, --Weapon
		"FDS9I83", --Remote validation key
		BulletOrigin, --Origin (Vector3)
		Directions, --Bullet Directions
		BulletType --Bullet type
	)
]=]

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local function getIntersection(origin: Vector3, to: Vector3)
	local old = getthreadidentity()
	setthreadidentity(8)

	local hitPart, hitPoint, hitNormal, hitMaterial, extraInfo = rayHandler.CastRay(
		Ray.new(origin, to),
		{},
		{ type = "g", cg = "Default" },
		true
	)

	if old ~= 8 then
		setthreadidentity(old)
	end

	return {
		hitPart = hitPart,
		hitPoint = hitPoint,
		hitNormal = hitNormal,
		hitMaterial = hitMaterial,
		extraInfo = extraInfo,
	}
end

local raw = getrawmetatable(game)
oth.hook(raw.__namecall, function(...): ...any
	local root = oth.get_root_callback()

	local self = select(1, ...)

	local method = getnamecallmethod()
	local caller = checkcaller()

	local character = LocalPlayer.Character
	local target = Players.criadorde39.Character
	local targetPos = target.Head.Position

	if not caller then
		if self.Name:lower() == "gnx_s" then
			if method:lower() == "fireserver" then
				local _saltC = select(2, ...)
				local _shootCode = select(3, ...)
				local _tool = select(4, ...)
				local _code = select(5, ...)
				local origin = select(6, ...)
				local directions = select(7, ...)
				local _bulletType = select(8, ...)

				local hit = getIntersection(origin, targetPos)

                local dir = hit.hitPoint - origin

				for idx in directions do
					directions[idx] = dir.Unit
				end
			end
		end
	end

	return root(...)
end)
