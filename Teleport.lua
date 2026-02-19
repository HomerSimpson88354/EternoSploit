local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local gui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
gui.Name = "EternoTeleport"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100 -- High value to ensure it renders on top of other GUIs
gui.IgnoreGuiInset = true -- Ignore Roblox's default insets like the topbar

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local dragToggle = false
local dragInput, dragStart, startPos
local UserInputService = game:GetService("UserInputService")

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = false
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Eterno Teleport"
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 20
title.Font = Enum.Font.SourceSansBold

local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.Size = UDim2.new(1, -20, 0, 120)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local selectedPlayer = nil
local function refreshPlayers()
    scroll:ClearAllChildren()
    local y = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Position = UDim2.new(0, 5, 0, y)
            btn.Text = plr.Name
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
            end)
            y = y + 35
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end
refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

local frontToggle = Instance.new("TextButton", mainFrame)
frontToggle.Position = UDim2.new(0, 10, 0, 180)
frontToggle.Size = UDim2.new(1, -20, 0, 30)
frontToggle.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
frontToggle.TextColor3 = Color3.new(1, 1, 1)
frontToggle.Text = "Front / Back of Player"
local isFront = true
frontToggle.MouseButton1Click:Connect(function()
    isFront = not isFront
    frontToggle.Text = isFront and "Infront / Back" or "Front / Back of Player"
end)

local isActive = false
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Position = UDim2.new(0, 10, 0, 220)
toggleBtn.Size = UDim2.new(1, -20, 0, 30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0) 
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Text = "Teleport Disabled"
toggleBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    toggleBtn.Text = isActive and "Teleport Enabled" or "Teleport Disabled"
    toggleBtn.BackgroundColor3 = isActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

local menuBtn = Instance.new("TextButton", gui)
menuBtn.Position = UDim2.new(0, 10, 0, 10)
menuBtn.Size = UDim2.new(0, 80, 0, 35)
menuBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
menuBtn.TextColor3 = Color3.new(1,1,1)
menuBtn.Text = "Menu"
menuBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

local destroyBtn = Instance.new("TextButton", mainFrame)
destroyBtn.Position = UDim2.new(0, 10, 1, -40)
destroyBtn.Size = UDim2.new(1, -20, 0, 30)
destroyBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
destroyBtn.TextColor3 = Color3.new(1,1,1)
destroyBtn.Text = "Kill Script"
destroyBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    script:Destroy()
end)

task.spawn(function()
    while true do
        if isActive and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and character and character:FindFirstChild("HumanoidRootPart") then
            local offset = isFront and Vector3.new(0, 0, -2) or Vector3.new(0, 0, 2) -- Reduced offset from 5 to 2 studs for closer teleport
            character:MoveTo(selectedPlayer.Character.HumanoidRootPart.Position + (selectedPlayer.Character.HumanoidRootPart.CFrame.LookVector * offset.Z))
        end
        task.wait(0)
    end
end)

