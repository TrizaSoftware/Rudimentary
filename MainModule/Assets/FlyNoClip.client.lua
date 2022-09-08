local Plr = game.Players.LocalPlayer
local Character = Plr.Character
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
RunService.Stepped:Connect(function()
	if not Character:FindFirstChild("HumanoidRootPart") then return end
	for _, item in Character:GetDescendants() do
		if item:IsA("BasePart") then
			item.CanCollide = false
		end
	end
	Character.HumanoidRootPart.CFrame = (Character.HumanoidRootPart.CFrame - Character.HumanoidRootPart.CFrame.Position) + Character.HumanoidRootPart.Position
	Humanoid:ChangeState(11)
end)