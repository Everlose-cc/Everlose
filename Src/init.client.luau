--!nocheck

if shared["EverloseLoaded"] == true then
	warn("EL is already loaded.")
	return
end
shared.EverloseLoaded = true

--// Services
-------------

local Services = {
	HttpService = cloneref(game:GetService("HttpService")),
	ProximityPromptService = cloneref(game:GetService("ProximityPromptService")),
	VirtualUser = cloneref(game:GetService("VirtualUser")),
	UserInputService = cloneref(game:GetService("UserInputService")),
	RunService = cloneref(game:GetService("RunService")),
	Players = cloneref(game:GetService("Players")),
	Stats = cloneref(game:GetService("Stats")),
	ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage")),
	TweenService = cloneref(game:GetService("TweenService")),
	CollectionService = cloneref(game:GetService("CollectionService")),
}
wax.shared.Services = Services

wax.shared.LocalPlayer = Services.Players.LocalPlayer

--// SafeCall
-------------
local function SafeCall(Func: (...any) -> ...any, ...: any)
	if not (Func and typeof(Func) == "function") then
		return
	end

	local Result = table.pack(xpcall(Func, function(Error: string)
		wax.shared.Janitor:Add(task.defer(error, debug.traceback(Error, 2)))
		return Error
	end, ...))

	if not Result[1] then
		return nil
	end

	return table.unpack(Result, 2, Result.n)
end

wax.shared.SafeCall = SafeCall

local Unloading = false
function shared.EverloseInternalUnload()
	if Unloading then
		return
	end
	Unloading = true

	SafeCall(wax.shared.Library.Unload, wax.shared.Library)
	SafeCall(wax.shared.EspLibrary.Destroy, wax.shared.EspLibrary)
	SafeCall(wax.shared.FlyModule.Destroy, wax.shared.FlyModule)
	SafeCall(wax.shared.Janitor.Destroy, wax.shared.Janitor)
	SafeCall(wax.shared.Hooking.UnhookAll)

	shared.EverloseLoaded = nil
	shared.EverloseInternalUnload = nil
	Unloading = false
end

wax.shared.EverloseStartTime = tick()

local deividcomsonoObsidianRepo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local mstudio45MSESPRepo = "https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/"
local LunaXYZRepo = "https://raw.githubusercontent.com/00lxh/luna_xyz/refs/heads/main/src/"

local Library: Library = loadstring(game:HttpGet(deividcomsonoObsidianRepo .. "Library.lua"))() -- Bro upio add the fucking .luau extension already
local ThemeManager = loadstring(game:HttpGet(deividcomsonoObsidianRepo .. "addons/ThemeManager.lua"))() -- Bro upio add the fucking .luau extension already
local SaveManager = loadstring(game:HttpGet(deividcomsonoObsidianRepo .. "addons/SaveManager.lua"))() -- Bro upio add the fucking .luau extension already
local EspLibrary = loadstring(game:HttpGet(mstudio45MSESPRepo .. "source.luau"))() -- Thanks for having the fucking .luau extension
local Logger = loadstring(game:HttpGet(LunaXYZRepo .. "utils/system/Logger.lua"))() -- Not the non .luau extension, 😭

wax.shared.Library = Library
wax.shared.ThemeManager = ThemeManager
wax.shared.SaveManager = SaveManager
wax.shared.EspLibrary = EspLibrary
wax.shared.Logger = Logger

wax.shared.Promise = require("Modules/Utils/Promise")

local JanitorClass: JanitorStatic = require("Modules/Performance/Janitor")
local Janitor: Janitor = JanitorClass.new()

wax.shared.JanitorClass = JanitorClass
wax.shared.Janitor = Janitor
wax.shared.InstanceCache = require("Modules/Performance/InstanceCache")
wax.shared.TableUtils = require("Modules/Performance/TableUtils")

wax.shared.InputModule = require("Modules/Utils/InputModule")
wax.shared.Hooking = require("Modules/Utils/Hooking")
wax.shared.ClientUtils = require("Modules/Utils/ClientUtils")

wax.shared.Tracers = require("Modules/VisualStuff/Tracers")
wax.shared.RichTextManager = require("Modules/VisualStuff/RichTextManager")

wax.shared.QueryBuilder = require("Modules/Performance/QueryBuilder")
wax.shared.FlyModule = require("Modules/Mods/Fly")

--// Drawings
-------------
wax.shared.Drawings = {}

--// Groupboxes
---------------
wax.shared.Groupboxes = {}
wax.shared.RefreshGroupboxes = function()
	for _, v in wax.shared.Library.Tabs do
		for i, k in v.Groupboxes do
			if wax.shared.Groupboxes[i] then
				continue
			end
			wax.shared.Groupboxes[i] = k
		end
	end
end

--// WaitForChildOfClass
------------------------
wax.shared["WaitForChildOfClass"] = function(Parent: Instance, ClassName: string, TimeOut: number?)
	local StartTime = os.clock()
	while Services.RunService.Stepped:Wait() and (StartTime + TimeOut) - os.clock() > 0 and Parent do
		local Inst = Parent:FindFirstChildOfClass(ClassName)
		if Inst then
			return Inst
		end
	end
	return nil
end

--// DeepCopy
-------------
wax.shared.DeepCopy = function(orig: AnyTable, copies: { [AnyTable]: any })
	copies = copies or {}
	local orig_type = typeof(orig)
	local copy
	if orig_type == "table" then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[wax.shared.DeepCopy(orig_key, copies)] = wax.shared.DeepCopy(orig_value, copies)
			end
			setmetatable(copy, wax.shared.DeepCopy(getmetatable(orig), copies))
		end
	else
		copy = orig
	end
	return copy
end

--// Window
-----------
local Window: Window = Library:CreateWindow({
	Title = "Everlose",
	Footer = `Version: {"Alpha"}: {"0.0.1"}`,
	Icon = 89401785954152,
	NotifySide = "Right",
	ShowCustomCursor = true,
})
--[[
local Tabs = {
	Main = Window:AddTab({
		Name = "Main",
		Icon = "circle-user-round",
		Description = "Main features such as Speed, Jump, and more.",
	}),
	Visuals = Window:AddTab({
		Name = "Visuals",
		Icon = "eye",
		Description = "Visual features such as ESP and Chams.",
	}),
}
]]

wax.shared.Window = Window

--// Loader
-----------
wax.shared.Tabs = {}

wax.shared.Load = function(LoaderName: string, Type: string, ModuleName: string)
	local Path = `Loaders/{LoaderName}/{Type}/{ModuleName}`
	warn("Loading: " .. Path)
	local Result = nil
	SafeCall(function()
		Result = table.pack(require(Path)())
		wax.shared.RefreshGroupboxes()
	end)
	if Result ~= nil then
		warn("Loaded: " .. Path)
	end
	return table.unpack(Result)
end

require("Loader").Setup()

warn("EVERLOSE: Loading Done.")


local Players = cloneref(game:GetService("Players"))

local LocalPlayer = Players.LocalPlayer

warn("-------------------------------------------")

-- local gc = filtergc("function", {
-- 	Name = "regenerate",
-- 	IgnoreExecutor = true,
-- }, false)

-- for _, fn in gc do
--     local source = debug.info(fn, "s")
--     if source:find(".SprintFrame.Stamina") then
-- 		debug.setupvalue(fn, 4, 100)
--     end
-- end