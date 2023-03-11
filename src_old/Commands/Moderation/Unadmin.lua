local Players = game:GetService("Players")
local Command = {}
Command.Name = "unadmin"
Command.Description = "Removes the specified user(s) admin."
Command.Aliases = {"removeperms", "removeadmin"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Is Permanent", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	local isPerm = env.Utils.textToBool(args[2])
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to manage."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if isPerm == nil then
		isPerm = false
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
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s isn't a valid user.", target)})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
			end
		end
		if (env.Admins[UserId] or 0) >= env.API.getAdminLevel(plr) then
			env.RemoteEvent:FireClient(plr,"showHint", {
				Title = "Permissions Error", 
				Text = string.format("%s has a higher admin level or the same as you.", Players:GetNameFromUserIdAsync(UserId))
			})
			env.RemoteEvent:FireClient(plr, "playSound", "Error")
		else
			env.API.setAdminLevel(UserId, 0, isPerm)
			env.RemoteEvent:FireClient(plr,"showHint", {
				Title = "Success", 
				Text = string.format("Successfully removed %s's admin.", Players:GetNameFromUserIdAsync(UserId))
			})
			env.RemoteEvent:FireClient(plr, "playSound", "Success")
		end
	end
end

return Command
