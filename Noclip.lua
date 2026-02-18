_G.noclip = not _G.noclip
print(_G.noclip)

local plr = game:GetService('Players').LocalPlayer
local char = plr.Character

local function disableCollision(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function setupNoclip(character)
    if not character then return end
    
    if _G.NCLoop then
        _G.NCLoop:Disconnect()
    end
    
    _G.NCLoop = game:GetService("RunService").RenderStepped:Connect(function()
        if _G.noclip then
            disableCollision(character)
        end
    end)
end

if char then
    setupNoclip(char)
end

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    setupNoclip(newChar)
end)
