local Players = game:GetService("Players")
local Command = {}
Command.Name = "unchar"
Command.Description = "Makes the specified user(s) look like themselves."
Command.Aliases = {"unimpersonate"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't unchar no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			task.spawn(function()
				task.defer(env.Commands.char.Handler, env, plr, {{target}, target.Name})
			end)
		end
	end
end

return Command
