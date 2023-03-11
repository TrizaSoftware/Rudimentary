local Players = game:GetService("Players")
local Command = {}
Command.Name = "admins"
Command.Description = "Gets all admins."
Command.Aliases = {"staff"}
Command.Prefix = "MainPrefix"
Command.Schema = {}
Command.RequiredAdminLevel = 1
Command.Handler = function(env, plr, args)
	local AdminData = {}
	for uid, level in pairs(env.Admins) do
		local suc, err = pcall(function()
			if level >= 1 then
				local Name = Players:GetNameFromUserIdAsync(uid)
				local AdminLevel = tostring(env.AdminLevels[level])
				table.insert(AdminData, string.format("%s <font face = \"Gotham\">(%s)</font>",Name,AdminLevel))
			end
		end)
	end
	env.RemoteEvent:FireClient(plr, "makeList", {Title = "Admins", Items = AdminData, AllowSearch = true, AllowRefresh = true, MethodToCall = "getAdmins"})
end

return Command