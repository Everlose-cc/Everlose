--!nocheck

return function()
	local RunService: RunService = wax.shared.Services.RunService

	local LocalPlayer: Player = wax.shared.LocalPlayer

	-- local TableUtils = wax.shared.TableUtils

	local Library: Library = wax.shared.Library
	local Janitor: Janitor = wax.shared.Janitor

	local Toggles = Library.Toggles

	local ISTAMToggle = Toggles["ISTAM"]

	wax.shared.CharacterStuff = {}

	local function UpdateLocalCharacter(Character: Model)
		local gc = filtergc("function", {
			Name = "regenerate",
			IgnoreExecutor = true,
		}, false)

		for _, fn in gc do
			local source = debug.info(fn, "s")
			if source:find(".SprintFrame.Stamina") then
				wax.shared.CharacterStuff.regeneratefn = fn
				-- debug.setupvalue(fn, 4, 100)
			end
		end

		wax.shared.CharacterStuff.Loaded = true
	end
	local function LocalCharacterRemoving(Character: Model)
		wax.shared.CharacterStuff.Loaded = false
	end

	if LocalPlayer.Character then
		UpdateLocalCharacter(LocalPlayer.Character)
	end

	local LocalCharConn = LocalPlayer.CharacterAdded:Connect(UpdateLocalCharacter)
	local LocalCharRConn = LocalPlayer.CharacterRemoving:Connect(LocalCharacterRemoving)
	Janitor:Add(LocalCharConn)
	Janitor:Add(LocalCharRConn)

	RunService:BindToRenderStep("ISTAM", Enum.RenderPriority.Input.Value, function(dt: number)
        if not wax.shared.CharacterStuff.Loaded then
            return
        end

        if ISTAMToggle.Value then
            debug.setupvalue(wax.shared.CharacterStuff.regeneratefn, 4, 100)
        end
    end)
	Janitor:Add(function()
		RunService:UnbindFromRenderStep("ISTAM")
	end)
end
