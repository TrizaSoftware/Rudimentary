local Types = require(script.Parent.Dependencies.Types)
local RemoteEventWrapper = require(script.Parent.Dependencies.RemoteEventWrapper)
local RemoteFunctionWrapper = require(script.Parent.Dependencies.RemoteFunctionWrapper)
local RemotePropertyHelper = require(script.Parent.Dependencies.RemotePropertyHelper)

local Server = {}
Server.__index = Server

function Server.new(middleware: Types.Middleware?)
    local self = setmetatable({}, Server)
    self._events = {}
    self._remoteProperties = {}
    self.Middleware = middleware
    return self
end

function Server:WrapRemoteEvent(event: RemoteEvent)
    local WrappedEvent = RemoteEventWrapper:Wrap(event, self.Middleware)
    table.insert(self._events, WrappedEvent)
    return WrappedEvent
end

function Server:WrapRemoteFunction(func: RemoteFunction)
    local WrappedFunc = RemoteFunctionWrapper:Wrap(func, self.Middleware)
    table.insert(self._events, WrappedFunc)
    return WrappedFunc
end

function Server:DispatchGlobalMiddlewareChange(middleware: Types.Middleware)
    self.Middleware = middleware
    for _, event in self._events do
        event.Middleware = middleware
    end
end

function Server:CreateRemoteProperty(initialValue: any, folder: Folder?)
    local RemoteProperty = RemotePropertyHelper:Create(initialValue, folder)

    table.insert(self._remoteProperties, RemoteProperty)

    return RemoteProperty
end

return Server