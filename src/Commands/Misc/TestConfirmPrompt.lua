local Command = {}
Command.Name = "testconfirmprompt"
Command.Description = "Does cool prompt things"
Command.Aliases = {"tcp"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 0
Command.Schema = {}
Command.Handler = function(env, plr, args)
	env.RemoteEvent:FireClient(plr, "MakeConfirmationPrompt", "This is a test.")
end

return Command
