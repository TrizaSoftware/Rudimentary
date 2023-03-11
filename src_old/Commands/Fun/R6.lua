local Command = {}
Command.Name = "r6"
Command.Description = "Morphs the specified user(s) into R6."
Command.Aliases = {"mr6"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 2
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env, plr, args)
  if not args[1] then
		env.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't set no one to R6."})
		env.RemoteEvent:FireClient(plr, "playSound", "Error")
	end

  for _, target in args[1] do
    local Rig = env.Assets.R6Rig:Clone()
    Rig.Parent = workspace
    Rig.Name = target.Name
    Rig.Humanoid.DisplayName = target.DisplayName
    Rig.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    local Script = env.Assets.R6Animate:Clone()
    local HealthScript = env.Assets.Health:Clone()
    local OldChar = target.Character
    target.Character = Rig
    Script.Parent = Rig
    HealthScript.Parent = Rig
    Script.Disabled = false
    HealthScript.Disabled = false
    OldChar:Destroy()
    env.RemoteEvent:FireClient(
      target,
      "ViewUser",
      target
    )
    pcall(function()
      Rig.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(target.UserId))
    end)
  end
end

return Command