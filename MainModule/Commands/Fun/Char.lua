local Players = game:GetService("Players")
local Command = {}
Command.Name = "char"
Command.Description = "Makes the specified user(s) look like the specified character."
Command.Aliases = {"impersonate", "makecharacter"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "User To Become", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't char no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if not args[2] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify someone to become."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local HumanoidDescription = nil
	local suc = pcall(function()
		HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(Players:GetUserIdFromNameAsync(args[2]))
	end)
	if not suc then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s doesn't exist.", args[2])})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			target.Character.Humanoid:ApplyDescription(HumanoidDescription)
		end
	end
end

return Command
