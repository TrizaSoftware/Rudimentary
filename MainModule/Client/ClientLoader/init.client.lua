if _G.RudimentaryClientStarted then
	script:Destroy()
end

local Plr = game.Players.LocalPlayer
local Mouse = Plr:GetMouse()
local Start = tick()
local MarketPlaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")
local Players = game:GetService("Players")
local RudimentaryFolder = ReplicatedStorage:WaitForChild("Rudimentary") :: Folder
local RemoteEvent = RudimentaryFolder:WaitForChild("RudimentaryRemoteEvent") :: RemoteEvent

RemoteEvent:FireServer("signifyClientStart")

local RemoteFunction = RudimentaryFolder:WaitForChild("RudimentaryRemoteFunction") :: RemoteFunction
local SharedAssets = RudimentaryFolder:WaitForChild("Shared")
local Dependencies = script:WaitForChild("Dependencies")
local ValidInterfaceModules = {
	"Window",
	"List"
}
local LockedPanels = {

}

local Signal = require(SharedAssets:WaitForChild("Signal"))
local Sounds = script:WaitForChild("Sounds")
local Utils = require(SharedAssets.Utils)
local UserAvatar = Players:GetUserThumbnailAsync(Plr.UserId, Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
local Key = nil
local GameInfo 

local ClientFunctions = require(Dependencies.Functions)
local FaderModule = require(Dependencies.Fader)
local StringFormatter = require(Dependencies.StringFormatter)
local DraggerModule = require(Dependencies.Dragger)
local Snackbar = require(Dependencies.Snackbar)
local PromptMaker = require(Dependencies.Prompt)
local Icons = require(Dependencies.MaterialIcons)
local DropdownMenu = require(Dependencies.DropdownMenu)
--local NotificationQueue = {}
local MainInterfaceFaders = {}
local SelectedInterface = "General"
local MainInterfaceOpen = false
local CanSwitchPanels = true
local _warn = warn
local function warn(...)
	_warn("[Rudimentary Client]:",...)
end

_G.RudimentaryClientStarted = true

local Data = RemoteFunction:InvokeServer("fetchData")
local Settings = RemoteFunction:InvokeServer("getSettings")
local Client = {}
Client.MainInterfaceHolder = Plr.PlayerGui:WaitForChild("RudimentaryUi") :: ScreenGui
Client.Utils = Utils
Client.Shared = SharedAssets
Client.RemoteEvent = RemoteEvent
Client.RemoteFunction = RemoteFunction
Client.UI = {
	["Theme"] = Data.Theme,
	["Make"] = function(itemType, ...)
		if table.find(ValidInterfaceModules, itemType) then
			local Module = require(Dependencies:WaitForChild(itemType))
			local suc, res = pcall(Module.new,Client,...)
			if not suc then
				warn(res)
			end
			return res
		end
	end,
	["GetFolderForElement"] = function(element)
		return if Client.MainInterfaceHolder.Assets[Data.Theme]:FindFirstChild(element) then Data.Theme else "Default"
	end,
}
local MainInterface = Client.MainInterfaceHolder:WaitForChild("Main UI") :: Frame
local RudimentaryIcon = Client.MainInterfaceHolder:WaitForChild("RudimentaryIcon")
local NotificationFrame = Client.MainInterfaceHolder:WaitForChild("Notifications")
local InterfaceFader = FaderModule.new(MainInterface)
local InterfaceDragger = DraggerModule.new(MainInterface)
task.spawn(function()
	GameInfo = MarketPlaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
	MainInterface.General.Holder.GameName.Text = string.format("Name: %s", GameInfo.Name)
end)

warn(string.format("Started in %s second(s).", tick() - Start))

task.spawn(function()
	while true do
		MainInterface.General.Holder.ServerUptime.Text = string.format("Server Uptime: %s",Utils.formatTimeFromSeconds(RemoteFunction:InvokeServer("getGameTime")))
		task.wait()
	end
end)

task.spawn(function()
	local ThemeFolder = Client.MainInterfaceHolder.Assets[Data.Theme]
	Client.MainInterfaceHolder.HoverData.BackgroundColor3 = if ThemeFolder:FindFirstChild("HoverDataColor") then ThemeFolder.HoverDataColor.Value else Color3.fromRGB(30,30,30)
end)

RudimentaryIcon.MouseButton1Click:Connect(function()
	if not MainInterfaceOpen then
		InterfaceFader:fadeIn(1)
		for ui, item in pairs(MainInterfaceFaders) do
			if ui ~= SelectedInterface then
				item:fadeOut(0)
			end
		end
	else
		InterfaceFader:fadeOut(1)
	end
	MainInterfaceOpen = not MainInterfaceOpen
end)

--[[
local function makeListItem(pos, itemData, list)
	local self = {}
	self.MouseEntered = Signal.new()
	self.MouseLeave = Signal.new()
	local listElemClone = Client.MainInterfaceHolder.Assets.Default.ListElementTemplate:Clone()
	local ElementFader = FaderModule.new(listElemClone)
	listElemClone.Name = pos
	self.Item = listElemClone
	if not itemData.Data then
		itemData = StringFormatter.formatString(itemData)
	else
		itemData.Data = StringFormatter.formatString(itemData.Data)
	end
	if typeof(itemData) == "string" then
		listElemClone.Name = Utils.shortenText(Utils.filterOutRichTextData(itemData), 30)
		listElemClone.Text.Text = Utils.shortenText(Utils.filterOutRichTextData(itemData), 30)
	else
		listElemClone.Name = Utils.shortenText(Utils.filterOutRichTextData(itemData.Data), 30)
		listElemClone.Text.Text = Utils.shortenText(Utils.filterOutRichTextData(itemData.Data), 30)
	end
	self.Fader = ElementFader
	ElementFader:fadeOut(0.1)
	ElementFader.FadeOutCompleted:Wait()
	listElemClone.Parent = list.ScrollingFrame
	task.spawn(function()
		repeat task.wait(0.1) until listElemClone.Parent == list.ScrollingFrame
		ElementFader:fadeIn(1)
		list.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,list.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y + 10)
	end)
	listElemClone.MouseEnter:Connect(function()
		self.MouseEntered:Fire()
		if typeof(itemData) == "string" then
			Client.MainInterfaceHolder.HoverData.Text = itemData
		else
			Client.MainInterfaceHolder.HoverData.Text = string.format("%s\n%s",itemData.Data,itemData.ExtraData)
		end
	end)
	listElemClone.MouseLeave:Connect(function()
		self.MouseLeave:Fire()
	end)
	return self
end

local function makeList(ListData)
	local AllowSearch = ListData.AllowSearch
	local AllowRefresh = ListData.AllowRefresh
	local AutoRefresh = ListData.AutoRefresh
	local AutoRefreshSeconds = ListData.AutoRefreshSeconds
	local ListItems = ListData.Items
	local Title = ListData.Title
	local ListClone = Client.MainInterfaceHolder.Assets.Default.ListTemplate:Clone()
	local ItemFrames = {}
	ListClone.Parent = Client.MainInterfaceHolder
	local ListFader = FaderModule.new(ListClone)
	local ListDragger = DraggerModule.new(ListClone)
	local Clicked = false
	local Refreshing = false
	local Searching = false
	ListFader:fadeOut()
	ListFader.FadeOutCompleted:Wait()
	ListFader:fadeIn(1)
	ListClone.Topbar.Listname.Text = Utils.shortenText(Title, 20)
	if AllowSearch then
		ListClone.Topbar.Search.Visible = true
	end
	if AllowRefresh then
		ListClone.Topbar.Refresh.Visible = true
	end
	if #ListItems == 0 then
		TweenService:Create(ListClone.NoData, TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
		ListClone.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
	end
	ListClone.Topbar.Search.MouseButton1Click:Connect(function()
		Searching = not Searching
		ListClone.Topbar.Listname.Visible = not ListClone.Topbar.Listname.Visible
		ListClone.Topbar.SearchQuery.Visible = not ListClone.Topbar.SearchQuery.Visible
		if AllowRefresh then
			ListClone.Topbar.Refresh.Visible = not ListClone.Topbar.Refresh.Visible
		end
		if ListClone.Topbar.SearchQuery.Visible == false then
			ListClone.Topbar.SearchQuery.Text = ""
			for _, item in pairs(ItemFrames) do
				item.Fader:fadeIn(0.2)
			end
		end
	end)
	ListClone.Topbar.SearchQuery:GetPropertyChangedSignal("Text"):Connect(function()
		local Query = ListClone.Topbar.SearchQuery.Text:lower()
		local Frames = 0
		for _, item in pairs(ItemFrames) do
			local ItemText = item.Item.Text.Text:lower()
			if string.find(ItemText, Query) then
				item.Fader:fadeIn(0.2)
				Frames = Frames + 1
			else
				item.Fader:fadeOut(0.2)
			end
		end
		if Frames == 0 then
			TweenService:Create(ListClone.NoData, TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
		else
			TweenService:Create(ListClone.NoData, TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
		end
	end)
	
	local function refresh()
		if AllowSearch then
			ListClone:WaitForChild("Topbar").Search.Visible = false
		end
		Refreshing = true
		task.spawn(function()
			repeat 
				ListClone.Topbar.Refresh.Rotation = ListClone.Topbar.Refresh.Rotation + 4
				task.wait()
			until Refreshing == false
			TweenService:Create(ListClone.Topbar.Refresh,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{Rotation = 0}):Play()
		end)
		local newData = RemoteFunction:InvokeServer(ListData.MethodToCall)
		for _, item in pairs(ListClone.ScrollingFrame:GetChildren()) do
			if item:IsA("Frame") then
				task.spawn(function()
					local frame = nil
					for _, itemFrame in pairs(ItemFrames) do
						if itemFrame.Item == item then
							frame = itemFrame
						end
					end
					frame.Fader:fadeOut(0.3)
					frame.Fader.FadeOutCompleted:Wait()
					frame.Item:Destroy()
				end)
			end
		end
		
		--for i = #ItemFrames, 0,-1 do 
			--if i == 0 then break end
			--local frameData = ItemFrames[i]
			--frameData.Fader:fadeOut(0.3)
			--frameData.Fader.FadeOutCompleted:Wait()
			--frameData.Item:Destroy()
		--end
		
		task.wait(1)
		Refreshing = false
		ListClone.Topbar.Search.Visible = true
		ListClone.Topbar.SearchQuery.Visible = false
		for i in pairs(ItemFrames) do
			table.remove(ItemFrames, i)
		end
		if #newData > 0 then
			TweenService:Create(ListClone.NoData, TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
		end
		for i, item in pairs(newData) do
			task.spawn(function()
				local Item = makeListItem(i, item, ListClone)
				Item.MouseEntered:Connect(function()
					if Clicked then return end
					Client.MainInterfaceHolder.HoverData.Visible = true
				end)
				Item.MouseLeave:Connect(function()
					Client.MainInterfaceHolder.HoverData.Visible = false
				end)
				ItemFrames[i] = Item
			end)
		end
	end
	
	if AutoRefresh then
		task.spawn(function()
			repeat 
				task.wait(AutoRefreshSeconds or 2)
				if not Refreshing and not Searching then
					refresh()
					repeat task.wait() until not Refreshing
					--task.wait(if #ListClone.ScrollingFrame:GetChildren() - 1 == 0 then 0.5 else #ListClone.ScrollingFrame:GetChildren() - 1)
				end
			until ListClone == nil
		end)
	end
	ListClone.Topbar.Refresh.MouseButton1Click:Connect(function()
		if not ListData.MethodToCall then
			warn("Can't fetch new data if no method is stated.")
			return
		end
		if Refreshing then return end
		refresh()
	end)
	for i, item in pairs(ListItems) do
		task.spawn(function()
			local Item = makeListItem(i, item, ListClone)
			Item.MouseEntered:Connect(function()
				if Clicked then return end
				Client.MainInterfaceHolder.HoverData.Visible = true
			end)
			Item.MouseLeave:Connect(function()
				Client.MainInterfaceHolder.HoverData.Visible = false
			end)
			ItemFrames[i] = Item
		end)
	end
	ListClone.Topbar.Close.MouseButton1Click:Connect(function()
		if Clicked then return end
		Clicked = true
		if not Refreshing then
			for i = #ItemFrames, 0,-1 do 
				if i == 0 then break end
				task.spawn(function()
					local frameData = ItemFrames[i]
					frameData.Fader:fadeOut(0.3)
					frameData.Fader.FadeOutCompleted:Wait()
				end)
			end
		end
		task.wait(0.2)
		ListFader:fadeOut(1)
		ListFader.FadeOutCompleted:Wait()
		ListClone:Destroy()
		ListFader:Destroy()
	end)
	ListClone.MouseLeave:Connect(function()
		Client.MainInterfaceHolder.HoverData.Visible = false
	end)
end
]]

-- Handles Showing A Hint On The Screen

local function showHint(Title, Text, IsSticky)
	pcall(function()
		Sounds.Message:Play()
		local MessageSeconds = math.clamp(math.floor(Text:len()/3),3,9)
		local Clone = Client.MainInterfaceHolder.Assets[Client.UI.GetFolderForElement("HintTemplate")].HintTemplate:Clone()
		Clone.Name = if not IsSticky then "Hint" else "StickyHint"
		local Clicked = false
		local Closing = false
		Clone.Title.HintTitle.Text = Title
		Clone.HintText.Text = Text
		local OtherFrame = if not IsSticky then Client.MainInterfaceHolder.HintFrame:FindFirstChild("Hint") else Client.MainInterfaceHolder.HintFrame:FindFirstChild("StickyHint")
		if OtherFrame then
			OtherFrame.Title.Timer.Text = "Closing..."
			OtherFrame:TweenPosition(UDim2.new(0.276, 0,-1.158, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
			task.spawn(function()
				task.wait(0.5)
				pcall(function()
					OtherFrame:Destroy()
				end)
			end)
			Clone.Parent = Client.MainInterfaceHolder.HintFrame
			Clone.Visible = true
			Clone:TweenPosition(UDim2.new(0.276, 0,0.158, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
		else
			Clone.Parent = Client.MainInterfaceHolder.HintFrame
			Clone.Visible = true
			Clone:TweenPosition(UDim2.new(0.276, 0,0.158, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
		end
		task.spawn(function()
			if not IsSticky then
				for i = MessageSeconds,0,-1 do
					if i > 0 then
						if Clone.Parent then
							if Closing then
								break
							end
							Clone.Title.Timer.Text = string.format("Closes in: %s.0", i)
							task.wait(1)
						end
					else
						break
					end
				end
				Closing = true
				if Clone.Parent then
					Clone.Title.Timer.Text = "Closing..."
					task.wait(0.5)
					Clone:TweenPosition(UDim2.new(0.276, 0,-1.158, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
					task.wait(0.6)
					Clone:Destroy()
				end
			else
				Clone.Title.Timer.Text = "Click to Dismiss"
			end
		end)
		Clone.HintButton.MouseButton1Click:Connect(function()
			if Clicked then return end
			Clicked = true
			Closing = true
			Clone.Title.Timer.Text = "Closing..."
			task.wait(0.5)
			Clone:TweenPosition(UDim2.new(0.276, 0,-1.158, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
			task.wait(0.6)
			Clone:Destroy()
		end)
	end)
end

-- Handles Showing A Message On The Screen

local function displayMessage(Title, Text)
	pcall(function()
		Sounds.Message:Play()
		local MessageSeconds = math.clamp(math.floor(Text:len()/3),3,15)
		local Clone = Client.MainInterfaceHolder.Assets[Client.UI.GetFolderForElement("MessageTemplate")].MessageTemplate:Clone()
		Clone.Size = UDim2.new(1,0,1,0)
		Clone.Position = UDim2.new(0,0,1,0)
		Clone.Title.MessageTitle.Text = Title
		Clone.MessageText.Text = Text
		local Clicked = false
		local Closing = false
		if Client.MainInterfaceHolder.MessageFrame:FindFirstChildWhichIsA("Frame") then
			local OtherFrame = Client.MainInterfaceHolder.MessageFrame:FindFirstChildWhichIsA("Frame")
			OtherFrame:TweenPosition(UDim2.new(0, 0, 1, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
			OtherFrame.Title.Timer.Text = "Closing..."
			task.spawn(function()
				task.wait(0.5)
				pcall(function()
					OtherFrame:Destroy()
				end)
			end)
			Clone.Parent = Client.MainInterfaceHolder.MessageFrame
			Clone.Visible = true
			Clone:TweenPosition(UDim2.new(0, 0,0, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
		else
			Clone.Parent = Client.MainInterfaceHolder.MessageFrame
			Clone.Visible = true
			Clone:TweenPosition(UDim2.new(0, 0,0, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
		end
		task.spawn(function()
			for i = MessageSeconds,0,-1 do
				if i > 0 then
					if Clone.Parent then
						if Closing then
							break
						end
						Clone.Title.Timer.Text = string.format("Closes in: %s.0", i)
						task.wait(1)
					end
				else
					break
				end
			end
			Closing = true
			if Clone.Parent then
				Clone.Title.Timer.Text = "Closing..."
				task.wait(0.5)
				Clone:TweenPosition(UDim2.new(0, 0,1, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
				task.wait(0.6)
				Clone:Destroy()
			end
		end)
		Clone.MessageButton.MouseButton1Click:Connect(function()
			if Clicked then return end
			Clicked = true
			Closing = true
			Clone.Title.Timer.Text = "Closing..."
			task.wait(0.5)
			Clone:TweenPosition(UDim2.new(0, 0,1, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
			task.wait(0.6)
			Clone:Destroy()
		end)
	end)
end

local function makePrivateMessage(PrivateMessageData)
	task.spawn(function()
		local PMClone = Client.MainInterfaceHolder.Assets.Default.PrivateMessageTemplate:Clone()
		local PMFader = FaderModule.new(PMClone)
		local PMDragger = DraggerModule.new(PMClone)
		local Clicked = false
		if not PrivateMessageData.CanRespond then
			PMClone.Contents.Reply.send.Visible = false
			PMClone.Contents.Reply.TextEditable = false
			PMClone.Contents.Reply.PlaceholderText = "You Can't Reply To This Message."
		else
			if not PrivateMessageData.Sender then
				PrivateMessageData.Sender = "Server"
			end
		end
		if PrivateMessageData.CanCopyMessage then
			PMClone.Contents.MessageCopyable.Text = PrivateMessageData.Text
			PMClone.Contents.MessageCopyable.Visible = true
			PMClone.Contents.Message.Visible = false
		else
			PMClone.Contents.Message.Text = PrivateMessageData.Text
		end
		PMClone.Top.clear.MouseButton1Click:Connect(function()
			if Clicked then return end
			Clicked = true
			PMFader:fadeOut(1)
			task.spawn(function()
				task.wait(1.1)
				PMClone:Destroy()
			end)
		end)
		PMClone.Contents.Reply.send.MouseButton1Click:Connect(function()
			local Message = PMClone.Contents.Reply.Text
			if Message:len() >= 1 then
				if Clicked then return end
				Clicked = true
				if PrivateMessageData.Sender ~= "Server" and PrivateMessageData.Sender ~= nil then
					local Response = RemoteFunction:InvokeServer("sendPrivateMessage", PrivateMessageData.Sender, Message, Key)
					if typeof(Response) == "boolean" then
						if Response == true then
							showHint("Success", "Successfully Sent Message.")	
						else
							showHint("Error", "Somehow A Fatal Error Has Occurred.")	
						end
					else
						showHint("Error", Response)					
					end
				end
				PMFader:fadeOut(1)
				task.spawn(function()
					task.wait(1.1)
					PMClone:Destroy()
				end)
			else
				Snackbar.new("error", "You can't send an empty message.")
			end
		end)
		PMFader:fadeOut()
		PMClone.Name = PrivateMessageData.Title
		PMClone.Top.Title.Text = PrivateMessageData.Title
		PMClone.Parent = Client.MainInterfaceHolder
		task.wait(0.5)
		PMFader:fadeIn(1)
	end)
end

-- Used When The Admin Makes A Notification

local function makeNotification(NotiData)
	task.spawn(function()
		local NotiClone = Client.MainInterfaceHolder.Assets[Client.UI.GetFolderForElement("NotificationTemplate")].NotificationTemplate:Clone()
		local Id = #NotificationFrame:GetChildren() 
		local NotiFader = FaderModule.new(NotiClone)
		--local AspectRatio = Instance.new("UIAspectRatioConstraint", NotiClone)
		local Clicked = false
		--AspectRatio.DominantAxis = Enum.DominantAxis.Width
		--AspectRatio.AspectType = Enum.AspectType.ScaleWithParentSize
		--AspectRatio.AspectRatio = 3
		NotiClone.Size = UDim2.new(1, -20,0, 70)
		NotiClone.Name = Id
		NotiFader:fadeOut()
		task.wait(0.2)
		--NotiFader.FadeOutCompleted:Wait()
		local Type = NotiData.Type
		Sounds.Notification:Play()
		if Type == "Alert" then
			NotiClone.Topbar.Icon.Image = string.format("rbxassetid://%s", Icons.Notification_important)
		elseif Type == "Error" then
			NotiClone.Topbar.Icon.Image = string.format("rbxassetid://%s", Icons.Error)
			Sounds.Error:Play()
		else
			NotiClone.Topbar.Icon.Image = string.format("rbxassetid://%s", Icons.Info)
		end
		local MainText = NotiData.Text
		NotiClone.MainText.Text = MainText
		NotiClone.SecondaryText.Text = if NotiData.SecondaryText then NotiData.SecondaryText else ""
		NotiClone.Topbar.Title.Text = if NotiData.Title then NotiData.Title else "Notification"
		if not NotiData.SecondaryText then
			NotiClone.MainText.Size = UDim2.new(1, 0,0.52, 0)
		end
		NotiClone.Parent = NotificationFrame
		NotiFader:fadeIn(1)
		NotiClone.Topbar.close.MouseButton1Click:Connect(function()
			NotiFader:fadeOut(1)
			NotiFader.FadeOutCompleted:Wait()
			NotiClone:Destroy()
		end)
		NotiClone.NotificationButton.MouseButton1Click:Connect(function()
			if Clicked then return end
			Clicked = true
			if NotiData.ExtraData then
				if NotiData.ExtraData.InstanceToCreate then
					local InstanceToCreate = NotiData.ExtraData.InstanceToCreate
					local InstanceData = NotiData.ExtraData.InstanceData
					if InstanceToCreate == "List" then
						local Method = NotiData.ExtraData.MethodAfterClick
						local data = RemoteFunction:InvokeServer(Method)
						Client.UI.Make("List", {
							Title = InstanceData.Title, 
							Items = data, 
							AllowSearch = true, 
							AllowRefresh = true, 
							MethodToCall = Method
						})
						--	makeList({Title = InstanceData.Title, Items = data, AllowSearch = true, AllowRefresh = true, MethodToCall = Method})
					elseif InstanceToCreate == "PrivateMessage" then
						makePrivateMessage(InstanceData)
					end
				elseif NotiData.ExtraData.ClientFunctionToRun then
					local suc, result = pcall(ClientFunctions[NotiData.ExtraData.ClientFunctionToRun], Client)
					if not suc then
						warn(string.format("Client Function Failure: %s", result))
					end
				end
			end
			NotiFader:fadeOut(1)
			NotiFader.FadeOutCompleted:Wait()
			NotiClone:Destroy()
		end)
	end)
end

-- Handle Authentication Request Function

local function handleAuthRequest(message)
	local AuthFrame = Client.MainInterfaceHolder.Assets.Default.AuthRequestTemplate:Clone()
	AuthFrame.Parent = Client.MainInterfaceHolder
	local Fader = FaderModule.new(AuthFrame)
	local Dragger = DraggerModule.new(AuthFrame)
	for _, item in AuthFrame:GetDescendants() do
		if Utils.hasProperty(item, "ZIndex") then
			item.ZIndex = 100
		end
	end
	AuthFrame.AuthText.Text = message
	Fader:fadeOut()
	task.wait(0.2)
	Fader:fadeIn(1)
	local response = nil
	AuthFrame.Confirm.MouseButton1Click:Connect(function()
		response = true		
		Fader:fadeOut(1)
	end)
	AuthFrame.Cancel.MouseButton1Click:Connect(function()
		response = false	
		Fader:fadeOut(1)
	end)
	Fader.FadeOutCompleted:Connect(function()
		AuthFrame:Destroy()
	end)
	repeat task.wait() until response ~= nil	
	return response
end

-- Handle Capes

local function handleCapes()
	pcall(function()
		for _, plr in Players:GetPlayers() do
			if plr.Character and plr.Character:FindFirstChild("RudimentaryCape") then
				local Torso = plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("UpperTorso")
				local Motor = plr.Character:FindFirstChild("RudimentaryCape"):FindFirstChild("RudimentaryCapeMotor")
				local ang = 0.1
				--if wave then
				if Torso.Velocity.Magnitude > 1 then
					ang = ang + ((Torso.Velocity.Magnitude/10)*.05)+.05
				end
				--	v.Wave = false
				--else
				--v.Wave = true
				--end
				ang = ang + math.min(Torso.Velocity.Magnitude/11, .8)
				Motor.MaxVelocity = math.min((Torso.Velocity.Magnitude/111), .04) + 0.002
				--if isPlayer then
				Motor.DesiredAngle = -ang
				--else
				--	motor.CurrentAngle = -ang -- bugs
				--end
				if Motor.CurrentAngle < -.2 and Motor.DesiredAngle > -.2 then
					Motor.MaxVelocity = .04
				end
			end
		end
	end)
end

RunService.RenderStepped:Connect(function()
	handleCapes()
end)

--

local function addPlayerToList(plr)
	local Clone = Client.MainInterfaceHolder.Assets.Default.PlayerTemplate:Clone()
	Clone.UserId.Text = plr.UserId
	Clone.Username.Text = if plr.Name ~= plr.DisplayName then string.format("%s (@%s)", plr.DisplayName, plr.Name) else plr.Name
	Clone.Parent = MainInterface.Players.PlayerList
	Clone.Visible = true
	Clone.Name = plr.UserId
	MainInterface.Players.PlayerList.CanvasSize = UDim2.new(0,0,0,MainInterface.Players.PlayerList.UIListLayout.AbsoluteContentSize.Y)
end

local function removePlayerFromList(plr)
	MainInterface.Players.PlayerList:WaitForChild(plr.UserId):Destroy()
end

Mouse.Move:Connect(function()
	Client.MainInterfaceHolder.HoverData.Position = UDim2.new(0, Mouse.X + 10, 0, Mouse.Y +15)
end)

InterfaceFader:fadeOut()


for _, ui in pairs(MainInterface:GetChildren()) do
	if MainInterface.Sidebar:FindFirstChild(ui.Name) and ui:IsA("Frame") then
		local Fader = FaderModule.new(ui)
		MainInterfaceFaders[ui.Name] = Fader
		if ui.Name ~= SelectedInterface then
			MainInterfaceFaders[ui.Name]:fadeOut(0)
		end
	end
end

--Snackbar.new("warning", "Client Started")

Plr:WaitForChild("PlayerScripts")
if script.Parent.Name ~= "PlayerScripts" then
	script.Parent = Plr.PlayerScripts
	warn("Moved Client to PlayerScripts")
end

if Data.AdminLevel >= 1 then
	RudimentaryIcon.Visible = true
end

-- HANDLE MAIN INTERFACE

if Data.AdminLevel < Data.RequiredLevelForSettings then
	table.insert(LockedPanels, "Settings")
end

local function updatePlayers(plr)
	MainInterface.General.Holder.PlayerCount.Text = string.format("Player Count: %s", #Players:GetPlayers())
	if plr then
		if plr.Parent then
			addPlayerToList(plr)
		else
			removePlayerFromList(plr)
		end
	end
end

local function makeCommand(data)
	if data.Schema then
		local Clone = Client.MainInterfaceHolder.Assets[Client.UI.GetFolderForElement("CommandTemplate")].CommandTemplate:Clone()
		Clone.Name = data.Name
		Clone.CommandName.Text = data.Name
		Clone.Description.Text = Utils.shortenText(data.Description or "", 50)
		Clone.Visible = true
		Clone.Parent = MainInterface.Commands.ScrollingFrame
		MainInterface.Commands.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,MainInterface.Commands.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y+10)
		Clone.MouseButton1Click:Connect(function()
			if #data.Schema == 0 then
				local cmdstring = string.format("%s%s", if data.Prefix == "MainPrefix" then Data.Prefix else Data.SecondaryPrefix, data.Name)
				RemoteEvent:FireServer("execute", cmdstring)
			else
				local cmdstring = string.format("%s%s", if data.Prefix == "MainPrefix" then Data.Prefix else Data.SecondaryPrefix, data.Name)
				for _, item in data.Schema do
					local ExtraData = {}
					if item.Type == "Number" then
						ExtraData.ResultType = "Number"
					end
					local Prompt = PromptMaker.new(string.format("Input %s", item.Name), "Regular", ExtraData)
					local Res = nil
					Prompt.Result:Connect(function(response)
						Res = response
					end)
					repeat task.wait() until Res
					if Res == nil then 
						break
					else
						cmdstring = string.format("%s %s", cmdstring, Res)
					end
				end
				RemoteEvent:FireServer("execute", cmdstring)
			end
		end)
	end
end

local function makeSetting(data)
	local Clone = Client.MainInterfaceHolder.Assets.Default.TemplateSettingsFrame:Clone()
	local Dropdown = DropdownMenu.new()
	local Connection
	Clone.Name = data.Name
	Clone.SettingName.Text = data.Name
	Clone.SettingValue.Text = if data.IsStudioOnly then "Studio Only" else tostring(data.Value)
	if data.IsStudioOnly then
		Clone.SettingValue.TextColor3 = Color3.fromRGB(120,120,120)
	end
	Clone.SettingValue.MouseButton1Click:Connect(function()
		if data.IsStudioOnly then return end
		if data.Type == "keycode" then
			if Connection and Connection.Connected then return end
			Clone.SettingValue.Text = "Awaiting Input"
			Connection = UserInputService.InputBegan:Connect(function(IO, GP)
				if IO.KeyCode ~= Enum.KeyCode.Unknown then
					local KeyCode = IO.KeyCode.Name
					local success = RemoteFunction:InvokeServer("changeSetting", data.Name, KeyCode, Key)
					if success then
						Snackbar.new("info", "Setting saved successfully.") 
						Clone.SettingValue.Text = KeyCode
					else
						Snackbar.new("error", "Setting save failure.") 
					end
					Connection:Disconnect()
				end
			end)
		elseif data.Type == "selectable" then
			if not Dropdown.Open then
				Dropdown.Size = UDim2.new(0.372, 0,2.884, 0)
				Dropdown.Position = UDim2.new(0.626, 0,1, 0)
				Dropdown.Options = data.Options
				Dropdown.Parent = Clone
				Dropdown.Fader:fadeOut()
				Connection = Dropdown.OptionSelected:Connect(function(opt)
					Dropdown:close()
					Connection:Disconnect()
					local success = RemoteFunction:InvokeServer("changeSetting", data.Name, opt, Key)
					if success then
						Snackbar.new("info", "Setting saved successfully.") 
						Clone.SettingValue.Text = opt
					else
						Snackbar.new("error", "Setting save failure.") 
					end
				end)
				task.wait(0.2)
				Dropdown:open()
			else
				Dropdown:close()
				Connection:Disconnect()
			end
		elseif data.Type == "boolean" then
			if not Dropdown.Open then
				Dropdown.Size = UDim2.new(0.372, 0,2.884, 0)
				Dropdown.Position = UDim2.new(0.626, 0,1, 0)
				Dropdown.Options = {"true", "false"}
				Dropdown.Parent = Clone
				Dropdown.Fader:fadeOut()
				Connection = Dropdown.OptionSelected:Connect(function(opt)
					Dropdown:close()
					Connection:Disconnect()
					local success = RemoteFunction:InvokeServer("changeSetting", data.Name, Utils.textToBool(opt), Key)
					if success then
						Snackbar.new("info", "Setting saved successfully.") 
						Clone.SettingValue.Text = opt
					else
						Snackbar.new("error", "Setting save failure.") 
					end
				end)
				task.wait(0.2)
				Dropdown:open()
			else
				Dropdown:close()
				Connection:Disconnect()
			end
		else
			Clone.SettingValue.Visible = false
			Clone.SettingValueText.Visible = true
			Clone.SettingValueText:CaptureFocus()
			Clone.SettingValueText.FocusLost:Connect(function(enterpressed)
				if enterpressed then
					local NewSettingValue = Clone.SettingValueText.Text
					if NewSettingValue:gsub(" ", ""):len() >= 1 then
						if data.Type == "number" then
							if tonumber(NewSettingValue) then
								NewSettingValue = tonumber(NewSettingValue)
							else
								Snackbar.new("error", "Setting value must be a number.")
								Clone.SettingValueText:CaptureFocus()
								return
							end
						end
						local success = RemoteFunction:InvokeServer("changeSetting", data.Name, NewSettingValue, Key)
						if success then
							Snackbar.new("info", "Setting saved successfully.") 
							Clone.SettingValue.Text = NewSettingValue
						else
							Snackbar.new("error", "Setting save failure.") 
						end
						Clone.SettingValue.Visible = true
						Clone.SettingValueText.Visible = false
					else
						Snackbar.new("error", "Can't save an empty setting.")
						Clone.SettingValueText:CaptureFocus()
					end
				else
					Clone.SettingValue.Visible = true
					Clone.SettingValueText.Visible = false
				end
			end)
		end
	end)
	Clone.Parent = MainInterface.Settings.SettingsHolder
	Clone.Visible = true
	MainInterface.Settings.SettingsHolder.CanvasSize = UDim2.new(0,0,0,MainInterface.Settings.SettingsHolder.UIListLayout.AbsoluteContentSize.Y+10)
end

updatePlayers()

game.Players.PlayerAdded:Connect(updatePlayers)

game.Players.ChildRemoved:Connect(updatePlayers)

MainInterface.Topbar.close.MouseButton1Click:Connect(function()
	MainInterfaceOpen = false
	InterfaceFader:fadeOut(1)
end)

MainInterface.General.Holder.Avatar.Image = UserAvatar
MainInterface.General.Holder.ServerLocation.Text = string.format("Server Location: %s", Data.ServerRegion)
MainInterface.General.Holder.AdminLevel.Text = Data.AdminLevelName

if Plr.DisplayName ~= Plr.Name then
	MainInterface.General.Holder.Username.Text = string.format("%s (@%s)", Plr.DisplayName, Plr.Name)
else
	MainInterface.General.Holder.Username.Text = Plr.Name
end

MainInterface.General.Holder.Admins.Text = string.format("Administrators In-Game: %s", Data.InGameAdmins)

MainInterface.Version.Text = string.format("Rudimentary Version: %s (%s)", Data.Version, Data.VersionName)

for _, plr in pairs(Players:GetChildren()) do
	addPlayerToList(plr)
end

MainInterface.Players.Query:GetPropertyChangedSignal("Text"):Connect(function()
	for _, item in pairs(MainInterface.Players.PlayerList:GetChildren()) do
		if item:IsA("Frame") then
			if item.Username.Text:lower():find(MainInterface.Players.Query.Text:lower()) or item.UserId.Text:find(MainInterface.Players.Query.Text) then
				item.Visible = true
			else
				item.Visible = false
			end
		end
	end
end)

MainInterface.Commands.Query:GetPropertyChangedSignal("Text"):Connect(function()
	for _, item in pairs(MainInterface.Commands.ScrollingFrame:GetChildren()) do
		if item:IsA("TextButton") then
			if item.Name:lower():find(MainInterface.Commands.Query.Text:lower()) then
				item.Visible = true
			else
				item.Visible = false
			end
		end
	end
end)

for _, Command in pairs(RemoteFunction:InvokeServer("getAllAccessableCommandData")) do
	makeCommand(Command)
end

for _,setting in Settings do
	makeSetting(setting)
end


for _, button:TextButton in pairs(MainInterface.Sidebar:GetChildren()) do
	if button:IsA("TextButton") then
		local ButtonOriginalColor = nil
		button.MouseButton1Click:Connect(function()
			if not MainInterfaceFaders[button.Name] then return end
			if table.find(LockedPanels, button.Name) then return end
			if not CanSwitchPanels then return end
			CanSwitchPanels = false
			if SelectedInterface ~= button.Name then
				TweenService:Create(MainInterface.Sidebar[SelectedInterface], TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{BackgroundColor3 = Color3.fromRGB(34,34,34)}):Play()
				TweenService:Create(button, TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{BackgroundColor3 = Color3.fromRGB(58, 87, 150)}):Play()
				ButtonOriginalColor = Color3.fromRGB(58, 87, 150)
				MainInterfaceFaders[SelectedInterface]:fadeOut(1)
				MainInterfaceFaders[SelectedInterface].FadeOutCompleted:Wait()
				MainInterfaceFaders[button.Name]:fadeIn(1)
				SelectedInterface = button.Name
				task.spawn(function()
					task.wait(1)
					CanSwitchPanels = true
				end)
			end
		end)
		button.MouseEnter:Connect(function()
			ButtonOriginalColor = button.BackgroundColor3
			TweenService:Create(button, TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{BackgroundColor3 = Color3.fromRGB(66, 66, 66)}):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{BackgroundColor3 = ButtonOriginalColor}):Play()
		end)
	end
end

-- Handle Console

local ConsoleOpen = false
local Suggestion = nil
local ConsoleFrame

UserInputService.InputBegan:Connect(function(IO, GP)
	if GP and ConsoleOpen == false then 
		return 
	end
	if IO.KeyCode == Enum.KeyCode[Data.CommandBarKey] and not ConsoleOpen and Data.AdminLevel >= 1 then 
		RunService.RenderStepped:Wait()
		local ChatCoreGuiOpen = StarterGui:GetCoreGuiEnabled("Chat")
		local PlayerListCoreGuiOpen = StarterGui:GetCoreGuiEnabled("PlayerList")
		local CommandBarHolder = Client.MainInterfaceHolder.CommandBarHolder
		local Frame = Client.MainInterfaceHolder.Assets[Client.UI.GetFolderForElement("CommandBarTemplate")].CommandBarTemplate:Clone()
		ConsoleFrame = Frame
		Frame.Name = "CommandBar"
		Frame.Parent = CommandBarHolder
		Frame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
		Frame.Input:CaptureFocus()
		Frame.Helper.Visible = false
		if ChatCoreGuiOpen then
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		end
		if PlayerListCoreGuiOpen then
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		end
		ConsoleOpen = true
		Suggestion = nil
		local CurrentArg = nil
		local CommandData = RemoteFunction:InvokeServer("getAllAccessableCommandData")
		local TextChangeConnection 
		TextChangeConnection = Frame.Input:GetPropertyChangedSignal("Text"):Connect(function()
			if not Frame.Input.Text:find("%w") or Frame.Input.Text:split(" ")[2] then 		
				Frame.Helper.Visible = false 
				return 
			end
			local Command = Frame.Input.Text:split(" ")[1]
			local CommandName 
			for _, cmd in pairs(CommandData) do
				if cmd.Name:sub(1,Command:len()) == Command:lower() then
					CommandName = cmd.Name
				else
					for _, alias in pairs(cmd.Aliases) do
						if alias:sub(1,Command:len()) == Command:lower() then
							CommandName = alias
						end
					end
				end
			end
			if CommandName then
				Suggestion = CommandName
				Frame.Helper.Visible = true
				Frame.Helper.Text = CommandName
			else
				Frame.Helper.Visible = false 
			end
		end)
		local CloseConnection
		CloseConnection = Frame.Input.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				local Command = Frame.Input.Text:split(" ")[1]
				local CmdData 
				for _, cmd in pairs(CommandData) do
					if cmd.Name == Command:lower() or table.find(cmd.Aliases, Command:lower()) then
						CmdData = cmd
					end
				end
				if CmdData then
					local cmdstring = Frame.Input.Text
					cmdstring = string.format("%s%s", if CmdData.Prefix == "MainPrefix" then Data.Prefix else Data.SecondaryPrefix, cmdstring)
					RemoteEvent:FireServer("execute", cmdstring)
				else
					if Command:find("%w") then
						Sounds.Warning:Play()
						Snackbar.new("warning", string.format("%s isn't a valid command.", Command)) 
					end
					--makeNotification({Type = "Error", Title = "Invalid Command", Text = string.format("%s isn't a valid command.", Command)})
				end
			end
			ConsoleFrame = nil
			ConsoleOpen = false
			if ChatCoreGuiOpen then
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
			end
			if PlayerListCoreGuiOpen then
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
			end
			local function tweencomp(status)
				if status == Enum.TweenStatus.Completed then
					Frame:Destroy()
				end
			end
			Frame:TweenPosition(UDim2.new(0,0,-1,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true,tweencomp)
			CloseConnection:Disconnect()
			TextChangeConnection:Disconnect()
		end)
	elseif IO.KeyCode == Enum.KeyCode.Tab and ConsoleOpen and Suggestion then
		RunService.RenderStepped:Wait()
		local Text = ConsoleFrame.Input.Text
		local FormerText = Text:sub(1,Text:len()-1)
		local WordToReplace = nil
		for i, word in FormerText:split(" ") do
			WordToReplace = word
		end
		local NewText = FormerText:gsub(WordToReplace, Suggestion)
		ConsoleFrame.Input.Text = NewText
		ConsoleFrame.Input.CursorPosition = NewText:len()+1
	end
end)

-- Handle Events

RemoteEvent.OnClientEvent:Connect(function(req, ...)
	local ReqData = {...}
	if req == "displayNotification" then
		makeNotification(ReqData[1])
		--[[
		local NotiClone = Notification:Clone()
		local NotiFader = FaderModule.new(NotiClone)
		NotiClone.Name = #NotificationFrame:GetChildren()
		NotiFader:fadeOut()
		task.wait(0.3)
		local Text = Data[1]
		NotiClone.NotificationText.Text = Text
		NotiClone.Parent = NotificationFrame
		NotiFader:fadeIn(1)
		for _, item:Frame in pairs(NotificationFrame:GetChildren()) do
			if tonumber(item.Name) < tonumber(NotiClone.Name) then
				local NewPosition = item.Position - UDim2.new(0,0,0.223,0)
				item:TweenPosition(item.Position - UDim2.new(0,0,0.223,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
				task.spawn(function()
					task.wait(0.5)
					if item.Position.Y.Scale > NewPosition.Y.Scale then
						item.Position = NewPosition
					end
				end)
			end
		end
		]]

	elseif req == "displayMessage" then
		local Message = ReqData[1]
		local Title = Message.Title
		local Text = Message.Text
		displayMessage(Title, Text)
	elseif req == "showHint" then
		local Hint = ReqData[1]
		local Title = Hint.Title
		local Text = Hint.Text
		local Sticky = Hint.Sticky
		showHint(Title, Text, Sticky or false)
	elseif req == "makeList" then
		Client.UI.Make("List", ReqData[1])
		--makeList(ReqData[1])
	elseif req == "makePrivateMessage" then
		makePrivateMessage(ReqData[1])
	elseif req == "playSound" then
		local Sound = ReqData[1]
		if Sounds:FindFirstChild(Sound) then
			Sounds:FindFirstChild(Sound):Play()
		end
	elseif req == "handleAuthRequest" then
		local Remote = ReqData[1]
		task.spawn(function()
			Remote.OnClientInvoke = handleAuthRequest
		end)
	elseif req == "changeData" then
		local Index,Value = ReqData[1],ReqData[2]
		Data[Index] = Value
		local Item = MainInterface.Settings.SettingsHolder:FindFirstChild(Index)
		if Item then
			if Item.SettingValue.TextColor3 ~= Color3.fromRGB(120,120,120) then
				Item.SettingValue.Text = tostring(Value)
			end
		end
		if Index == "AdminLevel" then
			if Value >= 1 then
				RudimentaryIcon.Visible = true
				MainInterface.General.Holder.AdminLevel.Text = RemoteFunction:InvokeServer("getAdminLevel", Value)
				for _, item in MainInterface.Commands.ScrollingFrame:GetChildren() do
					if item:IsA("TextButton") then
						item:Destroy()
					end
				end
			else
				if MainInterfaceOpen then
					InterfaceFader:fadeOut(1)
					MainInterfaceOpen = false
				end
				RudimentaryIcon.Visible = false
			end
			for _, Command in pairs(RemoteFunction:InvokeServer("getAllAccessableCommandData")) do
				makeCommand(Command)
			end
			if Data.RequiredLevelForSettings >= Value and (#MainInterface.Settings.SettingsHolder:GetChildren() - 1) == 0 then
				MainInterface.Sidebar.Settings.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				if table.find(LockedPanels, "Settings") then
					table.insert(LockedPanels, table.find(LockedPanels, "Settings"))
				end
				for _, setting in RemoteFunction:InvokeServer("getSettings") do
					makeSetting(setting)
				end
			elseif Data.RequiredLevelForSettings < Value then
				if not table.find(LockedPanels, "Settings") then
					table.insert(LockedPanels, "Settings")
				end
				for _, item in MainInterface.Settings.SettingsHolder:GetChildren() do
					if item:IsA("Frame") then
						item:Destroy()
					end
				end
				if SelectedInterface == "Settings" then
					MainInterfaceFaders.Settings:fadeOut(1)
					MainInterfaceFaders.General:fadeIn(1)
					SelectedInterface = "General"
					TweenService:Create(MainInterface.Sidebar.Settings, TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{BackgroundColor3 = Color3.fromRGB(34,34,34)}):Play()
					TweenService:Create(MainInterface.Sidebar.General, TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{BackgroundColor3 = Color3.fromRGB(58, 87, 150)}):Play()
				end
			end
		elseif Index == "RequiredLevelForSettings" then
			if Data.AdminLevel < Data.RequiredLevelForSettings and (#MainInterface.Settings.SettingsHolder:GetChildren() - 1) ~= 0 then
				if table.find(LockedPanels, "Settings") then
					table.insert(LockedPanels, table.find(LockedPanels, "Settings"))
				end
				for _, item in MainInterface.Settings.SettingsHolder:GetChildren() do
					if item:IsA("Frame") then
						item:Destroy()
					end
				end
				if SelectedInterface == "Settings" then
					MainInterfaceFaders.Settings:fadeOut(1)
					MainInterfaceFaders.General:fadeIn(1)
					SelectedInterface = "General"
					TweenService:Create(MainInterface.Sidebar.Settings, TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{BackgroundColor3 = Color3.fromRGB(34,34,34)}):Play()
					TweenService:Create(MainInterface.Sidebar.General, TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{BackgroundColor3 = Color3.fromRGB(58, 87, 150)}):Play()
				end
			elseif Data.AdminLevel >= Data.RequiredLevelForSettings and (#MainInterface.Settings.SettingsHolder:GetChildren() - 1) == 0 then
				if table.find(LockedPanels, "Settings") then
					table.insert(LockedPanels, table.find(LockedPanels, "Settings"))
				end
				for _, setting in RemoteFunction:InvokeServer("getSettings") do
					makeSetting(setting)
				end
			end
		elseif Index == "InGameAdmins" then
			MainInterface.General.Holder.Admins.Text = string.format("Administrators In-Game: %s", Value)
		elseif Index == "Theme" then
			local ThemeFolder = Client.MainInterfaceHolder.Assets[Value]
			Client.MainInterfaceHolder.HoverData.BackgroundColor3 = if ThemeFolder:FindFirstChild("HoverDataColor") then ThemeFolder.HoverDataColor.Value else Color3.fromRGB(30,30,30)
		end
	elseif req == "changeKey" then
		Key = ReqData[1]
	elseif req == "checkKeyValidity" then
		local RemoteName = ReqData[1]
		RudimentaryFolder:WaitForChild(RemoteName):FireServer(Key)
	elseif ClientFunctions[req] then
		pcall(ClientFunctions[req], Client, ...)
	end
end)

LogService.MessageOut:Connect(function(message)
	RemoteEvent:FireServer("sendClientLog", message, Key)
end)

--[[
task.spawn(function()
	while true do
		if #NotificationQueue > 0 then
			for i, notiData in pairs(NotificationQueue) do
				local NotiClone = Notification:Clone()
				local Id = #NotificationFrame:GetChildren() + 1
				local NotiFader = FaderModule.new(NotiClone)
				local Clicked = false
				NotiClone.Name = Id
				NotiFader:fadeOut()
				NotiFader.FadeOutCompleted:Wait()
				local Type = notiData.Type
				Sounds.Notification:Play()
				if Type == "Alert" then
					NotiClone.Type.NotiType.Text = "!"
				elseif Type == "Error" then
					NotiClone.Type.NotiType.Text = "ERR"
					Sounds.Error:Play()
				else
					NotiClone.Type.NotiType.Text = "!"
				end
				local Text = notiData.Text
				NotiClone.NotificationText.Text = Text
				NotiClone.Parent = NotificationFrame
				NotiFader:fadeIn(1)
				for _, item:Frame in pairs(NotificationFrame:GetChildren()) do
					if tonumber(item.Name) < tonumber(NotiClone.Name) then
						local NewPosition = item.Position - UDim2.new(0,0,0.223,0)
						item:TweenPosition(NewPosition,Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,true)
						item:SetAttribute("BeingProcessed", true)
						task.spawn(function()
							item:SetAttribute("BeingProcessed", false)
							task.wait(0.7)
							if item.Position.Y.Scale > NewPosition.Y.Scale then
								item.Position = NewPosition
							end
						end)
					end
				end
				NotiClone.NotificationButton.MouseButton1Click:Connect(function()
					--if #NotificationQueue > 0 then NotificationQueue[#NotificationQueue] = {"Error", "Can't handle a notification while notificiations are being created."} return end
					if Clicked then return end
					Clicked = true
					NotiFader:fadeOut(1)
					NotiFader.FadeOutCompleted:Wait()
					NotiFader:Destroy()
					NotiClone:Destroy()
					for _, item:Frame in pairs(NotificationFrame:GetChildren()) do
						if tonumber(item.Name) > Id then
							item.Name = tonumber(item.Name) - 1
						end
					end 
					for _, item:Frame in pairs(NotificationFrame:GetChildren()) do
						local itemId = tonumber(item.Name)
						if itemId < Id and itemId ~= #NotificationFrame:GetChildren() then
							item:SetAttribute("BeingProcessed", true)
						end
					end
					for itemId = #NotificationFrame:GetChildren(),0,-1 do
						if itemId == 0 then break end
						local item = NotificationFrame[itemId]
						if itemId < Id then
							if itemId == #NotificationFrame:GetChildren() then
								item:TweenPosition(UDim2.new(0.089, 0,0.781, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,false)
							else
								local function itemCallback()
									item:SetAttribute("BeingProcessed", false)
								end
								warn(itemId+1)
								repeat task.wait() until not NotificationFrame[itemId + 1]:GetAttribute("BeingProcessed")
								item:TweenPosition(NotificationFrame[itemId + 1].Position - UDim2.new(0,0,0.223,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.5,false,itemCallback)
							end
							--item:TweenPosition(NewPosition,Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,0.2,true)
						end
					end
				end)
				table.remove(NotificationQueue,i)
				wait(0.5)
			end
		end
		task.wait()
	end
end)

]]