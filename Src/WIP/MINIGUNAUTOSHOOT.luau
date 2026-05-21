local RunService = game:GetService("RunService")
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage: ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Stats = cloneref(game:GetService("Stats"))

local Events = ReplicatedStorage:WaitForChild("Events")
local Remotes = {
	Gun_Shoot = Events.GNX_S,
	Gun_Reload = Events.GNX_R,
	Gun_Hit = Events.ZFKLF_H,
}
local ReloadKeys = {
	Start = "STZNRD",
	End = "KLWE89U0",
}
local GameEnv = getrenv()
local CrimCrosshair = GameEnv._G.DCH
local LocalPlayer: Player = Players.LocalPlayer

local lastReload = 0
local function checkReloadDelay() : (boolean)
	return ((os.clock() - lastReload) >= 1)
end

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
	Params.FilterType = Enum.RaycastFilterType.Blacklist
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
	local MaxPenetration = 25 + (HitPart.AssemblyLinearVelocity.Magnitude / 2) -- / 0

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

local ShotCount = 0
local function RandomStr(Length)
	local t = ""
	for i = 1, Length do
		t = t .. string.char(math.random(65, 122))
	end
	return t
end

local LastShoot = 0

local function Shoot(Target: Player | Model, Tool: Tool | Model, ToolConfig, BulletOrigin: Vector3)
	local Plr = (Target:IsA("Model") and Players:GetPlayerFromCharacter(Target) or Target:IsA("Player") and Target)
		or nil
	if not Plr then
		return
	end
	local TargetCharacter = Plr.Character

	local Shootcode = RandomStr(30) .. ShotCount
	ShotCount += 1
	task.delay(5, function()
		ShotCount -= 1
	end)

	local TargetPosition = TargetCharacter.Head.Position

	local Directions = {}
	for _ = 1, (ToolConfig.BulletsPerShot or 1) do
		table.insert(Directions, (TargetPosition - BulletOrigin))
	end

	task.spawn(function() --debug stuff test
		if not _G.tracerModule then
			local Distance = (TargetPosition - BulletOrigin).Magnitude
			local DebugPart = Instance.new("Part")

			DebugPart.Anchored = true
			DebugPart.CanCollide = false
			DebugPart.CanTouch = false
			DebugPart.CanQuery = false
			DebugPart.Material = Enum.Material.Neon
			DebugPart.Color = Color3.fromRGB(255, 0, 0)
			DebugPart.Size = Vector3.new(0.15, 0.15, Distance)

			DebugPart.CFrame = CFrame.lookAt(BulletOrigin, TargetPosition) * CFrame.new(0, 0, -Distance / 2)
			DebugPart.Parent = workspace

			local OriginSphere = Instance.new("Part")
			OriginSphere.Shape = Enum.PartType.Ball
			OriginSphere.Anchored = true
			OriginSphere.CanCollide = false
			OriginSphere.Material = Enum.Material.Neon
			OriginSphere.Color = Color3.fromRGB(0, 255, 0)
			OriginSphere.Size = Vector3.new(0.5, 0.5, 0.5)
			OriginSphere.Position = BulletOrigin
			OriginSphere.Parent = workspace

			task.delay(30, function()
				DebugPart:Destroy()
				OriginSphere:Destroy()
			end)
		else
			_G.tracerModule(BulletOrigin, TargetPosition)
		end
	end)
	--------------------------------------------------------------------
	local SaltC = tick()

	local BulletType = false
	if ToolConfig.BulletTypeChange and ToolConfig.BulletTypeChange.Enabled then
		BulletType = ToolConfig.BulletTypeChange.M1
	end

	Remotes.Gun_Shoot:FireServer(
		SaltC, --Salt
		Shootcode, --ShootCode
		Tool, --Weapon
		"FDS9I83", --Remote validation key
		BulletOrigin, --Origin (Vector3)
		Directions, --Bullet Directions
		BulletType --Bullet type
	)
	for _, Dir in Directions do
		--BloodFx(ToolConfig, BulletOrigin, Dir, TargetCharacter.Head, TargetPosition, Vector3.xAxis, {})
		Remotes.Gun_Hit:FireServer(
			"\240\159\141\175", --Bullet hit code
			SaltC, --Weapon
			Tool,
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

		CrimCrosshair.hitmarker()
	end
end

local ShootOffsetTRASHhold = 20 -- 28
local RadiusMul = 2.5 -- 5

local function getPing() : (number)
	local set = 8
	local old = getthreadidentity()
	setthreadidentity(set)
	local Ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
	if set ~= old then
		setthreadidentity(old)
	end
	return Ping
end

local function getCurrentGun(): (Tool?)
	local zLocalCharacter = LocalPlayer.Character
	if not zLocalCharacter or not zLocalCharacter:FindFirstChild("Head") then
		return
	end

	local Tool = zLocalCharacter:FindFirstChildOfClass("Tool")
	if not Tool then
		return
	end

	local IsGun = false
	for Attr, Val in Tool:GetAttributes() do
		if Attr:lower():find("isgun") then
			IsGun = true
			break
		end
	end

	if not IsGun then
		return
	end

	return Tool, require(Tool.Config)
end

local function serverTick(): number
	return (workspace:GetServerTimeNow())
end

local function reload(gun: Tool?, cfg: {[any]: any}?)
	if not gun or not cfg then
		return
	end

	local values = gun:FindFirstChild("Values")
    if not values or values.SERVER_Ammo.Value >= values.SERVER_Ammo.MaxValue then
        return
    end

	local function _rl()
		local SaltC = serverTick()

		local _rand = math.random()

		lastReload = os.clock()
		Remotes.Gun_Reload:FireServer(SaltC, ReloadKeys.Start, gun, nil, nil)
		task.delay(0.1, function()
			local timeTaken = serverTick() + (serverTick() - SaltC)
			Remotes.Gun_Reload:FireServer(timeTaken + (cfg.ReloadTime + _rand), ReloadKeys.End, gun, _rand, nil)
		end)
	end
	xpcall(_rl, warn)
end

local function ShootAll()
	local zLocalCharacter = LocalPlayer.Character
	if not zLocalCharacter or not zLocalCharacter:FindFirstChild("Head") then
		return
	end

	local Tool, Config = getCurrentGun()
	if not Tool or not Config then
		return
	end

	local ServerAmmo = Tool.Values.SERVER_Ammo
	local Ammo = Tool.Values.Ammo
	local Reloading = Tool.Values.Reloading

	local FireRate = Config.FireRate

	if ServerAmmo.Value <= 0 then
		return
	end

	if Reloading.Value then
		return
	end

	if
		tick() - LastShoot
		<= ((1 / FireRate) + (getPing() / 100))
	then
		return
	end

	local LocalHeadPos = zLocalCharacter.Head.Position

	local List = {}
	for _, Player in Players:GetPlayers() do
		local TargetChar = Player.Character
		local TargetHum = TargetChar and TargetChar:FindFirstChildOfClass("Humanoid")
		if Player:IsFriendsWith(LocalPlayer.UserId) then
			continue
		end
		if
			Player ~= LocalPlayer
			and TargetChar
			and TargetChar:FindFirstChild("Head")
			and not TargetChar:FindFirstChildOfClass("ForceField")
			and TargetHum
			and TargetHum.Health >= 1
			and TargetHum.Health <= 10000
		then
			local TargetHead = Player.Character.Head
			local TargetPos = TargetHead.Position
			local Direction = (TargetPos - LocalHeadPos)

			local Distance = Direction.Magnitude
			local Look = Direction.Unit

			local Right = Look:Cross(Vector3.yAxis)
			if Right.Magnitude < 0.001 then
				Right = Vector3.xAxis
			else
				Right = Right.Unit
			end
			local Up = Right:Cross(Look).Unit

			local ValidOrigin = nil

			if CheckWallHit(Player, LocalHeadPos, TargetPos, TargetHead) then
				ValidOrigin = LocalHeadPos
			else
				local Found = false
				for Radius = RadiusMul, ShootOffsetTRASHhold, RadiusMul do
					local Offsets = {
						Up * Radius,
						Right * Radius,
						-Right * Radius,
						(Up + Right).Unit * Radius,
						(Up - Right).Unit * Radius,
						-Up * Radius,
					}

					for _, OffsetVector in Offsets do
						local TestOrigin = LocalHeadPos + OffsetVector

						if CheckWallHit(Player, TestOrigin, TargetPos, TargetHead) then
							ValidOrigin = TestOrigin
							Found = true
							break
						end
					end

					if Found then
						break
					end
				end
			end
			if ValidOrigin then
				table.insert(List, {
					Player = Player,
					Origin = ValidOrigin,
					Distance = Distance,
				})
			end
		end
	end

	table.sort(List, function(a0, a1): boolean
		return a0.Distance < a1.Distance
	end)

	local Target = List[1]
	if Target then
		LastShoot = tick()
		Ammo.Value -= 1
		if Ammo.Value <= 0 then
			Ammo.Value = ServerAmmo.Value
		end

		SafeCall(Shoot, Target.Player, Tool, Config, Target.Origin)

		local function canReload() : (boolean)
			local ServerAmmo: DoubleConstrainedValue = Tool.Values.SERVER_Ammo
			return (not Reloading.Value and ServerAmmo.Value <= math.round(ServerAmmo.MaxValue/2))
		end

		if (Tool.Parent == zLocalCharacter and checkReloadDelay() and canReload()) then
			reload(Tool, Config)
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
	while RunService.Stepped:Wait() do
		ShootAll()
	end
end)
