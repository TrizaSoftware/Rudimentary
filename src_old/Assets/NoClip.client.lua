local Plr = game.Players.LocalPlayer
local Character = Plr.Character
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local RegY = Character.HumanoidRootPart.CFrame.Position.Y
RunService.Stepped:Connect(function()
	for _, item in Character:GetDescendants() do
		if item:IsA("BasePart") then
			item.CanCollide = false
		end
	end
	Character.HumanoidRootPart.CFrame = (Character.HumanoidRootPart.CFrame - Character.HumanoidRootPart.CFrame.Position) + Vector3.new(Character.HumanoidRootPart.Position.X, RegY, Character.HumanoidRootPart.CFrame.Position.Z)
	Humanoid:ChangeState(11)
end)