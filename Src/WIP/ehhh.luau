local bloodFX = filtergc("function", { IgnoreExecutor = true }, true)
warn(bloodFX)

local output = function(...)
	print(...)
end

local watch = function(fn: AnyFunction)
	local s, l, n, a, f = debug.info(fn, "slnaf")

	local path = `{s},{l},{n},{a},{f}`
	output(`Now Watching: {path}`)

	-- local oh; oh = hookfunction(fn, function(...)
	--     output(`{path}: {...}`)
	--     return oh(...)
	-- end)

	local upvalues = debug.getupvalues(fn)
	local constants = debug.getconstants(fn)
	local protos = debug.getprotos(fn)

	output("upvalues:")
	for i, v in upvalues do
		output(i, v)
	end
	output("constants:")
	for i, v in constants do
		output(i, v)
	end
	output("protos:")
	for i, v in protos do
		output(i, v)
	end
end

local gc = filtergc("function", { IgnoreExecutor = true }, false)

for _, obj in gc do
	if islclosure(obj) then
		watch(obj)
		break
	end
end
