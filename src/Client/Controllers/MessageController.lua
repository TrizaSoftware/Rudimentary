local Dependencies = script.Parent.Parent.Dependencies

-- MODULES

local Controller = require(Dependencies.Controller)
local Fader = require(Dependencies.Fader)

-- VARIABLES

local ENVIRONMENT
local QUEUE = {}
local DISPLAYING_MESSAGE = false

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
    local MessageUI = MessageModule {
        Title = message.Title,
        Text = message.Text,
        CloseCallback = function()
        end
    }
    local MessageFader = Fader.new(MessageUI)
    local NotificationSound = message.Sound and Dependencies.Sounds:FindFirstChild(message.Sound) or Dependencies.Sounds.Message
    local TimeToClose = math.clamp(message.Text:len() * 0.7, 3, 20) -- In Seconds

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