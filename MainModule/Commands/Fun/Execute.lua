local Command = {}
Command.Name = "execute"
Command.Description = "Executes the code that a user specifies."
Command.Aliases = {"exec"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Code", ["Type"] = "String"}}
Command.RequiredAdminLevel = 4
Command.Handler = function(env, plr, args)
	local Loadstring = require(env.ServerModules.Loadstring)
	local Code = table.concat(args, " ")
	Loadstring(Code, getfenv(3))()
	env.RemoteEvent:FireClient(plr, "showHint", {Title = "Success", Text = "Code Successfully Executed."})
end

return Command