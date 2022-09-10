local Players = game:GetService("Players")
local Command = {}
Command.Name = "banhistory"
Command.Description = "Fetches the ban history for the specified user."
Command.Aliases = {"bh"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User", ["Type"] = "string"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't see the ban history of no one."})
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
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s isn't a valid user.", target)})
			end
		end
		local BanHistory = env.DataStore:GetAsync(string.format("BanHistory_%s", UserId)) or {}
		for i, data in BanHistory do
			BanHistory[i] = {Data = data, Clickable = true}
		end
		env.RemoteEvent:FireClient(plr, "makeList", {
			Title = string.format("%s's Ban History", Players:GetNameFromUserIdAsync(tonumber(UserId))), 
			Items = BanHistory, 
			AllowSearch = true, 
			AllowRefresh = true,
			MethodToCall = "getBanHistory", 
			ReqArgs = {UserId}
		})
	end
end

return Command
