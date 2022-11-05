--[[

  _______   __     __ 
 /_  __/ | / /__  / /_
  / / /  |/ / _ \/ __/
 / / / /|  /  __/ /_  
/_/ /_/ |_/\___/\__/  
                      

Programmer(s): CodedJimmy

Copyright(c): T:Riza Corporation 2020-2022

]]

local Dependencies = script.Parent.Dependencies

local TNetServer = {}
TNetServer.__index = TNetServer
TNetServer.Dependencies = Dependencies

function TNetServer.new()
    local self = setmetatable({}, TNetServer)
    self.Middleware = {}
    self.EventSignals = {}
    return self
end

function TNetServer:HandleRemoteEvent(event: RemoteEvent)
    assert(event:IsA("RemoteEvent"), "RemoteEvents can only be handled through HandleRemoteEvent.")
    local EventSignal = require(Dependencies.NetSignal).new("Event", event)
    EventSignal.Middleware = self.Middleware
    table.insert(self.EventSignals, EventSignal)
    return EventSignal
end

function TNetServer:HandleRemoteFunction(event: RemoteFunction)
    assert(event:IsA("RemoteFunction"), "RemoteFunctions can only be handled through HandleRemoteFunction.")
    local EventSignal = require(Dependencies.NetSignal).new("Function", event)
    EventSignal.Middleware = self.Middleware
    table.insert(self.EventSignals, EventSignal)
    return EventSignal
end

function TNetServer:UpdateMiddleware(middleware: {})
    self.Middleware = middleware
    for _, signal in self.EventSignals do
        if signal.Event then
            signal.Middleware = middleware
        end
    end
end

return TNetServer