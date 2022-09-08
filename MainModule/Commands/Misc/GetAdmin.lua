local MarketPlaceService = game:GetService("MarketplaceService")
local Command = {}
Command.Name = "getadmin"
Command.Description = "Prompts you to get the admin."
Command.Aliases = {"getmodule"}
Command.Prefix = "SecondaryPrefix"
Command.Schema = {}
Command.RequiredAdminLevel = 0
Command.Handler = function(env, plr, args)
	if not workspace.AllowThirdPartySales then
		env.RemoteEvent:FireClient(plr, "makePrivateMessage", {
				Title = "Third Party Sales Not Enabled",
				Text = [[Hey, we're sorry we have to do this, but the game owner hasn't enabled Third Party sales. 
							
				Please go to the following link to get the admin script.
							
				https://www.roblox.com/catalog/10479660883
				]],
				CanRespond = false,
				CanCopyMessage = true
			}
		)
	else
		MarketPlaceService:PromptPurchase(plr, 10479660883)
	end
end

return Command