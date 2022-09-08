local Players = game:GetService("Players")
local Command = {}
Command.Name = "removewarning"
Command.Description = "Removes the specified warning from the user."
Command.Aliases = {"rw"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Player", ["Type"] = "String"}, {["Name"] = "Warning Number", ["Type"] = "Number"}}
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't remove a warning from no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
	end
	if not args[2] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a warning number."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
	end
	
	local WarningNumber = tonumber(args[2])

		
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
				continue
			end
		end
		if (env.Admins[UserId] or 0) < env.API.getAdminLevel(plr) then
			local Key = string.format("Warnings_%s", UserId)
			local Warnings = env.DataStore:GetAsync(Key) or {}
			if Warnings[WarningNumber] then
				table.remove(Warnings, WarningNumber)
				env.DataStore:SetAsync(Key, Warnings)
				env.RemoteEvent:FireClient(plr, "showHint", {Title = "Success", Text = string.format("Successfully removed warning %s from %s", WarningNumber, Players:GetNameFromUserIdAsync(UserId))})
				env.RemoteEvent:FireClient(plr, "playSound", "Success")
			else
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Permissions Error", Text = string.format("%s doesn't have a warning number %s", Players:GetNameFromUserIdAsync(UserId), WarningNumber)})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
			end
		else
			env.RemoteEvent:FireClient(plr,"showHint", {Title = "Permissions Error", Text = string.format("%s has a higher admin level or the same as you", Players:GetNameFromUserIdAsync(UserId))})
			env.RemoteEvent:FireClient(plr, "playSound", "Error")
		end
	end
end

return Command