_G.infinjump = not _G.infinjump

local plr = game:GetService'Players'.LocalPlayer
local m = plr:GetMouse()
local spaceHeld = false

m.KeyDown:connect(function(k)
	if k:byte() == 32 then
		spaceHeld = true
	end
end)

m.KeyUp:connect(function(k)
	if k:byte() == 32 then
		spaceHeld = false
	end
end)

game:GetService'RunService'.RenderStepped:connect(function()
	if _G.infinjump and spaceHeld then
		local plrChar = game:GetService'Players'.LocalPlayer.Character
		if plrChar then
			local plrh = plrChar:FindFirstChildOfClass'Humanoid'
			local rootPart = plrChar:FindFirstChild'HumanoidRootPart'
			
			if plrh and rootPart then
				
				local forward = plr.Character:FindFirstChild'HumanoidRootPart'.CFrame.LookVector
				
				local upwardVelocity = Vector3.new(0, 5, 0) 
				local forwardVelocity = Vector3.new(forward.X * 5, 0, forward.Z * 5) 
				
				local currentVelocity = rootPart.Velocity
				local newVelocity = currentVelocity + upwardVelocity + forwardVelocity
				rootPart.Velocity = newVelocity
			end
		end
	end
end)
