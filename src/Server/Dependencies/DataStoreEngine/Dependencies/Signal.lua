local Signal = {}

Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	self.bindableEvent = Instance.new("BindableEvent")
	return self	
end

function Signal:Connect(...)
	return self.bindableEvent.Event:Connect(...)
end

function Signal:Fire(...)
	self.bindableEvent:Fire(...)
end

function Signal:Wait()
	self.bindableEvent.Event:Wait()
end

function Signal:Destroy()
	self.bindableEvent:Destroy()
	self.bindableEvent = nil
	setmetatable(self, nil)
end

return Signal