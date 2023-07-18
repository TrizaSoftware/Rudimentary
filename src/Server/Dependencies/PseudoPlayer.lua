local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Folder = ReplicatedStorage:WaitForChild("Rudimentary")
local SharedPackages = Folder.Shared.Packages
local SharedHelpers = Folder.Shared.Helpers

local BetterSignal = require(SharedPackages.BetterSignal)
local TableHelper = require(SharedHelpers.TableHelper)

export type PseudoPlayer = {
  Player: Player,
  AdminLevel: number,
  Destroy: () -> nil,
  _propertyChangedSignalThreads: {thread},
  GetPropertyChangedSignal: () -> {
  }
}

local PseudoPlayers = {}

local PseudoPlayer = {}
PseudoPlayer.__index = PseudoPlayer

function PseudoPlayer.new(player: Player)
  local self: PseudoPlayer = setmetatable({}, PseudoPlayer)
  self.Player = player
  self.AdminLevel = 0
  self._propertyChangedSignalThreads = {}
  PseudoPlayers[player] = self
  return self
end

function PseudoPlayer:GetPropertyChangedSignal(propertyName: string)
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

function PseudoPlayer:Destroy()
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

function PseudoPlayer:GetPseudoPlayerFromPlayer(player: Player): PseudoPlayer
  return PseudoPlayers[player]
end

return PseudoPlayer