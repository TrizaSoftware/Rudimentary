local characters = {"a","b","c","d","e","f","g","h",'i',"j","k","l",'m',"n","o","p","q","r","s","t","u","v","w","x","y","z","_","-","/",1,2,3,4,5,6,7,8,9,0}
return function (length:number)
	assert(typeof(length) == "number", "Length must be a number.")
	local key = ""
	for i = 1,length do
		local character = characters[math.random(1,#characters)]
		if typeof(character) == "string" and math.random(1,2) == 1 then
			character = character:upper()
		end
		key = key..character
	end
	return key
end