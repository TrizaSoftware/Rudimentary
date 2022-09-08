local Players = game:GetService("Players")
local Command = {}
Command.Name = "warnings"
Command.Description = "Views the warnings for the specified user."
Command.Aliases = {"viewwarnings"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "Player", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't view the warnings of no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
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
				continue
			end
		end
		local Key = string.format("Warnings_%s", UserId)
		local Warnings = env.DataStore:GetAsync(Key) or {}
		local WarningData = {}
		for i, warning in Warnings do
			WarningData[i] = {Data = string.format("Warning %s | %s", i, warning.Reason or warning), ExtraData = string.format("Moderator: %s", warning.Moderator or "Error")}
		end
		env.RemoteEvent:FireClient(plr, "makeList", {Title = string.format("%s's Warnings", Players:GetNameFromUserIdAsync(UserId)), Items = WarningData, AllowSearch = true, AllowRefresh = true, MethodToCall = "getWarnings", ReqArgs = {UserId}})
	end
end

return Command