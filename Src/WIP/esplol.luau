--!nocheck

local Players = cloneref(game:GetService("Players"))

local ESPLibrary =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()

local LocalPlayer = Players.LocalPlayer

local function OnCharAdded(plr: Player?, char: Model)
	local Color = plr and plr.TeamColor.Color or BrickColor.Random().Color
	local Settings: ESPSettings = {
		Name = "...",
		Model = char,
		TextModel = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"),

		Color = Color,
		MaxDistance = 10000,

		TextSize = 17,

		ESPType = "Highlight",

		FillColor = Color,
		OutlineColor = Color,
		FillTransparency = 0.5,
		OutlineTransparency = 0,

		Arrow = {
			Enabled = true,
			Color = Color,
		},

		BeforeUpdate = function(esp: ESPInstance)
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local hp, maxhp =
					humanoid:GetAttribute("Health") or humanoid.Health,
					humanoid:GetAttribute("MaxHealth") or humanoid.MaxHealth

				local health = string.format("%.2f", hp)
				local maxHealth = string.format("%.2f", maxhp)

				local name = plr and plr.Name or "NPC"
				esp.CurrentSettings.Name = `{name} <br/>{health}/{maxHealth}`
			end
		end,
	}
	local Esp: ESPInstance = ESPLibrary:Add(Settings)
	return Esp
end

local function HandlePlayer(Plr: Player)
	if Plr ~= LocalPlayer then
		if Plr.Character then
			OnCharAdded(Plr, Plr.Character)
		end
		Plr.CharacterAdded:Connect(function(a0: Model)
			HandlePlayer(Plr, a0)
		end)
	end
end

for _, plr in Players:GetPlayers() do
	HandlePlayer(plr)
end
Players.PlayerAdded:Connect(HandlePlayer)
