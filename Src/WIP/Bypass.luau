local Bypasses = {}
Bypasses.__index = Bypasses

local plrname = game:GetService("Players").LocalPlayer.Name

local function ErrHandler(...)
	warn(`Everlose error: {...}`)
end

Bypasses.Yield = function()
	coroutine.yield()
	return task.wait(1e17)
end

Bypasses.Adonis = function()
	local AdonisKeys = {
		["Detected"] = "function",
		["RLocked"] = "function",
	}
	local AdonisPaths = {
		".Client.Core.Anti",
		".Client.Plugins.Anti_Cheat",
	}
	local AdonisTables = {}
	local AdonisThreads = {}

	local function IsAdonisTable(Tbl: {}): boolean
		for key, keyType in AdonisKeys do
			local get = rawget(Tbl, key)
			if get and typeof(get) ~= keyType or not get then
				return false
			end
		end
		return true
	end

	for _, thread in getreg() do
		if typeof(thread) == "thread" then
			local s = debug.info(thread, 1, "slnaf")
			if s ~= "" and s ~= " " and s ~= nil then
				for _, Path in AdonisPaths do
					if s:match(Path) then
						table.insert(AdonisThreads, thread)
						break
					end
				end
			end
		end
	end

	if filtergc then
		local Keys = {}
		for i in AdonisKeys do
			table.insert(Keys, i)
		end
		local FilteredGC = filtergc("table", { Keys = Keys }, false)
		for _, tbl in FilteredGC do
			if IsAdonisTable(tbl) then
				table.insert(AdonisTables, tbl)
			end
		end
	else
		local gc = getgc(true)
		for _, obj in gc do
			if typeof(obj) == "table" then
				if IsAdonisTable(obj) then
					table.insert(AdonisTables, obj)
				end
			end
		end
	end

	for _, thread in AdonisThreads do
		task.cancel(thread)
	end
	for _, AdonisTable in AdonisTables do
		for k, keyType in AdonisKeys do
			if keyType == "function" then
				warn("Hooking Adonis function: ", k)
				local fn = rawget(AdonisTable, k)
				hookfunction(fn, Bypasses.Yield)
			end
		end
	end
end

Bypasses.Criminality = function()
	local FNHash = "b7813a36de66da441fb6e63dfb024ccbc249934afcc67aad7a61ba464f6b366ea023cdabe4b05b75c8ee97d98bc7921c"

	local function IsDTC(fn: AnyFunction): boolean
		local s = debug.info(fn, "s")
		if typeof(fn) ~= "function" or not islclosure(fn) or not s:find(`{plrname}.PlayerScripts`) then
			return false
		end

		if getfunctionhash(fn) == FNHash then
			warn("Hash Match")
			return true
		end

		local fnConstants = debug.getconstants(fn)
		local fnUpvalues = debug.getupvalues(fn)
		local fnProtos = debug.getprotos(fn)

		local constants = {
			"pairs",
			"userdata",
			"tostring",
			"userdata",
			"table",
			"insert",
			"userdata",
			"Z_Z",
			"RenderStepped",
			"Wait",
			"1000",
		}
		local upvalues = {
			"true",
			"function",
			plrname,
			"Humanoid",
			"function",
			"function",
			"somerandomnumberssorry",
			"false",
			"Run Service",
		}
		local protos = {
			"ProtoProxy",
			"ProtoProxy",
		}

		local matchCount = 0

		for index, constant in fnConstants do
			xpcall(function()
				if constants[index] == tostring(constant) then
					matchCount += 1
				end
			end, ErrHandler)
		end

		for index, upvalue in fnUpvalues do
			xpcall(function()
				if upvalues[index] == tostring(upvalue) then
					matchCount += 1
				end
			end, ErrHandler)
		end

		for index, proto in fnProtos do
			xpcall(function()
				if protos[index] == tostring(proto) then
					matchCount += 1
				end
			end, ErrHandler)
		end

		warn("Other Match")
		return matchCount >= 13
	end

	local fns = filtergc("function", {
		IgnoreExecutor = true,
	})

	for _, fn in fns do
		if IsDTC(fn) then
			hookfunction(fn, Bypasses.Yield)
		end
	end
end

return Bypasses
