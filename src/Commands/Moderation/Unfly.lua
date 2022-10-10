local Command = {}
Command.Name = "unfly"
Command.Description = "Stops the user(s) from flying."
Command.Aliases = {"removeflight"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "Can't unfly no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			if target.Character:FindFirstChild("RudimentaryFlyHandler") then
				target.Character.HumanoidRootPart.RudimentaryBodyPosition:Destroy()
				target.Character.HumanoidRootPart.RudimentaryBodyGyro:Destroy()
				target.Character.RudimentaryFlyHandler:Destroy()
				target.Character.Humanoid.PlatformStand = true
				target.Character.Humanoid.PlatformStand = false
				if target.Character:FindFirstChild("RudimentaryFlyNoClipHandler") then
					target.Character.RudimentaryFlyNoClipHandler:Destroy()
				end
			end
		end
	end
end

return Command