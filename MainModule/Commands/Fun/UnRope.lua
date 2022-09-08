local Command = {}
Command.Name = "unrope"
Command.Description = "Removes a rope from a roped user(s)."
Command.Aliases = {"removerope"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't unrope no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			local Character = target.Character
			local RRA = Character.HumanoidRootPart:FindFirstChild("RudimentaryRopeAttachment")
			if RRA then
				local Rope = nil
				for _, item in env.RWA:GetChildren() do
					if item:IsA("RopeConstraint") and item.Attachment1 == RRA then
						Rope = item
					end
				end
				if Rope then
					for _, item in Character:GetChildren() do
						if item:IsA("BasePart") then
							item:SetNetworkOwner(target)
						end
					end
					Character.Humanoid.PlatformStand = false
					Rope.Attachment0:Destroy()
					Rope.Attachment1:Destroy()
					Rope:Destroy()
				else
					env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s doesn't have a rope attached to them.", target.Name)})
					return
				end
			end
		end
	end
end

return Command
