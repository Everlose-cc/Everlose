--!nocheck

if shared["EverloseLoaded"] == true then
	warn("EL is already loaded.")
	return
end
shared.EverloseLoaded = true

--// Services
-------------

local Services = {
	UserInputService = cloneref(game:GetService("UserInputService")),
	RunService = cloneref(game:GetService("RunService")),
	Players = cloneref(game:GetService("Players")),
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

function shared.EverloseInternalUnload()
	SafeCall(wax.shared.Library.Unload, wax.shared.Library.Unload)
	SafeCall(wax.shared.EspLibrary.Destroy, wax.shared.EspLibrary.Destroy)
	SafeCall(wax.shared.Janitor.Destroy, wax.shared.Janitor.Destroy)

	shared.EverloseLoaded = nil
	shared.EverloseInternalUnload = nil
end

wax.shared.EverloseStartTime = tick()

local deividcomsonoObsidianRepo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local mstudio45MSESPRepo = "https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/"

local Library: Library = loadstring(game:HttpGet(deividcomsonoObsidianRepo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(deividcomsonoObsidianRepo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(deividcomsonoObsidianRepo .. "addons/SaveManager.lua"))()
local EspLibrary = loadstring(game:HttpGet(mstudio45MSESPRepo .. "source.luau"))()

wax.shared.Promise = require("Modules/Utils/Promise")
wax.shared.Janitor = require("Modules/Performance/Janitor")

wax.shared.InstanceCache = require("Modules/Performance/InstanceCache")
wax.shared.Tracers = require("Modules/VisualStuff/Tracers")

wax.shared.Library = Library
wax.shared.ThemeManager = ThemeManager
wax.shared.SaveManager = SaveManager
wax.shared.EspLibrary = EspLibrary

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
	while RunService.Stepped:Wait() and (StartTime + TimeOut) - os.clock() > 0 and Parent do
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
wax.shared.Tabs = {}

--// Loader
-----------
wax.shared.Load = function(LoaderName: string, Type: string)
	warn("Loaded: " .. LoaderName .. "/" .. Type)
	return require("Loaders/" .. LoaderName .. "/" .. Type)()
end

warn("EVERLOSE: Loading Done.")
