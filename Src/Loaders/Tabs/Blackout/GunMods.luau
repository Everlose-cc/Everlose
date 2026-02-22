--!nocheck

return function()
	local Tabs: { [number | string]: Tab } = wax.shared.Tabs
	local Tab = Tabs["GunMods"]

	local Library: Library = wax.shared.Library
	local Toggles = Library.Toggles
	local Options = Library.Options

	wax.shared.UpdateGunMods = function()
		local Value = Toggles.GunModsToggle.Value
		if not Value then
			local DefaultGunSettings, GunSettings = wax.shared["DefaultSettings"], wax.shared["GunSettings"]
			if DefaultGunSettings == nil and GunSettings == nil then
				return
			end
			local DefaultFiring, Firing = DefaultGunSettings["Firing"], GunSettings["Firing"]

			if Toggles.CustomRecoil.Value then
				Firing["Recoil"] = DefaultFiring["Recoil"]
			end

			if Toggles.CustomSpread.Value then
				Firing["Spread"] = DefaultFiring["Spread"]
			end
		else
			local DefaultGunSettings, GunSettings = wax.shared["DefaultSettings"], wax.shared["GunSettings"]
			if DefaultGunSettings == nil and GunSettings == nil then
				return
			end
			local DefaultFiring, Firing = DefaultGunSettings["Firing"], GunSettings["Firing"]

			if Toggles.CustomRecoil.Value then
				Firing["Recoil"] = NumberRange.new(
					DefaultFiring["Recoil"].Min * Options.RecoilMulti.Value,
					DefaultFiring["Recoil"].Max * Value
				)
			end

			if Toggles.CustomSpread.Value then
				Firing["Spread"] = DefaultFiring["Spread"] * Options.SpreadMulti
			end
		end
	end

	local TogglesGroupbox = Tab:AddLeftGroupbox("Toggles")
	TogglesGroupbox:AddToggle("GunModsToggle", {
		Text = "Enable Gun Mods",
		Default = false,
		Callback = wax.shared.UpdateGunMods,
	})

	TogglesGroupbox:AddDivider()

	TogglesGroupbox:AddToggle("CustomRecoil", {
		Text = "Recoil",
		Default = false,
		Callback = wax.shared.UpdateGunMods,
	})

	TogglesGroupbox:AddSlider("RecoilMulti", {
		Text = "Recoil Multi",
		Default = 1,
		Min = 0,
		Max = 1,
		Rounding = 0.1,
		Compact = true,
		Callback = wax.shared.UpdateGunMods,
	})

	TogglesGroupbox:AddToggle("CustomSpread", {
		Text = "Custom Spread",
		Default = false,
		Callback = wax.shared.UpdateGunMods,
	})

	TogglesGroupbox:AddSlider("SpreadMulti", {
		Text = "Spread Multi",
		Default = 1,
		Min = 0,
		Max = 1,
		Rounding = 0.1,
		Compact = true,
		Callback = wax.shared.UpdateGunMods,
	})

	TogglesGroupbox:AddDivider()
end
