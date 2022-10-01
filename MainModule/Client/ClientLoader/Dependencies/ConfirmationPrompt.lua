local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RudimentaryFolder = ReplicatedStorage:WaitForChild("Rudimentary") :: Folder
local SharedModules = RudimentaryFolder:WaitForChild("Shared") :: Folder
local ConfirmationPrompt = {}
ConfirmationPrompt.__index = ConfirmationPrompt

function ConfirmationPrompt.new(Client, message)
    local self = setmetatable({}, ConfirmationPrompt)
    local Window = Client.UI.Make("Window", "Confirmation Prompt")
    local ActualWindow = Window.WindowInstance
    local Button = Client.UI.Make("Button")
    Button.Color = Color3.fromRGB(27, 180, 27)
    Button.Text = "Yes"
    Button.Parent = ActualWindow
    return self
end

return ConfirmationPrompt