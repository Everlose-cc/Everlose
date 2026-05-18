--!nocheck
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local CoreGui = LocalPlayer.PlayerGui:WaitForChild('CoreGUI')
local HitSounds = {
	Everlose = "rbxassetid://127091812835195",
}
local User_HitSound = "Everlose"

const tempTable = table.clone(HitSounds)
for HitSoundName, ID in tempTable do
	local SoundTemplate = Instance.new("Sound")
	SoundTemplate.SoundId = ID
	SoundTemplate.Volume = 1
	HitSounds[HitSoundName] = SoundTemplate
end

local function PlayHitmarkerSound()
	local zSound = HitSounds[User_HitSound]:Clone()
	zSound.Parent = game:GetService("CoreGui")
	zSound:Play()
	Debris:AddItem(zSound, 10)
end

local function MonitorMainCrosshair(Main)
	Main.ChildAdded:Connect(PlayHitmarkerSound)
end

for _, Mains in CoreGui.Crosshair:GetChildren() do
	MonitorMainCrosshair(Mains)
end
CoreGui.Crosshair.ChildAdded:Connect(MonitorMainCrosshair)