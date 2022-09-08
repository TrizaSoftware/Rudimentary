local RunService = game:GetService("RunService")
local Command = {}
Command.Name = "jail"
Command.Description = "Jails specified user(s)."
Command.Aliases = {"putinjail"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't jail no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			local IsInJail = false
			for _, item in env.RWA:GetChildren() do
				if item.Name == "Jail" and item:GetAttribute("UserId") == target.UserId then
					IsInJail = true
				end
			end
			if IsInJail then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s is already in jail.", target.Name)})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			local Character = target.Character
			local Jail = env.Assets.Jail:Clone()
			Jail:SetAttribute("UserId", target.UserId)
			Character.HumanoidRootPart.Anchored = true
			Jail.PrimaryPart.Position = Character.HumanoidRootPart.Position + Vector3.new(0,1,0)
			Jail.Parent = env.RWA
			Jail.PrimaryPart.Anchored = true
			local Region = Region3.new(Jail.PrimaryPart.Position, Jail.PrimaryPart.Position)
			task.wait(0.1)
			Character.HumanoidRootPart.Anchored = false
			local function handleChar(char)
				repeat
					local PartsInRegion = workspace:FindPartsInRegion3(Region) 
					local PartsInChar = Character:GetDescendants()
					local Found = false
					for _, part in PartsInRegion do
						if table.find(PartsInChar, part) then
							Found = true
						end
					end
					if not Found then
						char.HumanoidRootPart.CFrame = CFrame.new(Jail.PrimaryPart.Position + Vector3.new(0,1,0))
					end
					RunService.Stepped:Wait()
				until not char.Parent or not Jail.Parent
			end
			handleChar(target.Character)
			local Connection
			Connection = target.CharacterAdded:Connect(function(char)
				char:WaitForChild("Head")
				char:WaitForChild("HumanoidRootPart")
				RunService.Stepped:Wait()
				char.HumanoidRootPart.CFrame = CFrame.new(Jail.PrimaryPart.Position + Vector3.new(0,1,0))
				handleChar(char)
			end)
			local PlayerConnection
			PlayerConnection = game.Players.PlayerRemoving:Connect(function(player)
				if target == player then
					Jail:Destroy()
					Connection:Disconnect()
					PlayerConnection:Disconnect()
				end
			end)
			local OtherConnection
			OtherConnection = env.RWA.ChildRemoved:Connect(function(item)
				if item.Name == "Jail" and Jail:GetAttribute("UserId") == target.UserId then
					Connection:Disconnect()
					OtherConnection:Disconnect()
					PlayerConnection:Disconnect()
				end
			end)
		end
	end
end

return Command
