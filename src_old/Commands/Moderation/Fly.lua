local Command = {}
Command.Name = "fly"
Command.Description = "Lets the user(s) fly."
Command.Aliases = {"giveflight"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Noclip", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "Can't fly no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local isNoclip = env.Utils.textToBool(args[2])
	if isNoclip == nil then
		isNoclip = false
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			if target.Character:FindFirstChild("RudimentaryFlyHandler") then
				env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("%s is already flying.", target.Name)})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			env.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Info", Title = "Notification", Text = "You're flying. Press F to toggle flight."})
			local BodyPosition = Instance.new("BodyPosition")
			BodyPosition.Name = "RudimentaryBodyPosition"
			BodyPosition.Parent = target.Character.HumanoidRootPart
			local BodyGyro = Instance.new("BodyGyro")
			BodyGyro.Name = "RudimentaryBodyGyro"
			BodyGyro.Parent = target.Character.HumanoidRootPart
			local Clone = env.Assets.FlyHandler:Clone()
			Clone.Name = "RudimentaryFlyHandler"
			Clone.Parent = target.Character
			Clone.Disabled = false
			if isNoclip then
				local NCClone = env.Assets.FlyNoClip:Clone()
				NCClone.Name = "RudimentaryFlyNoClipHandler"
				NCClone.Parent = target.Character
				NCClone.Disabled = false
			end
		end
	end
end

return Command