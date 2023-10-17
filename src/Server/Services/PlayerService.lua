local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Dependencies = script.Parent.Parent.Dependencies
local Shared = script.Parent.Parent.Parent.Shared

-- MODULES

local Service = require(Dependencies.Service)
local PseudoPlayer = require(Dependencies.PseudoPlayer)
local Promise = require(Shared.Packages.Promise)
local BetterSignal = require(Shared.Packages.BetterSignal)

-- VARIABLES

local Environment

-- SERVICE

local PlayerService = Service.new("PlayerService")
PlayerService.RegisteredPlayers = {}
PlayerService.PlayerInitialized = BetterSignal.new()

function PlayerService:ComputePlayerAdminLevel(player: Player): number
	local PermissionLevels = { Environment.Admins[player.UserId] or 0 }
	local UserPermissionLevelPromises = {}

	for _, permissionConfig in Environment.SystemSettings.PermissionsConfiguration do
		table.insert(
			UserPermissionLevelPromises,
			Promise.new(function(resolve)
				if permissionConfig.Type == "Rank" then
					local PlayerRank = player:GetRankInGroup(permissionConfig.GroupId)

					if permissionConfig.Operation == ">=" then
						if PlayerRank >= permissionConfig.Rank then
							table.insert(PermissionLevels, permissionConfig.Level)
						end
					elseif permissionConfig.Operation == "<=" then
						if PlayerRank <= permissionConfig.Rank then
							table.insert(PermissionLevels, permissionConfig.Level)
						end
					elseif permissionConfig.Operation == "==" then
						if PlayerRank == permissionConfig.Rank then
							table.insert(PermissionLevels, permissionConfig.Level)
						end
					end
				elseif permissionConfig.Type == "Gamepass" then
					if MarketplaceService:UserOwnsGamePassAsync(player.UserId, permissionConfig.GamepassId) then
						table.insert(PermissionLevels, permissionConfig.Level)
					end
				end
				resolve()
			end)
		)
	end

	Promise.all(UserPermissionLevelPromises):await()

	table.sort(PermissionLevels, function(a, b)
		return a > b
	end)

	return PermissionLevels[1]
end

function PlayerService:InitializePlayer(player: Player): typeof(PseudoPlayer)
  local PlayerPseudoPlayer = PseudoPlayer.new(player)
  PlayerPseudoPlayer.AdminLevel = self:ComputePlayerAdminLevel(player)

  local UserEnvironment = Environment.API.BuildClientEnvironment(PlayerPseudoPlayer.AdminLevel)
  UserEnvironment.AdminLevel = PlayerPseudoPlayer.AdminLevel
  Environment.UserInformationProperty:SetFor(player.UserId, UserEnvironment)

  local RudimentaryGui = Instance.new("ScreenGui")
  RudimentaryGui.Name = "RudimentaryInterface"
  RudimentaryGui.ResetOnSpawn = false
  RudimentaryGui.Parent = player.PlayerGui

  local ClientMainScript = script.Parent.Parent.Parent.Client:Clone()
  ClientMainScript.Parent = RudimentaryGui
  ClientMainScript.Disabled = false

  self.PlayerInitialized:Fire(PlayerPseudoPlayer)

  return PlayerPseudoPlayer
end

function PlayerService:GetPseudoPlayer(player: Player)
  return PseudoPlayer:GetPseudoPlayerFromPlayer(player)
end

function PlayerService:Start()
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

function PlayerService:Initialize(env)
  Environment = env
end

return PlayerService