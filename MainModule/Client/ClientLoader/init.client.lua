if _G.RudimentaryClientStarted then
	script:Destroy()
end

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
local Dependencies = script:WaitForChild("Dependencies")
local Sounds = script:WaitForChild("Sounds")
local Key = nil
local Client = {UI = {}}

-- REDEFINE WARN

local _warn = warn
local function warn(...)
  _warn("[Rudimentary Client]:",...)
end

-- CLIENT TABLE SETUP

function Client.UI:GetFolderForElement(element:string)
  return if Client.MainInterface.Assets[Client.Theme]:FindFirstChild(element) then Client.MainInterface.Assets[Client.Theme] else Client.MainInterface.Assets.Default
end

function Client.UI.Make(element, ...)
  assert(Dependencies:FindFirstChild(element), string.format("%s isn't a valid Dependency.", element))
  local suc, res = pcall(require(Dependencies:FindFirstChild(element)).new, ...)
  if not suc then
    warn(res)
  else
    return res
  end
end

Client.MainInterface = Player.PlayerGui:WaitForChild("RudimentaryUi")
Client.Theme = ClientData.Theme
Client.MainInterfaceHandlers = {}
Client.Panel = Client.UI:GetFolderForElement("Panel").Panel:Clone()

-- INTIALIZE INTERFACES

for _, module in Dependencies.MainInterface:GetChildren() do
  if module:IsA("ModuleScript") and Client.Panel:FindFirstChild(module.Name) then
    Client.MainInterfaceHandlers[module.Name] = require(module)(Client)
  end
end

for interfaceName, _ in Client.MainInterfaceHandlers do
  local Button = Client.UI.Make("Button")
  Button.Text = interfaceName
  Button.Color = Client.UI:GetFolderForElement("PrimaryButtonColor").PrimaryButtonColor.Value
  Button.Parent = Client.MainInterface
end

-- MOVE CLIENT IF NEEDED

if script.Parent ~= Player.PlayerScripts then
  script.Parent = Player.PlayerScripts
  warn("Moved client to PlayerScripts")
end

TestService:Message(string.format("Rudimentary Client Initialized in %s second(s)", tick() - Start))