local Players = game:GetService("Players")
local Command = {}
Command.Name = "unban"
Command.Description = "Unbans the specified user."
Command.Aliases = {"removeban", "revokeban"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Username or User Id", ["Type"] = "String"}}
Command.RequiredAdminLevel = 2
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't unban no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return 
	end
	local UsersToUnban = args[1]:split(",")
	for _, User in UsersToUnban do
		local UserId = nil
		if tonumber(User) ~= nil then
			if tonumber(User) < 1 then
				env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "Invalid User Id."})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				return
			end
			UserId = tonumber(User)
		else
			local suc = pcall(function()
				UserId = game.Players:GetUserIdFromNameAsync(User)
			end)
			if not suc then
				env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("A user with the name \"%s\" doesn't exist.", args[1])})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
			end
		end
		local BansRemoved = 0
		for _, bandata in env.Bans do
			if bandata.UserId == UserId then
				if bandata.Type == "Perm" then
					env.API.CSM.dispatchMessageToServers({request = "removePermanentBan", userId = UserId})
					local PermanentBans = env.DataStore:GetAsync("PermanentBans")
					for i, bd in PermanentBans do
						if bd.UserId == UserId then
							table.remove(PermanentBans, i)
						end
					end
					env.DataStore:SetAsync("PermanentBans", PermanentBans)
				elseif bandata.Type == "Trello" then
					env.API.makeTrelloRequest("removeBan", UserId)
				end
				env.API.removeBan(bandata.UserId, bandata.Type)
				BansRemoved += 1
			end
		end
		if BansRemoved > 0 then
			env.API.addToBanHistory(UserId, 
				string.format("[{time:%s:sdi}] All bans revoked at {time:%s:ampm} by %s", 
					os.time(),
					os.time(),
					plr.Name
				)
			)
			env.RemoteEvent:FireClient(plr, "showHint", {Title = "Success", Text = string.format("Successfully removed all bans from %s.", Players:GetNameFromUserIdAsync(UserId))})
			env.RemoteEvent:FireClient(plr, "playSound", "Success")
		else
			env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("%s isn't banned.", Players:GetNameFromUserIdAsync(UserId))})
			env.RemoteEvent:FireClient(plr, "playSound", "Error")
		end
		--[[[
		if env.Bans[UserId] then
			env.API.removeUserFromBans(UserId)
			env.RemoteEvent:FireClient(plr, "showHint", {Title = "Success", Text = string.format("\"%s\" was unbanned.", args[1])})
		else
			env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("\"%s\" isn't banned.", args[1])})
		end
		]]
	end
end

return Command