--[[
	
	Credits: CodedJimmy, The Adonis Development Team

]]

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Character = game.Players.LocalPlayer.Character
local BodyPosition = Character.HumanoidRootPart:WaitForChild("RudimentaryBodyPosition")
local BodyGyro = Character.HumanoidRootPart:WaitForChild("RudimentaryBodyGyro")
local Flying = true
local Directions = {
	["Forward"] = false,
	["Backward"] = false,
	["Right"] = false,
	["Left"] = false,
	["Up"] = false,
	["Down"] = false
}
local Speed = 5

function getCF(part, isFor)
	local cframe = part.CFrame
	local noRot = CFrame.new(cframe.p)
	local x, y, z = (workspace.CurrentCamera.CFrame - workspace.CurrentCamera.CFrame.Position):toEulerAnglesXYZ()
	return noRot * CFrame.Angles(isFor and z or x, y, z)
end


function dirToCom(part, mdir)
	local dirs = {
		Forward = ((getCF(part, true)*CFrame.new(0, 0, -1)) - part.CFrame.p).p;
		Backward = ((getCF(part, true)*CFrame.new(0, 0, 1)) - part.CFrame.p).p;
		Right = ((getCF(part)*CFrame.new(1, 0, 0)) - part.CFrame.p).p;
		Left = ((getCF(part)*CFrame.new(-1, 0, 0)) - part.CFrame.p).p;
	}

	for i,v in next,dirs do
		if (v - mdir).Magnitude <= 1.05 and mdir ~= Vector3.new(0,0,0) then
			Directions[i] = true
		else
			Directions[i] = false
		end
	end
end

function Toggle()
	Flying = not Flying
	Character.Humanoid.PlatformStand = Flying
	if not Flying then
		BodyPosition.MaxForce = Vector3.new(0,0,0)
		BodyGyro.MaxTorque = Vector3.new(0, 0, 0)
	else
		BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BodyPosition.Position = Character.HumanoidRootPart.Position + Vector3.new(0,2,0)
	end
end

function handleInput(Key, enabled)
	if Key == Enum.KeyCode.E then
		Directions.Up = enabled
	elseif Key == Enum.KeyCode.Q then
		Directions.Down = enabled
	elseif Key == Enum.KeyCode.W then
		Directions.Forward = enabled
	elseif Key == Enum.KeyCode.S then
		Directions.Backward = enabled
	elseif Key == Enum.KeyCode.A then
		Directions.Left = enabled
	elseif Key == Enum.KeyCode.D then
		Directions.Right = enabled
	elseif Key == Enum.KeyCode.F and enabled then
		Toggle()
	end
end

function handleAction(AN, IS)
	if AN == "Toggle Flight" and IS == Enum.UserInputState.Begin then
		Toggle()
	end
end

BodyGyro.CFrame = Character.HumanoidRootPart.CFrame
BodyPosition.Position = Character.HumanoidRootPart.Position + Vector3.new(0,2,0)
BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
Character.Humanoid.PlatformStand = true
task.spawn(function()
	while task.wait() do
		if Flying then
			--				local Pos = Character.HumanoidRootPart.Position + ((Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Unit * 20)
			--local MD = Character.Humanoid.MoveDirection
			local NewPos = BodyGyro.CFrame - BodyGyro.CFrame.Position + BodyPosition.Position
			if Directions.Up then
				NewPos = NewPos * CFrame.new(0,Speed,0)
			end
			if Directions.Down then
				NewPos = NewPos * CFrame.new(0,-Speed,0)
			end
			if Directions.Forward then
				NewPos = NewPos + workspace.CurrentCamera.CFrame.LookVector * Speed
			end
			if Directions.Backward then
				NewPos = NewPos - workspace.CurrentCamera.CFrame.LookVector * Speed
			end
			if Directions.Left then
				NewPos = NewPos * CFrame.new(-Speed,0,0)
			end
			if Directions.Right then
				NewPos = NewPos * CFrame.new(Speed,0,0)
			end
			--local CamPos = Character.HumanoidRootPart.Position + ((Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Unit)
			BodyGyro.CFrame = workspace.CurrentCamera.CFrame --[[CFrame.new(Character.HumanoidRootPart.Position, CamPos)]]
			BodyPosition.Position = NewPos.p
			--BodyPosition.Position = Pos + (MD * 20) + if UserInputService:IsKeyDown(Enum.KeyCode.E) then Vector3.new(0,5,0) else if UserInputService:IsKeyDown(Enum.KeyCode.Q) then Vector3.new(0,-5,0) else Vector3.new(0,0,0)
		end
	end
end)

UserInputService.InputBegan:Connect(function(IO, GP)
	if GP then return end
	if UserInputService.KeyboardEnabled then
		if IO.KeyCode ~= Enum.KeyCode.Unknown then
			 handleInput(IO.KeyCode, true)
		end
	end
end)

UserInputService.InputEnded:Connect(function(IO, GP)
	if GP then return end
	if UserInputService.KeyboardEnabled then
		if IO.KeyCode ~= Enum.KeyCode.Unknown then
		    handleInput(IO.KeyCode, false)
		end
	end
end)

if not UserInputService.KeyboardEnabled then
	ContextActionService:BindAction("Toggle Flight", handleAction, true)
	ContextActionService:SetTitle("Toggle Flight", "Toggle Flight")
	Character.Humanoid.Changed:Connect(function()
		dirToCom(Character.HumanoidRootPart, Character.Humanoid.MoveDirection)
	end)
	Character.HumanoidRootPart.ChildRemoved:Connect(function(child)
		if child.Name == "RudimentaryBodyPosition" then
			ContextActionService:UnbindAction("Toggle Flight")
		end
	end)
end