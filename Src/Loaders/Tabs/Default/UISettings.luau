--!nocheck

return function()
	local Library: Library = wax.shared.Library
    local EspLibrary: EspLibrary = wax.shared.EspLibrary
    local FlyModule = wax.shared.FlyModule

	local Tab: Tab = wax.shared.Tabs["UISettings"]
	local MenuGroup = Tab:AddLeftGroupbox("Menu", "wrench")

	getgenv().UnloadEverlose = function()
		local StartTime = tick()

		for _, Connection: RBXScriptConnection in wax.shared.Connections do
			Connection:Disconnect()
		end
		table.clear(wax.shared.Connections)

		for _, Signal in wax.shared.Signals do
			Signal:DisconnectAll()
		end
		table.clear(wax.shared.Signals)

		for _, Thread: thread in wax.shared.Threads do
			task.cancel(Thread)
		end
		table.clear(wax.shared.Threads)

		EspLibrary:Destroy()
		Library:Unload()
		FlyModule:Cleanup()

		getgenv().UnloadEverlose = nil

		print("Everlose Unloaded, took: " .. (tick() - StartTime) .. " seconds.")
		print("Everlose ran for: " .. (tick() - wax.shared.EverloseStartTime) .. " seconds.")
	end

	local Options = Library.Options

	MenuGroup:AddToggle("KeybindMenuOpen", {
		Default = false,
		Text = "Open Keybind Menu",
		Callback = function(Value: boolean)
			Library.KeybindFrame.Visible = Value
		end,
	})
	MenuGroup:AddToggle("ShowCustomCursor", {
		Default = true,
		Text = "Custom Cursor",
		Callback = function(Value: boolean)
			Library.ShowCustomCursor.Visible = Value
		end,
	})
	MenuGroup:AddDropdown("NotificationSide", {
		Values = { "Left", "Right" },
		Default = "Right",
		Text = "Notification Side",
		Callback = function(Value: string)
			Library:SetNotifySide(Value)
		end,
	})
	MenuGroup:AddDropdown("DPIDropdown", {
		Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
		Default = "100%",

		Text = "DPI Scale",

		Callback = function(Value: string | number)
			Value = Value:gsub("%%", "")
			local DPI = tonumber(Value)

			Library:SetDPIScale(DPI)
		end,
	})
	MenuGroup:AddDivider()
	local MenuBind = MenuGroup:AddLabel("Menu Bind")
	MenuBind:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
	MenuGroup:AddButton("Unload", getgenv().UnloadEverlose)

	Library.ToggleKeybind = Options.MenuKeybind
end
