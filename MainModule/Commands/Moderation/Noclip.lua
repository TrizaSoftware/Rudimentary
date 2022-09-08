local Command = {}
Command.Name = "noclip"
Command.Description = "Lets user(s) noclip."
Command.Aliases = {"nc"}
Command.Prefix = "MainPrefix"
Command.RequiredAdminLevel = 1
Command.Schema = {{["Name"] = "User(s)", ["Type"] = "String"}}
Command.ArgsToReplace = {1}
Command.Handler = function(env : table, plr : Player, args : table)
   if not args[1] then
        env.API.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = "You can't let no one noclip."})
        env.RemoteEvent:FireClient(plr, "playSound", "Error")
        return
   end 

   for _, target : Player in args[1] do
        if typeof(target) == "Instance" then
            if target.Character:FindFirstChild("RudimentaryNoclipHandler") then
                env.API.RemoteEvent:FireClient(plr, "showHint", {Title = "Error", Text = string.format("%s is already noclipping.", target.Name)})
                env.RemoteEvent:FireClient(plr, "playSound", "Error")
                continue
            end
            local Clone = env.Shared.NoClip:Clone()
            Clone.Parent = target.Character
            Clone.Name = "RudimentaryNoClipHandler"
            Clone.Disabled = false
        end
   end
end

return Command
