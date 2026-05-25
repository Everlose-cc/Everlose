--!nocheck

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Map = workspace.Map

local Await = 0

local function getCharacter(): Model?
	return LocalPlayer.Character
end

local function getRoot(): BasePart?
	local char = getCharacter()
	if char then
		return char:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function can()
	if Await > 0 or not getCharacter() or not getRoot() then
		repeat
			task.wait()
		until Await <= 0 and getCharacter() and getRoot()
	end
end

local function touch(a: Instance?, b: Instance?)
	task.wait()
	if (a and a.Parent) and (b and b.Parent) then
		firetouchinterest(a, b, true)
	end
	task.wait()
	if (a and a.Parent) and (b and b.Parent) then
		firetouchinterest(a, b, false)
	end
	task.wait()
end

local function DoRoom(Room: Folder)
	can()

	if Room.Name == "RouletteRoom" then
		Await += 1
		repeat
			task.wait(0.1)
			local doorsFolder = Room:FindFirstChild("Doors")
			local root = getRoot()
			if doorsFolder and root then
				for _, door in doorsFolder:GetChildren() do
					if door:FindFirstChildOfClass("TouchTransmitter") then
						touch(root, door)
						break
					end
				end
			end
		until not Room or not Room.Parent
		Await -= 1
	end

	if Room.Name == "Maze" then
		Await += 1
		repeat
			task.wait(0.1)
			local configs = Room:FindFirstChild("Configs")
			local root = getRoot()
			if configs then
				for _, cfg in configs:GetChildren() do
					for _, child in cfg:GetChildren() do
						if child.Name:lower():find("exit") then
							if child:FindFirstChildOfClass("TouchTransmitter") then
								touch(root, child)
								break
							end
						end
					end
				end
			end
		until not Room or not Room.Parent
		Await -= 1
	end

	if Room.Name == "End" then
		Await += 1
		repeat
			task.wait(0.1)
			local root = getRoot()
			if root then
				local portalPart = Room:FindFirstChild("PortalPart")
				if portalPart and portalPart:FindFirstChildOfClass("TouchTransmitter") then
					touch(root, portalPart)
				end
			end
		until not Room or not Room.Parent
		Await -= 1
	end
end

if _G.CTConn then
    _G.CTConn:Disconnect()
end
_G.CTConn = workspace.Map.CT_DIR.ChildAdded:Connect(function(c: Instance)
	DoRoom(c)
end)

-- for _, v in workspace.Map.CT_DIR.CT_OBBY:GetChildren() do
-- 	local Hazards = v:FindFirstChild("Hazards")

-- 	if Hazards then
-- 		for _, hazard in Hazards:GetChildren() do
-- 			hazard:PivotTo(CFrame.new(vector.zero))
-- 		end
-- 	end
-- end
