local EnumHelper = {}

local EnumType

do
    EnumType = {}
    
    EnumType.__index = function(self, index)
        if not rawget(self._items, index) and EnumType[index] then
            return EnumType[index]
        elseif rawget(self, index) then
            return self[index]
        else
            return self._items[index]
        end
    end
    EnumType.__tostring = function(self)
        return self.Name
    end
    
    function EnumType.new(name: string, items: {[number]: any})
        local self = setmetatable({}, EnumType)
        self.Name = name
        self._items = items
        return self
    end
end

function EnumHelper:MakeEnum(typeName: string, items: {[number]: string})
    local EnumTable = {}

    for i, item in items do
        local EnumItemTable = {
            Name = item,
            Value = i,
            EnumType = typeName
        }
        EnumTable[item] = table.freeze(EnumItemTable)
    end

    local EnumItems = setmetatable(EnumTable, {
        __index = function(_, index)
            error(`{index} is not a member of {typeName}`)
        end,
        __newindex = function()
            error(`Can't assign a new member of {typeName}`)
        end
    })

    return EnumType.new(typeName, EnumItems)
end

return EnumHelper