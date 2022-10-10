local Command = {}
Command.Name = "rope"
Command.Description = "Puts a rope on the specified user(s)."
Command.Aliases = {"grabwithrope"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't rope no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			if target == plr then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't rope yourself."})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
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
					env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s already has a rope attached to them.", target.Name)})
					env.RemoteEvent:FireClient(plr, "playSound", "Error")
					continue
				end
			end
			for _, item in Character:GetChildren() do
				if item:IsA("BasePart") then
					item:SetNetworkOwner(plr)
				end
			end
			Character.HumanoidRootPart.Position = plr.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.CFrame.LookVector * 14
			Character.Humanoid.PlatformStand = true
			local Rope = Instance.new("RopeConstraint")
			local Attachment0 = Instance.new("Attachment", plr.Character.HumanoidRootPart)
			local Attachment1 = Instance.new("Attachment", Character.HumanoidRootPart)
			Attachment0.Name = "RudimentaryRopeAttachment"
			Attachment1.Name = "RudimentaryRopeAttachment"
			Rope.Name = "RudimentaryRope"
			Rope.Parent = env.RWA
			Rope.Attachment0 = Attachment0
			Rope.Attachment1 = Attachment1
			Rope.Length = 15
			Rope.Visible = true
		end
	end
end

return Command
