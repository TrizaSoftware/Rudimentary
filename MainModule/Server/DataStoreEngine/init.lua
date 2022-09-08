--[[
   Name: T:Riza DataStore Engine v2
   Programmer(s): CodedJimmy
   License: https://www.gnu.org/licenses/agpl-3.0.en.html
   
   © The T:Riza Corporation 2020-2022
]]

assert(game.Players.LocalPlayer == nil, "Module can not be required from the client.")

local DataStoreService = game:GetService("DataStoreService")
local FirebaseService = require(script.Dependencies.FirebaseService)
local QueueManager = require(script.Dependencies.DataStoreQueueManager)
local Dependencies = script.Dependencies
local Signal = require(Dependencies.Signal)
local _warn = warn
local function warn(...)
	_warn("[DataStoreEngine]:",...)
end

local success, res = pcall(function()
	DataStoreService:GetDataStore("DataStoreEngine_Test"):SetAsync("DataStoreEngine_Test", os.time()) 
end)
if not success then
	if tostring(res):find("403") then
		DataStoreService = require(script.Dependencies.MockDataStoreService)
		warn("Using MockDataStoreService.")
	end
end

local ActiveDataStores = {}

local DataStore = {}
DataStore.__index = DataStore
DataStore.DataStoreTypes = {
	["Ordered"] = "Ordered",
	["Normal"] = "Normal",
	["Global"] = "Global"
}

function DataStore.new(Name:string, Type:string)
	assert(Name ~= nil, "A name is required for the DataStore.")
	assert(DataStore.DataStoreTypes[Type] ~= nil, string.format("%s isn't a valid DataStoreType", tostring(Type)))
	local self = setmetatable({}, DataStore)
	ActiveDataStores[Name] = self
	self.ClassName = "DataStoreInstance"
	self.DSName = Name
	self.ActualDSInstance = if Type == "Normal" then DataStoreService:GetDataStore(Name) elseif Type == "Ordered" then DataStoreService:GetOrderedDataStore(Name) else DataStoreService:GetGlobalDataStore(Name)
	self.QueueManager = QueueManager.new(Name, self.ActualDSInstance)
	return self
end


function DataStore:SetAsync(key, value:any, expediterequest:boolean)
	assert(key ~= nil, "You must specify a key.")
	assert(value ~= nil, "You must specify a value.")
	if expediterequest then
		local suc = pcall(function()
			self.ActualDSInstance:SetAsync(key, value)
		end)
		return suc
	else
		return self.QueueManager:addItemToQueue(key, value)
	end
end

function DataStore:ChangeData(key, value:any, expediterequest:boolean)
	return self:SetAsync(key, value, expediterequest)
end


function DataStore:GetAsync(key)
	return self.ActualDSInstance:GetAsync(key)
end

function DataStore:GetData(key)
	return self:GetAsync(key)
end

function DataStore:FindDataStoreInstance(Name:string)
	return ActiveDataStores[Name]
end

function DataStore:ForceQueueCompletion(key:string)
	self.QueueManager:forceQueueCompletion(key)
end



return DataStore