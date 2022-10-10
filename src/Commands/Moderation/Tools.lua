local Command = {}
Command.Name = "tools"
Command.Description = "Gets the list of tools."
Command.Aliases = {"gettoollist"}
Command.Prefix = "MainPrefix"
Command.Schema = {}
Command.RequiredAdminLevel = 1
Command.Handler = function(env, plr, args)
	local Tools = {}
	for _, tool in env.ToolStorage:GetDescendants() do
		if tool:IsA("Tool") then
			table.insert(Tools, tool.Name)
		end
	end
	env.RemoteEvent:FireClient(plr, "makeList", {Title = "Tools", Items = Tools, AllowSearch = true})
end

return Command