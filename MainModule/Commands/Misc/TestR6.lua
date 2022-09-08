local Command = {}
Command.Name = "testr6"
Command.Description = "does cool r6 things"
Command.Aliases = {"tr6"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {}
Command.Handler = function(env, plr, args)
	local Rig = env.Assets.R6Rig:Clone()
	Rig.Parent = workspace
	Rig.Name = plr.Name
	Rig.Humanoid.DisplayName = plr.DisplayName
	Rig.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
	local Script = env.Assets.R6Animate:Clone()
	local HealthScript = env.Assets.Health:Clone()
	local OldChar = plr.Character
	plr.Character = Rig
	Script.Parent = Rig
	HealthScript.Parent = Rig
	Script.Disabled = false
	HealthScript.Disabled = false
	OldChar:Destroy()
	env.RemoteEvent:FireClient(
		plr,
		"ViewUser",
		plr
	)
	Rig.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(plr.UserId))
end

return Command