--!nocheck

local name = identifyexecutor()

if name:lower() == "potassium" then
	getgenv().oth = nil
end

local HitSounds = {
	Everlose = "rbxassetid://127091812835195",
}
local User_HitSound = "Everlose"

local namecall = getrawmetatable(game).__namecall
xpcall(function()
	if oth then
		oth.unhook(namecall)
	else
		restorefunction(namecall)
	end
end, warn)

task.wait(1)

local SoundTemplate = Instance.new("Sound")
SoundTemplate.SoundId = HitSounds[User_HitSound]
SoundTemplate.Volume = 1

local function hookfn(fn: AnyFunction, hook: AnyFunction): AnyFunction?
	if not iscclosure(hook) then
		hook = newcclosure(hook)
	end

	if iscclosure(fn) then
		if oth then
			return oth.hook(fn, hook)
		end
	end

	return hookfunction(fn, hook)
end

local function hookmm(obj: Object, method: string, hook: AnyFunction): AnyFunction?
	local mt = getrawmetatable(obj)
	if mt then
		local fn = rawget(mt, method)

		if oth and iscclosure(fn) then
			return oth.hook(fn, hook)
		else
			return hookmetamethod(obj, method, hook)
		end
	end
	return nil
end

local GameEnv = getrenv()
local CrimCrosshair = GameEnv._G.DCH
local OldHook
OldHook = hookfunction(CrimCrosshair.hitmarker, function(...)
	task.defer(function()
		local old = getthreadidentity()
		setthreadidentity(8)

		local Sound = SoundTemplate:Clone()
		Sound.Parent = game:GetService("CoreGui")
		Sound.Resume(Sound)
		task.delay((Sound.TimeLength / Sound.PlaybackSpeed) + 1, function()
			if Sound then
				Sound:Destroy()
			end
		end)

		setthreadidentity(old)
	end)
	return OldHook(...)
end)
