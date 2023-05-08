local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Connection = require(script.Parent.Connection)
local RemoteEventWrapper = require(script.Parent.RemoteEventWrapper)
local RemoteFunctionWrapper = require(script.Parent.RemoteFunctionWrapper)

local RemoteProperty = {}
RemoteProperty.__index = RemoteProperty

function RemoteProperty.new(initialValue: any, folder: Folder?)
    local self = setmetatable({}, RemoteProperty)
    self.ShareOtherUsersData = false
    self._folder = folder
    if not self._folder then
        self._folder = Instance.new("Folder")
        local Event = Instance.new("RemoteEvent")
        Event.Parent = self._folder
        self._event = RemoteEventWrapper:Wrap(Event)
        local Func = Instance.new("RemoteFunction")
        Func.Parent = self._folder
        self._func = RemoteFunctionWrapper:Wrap(Func)
    else
        self._event = RemoteEventWrapper:Wrap(self._folder:FindFirstChildWhichIsA("RemoteEvent"))
        self._func = RemoteFunctionWrapper:Wrap(self._folder:FindFirstChildWhichIsA("RemoteFunction"))
    end
    self._values = {}
    self._environment = RunService:IsServer() and "Server" or "Client"
    self._observers = {}
    self._initialValue = initialValue

    if self._environment == "Client" then
        self._event:Connect(function(...)
            for i, observer in self._observers do
                if observer._callback then
                    task.spawn(observer._callback, ...)
                else
                    table.remove(self._observers, i)
                end
            end
        end)
    end

    self._func:Connect(function(player: Player, request: string, ...)
        local RequestData = {...}

        if request == "Get" then
            if
                RequestData[1]
                and
                RequestData[1] ~= player.UserId
                and
                not self.ShareOtherUsersData
            then
                return "You don't have permission to see the data for this user."
            end

            return self:GetFor(RequestData[1] or player.UserId)
        end
    end)

    return self
end

function RemoteProperty:SetFor(userId: number, newValue: any)
    assert(self._environment == "Server", "RemoteProperty:SetFor() can only be called on the server.")

    self._values[userId] = newValue

    self._event:Fire(Players:GetPlayerByUserId(userId), newValue)
end

function RemoteProperty:GetFor(userId: number)
    if self._environment == "Server" then
        if not self._values[userId] then
            self:SetFor(userId, self._initialValue)
        end
        return self._values[userId]
    elseif self._environment == "Client" then
        local Response
        local CurrentThread = coroutine.running()

        self._func:Invoke("Get", userId):andThen(function(res)
            Response = res
            coroutine.resume(CurrentThread)
        end)
    
        coroutine.yield()
    
        return Response
    end
end

function RemoteProperty:Get()
    assert(self._environment == "Client", "RemoteProperty:Get() can only be called on the client.")

    local Response
    local CurrentThread = coroutine.running()

    self._func:Invoke("Get"):andThen(function(res)
        Response = res
        coroutine.resume(CurrentThread)
    end)

    coroutine.yield()

    return Response
end

function RemoteProperty:Observe(callback: () -> nil)
    assert(self._environment == "Client", "RemoteProperty:Observe() can only be called on the client.")

    local Observer = Connection.new(callback)

    task.defer(function()
        Observer._callback(self:Get())
    end)

    table.insert(self._observers, Observer)
end

return RemoteProperty