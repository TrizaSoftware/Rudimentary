--[[

    ____                             __ 
   / __ \_________  ____ ___  ____  / /_
  / /_/ / ___/ __ \/ __ `__ \/ __ \/ __/
 / ____/ /  / /_/ / / / / / / /_/ / /_  
/_/   /_/   \____/_/ /_/ /_/ .___/\__/  
                          /_/           

 	 Programmer(s): CodedJimmy
	 
	 Prompt
	  
	 © T:Riza Corporation 2020-2022

]]

local Player = game.Players.LocalPlayer
local RudimentaryUi = Player.PlayerGui:WaitForChild("RudimentaryUi")
local SharedModules = game.ReplicatedStorage:WaitForChild("Rudimentary"):WaitForChild("Shared")
local Signal = require(SharedModules:WaitForChild("Signal"))
local Utils = require(SharedModules:WaitForChild("Utils"))
local Fader = require(script.Parent.Fader)
local Dragger = require(script.Parent.Dragger)
local Snackbar = require(script.Parent.Snackbar)
local Prompt = {}
Prompt.__index = Prompt

function Prompt.new(Title, Type, Data)
	local self = setmetatable({}, Prompt)
	self.Result = Signal.new()
	Data = Data or {}
	if Type == "Regular" then
		self.Frame = script.MainPrompt:Clone()
		self.Frame.Visible = false
		self.Fader = Fader.new(self.Frame)
		self.Dragger = Dragger.new(self.Frame)
		self.Frame.Parent = RudimentaryUi
		self.Fader:fadeOut()
		task.wait(0.1)
		self.Frame.Topbar.Title.Text = Title
		for _, item in self.Frame:GetDescendants() do
			if Utils.hasProperty(item, "ZIndex") then
				item.ZIndex = 100
			end
		end
		self.Fader:fadeIn(1)
		self.Frame.Select.MouseButton1Click:Connect(function()
			if Data.ResultType == "Number" then
				if tonumber(self.Frame.Input.Text) == nil then
					Snackbar.new("error", "Input must be a number.")
				else
					self.Result:Fire(tonumber(self.Frame.Input.Text))
					self.Fader:fadeOut(0.5)
				end
			else
				if string.find(self.Frame.Input.Text:gsub(" ", ""), "%w") then
					self.Result:Fire(self.Frame.Input.Text)
					self.Fader:fadeOut(0.5)
				else
					Snackbar.new("error", "You must input something.")
				end
			end
		end)
		self.Frame.Topbar.clear.MouseButton1Click:Connect(function()
			self.Fader:fadeOut(0.5)
			self.Result:Fire(nil)
		end)
		self.Fader.FadedOut:Connect(function()
			self.Frame:Destroy()
		end)
	end
	return self
end


return Prompt