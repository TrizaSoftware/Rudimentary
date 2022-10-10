local Command = {}
Command.Name = "serverlock"
Command.Description = "Locks the server."
Command.Aliases = {"slock"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "Yes/No", ["Type"] = "String"}}
Command.Handler = function(env, plr, args)
	local Enabled = env.Utils.textToBool(args[1])
	if Enabled == nil then
		Enabled = true
	end
	if env.ServerLocked == Enabled then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("This server is already %s", if Enabled then "locked" else "unlocked")})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
	else
		env.API.setServerLock(Enabled)
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Success", Text = string.format("This server has been %s", if Enabled then "locked" else "unlocked")})
		env.RemoteEvent:FireClient(plr, "playSound", "Success")
	end
end

return Command
