local TeleportService = game:GetService("TeleportService")
local Command = {}
Command.Name = "place"
Command.Description = "Sends the user(s) to the specified place."
Command.Aliases = {"tptoplace"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Place Id", ["Type"] = "Number"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to place."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if not args[2] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify a place id."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local SortedTargets = {}
	
	for _, tgt in args[1] do
		if typeof(tgt) == "Instance" then
			table.insert(SortedTargets, tgt)
		end
	end
	
	local suc = pcall(function()
		TeleportService:TeleportPartyAsync(tonumber(args[2]) or 0, SortedTargets)
	end)
	if not suc then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "An error has occurred."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
end

return Command
