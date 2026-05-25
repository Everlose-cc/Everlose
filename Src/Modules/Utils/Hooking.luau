--!nocheck

local othSupport = oth ~= nil

local restore = restorefunc or restorefunction
local hookfn = hookfunc or hookfunction or replaceclosure
local getraw = getrawmetatable
local hookmm = hookmetamethod

local HookingService = {}

wax.shared.Hooks = {}

local function errorHandler(message: string)
	wax.shared.Logger.error(`{message} {debug.traceback()}`)
end

function HookingService.hookfunction(Original: AnyFunction, Replacement: AnyFunction): AnyFunction
	if not Original then
		errorHandler("Orignal function not found.")
		return
	end
	if not Original then
		errorHandler("Replacement function not found.")
		return
	end

	local hookMethod = (iscclosure(Original) and othSupport and oth.hook or hookfn)

	local hkd
	hkd = hookMethod(Original, Replacement)

	return hkd
end

function HookingService.hookmetamethod(object: Object, method: string, hook: AnyFunction): AnyFunction
	if not getraw then
		return
	end
	if not hookmm and not oth then
		return
	end

	local RawMetatable = getrawmetatable(object)
	if not RawMetatable then
		errorHandler("Object doesn't have a metatable.")
		return
	end

	local fn: AnyFunction = rawget(RawMetatable, method)
	if fn then
		local hfn = HookingService.hookfunction(fn, hook)
		wax.shared.Hooks[fn] = hfn
		return hfn
	else
		errorHandler(`Invalid function at {object}, couldn't find metamethod {method}.`)
		return
	end
end

function HookingService.unhook(Method: "FromHook" | "FromOriginal", fn: AnyFunction)
	if Method == "FromHook" then
		for original: AnyFunction, hook: AnyFunction in wax.shared.Hooks do
			if fn == hook then
				if othSupport and iscclosure(original) then
					oth.unhook(original)
				else
					restore(original)
				end
				break
			end
		end
	elseif Method == "FromOriginal" then
		if othSupport then
			oth.unhook(fn)
		else
			restore(fn)
		end
	end
end

function HookingService.unhookAll()
	for original: AnyFunction, hook: AnyFunction in wax.shared.Hooks do
		HookingService.unhook("FromOriginal", original)
		wax.shared.Hooks[original] = nil
	end
end

return HookingService
