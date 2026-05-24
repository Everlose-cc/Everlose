local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = ReplicatedStorage.Modules.NoxNetwork

local functions = filtergc("function", { IgnoreExecutor = true }, false)

for _, fn in functions do
    local fn_s = debug.info(fn, "s")
	if Module:GetFullName():find(fn_s) then
		local s, l, n, a, f = debug.info(fn, "slnaf")
		if n == "" or n == " " then
			local constants = debug.getconstants(fn)
			local upvalues = debug.getupvalues(fn)

            local function test(fn2)
                if typeof(fn2) ~= "function" then return end
                local s2, l2, n2, a2, f2 = debug.info(fn2, "slnaf")
                print(`Subfn: {s2}, {l2}, {n2}, {a2}, {f2}`)
                hookfunc(fn2, function(...): ...any
                    return false
                end)
            end

			for idx, constant in constants do
				test(constant)
			end
			for idx, upvalue in upvalues do
				test(upvalue)
			end
		end
	end
end
