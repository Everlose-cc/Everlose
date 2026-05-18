--!nolint BuiltinGlobalWrite

_G.STOP = false

local oldTask = getgenv().task

local threads = {}
local connections = {}

local debugPrint = true
local function output(...)
	if debugPrint then
		warn(...)
	end
end

task = {
	spawn = function(...)
		local thread = oldTask.spawn(...)
		table.insert(threads, thread)
		return thread
	end,
	defer = function(...)
		local thread = oldTask.defer(...)
		table.insert(threads, thread)
		return thread
	end,
	delay = function(...)
		local thread = oldTask.delay(...)
		table.insert(threads, thread)
		return thread
	end,
	cancel = function(...)
		local thread = select(1, ...)
		local index = table.find(threads, thread)
		if index then
			table.remove(threads, index)
		end
		xpcall(oldTask.cancel, output, thread)
	end,
	wait = oldTask.wait,
	syncronize = oldTask.synchronize,
	desynchronize = oldTask.desynchronize,
}

task.spawn(function()
	while not _G.STOP do
		task.wait()
	end

	for _, thread in threads do
		task.cancel(thread)
	end
	for _, connection in connections do
		connection:Disconnect()
	end

	for _, v in workspace:GetChildren() do
		if v.Name == "me deleta dps pra n dar memory leak" then
			v:Destroy()
		end
	end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local ihatecofres = { "SmallSafe_BD_12", "SmallSafe_WH_28", "SmallSafe_BD_18" }

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local function RefreshChar()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local Events = ReplicatedStorage:WaitForChild("Events")
local SwingE = Events:WaitForChild("XMHH.2")
local HitRemote = Events:WaitForChild("XMHH2.2")
local PickCashRemote = Events:WaitForChild("CZDPZUS")
local BuyRemote = Events:WaitForChild("SSHPRMTE1")

local MapF = workspace:WaitForChild("Map")
local Filter = workspace:WaitForChild("Filter")

local CashSpawns = MapF:WaitForChild("BredMakurz")
local DroppedCash = Filter:WaitForChild("SpawnedBread")

local R_K1, R_K2, R_K3 = "🍞", "DZDRRRKI", "2389ZFX34"

local NotificationEvent = Events:WaitForChild("Notification")

local AntiExploitHits = 0
local ResetDelay = 35
local TotalAlerts = 0
local LastRectTick = tick()
local MaxDist = 42
local TweenDist = 65

local KillAF = false

local AdminGroups = { 32406137 }
local AdminIds = { 29761878, 50801509 }
local KickReason = "Admin In Server"

local Reducing = false

local runningThread = nil
local respawning = false

--[[local function MonitorCharacter(Character:Model)
	local Huma:Humanoid = Character:WaitForChild('Humanoid')
	local Animator:Animator = Huma:WaitForChild('Animator')
	Animator.AnimationPlayed:Connect(function(anim:AnimationTrack)
		if anim.Animation.AnimationId:find('215384594') then
			warn('👀!!! ', Character, ' Is a exploiter, adding to list.')
			if not table.find(Exploiters, Character) then
				table.insert(Exploiters, Character)
			end
		end
	end)
end]]

local function flashImage()
	local LIFETIME = 4

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://6332833898"
	sound.Volume = 10
	sound.Parent = LocalPlayer.PlayerGui:FindFirstChild("CoreGUI")

	local distortion = Instance.new("DistortionSoundEffect")
	distortion.Parent = sound
	distortion.Level = 123
	sound:Play()

	task.delay(LIFETIME, function()
		sound:Destroy()
	end)
end

local function HandlePlrAdded(p: Player)
	if p == LocalPlayer then
		return
	end
	for _, id in AdminGroups do
		if p:IsInGroupAsync(id) then
			flashImage()
			LocalPlayer:Kick(KickReason)
			return
		end
	end
	if table.find(AdminIds, p.UserId) then
		flashImage()
		LocalPlayer:Kick(KickReason)
		return
	end
	--[[if p.Character then
		MonitorCharacter(p)
	end
	p.CharacterAdded:Connect(MonitorCharacter)]]
	warn(p.Name, " | ", p.DisplayName, " Is not an Admin")
end

--[[for _,p in Players:GetPlayers() do
	pcall(HandlePlrAdded, p.Character)
end]]
local plraddedConn = Players.PlayerAdded:Connect(HandlePlrAdded)
table.insert(connections, plraddedConn)

local idledConn = LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	task.wait()
	VirtualUser:ClickButton2(Vector2.zero)
end)
table.insert(connections, idledConn)

local function ResetCounters()
	AntiExploitHits = 0
	TotalAlerts = 0
	print("resetosploit porque morre ou sim")
end

--[[local function ReduceCounters()
	if AntiExploitHits > 0 and TotalAlerts > 0 then
		AntiExploitHits -= 1
		TotalAlerts -= 1
		print("-1 anticheetos (vai toma no cu antiexploder)")
	end
end]]

local function ResetCounterThing()
	while task.wait(1) do
		if _G.STOP then
			break
		end
		if not Reducing then
			break
		end
		local calculo = tick() - LastRectTick
		if calculo >= ResetDelay then
			ResetCounters()
			Reducing = false
			break
		end
	end
end
local NotificationEventConn = NotificationEvent.OnClientEvent:Connect(function(data, mode)
	if
		typeof(data) == "table"
		and data.Title == "Anti Exploit"
		and data.Text == "You were rectified due to possible movement cheats"
	then
		print("anticheetos aviso")

		TotalAlerts += 1

		if TotalAlerts > 0 then
			print("anticheter level ", TotalAlerts)
		end

		AntiExploitHits += 1
		LastRectTick = tick()
		print("antich avisos:", AntiExploitHits, "/ 3")

		if not Reducing then
			Reducing = true
			task.spawn(function()
				ResetCounterThing()
			end)
		end
	end
end)
table.insert(connections, NotificationEventConn)

local function SafeGetPos(model)
	if not model then
		return nil
	end
	local part = model:FindFirstChild("MainPart") or model:FindFirstChild("HumanoidRootPart")
	return part and part.Position or nil
end

local function PickCash(cash)
	if cash and cash:IsA("BasePart") then
		PickCashRemote:FireServer(cash)
	end
end

local function FindNearestCash(bred)
	local rootPos = SafeGetPos(bred)
	if not rootPos then
		return nil
	end

	local nearest = nil
	local shortestDistance = 30

	for _, v in DroppedCash:GetChildren() do
		if v:IsA("BasePart") then
			local distance = (v.Position - rootPos).Magnitude

			if distance <= 6 and distance < shortestDistance then
				shortestDistance = distance
				nearest = v
			end
		end
	end

	return nearest
end

local function SmoothTeleport(targetPos)
	RefreshChar()
	local hrp = Character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local startPos = hrp.Position
	local t0 = tick()
	local duration = 1

	local Dist = (startPos - targetPos).Magnitude

	if Dist <= TweenDist and Dist > MaxDist then
		duration = 3
	end

	local function startTp()
		local conns = {}
		local methods = { "Stepped", "Heartbeat", "RenderStepped", "PreSimulation", "PostSimulation", "PreAnimation" }

		local stopped = false
		local function stop(): boolean
			if tick() - t0 >= duration or _G.STOP then
				for _, conn in conns do
					conn:Disconnect()
				end
				return true
			end
			return false
		end

		for _, method in methods do
			local conn = RunService[method]:Connect(function()
				if stopped then
					return
				end
				hrp.CFrame = CFrame.new(targetPos, targetPos + Vector3.new(0, 10, 0))
				if stop() then
					stopped = true
					return
				end
			end)
			table.insert(conns, conn)
			table.insert(connections, conn)
		end

		while not stopped do
			RunService.Heartbeat:Wait()
		end
	end
	startTp()
end

local function TryTeleportFor6Sec(bred)
	local start = tick()

	while tick() - start < 6 do
		if _G.STOP then
			break
		end
		RefreshChar()

		local values = bred:FindFirstChild("Values")
		local broken = values and values:FindFirstChild("Broken")

		if broken and broken.Value == true then
			break
		end

		local main = bred:FindFirstChild("MainPart")
		if main then
			SmoothTeleport(main.Position)
		end

		RunService.Heartbeat:Wait()
	end
end

local function TeleportWithRetry(bred)
	while task.wait() do
		if _G.STOP then
			break
		end
		local values = bred:FindFirstChild("Values")
		local broken = values and values:FindFirstChild("Broken")

		if broken and broken.Value == true then
			break
		end

		TryTeleportFor6Sec(bred)
		task.wait(0.05)
	end
end

local function HitMAKURRA(bred)
	task.spawn(function()
		while not _G.STOP do
			task.wait()

			RefreshChar()

			local char = LocalPlayer.Character
			if not char then
				break
			end

			local hum = char:FindFirstChild("Humanoid")
			if not hum or hum.Health <= 0 then
				break
			end

			local tool = char:FindFirstChild("Crowbar")
			local ax = char:FindFirstChild("Fire-Axe")

			if ax then
				repeat
					task.wait()
				until not ax or ax.Parent ~= char
			end

			if not tool then
				local backpackTool = LocalPlayer.Backpack:FindFirstChild("Crowbar")
				if backpackTool then
					backpackTool.Parent = char
					tool = backpackTool
				else
					task.wait(0.5)
					continue
				end
			end

			local values = bred:FindFirstChild("Values")
			local broken = values and values:FindFirstChild("Broken")
			if not broken then
				break
			end

			local isBroken = broken.Value

			local code = SwingE:InvokeServer(R_K1, tick(), tool, R_K2, bred, "Register")

			if not isBroken then
				HitRemote:FireServer(
					R_K1,
					tick(),
					tool,
					R_K3,
					code,
					false,
					tool:FindFirstChild("WeaponHandle"),
					bred.MainPart,
					bred,
					bred.PrimaryPart.Position,
					char.PrimaryPart.Position
				)
				task.wait(0.3)
			else
				local cash = FindNearestCash(bred)

				if cash then
					PickCash(cash)
					task.wait(0.75)
				else
					task.wait(0.1)

					if not FindNearestCash(bred) then
						task.wait(1)
						if not FindNearestCash(bred) then
							break
						end
					end
				end
			end
		end
	end)
end

local function BreakBredMakur(bred)
	RefreshChar()

	local tool = Character:FindFirstChild("Crowbar")
	if not tool then
		while task.wait() do
			tool = LocalPlayer.Backpack:FindFirstChild("Crowbar")
			if tool then
				break
			end
		end
		tool.Parent = Character
	end

	local values = bred:FindFirstChild("Values")
	if not values then
		return
	end

	local broken = values:FindFirstChild("Broken")
	if not broken or broken.Value == true then
		return
	end

	HitMAKURRA(bred)
	task.spawn(function()
		TeleportWithRetry(bred)
	end)
end

local function Anim()
	if
		not LocalPlayer.Character
		or not LocalPlayer.Character.Humanoid
		or LocalPlayer.Character.Humanoid.Health <= 0
	then
		return
	end
	if workspace:FindFirstChild("me deleta dps pra n dar memory leak") then
		return
	end
	local Character = LocalPlayer.Character

	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	local Animator = Humanoid:FindFirstChildWhichIsA("Animator")

	for _, Limb in Character:GetDescendants() do
		if Limb:IsA("BasePart") and Limb.CanCollide == true then
			Limb.CanCollide = false
		end
	end

	local CarpetAnim = Instance.new("Animation")
	CarpetAnim.AnimationId = "rbxassetid://215384594"
	CarpetAnim.Parent = workspace
	CarpetAnim.Name = "me deleta dps pra n dar memory leak"

	LocalPlayer.Character.Humanoid.PlatformStand = true

	local LoadedCarpetAnim = Animator:LoadAnimation(CarpetAnim)
	LoadedCarpetAnim.Priority = Enum.AnimationPriority.Action4
	LoadedCarpetAnim:Play(0, 1e17, 0)
	LoadedCarpetAnim.TimePosition = 0.3
end

local function StopScript()
	if
		not LocalPlayer.Character
		or not LocalPlayer.Character.Humanoid
		or LocalPlayer.Character.Humanoid.Health <= 0
	then
		return
	end
	local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
	local Hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	Hum.PlatformStand = false
	Hrp.Anchored = false

	for _, Anim in Hum:GetPlayingAnimationTracks() do
		Anim:Stop()
	end
end

local function ChangeHumCF()
	if
		not LocalPlayer.Character
		or not LocalPlayer.Character.Humanoid
		or LocalPlayer.Character.Humanoid.Health <= 0
	then
		return
	end
	local Character = LocalPlayer.Character

	local hrp = Character:FindFirstChild("HumanoidRootPart")
	hrp.Rotation = Vector3.new(90, 0, 0)
	--hrp.Position = hrp.Position + Vector3.new(0,2,0)

	hrp.Transparency = 0
	hrp.Anchored = false
end

local function GetSortedMakursByDistance()
	RefreshChar()
	local root = Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return {}
	end
	local rootPos = root.Position

	local availableMakurs = {}
	for _, makur in CashSpawns:GetChildren() do
		local values = makur:FindFirstChild("Values")
		local broken = values and values:FindFirstChild("Broken")
		if broken and broken.Value == false then
			local main = makur:FindFirstChild("MainPart")
			local disst = (rootPos - main.Position).Magnitude
			if makur.Name:find("Register") and disst > MaxDist then
				continue
			end
			if main and not table.find(ihatecofres, makur.Name) then
				table.insert(availableMakurs, { makur = makur, dist = (rootPos - main.Position).Magnitude })
			end
		end
	end
	table.sort(availableMakurs, function(a, b)
		return a.dist < b.dist
	end)
	return availableMakurs
end

local function CheckForCrowbar()
	local Character = LocalPlayer.Character
	local Backpack = LocalPlayer.Backpack
	local ToolTable = { "Crowbar" }
	local ReturnTable = {}

	if KillAF and not table.find(ToolTable, "Fire-Axe") then
		table.insert(ToolTable, "Fire-Axe")
	end
	if not Character or not Backpack then
		return
	end

	for _, Item in Backpack:GetChildren() do
		if table.find(ToolTable, Item.Name) then
			table.insert(ReturnTable, Item.Name)
		end
	end
	for _, Item in Character:GetChildren() do
		if table.find(ToolTable, Item.Name) then
			table.insert(ReturnTable, Item.Name)
		end
	end

	return ReturnTable
end

local function SortDealers()
	RefreshChar()
	local root = Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local rootPos = root.Position

	local Shopz = workspace:WaitForChild("Map"):WaitForChild("Shopz")

	local availableDellirs = {}
	for _, Dellirs in Shopz:GetChildren() do
		local Crowbar = Dellirs.CurrentStocks:FindFirstChild("Crowbar")
		local MainPart = Dellirs.MainPart
		if
			Dellirs
			and Crowbar
			and Crowbar.Value > 0
			and MainPart
			and MainPart.Position ~= Vector3.new(-4122.08251953125, -93.27604675292969, -701.3008422851562)
		then
			table.insert(availableDellirs, { Dealer = Dellirs, dist = (rootPos - MainPart.Position).Magnitude })
		end
	end

	table.sort(availableDellirs, function(a, b)
		return a.dist < b.dist
	end)
	return availableDellirs
end

local function BuyCrowbar()
	local Dealers = SortDealers()
	if #Dealers == 0 then
		return
	end

	local MainPart = Dealers[1].Dealer.MainPart

	while RunService.Stepped:Wait() do
		local Inv = CheckForCrowbar()
		local Crowbar = Inv ~= nil and Inv[1] or nil
		if Crowbar then
			break
		end
		SmoothTeleport(MainPart.Position)
		BuyRemote:InvokeServer("IllegalStore", "Melees", "Crowbar", MainPart, nil, true)
		if KillAF then
			BuyRemote:InvokeServer("IllegalStore", "Melees", "Fire-Axe", MainPart, nil, true)
		end
	end
end

local function IsAlive(char)
	local hum = char and char:FindFirstChild("Humanoid")
	return hum and hum.Health > 0
end

local function AutoFarmMakursFunctional()
	task.spawn(function()
		while not _G.STOP do
			task.wait()

			local char = LocalPlayer.Character
			if not IsAlive(char) then
				StopScript()
				break
			end

			ChangeHumCF()
			Anim()
			char.Humanoid.PlatformStand = true
		end
	end)

	while not _G.STOP do
		task.wait()

		local char = LocalPlayer.Character
		if not IsAlive(char) then
			break
		end

		local sorted = GetSortedMakursByDistance()
		local Makur = sorted and sorted[1]

		if not Makur then
			task.wait(2)
			continue
		end

		-- Checa crowbar
		local inv = CheckForCrowbar()
		local crowbar = inv and inv[1]

		if not crowbar then
			BuyCrowbar()
			repeat
				task.wait()
			until AntiExploitHits < 1 or _G.STOP
		end

		-- Equipa crowbar
		local tool = char:FindFirstChild("Crowbar") or LocalPlayer.Backpack:FindFirstChild("Crowbar")
		if not tool then
			continue
		end

		if tool.Parent ~= char then
			tool.Parent = char
		end

		-- Anti exploit controle
		if AntiExploitHits >= 3 and Makur.dist > TweenDist then
			repeat
				task.wait()
			until AntiExploitHits < 3 or _G.STOP
		end

		-- Quebrar cofre
		local cofreDone = false
		local startTime = tick()

		local values = Makur.makur:FindFirstChild("Values")
		local broken = values and values:FindFirstChild("Broken")
		if not broken then
			continue
		end

		BreakBredMakur(Makur.makur)

		repeat
			task.wait(0.1)

			local cash = FindNearestCash(Makur.makur)

			if broken.Value and not cash and not cofreDone then
				task.wait(0.5)
				if not FindNearestCash(Makur.makur) then
					cofreDone = true
				end
			end

		until cofreDone or tick() - startTime >= 30 or _G.STOP
	end
end

task.spawn(AutoFarmMakursFunctional)

if LocalPlayer.Character and not CheckForCrowbar() then
	local Humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
	if Humanoid then
		Humanoid.Health = 0
	end
end

local function SafeStopThread()
	if runningThread then
		pcall(function()
			coroutine.close(runningThread)
		end)
		runningThread = nil
	end
end

local function Cleanup()
	local leak = workspace:FindFirstChild("me deleta dps pra n dar memory leak")
	if leak then
		leak:Destroy()
	end
end

local function Respawn()
	if respawning then
		return
	end
	respawning = true

	_G.STOP = true
	SafeStopThread()

	-- tenta respawn até funcionar
	for i = 1, 25 do
		if IsAlive(LocalPlayer.Character) then
			break
		end
		ReplicatedStorage.Events.DeathRespawn:InvokeServer("KMG4R904")
		task.wait(0.15)
	end

	-- espera o character realmente voltar
	LocalPlayer.CharacterAdded:Wait()
	local char = LocalPlayer.Character

	repeat
		task.wait()
	until IsAlive(char)

	-- reset geral
	Cleanup()
	Reducing = false
	ResetCounters()

	task.wait(1)

	_G.STOP = false
	runningThread = task.spawn(AutoFarmMakursFunctional)

	respawning = false
end

local charaddedConn = LocalPlayer.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")

	hum.Died:Connect(function()
		Respawn()
	end)

	if not respawning then
		_G.STOP = false
		SafeStopThread()
		runningThread = task.spawn(AutoFarmMakursFunctional)
	end
end)
table.insert(connections, charaddedConn)

if LocalPlayer.Character and IsAlive(LocalPlayer.Character) then
	SafeStopThread()
	runningThread = task.spawn(AutoFarmMakursFunctional)

	local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
	if hum then
		local diedConn = hum.Died:Once(function()
			Respawn()
		end)
		table.insert(connections, diedConn)
	end
end
