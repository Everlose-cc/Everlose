--!nocheck

return function()
	local ESPLibrary = wax.shared.EspLibrary
	local Library: Library = wax.shared.Library
	local Window: Window = wax.shared.Window
	local Signals: { [number | string]: RBXScriptSignal } = wax.shared.Signals
	local Services = wax.shared.Services

	local LocalPlayer = wax.shared.LocalPlayer

	local Buttons = Library.Buttons
	local Options = Library.Options

	local Players = Services:GetService("Players")

	Signals["CharacterAdded"]:Connect(function(Character: Model)
		local PlayerFromCharacter = Players:GetPlayerFromCharacter(Character)

		-- local Head = Character:WaitForChild('Head')
		local Humanoid = wax.shared.WaitForChildOfClass(Character, "Humanoid", 5)
		local RootPart = Character:WaitForChild("HumanoidRootPart", 5)

		local Color = (
			PlayerFromCharacter.Team == nil and Options.PlayerEspColor.Value or PlayerFromCharacter.TeamColor.Color
		)
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

	wax.shared.RunningCustomAvatarScript = true
	local UserId = nil
	local DisguiserButton = Buttons["Disguiser"]
	DisguiserButton["Func"] = function()
		local Dialog: Dialog = Window:AddDialog("DisguiseDialog", {
			Title = "Disguise Prompt",
			Description = "This is the confirmation prompt for Disguising as someone",
			AutoDismiss = true,
			OutsideClickDismiss = true,
			FooterButtons = {
				Cancel = {
					Title = "Cancel",
					Variant = "Ghost",
					Order = 1,
				},
				Confirm = {
					Title = "Confirm",
					Variant = "Primary",
					WaitTime = 10,
					Order = 2,
					Callback = function(self)
						local function WeldAccessory(Char: Model, accessory)
							local Handle = accessory:FindFirstChild("Handle")
							if not Handle then
								return
							end

							local attachment = Handle:FindFirstChildOfClass("Attachment")
							if attachment then
								local Attachment = Char:FindFirstChild(attachment.Name, true)
								if Attachment then
									Handle.CFrame = Attachment.WorldCFrame * attachment.CFrame:Inverse()

									local weld = Instance.new("Weld")
									weld.Name = "AccessoryWeld"
									weld.Part0 = Handle
									weld.Part1 = Attachment.Parent
									weld.C0 = attachment.CFrame
									weld.C1 = Attachment.CFrame
									weld.Parent = Handle
								end
							end
							accessory.Parent = Char
						end

						local function DoChar(Character: Model)
							if UserId == LocalPlayer.UserId then
								return
							end
							local Humanoid = Character:WaitForChild("Humanoid")
							if Humanoid:GetAttribute("LoadedChar1337") then
								return
							end
							Humanoid:SetAttribute("LoadedChar1337", true)
							task.wait(2)

							local Succ, HumanoidDescription = pcall(function()
								return Players:GetHumanoidDescriptionFromUserId(UserId)
							end)

							if Succ then
								local RigType = Humanoid.RigType
								local Dummy = Players:CreateHumanoidModelFromDescription(HumanoidDescription, RigType)

								for _, item in Character:GetChildren() do
									if
										item:IsA("Accessory")
										or item:IsA("Clothing")
										or item:IsA("ShirtGraphic")
										or item:IsA("BodyColors")
										or item:IsA("CharacterMesh")
									then
										item:Destroy()
									end
								end

								for _, item in Dummy:GetChildren() do
									if
										item:IsA("BodyColors")
										or item:IsA("Clothing")
										or item:IsA("ShirtGraphic")
										or item:IsA("CharacterMesh")
									then
										item:Clone().Parent = Character
									elseif item:IsA("Accessory") then
										WeldAccessory(Character, item:Clone())
									end
								end

								if RigType == Enum.HumanoidRigType.R15 then
									for _, part in Dummy:GetChildren() do
										local myPart = Character:FindFirstChild(part.Name)
										if myPart and part:IsA("MeshPart") and myPart:IsA("MeshPart") then
											myPart.MeshId = part.MeshId
											myPart.TextureID = part.TextureID
										end
									end
								end

								local Head = Character:FindFirstChild("Head")
								local DummyHead = Dummy:FindFirstChild("Head")
								if Head and DummyHead then
									if Head:FindFirstChild("face") then
										Head.face:Destroy()
									end
									local face = DummyHead:FindFirstChild("face")
									if face then
										face:Clone().Parent = Head
									end

									if Head:IsA("MeshPart") and DummyHead:IsA("MeshPart") then
										Head.MeshId = DummyHead.MeshId
									end
									Head.Color = DummyHead.Color
								end
								Character:SetAttribute("Loaded_CustomAvatar", true)
								Dummy:Destroy()
							else
							end
						end

						if LocalPlayer.Character then
							DoChar(LocalPlayer.Character)
						end
					end,
				},
			},
		})
		Dialog:AddInput("InputTest", {
			Text = "Type UserId here:",
			Callback = function(Value: string | number)
				UserId = tonumber(Value)
			end,
		})
	end
end
