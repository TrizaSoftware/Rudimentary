local Players = game:GetService("Players")
local Dependencies = script.Parent.Parent.Dependencies

-- MODULES

local Service = require(Dependencies.Service)
local PseudoPlayer = require(Dependencies.PsuedoPlayer)

-- VARIABLES

local Environment

-- SERVICE

local PlayerService = Service.new("PlayerService")
PlayerService.RegisteredPlayers = {}

function PlayerService:InitializePlayer(player: Player): PseudoPlayer.PsuedoPlayer
  local RudimentaryGui = Instance.new("ScreenGui")
  RudimentaryGui.Name = "RudimentaryUi"
  RudimentaryGui.ResetOnSpawn = false
  RudimentaryGui.Parent = player.PlayerGui

  local ClientMainScript = script.Parent.Parent.Parent.Client:Clone()
  ClientMainScript.Parent = RudimentaryGui
  ClientMainScript.Disabled = false
  
  local UserEnvironment = Environment.API.BuildClientEnvironment()
  Environment.UserInformationProperty:SetFor(player.UserId, UserEnvironment)
end

function PlayerService:Initialize(env)
  Environment = env

  for _, player in Players:GetPlayers() do
    self:InitializePlayer(player)
  end

  game.Players.PlayerAdded:Connect(function(player)
    self:InitializePlayer(player)
  end)
end

return PlayerService