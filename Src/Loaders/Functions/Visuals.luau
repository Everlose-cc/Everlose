--!nocheck

return function()
	local ESPLibrary = wax.shared.EspLibrary
	local Library: Library = wax.shared.Library
	local Signals: { [number | string]: RBXScriptSignal } = wax.shared.Signals
	local Services = wax.shared.Services

	local Options = Library.Options

	local Players = Services:GetService("Players")

	Signals["CharacterAdded"]:Connect(function(Character: Model)
		local PlayerFromCharacter = Players:GetPlayerFromCharacter(Character)

		-- local Head = Character:WaitForChild('Head')
		local Humanoid = wax.shared.WaitForChildOfClass(Character, "Humanoid", 5)
		local RootPart = Character:WaitForChild("HumanoidRootPart", 5)

		local Color = (PlayerFromCharacter.Team == nil and Options.PlayerEspColor.Value or PlayerFromCharacter.TeamColor.Color)
		local EspElement = ESPLibrary:Add({
			Name = "",
			Model = Character,
			TextModel = RootPart,
			Visible = false,
			Color = Color,
			MaxDistance = 5000,
			StudsOffset = vector.zero,

			TextSize = Options.TextSize.Value,
			EspType = Options.EspType.Value,

			SelectionBox = {
				SurfaceColor = Color,
			},
			Highlight = {
				FillColor = Color,
				OutlineColor = Color,
				FillTransparency = 0.65,
				OutlineTransparency = 0,
			},
			Tracer = {
				Enabled = true,
				Color = Color,
				Thickness = 2,
				Transparency = 0,
				From = Options.TracerStartPos.Value,
			},
			Arrow = {
				Enabled = true,
				Color = Color,
				CenterOffset = 300,
			},

			Box2D = {
				Enabled = true,
				Color = Color,
				Thickness = 2,
				Transparency = 0,
				Filled = false,
			},
			Box3D = {
				Enabled = true,
				Color = Color,
				Thickness = 2,
				Transparency = 0,
			},

			Skeleton = {
				Enabled = true,
				Color = Color,
				Thickness = 1,
				Transparency = 0,
			},

			AfterUpdate = function(self)
				if Humanoid then
					local Name = (
						Humanoid.DisplayName ~= "" and Humanoid.DisplayName ~= " " and Humanoid.DisplayName
						or Character.Name
					)
					self.CurrentSettings.Name =
						`{Name}: {math.round(Humanoid.Health)}/{math.round(Humanoid.MaxHealth)} Health`
				end
			end,
		})
		EspElement:SetEveryColor(Color, true)
		EspElement.CurrentSettings.Tracer.Enabled = ESPLibrary.GlobalConfig.Tracers
		EspElement.CurrentSettings.Arrow.Enabled = ESPLibrary.GlobalConfig.Arrows
		EspElement.CurrentSettings.Box2D.Enabled = ESPLibrary.GlobalConfig.Boxes2D
		EspElement.CurrentSettings.Box3D.Enabled = ESPLibrary.GlobalConfig.Boxes3D
		EspElement.CurrentSettings.Skeleton.Enabled = ESPLibrary.GlobalConfig.Skeleton
		if Library.Toggles.PlayerEsp.Value and PlayerFromCharacter then
			EspElement:Show()
		end
		table.insert(wax.shared.ESPCache.Players, EspElement)
	end)
end
