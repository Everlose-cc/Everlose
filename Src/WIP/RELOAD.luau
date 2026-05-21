local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local GNX_R = ReplicatedStorage.Events.GNX_R

local ReloadKeys = {
	Start = "STZNRD",
	End = "KLWE89U0",
}

local function getCurrentGun(): Tool?
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

local function getPing() : (number)
	return (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000)
end

local function serverTick(): number
	return (workspace:GetServerTimeNow())
end

local function reload()
	local gun, cfg = getCurrentGun()
	if not gun then
		return
	end
    if gun.Values.SERVER_Ammo.Value >= gun.Values.SERVER_Ammo.MaxValue then
        return
    end

	local function _rl()
		local SaltC = serverTick()

		GNX_R:FireServer(SaltC, ReloadKeys.Start, gun, nil, nil)
		GNX_R:FireServer(SaltC + (cfg.ReloadTime + math.random()), ReloadKeys.End, gun, math.random(), nil)
	end
	xpcall(_rl, warn)
end

_G.Reload = true

local nextReload = 0
while _G.Reload and task.wait() do
    if os.clock() - nextReload > (0.25 + getPing()) then
        nextReload = os.clock()
        reload()
    end
end