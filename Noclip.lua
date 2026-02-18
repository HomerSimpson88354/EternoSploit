_G.noclip = not _G.noclip
print(_G.noclip)

local plr = game:GetService('Players').LocalPlayer
local char = plr.Character

if not char then return end

local function disableCollision()
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

if char:FindFirstChild("LowerTorso") then
	if _G.NCLoop then
		_G.NCLoop:Disconnect()
	end
	
	_G.NCLoop = game:GetService("RunService").RenderStepped:Connect(function()
		if _G.noclip then
			disableCollision()
		end
	end)
else

	if _G.NCLoop then
		_G.NCLoop:Disconnect()
	end
	
	_G.NCLoop = game:GetService("RunService").RenderStepped:Connect(function()
		if _G.noclip then
			disableCollision()
		end
	end)
end
