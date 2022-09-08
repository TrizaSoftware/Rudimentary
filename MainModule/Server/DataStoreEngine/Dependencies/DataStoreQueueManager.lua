local Signal = require(script.Parent.Signal)
local Key = require(script.Parent.Key)
local DataStoreQueueManager = {}
DataStoreQueueManager.__index = DataStoreQueueManager

function DataStoreQueueManager.new(DataStoreName:string, DSInstance:DataStore)
	local self = setmetatable({}, DataStoreQueueManager)
	self.ClassName = "DataStoreQueueManager"
	self.Queue = {}
	self.Cooldowns = {}
	self.HandlingQueue = {}
	self.itemAddedToQueue = Signal.new()
	self.DSInstance = DSInstance
	self.QueueHandlers = {}
	return self
end

function DataStoreQueueManager:addItemToQueue(key, value)
	assert(key ~= nil, "A key must be specified.")
	assert(value ~= nil, "A value must be specified.")
	if not self.Queue[key] then self.Queue[key] = {} end
	local requestId = Key(64)
	local resultEvent = Signal.new()
	self.Queue[key][#self.Queue[key] + 1] = {newValue = value, requestId = requestId, remote = resultEvent}
	if not self.HandlingQueue[key] then
		task.spawn(function()
			self:handleQueueForKey(key)
		end)
	end
	return {requestId = requestId, result = resultEvent}
end

function DataStoreQueueManager:handleQueueForKey(key)
	task.spawn(function()
		if self.HandlingQueue[key] == true then return end	
		local queueHandler = {}
		queueHandler.Stop = false
		function queueHandler:Cancel()
			queueHandler.Stop = true
		end
		self.QueueHandlers[key] = queueHandler
		self.HandlingQueue[key] = true
		if self.Cooldowns[key] then
			task.wait(1)
			self.Cooldowns[key] = false
		end
		for i, item in pairs(self.Queue[key]) do
			local suc = pcall(function()
				self.DSInstance:SetAsync(key, item.newValue)
			end)
			item.remote:Fire(suc)
			table.remove(self.Queue[key],i)
			local te = 0
			repeat
				task.wait(0.1)
				te += 0.1
			until te >= 1 or queueHandler.Stop
			if queueHandler.Stop then
				break
			end
		end
		if #self.Queue[key] > 0 then
			self.Cooldowns[key] = true
			self:handleQueueForKey(key)
			self.HandlingQueue[key] = false
			self.QueueHandlers[key] = nil
		else
			self.HandlingQueue[key] = false
			self.QueueHandlers[key] = nil
		end
	end)
end

function DataStoreQueueManager:forceQueueCompletion(key)
	if self.Queue[key] then
		if self.Queue[key][#self.Queue[key]] then
			if self.QueueHandlers[key] then
				self.QueueHandlers[key]:Cancel()
			end
			local newValue = self.Queue[key][#self.Queue[key]].newValue
			self.Queue[key] = {}
			self.HandlingQueue[key] = false
			local suc = pcall(function()
				repeat
					task.wait()
				until not self.HandlingQueue[key]
				self.DSInstance:SetAsync(key, newValue)
			end)
		end
	end
end

return DataStoreQueueManager