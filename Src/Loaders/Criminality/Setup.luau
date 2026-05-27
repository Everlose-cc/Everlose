local function Load(a: string, Module: string)
	wax.shared.Load(a, "Tabs", Module)
	wax.shared.Load(a, "Functions", Module)
end

return function()
	local LocalPath = "Loaders/Criminality"
	local ReplicatedStorage: ReplicatedStorage = wax.shared.Services.ReplicatedStorage
	local ClientUtils = wax.shared.ClientUtils
	local Events = ReplicatedStorage:WaitForChild("Events")
	wax.shared.LocalPath = LocalPath

	wax.shared.Remotes = {
		GunShoot = Events.GNX_S,
		GunReload = Events.GNX_R,
		GunHit = ClientUtils.FindFirstChildOr(Events, "ZFKLF__H", "ZFKLF_H"),
	}

	Load("Criminality", "Exploits")

	local Features = {
		"AutoShoot";
	}
	local sharedFeatures = {}
	for _, Feature in Features do
		sharedFeatures[Feature] = require(("%s/Features/%s"):format(LocalPath, Feature))
	end
	wax.shared.Features = sharedFeatures

	wax.shared.CrimUtils = require(("%s/Utils"):format(LocalPath))

	Load("Universal", "Main")
	Load("Criminality", "Render")
end
