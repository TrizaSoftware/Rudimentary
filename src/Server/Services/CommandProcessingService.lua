local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local Shared = script.Parent.Parent.Parent.Shared

-- MODULES

local StringHelper = require(Shared.Helpers.StringHelper)
local PlayerHelper = require(Shared.Helpers.PlayerHelper)

-- SERVICES

local PlayerService = require(script.Parent.PlayerService)

-- VARIABLES

local Environment
local CommandArgumentProcessors = {
    {
        Type = "Equals",
        ItemToCheck = "me",
        Processor = function(executor, arg: string)
            return executor
        end
    },
    {
        Type = "Equals",
        ItemToCheck = "random",
        Processor = function()
            local PotentialPlayers = Players:GetPlayers()

            return PlayerService:GetPseudoPlayer(PotentialPlayers[Random.new():NextInteger(1, #PotentialPlayers)])
        end
    },
    {
        Type = "Equals",
        ItemToCheck = "all",
        Processor = function()
            local ProcessedPlayers = {}

            for _, player in Players:GetPlayers() do
                table.insert(ProcessedPlayers, PlayerService:GetPseudoPlayer(player))
            end

            return ProcessedPlayers
        end
    },
    {
        Type = "Includes",
        ItemToCheck = "%",
        Processor = function(_, arg: string)
            local TeamName = arg:sub(2,arg:len()):lower()
            local Team: Team

            for _, team in Teams:GetTeams() do
                if team.Name:sub(1,TeamName:len()):lower() == TeamName then
                    Team = team
                end
            end

            if not Team then
                return
            end

            local ProcessedPlayers = {}

            for _, player in Team:GetPlayers() do
                table.insert(ProcessedPlayers, PlayerService:GetPseudoPlayer(player))
            end

            return ProcessedPlayers
        end
    }
}

-- SERVICE

local CommandProcessingService = {
    Name = "CommandProcessingService"
}

function CommandProcessingService:ProcessCommand(player, message: string)
    local MainPrefix = Environment.SystemSettings.MainPrefix
    local SecondaryPrefix = Environment.SystemSettings.SecondaryPrefix
    local UnfilteredArgs = message:split(" ")
    local CommandArgument = UnfilteredArgs[1]

    local DoesMatchMainPrefix = CommandArgument:sub(1, MainPrefix:len()) == MainPrefix or MainPrefix:len() == 0
    local DoesMatchSecondaryPrefix = CommandArgument:sub(1, SecondaryPrefix:len()) == SecondaryPrefix or SecondaryPrefix:len() == 0
    local CommandName

    if DoesMatchMainPrefix then
        CommandName = MainPrefix:len() == 0 and CommandArgument or CommandArgument:split(MainPrefix)[2]
    end

    if DoesMatchSecondaryPrefix then
        CommandName = SecondaryPrefix:len() == 0 and CommandArgument or CommandArgument:split(SecondaryPrefix)[2]
    end

    local CommandInformation = Environment.CommandRegistry[CommandName] or Environment.CommandRegistry[Environment.CommandAliasRegistry[CommandName]]

    if not CommandInformation then
        return
    end

    if (CommandInformation.Prefix == "MainPrefix") and not DoesMatchMainPrefix then
        return
    end

    if (CommandInformation.Prefix == "SecondaryPrefix") and not DoesMatchSecondaryPrefix then
        return
    end

    if player.AdminLevel < CommandInformation.AdminLevel then
        return
    end

    local Arguments = {}

    local ActualIndex = 1

    for i, argument in UnfilteredArgs do
        if i == 1 then continue end

        if table.find(CommandInformation.ArgumentsToProcess, ActualIndex) then
            local ProcessedArgument = {}
            local ArgumentsOfArgument = argument:split(",")

            for _, subArgument in ArgumentsOfArgument do
                local Result

                for _, processor in CommandArgumentProcessors do
                    if processor.Type == "Equals" then
                        if subArgument == processor.ItemToCheck then
                            Result = processor.Processor(player, subArgument)
                        end
                    elseif processor.Type == "Includes" then
                        if StringHelper:CheckCharacterIsInString(processor.ItemToCheck, subArgument) then
                            Result = processor.Processor(player, subArgument)
                        end
                    end
                end

                if not Result then
                    local Player = PlayerHelper:GetPlayerFromName(subArgument)

                    if Player then
                        Result = PlayerService:GetPseudoPlayer(Player)
                    else
                        Result = subArgument
                    end
                end

                if typeof(Result) == "table" and Result[1] then
                    for _, resultItem in Result do
                        table.insert(ProcessedArgument, resultItem)
                    end
                else
                    table.insert(ProcessedArgument, Result)
                end
            end

            argument = ProcessedArgument
        end

        table.insert(Arguments, argument)

        ActualIndex += 1
    end

    local success, response = pcall(CommandInformation.Handler, Environment, player, table.unpack(Arguments))

    if not success then
        Environment.MainRemoteEventWrapper:Fire(player.Player, "displayMessage", {Title = "Command Execution Error", Text = `{self.Name} experienced an error:\n{response}`})
    end
end

function CommandProcessingService:Start()
    PlayerService.PlayerInitialized:Connect(function(pseudoPlayer)
        local Player: Player = pseudoPlayer.Player

        Player.Chatted:Connect(function(message: string)
            self:ProcessCommand(pseudoPlayer, message)
        end)
    end)

    Environment.API.AddNetworkEventCallback("execute", function(player, message)
        self:ProcessCommand(PlayerService:GetPseudoPlayer(player), message)
    end)
end

function CommandProcessingService:Initialize(Env)
    Environment = Env
end

return CommandProcessingService