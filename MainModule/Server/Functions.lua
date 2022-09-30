local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")

local RudimentaryFolder = ReplicatedStorage:WaitForChild("Rudimentary")
local Utils = require(RudimentaryFolder.Shared.Utils)


function getImageIdFromDecal(decalId:number)
	local assetInfo = MarketplaceService:GetProductInfo(decalId, Enum.InfoType.Asset)
	
	assert(assetInfo.AssetTypeId == Enum.AssetType.Decal.Value)

	local decal = InsertService:LoadAsset(decalId):FindFirstChildWhichIsA("Decal")
	return decal.Texture
end

function getAccessoryFromId(id:number)
	local assetInfo = MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset)

	assert(assetInfo, "Invalid assetId.")

	local model = InsertService:LoadAsset(id):FindFirstChildWhichIsA("Accessory")
	return model
end

return {
	getAdminLevel = function(plr, env, lvl)
		return tostring(env.AdminLevels[lvl])
	end, 
	giveCape = function(plr, env, color, texture, decal)
		if not env.API.checkIsDonor(plr) then
			return false
		end
		if not color then
			color = BrickColor.new("Mid gray")
		end
		if not texture then
			texture = "SmoothPlastic"
		end
		if not decal or not decal:find("%w") then
			decal = "rbxassetid://10665059114"
		else
			local suc = pcall(function()
				decal = getImageIdFromDecal(tonumber(decal))
			end)
			if not suc then
				decal = if not decal:find("rbxassetid://") then string.format("rbxassetid://%s", decal) else decal
			end
		end
		local Cape = nil
		if plr.Character:FindFirstChild("RudimentaryCape") then
			Cape = plr.Character.RudimentaryCape 
		else
			local Torso = plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("UpperTorso")
			local isR15 = if Torso.Name == "UpperTorso" then true else false
			local CreatedCape = Instance.new("Part")
			CreatedCape.Name = "RudimentaryCape"
			CreatedCape.Size = Vector3.new(2.645, 4.493, 0.031)
			CreatedCape.Position = Torso.Position - (Torso.CFrame.LookVector * 2)
			CreatedCape.Anchored = false
			CreatedCape.CanCollide = false
			CreatedCape.Parent = plr.Character
			local Decal = Instance.new("Decal")
			Decal.Face = Enum.NormalId.Back
			Decal.Parent = CreatedCape
			local Motor = Instance.new("Motor")
			Motor.Name = "RudimentaryCapeMotor"
			Motor.Part0 = CreatedCape
			Motor.Part1 = Torso
			Motor.MaxVelocity = .1
			Motor.Parent = CreatedCape
			Motor.C0 = CFrame.new(0,2.1,0)*CFrame.Angles(0,math.rad(90),0)+Vector3.new(0,0.2,0)
			Motor.C1 = CFrame.new(0,1-((isR15 and 0.2) or 0),(Torso.Size.Z/2))*CFrame.Angles(0,math.rad(90),0)
			Cape = CreatedCape
		end
		Cape.Color = color.Color
		Cape.Material = texture
		Cape.Decal.Texture = decal
		env.API.changeCapeData(plr, {Color = color.Name, Texture = texture, Decal = decal, Equipped = true})
		return true
	end,
	removeCape = function(plr, env)
		if not env.API.checkIsDonor(plr) then
			return false
		end
		if plr.Character:FindFirstChild('RudimentaryCape') then
			plr.Character.RudimentaryCape:Destroy()
			env.API.changeCapeData(plr, {Equipped = false})
		end
	end,
	addAccessory = function(plr, env, id)
		if not env.API.checkIsDonor(plr) then
			return false
		end
		if table.find(env.BannedAssetIds, tonumber(id)) then
			return false
		end
		local accessory = getAccessoryFromId(id)
		plr.Character:AddAccessory(accessory)
	end,
	getWarnings = function(plr, env, userid)
		if env.Admins[plr.UserId] >= env.Commands.warnings.RequiredAdminLevel then
			local Key = string.format("Warnings_%s", userid)
			local Warnings = env.DataStore:GetAsync(Key) or {}
			local WarningData = {}
			for i, warning in Warnings do
				WarningData[i] = {Data = string.format("Warning %s | %s", i, warning.Reason or warning), ExtraData = string.format("Moderator: %s", warning.Moderator or "Error")}
			end
			return WarningData
		else
			return {}
		end
	end,
	getBanHistory = function(plr, env, userid)
		if env.Admins[plr.UserId] >= env.Commands.banhistory.RequiredAdminLevel then
			local Key = string.format("BanHistory_%s", userid)
			local BanHistory = env.DataStore:GetAsync(Key) or {}
			for i, data in BanHistory do
				BanHistory[i] = {Data = data, Clickable = true}
			end
			return BanHistory
		else
			return {}
		end
	end,
	getClientLogs = function(plr, env, userid)
		if env.Admins[plr.UserId] >= env.Commands.clientlogs.RequiredAdminLevel then
			local LogsToSend = {}
			for i,data in env.ClientLogs[plr.UserId] do
				if i <= 1500 then
					table.insert(LogsToSend, {Data = data, Clickable = true})
				end
			end
			return LogsToSend
		else
			return {}
		end
	end,
}