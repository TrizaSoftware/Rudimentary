local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local validIndentifiers = {
  "d",
  "h",
  "m"
}

local function parseString(str)
	local chars = str:split("")
	local parsedData = {}
	for i, char in chars do
		if table.find(validIndentifiers, char) then
			 local numparts = ""
			 for num = i-1,1,-1 do
				  if tonumber(chars[num]) ~= nil then
					numparts = string.format("%s%s", numparts, chars[num])
				 else
					 break
				end
			 end
			 numparts = numparts:reverse()
			 parsedData[char] = if parsedData[char] then tonumber(numparts) + parsedData[char] else tonumber(numparts)
		  end
	 end
	return parsedData
 end

local Command = {}
Command.Name = "timeban"
Command.Description = "Bans a user from the game for a specified amount of time."
Command.Aliases = {"tban"}
Command.Prefix = "MainPrefix"
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}, {["Name"] = "Time", ["Type"] = "String"}, {["Name"] = "Reason", ["Type"] = "String"}}
Command.RequiredAdminLevel = 2
Command.ArgsToReplace = {1}

Command.Handler = function(env, plr, args)
	if not args[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to ban."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
  if not args[2] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify an amount of time."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	end
	local Target = args[1]
	local ParsedTimeData = parseString(args[2])
	local Seconds = 0
	for timetype, num in ParsedTimeData do
		if timetype == "d" then
				Seconds += num * 86400
		elseif timetype == "h" then
				Seconds += num * 3600
		elseif timetype == "m" then
				Seconds += num * 60
		end
	end
	print(Seconds)
  local UnbanTime = os.time() + Seconds
	print(UnbanTime)
	local BanReason = "You've been time banned."
	local nt = {}
	if #args >= 3 then
		for i = 3,#args do
			table.insert(nt, args[i])
		end
	end
	BanReason = string.format("%s\nReason: %s",BanReason,if #args >= 2 then table.concat(nt," ") else "No reason provided.")
	BanReason = string.format("%s\nModerator:\n%s",Chat:FilterStringForBroadcast(BanReason, plr),plr.Name)
  BanReason = string.format("\nExpires:\n%s", os.date("%A, %b %d, %Y @ %H:%M (UTC)", UnbanTime))
	if not Target[1] then
		env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You must specify at least one user to ban."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
		return
	else
		if #Target > 5 then
			if env.API.requestAuth(plr, "You're attempting to time ban more than 5 people at a time, are you sure you want to contunue?") == false then
				return
			end
		end
		local TimeBans = env.DataStore:GetAsync("TimeBans")
		for _, tgt in Target do
			local UserId = nil
			if typeof(tgt) == "Instance" then
				UserId = tgt.UserId
			elseif tonumber(tgt) ~= nil then
				UserId = tonumber(tgt)
			else
				local suc = pcall(function()
					UserId = Players:GetUserIdFromNameAsync(tgt)
				end)
				if not suc then
					env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s isn't a valid user.", tgt)})
					env.RemoteEvent:FireClient(plr, "playSound", "Error")
					return
				end
			end
			local TimeBanned = false
			for _, bd in TimeBans do
				if bd.UserId == UserId then
					TimeBanned = true
				end
			end
			if TimeBanned then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = string.format("%s is already time banned.", Players:GetNameFromUserIdAsync(UserId))})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			if UserId == plr.UserId then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Error", Text = "You can't server ban yourself."})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
				continue
			end
			if (env.Admins[UserId] or 0) < env.API.getAdminLevel(plr) then
				env.RemoteEvent:FireClient(plr,"showHint", {Title = "Success", Text = string.format("Successfully time banned %s.", Players:GetNameFromUserIdAsync(UserId))})
				env.RemoteEvent:FireClient(plr, "playSound", "Success")
				local tgtplr = Players:GetPlayerByUserId(tonumber(UserId))
				if tgtplr then
					env.API.removePlayerFromServer(tgtplr, BanReason)
				end
				table.insert(TimeBans, {UserId = UserId, Reason = BanReason, UnbanTime = UnbanTime})
				env.DataStore:SetAsync("TimeBans", TimeBans)
				env.API.CSM.dispatchMessageToServers({request = "addTimeBan", userId = UserId, reason = BanReason, unbanTime = UnbanTime})
				env.API.addToBanHistory(UserId,
					string.format("[{time:%s:sdi}] Time Banned at {time:%s:ampm} by %s for reason %s until %s",
						os.time(),
						os.time(),
						plr.Name,
						if #args >= 3 then table.concat(nt," ") else "No reason provided.",
						os.date("%A, %b %d, %Y @ %H:%M (UTC)", UnbanTime)
					)
				)
			else
				env.RemoteEvent:FireClient(plr,"showHint", {
					Title = "Permissions Error",
					Text = string.format("%s has a higher admin level or the same as you.", Players:GetNameFromUserIdAsync(UserId))
				})
				env.RemoteEvent:FireClient(plr, "playSound", "Error")
			end
		end
	end
end

return Command