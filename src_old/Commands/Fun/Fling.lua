local Command = {}
Command.Name = "fling"
Command.Description = "Flings the specified user(s)."
Command.Aliases = {"flg"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	local Targets = args[1]
	if not Targets then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't fling no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in Targets do
		if typeof(target) == "Instance" then
			task.spawn(function()
				local Attach = Instance.new("Attachment", target.Character.HumanoidRootPart)
				Attach.Name = "RudimentaryAttachment"
				local LinVel = Instance.new("LinearVelocity")
				LinVel.MaxForce = math.huge
				LinVel.VectorVelocity = CFrame.new(target.Character.HumanoidRootPart.Position,  target.Character.HumanoidRootPart.Position + target.Character.HumanoidRootPart.CFrame.LookVector * 5).LookVector *1500 + Vector3.new(0,50,0)
				LinVel.Attachment0 = Attach
				LinVel.Parent = target.Character.HumanoidRootPart
				task.wait(2.5)
				LinVel:Destroy()
			end)
		end
	end
end

return Command
