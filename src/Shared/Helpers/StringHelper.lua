local StringHelper = {}

function StringHelper:CheckCharacterIsInString(character: string, targetString: string)
    for _, char in targetString:split("") do
        if char == character then
            return true
        end
    end

    return false
end

return StringHelper