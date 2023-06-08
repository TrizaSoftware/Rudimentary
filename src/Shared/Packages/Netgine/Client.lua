local Types = require(script.Parent.Dependencies.Types)
local RemoteEventWrapper = require(script.Parent.Dependencies.RemoteEventWrapper)
local RemoteFunctionWrapper = require(script.Parent.Dependencies.RemoteFunctionWrapper)
local RemotePropertyHelper = require(script.Parent.Dependencies.RemotePropertyHelper)

local Client = {}
Client.__index = Client

function Client.new(middleware: Types.Middleware?)
    local self = setmetatable({}, Client)
    self._events = {}
    self._remoteProperties = {}
    self.Middleware = middleware
    return self
end

function Client:WrapRemoteEvent(event: RemoteEvent)
    local WrappedEvent = RemoteEventWrapper:Wrap(event, self.Middleware)
    table.insert(self._events, WrappedEvent)
    return WrappedEvent
end

function Client:WrapRemoteFunction(func: RemoteFunction)
    local WrappedFunc = RemoteFunctionWrapper:Wrap(func, self.Middleware)
    table.insert(self._events, WrappedFunc)
    return WrappedFunc
end

function Client:DispatchGlobalMiddlewareChange(middleware: Types.Middleware)
    self.Middleware = middleware
    for _, event in self._events do
        event.Middleware = middleware
    end
end

function Client:RegisterRemoteProperty(folder: Folder?)
    local RemoteProperty = RemotePropertyHelper:Handle(folder)

    table.insert(self._remoteProperties, RemoteProperty)

    return RemoteProperty
end

return Client