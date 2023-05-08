local RemoteProperty = require(script.Parent.RemoteProperty)

local RemotePropertyHelper = {}

function RemotePropertyHelper:Handle(folder: Folder)
    return RemoteProperty.new(nil, folder)
end

function RemotePropertyHelper:Create(initialValue: any, folder: Folder?)
    return RemoteProperty.new(initialValue, folder)
end

return RemotePropertyHelper