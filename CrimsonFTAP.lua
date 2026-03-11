local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local mouse = LP:GetMouse()

local Music = Instance.new("Sound", LP.PlayerGui)
Music.SoundId = "rbxassetid://11532132338"
Music.Volume = 1
local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size = 0
local ColorCorr = Instance.new("ColorCorrectionEffect", Lighting)
ColorCorr.TintColor = Color3.fromRGB(0, 255, 100)

local ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
local BinaryContainer = Instance.new("Frame", ScreenGui)
BinaryContainer.Size = UDim2.new(1, 0, 1, 0)
BinaryContainer.BackgroundTransparency = 1

local function CreateDenseBinary()
    task.spawn(function()
        local Label = Instance.new("TextLabel", BinaryContainer)
        Label.Size = UDim2.new(0, 40, 0, 40)
        Label.Position = UDim2.new(math.random(), 0, -0.2, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(0, 255, 100)
        Label.TextSize = math.random(25, 45)
        Label.Font = Enum.Font.Code
        Label.Text = math.random(0, 1)
        Label.TextStrokeTransparency = 0.5
        local fallTime = math.random(0.5, 1.5)
        local tween = TweenService:Create(Label, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
            Position = UDim2.new(Label.Position.X.Scale, 0, 1.2, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        Label:Destroy()
    end)
end

Music:Play()
Blur.Size = 20
for i = 1, 150 do
    CreateDenseBinary()
    if i > 100 then task.wait(0.01) else task.wait(0.03) end
end
task.wait(0.5)
local Flash = Instance.new("ColorCorrectionEffect", Lighting)
Flash.Brightness = 10
Flash.TintColor = Color3.fromRGB(255, 255, 255)
Music:Stop()
ScreenGui:Destroy()
Blur:Destroy()
ColorCorr:Destroy()
TweenService:Create(Flash, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Brightness = 0}):Play()
task.delay(0.6, function() Flash:Destroy() end)

setclipboard("https://linkvertise.com/3529018/8azhAcgnKA9b?o=sharing")

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Rayfield failed to load.")
    return
end
print("Rayfield loaded successfully.")

_G.AttackSpeed = 0.05
_G.WhitelistEnabled = false
_G.SuperFlingEnabled = false
_G.FlingStrength = 850
_G.noclip = false
_G.infinjump = false
_G.thirdPerson = false

local v79_AntiGrab = false
local v84_AntiExplode = false
local antiLagT = false
local v14_AntiBlobman = false
local v64_Gucci = {enabled = false, ragdollConn = nil, posCheckConn = nil}
local FLING_VELOCITY_NAME = "FlingVelocity"
local ServerLoopKickActive = false

local GucciConfig = {
    enabled = false,
    ragdollConn = nil,
    isSitting = false
}

-- Kill All Functions (Adapted from BlizT)
local destroyGrabLineEvent = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("DestroyGrabLine")
local setNetworkOwnerEvent = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
local ragdollRemoteEvent = ReplicatedStorage.CharacterEvents:WaitForChild("RagdollRemote")

function CheckPlayer(potentialPlayer)
    return potentialPlayer and potentialPlayer.Character and potentialPlayer.Character:FindFirstChild("HumanoidRootPart") and potentialPlayer ~= LP
end

function CheckPlayerKill(potentialKickedPlayer4)
    if CheckPlayer(potentialKickedPlayer4) and not IsPlayerInsideSafeZone(potentialKickedPlayer4) then
        return true
    end
end

function IsPlayerInsideSafeZone(player)
    if typeof(player) == "Instance" and (player:IsA("Player") and (player:FindFirstChild("InPlot") and player.InPlot.Value)) then
        return true
    end
end

function SNOWship(targetPart)
    if targetPart and typeof(targetPart) == "Instance" then
        local distanceFromCharacter = LP:DistanceFromCharacter(targetPart.Position)
        if LP.Character and (LP.Character:FindFirstChild("HumanoidRootPart") and distanceFromCharacter <= 30) then
            setNetworkOwnerEvent:FireServer(targetPart, lookAt(LP.Character.HumanoidRootPart.Position, targetPart.Position))
        end
    end
end

function lookAt(startPosition, targetPosition)
    local directionVector = (targetPosition - startPosition).Unit
    local rightVector = directionVector:Cross((Vector3.new(0, 1, 0)))
    local upVector = rightVector:Cross(directionVector)
    return CFrame.fromMatrix(startPosition, rightVector, upVector)
end

function CreateSkyVelocity(skyObject)
    if not skyObject:FindFirstChild("SkyVelocity") then
        local skyVelocityBodyVelocity = Instance.new("BodyVelocity", skyObject)
        skyVelocityBodyVelocity.Name = "SkyVelocity"
        skyVelocityBodyVelocity.Velocity = Vector3.new(0, 100000000000000, 0)
        skyVelocityBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    end
end

function GetPlayerCharacter()
    if LP.Character and (LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character:FindFirstChildOfClass("Humanoid")) then
        return LP.Character
    end
end

_G.TP_Priority = 0
function ChangeActivityPriority(teleportPriority)
    if _G.TP_Priority <= teleportPriority then
        _G.TP_Priority = teleportPriority
        return true
    end
    if teleportPriority == 0 then
        _G.TP_Priority = teleportPriority
        return true
    end
end

function TeleportPlayer(cframeOffset, teleportPriority)
    if (teleportPriority == nil and 0 or teleportPriority) == _G.TP_Priority then
        local playerCharacter = GetPlayerCharacter()
        if playerCharacter and (not _G.TeleportingToNetworkOwnership and typeof(cframeOffset) == "CFrame") then
            local humanoidRootPart = playerCharacter.HumanoidRootPart
            local humanoid = playerCharacter:FindFirstChildOfClass("Humanoid")
            humanoidRootPart.CFrame = humanoidRootPart.CFrame.Rotation + cframeOffset.Position
            if humanoid.SeatPart == nil or tostring(humanoid.SeatPart.Parent) ~= "CreatureBlobman" then
                humanoid.Sit = false
            end
        end
    end
end

function GetPlayerCFrame()
    local playerCharacter = GetPlayerCharacter()
    if playerCharacter then
        return playerCharacter.HumanoidRootPart.CFrame
    end
end

function dialogueFunction2()
    -- Placeholder for any chat or dialogue action
end

function CheckNetworkOwnerShipOnPlayer(potentialPlayer, condition)
    if typeof(potentialPlayer) == "Instance" and (potentialPlayer:IsA("Player") and potentialPlayer.Character) and (potentialPlayer.Character:FindFirstChild("Head") and (potentialPlayer.Character.Head:FindFirstChild("PartOwner") and potentialPlayer.Character.Head.PartOwner.Value == LP.Name)) then
        return not condition and true or potentialPlayer.Character.Head.PartOwner
    end
end

workspace.ChildAdded:Connect(function(child)
    if child.Name == "GrabParts" then
        local success, grabPart = pcall(function()
            return child:WaitForChild("GrabPart", 2):WaitForChild("WeldConstraint", 2).Part1
        end)
        if not success or not grabPart then return end
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = FLING_VELOCITY_NAME
        bodyVelocity.Parent = grabPart
        local connection
        connection = child:GetPropertyChangedSignal("Parent"):Connect(function()
            if child.Parent == nil then
                if _G.SuperFlingEnabled then
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.FlingStrength
                    Debris:AddItem(bodyVelocity, 1)
                else
                    bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
                    Debris:AddItem(bodyVelocity, 1)
                end
                if connection then connection:Disconnect() end
            end
        end)
    end
end)

local Window = Rayfield:CreateWindow({
    Name = "Crimson FTAP",
    LoadingTitle = "Test Version By -Homer",
    LoadingSubtitle = "Loading",
    Theme = "Green",
    KeySystem = false,
    KeySettings = { Title = "Crimson Key", Key = {"PassedCrimson"} }
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
print("CombatTab created")
local ProtTab = Window:CreateTab("Invincibility", 4483362458)
print("ProtTab created")
local LocalPlayerTab = Window:CreateTab("Local Player", 4483362458)
print("LocalPlayerTab created")
local ESPTab = Window:CreateTab("ESP", 4483362458)
print("ESPTab created")
local BlobmanTab = Window:CreateTab("Blobman / Sniper", 6031091005)
print("BlobmanTab created")
local ServerTab = Window:CreateTab("Server", 4483362458)
print("ServerTab created")

-- Combat Tab
CombatTab:CreateSection("Fling & Kill")

CombatTab:CreateToggle({
    Name = "Super Fling",
    CurrentValue = false,
    Flag = "FlingToggle",
    Callback = function(Value) _G.SuperFlingEnabled = Value end
})

CombatTab:CreateSlider({
    Name = "Fling Strength",
    Range = {100, 10000},
    Increment = 50,
    CurrentValue = 850,
    Flag = "FlingPower",
    Callback = function(Value) _G.FlingStrength = Value end
})

-- Protection Tab
ProtTab:CreateSection("Anti")

ProtTab:CreateToggle({
    Name = "Anti Blobman",
    CurrentValue = false,
    Callback = function(Value)
        v14_AntiBlobman = Value
        if v14_AntiBlobman then
            task.spawn(function()
                while v14_AntiBlobman do
                    local char = LP.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and (v.Name == "LeftDetector" or v.Name == "RightDetector") then
                                if (char.HumanoidRootPart.Position - v.Position).Magnitude > 10 then v:Destroy() end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

ProtTab:CreateToggle({
    Name = "Anti Grab",
    CurrentValue = false,
    Callback = function(Value)
        v79_AntiGrab = Value
        if v79_AntiGrab then
            task.spawn(function()
                while v79_AntiGrab and task.wait() do
                    if LP:FindFirstChild("IsHeld") and LP.IsHeld.Value == true then
                        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Anchored = true
                            while LP.IsHeld.Value == true and v79_AntiGrab do
                                ReplicatedStorage.CharacterEvents.Struggle:FireServer(LP)
                                task.wait(0.001)
                            end
                            hrp.Anchored = false
                        end
                    end
                end
            end)
        end
    end
})

ProtTab:CreateToggle({
    Name = "Anti Explode",
    CurrentValue = false,
    Callback = function(Value)
        v84_AntiExplode = Value
        if v84_AntiExplode then
            workspace.ChildAdded:Connect(function(obj)
                if obj:IsA("Part") and obj.Name == "Part" and v84_AntiExplode then
                    local char = LP.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local rArm = char and char:FindFirstChild("Right Arm")
                    if hrp and rArm and (obj.Position - hrp.Position).Magnitude <= 20 then
                        hrp.Anchored = true
                        task.wait(0.01)
                        hrp.Anchored = false
                    end
                end
            end)
        end
    end
})

ProtTab:CreateToggle({
    Name = "Anti Burn",
    CurrentValue = false,
    Callback = function(Value)
        local hole = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Hole") and workspace.Map.Hole.PoisonBigHole.ExtinguishPart
        if not hole then return end
        local originalPos = hole.Position
        if Value then
            _G.FireLoop = RunService.Heartbeat:Connect(function()
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp:FindFirstChild("FireLight") or hrp:FindFirstChild("FireParticleEmitter")) then
                    hole.CFrame = CFrame.new(hrp.Position)
                else
                    hole.CFrame = CFrame.new(originalPos)
                end
            end)
        else
            if _G.FireLoop then _G.FireLoop:Disconnect() end
            hole.CFrame = CFrame.new(originalPos)
        end
    end
})

ProtTab:CreateToggle({
    Name = "Anti Lag",
    CurrentValue = false,
    Callback = function(Value)
        antiLagT = Value
        local scripts = LP:FindFirstChild("PlayerScripts")
        local beam = scripts and scripts:FindFirstChild("CharacterAndBeamMove")
        if beam then beam.Disabled = antiLagT end
    end
})

-- Local Player Tab with NoClip, Infinite Jump, FOV Slider, and 3rd Person Mode
LocalPlayerTab:CreateSection("Local Player")

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
    
    _G.NCLoop = RunService.RenderStepped:Connect(function()
        if _G.noclip then
            disableCollision(character)
        end
    end)
end

if LP.Character then
    setupNoclip(LP.Character)
end

LP.CharacterAdded:Connect(function(newChar)
    setupNoclip(newChar)
end)

LocalPlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Callback = function(Value)
        print("No Clip toggled to:", Value)
        _G.noclip = Value
    end
})

local spaceHeld = false
local moveForward = false
local moveBackward = false
local moveLeft = false
local moveRight = false

mouse.KeyDown:Connect(function(k)
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

mouse.KeyUp:Connect(function(k)
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

RunService.RenderStepped:Connect(function()
    if _G.infinjump and spaceHeld then
        local plrChar = LP.Character
        if plrChar then
            local plrh = plrChar:FindFirstChildOfClass("Humanoid")
            local rootPart = plrChar:FindFirstChild("HumanoidRootPart")
            
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

LocalPlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        print("Infinite Jump toggled to:", Value)
        _G.infinjump = Value
    end
})

LocalPlayerTab:CreateSlider({
    Name = "Field of View (FOV)",
    Range = {30, 120},
    Increment = 1,
    CurrentValue = 70,
    Flag = "FOVSlider",
    Callback = function(Value)
        print("FOV set to:", Value)
        workspace.CurrentCamera.FieldOfView = Value
    end
})

local thirdPersonConnection = nil

local function updateCameraMode()
    local character = LP.Character
    if not character then
        print("3rd Person Mode: Character not found.")
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not humanoidRootPart then
        print("3rd Person Mode: Humanoid or HumanoidRootPart not found.")
        return
    end
    
    local camera = workspace.CurrentCamera
    if _G.thirdPerson then
        print("3rd Person Mode: Enabled, setting up camera with Classic mode.")
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMinZoomDistance = 2
        LP.CameraMaxZoomDistance = 30
        
        local success, err = pcall(function()
            LP.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        end)
        if not success then
            print("3rd Person Mode: Could not set DevCameraOcclusionMode: " .. tostring(err))
        else
            print("3rd Person Mode: Third-person settings applied successfully.")
        end
        
        camera.CameraType = Enum.CameraType.Custom
        humanoid.CameraOffset = Vector3.new(0, 0, 0)
        
        if thirdPersonConnection then
            thirdPersonConnection:Disconnect()
        end
        thirdPersonConnection = RunService.RenderStepped:Connect(function()
            if _G.thirdPerson and character and humanoidRootPart and camera then
                local rootCFrame = humanoidRootPart.CFrame
                local cameraOffset = rootCFrame.LookVector * -10 + Vector3.new(0, 5, 0)
                camera.CFrame = CFrame.new(rootCFrame.Position + cameraOffset, rootCFrame.Position)
            else
                if thirdPersonConnection then
                    thirdPersonConnection:Disconnect()
                    thirdPersonConnection = nil
                end
            end
        end)
    else
        print("3rd Person Mode: Disabled, resetting camera.")
        if thirdPersonConnection then
            thirdPersonConnection:Disconnect()
            thirdPersonConnection = nil
        end
        LP.CameraMode = Enum.CameraMode.LockFirstPerson
        LP.CameraMinZoomDistance = 0.5
        LP.CameraMaxZoomDistance = 400
        humanoid.CameraOffset = Vector3.new(0, 0, 0)
        camera.CameraType = Enum.CameraType.Custom
    end
end

if LP.Character then
    print("3rd Person Mode: Initializing on current character.")
    updateCameraMode()
end

LP.CharacterAdded:Connect(function(newChar)
    print("3rd Person Mode: Character respawned, reinitializing.")
    updateCameraMode()
end)

LocalPlayerTab:CreateToggle({
    Name = "3rd Person Mode",
    CurrentValue = false,
    Callback = function(Value)
        print("3rd Person Mode toggled to:", Value)
        _G.thirdPerson = Value
        updateCameraMode()
    end
})

-- ESP Tab
local ESP_Enabled = false
local ESP_ShowNames = false
local ESP_Rainbow = false
local ESP_Color = Color3.fromRGB(0, 255, 100)

local function ApplyESP(player)
    if player == LP then return end 

    local function Setup(character)
        if not character then return end
        
        local hrp = character:WaitForChild("HumanoidRootPart", 10)
        local head = character:WaitForChild("Head", 10)
        if not hrp or not head then return end
        
        if character:FindFirstChild("Gemini_ESP") then character.Gemini_ESP:Destroy() end
        if character:FindFirstChild("Gemini_NameTag") then character.Gemini_NameTag:Destroy() end
    
        local highlight = Instance.new("Highlight")
        highlight.Name = "Gemini_ESP"
        highlight.Parent = character
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        
        local bill = Instance.new("BillboardGui", character)
        bill.Name = "Gemini_NameTag"
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0, 100, 0, 100)
        bill.ExtentsOffset = Vector3.new(0, 4, 0)
        
        local headshot = Instance.new("ImageLabel", bill)
        headshot.BackgroundTransparency = 1
        headshot.Size = UDim2.new(0, 40, 0, 40)
        headshot.Position = UDim2.new(0.5, -20, 0, 0)
        headshot.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
        local corner = Instance.new("UICorner", headshot)
        corner.CornerRadius = UDim.new(1, 0)
        
        local label = Instance.new("TextLabel", bill)
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 0, 0, 45)
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Text = player.DisplayName or player.Name
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextStrokeTransparency = 0
        label.TextColor3 = Color3.new(1,1,1)
        
        task.spawn(function()
            local hue = 0
            while character and character.Parent do
                hue = hue + 0.01
                local currentCol = ESP_Rainbow and Color3.fromHSV(hue % 1, 0.7, 1) or ESP_Color
                
                highlight.Enabled = ESP_Enabled
                highlight.FillColor = currentCol
                highlight.OutlineColor = currentCol
                
                bill.Enabled = (ESP_Enabled and ESP_ShowNames)
                label.TextColor3 = currentCol
                
                task.wait(0.05)
            end
        end)
    end
    
    player.CharacterAdded:Connect(Setup)
    if player.Character then Setup(player.Character) end
end

for _, p in pairs(game.Players:GetPlayers()) do
    ApplyESP(p)
end

game.Players.PlayerAdded:Connect(ApplyESP)

ESPTab:CreateToggle({
    Name = "Activer l'ESP",
    CurrentValue = false,
    Flag = "esp_active",
    Callback = function(v) ESP_Enabled = v end
})

ESPTab:CreateToggle({
    Name = "Player Icon & Name",
    CurrentValue = false,
    Flag = "esp_names",
    Callback = function(v) ESP_ShowNames = v end
})

ESPTab:CreateToggle({
    Name = "Rainbow ESP",
    CurrentValue = false,
    Flag = "esp_rainbow",
    Callback = function(v) ESP_Rainbow = v end
})

ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(0, 255, 100),
    Flag = "esp_color",
    Callback = function(v) ESP_Color = v end
})

ESPTab:CreateButton({
    Name = "Force Refresh ESP",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            ApplyESP(p)
        end
        Rayfield:Notify({Title = "ESP System", Content = "Rafraîchissement forcé effectué", Duration = 2})
    end
})

-- Blobman / Sniper Tab
local SelectedTargetPlayer = nil 
local BlobmanLoopActive = false
local blobalter = 1

local function getPlayersForDropdown()
    local tbl = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LP then table.insert(tbl, p.Name) end
    end
    return tbl
end

local function findCurrentBlobman()
    if not LP.Character then return nil end
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
            local seat = v.VehicleSeat
            if seat.Occupant and seat.Occupant.Parent == LP.Character then
                return v
            end
        end
    end
    return nil
end

local function performGrab(targetPlayer, bman)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = targetPlayer.Character.HumanoidRootPart
    
    pcall(function()
        local scriptBase = bman:FindFirstChild("BlobmanSeatAndOwnerScript")
        if not scriptBase then return end
        
        local remote = scriptBase:FindFirstChild("CreatureGrab")
        if not remote then return end
        
        local detectorName = (blobalter == 1) and "RightDetector" or "LeftDetector"
        local weldName = (blobalter == 1) and "RightWeld" or "LeftWeld"
        
        local detector = bman:FindFirstChild(detectorName)
        if detector then
            remote:FireServer(detector, hrp, detector:FindFirstChild(weldName))
        end
        blobalter = (blobalter == 1) and 2 or 1
    end)
end

BlobmanTab:CreateSection("Control of the target")

local TargetDropdown = BlobmanTab:CreateDropdown({
    Name = "Select a target player",
    Options = getPlayersForDropdown(),
    CurrentValue = "",
    Callback = function(Option)
        local name = type(Option) == "table" and Option[1] or Option
        SelectedTargetPlayer = game.Players:FindFirstChild(name)
        if SelectedTargetPlayer then
            Rayfield:Notify({Title = "Target Selected", Content = "Focus : " .. name, Duration = 2})
        end
    end,
})

BlobmanTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        TargetDropdown:Refresh(getPlayersForDropdown(), true)
    end
})

BlobmanTab:CreateSection("Combat Actions")

BlobmanTab:CreateButton({
    Name = "Teleport behind the target",
    Callback = function()
        if SelectedTargetPlayer and SelectedTargetPlayer.Character and SelectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                myHRP.CFrame = SelectedTargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        else
            Rayfield:Notify({Title = "Erreur", Content = "Cible introuvable ou non sélectionnée", Duration = 2})
        end
    end
})

BlobmanTab:CreateToggle({
    Name = "AUTO-KICK",
    CurrentValue = false,
    Flag = "blob_kick_single",
    Callback = function(Value)
        BlobmanLoopActive = Value
        if Value then
            task.spawn(function()
                while BlobmanLoopActive do
                    local bman = findCurrentBlobman()
                    
                    if bman and SelectedTargetPlayer then
                        performGrab(SelectedTargetPlayer, bman)
                        task.wait(0.01) 
                    elseif not bman then
                        task.wait(1)
                    else
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
})

-- Gucci Anti (GODLY)
local function runGucciSetup()
    game:GetService("ReplicatedStorage").MenuToys.SpawnToyRemoteFunction:InvokeServer(
        "CreatureBlobman", 
        CFrame.new(0, 50000, 0) * CFrame.Angles(-0.7351, 0.9028, 0.6173), 
        Vector3.new(0, 59.667, 0)
    )
    
    local LP = game.Players.LocalPlayer
    local Char = LP.Character or LP.CharacterAdded:Wait()
    local Hum = Char:WaitForChild("Humanoid")
    local HRP = Char:WaitForChild("HumanoidRootPart")
    local OldPos = HRP.Position
    
    task.wait(0.3)
    local toyFolder = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
    local bman = toyFolder and toyFolder:FindFirstChild("CreatureBlobman")
    
    if bman then
        local head = bman:FindFirstChild("Head")
        local seat = bman:FindFirstChild("VehicleSeat")
        
        if head then
            head.CFrame = CFrame.new(0, 50000, 0)
            head.Anchored = true
        end
        
        if seat and seat:IsA("VehicleSeat") then
            HRP.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
            seat:Sit(Hum)
            GucciConfig.isSitting = true
        end
    end
    
    local jumpConn
    jumpConn = Hum:GetPropertyChangedSignal("Jump"):Connect(function()
        if GucciConfig.isSitting and Hum.Jump then
            task.wait(0.08)
            HRP.CFrame = CFrame.new(OldPos)
            GucciConfig.isSitting = false
            jumpConn:Disconnect()
        end
    end)
    
    if GucciConfig.ragdollConn then GucciConfig.ragdollConn:Disconnect() end
    GucciConfig.ragdollConn = game:GetService("RunService").Heartbeat:Connect(function()
        if GucciConfig.enabled and GucciConfig.isSitting then
            pcall(function()
                game:GetService("ReplicatedStorage").CharacterEvents.RagdollRemote:FireServer(HRP, 0)
            end)
        end
    end)
end

ProtTab:CreateToggle({
    Name = "Gucci Anti (GODLY)",
    CurrentValue = false,
    Flag = "gucci_toggle", 
    Callback = function(Value)
        GucciConfig.enabled = Value
        if Value then
            runGucciSetup()
        else
            if GucciConfig.ragdollConn then 
                GucciConfig.ragdollConn:Disconnect() 
                GucciConfig.ragdollConn = nil
            end
            GucciConfig.isSitting = false
        end
    end,
})

-- Server Tab with Loop Kick Server (Updated with Teleport to Spawn, Grab, and Float in Circle)
local function spawnAndSitBlobman()
    local LP = game.Players.LocalPlayer
    local Char = LP.Character or LP.CharacterAdded:Wait()
    local Hum = Char:WaitForChild("Humanoid")
    local HRP = Char:WaitForChild("HumanoidRootPart")
    local OldPos = HRP.Position

    game:GetService("ReplicatedStorage").MenuToys.SpawnToyRemoteFunction:InvokeServer(
        "CreatureBlobman", 
        CFrame.new(0, 50000, 0) * CFrame.Angles(-0.7351, 0.9028, 0.6173), 
        Vector3.new(0, 59.667, 0)
    )

    task.wait(0.3)
    local toyFolder = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
    local bman = toyFolder and toyFolder:FindFirstChild("CreatureBlobman")

    if bman then
        local head = bman:FindFirstChild("Head")
        local seat = bman:FindFirstChild("VehicleSeat")

        if head then
            head.CFrame = CFrame.new(0, 50000, 0)
            head.Anchored = true
        end

        if seat and seat:IsA("VehicleSeat") then
            HRP.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
            seat:Sit(Hum)
            GucciConfig.isSitting = true
            return bman
        end
    end
    return nil
end

local function teleportToSpawn()
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then
        -- Assuming spawn point is near (0, 50, 0) or a high position; adjust if your game has a specific spawn
        myHRP.CFrame = CFrame.new(0, 50, 0)
        return true
    end
    return false
end

local function positionPlayerInCircle(targetPlayer, index, totalPlayers, centerPos, radius, height)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    local angle = (2 * math.pi * index) / totalPlayers
    local x = centerPos.X + radius * math.cos(angle)
    local z = centerPos.Z + radius * math.sin(angle)
    local targetHRP = targetPlayer.Character.HumanoidRootPart
    targetHRP.CFrame = CFrame.new(x, centerPos.Y + height, z)
    -- Add a small oscillating movement to glitch anti-cheat detection
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.new(0, math.sin(tick() * 5) * 3, 0) -- Up and down movement
    bodyVelocity.Parent = targetHRP
    Debris:AddItem(bodyVelocity, 0.5)
    return true
end

ServerTab:CreateSection("Server Control")

ServerTab:CreateToggle({
    Name = "Kill All",
    CurrentValue = false,
    Flag = "kill_all_toggle",
    Callback = function(killAllEnabled)
        _G.KillAll = killAllEnabled
        if killAllEnabled then
            while _G.KillAll do
                local ipos = GetPlayerCFrame()
                local playersService = Players
                local playerIterator, playerIterator3, playerIndex = pairs(playersService:GetPlayers())
                while true do
                    local player
                    playerIndex, player = playerIterator(playerIterator3, playerIndex)
                    if playerIndex == nil then
                        break
                    end
                    if CheckPlayerKill(player) then
                        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        local humanoid = player.Character:FindFirstChild("Humanoid")
                        if player and (humanoidRootPart and humanoid) then
                            for _ = 0, 50 do
                                dialogueFunction2()
                                SNOWship(humanoidRootPart)
                                if not CheckPlayerKill(player) or (not _G.KillAll or (CheckNetworkOwnerShipOnPlayer(player) or humanoidRootPart.AssemblyLinearVelocity.Magnitude > 500)) then
                                    CreateSkyVelocity(humanoidRootPart)
                                    destroyGrabLineEvent:FireServer(humanoidRootPart)
                                    break
                                end
                                task.wait()
                                if humanoidRootPart.Position.Y <= -12 then
                                    TeleportPlayer(CFrame.new(humanoidRootPart.Position + Vector3.new(0, 5, -15)))
                                else
                                    TeleportPlayer(CFrame.new(humanoidRootPart.Position + Vector3.new(0, -10, -10)))
                                end
                                humanoid.BreakJointsOnDeath = false
                                humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                                humanoid.Jump = true
                                humanoid.Sit = false
                            end
                        end
                    end
                end
                TeleportPlayer(ipos)
                task.wait(0.2)
            end
            dialogueFunction1()
            TeleportPlayer(ipos)
        end
    end
})

ServerTab:CreateToggle({
    Name = "Loop Kick Server",
    CurrentValue = false,
    Flag = "loop_kick_server",
    Callback = function(Value)
        ServerLoopKickActive = Value
        if Value then
            task.spawn(function()
                Rayfield:Notify({Title = "Loop Kick Server", Content = "Started targeting all players for kick glitch", Duration = 3})
                
                local bman = findCurrentBlobman()
                if not bman then
                    Rayfield:Notify({Title = "Loop Kick Server", Content = "Spawning Blobman automatically", Duration = 2})
                    bman = spawnAndSitBlobman()
                    if not bman then
                        Rayfield:Notify({Title = "Loop Kick Server", Content = "Failed to spawn Blobman, retrying soon", Duration = 2})
                        ServerLoopKickActive = false
                        return
                    end
                end

                while ServerLoopKickActive do
                    bman = findCurrentBlobman()
                    if bman then
                        -- Teleport Blobman (and thus the player) to spawn area
                        local teleported = teleportToSpawn()
                        if teleported then
                            local targetPlayers = {}
                            for _, targetPlayer in pairs(game.Players:GetPlayers()) do
                                if targetPlayer ~= LP and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(targetPlayers, targetPlayer)
                                    -- Attempt to grab each player to hold them with Blobman
                                    performGrab(targetPlayer, bman)
                                    task.wait(0.05)
                                end
                            end
                            -- Position grabbed players in a floating circle above spawn
                            local centerPos = Vector3.new(0, 60, 0) -- Adjust based on your game's spawn height
                            local radius = 10
                            for i, targetPlayer in ipairs(targetPlayers) do
                                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    -- Check if they are grabbed by Blobman to avoid re-teleporting if not
                                    if targetPlayer:FindFirstChild("IsHeld") and targetPlayer.IsHeld.Value == true then
                                        positionPlayerInCircle(targetPlayer, i, #targetPlayers, centerPos, radius, 10)
                                    end
                                end
                            end
                        end
                    else
                        Rayfield:Notify({Title = "Loop Kick Server", Content = "Blobman not found, respawning in 2 seconds", Duration = 2})
                        bman = spawnAndSitBlobman()
                        if not bman then
                            Rayfield:Notify({Title = "Loop Kick Server", Content = "Failed to respawn Blobman, retrying soon", Duration = 2})
                            task.wait(2)
                            if not ServerLoopKickActive then break end
                        end
                    end
                    task.wait(0.5) -- Delay between cycles to avoid server overload
                end
                Rayfield:Notify({Title = "Loop Kick Server", Content = "Stopped targeting players for kick glitch", Duration = 3})
            end)
        end
    end
})

Rayfield:Notify({Title = "Crimson Ready", Content = "jaka town", Duration = 5})
