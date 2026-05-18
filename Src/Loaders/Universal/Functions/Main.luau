return function()
	local VirtualUser: VirtualUser = wax.shared.Services.VirtualUser
	local ProximityPromptService: ProximityPromptService = wax.shared.Services.ProximityPromptService

	local Library: Library = wax.shared.Library

	local Toggles = Library.Toggles
	local Options = Library.Options

	local Janitor: Janitor = wax.shared.Janitor

	local LocalPlayer: Player = wax.shared.LocalPlayer

	local PromptButtonHoldBeganConnection
	PromptButtonHoldBeganConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(
		function(Prompt: ProximityPrompt, PlayerWhoTriggered: Player)
			if PlayerWhoTriggered == LocalPlayer and Toggles.InstantPP.Value then
				fireproximityprompt(Prompt)
			end
		end
	)

	local IdledConnection
	IdledConnection = LocalPlayer.Idled:Connect(function(a0: number)
		if Toggles.AntiAfk.Value then
			VirtualUser:CaptureController()
			task.wait()
			VirtualUser:ClickButton2(Vector2.zero)
		end
	end)

	Janitor:Add(PromptButtonHoldBeganConnection)
	Janitor:Add(IdledConnection)

	local OldNewIndex
	OldNewIndex = wax.shared.Hooking.HookMetaMethod(
		game,
		"__newindex",
		function(self: Instance, key: string, value: any)
			local Caller = checkcaller()

			if not Caller then
				if self == wax.shared.Humanoid then
					if key == "WalkSpeed" and Toggles.SpeedSlider.Value then
						local IsWalkSpeedDown: boolean = (Options.SpeedKeybind:GetState() and Toggles.SpeedToggle.Value)
							or false

						wax.shared.DefaultValues.Humanoid["WalkSpeed"] = value
						if IsWalkSpeedDown then
							value = Options.SpeedSlider.Value
						end
					end
				end
			end

			return OldNewIndex(self, key, value)
		end
	)
end
