--[[

    ____                   __ 
   / __ \__  ______ ______/ /_
  / /_/ / / / / __ `/ ___/ __/
 / _, _/ /_/ / /_/ / /__/ /_  
/_/ |_|\__,_/\__,_/\___/\__/  
                              
    Ruact - A Roblox UI Creation Engine Named after Rudimentary and React

	Programmer(s): CodedJimmy

	© T:Riza Corporation 2020-2022

]]

local Ruact = {}

function Ruact.new(Item:Instance, Properties:table)
	local CreatedItem = Instance.new(Item)
	for Property, Value in Properties do
		CreatedItem[Property] = Value
	end
	return CreatedItem
end

return Ruact
