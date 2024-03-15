local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dependencies = script.Parent.Parent.Dependencies

-- MODULES

local Fader = require(Dependencies.Fader)
local Fusion = require(ReplicatedStorage.Rudimentary.Shared.Packages.Fusion)

-- VARIABLES

local ENVIRONMENT
local QUEUE = {}
local DISPLAYING_MESSAGE = false
local Value = Fusion.Value

-- TYPES

export type Message = {
    Title: string,
    Text: string,
    Sound: string?
}

-- CONTROLLER

local MessageController = {
    Name = "MessageController"
}

function MessageController:DisplayMessage(message: Message)
    DISPLAYING_MESSAGE = true
    local MessageModule = require(ENVIRONMENT.API.GetInterfaceModule("Message"))
    local NotificationSound = message.Sound and Dependencies.Sounds:FindFirstChild(message.Sound) or Dependencies.Sounds.Message
    local TimeToClose = math.clamp(math.round(message.Text:len() * 0.4), 5, 20) -- In Seconds
    local CloseTimer = Value(TimeToClose)
    local MessageUI = MessageModule {
        Title = message.Title,
        Text = message.Text,
        Countdown = CloseTimer,
        CloseCallback = function()
        end
    }
    local MessageFader = Fader.new(MessageUI)

    task.spawn(function()
        for i = TimeToClose, 0, -1 do
            CloseTimer:set(i)
            task.wait(1)
        end

        MessageFader:fadeOut(1)
        task.wait(1.1)
        MessageFader:Destroy()
        MessageUI:Destroy()
    end)

    MessageFader:fadeOut()
    MessageFader.FadedOut:Wait()
    NotificationSound:Play()
    MessageUI.Parent = ENVIRONMENT.Interface
    MessageFader:fadeIn(1)
end

function MessageController:Start()
    ENVIRONMENT.API.CatchNetworkEvent("displayMessage", function(message: Message)
        self:DisplayMessage(message)
    end)
end

function MessageController:Initialize(Env)
    ENVIRONMENT = Env
end

return MessageController