local Command = {}
Command.Name = "bring"
Command.Description = "Teleports specified users to you."
Command.Aliases = {"bringtome"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Player", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a user."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	task.defer(env.Commands["teleport"].Handler,env,plr,{args[1], {plr}})
end

return Command