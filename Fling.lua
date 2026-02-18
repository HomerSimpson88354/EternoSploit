local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local flingForce = 5000 
local heldTarget = nil
local isHolding = false

mouse.Button2Down:Connect(function()
    if isHolding then return end
    if not mouse.Target then return end

    local target = mouse.Target
    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end


    if target:IsA("Terrain") then return end

    
    local isPlayerPart = target.Parent and target.Parent:IsA("Model") and target.Parent:FindFirstChild("Humanoid")
    local isObject = target:IsA("BasePart") and not target.Anchored

    if not (isPlayerPart or isObject) then return end

  
    isHolding = true
    heldTarget = target
    print("Picked up: " .. target.Name .. " under crosshair")
end)

mouse.Button2Up:Connect(function()
    if not isHolding or not heldTarget then return end

    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    
    local direction = (heldTarget.Position - rootPart.Position).Unit
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = direction * flingForce
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.P = math.huge
    bodyVelocity.Parent = heldTarget

    game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
    print("Flung: " .. heldTarget.Name .. " with force direction " .. tostring(direction))

  
    isHolding = false
    heldTarget = nil
end)
