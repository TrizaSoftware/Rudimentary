local Command = {}
Command.Name = "brazil"
Command.Description = "Sends the specified user(s) to Brazil."
Command.Aliases = {"bzl"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	local Targets = args[1]
	if not Targets then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't brazil no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in Targets do
		if typeof(target) == "Instance" then
			task.spawn(function()
				local Particles = env.Assets.BrazilParticles:Clone()
				Particles.Parent = target.Character.HumanoidRootPart
				local Sound = Instance.new("Sound")
				Sound.SoundId = "rbxassetid://5816432987"
				Sound.Parent = target.Character.HumanoidRootPart
				Sound.Volume = 0.5
				Sound.RollOffMinDistance = 10
				Sound.RollOffMaxDistance = 100
				Sound:Play()
				task.wait(1.3)
				Sound.Ended:Connect(function()
					Sound:Destroy()
				end)
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
