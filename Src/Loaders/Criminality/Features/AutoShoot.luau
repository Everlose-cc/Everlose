--!nocheck

local Players = cloneref(game:GetService("Players"))

local ReloadKeys = {
	Start = "STZNRD",
	End = "KLWE89U0",
	Cancel = "CANZZELCULTUUUR",
}

local Library: Library = wax.shared.Library
local SafeCall = wax.shared.SafeCall
local ClientUtils = wax.shared.ClientUtils
local CrimUtils = wax.shared.CrimUtils
local Remotes = wax.shared.Remotes

local ServerTick = ClientUtils.ServerTick
local GetPing = ClientUtils.GetPing

local GetCurrentGun = CrimUtils.GetCurrentGun
local Notify = CrimUtils.Notify
local RayParams = CrimUtils.CharacterParams

local Options = Library.Options
local GameEnv = getrenv()
local LocalPlayer: Player = wax.shared.LocalPlayer

local LastReload = 0
local LastShoot = 0
local ShotCount = 0

local OriginRadiusMul = 2.5
local TargetRadiusStep = 2
local TargetRadiusMax = 23

local function CheckWallHit(Player, StartPos, HitPos, HitPart)
	local Direction = HitPos - StartPos
	local Mag = Direction.Magnitude

	local Ignore = { workspace.Map.Doors }
	if Player and Player.Character then
		table.insert(Ignore, Player.Character)
	end
	RayParams.FilterDescendantsInstances = Ignore

	local Origin = StartPos
	local Remaining = Direction
	local HitResult = nil

	for _ = 1, 10 do
		local Result = workspace:Raycast(Origin, Remaining, RayParams)
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
			for _, V in ipairs(RayParams.FilterDescendantsInstances) do
				table.insert(NewIgnore, V)
			end
			table.insert(NewIgnore, Part)
			RayParams.FilterDescendantsInstances = NewIgnore
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
	local MaxPenetration = 25 + (HitPart.AssemblyLinearVelocity.Magnitude / 2)

	return DistToTarget < MaxPenetration
end

local function GetTargetOffsets(Up: Vector3, Right: Vector3, Radius: number): { Vector3 }
	if Radius == 0 then
		return { Vector3.zero }
	end
	return {
		Up * Radius,
		Right * Radius,
		-Right * Radius,
		-Up * Radius,
		(Up + Right).Unit * Radius,
		(Up - Right).Unit * Radius,
	}
end

local function GetOriginOffsets(Up: Vector3, Right: Vector3, Radius: number): { Vector3 }
	return {
		Up * Radius,
		Right * Radius,
		-Right * Radius,
		(Up + Right).Unit * Radius,
		(Up - Right).Unit * Radius,
		-Up * Radius,
	}
end

local function FindValidShot(Player, LocalHeadPos: Vector3, TargetPos: Vector3, TargetHead, Up: Vector3, Right: Vector3)
	local ValidOrigin = nil
	local ValidTarget = TargetPos
	local Found = false

	for Radius = 0, TargetRadiusMax, TargetRadiusStep do
		for _, TargetOff in GetTargetOffsets(Up, Right, Radius) do
			local TestTarget = TargetPos + TargetOff
			if CheckWallHit(Player, LocalHeadPos, TestTarget, TargetHead) then
				ValidOrigin = LocalHeadPos
				ValidTarget = TestTarget
				Found = true
				break
			end
		end
		if Found then
			break
		end
	end

	if not Found then
		for OriginRadius = OriginRadiusMul, Options['AutoShoot_OriginOffset'].Value, OriginRadiusMul do
			for _, OriginOff in GetOriginOffsets(Up, Right, OriginRadius) do
				local TestOrigin = LocalHeadPos + OriginOff
				for TargetRadius = 0, TargetRadiusMax, TargetRadiusStep do
					for _, TargetOff in GetTargetOffsets(Up, Right, TargetRadius) do
						local TestTarget = TargetPos + TargetOff
						if CheckWallHit(Player, TestOrigin, TestTarget, TargetHead) then
							ValidOrigin = TestOrigin
							ValidTarget = TestTarget
							Found = true
							break
						end
					end
					if Found then
						break
					end
				end
				if Found then
					break
				end
			end
			if Found then
				break
			end
		end
	end

	return ValidOrigin, ValidTarget
end

local function Shoot(
	Target: Player | Model,
	Tool: Tool | Model,
	ToolConfig: { [any]: any },
	BulletOrigin: Vector3,
	TargetOverride: Vector3?
)
	local Plr = (Target:IsA("Model") and Players:GetPlayerFromCharacter(Target) or Target:IsA("Player") and Target)
		or nil
	if not Plr then
		return
	end
	local TargetCharacter = Plr.Character

	local ShootCode = RandomStr(30) .. ShotCount
	ShotCount += 1
	task.delay(5, function()
		ShotCount -= 1
	end)

	local HeadPos = TargetCharacter.Head.Position

	local TargetPosition
	if TargetOverride then
		TargetPosition = TargetOverride
	else
		TargetPosition = HeadPos + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	end

	local Directions = {}
	for _ = 1, (ToolConfig.BulletsPerShot or 1) do
		table.insert(Directions, (TargetPosition - BulletOrigin))
	end

	task.spawn(function()
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

	local SaltC = ServerTick()

	local BulletType = false
	if ToolConfig.BulletTypeChange and ToolConfig.BulletTypeChange.Enabled then
		BulletType = ToolConfig.BulletTypeChange.M1
	end

	Remotes.GunShoot:FireServer(SaltC, ShootCode, Tool, "FDS9I83", BulletOrigin, Directions, BulletType)

	for Idx, Dir in Directions do
		Remotes.GunHit:FireServer(
			"\240\159\141\175",
			SaltC,
			Tool,
			ShootCode,
			Idx,
			TargetCharacter.Head,
			TargetPosition,
			Dir,
			nil,
			{ "Front", UDim2.new(0, 0, 0, 0), Vector2.zero }
		)
		GameEnv._G.DCH.hitmarker()
	end
end

local function Reload(Gun: Tool?, Cfg: { [any]: any }?)
	if not Gun or not Cfg then
		return
	end

	local Values = Gun:FindFirstChild("Values")
	if not Values or Values.SERVER_Ammo.Value >= Values.SERVER_Ammo.MaxValue then
		return
	end

	local function CanReload()
		return Gun and Gun.Parent and Gun.Parent == LocalPlayer.Character
	end

	local function DoReload()
		local Code = math.random()
		if CanReload() then
			if not Gun:GetAttribute("___lol") then
				Gun:SetAttribute("___lol", true)
				Remotes.GunReload:FireServer(ServerTick() - 10, ReloadKeys.Start, Gun, Code, nil)
				Remotes.GunReload:FireServer(ServerTick() - 10, ReloadKeys.Cancel, Gun, Code)
				task.delay(Cfg.ReloadTime + 0.1, function()
					Gun:SetAttribute("___lol2", true)
				end)
			end
		end
		if CanReload() and Gun:GetAttribute("___lol2") then
			Notify("Reloaded", 1 / 60, BrickColor.Blue().Color, BrickColor.Black().Color, "allowance")
			LastReload = ServerTick()
			Remotes.GunReload:FireServer(ServerTick() + Cfg.ReloadTime, ReloadKeys.End, Gun, nil, nil)
		end
	end

	DoReload()
end

local function Thread()
	local ZLocalCharacter = LocalPlayer.Character
	if not ZLocalCharacter or not ZLocalCharacter:FindFirstChild("Head") then
		return
	end

	local Tool, Config = GetCurrentGun()
	if not Tool or not Config then
		return
	end

	local ServerAmmo = Tool.Values.SERVER_Ammo
	local ServerStoredAmmo = Tool.Values.SERVER_StoredAmmo
	local Ammo = Tool.Values.Ammo
	local StoredAmmo = Tool.Values.StoredAmmo
	local Reloading = Tool.Values.Reloading
	local FireRate = Config.FireRate
	local FireModeSettings = Config.FireModeSettings

	local UseBurst = (
		FireModeSettings
		and FireModeSettings.CanSwitch
		and FireModeSettings.SwitchTo == "Burst"
		and FireModeSettings.BurstAmount
	)
			and true
		or false

	if UseBurst then
		FireRate = FireModeSettings.BurstRate * 10000
	end

	local Now = ServerTick()

	local function ReloadCheck()
		if
			Tool.Parent == ZLocalCharacter
			and ((Now - LastReload) >= (0.3 + GetPing()))
			and (not Reloading.Value and ServerAmmo.Value < ServerAmmo.MaxValue)
		then
			Reload(Tool, Config)
			StoredAmmo.Value = ServerStoredAmmo.Value
			Ammo.Value = ServerAmmo.Value
		end
	end

	if ServerAmmo.Value < ServerAmmo.MaxValue then
		if ServerStoredAmmo.Value <= 0 and ServerAmmo.Value <= 0 then
			return
		end
		if ServerStoredAmmo.Value > 0 then
			ReloadCheck()
		end
		if ServerAmmo.Value <= 0 then
			return
		end
	end

	if Reloading.Value then
		return
	end

	if Now - LastShoot <= (1 / FireRate) then
		return
	end

	local LocalHeadPos = ZLocalCharacter.Head.Position
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
			local Direction = TargetPos - LocalHeadPos
			local Distance = Direction.Magnitude
			local Look = Direction.Unit

			local Right = Look:Cross(Vector3.yAxis)
			if Right.Magnitude < 0.001 then
				Right = Vector3.xAxis
			else
				Right = Right.Unit
			end
			local Up = Right:Cross(Look).Unit

			local ValidOrigin, ValidTarget = FindValidShot(Player, LocalHeadPos, TargetPos, TargetHead, Up, Right)

			if ValidOrigin then
				table.insert(List, {
					Player = Player,
					Origin = ValidOrigin,
					Target = ValidTarget,
					Distance = Distance,
				})
			end
		end
	end

	table.sort(List, function(A, B): boolean
		return A.Distance < B.Distance
	end)

	local Target = List[1]
	if Target then
		if ServerAmmo.Value <= 0 then
			return
		end

		LastShoot = ServerTick()
		Ammo.Value = ServerAmmo.Value - 1
		StoredAmmo.Value = ServerStoredAmmo.Value

		SafeCall(Shoot, Target.Player, Tool, Config, Target.Origin, Target.Target)
	end
end

return Thread
