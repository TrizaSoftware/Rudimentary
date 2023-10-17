local Dependencies = script.Parent.Parent.Dependencies

-- MODULES

local Controller = require(Dependencies.Controller)
local Fader = require(Dependencies.Fader)

-- VARIABLES

local Environment

-- TYPES

export type Message = {
    Title: string,
    Text: string,
    Sound: string?
}

-- CONTROLLER

local MessageController = Controller.new("MessageController")

function MessageController:DisplayMessage(message: Message)
    local MessageModule = require(Environment.API.GetInterfaceModule("Message"))
    local MessageUI = MessageModule {
        Title = message.Title,
        Text = message.Text,
        CloseCallback = function()
            print("Test")
        end
    }
    local MessageFader = Fader.new(MessageUI)
    local NotificationSound = message.Sound and Dependencies.Sounds:FindFirstChild(message.Sound) or Dependencies.Sounds.Message
    local TimeToClose = math.clamp(message.Text:len() * 0.7, 3, 20) -- In Seconds

    print(TimeToClose)

    MessageFader:fadeOut()
    MessageFader.FadedOut:Wait()
    NotificationSound:Play()
    MessageUI.Parent = Environment.Interface
    MessageFader:fadeIn(1)
end

function MessageController:Start()
    Environment.API.CatchNetworkEvent("displayMessage", function(message: Message)
        self:DisplayMessage(message)
    end)
end

function MessageController:Initialize(Env)
    Environment = Env
end

return MessageController