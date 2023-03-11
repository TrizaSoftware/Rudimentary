local Players = game:GetService("Players")
local Command = {}
Command.Name = "bans"
Command.Description = "Returns a list of banned users."
Command.Aliases = {"serverbans"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 3
Command.Handler = function(env, plr, args)
	local BanData = {}
	for _, data in pairs(env.Bans) do
		local suc, err = pcall(function()
			local Name = Players:GetNameFromUserIdAsync(data.UserId)
			table.insert(BanData, {
				Data = string.format("%s <font face = \"Gotham\">(%s)</font>",Name,data.UserId),
				ExtraData = string.format("Type: %s", data.Type)
			})
		end)
	end
	env.RemoteEvent:FireClient(plr, "makeList", {Title = "Bans", Items = BanData, AllowSearch = true, AllowRefresh = true, MethodToCall = "getBans"})
end

return Command