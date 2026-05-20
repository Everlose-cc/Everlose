--!nocheck
--!nolint BuiltinGlobalWrite

local function output(...)
	print("Melee Reach: " .. tostring(...))
end

if _G.ReachConnections then
	for _, connection in _G.ReachConnections do
		xpcall(connection.Disconnect, output, connection)
	end
end

if _G.ReachThreads then
	for _, thread in _G.ReachThreads do
		xpcall(task.cancel, output, thread)
	end
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local raw = getrawmetatable(game)

_G.ReachConnections = {}
_G.ReachThreads = {}

local currentTool: Tool = nil

local oldTask = getgenv().task
task = {
	spawn = function(...)
		local thread = oldTask.spawn(...)
		table.insert(_G.ReachThreads, thread)
		return thread
	end,
	defer = function(...)
		local thread = oldTask.defer(...)
		table.insert(_G.ReachThreads, thread)
		return thread
	end,
	delay = function(...)
		local thread = oldTask.delay(...)
		table.insert(_G.ReachThreads, thread)
		return thread
	end,
	cancel = function(...)
		local thread = select(1, ...)
		local index = table.find(_G.ReachThreads, thread)
		if index then
			table.remove(_G.ReachThreads, index)
		end
		xpcall(oldTask.cancel, output, thread)
	end,
	wait = oldTask.wait,
	syncronize = oldTask.synchronize,
	desynchronize = oldTask.desynchronize,
}

local function connect(signal: RBXScriptSignal, fn: AnyFunction, method: string)
	method = method:lower()
	local connection
	if method == "connect" or method == "once" then
		connection = signal[method](signal, fn)
		table.insert(_G.ReachConnections, connection)
	elseif method == "wait" then
		connection = signal[method](signal)
		if fn then
			fn(connection)
		end
	else
		output("Invalid connection method: " .. method)
	end
	return connection
end
local function disconnect(connection: RBXScriptConnection)
	for i, v in _G.ReachConnections do
		if v == connection then
			table.remove(_G.ReachConnections, i)
			v:Disconnect()
			return
		end
	end
end

local handleChar = function(char: Model)
	local Humanoid = char:WaitForChild("Humanoid")

	local function childAdded(child: Instance)
		if child:IsA("Tool") then
			currentTool = child
		end
	end
	local function childRemoved(child: Instance)
		if child:IsA("Tool") and child == currentTool then
			currentTool = nil
		end
	end

	local tool = char:FindFirstChildOfClass("Tool")
	if tool then
		childAdded(tool)
	end

	connect(char.ChildAdded, childAdded, "connect")
	connect(char.ChildRemoved, childRemoved, "connect")
end

--yuxido3 is the next

if LocalPlayer.Character then
	task.spawn(handleChar, LocalPlayer.Character)
end
connect(LocalPlayer.CharacterAdded, handleChar, "connect")

local function targetable(character: Model)
	local Humanoid = character:FindFirstChildOfClass("Humanoid")
	if not Humanoid or Humanoid.Health <= 0 or Humanoid.Health >= 10000 then
		return false
	end

	local Head = character:FindFirstChild("Head")
	if not Head then
		return false
	end

	local distance = (Head.Position - LocalPlayer.Character.Head.Position).Magnitude
	if distance > 20 then
		return false
	end

	if character:FindFirstChildOfClass("ForceField") then
		return false
	end

	return true, Humanoid, Head, distance
end
local function getNearestTarget()
	local old = getthreadidentity()
	setthreadidentity(8)

	local list = {}
	for _, player in Players:GetPlayers() do
		if player ~= LocalPlayer and not player:IsFriendsWith(LocalPlayer.UserId) then
			local targetCharacter = player.Character
			if targetCharacter then
				local isTargetable, Humanoid, Head, distance = targetable(targetCharacter)
				if isTargetable then
					table.insert(list, {
						Player = player,
						Character = targetCharacter,
						Humanoid = Humanoid,
						Head = Head,
						Distance = distance,
					})
				end
			end
		end
	end

	table.sort(list, function(a, b)
		return a.Distance < b.Distance
	end)

	setthreadidentity(old)

	return list
end

local nearest = nil

connect(RunService.Heartbeat, function(dt: number)
    local currentNearest = getNearestTarget()[1]
    if currentNearest then
        nearest = currentNearest
    else
        nearest = nil
    end
end, "connect")

oth.hook(raw.__namecall, function(...)
	local root = oth.get_root_callback()

	local self = select(1, ...)

	local caller = checkcaller()
	local method = getnamecallmethod()
	local source = getcallingscript()

	if not caller and self == workspace then
		if method == "Raycast" then
			if currentTool and source:GetFullName():find(currentTool.Name) then
				if nearest then
					local rayResult = setmetatable({ __hi = true }, {
						__index = {
							Distance = nearest.Distance,
							Instance = nearest.Head,
							Material = nearest.Head.Material,
							Position = nearest.Head.Position,
							Normal = Vector3.xAxis,
						},
						__metatable = false,
					})
					return rayResult
				end
			end
		end
	end

	return root(...)
end)

oth.hook(typeof, function(obj: Object?)
	local root = oth.get_root_callback()
	if obj and root(obj) == "table" then
		local hiIdx = rawget(obj, "__hi")
		if hiIdx then
			return "RaycastResult"
		end
	end
	return root(obj)
end)
