local MarketPlaceService = game:GetService("MarketplaceService")
local Command = {}
Command.Name = "music"
Command.Description = "Plays music."
Command.Aliases = {"setmusic", "play"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "Music", ["Type"] = "String"}}
Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't play no music."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	if args[1] == "off" then
		if env.RWA:FindFirstChild("RudimentaryMusic") then
			env.RWA.RudimentaryMusic:Destroy()
		end
		return
	end
	if tonumber(args[1]) == nil then
		args[1] = 0
	else
		args[1] = tonumber(args[1])
	end
	local Sound = nil
	if env.RWA:FindFirstChild("RudimentaryMusic") then
		Sound = env.RWA.RudimentaryMusic
	else
		Sound = Instance.new("Sound")
		Sound.Name = "RudimentaryMusic"
		Sound.Parent = env.RWA
	end
	local suc = pcall(function()
		local ProductInfo = MarketPlaceService:GetProductInfo(args[1], Enum.InfoType.Asset)
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Success", Text = string.format("Successfully set music to %s", ProductInfo.Name)})
		env.RemoteEvent:FireClient(plr, "playSound", "Success")
		Sound.TimePosition = 0
		Sound:Stop()
		task.wait(0.1)
		Sound.SoundId = string.format("rbxassetid://%s", args[1])
		Sound:Play()
	end)
	if not suc then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "This sound doesn't exist."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
	end
end

return Command
