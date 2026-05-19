local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage: ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local Events = ReplicatedStorage:WaitForChild("Events")
local Remotes = {
	Gun_Shoot = Events.GNX_S,
	Gun_Hit = Events.ZFKLF_H,
}
local GameEnv = getrenv()
local CrimCrosshair = GameEnv._G.DCH
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

local function Shoot(Target: Player | Model, Tool: Tool | Model, ToolConfig, BulletOrigin: Vector3)
	local LocalCharacter = LocalPlayer.Character
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
	table.insert(Directions, (TargetPosition - BulletOrigin))

	task.spawn(function()--debug stuff test
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
	end)
	--------------------------------------------------------------------
	local SaltC = tick()

	Remotes.Gun_Shoot:FireServer(
		SaltC, --Salt
		Shootcode, --ShootCode
		Tool, --Weapon
		"FDS9I83", --Remote validation key
		BulletOrigin, --Origin (Vector3)
		Directions, --Bullet Directions
		false --Bullet type
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

local ShootOffsetTRASHhold = 28
local function ShootAll()
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
	
	local Ammo = Tool.Values.Ammo
	local Reloading = Tool.Values.Reloading
	local Config = require(Tool.Config)
	local FireRate = Config.FireRate

	if Ammo.Value <= 0 then
		return
	end

	if Reloading.Value then
		return
	end

	if tick() - LastShoot <= (1 / FireRate) then
		return
	end

	local LocalHeadPos = zLocalCharacter.Head.Position

	for _, Player in Players:GetPlayers() do
		local TargetChar  = Player.Character
		local TargetHum = TargetChar and TargetChar:FindFirstChildOfClass('Humanoid')
        if Player:IsFriendsWith(LocalPlayer.UserId) then continue end
		if Player ~= LocalPlayer and TargetChar and TargetChar:FindFirstChild("Head") and not TargetChar:FindFirstChildOfClass('ForceField') and TargetHum and TargetHum.Health >= 1 then
			local TargetHead = Player.Character.Head
			local TargetPos = TargetHead.Position
			local Look = (TargetPos - LocalHeadPos).Unit

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
				for Radius = 5, ShootOffsetTRASHhold, 5 do
					local Offsets = {
						Up * Radius,
						Right * Radius,
						-Right * Radius,
						(Up + Right).Unit * Radius,
						(Up - Right).Unit * Radius,
						-Up * Radius
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
				LastShoot = tick()
				Ammo.Value -= 1
				SafeCall(Shoot, Player, Tool, Config, ValidOrigin)
			end
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

	while task.wait() do
		ShootAll()
	end
end)
