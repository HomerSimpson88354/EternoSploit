
local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")

-- Configuration
local desiredWalkSpeed = 100  
local maxRetries = 3
local retryDelay = 0.5


local function setWalkSpeed(speed)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
 
    if humanoid.WalkSpeed ~= speed then
        humanoid.WalkSpeed = speed
    end
end


runService.Stepped:Connect(function()
   
    local success, err
    for i = 1, maxRetries do
        success, err = pcall(setWalkSpeed, desiredWalkSpeed)
        if success then break end
        task.wait(retryDelay)
    end
    
  
end)   
