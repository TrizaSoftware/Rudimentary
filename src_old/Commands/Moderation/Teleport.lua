local Command = {}
Command.Name = "teleport"
Command.Description = "Teleports the specified player(s) to a user."
Command.Aliases = {"tp"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.ArgsToReplace = {1,2}
Command.Schema = {{["Name"] = "Player(s)", ["Type"] = "String"}, {["Name"] = "Target", ["Type"] = "String"}}
Command.Handler = function(env, plr, args)
	local target1 = args[1]
	local target2 = if args[2] then args[2][1] else nil
	--[[
	
	if typeof(target1) == "table" then
		for i, item in pairs(target1) do
			if typeof(item) == "string" then
				local user = env.API.findUser(item)
				if user then
					target1[i] = user
				else
					table.remove(target1,i)
				end
			end
		end
	elseif typeof(target1) == "string" then
		local user = env.API.findUser(target1)
		if user then
			target1 = user
		else
			target1 = nil
		end
	end
	if typeof(target1) ~= "table" then
		target1 = {target1}
	end
	local target2 = args[2]
	if typeof(target2) == "table" then
		for i, item in pairs(target2) do
			if typeof(item) == "string" then
				local user = env.API.findUser(item)
				if user then
					target2[i] = user
				else
					table.remove(target2,i)
				end
			end
		end
	elseif typeof(target2) == "string" then
		local user = env.API.findUser(target2)
		if user then
			target2 = user
		else
			target2 = nil
		end
	end
	]]
	if not target1 then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't teleport no one."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if typeof(target2) ~= "Instance" then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "The thing you're teleporting to must be a user."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	for i, target in target1 do
		task.spawn(function()
			if target.Character.Humanoid.Sit then
				target.Character.Humanoid.Jump = true
				task.wait(0.3)
			end
			target.Character.HumanoidRootPart.CFrame = (target2.Character.HumanoidRootPart.CFrame*CFrame.Angles(0, math.rad(90/#target1*i), 0)*CFrame.new(5+.2*#target1, 0, 0))*CFrame.Angles(0, math.rad(90), 0)
		end)
	end
end

return Command