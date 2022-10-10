local GroupService = game:GetService("GroupService")
local module = {}

function module.formatString(str:string)
	str = tostring(str)
	local letters = str:split("")
	local strings = {}
	for i, letter in pairs(letters) do
		if letter == "{" then
			local startpos = i
			local endpos = nil
			for oi, ltr in pairs(str:sub(i+1,str:len()):split("")) do
				if ltr == "}" then
					endpos = oi+i
					break
				end
			end
			if endpos then
				table.insert(strings,str:sub(startpos, endpos))
			end
		end
	end
	for _, data in pairs(strings) do
		local nd
		nd = data:gsub("{","")
		nd = nd:gsub("}","")
		local args = nd:split(":") 
		local datatype = args[1]
		if datatype == "time" then
			if tonumber(args[2]) < 0 then
				args[2] = "0"
			end
			if args[3] == "ampm" then
				str = str:gsub(data, string.format("%s:%s %s", os.date("%I", tonumber(args[2])), os.date("%M", tonumber(args[2])), os.date("%p", tonumber(args[2]))))
			elseif args[3] == "sdi" then
				str = str:gsub(data, string.format("%s %s:%s", os.date("%x", tonumber(args[2])), os.date("%I", tonumber(args[2])), os.date("%M", tonumber(args[2]))))
			elseif not args[3] then
				str = str:gsub(data, string.format("%s:%s", os.date("%I", tonumber(args[2])), os.date("%M", tonumber(args[2]))))
			end
		elseif datatype == "group" then
			local id = tonumber(args[2])
			if args[3] == "name" then
				str = str:gsub(data, GroupService:GetGroupInfoAsync(id).Name)
			elseif args[4] then
				local userid = tonumber(args[3])
				if args[4] == "role" then
					str = str:gsub(data, game.Players:GetPlayerByUserId(userid):GetRoleInGroup(id))
				end
			end
		end
	end
	return str
end

return module