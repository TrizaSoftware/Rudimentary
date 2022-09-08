local Command = {}
Command.Name = "adminlevels"
Command.Description = "Gets all admin levels."
Command.Aliases = {"als"}
Command.Prefix = "MainPrefix"
Command.Schema = {}
Command.RequiredAdminLevel = 1
Command.Handler = function(env, plr, args)
	local AdminData = {}
	for level, name in pairs(env.AdminLevels) do
		table.insert(AdminData, {Data = name, ExtraData = string.format("Permission Level: %s", level)})
	end
	env.RemoteEvent:FireClient(plr, "makeList", {Title = "Admin Levels", Items = AdminData, AllowSearch = true, AllowRefresh = false})
end

return Command