--[[
    ____            ___                      __                  
   / __ \__  ______/ (_)___ ___  ___  ____  / /_____ ________  __
  / /_/ / / / / __  / / __ `__ \/ _ \/ __ \/ __/ __ `/ ___/ / / /
 / _, _/ /_/ / /_/ / / / / / / /  __/ / / / /_/ /_/ / /  / /_/ / 
/_/ |_|\__,_/\__,_/_/_/ /_/ /_/\___/_/ /_/\__/\__,_/_/   \__, /  
                                                        /____/                
                                                        
	 Programmer(s): CodedJimmy
	 
	 T:Riza Rudimentary
	  
	 © T:Riza Corporation 2020-2022
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local MarketPlaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local GroupService = game:GetService("GroupService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local Shared = script.Parent:WaitForChild("Shared")
local Assets = script.Parent:WaitForChild("Assets")
local TNet = require(Shared.TNet)
local Utils = require(Shared.Utils)
local Signal = require(Shared.BetterSignal)
local KeyModule = require(Shared.Key)
local Dependencies = script.Dependencies
local DataStoreEngine = require(Dependencies.DataStoreEngine)
local ServerFunctions = require(Dependencies.Functions)
local AuthRequest
task.spawn(function()
	AuthRequest = require(Dependencies.AuthRequest)
end)
local _warn = warn
local function warn(...)
	_warn("[Rudimentary]:",...)
end

local Settings = {
	["DebugMode"] = false,
	["Prefix"] = ":",
	["SecondaryPrefix"] = "!",
	["CommandBarKey"] = "Quote",
	["DataStoreName"] = "DefaultRudimentaryStore",
	["ServerMessageTitle"] = "Server Message",
	["Theme"] = "Default",
	["RequiredLevelForSettings"] = 4,
	["TrelloIntegrations"] = false,
	["DisableCommandTargetNotifications"] = false,
	["DisabledCommandTypes"] = {},
	["ToolStorage"] = ServerStorage,
	["CommandLevels"] = {},
	["RudimentaryPlus"] = false,
	["RudimentaryPlusKey"] = ""
}

local ValidSettings = {
	"DebugMode",
	"Prefix",
	"SecondaryPrefix",
	"CommandBarKey",
	"DataStoreName",
	"ServerMessageTitle",
	"Lytica",
	"LyticaKey",
	"TrizaRanking",
	"TrizaRankingKey",
	"DisableAdminCreators",
	"GroupRankToDisplay",
	"LoaderId",
	"CustomAdminLevels",
	"RequiredLevelForSettings",
	"TrelloIntegrations",
	"TrelloBoardId",
	"TrelloAppKey",
	"TrelloToken",
	"Theme",
	"ToolStorage",
	"DisabledCommandTypes",
	"DisableCommandTargetNotifications",
	"RudimentaryPlus",
	"RudimentaryPlusKey"
}

local ValidSettingsExceptions = {
	"GroupConfig",
	"Admins",
	"CommandLevels",
}

local NonEditableSettings = {
	"DebugMode",
	"LoaderId",
	"GroupConfig",
	"Lytica",
	"LyticaKey",
	"TrizaRanking",
	"TrizaRankingKey",
	"DisableAdminCreators",
	"CustomAdminLevels",
	"TrelloBoardId",
	"TrelloAppKey",
	"TrelloToken",
	"DataStoreName",
	"ToolStorage",
	"DisabledCommandTypes",
	"CommandLevels",
	"RudimentaryPlus",
	"RudimentaryPlusKey"
}

local BlacklistedSettingsTerms = {
	"TrelloAppKey",
	"TrelloBoardId",
	"TrelloToken",
	"Lytica",
	"TrizaRanking"
}

local KeyCodeSettings = {
	"CommandBarKey"
}

local OptionsForSettings = {
	Theme = {}
}

local AuthRequests = {

}

local function checkHTTPService()
	local suc = pcall(function()
		HttpService:GetAsync("https://infra.triza.dev/api/v1/checkuptime")
	end)
	return suc
end

local mainTable = {
	Version = "0.9.3-canary",
	VersionName = "Tired Tiger",
	ChangeLogs = [[
		In Dev
	]],
	HttpService = checkHTTPService(),
	ServerRegion = "",
	ServerLocked = false,
	ShutDown = false,
	RemoteFunction = nil,
	RemoteEvent = nil,
	AuthFolder = nil,
	RudimentaryServerId = nil,
	Admins = {
		[177424228] = math.huge,
		[671742714] = math.huge
	},
	Donors = {
		
	},
	Keys = {
	},
	DataStore = nil,
	AdminLevels = {
		[0] = "Nonadmin",
		[1] = "Moderator",
		[2] = "Administrator",
		[3] = "Super Admin",
		[4] = "Lead Admin",
		[5] = "Game Creator",
		[math.huge] = "Admin Developer"
	},
	DonorShirt = 10422629762,
	Commands = {
		
	},
	Aliases = {
		
	},
	Bans = {
		
	},
	Logs = {
		
	},
	ChatLogs = {
		
	},
	BannedAssetIds = {
		1055299
	},
	CapeData = {
		
	},
	ClientLogs = {
		
	},
	DebugLogs = {

	},
	TrelloListIds = {

	},
	TrelloCards = {
		
	}
}


local StartedClients = {
	
}

local APIEvents = {
	["commandRan"] = Signal.new(),
	["authGave"] = Signal.new()
}

local APIFunctions = nil

APIFunctions = {
	["findUser"] = function(username: string)
		if username == "" or not username then return end
		username = username:lower()
		for _, user in pairs (Players:GetPlayers()) do
			if username == user.Name:lower():sub(1,username:len()) then
				return user
			end
		end
		for _, user in pairs (Players:GetPlayers()) do
			if username == user.DisplayName:lower():sub(1,username:len()) then
				return user
			end
		end
	end,
	["setAdminLevel"] = function(userId: number, AdminLevel, isPerm)
		if not mainTable.AdminLevels[AdminLevel] then return end 
		if AdminLevel == math.huge then return end
		if not userId then return end
		if not isPerm then
			mainTable.Admins[userId] = AdminLevel
			local player = Players:GetPlayerByUserId(userId)
			if player then
				mainTable.RemoteEvent:FireClient(player, "changeData", "AdminLevel", AdminLevel)
				if AdminLevel > 0 then
					mainTable.RemoteEvent:FireClient(player, "displayNotification", {
						Type = "Alert",
						Text = string.format("You're a(n) %s!", mainTable.AdminLevels[mainTable.Admins[player.UserId]]),
						SecondaryText = "Click for Commands",
						ExtraData = {
							MethodAfterClick = "getCommands",
							InstanceToCreate = "List",
							InstanceData = {
								Title = "Commands"
							}
						}
					})
				end
			end
		else
			local SavedAdmins = mainTable.DataStore:GetAsync("SavedAdmins")
			SavedAdmins[tostring(userId)] = AdminLevel
			mainTable.DataStore:SetAsync("SavedAdmins", SavedAdmins)
			mainTable.Admins[userId] = AdminLevel
			APIFunctions.CSM.dispatchMessageToServers({request = "changeUserAdminLevel", userId = userId, adminLevel = AdminLevel})
		end
	end,
	["getAdminLevel"] = function(plr)
		return mainTable.Admins[plr.UserId]
	end,
	["checkIsDonor"] = function(plr)
		return if table.find(mainTable.Donors, plr.UserId) then true else false
	end,
	["makeUserDonor"] = function(plr)
		table.insert(mainTable.Donors, plr.UserId)
	end,
	["addUserToBans"] = function(userId,data)
		data.UserId = userId
		table.insert(mainTable.Bans, data)
	end,
	["removeBan"] = function(userId, banType)
		for index, data in mainTable.Bans do
			if data.UserId == userId and data.Type == banType then
				table.remove(mainTable.Bans, index)
			end
		end
	end,
	["makeHTTPRequest"] = function(url, method, headers, body)
		assert(mainTable.HttpService == true, "HttpService must be enabled to make HTTP requests.")
		local suc,res = pcall(function()
			local BodyEncoded = if body then HttpService:JSONEncode(body) else nil
			local req = HttpService:RequestAsync({Url = url, Method = method or "GET", Headers = headers or {}, Body = BodyEncoded})
			return req
		end)
		return res
	end,
	["makeTrelloRequest"] = function(request, ...)
		local BoardId, AppKey, Token = Settings.TrelloBoardId, Settings.TrelloAppKey, Settings.TrelloToken
		local Data = {...}
		if request == "removeBan" then
			local UserId = Data[1]
			for i, card in mainTable.TrelloCards.Ban do
				local CardData = card.name:split(":")
				local uid = tonumber(CardData[2])
				if uid == UserId then
					APIFunctions.makeHTTPRequest(
						string.format("https://api.trello.com/1/cards/%s?key=%s&token=%s", card.id, AppKey, Token),
						"DELETE"
					)
					table.remove(mainTable.TrelloCards.Ban, i)
				end
			end
		elseif request == "addBan" then
			assert(mainTable.TrelloListIds.Ban ~= nil, "No ban list exists.")
			local UserId = Data[1]
			local Reason = Data[2]
			local CardName = string.format("UserId:%s", UserId)
			local Response = APIFunctions.makeHTTPRequest(
				string.format("https://api.trello.com/1/cards?idList=%s&name=%s&desc=%s&key=%s&token=%s",
					mainTable.TrelloListIds.Ban, CardName, Reason, AppKey, Token
				),
				"POST"
			)
			table.insert(mainTable.TrelloCards.Ban, HttpService:JSONDecode(Response.Body))
		end
	end,
	["requestAuth"] = function(plr, message)
		local RF = Instance.new("RemoteFunction", mainTable.AuthFolder)
		RF.Name = require(Shared.Key)(100)
		mainTable.RemoteEvent:FireClient(plr, "handleAuthRequest", RF)
		task.wait(0.2)
		local Response = RF:InvokeClient(plr, message)
		repeat task.wait() until Response ~= nil
		APIEvents.authGave:Fire(plr, Response, message)
		return Response
	end,
	["removePlayerFromServer"] = function(plr, message)
		plr:Kick(string.format("[Rudimentary] %s", message))
	end,
	["changeCapeData"] = function(plr, data)
		mainTable.CapeData[plr.UserId] = data
		mainTable.DataStore:SetAsync(string.format("CapeData_%s",plr.UserId), data)
	end,
	["addToBanHistory"] = function(userId, data)
		local Key = string.format("BanHistory_%s", userId)
		local BanHistory = mainTable.DataStore:GetAsync(Key)
		if not BanHistory then
			mainTable.DataStore:SetAsync(Key, {data})
		else
			table.insert(BanHistory, 1, data)
			mainTable.DataStore:SetAsync(Key, BanHistory)
		end
	end,
	["setServerLock"] = function(isLocked)
		mainTable.ServerLocked = isLocked
	end,
	["enableShutdownMode"] = function()
		mainTable.ShutDown = true
	end,
	["addDebugLog"] = function(message: string)
		assert(typeof(message) == "string", "A Debug Log must be a string.")
		table.insert(mainTable.DebugLogs, message)
	end,
	["CSM"] = {
		["dispatchMessageToServers"] = function(message)
			MessagingService:PublishAsync("rudimentaryMessageDispatch", message)
		end,
	}
}

local function getTrelloData()
	if Settings.TrelloIntegrations and mainTable.HttpService then
		local suc = pcall(function()
			local BoardId, AppKey, Token = Settings.TrelloBoardId, Settings.TrelloAppKey, Settings.TrelloToken
			if BoardId and AppKey and Token then
				local BoardData = APIFunctions.makeHTTPRequest(
					string.format("https://api.trello.com/1/boards/%s/lists?key=%s&token=%s", BoardId, AppKey, Token)
				)
				BoardData = HttpService:JSONDecode(BoardData.Body)
				mainTable.TrelloCards.Ban = {}
				local Bans = {}
				for _, list in BoardData do
					if list.name:lower() == "bans" then
						mainTable.TrelloListIds.Ban = list.id
						local ListData = APIFunctions.makeHTTPRequest(
							string.format("https://api.trello.com/1/lists/%s/cards?key=%s&token=%s", list.id, AppKey, Token)
						)
						ListData = HttpService:JSONDecode(ListData.Body)
						for _, card in ListData do
							local Data = card.name:split(":")
							local UserId = tonumber(Data[2])
							Bans[UserId] = card.desc
							table.insert(mainTable.TrelloCards.Ban, card)
						end
					end
				end
				for id,data in Bans do
					local Reason = string.format("You've been Trello banned Reason: %s", if data:gsub(" ", ""):find("%w") == nil then "No reason provided." else data)
					for _, plr in Players:GetPlayers() do
						if plr.UserId == id then
							APIFunctions.removePlayerFromServer(plr, Reason)
						end
					end
					table.insert(mainTable.Bans, {
						UserId = id,
						Type = "Trello", 
						Reason = Reason
					})
				end
				for _, data in mainTable.Bans do
					if Bans[data.UserId] == nil and data.Type == "Trello" then
						APIFunctions.removeBan(data.UserId, "Trello")
					end
				end
			end
		end)
		if not suc then
			warn("Failed To Fetch Trello Data")
		end
	end
end

local function getLatestVersion()
	if mainTable.HttpService then
		local Information = HttpService:JSONDecode(APIFunctions.makeHTTPRequest("https://api.github.com/repos/TrizaCorporation/Rudimentary/releases/latest").Body)
		if mainTable.LatestVersion ~= Information.tag_name then
			mainTable.RemoteEvent:FireAllClients("changeData", "LatestVersion", Information.tag_name)
		end
		mainTable.LatestVersion = Information.tag_name
	end
end

local function makeSettingsData()
	local Data = {}
	for setting, val in Settings do
		table.insert(Data, {
			Name = setting, 
			IsStudioOnly = if table.find(NonEditableSettings, setting) then true else false, 
			Value = if not table.find(NonEditableSettings, setting) then val else nil,
			Type = if OptionsForSettings[setting] then "selectable" else if table.find(KeyCodeSettings, setting) then "keycode" else typeof(val),
			Options = OptionsForSettings[setting] or {}
		})
	end
	return Data
end

local function checkValidKey(plr, key)
	if not mainTable.Keys[plr.UserId] then repeat task.wait() until mainTable.Keys[plr.UserId] end
	return if table.find(mainTable.Keys[plr.UserId], key) then true else false
end

local function getAdminsInGame()
	local Admins = 0
	for _, user in Players:GetPlayers() do
		if (mainTable.Admins[user.UserId] or 0) >= 1 then
			Admins += 1
		end
	end
	return Admins
end

local function getAdminLevel(permissionsTable, player:Player)
	local adminLevel = mainTable.Admins[player.UserId] or 0
	local suc, err = pcall(function()
	assert(typeof(permissionsTable) == "table", "Permissions Table must be a table.")
		warn(string.format("Fetching Admin Level For: %s", player.Name))
		for _, permission in pairs(permissionsTable) do
			if permission.PermissionType == ">=" then
				if player:GetRankInGroup(permission.GroupId) >= permission.GroupRank then
					if permission.AdminLevel > adminLevel then
						adminLevel = permission.AdminLevel
					end
				end
			elseif permission.PermissionType == "<=" then
				if player:GetRankInGroup(permission.GroupId) <= permission.GroupRank then
					if permission.AdminLevel > adminLevel then
						adminLevel = permission.AdminLevel
					end
				end
			elseif permission.PermissionType == "==" then
				if player:GetRankInGroup(permission.GroupId) == permission.GroupRank then
					if permission.AdminLevel > adminLevel then
						adminLevel = permission.AdminLevel
					end
				end
			end
		end
	end)
	if suc then
		return adminLevel
	else
		task.wait(2)
		if not Players:FindFirstChild(player.Name) then
			return 0
		end
		--warn(err)
		--warn(string.format("An Error Occurred While Fetching Admin Level For %s, Retrying.", player.Name))
		return getAdminLevel(permissionsTable, player)
	end
end

local function makeEnv()
	local env = {
		["API"] = {},
	}
	env.Utils = Utils
	env.Shared = Shared
	env.ServerModules = Dependencies
	env.Assets = Assets
	for index, value in pairs(mainTable) do
		env[index] = value
	end
	for index, value in pairs(APIFunctions) do
		env.API[index] = value
	end
	for index, value in pairs(APIEvents) do
		env.API[index] = value
	end
	for index, value in pairs(Settings) do
		local hasblacklistedterms = false
		for _, term in BlacklistedSettingsTerms do
			if index:find(term) then
				hasblacklistedterms = true
			end
		end
		if not hasblacklistedterms then
			env[index] = value
		end
	end
	return env
end

local function executeCommand(plr, str)
	if str:sub(1,Settings.Prefix:len()) == Settings.Prefix or str:sub(1,Settings.SecondaryPrefix:len()) == Settings.SecondaryPrefix then
		local PrefixType = "MainPrefix"
		if str:sub(1,Settings.Prefix:len()) ~= Settings.Prefix then 
			PrefixType = "SecondaryPrefix"
		end
		local StartNum = if PrefixType == "MainPrefix" then Settings.Prefix:len() else Settings.SecondaryPrefix:len()
		local MsgNoPrefix = str:sub(StartNum + 1, str:len())
		local Data = MsgNoPrefix:split(" ")
		local Command = Data[1]:lower()
		local Args = {}
		local ArgsNoEdit = {}
		for i, item in pairs(Data) do
			if i ~= 1 then
				table.insert(Args, item)
				table.insert(ArgsNoEdit, item)
			end
		end
		--if not mainTable.Commands[Command] and not mainTable.Commands[mainTable.Aliases[Command]] then
			--mainTable.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Error", Title = "Error", Text = string.format("%s isn't a valid command.", Command)})
			--return 
		--end
		local Cmd = mainTable.Commands[Command] or mainTable.Commands[mainTable.Aliases[Command]]
		if not Cmd then return end
		if Settings.Prefix ~= Settings.SecondaryPrefix then
			if Cmd.Prefix ~= PrefixType then 
				mainTable.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Error", Title = "Prefix Error", Text = "Invalid prefix for command."})
				return
			end
		end
		if mainTable.Admins[plr.UserId] < Cmd.RequiredAdminLevel then
			mainTable.RemoteEvent:FireClient(plr, "displayNotification", {Type = "Error", Title = "Permissions Error", Text = string.format("You must be a(n) %s to run this command.", mainTable.AdminLevels[Cmd.RequiredAdminLevel])})
			return
		end
		APIEvents.commandRan:Fire(plr, Command, ArgsNoEdit)
		--[[local cmdRanArgs = {}
		for i, item in pairs(Data) do
			if i ~= 1 then
				table.insert(cmdRanArgs, item)
			end
		end
		]]
		if Cmd.ArgsToReplace then
			for i, arg in pairs(Args) do
				if not table.find(Cmd.ArgsToReplace, i) then
					continue
				end
				local argtab = arg:split(",")
				local newarg = {}
				for _, argval in pairs(argtab) do
					if argval:lower() == "me" then
						table.insert(newarg, plr)
					elseif argval:lower() == "all" then
						table.insert(newarg, Players:GetPlayers())
					elseif argval:lower() == "others" then
						local tab = {}
						for _, user in Players:GetPlayers() do
							if user ~= plr then
								table.insert(tab, user)
							end
						end
						table.insert(newarg, tab)
					elseif argval:lower() == "random" then
						local Plrs = Players:GetPlayers()
						table.insert(newarg, Plrs[math.random(1,#Plrs)])
					elseif argval:lower() == "admins" then
						for _, plr in Players:GetPlayers() do
							if (mainTable.Admins[plr.UserId] or 0) > 0 then
								table.insert(newarg, plr)
							end
						end
					elseif argval:lower() == "nonadmins" then
						for _, plr in Players:GetPlayers() do
							if (mainTable.Admins[plr.UserId] or 0) <= 0 then
								table.insert(newarg, plr)
							end
						end
					elseif argval:lower():sub(1,1) == "%" then
						local teamname = argval:lower():split("%")[2]
						for _, team in game.Teams:GetChildren() do
							if team.Name:lower():sub(1,teamname:len()) == teamname then
								table.insert(newarg, team:GetPlayers())
							end
						end
					else
						local foundUser = APIFunctions.findUser(tostring(argval))
						if foundUser then
							table.insert(newarg, foundUser)
						elseif argval ~= nil then
							table.insert(newarg, argval)
						end
					end
				end
				local nt = {}
				for i, _ in newarg do
					if typeof(newarg[i]) == "table" then
						for _, v in newarg[i] do
							table.insert(nt, v)
						end
					else
						table.insert(nt, newarg[i])
					end
				end
				Args[i] = nt
				--[[
				
				if not argtab[2] then
					if arg:lower() == "me" then
						Args[i] = plr
					elseif arg:lower() == "all" then
						Args[i] = Players:GetPlayers()
					elseif arg:lower() == "others" then
						local tab = {}
						for _, user in Players:GetPlayers() do
							if user ~= plr then
								table.insert(tab, user)
							end
						end
						Args[i] = tab
					else
						Args[i] = tostring(arg)
					end
				else
					local newarg = {}
					for _, argval in pairs(argtab) do
						if argval:lower() == "me" then
							table.insert(newarg, plr)
						elseif argval:lower() == "all" then
							table.insert(newarg, Players:GetPlayers())
						elseif argval:lower() == "others" then
							local tab = {}
							for _, user in Players:GetPlayers() do
								if user ~= plr then
									table.insert(tab, user)
								end
							end
							table.insert(newarg, tab)
						else
							table.insert(newarg, tostring(argval))
						end
					end
					Args[1] = newarg
				end
				]]
			end
		end
		local suc, res = pcall(Cmd.Handler, makeEnv(), plr, Args, Command)
		table.insert(mainTable.Logs, 1, string.format("[{time:%s:ampm}] %s: %s", os.time(), plr.Name, Chat:FilterStringForBroadcast(str, plr)))
		if not suc then
			mainTable.RemoteEvent:FireClient(plr, "displayMessage", {Title = "Error", Text = string.format("An Error Has Occurred:\n%s", res)})
			mainTable.RemoteEvent:FireClient(plr, "playSound", "Error")
		end
	end
end

local function manageKeys(player)
	mainTable.Keys[player.UserId] = {}
	local FirstKey = KeyModule(100)
	mainTable.RemoteEvent:FireClient(player, "changeKey", FirstKey)
	table.insert(mainTable.Keys[player.UserId], FirstKey)
	--local OldKey = nil
	repeat
		task.wait(math.random(1,10))
		--[[
			if OldKey then
				task.wait(2)
				if mainTable.Keys[player.UserId] then
					for i,key in mainTable.Keys[player.UserId] do
						if key == OldKey then
							table.remove(mainTable.Keys[player.UserId], i)
						end
					end
				end
			end
			]]
		--OldKey = Key
		--local Remote = Instance.new("RemoteEvent", ReplicatedStorage:WaitForChild("Rudimentary"))
		--local RemoteName = KeyModule(100)
		--Remote.Name = RemoteName
		mainTable.RemoteEvent:FireClient(player, "checkKeyValidity")
		local Request = AuthRequest.new(player)
		table.insert(AuthRequests, Request)

		local SentKey
		local Connection = Request.KeySend:Connect(function(key)
			SentKey = key
		end)
		--[[
		local Connection = Remote.OnServerEvent:Connect(function(respondingplr, key)
			if respondingplr == player then
				if checkValidKey(respondingplr, key) then
					Responded = true
					task.spawn(function()
						pcall(function()
							task.wait(2)
							if mainTable.Keys[respondingplr.UserId] then
								table.remove(mainTable.Keys[respondingplr.UserId], table.find(mainTable.Keys[respondingplr.UserId]))
							end
						end)
					end)
				--else
				--	APIFunctions.removePlayerFromServer(respondingplr, "An Error Occurred During The Key Exchange Process.\nPlease contact a T:Riza Customer Support member.")
				end
			end
		end)
		]]
		local Start = tick()
		repeat task.wait() until SentKey or tick() - Start >= 15
		if not checkValidKey(player, SentKey) then
			mainTable.Keys[player] = {}
			return
		end
		task.spawn(function()
			pcall(function()
				task.wait(2)
				if mainTable.Keys[player.UserId] then
					table.remove(mainTable.Keys[player.UserId], table.find(mainTable.Keys[player.UserId], SentKey))
				end
			end)
		end)
		Connection:Disconnect()
		--Remote:Destroy()
		if tick() - Start >= 15 then
			--APIFunctions.removePlayerFromServer(player, "Client Failed To Respond To Rudimentary Key Management System")
			mainTable.Keys[player] = {}
			return
		end
		local NewKey = KeyModule(100)
		mainTable.RemoteEvent:FireClient(player, "changeKey", NewKey)
		table.insert(mainTable.Keys[player.UserId], NewKey)
	until not Players:FindFirstChild(player.Name)
end

local function renderCapeForUser(player)
	local CapeData = mainTable.CapeData[player.UserId]
	local Torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
	local isR15 = if Torso.Name == "UpperTorso" then true else false
	local Cape = Instance.new("Part")
	Cape.Name = "RudimentaryCape"
	Cape.Size = Vector3.new(2.645, 4.493, 0.031)
	Cape.Position = Torso.Position - (Torso.CFrame.LookVector * 2)
	Cape.Anchored = false
	Cape.CanCollide = false
	Cape.Parent = player.Character
	local Decal = Instance.new("Decal")
	Decal.Face = Enum.NormalId.Back
	Decal.Parent = Cape
	local Motor = Instance.new("Motor")
	Motor.Name = "RudimentaryCapeMotor"
	Motor.Part0 = Cape
	Motor.Part1 = Torso
	Motor.MaxVelocity = .1
	Motor.Parent = Cape
	Motor.C0 = CFrame.new(0,2.1,0)*CFrame.Angles(0,math.rad(90),0)+Vector3.new(0,0.2,0)
	Motor.C1 = CFrame.new(0,1-((isR15 and 0.2) or 0),(Torso.Size.Z/2))*CFrame.Angles(0,math.rad(90),0)
	Cape.Color = BrickColor.new(CapeData.Color).Color
	Cape.Material = CapeData.Texture
	Cape.Decal.Texture = CapeData.Decal
end

local function handlePlayer(player)
	task.spawn(function()
		local Start = tick()
		local maxtime = if game:GetService("RunService"):IsStudio() then 3 else 200
		repeat task.wait() until StartedClients[player] or (tick() - Start) > maxtime
		task.spawn(function()
			task.wait(1)
			if not player.PlayerGui:FindFirstChild("RudimentaryUi") then
				local Clone = script.Parent.RudimentaryUi:Clone()
				Clone.Parent = player.PlayerGui
			end
		end)
		if (tick() - Start) <= maxtime then
			warn(string.format("%s's Client Started In %s Second(s)", player.Name, tick() - Start))
		else
			StartedClients[player] = true
			warn(string.format("Performing A Manual Client Start For %s", player.Name))
			script.Parent.Client.ClientLoader:Clone().Parent = player.PlayerGui:WaitForChild("RudimentaryUi")
		end
		local Ban = nil
		for _, banData in mainTable.Bans do
			if banData.UserId == player.UserId then
				if banData.Type == "Time" then
					if os.time() >= banData.UnbanTime then
						APIFunctions.CSM.dispatchMessageToServers({request = "removeBan", userId = player.UserId, type = "Time"})
						local TimeBans = mainTable.DataStore:GetAsync("TimeBans")
						for i, bd in TimeBans do
							if bd.UserId == player.UserId then
								table.remove(TimeBans, i)
							end
						end
						mainTable.DataStore:SetAsync("TimeBans", TimeBans)
					else
						Ban = banData
					end
				else
					Ban = banData
				end
			end
		end
		if Ban then
		    APIFunctions.removePlayerFromServer(player, Ban.Reason)
			return
		end
		if mainTable.ShutDown then
			APIFunctions.removePlayerFromServer(player, "This server has been shutdown.")
 			return
		end
		if not mainTable.DataStore:GetAsync(string.format("BanHistory_%s", player.UserId)) then
			mainTable.DataStore:SetAsync(string.format("BanHistory_%s", player.UserId), {})
		end
		if not mainTable.DataStore:GetAsync(string.format("Warnings_%s", player.UserId)) then
			mainTable.DataStore:SetAsync(string.format("Warnings_%s", player.UserId), {})
		end
		local CapeData = mainTable.DataStore:GetAsync(string.format("CapeData_%s",player.UserId))
		if CapeData then
			mainTable.CapeData[player.UserId] = CapeData
		end
		mainTable.ClientLogs[player.UserId] = {}
		local adminLevel = getAdminLevel(mainTable.GroupConfig, player)
		if not mainTable.Admins[player.UserId] or (mainTable.Admins[player.UserId] and adminLevel > mainTable.Admins[player.UserId]) then
			mainTable.Admins[player.UserId] = adminLevel
		end
		--warn(string.format("Admin Level For %s Is: %s", player.Name, mainTable.Admins[player.UserId]))
		if adminLevel <= 0 and mainTable.ServerLocked then
			APIFunctions.removePlayerFromServer(player, "This Server Is Locked.")
		end
		task.spawn(function()
			task.wait(0.5)
			if adminLevel >= 1 then
				mainTable.RemoteEvent:FireClient(player, "displayNotification", {Type = "Alert", Text = string.format("You're a(n) %s!", mainTable.AdminLevels[mainTable.Admins[player.UserId]]), SecondaryText = "Click for Commands", ExtraData = {MethodAfterClick = "getCommands", InstanceToCreate = "List", InstanceData = {Title = "Commands"}}})
				mainTable.RemoteEvent:FireAllClients("changeData", "InGameAdmins", getAdminsInGame())
			end
			if not table.find(mainTable.Donors, player.UserId) and MarketPlaceService:PlayerOwnsAsset(player, mainTable.DonorShirt) then
				mainTable.RemoteEvent:FireClient(player, "displayNotification", {
					Type = "Info", 
					Title = "Donor Perks",
					Text = "You're A Donor", 
					SecondaryText = "Click to open the panel",
					ExtraData = {
						ClientFunctionToRun = "MakeDonorPanel", 
					}
				})
				table.insert(mainTable.Donors, player.UserId)
			end
		end)
		player.Chatted:Connect(function(msg)
			table.insert(mainTable.ChatLogs, 1, string.format("[{time:%s:ampm}] %s: %s", os.time(), player.Name, Chat:FilterStringForBroadcast(msg, player)))
			executeCommand(player, msg)
		end)
		task.spawn(function()
			manageKeys(player)
		end)
		if player.Character then
			if mainTable.CapeData[player.UserId] and mainTable.CapeData[player.UserId].Equipped then
				renderCapeForUser(player)
			end
		end
		player.CharacterAdded:Connect(function()
			if mainTable.CapeData[player.UserId] and mainTable.CapeData[player.UserId].Equipped then
				renderCapeForUser(player)
			end
		end)
	end)
end

local function setupAdmin(Config, Requirer)
	if _G.RudimentaryStarted then
		warn("Rudimentary Can Not Be Started Twice.")
		return
	end
	if Requirer.Parent ~= ServerScriptService then
		if Requirer.Parent:IsA("Model") then
			local oldParent = Requirer.Parent
			oldParent:Destroy()
		end
		Requirer.Parent = ServerScriptService
	end
	local Start = tick()
	script.Parent.Client.ClientLoader:Clone().Parent = game.StarterPlayer.StarterPlayerScripts
	script.Parent.RudimentaryUi:Clone().Parent = StarterGui
	mainTable.DataStore = DataStoreEngine.new(Config.DataStoreName or Settings.DataStoreName,"Regular")
	local Folder = Instance.new("Folder", ReplicatedStorage)
	Folder.Name = "Rudimentary"
	local RE = Instance.new("RemoteEvent", Folder)
	RE.Name = "RudimentaryRemoteEvent"
	mainTable.RemoteEvent = RE
	local RF = Instance.new("RemoteFunction", Folder)
	RF.Name = "RudimentaryRemoteFunction"
	mainTable.RemoteFunction = RF
	local RWA = Instance.new("Folder", workspace)
	RWA.Name = "RudimentaryWorkspaceAssets"
	mainTable.RWA = RWA
	local AuthFolder = Instance.new("Folder", Folder)
	AuthFolder.Name = "AuthFolder"
	mainTable.AuthFolder = AuthFolder
	Shared.Parent = Folder
	local TNetServer = TNet.new()

	--script.Client:Clone().Parent = script.RudimentaryClient
	--script.Sounds:Clone().Parent = script.RudimentaryClient
	for index, item in pairs (Config.GroupConfig) do
		if item.AdminLevel == math.huge then
			Config.GroupConfig[index].AdminLevel = 5
		end
	end
	
	mainTable.GroupConfig = Config.GroupConfig

	for _, player:Player in Players:GetPlayers() do
		task.spawn(function()
			repeat task.wait() until _G.RudimentaryStarted
			task.wait(if RunService:IsStudio() then 0 else 10)
			if not StartedClients[player] then
				handlePlayer(player)
			end
		end)
	end
	
	task.spawn(function()
		local ownerId = nil
		if game.CreatorType == Enum.CreatorType.Group then
			local groupInfo = GroupService:GetGroupInfoAsync(game.CreatorId)
			if groupInfo.Owner then
				ownerId = groupInfo.Owner.Id
			end
		else
			ownerId = game.CreatorId
		end
		if (mainTable.Admins[ownerId] or 0) < 5 then
			mainTable.Admins[ownerId] = 5
		end
	end)
	
	game.Players.PlayerAdded:Connect(handlePlayer)

	game.Players.PlayerRemoving:Connect(function(plr)
		StartedClients[plr] = false
		mainTable.Keys[plr.UserId] = nil
		mainTable.RemoteEvent:FireAllClients("changeData", "InGameAdmins", getAdminsInGame())
	end)
	
	if not mainTable.DataStore:GetAsync("SavedAdmins") then
		mainTable.DataStore:SetAsync("SavedAdmins", {})
	end
	
	if not mainTable.DataStore:GetAsync("PermanentBans") then
		mainTable.DataStore:SetAsync("PermanentBans", {})
	end

	if not mainTable.DataStore:GetAsync("TimeBans") then
		mainTable.DataStore:SetAsync("TimeBans", {})
	end
	
	task.spawn(function()
		task.wait(0.4)
		for userid, lvl in mainTable.DataStore:GetAsync("SavedAdmins") do
			mainTable.Admins[tonumber(userid)] = lvl
		end
		
		for _, bandata in mainTable.DataStore:GetAsync("PermanentBans") do
			 table.insert(mainTable.Bans, {Type = "Perm", Reason = bandata.Reason, UserId = tonumber(bandata.UserId)})
		end

		for _, bandata in mainTable.DataStore:GetAsync("TimeBans") do
			table.insert(mainTable.Bans, {Type = "Time", Reason = bandata.Reason, UserId = tonumber(bandata.UserId), UnbanTime = tonumber(bandata.UnbanTime)})
		end
	end)
	
	for index, value in pairs(Config) do
		task.spawn(function()
			if table.find(ValidSettings, index) then
				Settings[index] = value
				if not table.find(NonEditableSettings, index) then 
					task.spawn(function()
						if mainTable.DataStore:GetAsync(index) == nil then
							warn(string.format("Saving Data For Setting %s", index))
							local res = mainTable.DataStore:SetAsync(index, value)
							res:Connect(function(saved) 
								if saved then
									warn(string.format("Data Saved For Setting %s\nValue: %s", index,tostring(mainTable.DataStore:GetAsync(index))))
								else
									warn(string.format("An Error Occurred While Saving Data For Setting %s", index))
								end
							end)
							Settings[index] = value
						else
							Settings[index] = mainTable.DataStore:GetAsync(index)
						end
					end)
				end
			elseif not table.find(ValidSettingsExceptions, index) then
				warn(string.format("%s isn't a valid setting.", tostring(index)))
			end
		end)
	end
	
	if Config.DisableAdminCreators then
		for user, lvl in mainTable.Admins do
			if lvl == math.huge then
				mainTable.Admins[user] = nil
			end
		end
	end
		
	for uid, adminlevel in pairs (Config.Admins) do
		if adminlevel == math.huge then
			adminlevel = 5
		end
		mainTable.Admins[uid] = adminlevel
	end
	
	if Config.CustomAdminLevels then
		for level, name in Config.CustomAdminLevels do
			if typeof(level) == "number" then
				if level ~= math.huge then
					mainTable.AdminLevels[level] = tostring(name)
				else
					warn("Can't Set Admin Level To math.huge")
				end
			else
				warn("Admin Level Must Be A Number.")
			end
		end
	end
	
	local Id = require(Shared.Key)(35)
	mainTable.RudimentaryServerId = Id
	warn(string.format("Rudimentary Server Id: %s", Id))
	warn(string.format("HttpService Enabled: %s", tostring(mainTable.HttpService)))
	if mainTable.HttpService then
		local suc, result = pcall(function()
			local Data = HttpService:JSONDecode(HttpService:GetAsync("http://ip-api.com/json"))
			return string.format("%s / %s", Data.country, Data.regionName)
		end)
		if suc then
			mainTable.ServerRegion = result
		else
			mainTable.ServerRegion = "Error"
		end
	else
		mainTable.ServerRegion = "HttpService not Enabled"
	end
	
	task.spawn(function()
		while true do
			getTrelloData()
			getLatestVersion()
			task.wait(60)
		end
	end)
	
	warn("Requiring Commands.")
	for _, Command:ModuleScript in pairs(script.Parent.Commands:GetDescendants()) do
		if Command:IsA("ModuleScript") then
			local suc, err = pcall(function()
				if not table.find(Settings.DisabledCommandTypes, Command.Parent.Name) then
					local CommandData = Utils.CloneTableDeep(require(Command))
					CommandData.Type = Command.Parent.Name
					mainTable.Commands[CommandData.Name] = CommandData
					for _, Alias in pairs(CommandData.Aliases or {}) do
						mainTable.Aliases[Alias] = CommandData.Name
					end
				end
			end)
			if not suc then warn(string.format("Command %s could not be required.", Command.Name)) end
		end
	end
	
	warn("Configuring Command Levels.")
	if Config.CommandLevels then
		for command, level in Config.CommandLevels do
			if mainTable.Commands[command] then
				mainTable.Commands[command].RequiredAdminLevel = level
			end
		end
	end
		
	warn("Loading Themes.")
	if Requirer:FindFirstChild("Themes") and #Requirer.Themes:GetChildren() > 0 then
		for _, theme in Requirer.Themes:GetChildren() do
			theme:Clone().Parent = script.Parent.Themes
		end
	end
	for _, theme in script.Parent.Themes:GetChildren() do
		theme:Clone().Parent = StarterGui:WaitForChild("RudimentaryUi").Assets
		for _, plr in Players:GetPlayers() do
			task.spawn(function()
				local RudimentaryUi = plr.PlayerGui:FindFirstChild("RudimentaryUi")
				if not RudimentaryUi then
					RudimentaryUi = plr.PlayerGui:WaitForChild("RudimentaryUi", 100)
				end
				if not RudimentaryUi.Assets:FindFirstChild(theme.Name) then
					theme:Clone().Parent = RudimentaryUi.Assets
				end
			end)
		end
	end
	for _, item in script.Parent.Themes:GetChildren() do
		table.insert(OptionsForSettings.Theme, item.Name)
	end
	
	if Requirer:FindFirstChild("Plugins") and #Requirer.Plugins:GetChildren() > 0 then
		warn("Loading Plugins.")
		for _, plugin in Requirer.Plugins:GetChildren() do
			if plugin:IsA("ModuleScript") then
				task.spawn(function()
					local plugindata = require(plugin)
					local PluginStart = tick()
					local suc = pcall(function()
						if plugindata.Type == "Command" then
							local CommandData = Utils.CloneTableDeep(plugindata)
							CommandData.Type = "Plugin"
							mainTable.Commands[plugindata.Name] = CommandData
							for _, alias in plugindata.Aliases or {} do
								mainTable.Aliases[alias] = CommandData.Name
							end
						elseif plugindata.Type == "Startup" then
							plugindata.Handler(makeEnv())
						end
					end)
					if suc then
						warn(string.format("Loaded Plugin %s in %s second(s).", plugindata.Name, tick() - PluginStart))
					else
						warn(string.format("Plugin %s failed in %s second(s).", plugindata.Name, tick() - PluginStart))
					end
				end)
			end
		end
	end
	
	local opsuc = pcall(function()
		MessagingService:SubscribeAsync("rudimentaryMessageDispatch", function(message)
			local Data = message.Data
			if Data.request == "makeGameMessage" then
				mainTable.RemoteEvent:FireAllClients("displayMessage", {Title = string.format("Game Message from %s", Data.sender), Text = Data.text})
			elseif Data.request == "changeSetting" then
				Settings[Data.settingName] = Data.newValue
				mainTable.RemoteEvent:FireAllClients("changeData", Data.settingName, Data.newValue)
			elseif Data.request == "changeUserAdminLevel" then
				mainTable.Admins[Data.userId] = Data.adminLevel
				local player = Players:GetPlayerByUserId(Data.userId)
				if player then
					mainTable.RemoteEvent:FireClient(player, "changeData", "AdminLevel", Data.adminLevel)
					if Data.adminLevel > 0 then
						mainTable.RemoteEvent:FireClient(player, "displayNotification", {
							Type = "Alert", 
							Text = string.format("You're a(n) %s!", mainTable.AdminLevels[mainTable.Admins[player.UserId]]), 
							SecondaryText = "Click for Commands", 
							ExtraData = {
								MethodAfterClick = "getCommands", 
								InstanceToCreate = "List", 
								InstanceData = {
									Title = "Commands"
								}
							}
						})
					end
				end
			elseif Data.request == "addBan" then
				local Type = Data.type
				local UserId = Data.userId
				local Reason = Data.reason
				local UnbanTime = Data.unbanTime
				APIFunctions.addUserToBans(UserId, {Type = Type, Reason = Reason, UnbanTime = UnbanTime})
			elseif Data.request == "removeBan" then
				local Type = Data.type
				local UserId = Data.userId
				APIFunctions.removeBan(UserId, Type)
			elseif Data.request == "addPermanentBan" then
				APIFunctions.addUserToBans(Data.userId, {Type = "Perm", Reason = Data.reason})
			elseif Data.request == "removePermanentBan" then
				APIFunctions.removeBan(Data.userId, "Perm")
			elseif Data.request == "addTimeBan" then
				APIFunctions.addUserToBans(Data.userId, {Type = "Time", Reason = Data.reason, UnbanTime = Data.unbanTime})
			elseif Data.request == "removeTimeBan" then
				APIFunctions.removeBan(Data.userId, "Time")
			end
		end)
	end)
	if not opsuc then
		warn("MessagingService failed to connect, cross server utilities are unavailable.")
	end
	
	_G.RudimentaryStarted = true
	warn(string.format("Rudimentary Started In %s Second(s)", tick() - Start))

	local RemoteEventHandler = TNetServer:HandleRemoteEvent(RE)
	local RemoteFunctionHandler = TNetServer:HandleRemoteFunction(RF)

	RemoteEventHandler.Middleware = {
		RequestsPerMinute = 100
	}
	
	RemoteEventHandler:Connect(function(plr, req, ...)
		local Data = {...}
		if req == "execute" then
			executeCommand(plr, Data[1])		
		elseif req == "signifyClientStart" then
			if not StartedClients[plr] then
				StartedClients[plr] = true
			end
		elseif req == "sendClientLog" then
			local Key = Data[2]
			if checkValidKey(plr, Key) then
				table.insert(mainTable.ClientLogs[plr.UserId], 1, string.format("[{time:%s:ampm}] %s", os.time(), Data[1]))
			end
		elseif req == "completeAuthRequest" then
			for _, authRequest in AuthRequests do
				if authRequest.Player == plr then
					authRequest.KeySend:Fire(Data[1])
				end
			end
		end
	end)
	
	
	RemoteFunctionHandler:Connect(function(plr, req, ...)
		local Data = {...}
		if req == "fetchData" then
			local ClonedTable = makeEnv()
			ClonedTable["RudimentaryServerId"] = nil
			ClonedTable["RemoteEvent"] = nil
			ClonedTable["RemoteFunction"] = nil
			ClonedTable["GroupConfig"] = nil
			ClonedTable["API"] = nil
			ClonedTable["DataStore"] = nil
			if not mainTable.Admins[plr.UserId] then
				repeat task.wait() until mainTable.Admins[plr.UserId]
			end
			if mainTable.Admins[plr.UserId] < 1 then
				ClonedTable["Admins"] = {}
			end
			ClonedTable["AdminLevel"] = mainTable.Admins[plr.UserId] or 0
			ClonedTable["InGameAdmins"] = getAdminsInGame()
			ClonedTable["AdminLevelName"] = mainTable.AdminLevels[mainTable.Admins[plr.UserId]] or "Error"
			return ClonedTable
		elseif req == "getAllAccessableCommandData" then
			local CommandData = {}
			for _, command in pairs(mainTable.Commands) do
				if (mainTable.Admins[plr.UserId] or 0) >= command.RequiredAdminLevel then
					table.insert(CommandData, command)
				end
			end
			return CommandData
		elseif req == "getCommands" then
			local CommandData = {}
			for _, command in pairs(mainTable.Commands) do
				if (mainTable.Admins[plr.UserId] or 0) >= command.RequiredAdminLevel then
					table.insert(CommandData, {Data = string.format("%s%s <font face = \"Gotham\">(%s)</font>", 
						if command.Prefix == "MainPrefix" then Settings.Prefix else Settings.SecondaryPrefix, 
						command.Name, 
						command.Description
						),ExtraData = string.format("Permission Level: <font face = \"Gotham\">%s+</font>\nAliases: <font face = \"Gotham\">:%s</font>", mainTable.AdminLevels[command.RequiredAdminLevel], table.concat(command.Aliases, ", "))}
					)
				end
			end
			return CommandData
		elseif req == "getAdmins" then
			if mainTable.Admins[plr.UserId] >= mainTable.Commands.admins.RequiredAdminLevel then
				local AdminData = {}
				for uid, level in pairs(mainTable.Admins) do
					local suc, err = pcall(function()
						if level >= 1 then
					     	local Name = Players:GetNameFromUserIdAsync(uid)
							local AdminLevel = mainTable.AdminLevels[level]
							table.insert(AdminData, string.format("%s <font face = \"Gotham\">(%s)</font>",Name,AdminLevel))
						end
					end)
				end
				return AdminData
			else
				return {}
			end
		elseif req == "getBans" then
			if mainTable.Admins[plr.UserId] and mainTable.Admins[plr.UserId] >= mainTable.Commands.bans.RequiredAdminLevel then
				local BanData = {}
				for _, data in pairs(mainTable.Bans) do
					local suc, err = pcall(function()
						local Name = Players:GetNameFromUserIdAsync(data.UserId)
						table.insert(BanData, {
							Data = string.format("%s <font face = \"Gotham\">(%s)</font>",Name,data.UserId),
							ExtraData = string.format("Type: %s", data.Type)
						})
					end)
				end
				return BanData
			else
				return {}
			end
		elseif req == "getLogs" then
			if mainTable.Admins[plr.UserId] >= 1 then
				local LogsToSend = {}
				for i,data in mainTable.Logs do
					if i <= 1500 then
						table.insert(LogsToSend, {Data = data, Clickable = true})
					end
				end
				return LogsToSend
			else
				return {}
			end
		elseif req == "getChatLogs" then
			if mainTable.Admins[plr.UserId] >= 1 then
				local ChatLogsToSend = {}
				for i,data in mainTable.ChatLogs do
					if i <= 1500 then
						table.insert(ChatLogsToSend, data)
					end
				end
				return ChatLogsToSend
			else
				return {}
			end
		elseif req == "getGameTime" then
			return workspace.DistributedGameTime
		elseif req == "getSettings" then
			if mainTable.Admins[plr.UserId] >= Settings.RequiredLevelForSettings then
				return makeSettingsData()
			else
				return {}
			end
		elseif req == "sendPrivateMessage" then
			local Recipient = Data[1]
			local Message = Data[2]
			local RecipientUser = Players:FindFirstChild(Recipient)
			if checkValidKey(plr, Data[3]) then
				if RecipientUser then
					local suc = pcall(function()
						local FilteredMessage = Chat:FilterStringForBroadcast(Message, plr)
						mainTable.RemoteEvent:FireClient(RecipientUser, "displayNotification", {
							Type = "Info", 
							Text = "Private Message From:", 
							SecondaryText = plr.Name, 
							ExtraData = {
								InstanceToCreate = "PrivateMessage", 
								InstanceData = {
									Title = string.format("Private Message From: %s", plr.Name),
									Text = FilteredMessage,
									Sender = plr.Name,
									CanRespond = true
								}
							}
						})
					end)
					if suc then
						return true
					else
						return "Message Filtering Failed."
					end
				else
					return string.format("%s isn't in this server.", Recipient)
				end
			else
				return "A Fatal Error Has Occurred."
			end
		elseif req == "changeSetting" then
			local Setting, Value, Key = Data[1], Data[2], Data[3]
			if checkValidKey(plr, Key) and mainTable.Admins[plr.UserId] >= Settings.RequiredLevelForSettings then
				Settings[Setting] = Value
				local suc, err = pcall(function()
					mainTable.DataStore:SetAsync(Setting, Value)
					APIFunctions.CSM.dispatchMessageToServers({request = "changeSetting", settingName = Setting, newValue = Value})
				end)
				return suc
			end
		elseif ServerFunctions[req] then
			local suc, res = pcall(ServerFunctions[req], plr, makeEnv(), ...)
			if suc then return res else warn(string.format("An Error Occurred While Running A Server Function\nFunction: %s\nError: %s", req, res)) return "Error" end
		end
	end)
end

return setupAdmin