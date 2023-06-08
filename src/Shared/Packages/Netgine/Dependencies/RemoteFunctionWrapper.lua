local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Types = require(script.Parent.Types)
local EnumHelper = require(script.Parent.EnumHelper)
local Connection = require(script.Parent.Connection)
local Promise = require(script.Parent.Parent:FindFirstChild("Packages") and script.Parent.Parent.Packages.Promise or script.Parent.Parent.Parent.Promise)

local RequestType = EnumHelper:MakeEnum("RemoteFunctionWrapper.RequestType", {
    "Outbound",
    "Inbound"
})

local RemoteFunctionWrapper = {}
RemoteFunctionWrapper.__index = RemoteFunctionWrapper

function RemoteFunctionWrapper:Wrap(func: RemoteFunction, middleware: Types.Middleware?)
    local self = setmetatable({}, RemoteFunctionWrapper)
    
    self.Middleware = middleware
    self.Func = func or Instance.new("RemoteFunction")
    self._environment = RunService:IsServer() and "Server" or "Client"
    self._connections = {}
    self._rateLimits = {}
    self._rateLimiterThread = coroutine.create(function()
        while task.wait(60) do
            if not self.Middleware or not self.Middleware.RequestsPerMinute then continue end
            for _, player in self._rateLimits do
                self._rateLimits[player] = self.Middleware.RequestsPerMinute
            end
        end
    end)

    self.Func[self._environment == "Server" and "OnServerInvoke" or "OnClientInvoke"] = function(...)
        return self:HandleRequest(RequestType.Inbound, ...)
    end

    if self._environment == "Server" then
        coroutine.resume(self._rateLimiterThread)
    end
    
    return self
end

function RemoteFunctionWrapper:Connect(callback: Types.ConnectionCallback)
    local CreatedConnection = Connection.new(callback)
    table.insert(self._connections, CreatedConnection)
end

function RemoteFunctionWrapper:HandleRequest(type: EnumItem, ...)
    local Args = {...}
    local ClonedArgs = table.clone(Args)
    table.insert(ClonedArgs, 1, self.Func.Name)
    local Middleware = self.Middleware :: Types.Middleware
    if type == RequestType.Outbound then
        if Middleware and Middleware.Outbound then
            for _, callback in Middleware.Outbound do
                task.spawn(callback, table.unpack(ClonedArgs))
            end
        end
    elseif type == RequestType.Inbound then
        if Middleware then
            if Middleware.RequestsPerMinute then
                if not self._rateLimits[Args[2]] then
                    self._rateLimits[Args[2]] = Middleware.RequestsPerMinute
                else
                    self._rateLimits[Args[2]] -= 1
                end

                if self._rateLimits[Args[2]] <= 0 then
                    return "Rate Limit Reached"
                end
            end
            if Middleware.Inbound then
                for _, callback in Middleware.Inbound do
                    task.spawn(callback, table.unpack(ClonedArgs))
                end
            end
        end

        local ResponsePromises = {}
        local Responses = {}

        for i, connection in self._connections do
            if connection._callback then
                table.insert(ResponsePromises, Promise.new(function(resolve)
                    local Response = connection._callback(table.unpack(Args))
                    table.insert(Responses, Response)
                    resolve()
                end))
            else
                table.remove(self._connections, i)
            end
        end

        Promise.all(ResponsePromises):await()

        return #Responses > 1 and Responses or Responses[1]
    end
end

function RemoteFunctionWrapper:Invoke(...)
    local Args = {...}

    if self._environment == "Server" then
        self:HandleRequest(RequestType.Outbound, ...)
        local InvokePromise = Promise.new(function(resolve)
            resolve(self.Func:InvokeClient(table.unpack(Args)))
        end)

        return InvokePromise
    elseif self._environment == "Client" then
        self:HandleRequest(RequestType.Outbound, ...)
        local InvokePromise = Promise.new(function(resolve)
            resolve(self.Func:InvokeServer(table.unpack(Args)))
        end)

        return InvokePromise
    end
end

function RemoteFunctionWrapper:InvokeGroup(group: {[number]: Player}, ...)
    assert(self._environment == "Server", "RemoteFunctionWrapper:InvokeGroup() can only be called on the server.")

    local Args = {...}
    local ClonedArgs = table.clone(Args)

    table.insert(ClonedArgs, 1, group)

    self:HandleRequest(RequestType.Outbound, table.unpack(ClonedArgs))

    return Promise.new(function(resolve)
        local ResponsePromises = {}
        local Responses = {}

        for _, player in group do
            table.insert(ResponsePromises, Promise.new(function(responseResolve)
                Responses[player] = self.Func:InvokeClient(table.unpack(Args))
                responseResolve()
            end))
        end

        Promise.all(ResponsePromises):await()

        resolve(Responses)
    end)
end

function RemoteFunctionWrapper:InvokeFilter(filter: (player: Player) -> boolean, ...)
    local Args = {...}
    local ClonedArgs = table.clone(Args)

    local ValidPlayers: {[number]: Player} = {}

    for _, player in Players:GetPlayers() do
        if filter(player) then
            table.insert(ValidPlayers, player)
        end
    end

    table.insert(ClonedArgs, 1, ValidPlayers)

    return Promise.new(function(resolve)
        local ResponsePromises = {}
        local Responses = {}

        for _, player in ValidPlayers do
            table.insert(ResponsePromises, Promise.new(function(responseResolve)
                Responses[player] = self.Func:InvokeClient(table.unpack(Args))
                responseResolve()
            end))
        end

        Promise.all(ResponsePromises):await()

        resolve(Responses)
    end)
end

return RemoteFunctionWrapper