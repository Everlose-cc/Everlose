--!nocheck

return function()
	local Services = wax.shared.Services

	local ReplicatedStorage: ReplicatedStorage = Services:GetService("ReplicatedStorage")
	local GunStorage: Folder = ReplicatedStorage:WaitForChild("GunStorage")
	local Equip_RF: RemoteFunction = GunStorage:WaitForChild("Events"):WaitForChild("Equip")

	local RawMetatable = getrawmetatable(game)
	local OldNamecall = nil
	local function NameCallSpoof(self: Instance, ...)
		local Caller = checkcaller()
		local Method = getnamecallmethod()

		if not Caller then
			if self == Equip_RF and Method == "InvokeServer" then
				local ServerGunModel: Model, Settings, AmmoData = OldNamecall(self, ...)
				-- Settings["Firing"]["Recoil"] = NumberRange.new(0, 0)
				-- Settings["Firing"]["Spread"] = 0

				local DefaultSettings = table.clone(Settings)
				wax.shared.DefaultGunSettings = DefaultSettings
				wax.shared.GunSettings = Settings
				wax.shared.UpdateGunMods()

				return ServerGunModel, Settings, AmmoData
			end
		end

		return OldNamecall(self, ...)
	end

	if wax.shared.HasOth then
		OldNamecall = oth.hook(RawMetatable.__namecall, NameCallSpoof)
	else
		OldNamecall = hookmetamethod(game, "__namecall", newcclosure(NameCallSpoof))
	end
end
