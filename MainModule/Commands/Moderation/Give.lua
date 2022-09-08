local Command = {}
Command.Name = "give"
Command.Description = "Gives the specified user(s) the specified tool(s)."
Command.Aliases = {"givetool"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Tool(s)", ["Type"] = "String"}}
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a user."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if not args[2] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You must specify a tool."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local PotentialToolNames = args[2]:split(",")
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			local Tools = {}
			for _, item in env.ToolStorage:GetDescendants() do
				if item:IsA("Tool") then
					for _, tn in PotentialToolNames do
						if tn:lower() == "all" then
							table.insert(Tools, item)
						elseif item.Name:lower():sub(1,tn:len()) == tn:lower() then
							table.insert(Tools, item)
						end
					end
				end
			end
			for _, tool in Tools do
				tool:Clone().Parent = target.Backpack
			end
		end
	end
end

return Command