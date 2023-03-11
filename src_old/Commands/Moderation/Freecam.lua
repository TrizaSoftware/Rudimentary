local Command = {}
Command.Name = "freecam"
Command.Description = "Lets the user(s) use freecam."
Command.Aliases = {"usefreecam"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "Can't allow no one to use freecam."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local isNoclip = env.Utils.textToBool(args[2])
	if isNoclip == nil then
		isNoclip = false
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			if target.Character:FindFirstChild("RudimentaryFreecamHandler") then
				env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("%s is already using freecam.", target.Name)})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			env.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Info", Title = "Notification", Text = "You're using freecam. Press Shift + P to toggle freecam."})
			local Clone = env.Assets.Freecam:Clone()
			Clone.Name = "RudimentaryFreecamHandler"
			Clone.Parent = target.Character
			Clone.Disabled = false
		end
	end
end

return Command