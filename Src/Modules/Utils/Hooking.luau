--!nocheck

local othSupport = oth ~= nil

local Hookfn = othSupport and oth.hook or hookfunction or replaceclosure or nil
local RestoreFn = othSupport and oth.unhook or restorefunction or nil
local HasGetRawMetatable = getrawmetatable ~= nil and true or nil

local HookingService = {}

wax.shared.Hooks = {}

function HookingService.HookFunction(Original: AnyFunction, Replacement: AnyFunction)
	return Hookfn(Original, Replacement)
end

function HookingService.HookMetaMethod(object: Object, method: string, hook: AnyFunction)
	if not HasGetRawMetatable then
		return
	end

	local RawMetatable = getrawmetatable(object)
	local fn: AnyFunction = rawget(RawMetatable, method)

	local hfn = HookingService.HookFunction(fn, hook)
	wax.shared.Hooks[fn] = hfn

	return hfn
end

function HookingService.Unhook(Method: "FromHook" | "FromOriginal", fn: AnyFunction)
	if Method == "FromHook" then
		for original: AnyFunction, hook: AnyFunction in wax.shared.Hooks do
			if fn == hook then
				RestoreFn(original, hook)
				break
			end
		end
	elseif Method == "FromOriginal" then
		if othSupport then
			RestoreFn(fn, wax.shared.Hooks[fn])
		else
			restorefunction(fn)
		end
	end
end

function HookingService.UnhookAll()
	for original: AnyFunction, hook: AnyFunction in wax.shared.Hooks do
		HookingService.Unhook("FromOriginal", original)
		wax.shared.Hooks[original] = nil
	end
end

return HookingService
