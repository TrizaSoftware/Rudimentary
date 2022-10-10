local Players = game:GetService("Players")
local Command = {}
Command.Name = "setadminlevel"
Command.Description = "Sets the specified user(s) admin level."
Command.Aliases = {"admin", "rank", "sal"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Admin Level", ["Type"] = "Number"}, {["Name"] = "Is Permanent", ["Type"] = "String"}}
Command.RequiredAdminLevel = 2
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	local adminLevel = tonumber(args[2])
	local isPerm = env.Utils.textToBool(args[3])
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to manage."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if not adminLevel then 
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify an admin level."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if not env.AdminLevels[adminLevel] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify a valid admin level."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if adminLevel >= env.API.getAdminLevel(plr) then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't set someone's admin level to one higher or equal to yours."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if adminLevel == 0 then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't set someone's admin level to 0, use the \"unadmin\" command."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if isPerm == nil then
		isPerm = false
	end
	if #args[1] >= 5 then
		local approved = env.API.requestAuth(plr, "You're attempting to manage more than 5 people at a time, are you sure you want to contunue?")
		if not approved then return end
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
			env.API.setAdminLevel(UserId, adminLevel, isPerm)
			env.RemoteEvent:FireClient(plr,"showHint", {
				Title = "Success", 
				Text = string.format("Successfully gave %s admin level %s.", Players:GetNameFromUserIdAsync(UserId), adminLevel)
			})
			env.RemoteEvent:FireClient(plr, "playSound", "Success")
		end
	end
end

return Command