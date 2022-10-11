local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RudimentaryFolder = ReplicatedStorage:WaitForChild("Rudimentary") :: Folder
local SharedModules = RudimentaryFolder:WaitForChild("Shared") :: Folder
local Key = require(SharedModules.Key)
local Signal = require(SharedModules.Signal)
local Fader = require(script.Parent.Fader)
local Dragger = require(script.Parent.Dragger)
local StringFormatter = require(script.Parent.StringFormatter)
local TweenService = game:GetService("TweenService")
local Plr = game.Players.LocalPlayer
local mouse = Plr:GetMouse()
local List = {}
local Client = nil
List.__index = List

--[[
local function mouseInFrame(uiobject)
	local y_cond = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
	local x_cond = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X

	return (y_cond and x_cond)
end
]]

local function makeListItem(pos, itemData, list)
	local self = {}
	self.MouseEntered = Signal.new()
	self.MouseLeave = Signal.new()
	local listElemClone = Client.UI:GetFolderForElement("ListElementTemplate").ListElementTemplate:Clone()
	local ElementFader = Fader.new(listElemClone)
	listElemClone.Name = pos
	self.Item = listElemClone
	self.Clicked = false
	if not itemData.Data then
		itemData = StringFormatter.formatString(itemData)
	else
		itemData.Data = StringFormatter.formatString(itemData.Data)
	end
	if typeof(itemData) == "string" then
		--listElemClone.Name = Client.Utils.shortenText(Client.Utils.filterOutRichTextData(itemData), 30)
		listElemClone.Text.Text = Client.Utils.shortenText(Client.Utils.filterOutRichTextData(itemData), 30)
	else
		--listElemClone.Name = Client.Utils.shortenText(Client.Utils.filterOutRichTextData(itemData.Data), 30)
		listElemClone.Text.Text = Client.Utils.shortenText(Client.Utils.filterOutRichTextData(itemData.Data), 30)
		if itemData.Clickable then
			listElemClone.Clicker.Visible = true
		end
	end
	listElemClone.Clicker.MouseButton1Click:Connect(function()
		self.Clicked = not self.Clicked
		if self.Clicked then
			listElemClone.Text.Text = itemData.Data
		else
			listElemClone.Text.Text = Client.Utils.shortenText(Client.Utils.filterOutRichTextData(itemData.Data), 30)
		end
	end)
	self.Fader = ElementFader
	ElementFader:fadeOut()
	task.wait(0.01)
	if list.Parent then
		listElemClone.Parent = list.ScrollingFrame
	end
	listElemClone.MouseEnter:Connect(function()
		self.MouseEntered:Fire()
		if typeof(itemData) == "string" then
			Client.MainInterfaceHolder.HoverData.Text = itemData
		else
			Client.MainInterfaceHolder.HoverData.Text = string.format("%s%s",itemData.Data,if itemData.ExtraData then "\n"..itemData.ExtraData else "")
		end
	end)
	listElemClone.MouseLeave:Connect(function()
		self.MouseLeave:Fire()
	end)
	return self
end

function List.new(client,Data)
	Client = client
	local self = setmetatable({}, List)
	self.ScreenGui = Instance.new("ScreenGui", Plr.PlayerGui)
	local function bringUIToView()
		self.ScreenGui.DisplayOrder = 101
		for _, item in Plr.PlayerGui:GetChildren() do
			if item:GetAttribute("RudimentaryWindowUI") and item ~= self.ScreenGui then
				item.DisplayOrder = 100
			end
		end
	end
	bringUIToView()
	self.ListInstance = Client.UI:GetFolderForElement("ListTemplate").ListTemplate:Clone()
	self.DraggerInstance = Dragger.new(self.ListInstance, true)
	self.FaderInstance = Fader.new(self.ListInstance)
	self.FaderInstance:fadeOut()
	self.Clicked = false
	self.LoadingItems = false
	self.ItemFrames = {}
		
	local AllowSearch = Data.AllowSearch
	local AllowRefresh = Data.AllowRefresh
	local AutoRefresh = Data.AutoRefresh
	local AutoRefreshSeconds = Data.AutoRefreshSeconds
	local ListItems = Data.Items
	local Title = Data.Title
	local Refreshing = false
	local Searching = false
		
	self.ListInstance.Topbar.Listname.Text = Client.Utils.shortenText(Title, 20)
	if AllowSearch then
		self.ListInstance.Topbar.Search.Visible = true
	end
	if AllowRefresh then
		self.ListInstance.Topbar.Refresh.Visible = true
	end
	
	self.ListInstance.Topbar.Search.MouseButton1Click:Connect(function()
		Searching = not Searching
		self.ListInstance.Topbar.Listname.Visible = not self.ListInstance.Topbar.Listname.Visible
		self.ListInstance.Topbar.SearchQuery.Visible = not self.ListInstance.Topbar.SearchQuery.Visible
		if AllowRefresh then
			self.ListInstance.Topbar.Refresh.Visible = not self.ListInstance.Topbar.Refresh.Visible
		end
		if self.ListInstance.Topbar.SearchQuery.Visible == false then
			self.ListInstance.Topbar.SearchQuery.Text = ""
			for _, item in pairs(self.ItemFrames) do
				item.Fader:fadeIn(0.2)
			end
		end
	end)
	self.ListInstance.Topbar.SearchQuery:GetPropertyChangedSignal("Text"):Connect(function()
		local Query = self.ListInstance.Topbar.SearchQuery.Text:lower()
		local Frames = 0
		for _, item in pairs(self.ItemFrames) do
			local ItemText = item.Item.Text.Text:lower()
			if string.find(ItemText, Query) then
				item.Fader:fadeIn(0.2)
				Frames = Frames + 1
			else
				item.Fader:fadeOut(0.2)
			end
		end
		if Frames == 0 then
			TweenService:Create(self.ListInstance.NoData, TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
		else
			TweenService:Create(self.ListInstance.NoData, TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
		end
	end)

	local function refresh()
		if not self.ListInstance.Parent then
			return 
		end
		if AllowSearch then
			self.ListInstance.Topbar.Search.Visible = false
		end
		Refreshing = true
		task.spawn(function()
			repeat 
				self.ListInstance.Topbar.Refresh.Rotation = self.ListInstance.Topbar.Refresh.Rotation + 4
				task.wait()
			until Refreshing == false
			TweenService:Create(self.ListInstance.Topbar.Refresh,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{Rotation = 0}):Play()
		end)
		local newData = Client.RemoteFunction:InvokeServer(Data.MethodToCall, table.unpack(Data.ReqArgs or {}))
		for _, item in pairs(self.ListInstance.ScrollingFrame:GetChildren()) do
			if item:IsA("Frame") then
				task.spawn(function()
					local frame = nil
					for _, itemFrame in pairs(self.ItemFrames) do
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
		--[[
		for i = #ItemFrames, 0,-1 do 
			if i == 0 then break end
			local frameData = ItemFrames[i]
			frameData.Fader:fadeOut(0.3)
			frameData.Fader.FadeOutCompleted:Wait()
			frameData.Item:Destroy()
		end
		]]
		task.wait(1)
		Refreshing = false
		self.ListInstance.Topbar.Search.Visible = true
		self.ListInstance.Topbar.SearchQuery.Visible = false
		for i in pairs(self.ItemFrames) do
			table.remove(self.ItemFrames, i)
		end
		if #newData > 0 then
			TweenService:Create(self.ListInstance.NoData, TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
		else
			TweenService:Create(self.ListInstance.NoData, TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
		end
		task.spawn(function()
			self.LoadingItems = if #newData > 0 then true else false
			for i, item in pairs(newData) do
				if not self.ListInstance.Parent then
					break
				end
				self:renderItem(i, item)
				task.wait(0.01)
				task.spawn(function()
					task.wait(0.05)
					if self.ListInstance.Parent then
						self.ListInstance.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,self.ListInstance.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y + 10)
					end
				end)
				if i == #newData then
					self.LoadingItems = false
				end
			end
		end)
	end

	if AutoRefresh then
		task.spawn(function()
			repeat 
				task.wait(AutoRefreshSeconds or 2)
				if not Refreshing and not Searching and not self.LoadingItems then
					refresh()
					repeat task.wait() until not Refreshing
					--task.wait(if #self.ListInstance.ScrollingFrame:GetChildren() - 1 == 0 then 0.5 else #self.ListInstance.ScrollingFrame:GetChildren() - 1)
				end
			until self.ListInstance == nil
		end)
	end
	self.ListInstance.Topbar.Refresh.MouseButton1Click:Connect(function()
		if not Data.MethodToCall then
			warn("Can't fetch new data if no method is stated.")
			return
		end
		if Refreshing or self.LoadingItems then return end
		refresh()
	end)
	task.spawn(function()
		task.wait(0.5)
		self.LoadingItems = if #ListItems > 0 then true else false
		for i, item in pairs(ListItems) do
			if not self.ListInstance.Parent then
				break
			end
			self:renderItem(i, item)
			task.wait(0.01)
			task.spawn(function()
				task.wait(0.03)
				if self.ListInstance.Parent then
					self.ListInstance.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,self.ListInstance.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y + 10)
				end
			end)
			if i == #ListItems then
				self.LoadingItems = false
			end
		end
	end)
	self.ListInstance.Topbar.Close.MouseButton1Click:Connect(function()
		if self.Clicked then return end
		self.Clicked = true
		if not Refreshing then
			for i = #self.ItemFrames, 0,-1 do 
				if i == 0 then break end
				task.spawn(function()
					local frameData = self.ItemFrames[i]
					frameData.Fader:fadeOut(0.3)
					frameData.Fader.FadeOutCompleted:Wait()
				end)
			end
		end
		task.wait(0.2)
		self.FaderInstance:fadeOut(1)
		self.FaderInstance.FadeOutCompleted:Wait()
		self.ScreenGui:Destroy()
		self.FaderInstance:Destroy()
	end)
	self.ListInstance.MouseLeave:Connect(function()
		Client.MainInterfaceHolder.HoverData.Visible = false
	end)
	
	self.ScreenGui.Name = Key(15)
	self.ScreenGui:SetAttribute("RudimentaryWindowUI", true)
	self.ScreenGui.ResetOnSpawn = false
	self.ListInstance.Parent = self.ScreenGui
	self.ScreenGui.Parent = Plr.PlayerGui
	--[[
	self.ListInstance.Topbar.close.MouseButton1Click:Connect(function()
		if Clicked then return end
		Clicked = true
		self.FaderInstance:fadeOut(1)
		task.spawn(function()
			task.wait(1)
			self.ScreenGui:Destroy()
		end)
	end)
	]]
	task.spawn(function()
		task.wait(0.1)
		self.FaderInstance:fadeIn(1)
		if #ListItems == 0 then
			TweenService:Create(self.ListInstance.NoData, TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
			self.ListInstance.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
		end
	end)
	self.ListInstance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			bringUIToView()
		end
	end)
	self.DraggerInstance.Dragging:Connect(function(isDragging)
		if isDragging then
			bringUIToView()
		end
	end)
	--[[
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if mouseInFrame(self.ListInstance) and self.ScreenGui.DisplayOrder == 101 and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			bringUIToView()
		end
	end)
	]]
	return self
end

function List:renderItem(name, itemdata)
	task.spawn(function()
		if self.ListInstance.Parent then
			local Item = makeListItem(name, itemdata, self.ListInstance)
			Item.MouseEntered:Connect(function()
				if self.Clicked then return end
				Client.MainInterfaceHolder.HoverData.Visible = true
			end)
			Item.MouseLeave:Connect(function()
				Client.MainInterfaceHolder.HoverData.Visible = false
			end)
			self.ItemFrames[name] = Item
			if not self.Refreshing then
				task.wait(0.01)
				Item.Fader:fadeIn(0.5)
			end
		end
	end)
end

return List
