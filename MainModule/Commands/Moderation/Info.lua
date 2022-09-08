local PolicyService = game:GetService("PolicyService") 
local Command = {}
Command.Name = "info"
Command.Description = "Gets the information of the specified user."
Command.Aliases = {"i", "whois"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Player", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	--[[
	if typeof(args[1]) == "table" then
		for _, arg in pairs (args[1]) do
			if typeof(arg) == "Instance" then
				table.insert(Target, arg)
			else
				local user = env.API.findUser(arg)
				if user then
					table.insert(Target, user)
				end
			end
		end
	else
		if typeof(args[1]) == "Instance" then
			Target = args[1]
		else
			Target = env.API.findUser(args[1])
		end
	end
	]]
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't get the info of no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	--if (typeof(Target) == "table") == false then
	local suc, err = pcall(function()
		for _, Target in args[1] do
			if typeof(Target) == "Instance" then
				local Data = {}
				local PolicyInfo = PolicyService:GetPolicyInfoForPlayerAsync(Target)
				local HasSafechat = true
				if table.find(PolicyInfo.AllowedExternalLinkReferences, "Discord") then
					HasSafechat = false
				end
				table.insert(Data, string.format("Admin Level: <font face = \"Gotham\">%s</font>", env.AdminLevels[env.Admins[Target.UserId]]))
				table.insert(Data, string.format("Account Age: <font face = \"Gotham\">%s</font>", if Target.AccountAge == 1 then "1 Day" else Target.AccountAge.." Days"))
				table.insert(Data, string.format("Has SafeChat: <font face = \"Gotham\">%s</font>", tostring(HasSafechat)))
				table.insert(Data, string.format("Has Premium: <font face = \"Gotham\">%s</font>", tostring(Target.MembershipType == Enum.MembershipType.Premium)))
				table.insert(Data, string.format("Is Donor: <font face = \"Gotham\">%s</font>", tostring(env.API.checkIsDonor(Target))))
				table.insert(Data, string.format("Display Name: <font face = \"Gotham\">%s</font>", Target.DisplayName))
				local groups = {}
				for _, data in pairs(env.GroupConfig) do
					if not table.find(groups, data.GroupId) then
						table.insert(groups, data.GroupId)
						table.insert(Data, string.format("Rank In \"{group:%s:name}\": {group:%s:%s:role}", data.GroupId, data.GroupId, Target.UserId))
					end
				end
				env.RemoteEvent:FireClient(plr,"makeList", {Title = string.format("%s's Info", Target.Name), AllowRefresh = false, AllowSearch = true, Items = Data})
			end
		end
	end)
	if not suc then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "An error has occurred during the request."})
	end
	--end
	--[[
	local Message = table.concat(args, " ")
	if not Message:find("%w") then
		env.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Error", Text = "You must specify a message."})
		return
	end
	env.RemoteEvent:FireAllClients("showHint", {Title =  plr.Name, Text = Chat:FilterStringForBroadcast(Message, plr)})
	]]
end

return Command