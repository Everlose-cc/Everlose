--!nocheck

--[=[
oth.hook(getrawmetatable(game).__namecall, function(self, ...)
	local method = getnamecallmethod()

	if not checkcaller() then
		if self.Name == "__RZDONL" and method == "FireServer" then
			local remoteType: string = select(1, ...)
			if (remoteType == "FlllD" or remoteType == "FllH") then
				return
			end
		end
	end

	return oth.get_root_callback()(self, ...)
end)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage.Events.__RZDONL
Event:FireServer("__---r", Vector3.new(0, -50000, 0), Players.LocalPlayer.Character.HumanoidRootPart.CFrame)

local vel, movel = nil, 0.1

if _G.Thread then
    pcall(function(...)
        task.cancel(_G.Thread)
    end)
end


_G.Thread = task.spawn(function()
	while RunService.Heartbeat:Wait() do
		local HRP = Players.LocalPlayer.Character.HumanoidRootPart
		vel = HRP.Velocity
		HRP.Velocity = vel * 10000 + Vector3.yAxis * 10000
		RunService.RenderStepped:Wait()
		HRP.Velocity = vel
		RunService.Stepped:Wait()
		HRP.Velocity = vel + Vector3.yAxis * movel
		movel = movel * -1
	end
end)
]=]

-------------------------

local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage: ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
-- local GameSettings = UserSettings():GetService("UserGameSettings")

local Events = ReplicatedStorage:WaitForChild("Events")
local Remotes = {
	Gun_Shoot = Events.GNX_S,
	Gun_Hit = Events.ZFKLF__H,
}
local LocalPlayer: Player = Players.LocalPlayer

local function printTable(t: {})
	print(tostring(t) .. "-> {")
	for idx, value in t do
		if typeof(value) == "table" then
			printTable(value)
		else
			print(idx, value)
		end
	end
	print("}")
end

local function CheckWallHit(Player, StartPos, HitPos, HitPart)
	local Direction = HitPos - StartPos
	local Mag = Direction.Magnitude

	local Ignore = { workspace.Map.Doors }
	if Player and Player.Character then
		table.insert(Ignore, Player.Character)
	end

	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.IgnoreWater = true
	Params.CollisionGroup = "Character"
	Params.FilterDescendantsInstances = Ignore

	local Origin = StartPos
	local Remaining = Direction.Unit * Mag
	local HitResult = nil

	for _ = 1, 10 do
		local Result = workspace:Raycast(Origin, Remaining, Params)
		if not Result then
			break
		end

		local Part = Result.Instance
		local IsTransparent = Part.Transparency >= 1 and not Part:GetAttribute("TransparencyCheckIgnore")
		local IsNonHitboxChar = Part:IsDescendantOf(workspace.Characters)
			and Part.Name ~= "Head"
			and Part.Name ~= "Torso"
			and Part.Name ~= "Left Arm"
			and Part.Name ~= "Right Arm"
			and Part.Name ~= "Left Leg"
			and Part.Name ~= "Right Leg"

		if IsTransparent or IsNonHitboxChar then
			local NewIgnore = {}
			for _, V in ipairs(Params.FilterDescendantsInstances) do
				table.insert(NewIgnore, V)
			end
			table.insert(NewIgnore, Part)
			Params.FilterDescendantsInstances = NewIgnore
			Origin = Result.Position
			Remaining = Direction.Unit * math.max(0, Mag - (Result.Position - StartPos).Magnitude)
		else
			HitResult = Result
			break
		end
	end

	if not HitResult then
		return true
	end

	local DistToTarget = (HitResult.Position - HitPos).Magnitude
	local MaxPenetration = 25 + HitPart.AssemblyLinearVelocity.Magnitude

	return DistToTarget < MaxPenetration
end

local function SafeCall(Func: (...any) -> ...any, ...: any)
	if not (Func and typeof(Func) == "function") then
		return
	end

	local Result = table.pack(xpcall(Func, function(Error: string)
		task.defer(warn, debug.traceback(Error, 2))
		return Error
	end, ...))

	if not Result[1] then
		return nil
	end

	return table.unpack(Result, 2, Result.n)
end

local codeGenerator: AnyFunction = nil
local BloodFx: AnyFunction = nil

local ShotCount = 0
local function RandomStr(Length)
	local t = ""
	for i = 1, Length do
		t = t .. string.char(math.random(65, 122))
	end
	return t
end

local LastShoot = 0
local CurrentFirerate = 0

local function Shoot(Target: Player | Model, Tool: Tool | Model, ToolConfig)
	local LocalCharacter = LocalPlayer.Character
	local Plr = (Target:IsA("Model") and Players:GetPlayerFromCharacter(Target) or Target:IsA("Player") and Target)
		or nil
	if not Plr then
		return
	end
	local TargetCharacter = Plr.Character

	local fireModeSettings = ToolConfig.FireModeSettings

	local fireRate = (1 / ToolConfig.FireRate)
	local burstRate = (1 / fireModeSettings.BurstRate) or 0

	local function castBullet(extraData: {})
		local Shootcode = RandomStr(30) .. ShotCount
		ShotCount += 1
		task.delay(5, function()
			ShotCount -= 1
		end)

		local BulletOrigin = LocalCharacter.Head.Position
		local TargetPosition = TargetCharacter.Head.Position

		local Directions = {}
		table.insert(Directions, (TargetPosition - BulletOrigin))

		Remotes.Gun_Shoot:FireServer(
			codeGenerator() + (extraData and extraData.cgAdd or 0), --Salt
			Shootcode, --ShootCode
			Tool, --Weapon
			"FDS9I83", --Remote validation key
			BulletOrigin, --Origin (Vector3)
			Directions, --Bullet Directions
			false --Bullet type <- always false since we aint admins xd
		)

		for _, Dir in Directions do
			BloodFx(ToolConfig, BulletOrigin, Dir, TargetCharacter.Head, TargetPosition, Vector3.xAxis, {})
			Remotes.Gun_Hit:FireServer(
				"\240\159\167\136", --Bullet hit code
				Tool, --Weapon
				Shootcode,
				1,
				TargetCharacter.Head, --HitPart
				TargetPosition,
				Dir,
				nil,
				{
					"Front",
					UDim2.new(0, 0, 0, 0),
					Vector2.zero,
				}
			)
		end
	end

	for bullet: number = 1, fireModeSettings.BurstAmount do
		warn("shot after", burstRate)
		castBullet({ cgAdd = 0 })
		task.wait((fireModeSettings. urstRate or fireRate))
	end
end



local function ShootAll()
	local zLocalCharacter = LocalPlayer.Character
	if not zLocalCharacter then
		return
	end
	local Tool = zLocalCharacter:FindFirstChildOfClass("Tool")
	local IsGun = false

	if not Tool then
		return
	end

	for Attr, Val in Tool:GetAttributes() do
		if Attr:lower():find("isgun") then
			IsGun = true
			break
		end
	end

	if not IsGun then
		return
	end
	local Config = require(Tool.Config)
	local FireRate = Config.FireRate

	if tick() - LastShoot <= 1 / FireRate then
		return
	end

	for _, Player in Players:GetPlayers() do
		if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Head") then
			print("tiro")
			LastShoot = tick()
			-- SafeCall(Shoot, Player, Config)
		end
	end
end

if _G.Thread then
	SafeCall(task.cancel, _G.Thread)
end

local compare = function(_a: any?, _b: any?, _raw: boolean?): boolean
	return (_raw and rawequal(_a, _b) or _a == _b)
end

local exists = function(_a: any?): boolean
	return (not compare(_a, nil))
end

_G.Thread = task.spawn(function()
	while (not exists(BloodFx) or not exists(codeGenerator)) and task.wait(1 / 10) do
		local List = filtergc("function", {
			IgnoreExecutor = true,
		})

		for _, fn: AnyFunction in List do
			if islclosure(fn) then
				local name = debug.info(fn, "n")
				if name:lower() == "bloodfx" and not exists(BloodFx) then
					BloodFx = clonefunction(fn)
				end

				if name:lower() == "cg" and not exists(codeGenerator) then
					codeGenerator = clonefunction(fn)
					print("Got codeGenerator")
				end
			end
		end
	end
	-- print("porn")
	-- while task.wait() do
	-- 	ShootAll()
	-- end
	for i = 1, 2 do
		local Gun = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
		Shoot(Players.Guest463920.Character, Gun, require(Gun.Config))
	end
end)
