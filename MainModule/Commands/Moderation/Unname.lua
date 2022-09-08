local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "unname"
Command.Description = "Unnames the user(s)."
Command.Aliases = {"removename"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "Can't unname no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			if target.Character:FindFirstChild("RudimentaryNameUi") then
				target.Character.RudimentaryNameUi:Destroy()
			else
				env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("%s isn't named.", target.Name)})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
			end
		end
	end
end

return Command