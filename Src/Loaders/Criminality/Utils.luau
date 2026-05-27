local ReplicatedStorage = wax.shared.Services.ReplicatedStorage

local LocalPlayer: Player = wax.shared.LocalPlayer

local CrimUtils = {}

function CrimUtils.GetCurrentGun(): (Tool?, { [any]: any }?)
	local LocalCharacter = LocalPlayer.Character
	if not LocalCharacter or not LocalCharacter:FindFirstChild("Head") then
		return
	end

	local CurrentTool = LocalCharacter:FindFirstChildOfClass("Tool")
	if not CurrentTool then
		return
	end

	local IsGun = false
	for Attr, _ in CurrentTool:GetAttributes() do
		if Attr:lower():find("isgun") then
			IsGun = true
			break
		end
	end

	if not IsGun then
		return
	end

	return CurrentTool, require(CurrentTool.Config)
end

function CrimUtils.Notify(Msg: string, Duration: number, TextColor: Color3, TextStroke: Color3, Type: string)
	ReplicatedStorage.Events2.ClientWarn:Fire({ Msg, Duration, TextColor, TextStroke, Type })
end

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Blacklist
RayParams.IgnoreWater = true
RayParams.CollisionGroup = "Character"

CrimUtils.CharacterParams = RayParams

return CrimUtils
