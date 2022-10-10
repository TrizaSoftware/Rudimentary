local Command = {}
Command.Name = "team"
Command.Description = "Sets the specified user(s) team."
Command.Aliases = {"setteam"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Team", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't team no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if not args[2] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify a team."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	local FormattedTeamName = {}
	for i = 2,#args do
		table.insert(FormattedTeamName, args[i])
	end
	FormattedTeamName = table.concat(FormattedTeamName, " ")
	
	local Team = nil
	
	for _, team in game.Teams:GetChildren() do
		if team.Name:lower():sub(1,FormattedTeamName:len()) == FormattedTeamName:lower() then
			Team = team
		end
	end
	
	if not Team then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("Team %s doesn't exist.", args[2])})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			target.Team = Team
		end
	end
end

return Command
