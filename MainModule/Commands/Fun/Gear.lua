local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local Command = {}
Command.Name = "gear"
Command.Description = "Gives the specified user(s) the specified gear id."
Command.Aliases = {"givegear", "makecharacter"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Gear Id", ["Type"] = "Number"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't gear no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if not args[2] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify a gear id."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local GearTool = nil
	local suc = pcall(function()
		GearTool = InsertService:LoadAsset(tonumber(args[2])):FindFirstChildWhichIsA("Tool")
		if not GearTool then
			error()
		end
	end)
	if not suc then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s doesn't exist.", args[2])})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for _, target in args[1] do
		if typeof(target) == "Instance" then
			GearTool:Clone().Parent = target.Backpack
		end
	end
end

return Command
