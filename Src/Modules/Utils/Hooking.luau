--// Skidded from Upio's Cobalt Remotespy (I was too lazy, sry)

local othSupport = oth ~= nil

local Hookfn = hookfunction ~= nil and hookfunction or replaceclosure ~= nil and replaceclosure or nil
local HasHookMetaMethod = hookmetamethod ~= nil and hookmetamethod or nil
local HasGetRawMetatable = getrawmetatable ~= nil and getrawmetatable or nil

local HookingService = {}

function HookingService.HookFunction(Original: AnyFunction, Replacement: AnyFunction)
	if othSupport and iscclosure(Original) and islclosure(Replacement) then
		return oth.hook(Original, Replacement)
	end

	if islclosure(Replacement) then
		Replacement = newcclosure(Replacement)
	end

	if not Hookfn then
		return Original
	end

	return hookfunction(Original, Replacement)
end

function HookingService.HookMetaMethod(object, method: string, hook: AnyFunction) -- Adding a Type to "object" gives a error :>
	if not HasGetRawMetatable then
		return
	end

	local Metatable = HasGetRawMetatable(object)
	local originalMethod = rawget(Metatable, method)

	if othSupport then
		return oth.hook(originalMethod, hook)
	end

	if islclosure(hook) then
		hook = newcclosure(hook)
	end

	if not HasHookMetaMethod and HasGetRawMetatable ~= nil then
		setreadonly(Metatable, false)
		rawset(Metatable, method, hook)
		setreadonly(Metatable, true)

		return originalMethod
	end

	if not wax.shared.ExecutorSupport["hookmetamethod"].IsWorking then
		if method == "__index" then
			local _, Metamethod = xpcall(function()
				return object[tostring(math.random())]
			end, function(err)
				return debug.info(2, "f")
			end)

			return Metamethod
		elseif method == "__newindex" then
			local _, Metamethod = xpcall(function()
				object[tostring(math.random())] = true
			end, function(err)
				return debug.info(2, "f")
			end)

			return Metamethod
		elseif method == "__namecall" then
			local _, Metamethod = xpcall(function()
				object:EverloseCall()
			end, function(err)
				return debug.info(2, "f")
			end)

			return Metamethod
		end

		return nil
	end

	return HasHookMetaMethod(object, method, hook)
end

return HookingService
