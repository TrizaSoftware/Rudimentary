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

local TNetClient = {}
TNetClient.__index = TNetClient
TNetClient.Dependencies = Dependencies

function TNetClient.new()
    local self = setmetatable({}, TNetClient)
    self.Middleware = {}
    self.EventSignals = {}
    return self
end

function TNetClient:HandleRemoteEvent(event: RemoteEvent)
    assert(event:IsA("RemoteEvent"), "RemoteEvents can only be handled through HandleRemoteEvent.")
    local EventSignal = require(Dependencies.NetSignal).new("Event", event)
    EventSignal.Middleware = self.Middleware
    table.insert(self.EventSignals, EventSignal)
    return EventSignal
end

function TNetClient:HandleRemoteFunction(event: RemoteFunction)
    assert(event:IsA("RemoteFunction"), "RemoteFunctions can only be handled through HandleRemoteFunction.")
    local EventSignal = require(Dependencies.NetSignal).new("Function", event)
    EventSignal.Middleware = self.Middleware
    table.insert(self.EventSignals, EventSignal)
    return EventSignal
end

function TNetClient:UpdateMiddleware(middleware: {})
    self.Middleware = middleware
    for _, signal in self.EventSignals do
        if signal.Event then
            signal.Middleware = middleware
        end
    end
end

return TNetClient