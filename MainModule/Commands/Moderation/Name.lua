local Chat = game:GetService("Chat")
local Command = {}
Command.Name = "name"
Command.Description = "Names the user(s)."
Command.Aliases = {"setname"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Name", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't name no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	local Name = {}
	if #args >= 2 then
		for i = 2,#args do
			table.insert(Name, args[i])
		end
	end

	Name = if #args >= 2 then table.concat(Name, " ") else ""

	local suc = pcall(function()
		Name = Chat:FilterStringForBroadcast(Name, plr)
	end)
	if not suc then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "Text Filtering Failed."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			if not target.Character:FindFirstChild("RudimentaryNameUi") then
				local Clone = env.Assets.NameUi:Clone()
				Clone.Name = "RudimentaryNameUi"
				Clone.Parent = target.Character
				Clone.Adornee = target.Character.Head
				Clone.Holder.NameText.Text = Name
			else
				target.Character.RudimentaryNameUi.Holder.NameText.Text = Name
			end
		end
	end
end

return Command