-- https://lua.expert/
getfenv(0).script = nil
local _ = wait
local v1 = pcall
local v2 = os
local _2 = time
local v3 = math
local rad = v3.rad
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Events = ReplicatedStorage:WaitForChild("Events")
local Events2 = ReplicatedStorage:WaitForChild("Events2")
local Storage = ReplicatedStorage:WaitForChild("Storage")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local Debris_2 = workspace:WaitForChild("Debris")
workspace:WaitForChild("Filter")
local NewModules = ReplicatedStorage:WaitForChild("NewModules")
local ZFKLF__H = Events.ZFKLF__H
local Damage = require(NewModules.Client.Services.Effects.Damage)
local FastCastRedux = require(NewModules.Shared.Services.FastCastRedux)
local Spring = require(NewModules.Shared.Services.Spring)
local HitStuff = Storage:WaitForChild("HitStuff")
local GunClient = Storage:WaitForChild("GunClient")
local WhizzSounds = Storage:WaitForChild("WhizzSounds")
local t = {
	Head = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Right Leg"] = true,
	["Left Leg"] = true,
}
local v4 = FastCastRedux.new()
local Bullets = Instance.new("Folder")
Bullets.Name = "Bullets"
Bullets.Parent = CurrentCamera
FastCastRedux.DebugLogging = false
FastCastRedux.VisualizeCasts = false
FastCastRedux.RayExit = false
local v5 = Spring.spring.new((Vector3.new()))
v5.s = 20
v5.d = 0.999
local v6 = 60
local v7 = nil
local v8 = v2.clock()
local t2 = {}
local v9 = table.freeze({
	IntSalt = 21231,
	UserIdSalt = false,
})
local t3 = {}
local v10 = 1 / 60
local Bullet = Instance.new("Part")
Bullet.Name = "Bullet"
Bullet.Material = Enum.Material.SmoothPlastic
Bullet.CanCollide = false
Bullet.CanTouch = false
Bullet.CastShadow = false
Bullet.Anchored = true
local function CryptString(p1, p2) --[[ CryptString | Line: 74 ]]
	return p1:gsub(".", function(p1) --[[ Line: 75 | Upvalues: p2 (copy) ]]
		return string.char(p1:byte() + p2)
	end)
end
local function CryptTable(p1, p2) --[[ CryptTable | Line: 80 | Upvalues: CryptString (copy) ]]
	local t = {}
	for v1, v2 in next, p1 do
		t[CryptString(tostring(v1), p2)] = v2
	end
	return t
end
local function StrictTable(p1) --[[ StrictTable | Line: 90 ]]
	local v1 = newproxy(true)
	local v2 = getmetatable(v1)
	v2.__index = p1
	v2.__namecall = p1
	function v2.__newindex() --[[ Line: 96 ]]
		error("Attempt to modify a protected table.")
	end
	v2.__metatable = "This table is protected."
	return v1
end
local function protectTable(p1) --[[ protectTable | Line: 105 | Upvalues: v3 (copy), CryptTable (copy), CryptString (copy), StrictTable (copy) ]]
	local v2 = v3.floor(v3.random() * 100)
	local t = {}
	for v4, v5 in next, CryptTable(p1, v2) do
		local v6 = CryptString(tostring(v4), -v2)
		t[tonumber(v6) or v6] = v5
	end
	return StrictTable(t)
end
local function Lerp(p1, p2, p3) --[[ Lerp | Line: 118 ]]
	return p1 + (p2 - p1) * p3
end
local function BloodFX(p1, p2, p3, p4, p5, p6, p7) --[[ BloodFX | Line: 122 | Upvalues: Damage (copy) ]]
	local v2, v3 = Damage(
		nil,
		"Create",
		p2,
		p3,
		p4,
		p5,
		p6,
		p7,
		nil,
		nil,
		p1.Blood,
		p1.BulletHoleSize,
		(_G.IsArmoredCheck(p4.Parent, p4.Name))
	)
	return v2, v3
end
local function getValueStr(p1) --[[ getValueStr | Line: 129 ]]
	local sum = 0
	for v1 in p1:gmatch(".") do
		sum = sum + v1:byte()
	end
	return sum or 0
end
local function HeartbeatUpdate(p1) --[[ HeartbeatUpdate | Line: 138 | Upvalues: v2 (copy), v7 (ref), t2 (copy), v8 (copy), v3 (copy) ]]
	local v1 = v2.clock()
	v7 = v1
	for i = #t2, 1, -1 do
		t2[i + 1] = v1 - 1 <= t2[i] and t2[i] or nil
	end
	t2[1] = v1
	return v3.floor(v1 - v8 >= 1 and #t2 or #t2 / (v1 - v8))
end
local v11 = nil
v11 = table.freeze({
	cg = function() --[[ Line: 160 | Upvalues: v9 (copy), getValueStr (copy), v1 (copy) ]]
		local v12, v2 = v1(function() --[[ gnc | Line: 161 | Upvalues: v9 (ref), getValueStr (ref) ]]
			local v1 = tick()
			return v1
				- (
					v9.IntSalt
					+ (v9.UsernameSalt and getValueStr((tostring(game.Players.LocalPlayer))) or 0)
					+ (v9.UserIdSalt and game.Players.LocalPlayer.UserId / 2 or 0)
				)
		end)
		return if v12 and v2 then v2 else nil
	end,
	distToBullet = function(p1, p2, p3) --[[ Line: 168 | Upvalues: v3 (copy) ]]
		local v1 = p3 - p1
		local magnitude = v1.magnitude
		if magnitude <= 0.0001 then
			return 0
		end
		local v2 = v1:Dot(p2)
		if v2 - 0.0001 <= 0 then
			return magnitude
		else
			return v3.sqrt(magnitude ^ 2 - v2 ^ 2)
		end
	end,
	updtCam = function(p1) --[[ Line: 192 | Upvalues: v5 (copy), v3 (copy), v10 (ref), v6 (ref), CurrentCamera (copy) ]]
		if not (v3.abs(v5.p.x) > 0 or (v3.abs(v5.p.y) > 0 or v3.abs(v5.p.z) > 0)) then
			return
		end
		v10 = p1
		local v1 = v6
		if v1 > 30 then
			v1 = 60
		end
		CurrentCamera.CoordinateFrame = CurrentCamera.CoordinateFrame
			* CFrame.Angles(v5.p.x * p1 * v1, v5.p.y * p1 * v1, v5.p.z * p1 * v1)
	end,
	ONRH_S4 = function(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) --[[ Line: 204 | Upvalues: t (copy), Events2 (copy), Players (copy), LocalPlayer (copy), v1 (copy), ReplicatedStorage (copy), BloodFX (copy), ZFKLF__H (copy), HitStuff (copy), Debris (copy), v3 (copy), Debris_2 (copy) ]]
		local v12 = p11[1]
		local v2 = p11[2]
		local v32 = p1[1]
		local v4 = p1[2]
		local t2 = {
			Head = 1.5,
			["Left Arm"] = 2.5,
			["Right Arm"] = 2.5,
			["Left Leg"] = 2.5,
			["Right Leg"] = 2.5,
			Torso = 3,
		}
		if p4 == nil then
			return
		end
		local Humanoid = p4.Parent:FindFirstChild("Humanoid")
		local v5 = v2.Customs and v2.Customs.ExplosiveHit
		if Humanoid then
			if v12 then
				local v6 = if t[p4.Name] and _G.LimbCheck(p4.Parent, p4.Name, "Destroyed") then false else true
				if v6 and (Humanoid.Health > 0 or v5) then
					if Humanoid.Parent:FindFirstChildOfClass("ForceField") then
						Events2.ClientWarn:Fire({
							"Player is protected!",
							1.5,
							Color3.fromRGB(255, 121, 121),
							Color3.new(0 / 255, 0 / 255, 0 / 255),
							"lost",
						})
						return
					end
					if
						_G.TeamCheck
						and (
							Players:GetPlayerFromCharacter(p4.Parent)
							and _G.TeamCheck(LocalPlayer, Players:GetPlayerFromCharacter(p4.Parent))
						)
					then
						Events2.ClientWarn:Fire({
							"Friendly fire!",
							1,
							Color3.fromRGB(255, 121, 121),
							Color3.new(0 / 255, 0 / 255, 0 / 255),
							"lost",
						})
						return
					end
					local v7 = nil
					if
						_G._fd9ufds90wjaidjf
						or (
							Humanoid:GetAttribute("CSIZCHNGE")
							or (p4.Name ~= "Head" or not (p4.Size.X > 2.4 or (p4.Size.Y > 1.4 or p4.Size.Z > 1.4)))
						)
					then
						if (p5 - p4.Position).Magnitude > (t2[p4.Name] or 10) then
							return
						end
						local v8 = Humanoid:GetAttribute("__ABSRBBULTS")
						local v9 = not v2.CanExecute
							and ReplicatedStorage.Values.LegacyDowningSystem.Value
							and _G.DownedCheck(p4.Parent)
						if v8 then
							if not p8 then
								p8 = {}
							end
							p8.SHKW = true
						end
						if not v9 then
							local v10, _ = BloodFX(v2, p2, p3, p4, p5, p6, p8)
							v7 = v10
						end
						ZFKLF__H:FireServer("\240\159\167\136", p13, v32, v4, p4, p5, p6, p8, v7)
						if
							not v8
							and p13:FindFirstChild("Hitmarker")
							and not (
								p8 and (p8.ARv and (v2 and (v2.ArmorPenetration and v2.ArmorPenetration < p8.ARv)))
							)
						then
							p13.Hitmarker:Fire(p4)
						end
					else
						_G._fd9ufds90wjaidjf = true
						v1(function() --[[ Line: 249 | Upvalues: ReplicatedStorage (ref), p4 (copy) ]]
							ReplicatedStorage.Events.FGRGJBHBEE:FireServer(tostring(p4.Size), (tostring(p4.Parent)))
						end)
						return
					end
				elseif v6 then
					BloodFX(v2, p2, p3, p4, p5, p6, p8)
				end
			elseif Humanoid.Health <= 0 then
				BloodFX(v2, p2, p3, p4, p5, p6, p8)
			end
		else
			if v12 and p4:FindFirstChild("CanHitT2") then
				ZFKLF__H:FireServer("\240\159\167\136", p13, v32, v4, p4, p5, p6, p8, nil)
				if p13:FindFirstChild("Hitmarker") then
					p13.Hitmarker:Fire(p4)
				end
			elseif v12 and (p4 and v5) then
				ZFKLF__H:FireServer("\240\159\167\136", p13, v32, v4, nil, p5, p6, p8, nil)
			end
			if not p12 then
				local v122 = if _G.GSettings == nil then false else _G.GSettings.BulletHoles
				local v13 = HitStuff.BulletHole:Clone()
				Debris:AddItem(v13, 60)
				local v14 = CFrame.new(p5, p5 + p6)
				local Angles = CFrame.Angles
				local v15 = v3.random(0, 360)
				local v16 = v14 * Angles(0, 0, (v3.rad(v15)))
				v13.CFrame = v16
				v13.Size = Vector3.new(v2.BulletHoleSize, v2.BulletHoleSize, 0)
				local Attachment = Instance.new("Attachment", v13)
				Attachment.WorldCFrame = v16
				Attachment.Parent = v13
				if not p4.Anchored and v122 then
					local ManualWeld = Instance.new("ManualWeld")
					ManualWeld.Part0 = p4
					ManualWeld.Part1 = v13
					ManualWeld.C0 = p4.CFrame:Inverse() * CFrame.new(p4.Position)
					ManualWeld.C1 = v13.CFrame:Inverse() * CFrame.new(p4.Position)
					ManualWeld.Parent = v13
					v13.Anchored = false
				end
				if _G.GSettings == nil or _G.GSettings.BulletHoles then
					if p4:FindFirstChild("NoBHole") then
						v13.Decal.Transparency = 1
					end
				else
					v13.Decal.Transparency = 1
				end
				v13.Parent = Debris_2
				local v17 = nil
				local v18 = nil
				local function disc() --[[ disc | Line: 343 | Upvalues: v17 (ref), v18 (ref), v13 (copy) ]]
					v17:Disconnect()
					v18:Disconnect()
					if not (v13 and v13.Parent) then
						return
					end
					v13:Destroy()
				end
				v17 = v13.AncestryChanged:Connect(function(p1, p2) --[[ Line: 352 | Upvalues: disc (copy) ]]
					if p2 then
						return
					end
					disc()
				end)
				v18 = p4.AncestryChanged:Connect(function(p1, p2) --[[ Line: 357 | Upvalues: disc (copy) ]]
					if p2 then
						return
					end
					disc()
				end)
				local function hEffect(p1) --[[ hEffect | Line: 363 | Upvalues: HitStuff (ref), Attachment (copy), p4 (copy), Debris (ref), v3 (ref) ]]
					local v1 = HitStuff.HitEffects[p1]
					if _G.GSettings ~= nil and _G.GSettings.BulletSparks then
						local v2 = v1:GetChildren()
						for i = 1, #v2 do
							if v2[i].ClassName == "ParticleEmitter" then
								local v32 = v2[i]:Clone()
								v32.Parent = Attachment
								if v32.PartColor.Value then
									v32.Color = ColorSequence.new(p4.Color, p4.Color)
								end
								task.delay(0.01, function() --[[ Line: 376 | Upvalues: v32 (copy), Debris (ref) ]]
									v32:Emit(v32.EmitCount.Value)
									Debris:AddItem(v32, v32.Lifetime.Max)
								end)
							end
						end
					end
					local v4 = v1.Sounds:GetChildren()[v3.random(1, #v1.Sounds:GetChildren())]:Clone()
					Debris:AddItem(v4, 5)
					v4.Parent = Attachment
					v4.PlaybackSpeed = Random.new():NextNumber(v4.PlaybackSpeed * 0.9, v4.PlaybackSpeed * 1.1)
					v4:Play()
				end
				local function getMaterial(p1) --[[ getMaterial | Line: 391 ]]
					if
						p1 == Enum.Material.DiamondPlate
						or (p1 == Enum.Material.Metal or p1 == Enum.Material.CorrodedMetal)
					then
						return Enum.Material.Metal
					end
					if p1 == Enum.Material.Glass or p1 == Enum.Material.Ice then
						return Enum.Material.Glass
					end
					if p1 == Enum.Material.Wood or p1 == Enum.Material.WoodPlanks then
						return Enum.Material.Wood
					end
					if p1 == Enum.Material.Grass or p1 == Enum.Material.Fabric then
						return Enum.Material.Grass
					end
					if p1 == Enum.Material.Sand or p1 == Enum.Material.Pebble then
						return Enum.Material.Sand
					else
						return Enum.Material.Concrete
					end
				end
				if p4:GetAttribute("IsRShield") then
					hEffect("RiotShield")
				else
					if p4:GetAttribute("IsRShield2") then
						hEffect("RiotShield")
					end
					hEffect(getMaterial(p4.Material).Name)
				end
				if v13 then
					Debris:AddItem(v13, 30)
				end
			end
		end
		p10.Transparency = 1
		Debris:addItem(p10, 1)
		local v19 = p10:GetChildren()
		for i = 1, #v19 do
			if v19[i].ClassName == "ParticleEmitter" or v19[i].ClassName == "PointLight" then
				v19[i].Enabled = false
			end
		end
	end,
	VisualizeBullet = function(p1, p2, p3, p4, p5, p6, p7, p8) --[[ Line: 437 | Upvalues: Bullet (copy), Debris (copy), t3 (copy), v3 (copy), Bullets (copy), LocalPlayer (copy), GunClient (copy), v4 (copy) ]]
		for k, v in pairs(p7) do
			local v1
			local BulletType = p8.BulletType
			local fpT = p8.fpT
			local BulletSettings = p3.BulletSettings
			local v2 = p4:FindFirstChild(p3.HandleName or "Handle")
			local Muzzle = v2.Muzzle
			local FirePos = v2.FirePos
			local Ammo = p4.Values.Ammo.Value
			local LightColor = BulletSettings.LightColor
			local Color = BulletSettings.Color
			local v32 = 1
			if BulletType and BulletType == "HSP" then
				local v42 = Color3.fromRGB(255, 85, 85)
				LightColor = v42
				Color = v42
			elseif BulletType and BulletType == "RB" then
				local v5 = Color3.fromRGB(158, 158, 158)
				v32 = 0.5
				LightColor = v5
				Color = v5
			end
			local v6 = Bullet:Clone()
			Debris:AddItem(v6, 30)
			local v7 = nil
			v7 = v6.AncestryChanged:Connect(function(p1, p2) --[[ Line: 472 | Upvalues: t3 (ref), v6 (copy), v7 (ref) ]]
				if p2 then
					return
				end
				t3[v6] = nil
				v7:Disconnect()
			end)
			v6.Size = BulletSettings.Size or Vector3.new(1, 1, 1)
			v6.Transparency = 1
			v6.Material = BulletSettings.Material
			v6.Shape = BulletSettings.Shape
			v6.Color = Color
			if BulletSettings.MeshEnabled then
				local SpecialMesh = Instance.new("SpecialMesh")
				SpecialMesh.Scale =
					Vector3.new(BulletSettings.MeshScale.X, BulletSettings.MeshScale.Y, BulletSettings.MeshScale.Z)
				if BulletSettings.MeshID then
					SpecialMesh.MeshId = "rbxassetid://" .. BulletSettings.MeshID
				end
				if BulletSettings.TextureID then
					SpecialMesh.TextureId = "rbxassetid://" .. BulletSettings.TextureID
				end
				SpecialMesh.MeshType = BulletSettings.MeshType or "FileMesh"
				SpecialMesh.Parent = v6
			end
			local v9 = if v3.random(1, BulletSettings.TracerChance or 1) == 1 then true else false
			v6.CFrame = CFrame.new(p6, p6 + v)
			v6.Parent = Bullets
			v1 = not (p5 or _G.TeamCheck and _G.TeamCheck(p1, LocalPlayer))
			local t = {}
			if BulletSettings.TracerEnabled and (_G.GSettings ~= nil and _G.GSettings.BulletTracers) then
				if not _G.Y8OTOP and BulletSettings.LightEnabled then
					local PointLight = Instance.new("PointLight")
					PointLight.Brightness = BulletSettings.LightBrightness
					PointLight.Color = LightColor
					PointLight.Enabled = true
					PointLight.Range = BulletSettings.LightRange
					PointLight.Shadows = BulletSettings.Shadows
					PointLight.Parent = v6
				end
				local Attachment0 = Instance.new("Attachment", v6)
				Attachment0.Position = Vector3.new(
					BulletSettings.TracerOffset0.X * v32,
					BulletSettings.TracerOffset0.Y,
					BulletSettings.TracerOffset0.Z
				)
				Attachment0.Name = "Attachment0"
				local Attachment1 = Instance.new("Attachment", v6)
				Attachment1.Position = Vector3.new(
					BulletSettings.TracerOffset1.X * v32,
					BulletSettings.TracerOffset1.Y,
					BulletSettings.TracerOffset1.Z
				)
				Attachment1.Name = "Attachment1"
				t.TracerA0 = Attachment0
				t.TracerA1 = Attachment1
				if v6 and v6.Parent then
					local v12 = GunClient.TracerEffect:GetChildren()
					for i = 1, #v12 do
						if v12[i].className == "Trail" then
							local v13 = v12[i]:Clone()
							local v14 = BulletSettings.TracerTransparency or 1
							v13.Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.005, 1),
								NumberSequenceKeypoint.new(0.015, v14),
								NumberSequenceKeypoint.new(1, v14),
							})
							v13.LightEmission = BulletSettings.LightEmission or v13.LightEmission
							local TracerLifetime = BulletSettings.TracerLifetime
							v13.Lifetime = if TracerLifetime then TracerLifetime - 0.1 else 0
							v13.Attachment0 = Attachment0
							v13.Attachment1 = Attachment1
							v13.Color = ColorSequence.new(Color)
							v13.Enabled = false
							v13.Parent = v6
							v6:SetAttribute("TracerName", v13.Name)
						end
					end
				end
			end
			t.OTrans = v9 and BulletSettings.Transparency or 1
			t.Origin = v6.CFrame.p
			t.Direction = v
			t.MaxDist = p3.Range
			t.OSize = v6.Size
			t.BulletSize = v32
			t.BulletSettings = BulletSettings
			t.Velocity = BulletSettings.Velocity * 1.5
			if v1 then
				t.Firer = p1
				t.AP = p3.ArmorPenetration
			else
				t.Whizzed = true
			end
			t3[v6] = t
			local v18 = p4.Parent and p4.Parent:WaitForChild("HumanoidRootPart", 0.2)
			v4:FireWithBlacklist(
				{
					fc = { p2, k },
					t = { p5, p3 },
					To = p4,
					ex = p8,
				},
				p6,
				v * p3.Range,
				v * (BulletSettings.Velocity * 1.5) + (v18 and v18.Velocity or Vector3.new()),
				{ p4.Parent, workspace.CurrentCamera },
				v6,
				true,
				BulletSettings.Acceleration
			)
		end
	end,
	OnRayHit = function(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) --[[ Line: 629 | Upvalues: v11 (ref) ]]
		v11.ONRH_S4(p1.fc, p2, p3, p4, p5, p6, p7, p8, p9, p10, p1.t, p1.ex.NoHitEffect, p1.To)
	end,
	OnRayUpdated = function(p1, p2, p3, p4, p5, p6, p7, p8) --[[ Line: 647 | Upvalues: t3 (copy), v3 (copy), LocalPlayer (copy), Lerp (copy), WhizzSounds (copy), rad (copy), v5 (copy) ]]
		local v1 = p6.Size.Z / 2
		local v2 = CFrame.new(p2, p2 + p3)
		local v32 = t3[p6]
		if v32 then
			local BulletSettings = v32.BulletSettings
		end
		if p7 and p7[1] then
			local v4 = v2 * CFrame.new(0, 0, -(p4 - v1))
			local Angles = CFrame.Angles
			local v52 = tick() * p7[2]
			local v8 = v3.rad(-360 * (v52 - v3.floor(tick() * p7[2])))
			local v9 = tick() * p7[3]
			local v12 = v3.rad(-360 * (v9 - v3.floor(tick() * p7[3])))
			local v13 = tick() * p7[4]
			p6.CFrame = v4 * Angles(v8, v12, (v3.rad(-360 * (v13 - v3.floor(tick() * p7[4])))))
		end
		p6.CFrame = v2 * CFrame.new(0, 0, -(p4 - v1))
		local v16 = t3[p6]
		if not (v16 and (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head"))) then
			return
		end
		local v17 = Ray.new(v16.Origin, v16.Direction):Distance(LocalPlayer.Character.Head.Position)
		local v18 = LocalPlayer.Character
				and LocalPlayer.Character:FindFirstChild("Head")
				and LocalPlayer.Character.Head.Position
			or Vector3.new()
		local Magnitude = (v18 - p6.Position).Magnitude
		local function rayCheck() --[[ rayCheck | Line: 735 | Upvalues: LocalPlayer (ref), p6 (copy), Magnitude (copy) ]]
			local v2, _ = workspace:FindPartOnRayWithWhitelist(
				Ray.new(
					LocalPlayer.Character.Head.Position,
					(p6.Position - LocalPlayer.Character.Head.Position).unit * (Magnitude + 5)
				),
				{ workspace.Map, p6 },
				true
			)
			return v2 == p6
		end
		local BulletSettings = v16.BulletSettings
		if v16.Whizzed then
			return
		end
		if not ((v16.Origin - v18).Magnitude < 50 or Magnitude < v3.max(v16.Velocity / 200, 0.5)) then
			return
		end
		if not (v17 < 10) then
			return
		end
		local v20 = (10 - v17) / 10
		local v21 = Lerp(0.35, 1, v20)
		local v22 = Lerp(0.5, 1, v20)
		if not v16.Whizzed then
			local v23 = WhizzSounds.Whizz:GetChildren()[v3.random(1, #WhizzSounds.Whizz:GetChildren())]:Clone()
			v23.Volume = v21
			v23.EmitterSize = 50 * v22
			v23.Parent = p6
			v23:Play()
		end
		if v17 < 5 then
			local v24 = 1
			local v25, v26, v27
			if v17 < 1.5 then
				v24, v25, v26, v27 =
					2,
					4,
					WhizzSounds.BigCrack:GetChildren()[v3.random(1, #WhizzSounds.BigCrack:GetChildren())]:Clone(),
					100
			else
				v25, v26, v27 =
					3,
					WhizzSounds.SmallCrack:GetChildren()[v3.random(1, #WhizzSounds.SmallCrack:GetChildren())]:Clone(),
					75
			end
			local v30 = v24 * 40
			if BulletSettings then
				v30 = v30 * (BulletSettings.ShakeMulti or 1)
			end
			local function RAND(p1, p2, p3) --[[ RAND | Line: 790 | Upvalues: v3 (ref) ]]
				local v1 = 1 / (p3 or 1)
				return v3.random(p1 * v1, p2 * v1) / v1
			end
			local v31 = rad(v30 * RAND(-0.2, 0.2, 0.1))
			local v322 = rad(v30 * RAND(-0.1, 0.1, 0.1))
			v5:accelerate((Vector3.new(v31, v322, (rad(v30 * RAND(-1, 1, 0.1))))))
			coroutine.wrap(function() --[[ Line: 800 | Upvalues: v5 (ref), v31 (copy), v322 (copy) ]]
				task.wait(0.03)
				v5:accelerate((Vector3.new(-v31, -v322, 0)))
			end)()
			v26.Volume = v25 * v22
			v26.EmitterSize = v27 * v22
			v26.Parent = p6
			v26:Play()
		end
		v16.Whizzed = true
		t3[p6] = v16
	end,
})
Events2.Visualize.Event:Connect(v11.VisualizeBullet)
Events.Visualize.OnClientEvent:Connect(v11.VisualizeBullet)
v4.LengthChanged:Connect(v11.OnRayUpdated)
v4.RayHit:Connect(v11.OnRayHit)
RunService:BindToRenderStep("VisualizeClient", Enum.RenderPriority.Camera.Value + 5, v11.updtCam)
RunService.Heartbeat:Connect(function(p1) --[[ Line: 830 | Upvalues: v6 (ref), HeartbeatUpdate (copy) ]]
	v6 = HeartbeatUpdate(p1)
	_G.P23893189418293 = v6
end)
return nil
