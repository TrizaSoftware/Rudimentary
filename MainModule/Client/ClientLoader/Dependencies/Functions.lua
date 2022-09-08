local Player = game.Players.LocalPlayer

return {
	MakeWindow = function(Client, ...)
		Client.UI.Make("Window", ...)
	end,
	MakeDonorPanel = function(Client)
		local Window = Client.UI.Make("Window", "Donor Panel", nil, UDim2.new(0.177, 0,0.302, 0))
		Window.WindowInstance.Position = UDim2.new(0.411, 0,0.367, 0)
		Window:addItem("UIAspectRatioConstraint", {
			AspectRatio = 1.005,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width,
			Parent = Window.WindowInstance
		})
		local ScrollingFrameTemplate = Window:addItem("ScrollingFrame", {
			Size = UDim2.new(1,0,0.88,0),
			Position = UDim2.new(0,0,0.12,0),
			ScrollBarThickness = 4,
			TopImage = "rbxassetid://132155326",
			MidImage = "rbxassetid://132155326",
			BottomImage = "rbxassetid://132155326",
			ScrollBarImageColor3 = Color3.fromRGB(255,255,255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0
		})
		task.spawn(function()
			task.wait(0.5)
			local MainScrollingFrame = ScrollingFrameTemplate:Clone()
			MainScrollingFrame.Parent = Window.WindowInstance
			local UIListLayout = Window:addItem("UIListLayout", {
				HorizontalAlignment = "Center",
				Padding = UDim.new(0,5)
			})
			UIListLayout:Clone().Parent = MainScrollingFrame
			local PanelTemplate = Window:addItem("Frame", {
				Size = UDim2.new(0.95,0,0,155),
				BackgroundColor3 = Window.WindowInstance.Topbar.BackgroundColor3,
				BackgroundTransparency = 0.4,
			})
			local CapePanel = PanelTemplate:Clone()
			CapePanel.Name = "CapePanel"
			CapePanel.Parent = MainScrollingFrame
			local UICorner = Window:addItem("UICorner", {
				CornerRadius = UDim.new(0,8),
			})
			UICorner:Clone().Parent = CapePanel
			local CapeTextLabel = Window:addItem("TextLabel", {
				Text = "Cape",
				Font = Enum.Font.GothamBold,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextScaled = true,
				Size = UDim2.new(0.9,0,0.2,0),
				Position = UDim2.new(0.05,0,0,0),
				TextXAlignment = "Left",
				Parent = CapePanel,
				BackgroundTransparency = 1
			})
			local TextSizeConstraint = Window:addItem("UITextSizeConstraint", {
				MaxTextSize = 15,
			})
			TextSizeConstraint:Clone().Parent = CapeTextLabel
			local TextLabelTemplate = Window:addItem("TextLabel", {
				Font = Enum.Font.Gotham,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextScaled = true,
				Size = UDim2.new(0.9,0,0.2,0),
				Position = UDim2.new(0.05,0,0,0),
				BackgroundColor3 = Window.WindowInstance.Topbar.BackgroundColor3,
			})
			local TextButtonTemplate = Window:addItem("TextButton", {
				Font = Enum.Font.Gotham,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextScaled = true,
				Size = UDim2.new(0.9,0,0.2,0),
				Position = UDim2.new(0.05,0,0,0),
				BackgroundColor3 = Window.WindowInstance.Topbar.BackgroundColor3,
			})
			local TextBoxTemplate = Window:addItem("TextBox", {
				Font = Enum.Font.Gotham,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextScaled = true,
				Size = UDim2.new(0.9,0,0.2,0),
				Position = UDim2.new(0.05,0,0,0),
				BackgroundColor3 = Window.WindowInstance.Topbar.BackgroundColor3,
			})
			
			-- Handle Color Data
			
			local CapeColorTextLabel = TextLabelTemplate:Clone()
			local CapeColorTextButton = TextButtonTemplate:Clone()
			CapeColorTextLabel.Position = UDim2.new(0,0,0.18,0)
			CapeColorTextLabel.Size = UDim2.new(0.55,0,0.14,0)
			CapeColorTextLabel.Text = "Color"
			CapeColorTextLabel.Parent = CapePanel
			CapeColorTextButton.Position = UDim2.new(0.6,0,0.18,0)
			CapeColorTextButton.Size = UDim2.new(0.4,0,0.14,0)
			CapeColorTextButton.Text = "Choose"
			CapeColorTextButton.Parent = CapePanel
			UICorner:Clone().Parent = CapeColorTextLabel
			TextSizeConstraint:Clone().Parent = CapeColorTextLabel
			UICorner:Clone().Parent = CapeColorTextButton
			TextSizeConstraint:Clone().Parent = CapeColorTextButton
			
			local ColorScrollingFrame = ScrollingFrameTemplate:Clone()
			ColorScrollingFrame.Parent = Window.WindowInstance
			ColorScrollingFrame.Visible = false
			UIListLayout:Clone().Parent = ColorScrollingFrame
			
			local SelectedColor = nil
			
			task.spawn(function()
				pcall(function()
					local UsedColorNames = {}
					for i = 1,1032 do
						local BC = BrickColor.new(i)
						if not table.find(UsedColorNames, BC.Name) then
							table.insert(UsedColorNames, BC.Name)
							local Clone = TextButtonTemplate:Clone()
							Clone.Text = BC.Name
							Clone.Size = UDim2.new(0.9,0,0,25)
							Clone.TextXAlignment = "Right"
							local ColorDisplayFrame = Window:addItem("Frame", {
								Size = UDim2.new(0.15, 0, 0.8, 0),
								Position = UDim2.new(0.02,0,0.1,0),
								Parent = Clone,
								BorderSizePixel = 0,
								BackgroundColor3 = BC.Color
							})
							Clone.MouseButton1Click:Connect(function()
								CapeColorTextLabel.Text = BC.Name
								SelectedColor = BC
								MainScrollingFrame.Visible = true
								ColorScrollingFrame.Visible = false
							end)
							UICorner:Clone().Parent = ColorDisplayFrame
							UICorner:Clone().Parent = Clone
							TextSizeConstraint:Clone().Parent = Clone
							Clone.Parent = ColorScrollingFrame
							ColorScrollingFrame.CanvasSize = UDim2.new(0,0,0,ColorScrollingFrame.UIListLayout.AbsoluteContentSize.Y+10)
							task.wait(0.01)
						end
					end
				end)
			end)
			
			
			CapeColorTextButton.MouseButton1Click:Connect(function()
				MainScrollingFrame.Visible = false
				ColorScrollingFrame.Visible = true
			end)
			
			-- Handle Texture Data
			
			local CapeTextureTextLabel = TextLabelTemplate:Clone()
			local CapeTextureTextButton = TextButtonTemplate:Clone()
			CapeTextureTextLabel.Position = UDim2.new(0,0,0.41,0)
			CapeTextureTextLabel.Size = UDim2.new(0.55,0,0.14,0)
			CapeTextureTextLabel.Text = "Texture"
			CapeTextureTextLabel.Parent = CapePanel
			CapeTextureTextButton.Position = UDim2.new(0.6,0,0.41,0)
			CapeTextureTextButton.Size = UDim2.new(0.4,0,0.14,0)
			CapeTextureTextButton.Text = "Choose"
			CapeTextureTextButton.Parent = CapePanel
			UICorner:Clone().Parent = CapeTextureTextLabel
			TextSizeConstraint:Clone().Parent = CapeTextureTextLabel
			UICorner:Clone().Parent = CapeTextureTextButton
			TextSizeConstraint:Clone().Parent = CapeTextureTextButton

			local TextureScrollingFrame = ScrollingFrameTemplate:Clone()
			TextureScrollingFrame.Parent = Window.WindowInstance
			TextureScrollingFrame.Visible = false
			UIListLayout:Clone().Parent = TextureScrollingFrame

			local SelectedTexture = nil
			
			local Textures = {
				"SmoothPlastic",
				"Plastic",
				"Neon",
				"Glass",
				"ForceField",
				"Wood",
				"WoodPlanks",
				"Concrete",
				"Granite",
				"Brick",
				"Foil",
				"Metal",
				"Grass",
				"Fabric",
				"Ice"
			}
			
			for _, texture in Textures do
				local Clone = TextButtonTemplate:Clone()
				Clone.Text = texture
				Clone.Size = UDim2.new(0.9,0,0,25)
				Clone.TextXAlignment = "Center"
				Clone.MouseButton1Click:Connect(function()
					CapeTextureTextLabel.Text = texture
					SelectedTexture = texture
					MainScrollingFrame.Visible = true
					TextureScrollingFrame.Visible = false
				end)
				UICorner:Clone().Parent = Clone
				TextSizeConstraint:Clone().Parent = Clone
				Clone.Parent = TextureScrollingFrame
				TextureScrollingFrame.CanvasSize = UDim2.new(0,0,0,TextureScrollingFrame.UIListLayout.AbsoluteContentSize.Y+10)
			end


			CapeTextureTextButton.MouseButton1Click:Connect(function()
				MainScrollingFrame.Visible = false
				TextureScrollingFrame.Visible = true
			end)
			
			local DecalInput = TextBoxTemplate:Clone()
			DecalInput.PlaceholderColor3 = Color3.fromRGB(255,255,255)
			DecalInput.PlaceholderText = "Input Decal Id"
			DecalInput.Text = ""
			DecalInput.Position = UDim2.new(0,0,0.64,0)
			DecalInput.Size = UDim2.new(1,0,0.14,0)
			DecalInput.Parent = CapePanel
			UICorner:Clone().Parent = DecalInput
			TextSizeConstraint:Clone().Parent = DecalInput
			
			local CapeConfirmButton = TextButtonTemplate:Clone()
			local CapeRemoveButton = TextButtonTemplate:Clone()
			CapeConfirmButton.Position = UDim2.new(0,0,0.86,0)
			CapeConfirmButton.Size = UDim2.new(0.55,0,0.14,0)
			CapeConfirmButton.Text = "Confirm"
			CapeConfirmButton.Parent = CapePanel
			CapeRemoveButton.Position = UDim2.new(0.6,0,0.86,0)
			CapeRemoveButton.Size = UDim2.new(0.4,0,0.14,0)
			CapeRemoveButton.Text = "Remove"
			CapeRemoveButton.Parent = CapePanel
			UICorner:Clone().Parent = CapeConfirmButton
			TextSizeConstraint:Clone().Parent = CapeConfirmButton
			UICorner:Clone().Parent = CapeRemoveButton
			TextSizeConstraint:Clone().Parent = CapeRemoveButton
			
			CapeConfirmButton.MouseButton1Click:Connect(function()
				Client.RemoteFunction:InvokeServer("giveCape", SelectedColor, SelectedTexture, DecalInput.Text)
			end)
			
			CapeRemoveButton.MouseButton1Click:Connect(function()
				Client.RemoteFunction:InvokeServer("removeCape")
			end)
		end)
	end,
	MakeCountdown = function(Client, Time)
		-- 2.207
		local Window = Client.UI.Make("Window", "Countdown")
		Window.WindowInstance.Position = UDim2.new(0.02, 0,0.73, 0)
		Window:addItem("UIAspectRatioConstraint", {
			AspectRatio = 2.207,
			AspectType = Enum.AspectType.FitWithinMaxSize,
			DominantAxis = Enum.DominantAxis.Width,
			Parent = Window.WindowInstance
		})
		task.spawn(function()
			task.wait(0.5)
			local TextLabel = Window:addItem("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextScaled = true,
				Parent = Window.WindowInstance,
				Position = UDim2.new(0,0,0.3,0),
				Size = UDim2.new(1,0,0.5,0),
				TextColor3 = Color3.fromRGB(255,255,255)
			})
			task.spawn(function()
				for i = Time,0,-1 do
					if not Window.WindowInstance.Parent then
						break
					end
					TextLabel.Text = i
					if i == 0 then
						script.Parent.Parent.Sounds.ClockAlarm:Play()
						task.spawn(function()
							task.wait(3)
							if Window.WindowInstance.Parent then
								script.Parent.Parent.Sounds.ClockAlarm:Stop()
								Window.WindowInstance.FaderInstance:FadeOut(1)
								task.wait(1)
								Window.ScreenGui:Destroy()
							end
						end)
						break
					else
						script.Parent.Parent.Sounds.ClockTick:Play()
						task.spawn(function()
							task.wait(0.5)
							script.Parent.Parent.Sounds.ClockTick:Stop()
							script.Parent.Parent.Sounds.ClockTick.TimePosition = 0
						end)
					end
					task.wait(1)
				end
			end)
			Window.WindowInstance.Topbar.close.MouseButton1Click:Connect(function()
				script.Parent.Parent.Sounds.ClockAlarm:Stop()
			end)
		end)
	end,
	ViewUser = function(Client, plr)
		workspace.CurrentCamera.CameraSubject = plr.Character
	end,
	CanChat = function(Client, CanChat)
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, CanChat)
	end,
	TrackUser = function(Client, plr:Instance)
		if plr.Character:FindFirstChild("RudimentaryTrackHighlight") then return end
		local Color = if plr.Team then plr.Team.TeamColor.Color else Color3.fromRGB(255,255,255)
		if not plr.Character and plr.Parent then
			workspace:WaitForChild(plr.Name)
			workspace[plr.Name]:WaitForChild("HumanoidRootPart")
		end
		local TrackOverhead = Client.Shared.TrackUi:Clone()
		TrackOverhead.Holder.NameText.Text = plr.Name
		TrackOverhead.Parent = plr.Character
		TrackOverhead.Adornee = plr.Character.Head
		TrackOverhead.Name = "RudimentaryTrackUi"
		local Attach0 = Instance.new("Attachment")
		Attach0.Parent = Player.Character.HumanoidRootPart
		Attach0.Name = "RudimentaryTrackAttach"
		Attach0:SetAttribute("ConnectedUser", plr.UserId)
		local Attach1 = Instance.new("Attachment")
		Attach1.Parent = plr.Character.HumanoidRootPart
		Attach1.Name = "RudimentaryTrackAttach"
		local Beam = Instance.new("Beam")
		Beam.Name = "RudimentaryTrackBeam"
		Beam.Width0 = 0.3
		Beam.Width1 = 0.3
		Beam.Attachment0 = Attach0
		Beam.Attachment1 = Attach1
		Beam.Color = ColorSequence.new(plr.Team.TeamColor.Color)
		Beam.Parent = plr.Character
		local Highlight = Instance.new("Highlight")
		Highlight.Name = "RudimentaryTrackHighlight"
		Highlight.FillTransparency = 0.7
		Highlight.OutlineTransparency = 0
		Highlight.FillColor = Color
		Highlight.OutlineColor = Color
		Highlight.Parent = plr.Character
		local UpdateColor = plr:GetPropertyChangedSignal("Team"):Connect(function()
			Beam.Color = ColorSequence.new(plr.Team.TeamColor.Color)
			Highlight.FillColor = plr.Team.TeamColor.Color
			Highlight.OutlineColor = plr.Team.TeamColor.Color
		end)
		local ClientCharAddedConnection = Player.CharacterAdded:Connect(function(char)
			char:WaitForChild("HumanoidRootPart")
			Attach0.Parent = char.HumanoidRootPart
		end)
		local TargetCharAddedConnection = plr.CharacterAdded:Connect(function(char)
			char:WaitForChild("HumanoidRootPart")
			TrackOverhead.Parent = char
			TrackOverhead.Adornee = char.Head
			Attach1.Parent = char.HumanoidRootPart
			Beam.Parent = char
			Highlight.Parent = char
		end)
		local ClientDeathConnection = Player.Character.Humanoid.Died:Connect(function()
			if Attach0:IsDescendantOf(workspace) then
				Attach0.Parent = nil
			end
		end)
		local TrackedUserDeathConnection = nil
		TrackedUserDeathConnection = plr.Character.Humanoid.Died:Connect(function()
			if not Highlight:IsDescendantOf(workspace) then
				UpdateColor:Disconnect()
				TrackedUserDeathConnection:Disconnect()
				ClientCharAddedConnection:Disconnect()
				TargetCharAddedConnection:Disconnect()
				ClientDeathConnection:Disconnect()
				return
			end
			TrackOverhead.Parent = nil
			Attach1.Parent = nil
			Beam.Parent = nil
			Highlight.Parent = nil
		end)
		local PlayerLeaveConn 
		PlayerLeaveConn = game.Players.ChildRemoved:Connect(function(leavingplayer)
			if plr == leavingplayer then
				UpdateColor:Disconnect()
				TrackedUserDeathConnection:Disconnect()
				ClientCharAddedConnection:Disconnect()
				TargetCharAddedConnection:Disconnect()
				ClientDeathConnection:Disconnect()
				PlayerLeaveConn:Disconnect()
				if Highlight:IsDescendantOf(workspace) then
					Highlight:Destroy()
					TrackOverhead:Destroy()
					Attach0:Destroy()
					Attach1:Destroy()
					Beam:Destroy()
				end
			end
		end)
	end,
	StopTracking = function(Client, plr)
		if not plr.Character:FindFirstChild("RudimentaryTrackHighlight") then return end
		for _, item in Player.Character.HumanoidRootPart:GetChildren() do
			if item.Name == "RudimentaryTrackAttach" and item:GetAttribute("ConnectedUser") == plr.UserId then
				item:Destroy()
			end
		end
		plr.Character.RudimentaryTrackUi:Destroy()
		plr.Character.RudimentaryTrackBeam:Destroy()
		plr.Character.RudimentaryTrackHighlight:Destroy()
		plr.Character.HumanoidRootPart.RudimentaryTrackAttach:Destroy()
	end,
}