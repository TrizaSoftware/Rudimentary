local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "warn"
Command.Description = "Warns the specified user."
Command.Aliases = {"warnuser"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Player", ["Type"] = "String"}, {["Name"] = "Reason", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't warn no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
	end
	
	local WarnReason = {}
	if #args >= 2 then
		for i = 2,#args do
			table.insert(WarnReason, args[i])
		end
	end
	
	
	WarnReason = if #args >= 2 then table.concat(WarnReason, " ") else "No reason provided."
	
	local suc = pcall(function()
		WarnReason = Chat:FilterStringForBroadcast(WarnReason, plr)
	end)
	if not suc then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "Message Filtering Failed."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		local UserId = nil
		if typeof(target) == "Instance" then
			UserId = target.UserId
		elseif tonumber(target) ~= nil then
			UserId = tonumber(target)
		else
			local suc = pcall(function()
				UserId = Players:GetUserIdFromNameAsync(target)
			end)
			if not suc then
				env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("%s doesn't exist.", target)})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
			end
		end
		if (env.Admins[UserId] or 0) < env.API.getAdminLevel(plr) then
			local Key = string.format("Warnings_%s", UserId)
			local Warnings = env.DataStore:GetAsync(Key) or {}
			table.insert(Warnings, {Reason = WarnReason, Moderator = plr.Name})
			env.DataStore:SetAsync(Key, Warnings)
			env.RemoteEvent:FireClient(plr, "showHint", {Title = "Success", Text = string.format("Successfully warned %s for %s", Players:GetNameFromUserIdAsync(UserId), WarnReason)})
			env.RemoteEvent:FireClient(plr, "playSound", "Success")
			local tgtuser = Players:GetPlayerByUserId(UserId)
			if tgtuser then
				env.RemoteEvent:FireClient(tgtuser, "displayNotification", {
					Type = "Info", 
					Text = "You've been warned by:", 
					SecondaryText = plr.Name, 
					ExtraData = {
						InstanceToCreate = "PrivateMessage", 
						InstanceData = {
							Title = string.format("Warning From: %s", plr.Name),
							Text = WarnReason,
							Sender = plr.Name,
							CanRespond = false
						}
					}
				})
			end
		else
			env.RemoteEvent:FireClient(plr,"showHint", {Title = "Permissions Error", Text = string.format("%s has a higher admin level or the same as you", Players:GetNameFromUserIdAsync(UserId))})
			env.RemoteEvent:FireClient(plr, "playSound", "Error")
		end
	end
end

return Command