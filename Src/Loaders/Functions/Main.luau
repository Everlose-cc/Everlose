return function()
	local Library: Library = wax.shared.Library
	local Services = wax.shared.Services

	local VirtualUser: VirtualUser = Services:GetService("VirtualUser")
    local ProximityPromptService: ProximityPromptService = Services:GetService("ProximityPromptService")

	local LocalPlayer: Player = wax.shared.LocalPlayer

	local Toggles = Library.Toggles
	local Options = Library.Options

	local ConnectionsModule = wax.shared.ConnectionsHandler
	ConnectionsModule:GiveSignal(LocalPlayer.Idled, function(Time: number)
		if Toggles.AntiAfk.Value then
			VirtualUser:CaptureController()
			task.wait()
			VirtualUser:ClickButton2(Vector2.zero)
		end
	end)
    ConnectionsModule:GiveSignal(ProximityPromptService.PromptButtonHoldBegan, function(Prompt: ProximityPrompt, PlayerWhoTriggered: Player)
        if PlayerWhoTriggered == LocalPlayer and Toggles.InstantPP.Value then
            fireproximityprompt(Prompt)
        end
    end)

	local HookMetaMethod = wax.shared["HookMetaMethod"]
	if HookMetaMethod ~= nil then
        local RawMetatable = getrawmetatable(game)
        local OldNewIndex = nil
		local function NewIndexSpoof(self: Instance, Key: string, Value: any)
			local Caller = checkcaller()
			if not Caller then
				local Humanoid: Humanoid = wax.shared["LocalHumanoid"]
				if Humanoid ~= nil and self == Humanoid and Key == "WalkSpeed" then
					local IsWalkSpeedDown: boolean = (
						Options.WalkSpeedToggleBind:GetState() and Toggles.WalkSpeedToggle.Value
					) or false
					if IsWalkSpeedDown then
						wax.shared.DefaultValues["Humanoid"]["WalkSpeed"] = Value
						return OldNewIndex(self, Key, Options.WalkSpeedSlider.Value)
					end
				end
			end
			return OldNewIndex(self, Key, Value)
		end

		if wax.shared.HasOth then
            OldNewIndex = getgenv().oth.hook(RawMetatable.__newindex, NewIndexSpoof)
		else
			OldNewIndex = HookMetaMethod(game, "__newindex", newcclosure(NewIndexSpoof))
		end
	end
end
