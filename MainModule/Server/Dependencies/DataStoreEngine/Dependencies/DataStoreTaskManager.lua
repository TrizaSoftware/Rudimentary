local DataStoreService = game:GetService("DataStoreService")
local Promise = require(script.Parent.RbxLuaPromise)
local Signal = require(script.Parent.Signal)
local TaskManager = {}
TaskManager.__index = TaskManager

local function getRequestBudgetForType(type:EnumItem)
  return DataStoreService:GetRequestBudgetForRequestType(type)
end

function TaskManager.new(DataStoreInstance)
  local self = setmetatable({}, TaskManager)
  self.DataStore = DataStoreInstance.DataStore
  self.Tasks = {
    ["Get"] = {},
    ["Set"] = {}
  }
  self.CurrentTasks = {
    ["Get"] = {},
    ["Set"] = {}
  }
  return self
end


function TaskManager:AddTask(taskType, data)
  assert(self.Tasks[taskType], "Invalid TaskType.")
  local ResultSignal = Signal.new()
  data.signal = ResultSignal
  if not self.Tasks[taskType][data.key] then
   self.Tasks[taskType][data.key] = {}
  end
  table.insert(self.Tasks[taskType][data.key], #self.Tasks[taskType][data.key] + 1, data)
  if not self.CurrentTasks[taskType][data.key] then
    task.spawn(function()
      self.CurrentTasks[taskType][data.key] = true
      self:HandleTasksForKey(taskType, data.key)
    end)
  end
  return ResultSignal
end

function TaskManager:HandleTasksForKey(taskType:string, key)
  task.wait()
  if taskType == "Get" then
    for _, tsk in self.Tasks[taskType][key] do
      local CanResolve = false
      if getRequestBudgetForType(Enum.DataStoreRequestType.GetAsync) > 0 then
        CanResolve = true
      else
        repeat
          task.wait(0.5)
        until getRequestBudgetForType(Enum.DataStoreRequestType.GetAsync) > 0
        CanResolve = true
      end
      if not CanResolve then
        repeat
          task.wait()
        until CanResolve
      end
      local value = self.DataStore:GetAsync(key)
      tsk.signal:Fire(value)
      table.remove(self.Tasks[taskType][key], table.find(self.Tasks[taskType][key], tsk))
    end
  elseif taskType == "Set" then
    for _, tsk in self.Tasks[taskType][key] do
      if #self.Tasks[taskType][key] == 0 then
        break
      end
      local CanResolve = false
      if getRequestBudgetForType(Enum.DataStoreRequestType.SetIncrementAsync) > 0 then
        CanResolve = true
      else
        repeat
          task.wait(0.5)
        until getRequestBudgetForType(Enum.DataStoreRequestType.SetIncrementAsync) > 0
        CanResolve = true
      end
      if not CanResolve then
        repeat
          task.wait()
        until CanResolve
      end
      local suc, err = pcall(function()
        self.DataStore:SetAsync(key, tsk.value)
      end)
      tsk.signal:Fire(suc, err)
      table.remove(self.Tasks[taskType][key], table.find(self.Tasks[taskType][key], tsk))
      task.wait(3)
    end
  end
  if #self.Tasks[taskType][key] > 0 then
    self:HandleTasksForKey(taskType, key)
  else
    self.CurrentTasks[taskType][key] = false
  end
end

function TaskManager:ClearTaskQueue(taskType, key)
  assert(self.Tasks[taskType], "Invalid TaskType.")
  self.Tasks[taskType][key] = {}
end

return TaskManager