--!nocheck
return function()
	local RunService: RunService = wax.shared.Services.RunService

	local Library: Library = wax.shared.Library
	local Janitor: Janitor = wax.shared.Janitor
	local SafeCall = wax.shared.SafeCall
	
	local Toggles = Library.Toggles

	local Stepped = RunService.Stepped:Connect(function(t: number, d: number)
		for Name, Settings in Toggles do
			if Settings.Value then
				SafeCall(wax.shared.Features[Name], t, d)
			end
		end
	end)
	Janitor:Add(Stepped)
end
