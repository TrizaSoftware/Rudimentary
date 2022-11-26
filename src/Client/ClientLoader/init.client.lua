if _G.RudimentaryClientStarted then
	script:Destroy()
end

_G.RudimentaryClientStarted = true

local Start = tick()

-- SERVICES 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketPlaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local TestService = game:GetService("TestService")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")

-- VARIABLES

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local RudimentaryFolder = ReplicatedStorage:WaitForChild("Rudimentary") :: Folder
local RemoteEvent = RudimentaryFolder:WaitForChild("RudimentaryRemoteEvent") :: RemoteEvent
local RemoteFunction = RudimentaryFolder:WaitForChild("RudimentaryRemoteFunction")
RemoteEvent:FireServer("signifyClientStart")
local ClientData = RemoteFunction:InvokeServer("fetchData")
local Shared = RudimentaryFolder:WaitForChild("Shared")
local Utils = require(Shared:WaitForChild("Utils"))
local Dependencies = script:WaitForChild("Dependencies")
local Sounds = script:WaitForChild("Sounds")
local TNet = require(Shared.TNet)
local TNetClient = TNet.new()
local Fader = require(Dependencies.Fader)
local Dragger = require(Dependencies.Dragger)
local Functions = require(Dependencies.Functions)
local Key = nil
local Client = {UI = {}}

-- REDEFINE WARN

local _warn = warn
local function warn(...)
  _warn("[Rudimentary Client]:",...)
end

-- CLIENT TABLE SETUP

function Client:GetKey()
 local checkString = string.format("Players.%s.PlayerGui.RudimentaryUi.ClientLoader", Player.Name)
 local information = debug.traceback():split("GetKey")[2]
 information = information:sub(2,information:len())
 if checkString == information:sub(1,checkString:len()) then
  return Key
 end
end

function Client.UI:GetFolderForElement(element:string)
  return if Client.MainInterface.Assets[Client.Theme]:FindFirstChild(element) then Client.MainInterface.Assets[Client.Theme] else Client.MainInterface.Assets.Default
end

function Client.UI.Make(element, ...)
  assert(Dependencies:FindFirstChild(element), string.format("%s isn't a valid Dependency.", element))
  local suc, res = pcall(require(Dependencies:FindFirstChild(element)).new, Client, ...)
  if not suc then
    warn(string.format("Client UI Error: %s", tostring(res)))
  else
    return res
  end
end

Client.MainInterface = Player.PlayerGui:WaitForChild("RudimentaryUi")
Client.Theme = ClientData.Theme
Client.MainInterfaceHandlers = {}
Client.MainInterfaceFaders = {}
Client.Panel = Client.UI:GetFolderForElement("Panel").Panel:Clone()
Client.Fader = nil
Client.Dragger = Dragger.new(Client.Panel)
Client.PanelOpen = false
Client.SidebarOpen = false
Client.InterfaceOpen = "General"
Client.RemoteEvent = RemoteEvent
Client.RemoteFunction = RemoteFunction
Client.Data = ClientData
Client.Shared = Shared
Client.Utils = Utils
Client.Sounds = Sounds
Client.Icons = require(Dependencies.MaterialIcons)

-- INTIALIZE INTERFACES

Client.Panel.Parent = Client.MainInterface

Client.MainInterface.RudimentaryIcon.Visible = true

local function setVisibility(visibility:boolean)
  if not Client.Fader then return end
  if visibility then
    Client.Fader:fadeIn(0.8)
    for faderParent, fader in Client.MainInterfaceFaders do
      if faderParent == Client.InterfaceOpen then
        fader:fadeIn(0.8)
      end
    end
  else
    Client.Fader:fadeOut(0.8)
    for faderParent, fader in Client.MainInterfaceFaders do
      if faderParent == Client.InterfaceOpen then
        fader:fadeOut(0.8)
      end
    end
  end
end

Client.MainInterface.RudimentaryIcon.MouseButton1Click:Connect(function()
  setVisibility(not Client.PanelOpen)
  Client.PanelOpen = not Client.PanelOpen
end)

Client.Panel.Topbar.Icons.Close.MouseButton1Click:Connect(function()
  setVisibility(false)
  Client.PanelOpen = false
end)

Client.Panel.Topbar.Icons.Menu.MouseButton1Click:Connect(function()
  if not Client.SidebarOpen then
    Client.Panel.Sidebar:TweenPosition(UDim2.new(0.723, 0,0.09, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.4, true)
    task.spawn(function()
      task.wait(0.2)
      if Client.SidebarOpen then
        TweenService:Create(Client.Panel.Grey, TweenInfo.new(1,Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
      end
    end)
    Client.Panel.Grey.Visible = true
  else
    Client.Panel.Sidebar:TweenPosition(UDim2.new(1, 0,0.09, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.4, true)
    local Tween = TweenService:Create(Client.Panel.Grey, TweenInfo.new(1,Enum.EasingStyle.Quint), {BackgroundTransparency = 1})
    Tween:Play()
    Tween.Completed:Connect(function(playbackState)
      if playbackState == Enum.PlaybackState.Completed then
        Client.Panel.Grey.Visible = false
      end
    end)
  end
  Client.SidebarOpen = not Client.SidebarOpen
end)

for _, module in Dependencies.MainInterface:GetChildren() do
  if module:IsA("ModuleScript") and Client.Panel:FindFirstChild(module.Name) then
    Client.MainInterfaceHandlers[module.Name] = require(module)(Client)
  end
end

for interfaceName, _ in Client.MainInterfaceHandlers do
  local Button = Client.UI.Make("Button")
  Button.Style = "Outlined"
  Button.Text = interfaceName
  Button.Color = Client.UI:GetFolderForElement("PrimaryButtonColor").PrimaryButtonColor.Value
  Button.Parent = Client.Panel.Sidebar
  Button.Size = UDim2.new(0.8,0,0.075,0)
  local FaderInstance = Fader.new(Client.Panel:FindFirstChild(interfaceName))
  Client.MainInterfaceFaders[interfaceName] = FaderInstance
  FaderInstance:fadeOut()
  Button.Clicked:Connect(function()
    
  end)
end

Mouse.Move:Connect(function()
	Client.MainInterface.HoverData.Position = UDim2.new(0, Mouse.X + 10, 0, Mouse.Y +15)
end)

Client.Fader = Fader.new(Client.Panel)
Client.Fader:fadeOut()

-- MOVE CLIENT IF NEEDED

if script.Parent ~= Player.PlayerScripts then
  script.Parent = Player.PlayerScripts
  warn("Moved client to PlayerScripts")
end

-- HANDLE CAPES

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

TestService:Message(string.format("Rudimentary Client Initialized in %s second(s)", tick() - Start))

RemoteEvent.OnClientEvent:Connect(function(req, ...)
  local Data = {...}
  if req == "changeKey" then
    Key = Data[1]
  elseif req == "checkKeyValidity" then
    local RemoteName = Data[1]
    RudimentaryFolder:WaitForChild(RemoteName):FireServer(Key)
  elseif Functions[req] then
      local suc, err = pcall(Functions[req], Client, ...)
      if not suc then
        warn(err)
      end
  end
end)

LogService.MessageOut:Connect(function(message)
	RemoteEvent:FireServer("sendClientLog", message, Key)
end)