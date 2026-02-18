_G.infinjump = not _G.infinjump

local plr = game:GetService'Players'.LocalPlayer
local m = plr:GetMouse()
local spaceHeld = false


local moveForward = false
local moveBackward = false
local moveLeft = false
local moveRight = false


m.KeyDown:Connect(function(k)
    local keyCode = k:byte()
    if keyCode == 32 then 
        spaceHeld = true
    elseif keyCode == 119 then 
        moveForward = true
    elseif keyCode == 115 then 
        moveBackward = true
    elseif keyCode == 97 then 
        moveLeft = true
    elseif keyCode == 100 then 
        moveRight = true
    end
end)


m.KeyUp:Connect(function(k)
    local keyCode = k:byte()
    if keyCode == 32 then
        spaceHeld = false
    elseif keyCode == 119 then
        moveForward = false
    elseif keyCode == 115 then
        moveBackward = false
    elseif keyCode == 97 then
        moveLeft = false
    elseif keyCode == 100 then
        moveRight = false
    end
end)

game:GetService'RunService'.RenderStepped:Connect(function()
    if _G.infinjump and spaceHeld then
        local plrChar = game:GetService'Players'.LocalPlayer.Character
        if plrChar then
            local plrh = plrChar:FindFirstChildOfClass'Humanoid'
            local rootPart = plrChar:FindFirstChild'HumanoidRootPart'
            
            if plrh and rootPart then
                local lookVector = rootPart.CFrame.LookVector
                local rightVector = rootPart.CFrame.RightVector
                
                local forwardVelocity = Vector3.new(0, 0, 0)
                local speed = 2
                
                if moveForward then
                    forwardVelocity = forwardVelocity + (lookVector * speed)
                end
                if moveBackward then
                    forwardVelocity = forwardVelocity - (lookVector * speed)
                end
                if moveLeft then
                    forwardVelocity = forwardVelocity - (rightVector * speed)
                end
                if moveRight then
                    forwardVelocity = forwardVelocity + (rightVector * speed)
                end
                
                local upwardVelocity = Vector3.new(0, 5, 0)
                
                local currentVelocity = rootPart.Velocity
                local newVelocity = currentVelocity + upwardVelocity + forwardVelocity
                rootPart.Velocity = newVelocity
            end
        end
    end
end)

