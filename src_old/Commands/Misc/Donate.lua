local MarketPlaceService = game:GetService("MarketplaceService")
local Command = {}
Command.Name = "donate"
Command.Description = "Shows you the donor panel or a purchase prompt."
Command.Aliases = {"cape"}
Command.Prefix = "SecondaryPrefix"
Command.Schema = {}
Command.RequiredAdminLevel = 0
Command.Handler = function(env, plr, args)
	if env.API.checkIsDonor(plr) then
		env.RemoteEvent:FireClient(
			plr,
			"MakeDonorPanel"
		)
	else
		if MarketPlaceService:PlayerOwnsAsset(plr, env.DonorShirt) then
			env.API.makeUserDonor(plr)
			task.defer(Command.Handler, env, plr, args)
			return
		end
		if not workspace.AllowThirdPartySales then
			env.RemoteEvent:FireClient(plr, "makePrivateMessage", {
					Title = "Third Party Sales Not Enabled",
					Text = [[Hey, we're sorry we have to do this, but the game owner hasn't enabled Third Party sales. 
							
					Please go to the following link to purchase Donor Perks.
							
					https://www.roblox.com/catalog/10422629762
					]],
					CanRespond = false,
					CanCopyMessage = true
				}
			)
		else
			MarketPlaceService:PromptPurchase(plr, env.DonorShirt)
		end
	end
end

return Command