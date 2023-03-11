local Plr = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Icons = require(script.Parent.MaterialIcons)
local Snackbar = {}

function Snackbar.new(icon, text)
	task.spawn(function()
		local Frame = script.Frame:Clone()
		if icon == "warning" then
			Frame.Icon.Image = string.format("rbxassetid://%s", Icons.Warning)
		elseif icon == "error" then
			Frame.Icon.Image = string.format("rbxassetid://%s", Icons.Error)
		else
			Frame.Icon.Image = string.format("rbxassetid://%s", Icons.Info)
		end
		Frame.MainText.Text = text or ""
		Frame.MainText.TextTransparency = 1
		Frame.Parent = Plr.PlayerGui:WaitForChild("RudimentaryUi")
		task.wait(0.01)
		Frame:TweenPosition(UDim2.new(0.5, 0,0.916, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,1,true)
		task.wait(1)
		task.spawn(function()
			task.wait(0.5)
			TweenService:Create(Frame.MainText, TweenInfo.new(1.5,Enum.EasingStyle.Quint),{TextTransparency = 0}):Play()
		end)
		Frame:TweenSizeAndPosition(UDim2.new(0.304, 0,0.041, 0),UDim2.new(0.35, 0,0.916, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,2,true)
		task.wait(4)
		TweenService:Create(Frame.MainText, TweenInfo.new(1.5,Enum.EasingStyle.Quint),{TextTransparency = 1}):Play()
		Frame:TweenSizeAndPosition(UDim2.new(0.026, 0,0.041, 0),UDim2.new(0.5, 0,0.916, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,2,true)
		task.wait(2)
		Frame:TweenPosition(UDim2.new(0.5, 0,1.916, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quint,1,true)
		task.wait(1)
		Frame:Destroy()
	end)
end

return Snackbar