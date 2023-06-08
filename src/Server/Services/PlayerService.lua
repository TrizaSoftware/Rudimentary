local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Dependencies = script.Parent.Parent.Dependencies

-- MODULES

local Service = require(Dependencies.Service)
local PseudoPlayer = require(Dependencies.PseudoPlayer)

-- VARIABLES

local Environment

-- SERVICE

local PlayerService = Service.new("PlayerService")
PlayerService.RegisteredPlayers = {}

function PlayerService:ComputePlayerAdminLevel(player: Player): number
  local Level: number = Environment.Admins[player.UserId] or 0

  for _, permissionConfig in Environment.SystemSettings.PermissionsConfiguration do
    if permissionConfig.Type == "Rank" then
      if permissionConfig.Operation == ">=" then
        if player:GetRankInGroup(permissionConfig.GroupId) >= permissionConfig.Rank then
          if permissionConfig.Level > Level then
            Level = permissionConfig.Level
          end
        end
      elseif permissionConfig.Operation == "<=" then
        if player:GetRankInGroup(permissionConfig.GroupId) <= permissionConfig.Rank then
          if permissionConfig.Level > Level then
            Level = permissionConfig.Level
          end
        end
      elseif permissionConfig.Operation == "==" then
        if player:GetRankInGroup(permissionConfig.GroupId) == permissionConfig.Rank then
          if permissionConfig.Level > Level then
            Level = permissionConfig.Level
          end
        end
      end
    elseif permissionConfig.Type == "Gamepass" then
      if MarketplaceService:UserOwnsGamePassAsync(player.UserId, permissionConfig.GamepassId) then
        if permissionConfig.Level > Level then
          Level = permissionConfig.Level
        end
      end
    end
  end

  return Level
end

function PlayerService:InitializePlayer(player: Player): PseudoPlayer.PseudoPlayer
  local PlayerPseudoPlayer = PseudoPlayer.new(player)
  PlayerPseudoPlayer.AdminLevel = self:ComputePlayerAdminLevel(player)

  local UserEnvironment = Environment.API.BuildClientEnvironment()
  UserEnvironment.AdminLevel = PlayerPseudoPlayer.AdminLevel
  Environment.UserInformationProperty:SetFor(player.UserId, UserEnvironment)

  local RudimentaryGui = Instance.new("ScreenGui")
  RudimentaryGui.Name = "RudimentaryUi"
  RudimentaryGui.ResetOnSpawn = false
  RudimentaryGui.Parent = player.PlayerGui

  local ClientMainScript = script.Parent.Parent.Parent.Client:Clone()
  ClientMainScript.Parent = RudimentaryGui
  ClientMainScript.Disabled = false
end

function PlayerService:GetPseudoPlayer(player: Player)
  return PseudoPlayer:GetPseudoPlayerFromPlayer(player)
end

function PlayerService:Initialize(env)
  Environment = env

  for _, player in Players:GetPlayers() do
    self:InitializePlayer(player)
  end

  Players.PlayerAdded:Connect(function(player)
    self:InitializePlayer(player)
  end)

  Players.PlayerRemoving:Connect(function(player)
    local PlayerPseudoPlayer = PseudoPlayer:GetPseudoPlayerFromPlayer(player)
    PlayerPseudoPlayer:Destroy()
  end)
end

return PlayerService