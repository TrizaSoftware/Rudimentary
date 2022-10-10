--[[

    ____                                  
   / __ \_________ _____ _____ ____  _____
  / / / / ___/ __ `/ __ `/ __ `/ _ \/ ___/
 / /_/ / /  / /_/ / /_/ / /_/ /  __/ /    
/_____/_/   \__,_/\__, /\__, /\___/_/     
                 /____//____/   
                 
 	 Programmer(s): CodedJimmy, Tiffblocks
	 
	 Dragger
	  
	 Â© T:Riza Corporation 2020-2022
	 
]]

local RudimentaryFolder = game.ReplicatedStorage:WaitForChild("Rudimentary")
local SharedModules = RudimentaryFolder:WaitForChild("Shared")
local Signal = require(SharedModules.Signal)
local Dragger = {}
local _warn = warn
local function warn(...)
	_warn("[Dragger]:",...)
end

function Dragger.new(UI:Frame, isWindow:boolean)
	assert(UI:IsA("Frame"), "Interface must be a frame.")
	local self = {}
	self.Dragging = Signal.new()
	local UserInputService = game:GetService("UserInputService")

	local gui = UI

	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	
	local function checkIsOnTop()
		local suc, res = pcall(function()
			return if isWindow then if gui.Parent:IsA("ScreenGui") and gui.Parent.DisplayOrder == 101 then true else false else true
		end)	
		if suc then
			return res
		else
			return false
		end
	end
	
	local itemToCheck = gui:FindFirstChild("Topbar") or gui

	itemToCheck.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch and checkIsOnTop() then
			dragging = true
			self.Dragging:Fire(true)
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					self.Dragging:Fire(false)
				end
			end)
		end
	end)

	itemToCheck.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch and dragging then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging and checkIsOnTop() then
			update(input)
		end
	end)
	return self
end

return Dragger