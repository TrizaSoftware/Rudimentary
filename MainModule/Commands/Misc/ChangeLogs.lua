local Command = {}
Command.Name = "changelogs"
Command.Description = "Shows you the Admin ChangeLogs."
Command.Aliases = {"acl"}
Command.Prefix = "SecondaryPrefix"
Command.Schema = {}
Command.RequiredAdminLevel = 0
Command.Handler = function(env, plr, args)
	env.RemoteEvent:FireClient(plr, "makePrivateMessage", {
			Title = string.format("Change Logs For Version %s (%s)", env.Version, env.VersionName),
			Text = string.format("%s\n\n© T:Riza Corporation",env.ChangeLogs),
			CanRespond = false
		}
	)
end

return Command