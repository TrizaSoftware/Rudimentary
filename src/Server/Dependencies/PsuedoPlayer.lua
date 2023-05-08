local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Folder = ReplicatedStorage:WaitForChild("Rudimentary")
local SharedPackages = Folder.Shared.SharedPackages
local SharedHelpers = Folder.Shared.SharedHelpers

local BetterSignal = require(SharedPackages.BetterSignal)
local TableHelper = require(SharedHelpers.TableHelper)

export type PsuedoPlayer = {
  Player: Player,
  AdminLevel: number,
  Destroy: () -> nil,
  GetPropertyChangedSignal: () -> {
  }
}

local PseudoPlayers = {}

local PsuedoPlayer = {}
PsuedoPlayer.__index = PsuedoPlayer

function PsuedoPlayer.new(player: Player)
  local self: PsuedoPlayer = setmetatable({}, PsuedoPlayer)
  self.Player = player
  self.AdminLevel = 0
  self._propertyChangedSignalThreads = {}
  PseudoPlayers[player] = self
  return self
end

function PsuedoPlayer:GetPropertyChangedSignal(propertyName: string)
  local CurrentProperty = self[propertyName]
  local PropertySignal = BetterSignal.new()

 local Thread = coroutine.create(function()
    while true do
      if typeof(self[propertyName]) == "table" then
        if TableHelper:CloneDeep(self[propertyName]) ~= CurrentProperty then
          CurrentProperty = TableHelper:CloneDeep(self[propertyName])
          PropertySignal:Fire(CurrentProperty)
        end
      else
        if self[propertyName] ~= CurrentProperty then
          CurrentProperty = self[propertyName]
          PropertySignal:Fire(CurrentProperty)
        end
      end
      RunService.Heartbeat:Wait()
    end
  end)

  coroutine.resume(Thread)
  table.insert(self._propertyChangedSignalThreads, Thread)

  return PropertySignal
end

function PsuedoPlayer:Destroy()
  for _, thread in self._propertyChangedSignalThreads do
    coroutine.close(thread)
  end
  PseudoPlayers[self.Player] = nil
  setmetatable(self, nil)
  for property, _ in self do
    self[property] = nil
  end
  self = nil
end

function PsuedoPlayer:GetPseudoPlayerFromPlayer(player: Player): PsuedoPlayer
  return PseudoPlayers[player]
end

return PsuedoPlayer