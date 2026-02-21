--!nocheck

wax.shared.EverloseStartTime = tick()

local deividcomsonoObsidianRepo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local mstudio45MSESPRepo = "https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/"

local Library: Library = loadstring(game:HttpGet(deividcomsonoObsidianRepo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(deividcomsonoObsidianRepo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(deividcomsonoObsidianRepo .. "addons/SaveManager.lua"))()
local EspLibrary = loadstring(game:HttpGet(mstudio45MSESPRepo .. "source.luau"))()

wax.shared.Library = Library
wax.shared.ThemeManager = ThemeManager
wax.shared.SaveManager = SaveManager
wax.shared.EspLibrary = EspLibrary

local Connections = require("Utils/Connections")
local Signal = require("Utils/Signal")
wax.shared.Signal = Signal
wax.shared.Signals = {
	PlayerAdded = wax.shared.Signal.new(),
	CharacterAdded = wax.shared.Signal.new(),
}

wax.shared.DefaultValues = {
	["Humanoid"] = {
		["WalkSpeed"] = 16,
		["JumpPower"] = 50,
		["JumpHeight"] = 7.2,
	}
}

wax.shared["WaitForChildOfClass"] = function(Parent: Instance, ClassName: string, TimeOut: number?)
	local StartTime = tick()
	while task.wait() and (StartTime+TimeOut)-tick() > 0 and Parent do
		local Inst = Parent:FindFirstChildOfClass(ClassName)
		if Inst then return Inst end
	end
	return nil
end

local ConnectionsHandler = require("Utils/Connections")
wax.shared.ConnectionsHandler = ConnectionsHandler

local ThreadsHandler = require("Utils/ThreadsHandler")
wax.shared.ThreadsHandler = ThreadsHandler

Library.ForceCheckbox = true

-- local Options = Library.Options
-- local Toggles = Library.Toggles

--// Services
local Services = require("Utils/Services")
Services:GetServices({
	"RunService",
	"UserInputService",
	"TweenService",
	"ContextActionService",
	"Players",
	"ReplicatedStorage",
	"CoreGui",
	"VirtualUser",
	"ProximityPromptService",
	"TextChatService",
})
wax.shared.Services = Services

local FlyModule = require("Utils/LocalPlayer/Fly")
wax.shared.FlyModule = FlyModule

local Players: Players = Services:GetService("Players")
local LocalPlayer: Player = Players.LocalPlayer

local function HandlePlayerAdded(Player: Player)
	wax.shared.Signals.PlayerAdded:Fire(Player)
	if Player.Character then
		wax.shared.Signals.CharacterAdded:Fire(Player.Character)
	end
	table.insert(Connections, Player.CharacterAdded:Connect(function(Character: Model)
		wax.shared.Signals.CharacterAdded:Fire(Character)
	end))
end

wax.shared.LocalPlayer = LocalPlayer

--// Loader
wax.shared.Load = function(Type: "Tabs" | "Functions", LoaderName:string)
	warn("Loaded: " .. Type .. "/" .. LoaderName)
	return require("Loaders/"..Type.."/"..LoaderName)
end

--// Hooking Service
wax.shared.Hooks = {}

local HasOth = (getgenv()["oth"] ~= nil and true or false)

local IsHooked = (getgenv()["ishooked"] or getgenv()["isfunctionhooked"]) or function(fn:AnyFunction)
    for _,Hook in wax.shared.Hooks do
        if Hook.OldFunction == fn then
            return true
        end
    end
    return false
end

wax.shared.IsHooked = IsHooked
wax.shared.HasOth = HasOth

--// UI
local _UI = require("Utils/UI")

--// Connections
local LocalCharacterAddedHandler = require("Utils/LocalPlayer/CharacterAdded")
if LocalPlayer.Character then
	LocalCharacterAddedHandler(LocalPlayer.Character)
end
ConnectionsHandler:GiveSignal(LocalPlayer.CharacterAdded, LocalCharacterAddedHandler)

for _,Player in Players:GetPlayers() do
	if Player ~= LocalPlayer then
		HandlePlayerAdded(Player)
	end
end
ConnectionsHandler:GiveSignal(Players.PlayerAdded, HandlePlayerAdded)


warn("EVERLOSE: Loading Done.")