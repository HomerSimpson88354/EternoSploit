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

pcall(function()
    if type(setclipboard) == "function" then
        setclipboard("https://linkvertise.com/3529018/8azhAcgnKA9b?o=sharing")
    end
end)

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
_G.Poison_Grab = false
_G.Burn_Grab = false
_G.Death_Grab = false
_G.MasslessGrab = false
_G.AntiKick = false
_G.HoldingObjectGrabPart = nil
_G.RealGrabParts = nil
_G.FutherExtend = false
_G.noclip = false
_G.NoclipToggle = false
_G.infinjump = false
_G.thirdPerson = false
_G.SuperSpeed = false
_G.SpeedValue = 16
_G.AntiInputLag = false
_G.AntiGrab = false

getgenv().Multiplier = 0.15
local IncreaseLineExtend = 3
local pcDistance = 0
local activeExtendGrabModel = nil
local activeExtendDragPart = nil
local extendFollowActive = false

local v79_AntiGrab = false
local v84_AntiExplode = false
local antiLagT = false
local autoGucciActive = false
local antiGucciBlobActive = false

local v14_AntiBlobman = false
local suspendAntiBlobmanMaintenance = false
local antiBlobmanSuspendCount = 0
local v64_Gucci = {enabled = false, ragdollConn = nil, posCheckConn = nil}
local FLING_VELOCITY_NAME = "FlingVelocity"
local ServerLoopKickActive = false
local LagServerUsingPlayers = false
local LagServerUsingMap = false
local GrabsPerSecond = 100
local playerList = {}
_G.LoopKill = false

local function beginAntiBlobmanSuspend()
    antiBlobmanSuspendCount = antiBlobmanSuspendCount + 1
    suspendAntiBlobmanMaintenance = antiBlobmanSuspendCount > 0
end

local function endAntiBlobmanSuspend()
    antiBlobmanSuspendCount = math.max(0, antiBlobmanSuspendCount - 1)
    suspendAntiBlobmanMaintenance = antiBlobmanSuspendCount > 0
end

local MenuToysFolder = ReplicatedStorage:WaitForChild("MenuToys")
local SpawnToyRF = MenuToysFolder:WaitForChild("SpawnToyRemoteFunction")
local DeleteToyRE = MenuToysFolder:WaitForChild("DestroyToy")
local BuyToy = MenuToysFolder:WaitForChild("BuyToyRemoteFunction")
local StickyPartEvent = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
local destroyGrabLineEvent = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("DestroyGrabLine")
local createGrabLineEvent = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("CreateGrabLine")
local extendGrabLineEvent = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("ExtendGrabLine")
local setNetworkOwnerEvent = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
local ragdollRemoteEvent = ReplicatedStorage.CharacterEvents:WaitForChild("RagdollRemote")
local struggleEvent = ReplicatedStorage:WaitForChild("CharacterEvents"):WaitForChild("Struggle")
local isHeldValue = LP:FindFirstChild("IsHeld") or LP:WaitForChild("IsHeld")
local spawnedInToysFolderName = LP.Name .. "SpawnedInToys"
local spawnedInToysFolder = workspace:FindFirstChild(spawnedInToysFolderName) or workspace:WaitForChild(spawnedInToysFolderName, 5)

local SinkBlob = ReplicatedStorage:FindFirstChild("SinkBlob") or (function()
    local re = Instance.new("RemoteEvent")
    re.Name = "SinkBlob"
    re.Parent = ReplicatedStorage
    return re
end)()

local function createFallbackPoisonPart(name)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.Transparency = 1
    p.Size = Vector3.new(2, 2, 2)
    p.Position = Vector3.new(0, -50, 0)
    p.Parent = workspace
    return p
end

local map = workspace:FindFirstChild("Map")
local hole = map and map:FindFirstChild("Hole")
local poisonBigHole = hole and hole:FindFirstChild("PoisonBigHole")
local poisonSmallHole = hole and hole:FindFirstChild("PoisonSmallHole")
local factoryIsland = map and map:FindFirstChild("FactoryIsland")
local poisonContainer = factoryIsland and factoryIsland:FindFirstChild("PoisonContainer")

local bigHolePoisonPart = poisonBigHole and poisonBigHole:FindFirstChild("PoisonHurtPart") or createFallbackPoisonPart("FallbackPoisonBig")
local smallHolePoisonPart = poisonSmallHole and poisonSmallHole:FindFirstChild("PoisonHurtPart") or createFallbackPoisonPart("FallbackPoisonSmall")
local factoryIslandPoisonPart = poisonContainer and poisonContainer:FindFirstChild("PoisonHurtPart") or createFallbackPoisonPart("FallbackPoisonFactory")

factoryIslandPoisonPart.Size = Vector3.new(2, 2, 2)
smallHolePoisonPart.Size = Vector3.new(2, 2, 2)
bigHolePoisonPart.Size = Vector3.new(2, 2, 2)
factoryIslandPoisonPart.Position = Vector3.new(0, -50, 0)
smallHolePoisonPart.Position = Vector3.new(0, -50, 0)
bigHolePoisonPart.Position = Vector3.new(0, -50, 0)

local campfireInstance = nil

function CheckPlayer(potentialPlayer)
    return potentialPlayer and potentialPlayer.Character and potentialPlayer.Character:FindFirstChild("HumanoidRootPart") and potentialPlayer ~= LP
end

function CheckPlayerKill(potentialKickedPlayer4)
    if CheckPlayer(potentialKickedPlayer4) and not IsPlayerInsideSafeZone(potentialKickedPlayer4) then
        if killAllWhitelist and killAllWhitelist[potentialKickedPlayer4.Name] then
            return false
        end
        return true
    end
end

if not killAllWhitelist then killAllWhitelist = {} end

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

function SNOWshipForce(targetPart)
    if targetPart and typeof(targetPart) == "Instance" then
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
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

local masslessCharacterConnection = nil
local masslessGrabChildConnection = nil

local function applyInitMasslessGrabToModel(part)
    if not (part and part.Name == "GrabParts") then return end
    local dragPart = part:FindFirstChild("DragPart") or part:WaitForChild("DragPart", 2)
    if not dragPart then return end
    local alignOrientation = dragPart:FindFirstChild("AlignOrientation")
    local alignPosition = dragPart:FindFirstChild("AlignPosition")
    if not (alignOrientation and alignPosition) then return end
    alignOrientation.MaxTorque = math.huge
    alignOrientation.Responsiveness = 200
    alignPosition.MaxForce = math.huge
    alignPosition.Responsiveness = 200
end

local function refreshInitMasslessGrabHook()
    if masslessGrabChildConnection then
        masslessGrabChildConnection:Disconnect()
        masslessGrabChildConnection = nil
    end
    if not _G.MasslessGrab then return end
    masslessGrabChildConnection = workspace.ChildAdded:Connect(function(part)
        if part.Name == "GrabParts" then
            applyInitMasslessGrabToModel(part)
        end
    end)
    local currentGrab = workspace:FindFirstChild("GrabParts")
    if currentGrab then
        task.spawn(function() applyInitMasslessGrabToModel(currentGrab) end)
    end
end

local function attachInitMasslessCharacterLogic(character)
    if masslessCharacterConnection then
        masslessCharacterConnection:Disconnect()
        masslessCharacterConnection = nil
    end
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    masslessCharacterConnection = hrp:GetPropertyChangedSignal("Massless"):Connect(function()
        local char = LP.Character or LP.CharacterAdded:Wait()
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then v.Massless = false end
        end
        local currentHRP = char:FindFirstChild("HumanoidRootPart")
        if currentHRP and currentHRP.Massless then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local camPart = char:FindFirstChild("CamPart")
            local head = char:FindFirstChild("Head")
            while char and hum and currentHRP and head and currentHRP.Massless and head.Massless do
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("BasePart") then v.Massless = false task.wait() end
                end
                if currentHRP:FindFirstChild("RootAttachment") and camPart then
                    currentHRP.RootAttachment.Parent = camPart
                end
                if hum.Sit and not hum.SeatPart then hum.Sit = false end
                task.wait(0.1)
            end
        end
    end)
    task.spawn(function()
        local currentHRP = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 10)
        while currentHRP and currentHRP.Parent and currentHRP.Massless do
            for _, v in pairs(character:GetChildren()) do
                if v:IsA("BasePart") then v.Massless = false v.Velocity = Vector3.new() end
                task.wait()
            end
        end
    end)
end

if LP.Character then attachInitMasslessCharacterLogic(LP.Character) end
LP.CharacterAdded:Connect(function(newChar) attachInitMasslessCharacterLogic(newChar) end)

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
    if playerCharacter then return playerCharacter.HumanoidRootPart.CFrame end
end

local function getGroundSafePosition(basePosition)
    local character = LP.Character
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = character and {character} or {}
    raycastParams.IgnoreWater = false
    local origin = basePosition + Vector3.new(0, 8, 0)
    local result = workspace:Raycast(origin, Vector3.new(0, -80, 0), raycastParams)
    if result then return Vector3.new(basePosition.X, result.Position.Y + 3.5, basePosition.Z) end
    return basePosition + Vector3.new(0, 3.5, 0)
end

local function getLiveReturnCFrame(lastCFrame)
    local character = LP.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return lastCFrame end
    return CFrame.new(getGroundSafePosition(hrp.Position))
end

local function Getdistancefromcharacter(characterPosition)
    return LP:DistanceFromCharacter(characterPosition)
end

local function SetModelProperties(parentInstance)
    for _, descendantInstance in pairs(parentInstance:GetDescendants()) do
        if descendantInstance:IsA("BasePart") then descendantInstance.CanCollide = false end
    end
end

local function findCampfire()
    local playerCFrame = GetPlayerCFrame()
    local spawnedCampfire = nil
    for _, childInstance in pairs(workspace:GetChildren()) do
        if childInstance.Name == "Campfire" and childInstance.PrimaryPart and childInstance:FindFirstChild("FirePlayerPart") and childInstance.FirePlayerPart:FindFirstChild("CanBurn") and Getdistancefromcharacter(childInstance.PrimaryPart.Position) < 30 and childInstance.FirePlayerPart.CanBurn.Value then
            spawnedCampfire = childInstance
        end
    end
    if not spawnedCampfire then
        if playerCFrame then
            SpawnToyRF:InvokeServer("Campfire", CFrame.new(playerCFrame.Position.X, playerCFrame.Position.Y, playerCFrame.Position.Z, -0.133750245, -0.471861839, 0.871468484, -3.7252903e-9, 0.879369617, 0.476139903, -0.991015136, 0.0636838302, -0.117615893), Vector3.new(0, 97.69000244140625, 0))
        end
        BuyToy:InvokeServer("Campfire")
    end
    if spawnedCampfire and spawnedCampfire:FindFirstChild("FirePlayerPart") and spawnedCampfire.FirePlayerPart:FindFirstChild("CanBurn") and not spawnedCampfire:GetAttribute("Connected2") then
        local descendantAddedConnection = spawnedCampfire.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "PartOwner" and descendant.Value ~= LP.Name then
                spawnedCampfire:SetAttribute("AlreadySetOwnerShip", false)
            end
        end)
        task.spawn(function()
            local firePlayerPart = spawnedCampfire.FirePlayerPart
            while spawnedCampfire.Parent do
                if not spawnedCampfire:GetAttribute("AlreadySetOwnerShip") then
                    if SNOWshipOnce(firePlayerPart) then
                        spawnedCampfire:SetAttribute("AlreadySetOwnerShip", true)
                    elseif Getdistancefromcharacter(firePlayerPart.Position) > 30 then
                        DeleteToyRE:FireServer(spawnedCampfire)
                    end
                end
                task.wait(0.1)
            end
            descendantAddedConnection:Disconnect()
        end)
        spawnedCampfire:SetAttribute("Connected2", true)
    end
    campfireInstance = spawnedCampfire
end

local function getCampfire()
    if campfireInstance and campfireInstance.Parent ~= nil then return campfireInstance end
    findCampfire()
    return campfireInstance
end

local function handleCampfireTouch(partPosition)
    local currentCampfire = getCampfire()
    local campfirePrimaryPart = currentCampfire and currentCampfire.PrimaryPart or nil
    local characterHead = LP.Character and LP.Character:FindFirstChild("Head") or nil
    if currentCampfire and characterHead and campfirePrimaryPart then
        local campfireFirePart = currentCampfire:FindFirstChild("FirePlayerPart")
        local campfirePosRemove = campfirePrimaryPart:FindFirstChild("CampfirePosRemove")
        if campfireFirePart then campfireFirePart.Size = Vector3.new(2, 2, 2) end
        if not campfirePosRemove and currentCampfire:GetAttribute("AlreadySetOwnerShip") then
            SetModelProperties(currentCampfire)
            local bodyPosition = Instance.new("BodyPosition", currentCampfire.PrimaryPart)
            bodyPosition.Name = "CampfirePosRemove"
            bodyPosition.MaxForce = Vector3.new(12500, 12500, 12500)
            task.spawn(function()
                while currentCampfire.Parent do
                    bodyPosition.Position = characterHead.Position + Vector3.new(5, 500, 0)
                    task.wait()
                end
            end)
        end
        if campfireFirePart and partPosition and currentCampfire:GetAttribute("AlreadySetOwnerShip") and campfirePrimaryPart then
            campfireFirePart.Position = partPosition.Position
            task.wait()
            campfireFirePart.Position = campfirePrimaryPart.Position
        end
    end
end

local antiKickKunai = nil
local suspendAntiKickMaintenance = false
local antiKickSuspendCount = 0
local antiKickHooksInitialized = false

local function setupAntiKickHooks()
    if antiKickHooksInitialized then return end
    antiKickHooksInitialized = true
    pcall(function()
        if hookmetamethod and getnamecallmethod and newcclosure then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if _G.AntiKick and self == LP and (method == "Kick" or method == "kick") then return nil end
                return oldNamecall(self, ...)
            end))
        end
    end)
    pcall(function()
        if hookfunction and newcclosure and LP and LP.Kick then
            local oldKick
            oldKick = hookfunction(LP.Kick, newcclosure(function(...)
                if _G.AntiKick then return nil end
                return oldKick(...)
            end))
        end
    end)
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        local robloxPromptGui = coreGui:FindFirstChild("RobloxPromptGui")
        local promptOverlay = robloxPromptGui and robloxPromptGui:FindFirstChild("promptOverlay")
        if not promptOverlay then return end
        promptOverlay.ChildAdded:Connect(function(child)
            if not _G.AntiKick then return end
            local nameLower = string.lower(child.Name)
            if nameLower:find("error") or nameLower:find("kick") or nameLower:find("disconnect") then
                pcall(function() child.Visible = false end)
                pcall(function() child:Destroy() end)
            end
        end)
    end)
end

local function beginAntiKickSuspend()
    antiKickSuspendCount = antiKickSuspendCount + 1
    suspendAntiKickMaintenance = antiKickSuspendCount > 0
end

local function endAntiKickSuspend()
    antiKickSuspendCount = math.max(0, antiKickSuspendCount - 1)
    suspendAntiKickMaintenance = antiKickSuspendCount > 0
end

local function clearAntiKickKunai()
    local inv = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
    local destroyRemote = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy")
    if inv and destroyRemote then
        for _, toy in ipairs(inv:GetChildren()) do
            if toy.Name == "AntiKick" or toy.Name == "NinjaShuriken" then
                pcall(function() destroyRemote:FireServer(toy) end)
            end
        end
    end
    antiKickKunai = nil
end

local function getAntiKickRoot()
    local char = LP.Character or LP.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
end

local function findAntiKickKunaiInWorld()
    local inv = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
    if inv then return inv:FindFirstChild("AntiKick") or inv:FindFirstChild("NinjaShuriken") end
    return nil
end

local function spawnAntiKickKunai()
    local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
    local spawnRemote = menuToys and menuToys:FindFirstChild("SpawnToyRemoteFunction")
    if not spawnRemote then return nil end
    local canSpawn = LP:FindFirstChild("CanSpawnToy")
    local startTick = tick()
    while canSpawn and not canSpawn.Value do
        if not _G.AntiKick or tick() - startTick > 5 then return nil end
        task.wait(0.1)
    end
    local hrp = getAntiKickRoot()
    if not hrp then return nil end
    pcall(function() spawnRemote:InvokeServer("NinjaShuriken", hrp.CFrame * CFrame.new(0, 12, 20), Vector3.zero) end)
    task.wait(0.1)
    return findAntiKickKunaiInWorld()
end

local function styleAndStickAntiKickKunai(kunai)
    if not kunai or not kunai.Parent then return end
    local stickyPart = kunai:FindFirstChild("StickyPart")
    if not stickyPart then return end
    local hrp = getAntiKickRoot()
    if not hrp then return end
    local setOwner = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
    local stickyEvent = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
    if kunai:FindFirstChild("SoundPart") then
        local owner = kunai.SoundPart:FindFirstChild("PartOwner")
        if not owner or owner.Value ~= LP.Name then
            pcall(function() setOwner:FireServer(kunai.SoundPart, kunai.SoundPart.CFrame) end)
        end
    end
    local firePart = hrp:FindFirstChild("FirePlayerPart") or hrp:WaitForChild("FirePlayerPart", 2)
    if firePart then
        pcall(function() stickyEvent:FireServer(stickyPart, firePart, CFrame.new() * CFrame.Angles(0, math.rad(90), math.rad(90))) end)
    end
    for _, obj in ipairs(kunai:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanTouch = false
            obj.CanCollide = false
            obj.CanQuery = false
            obj.Transparency = (obj.Name == "Main" or obj.Name == "Pyramid") and 0 or 1
        end
    end
    kunai.Name = "AntiKick"
end

local function GetKunai()
    if suspendAntiKickMaintenance then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and hum and hum.Health > 0) then return end
    if not antiKickKunai or not antiKickKunai.Parent then
        antiKickKunai = findAntiKickKunaiInWorld() or spawnAntiKickKunai()
    end
    if not antiKickKunai or not antiKickKunai.Parent then return end
    styleAndStickAntiKickKunai(antiKickKunai)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local stickyPart = antiKickKunai:FindFirstChild("StickyPart")
    if hrp and stickyPart and (hrp.Position - stickyPart.Position).Magnitude >= 20 then
        clearAntiKickKunai()
    end
end

function dialogueFunction2() end
function dialogueFunction1() end

local function resetGlitchedSpikeIfNeeded()
    if not _G.AntiKick then return end
    local inv = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
    local spike = inv and (inv:FindFirstChild("AntiKick") or inv:FindFirstChild("NinjaShuriken"))
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not spike then return end
    local sticky = spike:FindFirstChild("StickyPart")
    local dist = (hrp and sticky) and (hrp.Position - sticky.Position).Magnitude or math.huge
    local soundPart = spike:FindFirstChild("SoundPart")
    local owner = soundPart and soundPart:FindFirstChild("PartOwner")
    local wrongOwner = owner and owner.Value ~= LP.Name
    if dist > 40 or wrongOwner or not sticky then clearAntiKickKunai() end
end

local function forceReleaseHeldInventoryAndGrab()
    local inv = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if inv and hrp then
        for _, toy in ipairs(inv:GetChildren()) do
            local holdPart = toy:FindFirstChild("HoldPart")
            local holder = holdPart and holdPart:FindFirstChild("HoldingPlayer")
            if holdPart and holder and holder.Value == LP then
                pcall(function() holdPart.DropItemRemoteFunction:InvokeServer(toy, hrp.CFrame * CFrame.new(0, 6, 0), Vector3.zero) end)
            end
        end
    end
    if _G.HoldingObjectGrabPart then
        pcall(function() destroyGrabLineEvent:FireServer(_G.HoldingObjectGrabPart) end)
    end
    if _G.RealGrabParts and _G.RealGrabParts.Parent then
        pcall(function() _G.RealGrabParts:Destroy() end)
    end
    _G.HoldingObjectGrabPart = nil
    _G.RealGrabParts = nil
end

local function recoverFromLoopKillBugState()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum then
        hum.PlatformStand = false
        hum.Sit = false
        hum.AutoRotate = true
        if hum.WalkSpeed < 8 then hum.WalkSpeed = 16 end
        if hum.UseJumpPower and hum.JumpPower < 25 then hum.JumpPower = 50
        elseif not hum.UseJumpPower and hum.JumpHeight < 4 then hum.JumpHeight = 7.2 end
    end
    if hrp then
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    _G.TP_Priority = 0
    _G.TeleportingToNetworkOwnership = false
    forceReleaseHeldInventoryAndGrab()
    resetGlitchedSpikeIfNeeded()
end

function CheckPlayerForLoopKill(player)
    if CheckPlayerKill(player) then return true end
end

function CheckNetworkOwnerShipOnPlayer(potentialPlayer, condition)
    if typeof(potentialPlayer) == "Instance" and (potentialPlayer:IsA("Player") and potentialPlayer.Character) and (potentialPlayer.Character:FindFirstChild("Head") and (potentialPlayer.Character.Head:FindFirstChild("PartOwner") and potentialPlayer.Character.Head.PartOwner.Value == LP.Name)) then
        return not condition and true or potentialPlayer.Character.Head.PartOwner
    end
end

local function teardownFurtherExtend()
    extendFollowActive = false
    if activeExtendGrabModel and activeExtendGrabModel.Parent then
        local originalDragPart = activeExtendGrabModel:FindFirstChild("DragPart")
        if originalDragPart and originalDragPart:FindFirstChild("AlignPosition") then
            originalDragPart.AlignPosition.Enabled = true
        end
    end
    if activeExtendDragPart and activeExtendDragPart.Parent then activeExtendDragPart:Destroy() end
    activeExtendGrabModel = nil
    activeExtendDragPart = nil
    pcDistance = 0
end

local function setupFurtherExtend(grabPartModel)
    if not (_G.FutherExtend and UserInputService.MouseEnabled) then return end
    if not (grabPartModel and grabPartModel:IsA("Model") and grabPartModel.Parent) then return end
    local dragPart = grabPartModel:FindFirstChild("DragPart")
    if not dragPart then return end
    teardownFurtherExtend()
    local dragPartClone = dragPart:Clone()
    dragPartClone.Name = "DragPart1"
    if dragPartClone:FindFirstChild("AlignPosition") and dragPartClone:FindFirstChild("DragAttach") then
        dragPartClone.AlignPosition.Attachment1 = dragPartClone.DragAttach
    end
    dragPartClone.Parent = grabPartModel
    if workspace.CurrentCamera then
        pcDistance = (dragPartClone.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    else
        pcDistance = 11
    end
    if dragPartClone:FindFirstChild("AlignOrientation") then dragPartClone.AlignOrientation.Enabled = false end
    if dragPart:FindFirstChild("AlignPosition") then dragPart.AlignPosition.Enabled = false end
    activeExtendGrabModel = grabPartModel
    activeExtendDragPart = dragPartClone
    extendFollowActive = true
    task.spawn(function()
        while extendFollowActive and activeExtendGrabModel == grabPartModel and grabPartModel.Parent and dragPartClone.Parent do
            if workspace.CurrentCamera then
                dragPartClone.Position = workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * pcDistance
            end
            task.wait()
        end
        if activeExtendDragPart == dragPartClone then teardownFurtherExtend() end
    end)
end

workspace.ChildAdded:Connect(function(child)
    if child.Name == "GrabParts" then
        local success, grabPart = pcall(function()
            return child:WaitForChild("GrabPart"):WaitForChild("WeldConstraint").Part1
        end)
        if not success or not grabPart then return end
        if not child:GetAttribute("Fake") then _G.RealGrabParts = child end
        _G.HoldingObjectGrabPart = grabPart
        setupFurtherExtend(child)
        local bodyVelocity = nil
        if _G.SuperFlingEnabled then
            bodyVelocity = Instance.new("BodyVelocity", grabPart)
            bodyVelocity.Name = FLING_VELOCITY_NAME
            bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            bodyVelocity.Velocity = Vector3.new()
        end
        task.spawn(function()
            if not bodyVelocity then return end
            if not LP.PlayerGui:FindFirstChild("ContextActionGui") then return end
            local contextActionGuiButtonParent = nil
            local mouseButtonDownConnection = nil
            local disconnectEvent = nil
            while contextActionGuiButtonParent == nil and child.Parent do
                for _, descendant in pairs(LP.PlayerGui.ContextActionGui:GetDescendants()) do
                    if descendant:IsA("ImageLabel") and descendant.Image == "http://www.roblox.com/asset/?id=9603678090" then
                        contextActionGuiButtonParent = descendant.Parent
                        break
                    end
                end
                task.wait()
            end
            if not contextActionGuiButtonParent then return end
            contextActionGuiButtonParent.Active = true
            mouseButtonDownConnection = contextActionGuiButtonParent.MouseButton1Down:Connect(function()
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.FlingStrength
            end)
            disconnectEvent = child:GetPropertyChangedSignal("Parent"):Connect(function()
                if not child.Parent then
                    Debris:AddItem(bodyVelocity, 1)
                    if mouseButtonDownConnection then mouseButtonDownConnection:Disconnect() end
                    if disconnectEvent then disconnectEvent:Disconnect() end
                end
            end)
        end)
        task.spawn(function()
            if not bodyVelocity then return end
            local parentChangedConnection = nil
            parentChangedConnection = child:GetPropertyChangedSignal("Parent"):Connect(function()
                if not child.Parent then
                    if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 and _G.SuperFlingEnabled then
                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bodyVelocity.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.FlingStrength
                        Debris:AddItem(bodyVelocity, 1)
                    else
                        bodyVelocity:Destroy()
                    end
                    parentChangedConnection:Disconnect()
                end
            end)
        end)
        if _G.MasslessGrab then
            task.spawn(function()
                local dragPart = child:FindFirstChild("DragPart") or child:WaitForChild("DragPart", 2)
                local dragPartAlignOrientation = dragPart and dragPart:FindFirstChild("AlignOrientation")
                local dragPartAlignPosition = dragPart and dragPart:FindFirstChild("AlignPosition")
                if not (dragPartAlignOrientation and dragPartAlignPosition) then return end
                dragPartAlignOrientation.MaxTorque = math.huge
                dragPartAlignOrientation.Responsiveness = 200
                dragPartAlignPosition.MaxForce = math.huge
                dragPartAlignPosition.Responsiveness = 200
            end)
        end
        if _G.Poison_Grab then
            task.spawn(function()
                if grabPart.Parent and grabPart.Parent:FindFirstChildOfClass("Humanoid") and grabPart.Parent:FindFirstChild("Head") then
                    local characterHead = grabPart.Parent.Head
                    while child.Parent and _G.Poison_Grab do
                        bigHolePoisonPart.CFrame = characterHead.CFrame
                        smallHolePoisonPart.CFrame = characterHead.CFrame
                        factoryIslandPoisonPart.CFrame = characterHead.CFrame
                        task.wait()
                        factoryIslandPoisonPart.Position = Vector3.new(0, -50, 0)
                        smallHolePoisonPart.Position = Vector3.new(0, -50, 0)
                        bigHolePoisonPart.Position = Vector3.new(0, -50, 0)
                    end
                end
            end)
        end
        if _G.Burn_Grab then
            task.spawn(function()
                while child.Parent and _G.Burn_Grab do
                    if grabPart.Parent and grabPart.Parent:FindFirstChildOfClass("Humanoid") and grabPart.Parent:FindFirstChild("HumanoidRootPart") then
                        handleCampfireTouch(grabPart.Parent.HumanoidRootPart)
                    elseif grabPart.Parent and grabPart.Parent:FindFirstChild("FireDetector") then
                        handleCampfireTouch(grabPart.Parent.FireDetector)
                    else
                        handleCampfireTouch(grabPart)
                    end
                    task.wait()
                end
            end)
        end
        if _G.Death_Grab then
            task.spawn(function()
                if grabPart.Parent and grabPart.Parent:FindFirstChildOfClass("Humanoid") then
                    local characterHumanoid = grabPart.Parent:FindFirstChildOfClass("Humanoid")
                    while grabPart.Parent do
                        local player = Players:GetPlayerFromCharacter(grabPart.Parent)
                        if player and CheckNetworkOwnerShipOnPlayer(player) then
                            characterHumanoid.BreakJointsOnDeath = false
                            characterHumanoid:ChangeState(Enum.HumanoidStateType.Dead)
                            characterHumanoid.Jump = true
                            characterHumanoid.Sit = false
                            if characterHumanoid:GetStateEnabled(Enum.HumanoidStateType.Dead) then
                                destroyGrabLineEvent:FireServer(grabPart)
                            end
                        end
                        task.wait()
                    end
                end
            end)
        end
    end
end)

workspace.ChildRemoved:Connect(function(part)
    if part.Name == "GrabParts" and not part:GetAttribute("Fake") then
        _G.RealGrabParts = nil
        _G.HoldingObjectGrabPart = nil
        teardownFurtherExtend()
    end
end)

UserInputService.InputChanged:Connect(function(inputObject)
    if not _G.FutherExtend then return end
    if inputObject.UserInputType ~= Enum.UserInputType.MouseWheel then return end
    local heldPart = _G.HoldingObjectGrabPart
    if not heldPart or not heldPart.Parent then return end
    if pcDistance <= 0 and workspace.CurrentCamera then
        pcDistance = (heldPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    end
    if pcDistance < 11 then pcDistance = 11 end
    if inputObject.Position.Z <= 0 then
        if inputObject.Position.Z < 0 then pcDistance = pcDistance - IncreaseLineExtend end
    else
        pcDistance = pcDistance + IncreaseLineExtend
    end
    if not activeExtendDragPart then extendGrabLineEvent:FireServer(pcDistance) end
end)

RunService.Heartbeat:Connect(function()
    if _G.SuperSpeed then
        local character = LP.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoidRootPart and humanoid then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + humanoid.MoveDirection * Multiplier
        end
    end
end)

local Window = Rayfield:CreateWindow({
    Name = "Crimson FTAP (Pc recommended for full functionality)",
    LoadingTitle = "Crimson FTAP - Homer, Virck",
    LoadingSubtitle = "Loading",
    Theme = {
        TextColor = Color3.fromRGB(238, 224, 226),
        Background = Color3.fromRGB(22, 8, 10),
        Topbar = Color3.fromRGB(30, 10, 13),
        Shadow = Color3.fromRGB(14, 5, 7),
        NotificationBackground = Color3.fromRGB(26, 10, 12),
        NotificationActionsBackground = Color3.fromRGB(230, 210, 214),
        TabBackground = Color3.fromRGB(60, 20, 26),
        TabStroke = Color3.fromRGB(80, 28, 36),
        TabBackgroundSelected = Color3.fromRGB(178, 48, 66),
        TabTextColor = Color3.fromRGB(228, 204, 208),
        SelectedTabTextColor = Color3.fromRGB(247, 232, 235),
        ElementBackground = Color3.fromRGB(44, 15, 20),
        ElementBackgroundHover = Color3.fromRGB(58, 20, 26),
        SecondaryElementBackground = Color3.fromRGB(32, 11, 14),
        ElementStroke = Color3.fromRGB(92, 34, 43),
        SecondaryElementStroke = Color3.fromRGB(72, 27, 34),
        SliderBackground = Color3.fromRGB(146, 40, 54),
        SliderProgress = Color3.fromRGB(188, 52, 70),
        SliderStroke = Color3.fromRGB(216, 66, 85),
        ToggleBackground = Color3.fromRGB(42, 15, 20),
        ToggleEnabled = Color3.fromRGB(184, 50, 66),
        ToggleDisabled = Color3.fromRGB(88, 54, 59),
        ToggleEnabledStroke = Color3.fromRGB(214, 66, 84),
        ToggleDisabledStroke = Color3.fromRGB(106, 70, 75),
        ToggleEnabledOuterStroke = Color3.fromRGB(142, 56, 66),
        ToggleDisabledOuterStroke = Color3.fromRGB(68, 34, 39),
        DropdownSelected = Color3.fromRGB(62, 22, 28),
        DropdownUnselected = Color3.fromRGB(38, 14, 18),
        InputBackground = Color3.fromRGB(42, 16, 20),
        InputStroke = Color3.fromRGB(98, 38, 46),
        PlaceholderColor = Color3.fromRGB(164, 126, 132)
    },
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CrimsonFTAPConfigs",
        FileName = "Main"
    },
    KeySystem = false,
    KeySettings = { Title = "Crimson Key", Key = {"PassedCrimson"} }
})

local function CreateTabSafe(tabName, iconName, fallbackIconId)
    local ok, tab = pcall(function() return Window:CreateTab(tabName, iconName) end)
    if ok and tab then return tab end
    return Window:CreateTab(tabName, fallbackIconId or 4483362458)
end

local CombatTab = CreateTabSafe("Combat", "swords", 4483362458)
local ProtTab = CreateTabSafe("Invincibility", "shield", 4483362458)
local LocalPlayerTab = CreateTabSafe("Local Player", "user", 4483362458)
local LoopPlayersTab = CreateTabSafe("Loop Players", "users", 4483362458)
local ESPTab = CreateTabSafe("ESP", "eye", 4483362458)
local BlobmanTab = CreateTabSafe("Teleport", "map-pin", 4483362458)
local ServerTab = CreateTabSafe("Server", "server", 4483362458)
local WhitelistTab = CreateTabSafe("Whitelist", "shield-check", 4483362458)
local SettingsTab = CreateTabSafe("Settings", "settings", 4483362458)
local ScriptTab = CreateTabSafe("Script", "file-code", 4483362458)

local DetectLag = true
local Alarm = true
local antiInputLagToggle = nil
local antiInputLagRunId = 0
local antiInputLagRestartQueued = false
local antiInputLagLastRestartAt = 0

SettingsTab:CreateSection("Script Settings")

SettingsTab:CreateToggle({
    Name = "Detect Lag Script",
    CurrentValue = true,
    Flag = "detect_lag_script_toggle",
    Callback = function(Value) DetectLag = Value end
})

SettingsTab:CreateToggle({
    Name = "Alarm When Lag Is Detected",
    CurrentValue = true,
    Flag = "alarm_when_lag_detected_toggle",
    Callback = function(Value) Alarm = Value end
})

-- ============================================================
-- Combat Tab
-- ============================================================
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

CombatTab:CreateSection("Grab Options")

CombatTab:CreateToggle({
    Name = "Poison Grab",
    CurrentValue = false,
    Flag = "poisongrab_toggle",
    Callback = function(Value) _G.Poison_Grab = Value end
})

CombatTab:CreateToggle({
    Name = "Burn Grab",
    CurrentValue = false,
    Flag = "burngrab_toggle",
    Callback = function(Value) _G.Burn_Grab = Value end
})

CombatTab:CreateToggle({
    Name = "Death Grab",
    CurrentValue = false,
    Flag = "deathgrab_toggle",
    Callback = function(Value) _G.Death_Grab = Value end
})

CombatTab:CreateToggle({
    Name = "Massless Grab (FIXED)",
    CurrentValue = false,
    Flag = "masslessgrab_toggle",
    Callback = function(Value)
        _G.MasslessGrab = Value
        refreshInitMasslessGrabHook()
    end
})

CombatTab:CreateSection("Line Extender")

CombatTab:CreateToggle({
    Name = "Further Extend",
    CurrentValue = false,
    Flag = "FurtherLineExtend_toggle",
    Callback = function(Value)
        _G.FutherExtend = Value
        if Value then
            local currentGrab = _G.RealGrabParts or workspace:FindFirstChild("GrabParts")
            if currentGrab and currentGrab:IsA("Model") then setupFurtherExtend(currentGrab) end
        else
            teardownFurtherExtend()
        end
    end
})

CombatTab:CreateSlider({
    Name = "Increase Extend",
    Range = {3, 25},
    Increment = 1,
    CurrentValue = 3,
    Flag = "FurtherLineExtend_slider",
    Callback = function(Value) IncreaseLineExtend = Value end
})

-- ============================================================
-- Protection Tab
-- ============================================================
ProtTab:CreateSection("Anti")

local antiGrabHeartbeatConnection = nil

local function stopAntiGrabHeartbeat()
    if antiGrabHeartbeatConnection then
        antiGrabHeartbeatConnection:Disconnect()
        antiGrabHeartbeatConnection = nil
    end
    local character = LP.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.Velocity = Vector3.new()
        humanoidRootPart.Anchored = false
    end
end

local function startAntiGrabHeartbeat()
    stopAntiGrabHeartbeat()
    antiGrabHeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not (_G.AntiGrab and isHeldValue and isHeldValue.Value) then
            stopAntiGrabHeartbeat()
            return
        end
        local character = LP.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.Velocity = Vector3.new()
            humanoidRootPart.Anchored = true
            struggleEvent:FireServer(LP)
            ragdollRemoteEvent:FireServer(humanoidRootPart, 0)
        end
    end)
end

if isHeldValue then
    isHeldValue.Changed:Connect(function(isHeldNow)
        if isHeldNow == true and _G.AntiGrab then startAntiGrabHeartbeat()
        else stopAntiGrabHeartbeat() end
    end)
end

ProtTab:CreateToggle({
    Name = "Anti Blobman",
    CurrentValue = false,
    Flag = "anti_blobman_toggle",
    Callback = function(Value)
        v14_AntiBlobman = Value
        if v14_AntiBlobman then
            task.spawn(function()
                while v14_AntiBlobman do
                    if suspendAntiBlobmanMaintenance then task.wait(0.1) continue end
                    local char = LP.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and (v.Name == "LeftDetector" or v.Name == "RightDetector") then
                                local owningBlob = v:FindFirstAncestorOfClass("Model")
                                if antiGucciBlobActive and owningBlob and owningBlob.Name == "CreatureBlobman" and isOwnBlobmanModel(owningBlob) then
                                    continue
                                end
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
    Flag = "anti_grab_toggle",
    Callback = function(Value)
        v79_AntiGrab = Value
        _G.AntiGrab = Value
        if Value then
            if isHeldValue and isHeldValue.Value then startAntiGrabHeartbeat() end
            struggleEvent:FireServer(LP)
        else
            stopAntiGrabHeartbeat()
        end
    end
})

ProtTab:CreateToggle({
    Name = "Anti Explode",
    CurrentValue = false,
    Flag = "anti_explode_toggle",
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
    Flag = "anti_burn_toggle",
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

-- ============================================================
-- Anti Input Lag (Burger Spam)
-- ============================================================
do
    local _anoOn   = false
    local _ToyName = "FoodHamburger"

    local _spawnFn  = ReplicatedStorage:FindFirstChild("MenuToys")
                      and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
    local _canSpawn = LP:WaitForChild("CanSpawnToy", 10)

    if not _spawnFn then
        task.spawn(function()
            pcall(function()
                local mt = ReplicatedStorage:WaitForChild("MenuToys", 12)
                _spawnFn = mt:WaitForChild("SpawnToyRemoteFunction", 8)
            end)
        end)
    end

    local function findExisting()
        local inv = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
        if inv then
            local b = inv:FindFirstChild(_ToyName)
            if b then return b end
        end
        return nil
    end

    local function startBurgerLoop()
        task.spawn(function()
            while _anoOn do
                RunService.Heartbeat:Wait()

                local char = LP.Character
                local hum  = char and char:FindFirstChild("Humanoid")
                if not (char and hum and hum.Health > 0) then continue end

                local burger = findExisting()
                if not burger then
                    if _canSpawn then
                        while _anoOn and not _canSpawn.Value do task.wait(0.1) end
                    end
                    if not _anoOn then break end
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then task.wait(0.1) continue end
                    if _spawnFn then
                        task.spawn(function()
                            pcall(function()
                                _spawnFn:InvokeServer(_ToyName, hrp.CFrame * CFrame.new(0, 3, 0), Vector3.new(0, 0, 0))
                            end)
                        end)
                    else
                        task.wait(0.1) continue
                    end
                    local t = tick()
                    while _anoOn and (tick() - t) < 3 do
                        RunService.Heartbeat:Wait()
                        burger = findExisting()
                        if burger then break end
                    end
                    if not burger then task.wait(0.1) continue end
                end

                pcall(function()
                    for _, p in ipairs(burger:GetDescendants()) do
                        if p:IsA("BasePart") and p.Transparency < 1 then p.Transparency = 1 end
                    end
                end)

                local _spamBusy = false

                repeat
                    local c    = LP.Character
                    local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
                    if c and hrp2 and burger and burger.Parent then
                        local holdPart = burger:FindFirstChild("HoldPart")
                        if holdPart then
                            local hv     = holdPart:FindFirstChild("HoldingPlayer")
                            local holder = hv and hv.Value
                            if holder and holder ~= LP then
                                task.spawn(function()
                                    pcall(function()
                                        holdPart.DropItemRemoteFunction:InvokeServer(burger, hrp2.CFrame * CFrame.new(0, 6, 0), Vector3.new(0, 0, 0))
                                    end)
                                end)
                                pcall(function() burger:Destroy() end)
                                burger = nil
                                break
                            end
                            if not _spamBusy then
                                _spamBusy = true
                                local b, c2, h2 = burger, c, hrp2
                                task.spawn(function()
                                    pcall(function() holdPart.HoldItemRemoteFunction:InvokeServer(b, c2) end)
                                    RunService.Heartbeat:Wait()
                                    pcall(function()
                                        holdPart.DropItemRemoteFunction:InvokeServer(b, h2.CFrame * CFrame.new(0, 6, 0), Vector3.new(0, 0, 0))
                                    end)
                                    _spamBusy = false
                                end)
                            end
                        end
                    end
                    RunService.Heartbeat:Wait()
                until not _anoOn or not burger or not burger.Parent
            end
        end)
    end

    antiInputLagToggle = ProtTab:CreateToggle({
        Name = "Anti Input Lag (Burger Spam)",
        CurrentValue = false,
        Flag = "anti_input_lag_toggle",
        Callback = function(Value)
            _anoOn = Value
            _G.AntiInputLag = Value
            if Value then
                startBurgerLoop()
            end
        end
    })
end

local antiLagToggle = nil
_G.AntiLag = false

task.defer(function()
    local lagDetectCooldown = 0
    while true do
        task.wait(1)
        if DetectLag and tick() - lagDetectCooldown > 10 then
            local fps = workspace:GetRealPhysicsFPS()
            if fps > 0 and fps <= 25 then
                lagDetectCooldown = tick()
                Rayfield:Notify({
                    Title = "!! Lag Script Detected",
                    Content = "FPS dropped to " .. math.floor(fps) .. ". Auto-enabling Anti Lag and Anti Input Lag.",
                    Duration = 8
                })
                if Alarm then
                    local portalAlarm = Instance.new("Sound")
                    portalAlarm.Name = "Portal Alarm"
                    portalAlarm.PlaybackSpeed = 0.95
                    portalAlarm.Pitch = 0.95
                    portalAlarm.SoundId = "rbxassetid://549313210"
                    portalAlarm.Volume = 0.25
                    portalAlarm.Parent = workspace
                    local count = 0
                    local max = 2
                    local function sigmasex()
                        count = count + 1
                        if count <= max then portalAlarm:Play()
                        else portalAlarm:Destroy() end
                    end
                    portalAlarm.Ended:Connect(sigmasex)
                    portalAlarm:Play()
                end
                if antiInputLagToggle then antiInputLagToggle:Set(true)
                else _G.AntiInputLag = true end
                if antiLagToggle then antiLagToggle:Set(true)
                else
                    _G.AntiLag = true
                    local scripts = LP:FindFirstChild("PlayerScripts")
                    local beam = scripts and scripts:FindFirstChild("CharacterAndBeamMove")
                    if beam then beam.Disabled = true end
                end
                if setfpscap then setfpscap(10000) end
            end
        end
    end
end)

ProtTab:CreateToggle({
    Name = "Anti-Kick",
    CurrentValue = false,
    Flag = "antikick_toggle",
    Callback = function(Value)
        setupAntiKickHooks()
        _G.AntiKick = Value
        _G.ShurikenAntiKick = Value
        if Value then
            task.spawn(function()
                while _G.AntiKick do
                    if not suspendAntiKickMaintenance then
                        GetKunai()
                        task.wait()
                    else
                        task.wait(0.1)
                    end
                end
            end)
        else
            _G.AntiKick = false
            _G.ShurikenAntiKick = false
            clearAntiKickKunai()
        end
    end
})

antiLagToggle = ProtTab:CreateToggle({
    Name = "Anti Lag (Invis Line)",
    CurrentValue = false,
    Flag = "anti_lag_toggle",
    Callback = function(Value)
        _G.AntiLag = Value
        local scripts = LP:FindFirstChild("PlayerScripts")
        local beam = scripts and scripts:FindFirstChild("CharacterAndBeamMove")
        if beam then beam.Disabled = Value end
    end,
})

-- ============================================================
-- GUCCI ANTI-GRAB
-- ============================================================
local function runGucciAntiGrab()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    local HRP = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    if not (hum and HRP) then return end

    local inv2 = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
        or workspace:WaitForChild(LP.Name .. "SpawnedInToys", 5)
    if not inv2 then return end

    local canSpawn = LP:FindFirstChild("CanSpawnToy")
    if canSpawn and not canSpawn.Value then canSpawn.Changed:Wait() end

    local blobb = nil
    local conn2
    conn2 = inv2.ChildAdded:Connect(function(c)
        if c.Name == "CreatureBlobman" then
            blobb = c
            conn2:Disconnect()
        end
    end)

    SpawnToyRF:InvokeServer("CreatureBlobman", HRP.CFrame * CFrame.new(3, 2, 0), Vector3.new(0, 0, 0))

    local timeout = tick() + 4
    repeat task.wait() until blobb or tick() > timeout
    if conn2 then conn2:Disconnect() end
    if not blobb then return end

    local seat = blobb:WaitForChild("VehicleSeat", 3)
    if not seat then return end

    seat:Sit(hum)

    local ragdollEnd = tick() + 1.5
    task.spawn(function()
        while tick() < ragdollEnd do
            ragdollRemoteEvent:FireServer(HRP, 0)
            task.wait(0.05)
        end
    end)

    local seatWait = tick() + 3
    while seat.Occupant ~= hum and tick() < seatWait do task.wait() end
    if seat.Occupant ~= hum then return end

    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait(0.05)

    local detector = blobb:FindFirstChild("RightDetector")
    if detector then
        setNetworkOwnerEvent:FireServer(detector, detector.CFrame)
    end

    task.wait(0.15)

    SinkBlob:FireServer(blobb)
end

ProtTab:CreateSection("Gucci")

ProtTab:CreateButton({
    Name = "Gucci Anti-Grab [G]",
    Callback = runGucciAntiGrab,
})

-- ============================================================
-- Local Player Tab
-- ============================================================
LocalPlayerTab:CreateSection("Local Player")

local floatSteppedConnection = nil

local function startFloating()
    if floatSteppedConnection then return end
    floatSteppedConnection = RunService.Stepped:Connect(function()
        if not _G.noclip then return end
        local ok, err = pcall(function()
            local character = LP.Character
            if not character then return end
            for _, hitPart in pairs(character:GetChildren()) do
                if hitPart:IsA("BasePart") and hitPart.CanCollide then hitPart.CanCollide = false end
            end
        end)
        if not ok then warn("Noclip stepped error:", err) end
    end)
end

local function stopFloating()
    if floatSteppedConnection then
        floatSteppedConnection:Disconnect()
        floatSteppedConnection = nil
    end
end

dialogueFunction2 = function()
    if _G.noclip then startFloating() end
end

dialogueFunction1 = function()
    stopFloating()
end

local function isOwnBlobmanModel(blobModel)
    local toysFolder = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
    return toysFolder and blobModel and blobModel.Parent == toysFolder
end

if _G.noclip then startFloating() end

LP.CharacterAdded:Connect(function()
    if _G.noclip then
        stopFloating()
        startFloating()
    end
end)

LocalPlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "noclip_toggle",
    Callback = function(Value)
        _G.noclip = Value
        _G.NoclipToggle = Value
        if Value then dialogueFunction2() else dialogueFunction1() end
    end
})

local spaceHeld = false
local moveForward = false
local moveBackward = false
local moveLeft = false
local moveRight = false

mouse.KeyDown:Connect(function(k)
    if k == "g" then
        task.spawn(runGucciAntiGrab)
        return
    end
    local keyCode = k:byte()
    if keyCode == 32 then spaceHeld = true
    elseif keyCode == 119 then moveForward = true
    elseif keyCode == 115 then moveBackward = true
    elseif keyCode == 97 then moveLeft = true
    elseif keyCode == 100 then moveRight = true end
end)

mouse.KeyUp:Connect(function(k)
    local keyCode = k:byte()
    if keyCode == 32 then spaceHeld = false
    elseif keyCode == 119 then moveForward = false
    elseif keyCode == 115 then moveBackward = false
    elseif keyCode == 97 then moveLeft = false
    elseif keyCode == 100 then moveRight = false end
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
                if moveForward then forwardVelocity = forwardVelocity + (lookVector * speed) end
                if moveBackward then forwardVelocity = forwardVelocity - (lookVector * speed) end
                if moveLeft then forwardVelocity = forwardVelocity - (rightVector * speed) end
                if moveRight then forwardVelocity = forwardVelocity + (rightVector * speed) end
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
    Flag = "infinite_jump_toggle",
    Callback = function(Value) _G.infinjump = Value end
})

LocalPlayerTab:CreateSection("Walkspeed")

LocalPlayerTab:CreateToggle({
    Name = "Walkspeed",
    CurrentValue = false,
    Flag = "walkspeed_toggle",
    Callback = function(Value) _G.SuperSpeed = Value end
})

LocalPlayerTab:CreateSlider({
    Name = "Speed",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 15,
    Flag = "walkspeed_slider",
    Callback = function(Value) Multiplier = Value * 0.01 end
})

LocalPlayerTab:CreateSlider({
    Name = "Field of View (FOV)",
    Range = {30, 120},
    Increment = 1,
    CurrentValue = 70,
    Flag = "FOVSlider",
    Callback = function(Value) workspace.CurrentCamera.FieldOfView = Value end
})

-- ============================================================
-- ============================================================
-- SAVITAR - 3rd Person System
-- ============================================================
local LookEvent = ReplicatedStorage:WaitForChild("CharacterEvents"):WaitForChild("Look")

local Savitar = {
    Active = false,
    LastSafeCFrame = nil,
    IsRecovering = false,
    RotationMode = false
}

-- Single persistent RenderStepped connection that runs always.
-- When 3rd person ON:  min=4 max=400 (free scroll, but cannot go to first person)
-- When 3rd person OFF: min=0 max=0 (forces first person, blocks scrolling out)
local savitarZoomConn = nil

local function savitarStartZoomLock()
    if savitarZoomConn then savitarZoomConn:Disconnect() savitarZoomConn = nil end
    savitarZoomConn = RunService.RenderStepped:Connect(function()
        if _G.thirdPerson and Savitar.Active then
            -- Free scroll in third person, just prevent going to first person
            LP.CameraMinZoomDistance = 4
            LP.CameraMaxZoomDistance = 400
        else
            -- Third person off: lock to 0 so scroll cannot zoom out to third person
            LP.CameraMinZoomDistance = 0
            LP.CameraMaxZoomDistance = 0
        end
    end)
end

local function savitarStopZoomLock()
    if savitarZoomConn then
        savitarZoomConn:Disconnect()
        savitarZoomConn = nil
    end
    -- Fully restore defaults when the feature is killed entirely (e.g. Kill Script)
    LP.CameraMinZoomDistance = 0.5
    LP.CameraMaxZoomDistance = 400
end

-- Main loop: only updates camera subject + sends look direction
-- Does NOT touch character parts (that caused the glitching)
task.spawn(function()
    while true do
        task.wait()
        if _G.thirdPerson and Savitar.Active then
            if not Savitar.IsRecovering then
                local camera = workspace.CurrentCamera
                local char = LP.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if camera and humanoid then
                    LP.CameraMode = Enum.CameraMode.Classic
                    camera.CameraType = Enum.CameraType.Custom
                    camera.CameraSubject = humanoid
                    if Savitar.RotationMode then
                        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                    else
                        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                    end
                    if char:FindFirstChild("Head") then
                        local camLook = camera.CFrame.LookVector
                        local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
                        if flatLook.Magnitude > 0 then
                            LookEvent:FireServer(flatLook.Unit)
                        else
                            LookEvent:FireServer(Vector3.new(0, 0, -1))
                        end
                    end
                end
            end
            -- Auto recover if player flies off map
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local p = hrp.Position
                if p.Magnitude > 2500 or p.Y < -500 or (p.X ~= p.X) then
                    Savitar.IsRecovering = true
                    hrp.Velocity = Vector3.zero
                    hrp.RotVelocity = Vector3.zero
                    if Savitar.LastSafeCFrame then hrp.CFrame = Savitar.LastSafeCFrame end
                    task.wait(0.05)
                    Savitar.IsRecovering = false
                elseif hrp.Velocity.Magnitude < 40 then
                    Savitar.LastSafeCFrame = hrp.CFrame
                end
            end
        end
    end
end)

-- R key = free rotation mode
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.R and _G.thirdPerson then
        Savitar.RotationMode = true
    end
end)
UserInputService.InputEnded:Connect(function(input, _processed)
    if input.KeyCode == Enum.KeyCode.R then
        Savitar.RotationMode = false
    end
end)

local function enableThirdPersonView()
    local character = LP.Character
    local camera = workspace.CurrentCamera
    if not (character and camera) then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 3)
    if not humanoid then return end
    LP.CameraMode = Enum.CameraMode.Classic
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
    Savitar.Active = true
    Savitar.RotationMode = false
    if character:FindFirstChild("HumanoidRootPart") then
        Savitar.LastSafeCFrame = character.HumanoidRootPart.CFrame
    end
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    savitarStartZoomLock()
end

local function disableThirdPersonView()
    Savitar.Active = false
    Savitar.RotationMode = false
    -- Note: zoom lock stays active (now locks to 0 to block scrolling out)
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    local camera = workspace.CurrentCamera
    if camera then
        local character = LP.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        LP.CameraMode = Enum.CameraMode.Classic
        camera.CameraType = Enum.CameraType.Custom
        if humanoid then camera.CameraSubject = humanoid end
    end
    -- Only reset LocalTransparencyModifier - do NOT touch Transparency or CanCollide
    local char = LP.Character
    if char then
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = 0
            end
        end
    end
end

local function applyThirdPersonState()
    if _G.thirdPerson then enableThirdPersonView() else disableThirdPersonView() end
end

if LP.Character then applyThirdPersonState() end
-- Start the zoom lock immediately so scrolling is blocked from the start
savitarStartZoomLock()

LP.CharacterAdded:Connect(function(newChar)
    task.wait(0.1)
    if _G.thirdPerson then
        Savitar.LastSafeCFrame = nil
        local hrp = newChar:FindFirstChild("HumanoidRootPart") or newChar:WaitForChild("HumanoidRootPart", 5)
        if hrp then Savitar.LastSafeCFrame = hrp.CFrame end
        applyThirdPersonState()
    end
end)

-- Reference so the key 3 bind can sync the UI toggle
local thirdPersonToggleRef = nil

-- Key 3 toggles third person
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Three then
        local newVal = not _G.thirdPerson
        _G.thirdPerson = newVal
        applyThirdPersonState()
        if thirdPersonToggleRef then
            pcall(function() thirdPersonToggleRef:Set(newVal) end)
        end
        if newVal then
            Rayfield:Notify({Title = "3rd Person", Content = "Active. Hold R to rotate freely.", Duration = 3})
        else
            Rayfield:Notify({Title = "3rd Person", Content = "Disabled.", Duration = 2})
        end
    end
end)

local thirdPersonToggle = LocalPlayerTab:CreateToggle({
    Name = "3rd Person Mode (Savitar) [Key: 3]",
    CurrentValue = false,
    Flag = "third_person_toggle",
    Callback = function(Value)
        _G.thirdPerson = Value
        applyThirdPersonState()
        if Value then
            Rayfield:Notify({Title = "3rd Person", Content = "Active. Hold R to rotate freely.", Duration = 3})
        end
    end
})
thirdPersonToggleRef = thirdPersonToggle

LocalPlayerTab:CreateSection("Troll")
task.spawn(function()
    local ok, err = pcall(function()
        local jerkEnabled = false
        local jerkTrack = nil
        local jerkAnimation = Instance.new("Animation")
        jerkAnimation.AnimationId = "rbxassetid://168268306"
        local jerkGui = nil
        local jerkLabel = nil
        local jerkLoopToken = 0

        local function ensureJerkGui()
            if jerkLabel and jerkLabel.Parent then return true end
            local playerGui = LP:FindFirstChild("PlayerGui")
            if not playerGui then return false end
            jerkGui = playerGui:FindFirstChild("JerkOffGui")
            if not jerkGui then
                jerkGui = Instance.new("ScreenGui")
                jerkGui.Name = "JerkOffGui"
                jerkGui.ResetOnSpawn = false
                jerkGui.Parent = playerGui
            end
            jerkLabel = jerkGui:FindFirstChild("JerkLabel")
            if not jerkLabel then
                jerkLabel = Instance.new("TextLabel")
                jerkLabel.Name = "JerkLabel"
                jerkLabel.Parent = jerkGui
                jerkLabel.Size = UDim2.new(0.1, 0, 0.015, 0)
                jerkLabel.Position = UDim2.new(0.458, 0, 0.477, 0)
                jerkLabel.Text = "Jerk"
                jerkLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                jerkLabel.BackgroundTransparency = 1
                jerkLabel.TextScaled = true
                jerkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                jerkLabel.TextStrokeTransparency = 0
            end
            jerkLabel.Visible = false
            return true
        end

        local function stopJerkTrack()
            if jerkTrack then pcall(function() jerkTrack:Stop() end) end
        end

        local function startJerkTrack()
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local animator = hum:FindFirstChildOfClass("Animator")
            if not animator then
                animator = Instance.new("Animator")
                animator.Parent = hum
            end
            stopJerkTrack()
            jerkTrack = animator:LoadAnimation(jerkAnimation)
            jerkTrack:Play()
        end

        local function startJerkLoop()
            jerkLoopToken = jerkLoopToken + 1
            local token = jerkLoopToken
            task.spawn(function()
                while jerkEnabled and token == jerkLoopToken do
                    if jerkTrack and jerkTrack.IsPlaying then jerkTrack.TimePosition = 0.3 end
                    task.wait(0.1)
                end
            end)
        end

        local function enableJerk()
            if jerkEnabled then return end
            jerkEnabled = true
            if ensureJerkGui() and jerkLabel then jerkLabel.Visible = true end
            pcall(function() Rayfield:Notify({Title = "JerkOff", Content = "JerkOff Enabled", Duration = 2, Image = 7734042071}) end)
            startJerkTrack()
            startJerkLoop()
        end

        local function disableJerk()
            if not jerkEnabled then return end
            jerkEnabled = false
            jerkLoopToken = jerkLoopToken + 1
            if jerkLabel then jerkLabel.Visible = false end
            stopJerkTrack()
            pcall(function() Rayfield:Notify({Title = "JerkOff", Content = "JerkOff Disabled", Duration = 2, Image = 7734000129}) end)
        end

        local function toggleJerk()
            if jerkEnabled then disableJerk() else enableJerk() end
        end

        LP.CharacterAdded:Connect(function()
            if jerkEnabled then task.wait(0.1) startJerkTrack() end
        end)

        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
                toggleJerk()
            end
        end)

        LocalPlayerTab:CreateToggle({
            Name = "JerkOff (Q)",
            CurrentValue = false,
            Flag = "jerkoff_toggle",
            Callback = function(Value)
                if Value then enableJerk() else disableJerk() end
            end,
        })
    end)
    if not ok then warn("[Troll/JerkOff] init failed:", err) end
end)

-- ============================================================
-- Loop Players Tab
-- ============================================================
local loopSpamKickTarget = nil
local loopSpamKickEnabled = false
local lp_spamKickToggle = nil
local loopBlobSpamKickEnabled = false
local lp_blobSpamKickToggle = nil
local loopBlobAntiBlobmanSuspended = false

local lp_selectDropdown = nil
local lp_inLoopDropdown = nil
local playerToAdd = nil
local playerToRemove = nil

local function getLoopPlayerOptions()
    local opts = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local display = p.DisplayName ~= p.Name and (p.DisplayName .. " (" .. p.Name .. ")") or p.Name
            table.insert(opts, display)
        end
    end
    return opts
end

local function extractUsername(option)
    if not option then return nil end
    local inner = option:match("%((.-)%)$")
    return inner or option
end

local function refreshStringList(uiElement, tableToIterate)
    local playerNames = {}
    local si, ss, sk = pairs(tableToIterate)
    while true do
        local item
        sk, item = si(ss, sk)
        if sk == nil then break end
        if typeof(item) == "string" then table.insert(playerNames, item) end
    end
    uiElement:Refresh(playerNames, true)
end

local function getFirstSelectedLoopTarget()
    local si, ss, sk = pairs(playerList)
    while true do
        local name
        sk, name = si(ss, sk)
        if sk == nil then break end
        local target = Players:FindFirstChild(name)
        if target and target ~= LP then return target end
    end
    return nil
end

LoopPlayersTab:CreateSection("Loop Players")

lp_selectDropdown = LoopPlayersTab:CreateDropdown({
    Name = "Select Player",
    Options = getLoopPlayerOptions(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "loop_select_player",
    Callback = function(option)
        local raw = type(option) == "table" and option[1] or option
        playerToAdd = extractUsername(raw)
    end,
})

LoopPlayersTab:CreateButton({
    Name = "Add to Loop",
    Callback = function()
        if not playerToAdd or playerToAdd == "" then
            Rayfield:Notify({Title = "Loop Players", Content = "Select a player first", Duration = 2}) return
        end
        if table.find(playerList, playerToAdd) then
            Rayfield:Notify({Title = "Loop Players", Content = playerToAdd .. " already in loop", Duration = 2}) return
        end
        local p = Players:FindFirstChild(playerToAdd)
        if not p then
            Rayfield:Notify({Title = "Loop Players", Content = "Player not found", Duration = 2}) return
        end
        table.insert(playerList, playerToAdd)
        pcall(function() startPlotWatch(playerToAdd) end)
        pcall(function() watchPlayerForKills(playerToAdd) end)
        loopSpamKickTarget = getFirstSelectedLoopTarget()
        Rayfield:Notify({Title = "Loop Players", Content = "Added: " .. playerToAdd, Duration = 2})
    end,
})

LoopPlayersTab:CreateButton({
    Name = "Remove Selected",
    Callback = function()
        if not playerToAdd or playerToAdd == "" then
            Rayfield:Notify({Title = "Loop Players", Content = "Select a player first", Duration = 2}) return
        end
        local found = false
        for i, name in ipairs(playerList) do
            if name == playerToAdd then
                table.remove(playerList, i)
                pcall(function() stopPlotWatch(playerToAdd) end)
                found = true break
            end
        end
        if found then
            loopSpamKickTarget = getFirstSelectedLoopTarget()
            Rayfield:Notify({Title = "Loop Players", Content = "Removed: " .. playerToAdd, Duration = 2})
        else
            Rayfield:Notify({Title = "Loop Players", Content = playerToAdd .. " is not in the loop", Duration = 2})
        end
    end,
})

LoopPlayersTab:CreateButton({
    Name = "Remove All",
    Callback = function()
        for _, name in ipairs(playerList) do pcall(function() stopPlotWatch(name) end) end
        playerList = {}
        loopSpamKickTarget = nil
        Rayfield:Notify({Title = "Loop Players", Content = "All players removed", Duration = 2})
    end,
})

LoopPlayersTab:CreateButton({
    Name = "View Selected",
    Callback = function()
        if #playerList == 0 then
            Rayfield:Notify({Title = "Selected Players", Content = "No players in loop", Duration = 3})
        else
            Rayfield:Notify({Title = "Selected (" .. #playerList .. ")", Content = table.concat(playerList, ", "), Duration = 6})
        end
    end,
})

LoopPlayersTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        if lp_selectDropdown then lp_selectDropdown:Refresh(getLoopPlayerOptions(), true) end
        Rayfield:Notify({Title = "Loop Players", Content = "Player list refreshed", Duration = 2})
    end,
})

safeZoneAlertCooldown = 0
local function checkAndAlertSafeZone(target)
    if not target then return end
    if tick() - safeZoneAlertCooldown < 3 then return end
    if IsPlayerInsideSafeZone(target) then
        safeZoneAlertCooldown = tick()
        Rayfield:Notify({Title = "!! Safe Zone", Content = target.Name .. " is in their house!", Duration = 4})
    end
end

LoopPlayersTab:CreateSection("Spam Grab Kick")

lp_spamKickToggle = LoopPlayersTab:CreateToggle({
    Name = "Kick (spam grab)",
    CurrentValue = false,
    Flag = "loop_players_spam_grab_kick",
    Callback = function(on)
        loopSpamKickEnabled = on
        if not on then endAntiBlobmanSuspend() return end
        loopSpamKickTarget = getFirstSelectedLoopTarget()
        if not loopSpamKickTarget or not loopSpamKickTarget.Parent then
            Rayfield:Notify({Title = "Spam Grab Kick", Content = "Check at least one valid player in 'Players to Loop Kill' first", Duration = 3})
            loopSpamKickEnabled = false
            if lp_spamKickToggle then lp_spamKickToggle:Set(false) end
            return
        end
        beginAntiBlobmanSuspend()
        task.spawn(function()
            local antiBlobmanSuspendedByThisLoop = true
            local function cleanupAntiBlobmanSuspend()
                if antiBlobmanSuspendedByThisLoop then
                    antiBlobmanSuspendedByThisLoop = false
                    endAntiBlobmanSuspend()
                end
            end
            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local myChar = LP.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then
                loopSpamKickEnabled = false
                if lp_spamKickToggle then lp_spamKickToggle:Set(false) end
                cleanupAntiBlobmanSuspend()
                return
            end
            local savedPos = myRoot.CFrame
            local kickCamPart = Instance.new("Part")
            kickCamPart.Anchored = true
            kickCamPart.CanCollide = false
            kickCamPart.CastShadow = false
            kickCamPart.Transparency = 1
            kickCamPart.Size = Vector3.new(1, 1, 1)
            kickCamPart.CFrame = CFrame.lookAt((savedPos * CFrame.new(0, -1, 10)).Position, (savedPos * CFrame.new(0, 17, 0)).Position)
            kickCamPart.Parent = workspace
            local kickCamOrigSubject = workspace.CurrentCamera.CameraSubject
            workspace.CurrentCamera.CameraSubject = kickCamPart
            local dragging = false
            local grabStartTime = 0
            while loopSpamKickEnabled do
                local target = loopSpamKickTarget
                if not target or not target.Parent then
                    local targetName = target and target.Name or (loopSpamKickTarget and loopSpamKickTarget.Name)
                    if not targetName then break end
                    Rayfield:Notify({Title = "Kick", Content = targetName .. " left -- waiting for rejoin...", Duration = 4})
                    repeat
                        task.wait(1)
                        local rejoined = Players:FindFirstChild(targetName)
                        if rejoined then
                            loopSpamKickTarget = rejoined
                            dragging = false
                            grabStartTime = 0
                            Rayfield:Notify({Title = "Kick", Content = targetName .. " rejoined -- resuming kick!", Duration = 3})
                        end
                    until Players:FindFirstChild(targetName) or not loopSpamKickEnabled
                    if not loopSpamKickEnabled then break end
                    RunService.Heartbeat:Wait()
                    continue
                end
                checkAndAlertSafeZone(target)
                myChar = LP.Character
                myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then RunService.Heartbeat:Wait() continue end
                local tChar = target.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if not tRoot or not tHum or tHum.Health <= 0 then
                    dragging = false
                    grabStartTime = 0
                    if target and target.Parent then
                        local t0 = tick()
                        while tick() - t0 < 5 and loopSpamKickEnabled do
                            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then break end
                            task.wait(0.1)
                        end
                        task.wait(0.1)
                    end
                    RunService.Heartbeat:Wait()
                    continue
                end
                if tRoot and tHum and tHum.Health > 0 then
                    tRoot.AssemblyLinearVelocity = Vector3.zero
                    tRoot.AssemblyAngularVelocity = Vector3.zero
                    for name, conn in pairs(loopKillCharConn or {}) do pcall(function() conn:Disconnect() end) end
        -- ADD HERE:
        setWaterWalk(false)
        disableAntiVoid()
        pcall(function() Rayfield:Destroy() end)
                    tRoot.Velocity = Vector3.zero
                    if not dragging then
                        myRoot.CFrame = tRoot.CFrame
                        myRoot.Velocity = Vector3.zero
                        pcall(function()
                            tHum.PlatformStand = true
                            tHum.Sit = true
                            GE.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        end)
                        if grabStartTime == 0 then grabStartTime = tick() end
                        if tick() - grabStartTime > 0.35 then dragging = true grabStartTime = 0 end
                    else
                        myRoot.CFrame = savedPos
                        myRoot.Velocity = Vector3.zero
                        local lockPos = savedPos * CFrame.new(0, 17, 0)
                        tRoot.CFrame = lockPos
                        tRoot.AssemblyLinearVelocity = Vector3.zero
                        tRoot.AssemblyAngularVelocity = Vector3.zero
                        tRoot.Velocity = Vector3.zero
                        tRoot.RotVelocity = Vector3.zero
                        pcall(function()
                            tHum.PlatformStand = true
                            tHum.Sit = false
                            GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                            GE.DestroyGrabLine:FireServer(tRoot)
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        end)
                    end
                else
                    dragging = false
                    grabStartTime = 0
                end
                RunService.Heartbeat:Wait()
            end
            local target = loopSpamKickTarget
            local tChar = target and target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot then pcall(function() GE.DestroyGrabLine:FireServer(tRoot) end) end
            kickCamPart:Destroy()
            if workspace.CurrentCamera then
                workspace.CurrentCamera.CameraSubject = (LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")) or kickCamOrigSubject
            end
            if myRoot then myRoot.CFrame = savedPos myRoot.Velocity = Vector3.zero end
            loopSpamKickEnabled = false
            if lp_spamKickToggle then lp_spamKickToggle:Set(false) end
            cleanupAntiBlobmanSuspend()
        end)
    end,
})

lp_blobSpamKickToggle = LoopPlayersTab:CreateToggle({
    Name = "Blob Kick (grab + blob)",
    CurrentValue = false,
    Flag = "loop_players_blob_spam_grab_kick",
    Callback = function(on)
        loopBlobSpamKickEnabled = on
        if not on then
            loopBlobSpamKickEnabled = false
            if loopBlobAntiBlobmanSuspended then
                loopBlobAntiBlobmanSuspended = false
                endAntiBlobmanSuspend()
            end
            return
        end
        local target = getFirstSelectedLoopTarget()
        if not target then
            loopBlobSpamKickEnabled = false
            Rayfield:Notify({Title = "Blob Kick", Content = "Select a valid target first", Duration = 3})
            if lp_blobSpamKickToggle then lp_blobSpamKickToggle:Set(false) end
            return
        end
        local function loopIsSeatedInBlobman()
            local character = LP.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not character or not humanoid or not humanoid.Sit or humanoid.SeatPart == nil then return false end
            return tostring(humanoid.SeatPart.Parent) == "CreatureBlobman"
        end
        local function loopGetOwnedBlobman()
            local folder = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
            return folder and folder:FindFirstChild("CreatureBlobman") or nil
        end
        local function loopDeleteOwnedBlobman()
            local bman = loopGetOwnedBlobman()
            if bman then pcall(function() DeleteToyRE:FireServer(bman) end) end
        end
        local function loopEnsureSeatedBlobman()
            local character = LP.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if not (character and humanoid and hrp) then return nil end
            if loopIsSeatedInBlobman() then return humanoid.SeatPart and humanoid.SeatPart.Parent or nil end
            loopDeleteOwnedBlobman()
            task.wait(0.05)
            local spawnCF = hrp.CFrame
            pcall(function()
                SpawnToyRF:InvokeServer("CreatureBlobman", spawnCF, Vector3.new(0, 97.69000244140625, 0))
                BuyToy:InvokeServer("CreatureBlobman")
            end)
            local bman = nil
            for _ = 1, 25 do
                bman = loopGetOwnedBlobman()
                if bman and bman:FindFirstChild("VehicleSeat") then break end
                task.wait(0.1)
            end
            if not bman then return nil end
            local seat = bman:FindFirstChild("VehicleSeat")
            if not seat then return nil end
            for _ = 1, 20 do
                hrp.CFrame = seat.CFrame + Vector3.new(0, 2.5, 0)
                task.wait(0.05)
                pcall(function() seat:Sit(humanoid) end)
                if loopIsSeatedInBlobman() then return humanoid.SeatPart and humanoid.SeatPart.Parent or bman end
                task.wait(0.1)
            end
            return nil
        end
        local blob = loopEnsureSeatedBlobman()
        if not blob then
            loopBlobSpamKickEnabled = false
            Rayfield:Notify({Title = "Blob Kick", Content = "Failed to spawn/seat on Blobman", Duration = 3})
            if lp_blobSpamKickToggle then lp_blobSpamKickToggle:Set(false) end
            return
        end
        if not loopBlobAntiBlobmanSuspended then
            beginAntiBlobmanSuspend()
            loopBlobAntiBlobmanSuspended = true
        end
        task.spawn(function()
            local function cleanupAntiBlobmanSuspend()
                if loopBlobAntiBlobmanSuspended then
                    loopBlobAntiBlobmanSuspended = false
                    endAntiBlobmanSuspend()
                end
            end
            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
            local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
            local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
            local R_Det = blob:FindFirstChild("RightDetector")
            local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
            local SavedPos = blobRoot and blobRoot.CFrame
            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot and blobRoot and SavedPos then
                local bringStart = tick()
                while tick() - bringStart < 0.35 do
                    if not loopBlobSpamKickEnabled then break end
                    blobRoot.CFrame = tRoot.CFrame
                    blobRoot.Velocity = Vector3.zero
                    pcall(function()
                        if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                    end)
                    RunService.Heartbeat:Wait()
                end
                blobRoot.CFrame = SavedPos
                blobRoot.Velocity = Vector3.zero
                task.wait(0.05)
            end
            local packetTimer = 0
            while loopBlobSpamKickEnabled do
                if not target or not target.Parent then
                    local newTarget = getFirstSelectedLoopTarget()
                    if newTarget then
                        target = newTarget
                    else
                        local targetName = target and target.Name
                        if not targetName then break end
                        Rayfield:Notify({Title = "Blob Kick", Content = targetName .. " left -- waiting for rejoin...", Duration = 4})
                        repeat
                            task.wait(1)
                            local rejoined = Players:FindFirstChild(targetName)
                            if rejoined then
                                target = rejoined
                                Rayfield:Notify({Title = "Blob Kick", Content = targetName .. " rejoined -- resuming kick!", Duration = 3})
                            end
                        until Players:FindFirstChild(targetName) or not loopBlobSpamKickEnabled
                        if not loopBlobSpamKickEnabled then break end
                        RunService.Heartbeat:Wait()
                        continue
                    end
                end
                tChar = target.Character
                tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")
                if not tRoot or not tHum or tHum.Health <= 0 then
                    if target and target.Parent then
                        local t0 = tick()
                        while tick() - t0 < 5 and loopBlobSpamKickEnabled do
                            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then break end
                            task.wait(0.1)
                        end
                        task.wait(0.1)
                    end
                    RunService.Heartbeat:Wait()
                    continue
                end
                if tRoot and tHum and tHum.Health > 0 and blobRoot and SavedPos then
                    blobRoot.CFrame = SavedPos
                    blobRoot.Velocity = Vector3.zero
                    local lockPos = SavedPos * CFrame.new(0, 23, 0)
                    tRoot.CFrame = lockPos
                    tRoot.Velocity = Vector3.zero
                    tRoot.RotVelocity = Vector3.zero
                    if tick() - packetTimer > 0.05 then
                        packetTimer = tick()
                        pcall(function()
                            tHum.PlatformStand = true
                            tHum.Sit = true
                            GE.SetNetworkOwner:FireServer(tRoot, lockPos)
                            if R_Det then
                                local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
                                if weld then CD:FireServer(weld) end
                            end
                            GE.DestroyGrabLine:FireServer(tRoot)
                            if R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        end)
                    end
                else
                    if blobRoot and SavedPos then blobRoot.CFrame = SavedPos blobRoot.Velocity = Vector3.zero end
                end
                if not loopBlobSpamKickEnabled then break end
                RunService.Heartbeat:Wait()
            end
            loopBlobSpamKickEnabled = false
            if lp_blobSpamKickToggle then lp_blobSpamKickToggle:Set(false) end
            if blobRoot and SavedPos then blobRoot.CFrame = SavedPos blobRoot.Velocity = Vector3.zero end
            cleanupAntiBlobmanSuspend()
        end)
    end,
})

LoopPlayersTab:CreateSection("Loop Kill Functions")

local blitzLKCFrame = nil
local lkCameraAnchorPart = nil
local lkCameraOriginalSubject = nil
local lkHiddenCharacterParts = nil

local function beginLoopKillCameraAnchor()
    if lkCameraAnchorPart and lkCameraAnchorPart.Parent then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    lkCameraAnchorPart = Instance.new("Part")
    lkCameraAnchorPart.Anchored = true
    lkCameraAnchorPart.CanCollide = false
    lkCameraAnchorPart.CastShadow = false
    lkCameraAnchorPart.Transparency = 1
    lkCameraAnchorPart.Size = Vector3.new(1, 1, 1)
    lkCameraAnchorPart.CFrame = hrp and hrp.CFrame or CFrame.new(0, 0, 0)
    lkCameraAnchorPart.Parent = workspace
    lkCameraOriginalSubject = workspace.CurrentCamera.CameraSubject
    workspace.CurrentCamera.CameraSubject = lkCameraAnchorPart
    lkHiddenCharacterParts = {}
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                lkHiddenCharacterParts[part] = part.LocalTransparencyModifier
                part.LocalTransparencyModifier = 1
            end
        end
    end
end

local function endLoopKillCameraAnchor()
    if lkCameraAnchorPart and lkCameraAnchorPart.Parent then lkCameraAnchorPart:Destroy() end
    lkCameraAnchorPart = nil
    local fallbackSubject = (LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")) or lkCameraOriginalSubject
    if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = fallbackSubject end
    if lkHiddenCharacterParts then
        for part, originalTransparency in pairs(lkHiddenCharacterParts) do
            if part and part.Parent then part.LocalTransparencyModifier = originalTransparency end
        end
    end
    lkHiddenCharacterParts = nil
    lkCameraOriginalSubject = nil
end

loopKillCounts = {}
loopKillCharConn = {}

local function watchPlayerForKills(playerName)
    if loopKillCharConn[playerName] then
        pcall(function() loopKillCharConn[playerName]:Disconnect() end)
        loopKillCharConn[playerName] = nil
    end
    local p = Players:FindFirstChild(playerName)
    if not p then return end
    loopKillCharConn[playerName] = p.CharacterAdded:Connect(function()
        if not _G.LoopKill then return end
        loopKillCounts[playerName] = (loopKillCounts[playerName] or 0) + 1
        Rayfield:Notify({Title = "Kill", Content = playerName .. " killed! (" .. loopKillCounts[playerName] .. ")", Duration = 3})
    end)
end

LoopPlayersTab:CreateToggle({
    Name = "Loop Kill",
    CurrentValue = false,
    Flag = "lk_toggle",
    Callback = function(loopKill)
        _G.LoopKill = loopKill
        if loopKill then
            local si, ss, sk = pairs(playerList)
            while true do
                local name
                sk, name = si(ss, sk)
                if sk == nil then break end
                watchPlayerForKills(name)
            end
        else
            endLoopKillCameraAnchor()
            recoverFromLoopKillBugState()
            return
        end
        while _G.LoopKill do
            blitzLKCFrame = GetPlayerCFrame()
            local lkI, lkS, lkK = pairs(playerList)
            while true do
                local playerName5
                lkK, playerName5 = lkI(lkS, lkK)
                if lkK == nil then break end
                local playerInstance3 = Players:FindFirstChild(playerName5)
                if playerInstance3 and IsPlayerInsideSafeZone(playerInstance3) then
                    Rayfield:Notify({Title = "!! Safe Zone", Content = playerName5 .. " is in their plot!", Duration = 4})
                    continue
                end
                if CheckPlayerForLoopKill(playerInstance3) and ChangeActivityPriority(2) then
                    local humanoidRootPart = playerInstance3.Character:FindFirstChild("HumanoidRootPart")
                    local headPart = playerInstance3.Character:FindFirstChild("Head")
                    local characterHumanoid = playerInstance3.Character:FindFirstChild("Humanoid")
                    if playerInstance3 and (humanoidRootPart and headPart) then
                        beginLoopKillCameraAnchor()
                        for _ = 0, 50 do
                            dialogueFunction2()
                            SNOWship(humanoidRootPart)
                            if not CheckPlayerForLoopKill(playerInstance3) or (not _G.LoopKill or (CheckNetworkOwnerShipOnPlayer(playerInstance3) or humanoidRootPart.AssemblyLinearVelocity.Magnitude > 500)) then
                                destroyGrabLineEvent:FireServer(humanoidRootPart)
                                CreateSkyVelocity(humanoidRootPart)
                                break
                            end
                            task.wait()
                            if humanoidRootPart.Position.Y <= -12 then
                                TeleportPlayer(CFrame.new(humanoidRootPart.Position + Vector3.new(0, 5, -15)), 2)
                            else
                                TeleportPlayer(CFrame.new(humanoidRootPart.Position + Vector3.new(0, -10, -10)), 2)
                            end
                            characterHumanoid.BreakJointsOnDeath = false
                            characterHumanoid:ChangeState(Enum.HumanoidStateType.Dead)
                            characterHumanoid.Jump = true
                            characterHumanoid.Sit = false
                        end
                        endLoopKillCameraAnchor()
                    end
                    ChangeActivityPriority(0)
                end
            end
            TeleportPlayer(blitzLKCFrame)
            task.wait(0.2)
        end
        endLoopKillCameraAnchor()
        dialogueFunction1()
        TeleportPlayer(blitzLKCFrame)
        recoverFromLoopKillBugState()
        print("End LoopKill")
    end,
})

function acquireFirePartOwnership(targetPlayer)
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end
    local targetChar = targetPlayer.Character
    if not targetChar then return false end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local firePart = targetHRP and targetHRP:FindFirstChild("FirePlayerPart")
    if not firePart then return false end
    myHRP.CFrame = CFrame.new(firePart.Position + Vector3.new(0, 0, 0))
    for _ = 1, 15 do
        setNetworkOwnerEvent:FireServer(firePart, CFrame.lookAt(myHRP.Position, firePart.Position))
        task.wait()
    end
    return true
end

function checkFirePartOwned(targetPlayer)
    local grabParts = workspace:FindFirstChild("GrabParts")
    if grabParts then
        local owner = grabParts:FindFirstChild("Owner")
        if owner and owner.Value == LP.Name then return true end
    end
    return false
end

LoopPlayersTab:CreateToggle({
    Name = "Loop Kill (Perm Ownership)",
    CurrentValue = false,
    Flag = "lk_perm_toggle",
    Callback = function(loopKillPerm)
        _G.LoopKillPerm = loopKillPerm
        if loopKillPerm then
            for _, name in ipairs(playerList) do watchPlayerForKills(name) end
        else
            endLoopKillCameraAnchor()
            recoverFromLoopKillBugState()
            return
        end
        local lkPermCFrame = GetPlayerCFrame()
        local GE = ReplicatedStorage:WaitForChild("GrabEvents")
        while _G.LoopKillPerm do
            lkPermCFrame = GetPlayerCFrame()
            local si, ss, sk = pairs(playerList)
            while true do
                local playerName6
                sk, playerName6 = si(ss, sk)
                if sk == nil then break end
                local playerInstance = Players:FindFirstChild(playerName6)
                if playerInstance and IsPlayerInsideSafeZone(playerInstance) then
                    Rayfield:Notify({Title = "!! Safe Zone", Content = playerName6 .. " is in their plot!", Duration = 4})
                    continue
                end
                if CheckPlayerForLoopKill(playerInstance) and ChangeActivityPriority(2) then
                    local targetChar = playerInstance.Character
                    local hrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                    local firePart = hrp and hrp:FindFirstChild("FirePlayerPart")
                    local head = targetChar and targetChar:FindFirstChild("Head")
                    local hum = targetChar and targetChar:FindFirstChild("Humanoid")
                    if hrp and firePart and head and hum then
                        beginLoopKillCameraAnchor()
                        local weldHRP = hrp:FindFirstChild("WeldHRP")
                        if weldHRP then pcall(function() weldHRP.Enabled = false end) end
                        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if myHRP then
                            myHRP.CFrame = CFrame.new(firePart.Position + Vector3.new(0, 2, 0))
                            for _ = 1, 20 do
                                setNetworkOwnerEvent:FireServer(firePart, CFrame.lookAt(myHRP.Position, firePart.Position))
                                setNetworkOwnerEvent:FireServer(hrp, CFrame.lookAt(myHRP.Position, hrp.Position))
                                task.wait()
                            end
                        end
                        for _ = 0, 50 do
                            if not CheckPlayerForLoopKill(playerInstance) or not _G.LoopKillPerm then
                                destroyGrabLineEvent:FireServer(hrp)
                                CreateSkyVelocity(hrp)
                                break
                            end
                            if hrp.AssemblyLinearVelocity.Magnitude > 500 then
                                CreateSkyVelocity(hrp)
                                break
                            end
                            myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if not myHRP then task.wait() continue end
                            pcall(function()
                                setNetworkOwnerEvent:FireServer(firePart, CFrame.lookAt(myHRP.Position, firePart.Position))
                                GE.CreateGrabLine:FireServer(firePart, Vector3.zero, firePart.Position, false)
                            end)
                            dialogueFunction2()
                            task.wait()
                            if hrp.Position.Y <= -12 then
                                TeleportPlayer(CFrame.new(hrp.Position + Vector3.new(0, 5, -15)), 2)
                            else
                                TeleportPlayer(CFrame.new(hrp.Position + Vector3.new(0, -10, -10)), 2)
                            end
                            hum.BreakJointsOnDeath = false
                            hum:ChangeState(Enum.HumanoidStateType.Dead)
                            hum.Jump = true
                            hum.Sit = false
                        end
                        endLoopKillCameraAnchor()
                    end
                    ChangeActivityPriority(0)
                end
            end
            TeleportPlayer(lkPermCFrame)
            task.wait(0.2)
        end
        endLoopKillCameraAnchor()
        dialogueFunction1()
        TeleportPlayer(lkPermCFrame)
        recoverFromLoopKillBugState()
    end,
})

LoopPlayersTab:CreateButton({
    Name = "Reset Kill Count",
    Callback = function()
        loopKillCounts = {}
        for name, conn in pairs(loopKillCharConn) do pcall(function() conn:Disconnect() end) end
        loopKillCharConn = {}
        Rayfield:Notify({Title = "Kill Count", Content = "Kill count reset", Duration = 2})
    end,
})

Players.PlayerAdded:Connect(function()
    task.wait(1)
    if lp_selectDropdown then lp_selectDropdown:Refresh(getLoopPlayerOptions(), true) end
end)
Players.PlayerRemoving:Connect(function(p)
    if lp_selectDropdown then lp_selectDropdown:Refresh(getLoopPlayerOptions(), true) end
    if loopSpamKickTarget == p then loopSpamKickTarget = nil end
    local wasInLoop = false
    local si, ss, sk = pairs(playerList)
    while true do
        local name
        sk, name = si(ss, sk)
        if sk == nil then break end
        if name == p.Name then playerList[sk] = nil wasInLoop = true end
    end
    if wasInLoop then
        if loopKillCharConn[p.Name] then
            pcall(function() loopKillCharConn[p.Name]:Disconnect() end)
            loopKillCharConn[p.Name] = nil
        end
        stopPlotWatch(p.Name)
        Rayfield:Notify({Title = "Player Left", Content = p.Name .. " left and was removed from the loop", Duration = 4})
    end
    if lp_inLoopDropdown then refreshStringList(lp_inLoopDropdown, playerList) end
end)

plotWatchConns = {}

local function stopPlotWatch(playerName)
    if plotWatchConns[playerName] then
        pcall(function() plotWatchConns[playerName]:Disconnect() end)
        plotWatchConns[playerName] = nil
    end
end

local function startPlotWatch(playerName)
    stopPlotWatch(playerName)
    local p = Players:FindFirstChild(playerName)
    if not p then return end
    task.spawn(function()
        local inPlotVal = p:FindFirstChild("InPlot") or p:WaitForChild("InPlot", 10)
        if not inPlotVal then return end
        if inPlotVal.Value then
            Rayfield:Notify({Title = "!! Safe Zone", Content = playerName .. " is already in their plot!", Duration = 5})
        end
        plotWatchConns[playerName] = inPlotVal.Changed:Connect(function(val)
            if val then
                Rayfield:Notify({Title = "!! Safe Zone", Content = playerName .. " entered their plot!", Duration = 5})
            else
                Rayfield:Notify({Title = "OK Left Plot", Content = playerName .. " left their plot -- go!", Duration = 5})
            end
        end)
    end)
end

-- Blobman Loopkill (GucciBypass)
do
_G.BlobGucciLoopKill = false
local _blobGucciRef = nil

local function bgk_getSeatedParent()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Sit and hum.SeatPart then
        local p = hum.SeatPart.Parent
        if p and p.Name == "CreatureBlobman" then return p end
    end
    return nil
end

local function bgk_forceSeat(bman)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local seat = bman and bman:FindFirstChild("VehicleSeat")
    if not (hum and hrp and seat) then return nil end
    for _ = 1, 20 do
        hrp.CFrame = CFrame.new(seat.CFrame.Position + Vector3.new(0, 2.5, 0))
        task.wait(0.05)
        pcall(function() seat:Sit(hum) end)
        if bgk_getSeatedParent() then return hum.SeatPart and hum.SeatPart.Parent or bman end
        task.wait(0.1)
    end
    return nil
end

local function bgk_spawnAndSit()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return nil end
    local folder = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
    if folder then
        for _, toy in ipairs(folder:GetChildren()) do
            if toy.Name == "CreatureBlobman" then pcall(function() DeleteToyRE:FireServer(toy) end) end
        end
    end
    task.wait(0.2)
    SpawnToyRF:InvokeServer("CreatureBlobman", hrp.CFrame * CFrame.new(0, 0, 3), Vector3.new(0, 97.69, 0))
    BuyToy:InvokeServer("CreatureBlobman")
    local bman = nil
    for _ = 1, 30 do
        folder = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
        bman = folder and folder:FindFirstChild("CreatureBlobman")
        if bman and bman:FindFirstChild("VehicleSeat") then break end
        task.wait(0.1)
    end
    if not bman then return nil end
    local seat = bman:FindFirstChild("VehicleSeat")
    if not seat then return nil end
    for _ = 1, 20 do
        hrp.CFrame = CFrame.new(seat.CFrame.Position + Vector3.new(0, 2.5, 0))
        task.wait(0.05)
        pcall(function() seat:Sit(hum) end)
        local sp = bgk_getSeatedParent()
        if sp then return sp end
        task.wait(0.1)
    end
    return nil
end

_blobGucciRef = LoopPlayersTab:CreateToggle({
    Name = "Blobman Loopkill (GucciBypass)",
    CurrentValue = false,
    Flag = "blob_gucci_loopkill_toggle",
    Callback = function(enabled)
        _G.BlobGucciLoopKill = enabled
        if not enabled then
            endLoopKillCameraAnchor()
            recoverFromLoopKillBugState()
            Rayfield:Notify({Title = "Blobman GucciBypass", Content = "Stopped.", Duration = 3})
            return
        end
        local hasTargets = false
        for _ in pairs(playerList) do hasTargets = true break end
        if not hasTargets then
            _G.BlobGucciLoopKill = false
            if _blobGucciRef then _blobGucciRef:Set(false) end
            Rayfield:Notify({Title = "Blobman GucciBypass", Content = "Add players to Loop list first!", Duration = 4})
            return
        end
        for _, n in ipairs(playerList) do watchPlayerForKills(n) end
        Rayfield:Notify({Title = "Blobman GucciBypass", Content = "Starting...", Duration = 3})
        task.spawn(function()
            local savedCF = GetPlayerCFrame()
            beginLoopKillCameraAnchor()
            local seatParent = nil
            seatParent = bgk_spawnAndSit()
            if not seatParent then
                Rayfield:Notify({Title = "Blobman GucciBypass", Content = "Seat failed on start.", Duration = 3})
                _G.BlobGucciLoopKill = false
                if _blobGucciRef then pcall(function() _blobGucciRef:Set(false) end) end
                return
            end
            while _G.BlobGucciLoopKill do
                local blobRoot = seatParent:FindFirstChild("HumanoidRootPart") or seatParent.PrimaryPart
                local scriptObj = seatParent:FindFirstChild("BlobmanSeatAndOwnerScript")
                local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
                local L_Det = seatParent:FindFirstChild("LeftDetector")
                local L_Weld = L_Det and (L_Det:FindFirstChild("LeftWeld") or L_Det:FindFirstChildWhichIsA("Weld"))
                if not (blobRoot and CG and L_Det and L_Weld) then task.wait(0.05) continue end
                for _, pName in ipairs(playerList) do
                    if not _G.BlobGucciLoopKill then break end
                    local tPlr = Players:FindFirstChild(pName)
                    if not tPlr then continue end
                    if IsPlayerInsideSafeZone(tPlr) then continue end
                    if not CheckPlayerForLoopKill(tPlr) then continue end
                    local tChar = tPlr.Character
                    local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
                    if not (tHRP and tHum and tHum.Health > 0) then continue end
                    local approachCF = CFrame.lookAt(tHRP.Position + Vector3.new(0, 4, -6), tHRP.Position)
                    local function stabilizeBlobmanTeleportLocal(targetCFrame, settleTime)
                        local character = LP.Character
                        local hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if not (hrp and targetCFrame) then return false end
                        local settle = settleTime or 0.03
                        local targetPos = targetCFrame.Position
                        local targetLook = targetCFrame.LookVector
                        targetPos = Vector3.new(targetPos.X, math.clamp(targetPos.Y, 10, 1500), targetPos.Z)
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        local seatPar = humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent
                        local bR = seatPar and (seatPar:FindFirstChild("HumanoidRootPart") or seatPar.PrimaryPart)
                        for _ = 1, 4 do
                            local stableCF = CFrame.lookAt(targetPos, targetPos + targetLook)
                            hrp.CFrame = stableCF
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                            hrp.Velocity = Vector3.zero
                            hrp.RotVelocity = Vector3.zero
                            if bR then
                                bR.CFrame = stableCF
                                bR.AssemblyLinearVelocity = Vector3.zero
                                bR.AssemblyAngularVelocity = Vector3.zero
                                bR.Velocity = Vector3.zero
                                bR.RotVelocity = Vector3.zero
                            end
                            task.wait(settle)
                        end
                        return true
                    end
                    stabilizeBlobmanTeleportLocal(approachCF, 0.02)
                    for _ = 1, 10 do SNOWshipForce(tHRP) task.wait() end
                    for _ = 1, 8 do pcall(function() CG:FireServer(L_Det, tHRP, L_Weld) end) task.wait(0.02) end
                    local killConfirmed = false
                    for _ = 0, 60 do
                        if not _G.BlobGucciLoopKill or not CheckPlayerForLoopKill(tPlr) then break end
                        SNOWshipForce(tHRP)
                        pcall(function() CG:FireServer(L_Det, tHRP, L_Weld) end)
                        if CheckNetworkOwnerShipOnPlayer(tPlr) then
                            tHRP.CFrame = CFrame.new(tHRP.Position.X, -5000, tHRP.Position.Z)
                            tHRP.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.1)
                            destroyGrabLineEvent:FireServer(tHRP)
                            killConfirmed = true
                            break
                        end
                        if tHRP.AssemblyLinearVelocity.Magnitude > 500 then
                            destroyGrabLineEvent:FireServer(tHRP)
                            break
                        end
                        task.wait()
                    end
                    destroyGrabLineEvent:FireServer(tHRP)
                    if killConfirmed then
                        local respawnTimeout = 0
                        repeat
                            task.wait(0.2)
                            respawnTimeout = respawnTimeout + 0.2
                            tChar = tPlr.Character
                        until (tChar and tChar:FindFirstChild("HumanoidRootPart") and tChar.HumanoidRootPart.Position.Y > -100) or respawnTimeout > 8 or not _G.BlobGucciLoopKill
                    end
                    if savedCF and blobRoot then
                        blobRoot.CFrame = savedCF
                        blobRoot.AssemblyLinearVelocity = Vector3.zero
                    end
                    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP and savedCF then
                        myHRP.CFrame = CFrame.new(savedCF.Position + Vector3.new(0, 2.5, 0))
                        myHRP.AssemblyLinearVelocity = Vector3.zero
                    end
                    task.wait(0.1)
                    if not bgk_getSeatedParent() then
                        seatParent = bgk_spawnAndSit()
                        if not seatParent then break end
                    end
                    task.wait(0.05)
                end
                task.wait(0.05)
            end
            endLoopKillCameraAnchor()
            recoverFromLoopKillBugState()
            dialogueFunction1()
            if savedCF then TeleportPlayer(savedCF) end
            _G.BlobGucciLoopKill = false
            if _blobGucciRef then pcall(function() _blobGucciRef:Set(false) end) end
        end)
    end,
})
end

-- ============================================================
-- ESP Tab
-- ============================================================
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

for _, p in pairs(game.Players:GetPlayers()) do ApplyESP(p) end
game.Players.PlayerAdded:Connect(ApplyESP)

ESPTab:CreateToggle({
    Name = "Activate ESP",
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
        for _, p in pairs(game.Players:GetPlayers()) do ApplyESP(p) end
        Rayfield:Notify({Title = "ESP System", Content = "Force refresh completed", Duration = 2})
    end
})

-- ============================================================
-- Blobman / Teleport Tab
-- ============================================================
local SelectedTargetPlayer = nil
local BlobmanLoopActive = false
local blobalter = 1
local blobAutoKickToggle = nil

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
            if seat.Occupant and seat.Occupant.Parent == LP.Character then return v end
        end
    end
    return nil
end

local function isPlayerSeatedInBlobman()
    local localCharacter = LP.Character
    local humanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
    if not localCharacter or not humanoid or not humanoid.Sit or humanoid.SeatPart == nil then return false end
    return tostring(humanoid.SeatPart.Parent) == "CreatureBlobman"
end

local function blobmanGrabAll()
    if not isPlayerSeatedInBlobman() then return false end
    local localHumanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    local seatParent = localHumanoid and localHumanoid.SeatPart and localHumanoid.SeatPart.Parent
    if not seatParent then return false end
    local leftDetector = seatParent:FindFirstChild("LeftDetector")
    local leftWeld = leftDetector and leftDetector:FindFirstChild("LeftWeld")
    local blobScript = seatParent:FindFirstChild("BlobmanSeatAndOwnerScript")
    local creatureGrabRemote = blobScript and blobScript:FindFirstChild("CreatureGrab")
    if not (leftDetector and leftWeld and creatureGrabRemote) then return false end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            creatureGrabRemote:FireServer(leftDetector, player.Character.HumanoidRootPart, leftWeld)
            task.wait()
        end
    end
    return true
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
        if detector then remote:FireServer(detector, hrp, detector:FindFirstChild(weldName)) end
        blobalter = (blobalter == 1) and 2 or 1
    end)
end

BlobmanTab:CreateSection("Control of the target")

local TargetDropdown = BlobmanTab:CreateDropdown({
    Name = "Select a target player",
    Options = getPlayersForDropdown(),
    CurrentOption = nil,
    MultipleOptions = false,
    Flag = "blobman_target_dropdown",
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
    Callback = function() TargetDropdown:Refresh(getPlayersForDropdown(), true) end
})

BlobmanTab:CreateSection("Combat Actions")

BlobmanTab:CreateButton({
    Name = "Teleport behind the target",
    Callback = function()
        if SelectedTargetPlayer and SelectedTargetPlayer.Character and SelectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then myHRP.CFrame = SelectedTargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
        else
            Rayfield:Notify({Title = "Error", Content = "Select a player", Duration = 2})
        end
    end
})

BlobmanTab:CreateSection("Safe Plot Teleport")

local PLOT_SPAWNS = {
    ["Plot 1  (Green House)"]   = Vector3.new(-576.08,  22,   79.49),
    ["Plot 2  (Red House)"] = Vector3.new(-511.92,  19, -163.95),
    ["Plot 3  (Purple House)"]   = Vector3.new( 311.94,  19,  496.80),
    ["Plot 4  (Blue House)"]  = Vector3.new( 528.87, 117, -374.65),
    ["Plot 5  (Asian House)"]   = Vector3.new( 587.28, 159,  -98.30),
}

local PLOT_NAMES = {}
for k in pairs(PLOT_SPAWNS) do table.insert(PLOT_NAMES, k) end
table.sort(PLOT_NAMES)

local selectedRespawnPlot = nil
local respawnPlotConn = nil

BlobmanTab:CreateDropdown({
    Name = "Select Plot",
    Options = PLOT_NAMES,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "respawn_plot_dropdown",
    Callback = function(option)
        local key = type(option) == "table" and option[1] or option
        selectedRespawnPlot = PLOT_SPAWNS[key]
        if selectedRespawnPlot then
            Rayfield:Notify({Title = "Respawn Plot", Content = "Plot set: " .. key, Duration = 2})
        end
    end,
})

BlobmanTab:CreateToggle({
    Name = "Auto-Teleport to Plot on Respawn",
    CurrentValue = false,
    Flag = "respawn_plot_toggle",
    Callback = function(Value)
        if respawnPlotConn then
            respawnPlotConn:Disconnect()
            respawnPlotConn = nil
        end
        if not Value then return end
        if not selectedRespawnPlot then
            Rayfield:Notify({Title = "Respawn Plot", Content = "Select a plot first!", Duration = 3})
            return
        end
        respawnPlotConn = LP.CharacterAdded:Connect(function(newChar)
            if not selectedRespawnPlot then return end
            local hrp = newChar:WaitForChild("HumanoidRootPart", 6)
            if not hrp then return end
            task.wait(0.4)
            hrp.CFrame = CFrame.new(selectedRespawnPlot)
            Rayfield:Notify({Title = "Respawn Plot", Content = "Teleported to safe plot!", Duration = 2})
        end)
        Rayfield:Notify({Title = "Respawn Plot", Content = "Active -- teleports on next respawn", Duration = 3})
    end
})

BlobmanTab:CreateButton({
    Name = "Teleport to Selected Plot Now",
    Callback = function()
        if not selectedRespawnPlot then
            Rayfield:Notify({Title = "Respawn Plot", Content = "Select a plot first!", Duration = 2})
            return
        end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Rayfield:Notify({Title = "Respawn Plot", Content = "No character found", Duration = 2})
            return
        end
        hrp.CFrame = CFrame.new(selectedRespawnPlot)
        Rayfield:Notify({Title = "Respawn Plot", Content = "Teleported!", Duration = 2})
    end
})

local function getOwnedBlobman()
    spawnedInToysFolder = spawnedInToysFolder or workspace:FindFirstChild(spawnedInToysFolderName)
    if not spawnedInToysFolder then return nil end
    return spawnedInToysFolder:FindFirstChild("CreatureBlobman")
end

local function spawnOwnedBlobman()
    local char = LP.Character
    local head = char and char:FindFirstChild("Head")
    local spawnCF = head and head.CFrame or CFrame.new(0, 50, 0)
    SpawnToyRF:InvokeServer("CreatureBlobman", spawnCF, Vector3.new(0, 97.69000244140625, 0))
    BuyToy:InvokeServer("CreatureBlobman")
    local bman = nil
    for _ = 1, 25 do
        bman = getOwnedBlobman()
        if bman and bman:FindFirstChild("VehicleSeat") then return bman end
        task.wait(0.1)
    end
    return nil
end

local function deleteOwnedBlobman()
    local bman = getOwnedBlobman()
    if bman then pcall(function() DeleteToyRE:FireServer(bman) end) end
end

local function ensureSeatedBlobman()
    if autoGucciActive then return nil end
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not (character and humanoid and hrp) then return nil end
    if isPlayerSeatedInBlobman() then return humanoid.SeatPart and humanoid.SeatPart.Parent or nil end
    deleteOwnedBlobman()
    task.wait(0.05)
    local bman = spawnOwnedBlobman()
    if not bman then return nil end
    local seat = bman:FindFirstChild("VehicleSeat")
    if not seat then return nil end
    for _ = 1, 20 do
        hrp.CFrame = seat.CFrame + Vector3.new(0, 2.5, 0)
        task.wait(0.05)
        pcall(function() seat:Sit(humanoid) end)
        if isPlayerSeatedInBlobman() then return humanoid.SeatPart and humanoid.SeatPart.Parent or bman end
        task.wait(0.1)
    end
    return nil
end

local function holdTargetInAir(targetPlayer, index, total)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end
    local center = myHRP.Position + Vector3.new(0, 45, 0)
    local radius = math.max(4, (total or 1) * 0.8)
    local angle = tick() * 7 + ((index - 1) * ((2 * math.pi) / math.max(1, total or 1)))
    local desired = center + Vector3.new(math.cos(angle) * radius, (index - 1) * 3, math.sin(angle) * radius)
    local floatBP = targetHRP:FindFirstChild("ServerKickFloat")
    if not floatBP then
        floatBP = Instance.new("BodyPosition")
        floatBP.Name = "ServerKickFloat"
        floatBP.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        floatBP.D = 1000
        floatBP.P = 25000
        floatBP.Parent = targetHRP
    end
    floatBP.Position = desired
    local spinBV = targetHRP:FindFirstChild("ServerKickSpin")
    if not spinBV then
        spinBV = Instance.new("BodyAngularVelocity")
        spinBV.Name = "ServerKickSpin"
        spinBV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        spinBV.P = 125000
        spinBV.Parent = targetHRP
    end
    spinBV.AngularVelocity = Vector3.new(0, 420, 0)
    targetHRP.CFrame = CFrame.new(desired)
    targetHRP.AssemblyLinearVelocity = Vector3.zero
    targetHRP.AssemblyAngularVelocity = Vector3.new(0, 420, 0)
    targetHRP.Velocity = Vector3.zero
    targetHRP.RotVelocity = Vector3.new(0, 420, 0)
end

local function applyServerKickAntiRagdoll(targetPlayer)
    if not (targetPlayer and targetPlayer.Character) then return end
    local tChar = targetPlayer.Character
    local tHum = tChar:FindFirstChildOfClass("Humanoid")
    local tHRP = tChar:FindFirstChild("HumanoidRootPart")
    if not (tHum and tHRP) then return end
    pcall(function() ragdollRemoteEvent:FireServer(tHRP, 0) end)
    tHum.PlatformStand = true
    tHum.Sit = true
    tHum.AutoRotate = false
    tHum.WalkSpeed = 0
    tHum.JumpPower = 0
    tHum.Jump = false
    tHRP.AssemblyLinearVelocity = Vector3.zero
    tHRP.AssemblyAngularVelocity = Vector3.new(0, 420, 0)
    tHRP.Velocity = Vector3.zero
    tHRP.RotVelocity = Vector3.new(0, 420, 0)
end

local function seatContextIsValid(seatParent)
    if not (seatParent and seatParent.Parent) then return false end
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local seatPart = humanoid and humanoid.SeatPart
    if not (humanoid and humanoid.Sit and seatPart and seatPart.Parent == seatParent) then return false end
    local blobScript = seatParent:FindFirstChild("BlobmanSeatAndOwnerScript")
    local creatureGrab = blobScript and blobScript:FindFirstChild("CreatureGrab")
    local leftDetector = seatParent:FindFirstChild("LeftDetector")
    local leftWeld = leftDetector and leftDetector:FindFirstChild("LeftWeld")
    return creatureGrab ~= nil and leftDetector ~= nil and leftWeld ~= nil
end

local function stabilizeBlobmanTeleport(targetCFrame, settleTime)
    local character = LP.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not (hrp and targetCFrame) then return false end
    local settle = settleTime or 0.03
    local targetPos = targetCFrame.Position
    local targetLook = targetCFrame.LookVector
    targetPos = Vector3.new(targetPos.X, math.clamp(targetPos.Y, 10, 1500), targetPos.Z)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local seatParent = humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent
    local blobRoot = seatParent and (seatParent:FindFirstChild("HumanoidRootPart") or seatParent.PrimaryPart)
    for _ = 1, 4 do
        local stableCF = CFrame.lookAt(targetPos, targetPos + targetLook)
        hrp.CFrame = stableCF
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        if blobRoot then
            blobRoot.CFrame = stableCF
            blobRoot.AssemblyLinearVelocity = Vector3.zero
            blobRoot.AssemblyAngularVelocity = Vector3.zero
            blobRoot.Velocity = Vector3.zero
            blobRoot.RotVelocity = Vector3.zero
        end
        task.wait(settle)
    end
    return true
end

local function getPrimaryGrabHand(seatParent)
    local blobScript = seatParent and seatParent:FindFirstChild("BlobmanSeatAndOwnerScript")
    local creatureGrab = blobScript and blobScript:FindFirstChild("CreatureGrab")
    if not creatureGrab then return nil end
    local leftDetector = seatParent:FindFirstChild("LeftDetector")
    local leftWeld = leftDetector and leftDetector:FindFirstChild("LeftWeld")
    if not (leftDetector and leftWeld) then return nil end
    return creatureGrab, leftDetector, leftWeld
end

local function hasOwnershipOnTarget(targetHRP)
    local owner = targetHRP and targetHRP:FindFirstChild("PartOwner")
    return owner and owner.Value == LP.Name
end

local function forceOwnershipBurst(targetHRP, repeats)
    if not targetHRP then return end
    for _ = 1, repeats or 2 do SNOWshipForce(targetHRP) task.wait() end
end

local function kickGrabPlayerWithBlobman(targetPlayer, seatParent)
    if not (targetPlayer and targetPlayer.Character and seatParent) then return false end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local creatureGrab, detector, weld = getPrimaryGrabHand(seatParent)
    if not (targetHRP and myHRP and creatureGrab and detector and weld) then return false end
    if not seatContextIsValid(seatParent) then return false end
    local toTarget = CFrame.lookAt(targetHRP.Position + Vector3.new(0, 5, -6), targetHRP.Position)
    if not stabilizeBlobmanTeleport(toTarget, 0.02) then return false end
    forceOwnershipBurst(targetHRP, 2)
    for _ = 1, 3 do
        if not seatContextIsValid(seatParent) then return false end
        creatureGrab:FireServer(detector, targetHRP, weld)
        task.wait(0.025)
    end
    return hasOwnershipOnTarget(targetHRP)
end

local workspaceService = workspace

function GetKey() return "Xana" end
function showNotification(message)
    Rayfield:Notify({Title = "Notification", Content = message, Duration = 5})
end

local freezecampart = Instance.new("Part", workspaceService)
freezecampart.Anchored = true
freezecampart.CanCollide = false
freezecampart.Transparency = 1
freezecampart.CanQuery = false
freezecampart.Size = Vector3.new()

function FreezeCam(cameraCFrame)
    freezecampart.CFrame = cameraCFrame
    workspace.CurrentCamera.CameraType = Enum.CameraType.Follow
    workspace.CurrentCamera.CameraSubject = freezecampart
end

function unFreezeCam()
    workspace.CurrentCamera.CameraSubject = LP.Character:FindFirstChildOfClass("Humanoid")
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end

function CheckPlayerVelocity(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        return player.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude
    end
    return math.huge
end

function CheckPlayerBring(potentialPlayer)
    if CheckPlayer(potentialPlayer) and not IsPlayerInsideSafeZone(potentialPlayer) and CheckPlayerVelocity(potentialPlayer) < 20 then
        return true
    end
end

function SNOWshipOnce(targetPart)
    if targetPart and typeof(targetPart) == "Instance" then
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            setNetworkOwnerEvent:FireServer(targetPart, lookAt(char.HumanoidRootPart.Position, targetPart.Position))
        end
    end
end

function CreateBringBody(humanoidRootPart, targetCFrame)
    local bodyPosition = humanoidRootPart:FindFirstChild("BringBody")
    if bodyPosition then
        bodyPosition.Position = targetCFrame.Position
    else
        bodyPosition = Instance.new("BodyPosition", humanoidRootPart)
        bodyPosition.Name = "BringBody"
        bodyPosition.Position = targetCFrame.Position
        bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyPosition.D = 5000
        bodyPosition.P = 1500000
    end
end

local function LagServer(modeType)
    task.defer(function()
        while task.wait(1 / GrabsPerSecond) do
            if modeType == "Players" then
                if not LagServerUsingPlayers then break end
                for _, player in pairs(Players:GetPlayers()) do
                    local character = player.Character
                    local torso = character and character:FindFirstChild("Torso")
                    if torso then
                        local args = {[1] = torso, [2] = torso.CFrame}
                        ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("CreateGrabLine"):FireServer(unpack(args))
                    end
                end
            elseif modeType == "Map" then
                if not LagServerUsingMap then break end
                local mapModel = workspace:FindFirstChild("Map")
                local baseGround = mapModel and mapModel:FindFirstChild("BaseGround")
                if baseGround then
                    for _, grass in pairs(baseGround:GetChildren()) do
                        if grass.Name == "Grass" then
                            local args = {[1] = grass, [2] = grass.CFrame}
                            ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("CreateGrabLine"):FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)
end

local function DisableInvisLine()
    if _G.InvisLine then
        Rayfield:Notify({Title = "Warning", Content = "Your ping will increase in some time (Invis line has been toggled off because lag script won't work if it's on.)", Duration = 7})
        _G.InvisLine = false
        if _G.InvisLineToggle then pcall(function() _G.InvisLineToggle:Set(false) end) end
    end
end

ServerTab:CreateSection("Server Lagger")

local lagServerPlayersToggle = ServerTab:CreateToggle({
    Name = "Lag Server Using Players",
    CurrentValue = false,
    Flag = "lag_server_using_players",
    Callback = function(Value)
        LagServerUsingPlayers = Value
        if LagServerUsingPlayers then DisableInvisLine() LagServer("Players") end
    end,
})

local lagServerMapToggle = ServerTab:CreateToggle({
    Name = "Lag Server Using Map",
    CurrentValue = false,
    Flag = "lag_server_using_map",
    Callback = function(Value)
        LagServerUsingMap = Value
        if LagServerUsingMap then DisableInvisLine() LagServer("Map") end
    end,
})

ServerTab:CreateSlider({
    Name = "Grabs Per Second",
    Range = {5, 5000},
    Increment = 1,
    CurrentValue = 50,
    Flag = "lag_grabs_per_second",
    Callback = function(Value) GrabsPerSecond = Value end,
})

ServerTab:CreateSection("Annoy All")

fireAllEnabled = false
ServerTab:CreateToggle({
    Name = "Fire All (Still Tweaking)",
    CurrentValue = false,
    Flag = "fire_all_toggle",
    Callback = function(Value)
        fireAllEnabled = Value
        if Value then
            task.spawn(function()
                while fireAllEnabled do
                    for _, p in pairs(Players:GetPlayers()) do
                        if CheckPlayerAnnoyAll(p) then
                            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                            local canBurn = hrp and hrp:FindFirstChild("FirePlayerPart") and hrp.FirePlayerPart:FindFirstChild("CanBurn")
                            if hrp and not (canBurn and canBurn.Value) then
                                handleCampfireTouch(hrp)
                                task.wait(0.015)
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end,
})

ragdollAllEnabled = false
ServerTab:CreateToggle({
    Name = "Ragdoll All (Being Fixed)",
    CurrentValue = false,
    Flag = "ragdoll_all_toggle",
    Callback = function(Value)
        ragdollAllEnabled = Value
        if Value then
            task.spawn(function()
                while ragdollAllEnabled do
                    for _, p in pairs(Players:GetPlayers()) do
                        if CheckPlayerAnnoyAll(p) then
                            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                            local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                            local ragdolled = hum and hum:FindFirstChild("Ragdolled")
                            if hrp and not (ragdolled and ragdolled.Value) then
                                pcall(function() ragdollRemoteEvent:FireServer(hrp, 1) end)
                                task.wait(0.015)
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end,
})

ServerTab:CreateSection("Auto Spin")

autoSpinEnabled = false
_G_SavedPositionInSpin = nil

local function areAllSlotsNeon()
    local slotsFolder = workspace:FindFirstChild("Slots")
    if not slotsFolder then return false end
    local anyNeon = false
    for _, slot in pairs(slotsFolder:GetChildren()) do
        local lightBall = slot:FindFirstChild("SlotHandle") and slot.SlotHandle:FindFirstChild("LightBall")
        if lightBall then
            if lightBall.Material ~= Enum.Material.Neon then return false end
            anyNeon = true
        end
    end
    return anyNeon
end

ServerTab:CreateToggle({
    Name = "Auto Spin",
    CurrentValue = false,
    Flag = "auto_spin_toggle",
    Callback = function(Value)
        autoSpinEnabled = Value
        if Value then
            task.spawn(function()
                while autoSpinEnabled do
                    if areAllSlotsNeon() and ChangeActivityPriority(5) then
                        local myChar = LP.Character
                        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                        if myHRP then _G_SavedPositionInSpin = myHRP.CFrame end
                        local slotsFolder = workspace:FindFirstChild("Slots")
                        if slotsFolder then
                            local slotHandle = nil
                            local teleportTask = task.spawn(function()
                                while autoSpinEnabled do
                                    if slotHandle then
                                        TeleportPlayer(slotHandle.CFrame + Vector3.new(0, 5, 0), 5)
                                        task.wait(0.2)
                                        SNOWship(slotHandle)
                                    end
                                    task.wait()
                                end
                            end)
                            for _, slot in pairs(slotsFolder:GetChildren()) do
                                local handle = slot:FindFirstChild("SlotHandle") and slot.SlotHandle:FindFirstChild("Handle")
                                if handle then
                                    slotHandle = handle
                                    handle.CanCollide = false
                                    for _ = 1, 5 do task.wait(0.2) end
                                    handle.CanCollide = true
                                end
                                if not areAllSlotsNeon() then break end
                            end
                            task.cancel(teleportTask)
                        end
                        ChangeActivityPriority(0)
                        local c = LP.Character
                        local h = c and c:FindFirstChild("HumanoidRootPart")
                        if h and _G_SavedPositionInSpin then h.CFrame = _G_SavedPositionInSpin end
                    end
                    task.wait(5)
                end
            end)
        end
    end,
})

spinTimerLabel = ServerTab:CreateParagraph({Title = "Spin Cooldown", Content = "Time Remaining: --"})

task.spawn(function()
    local slotsFolder = workspace:FindFirstChild("Slots")
    if not slotsFolder then return end
    local ok, timeText = pcall(function()
        return slotsFolder:WaitForChild("Slots", 5):WaitForChild("Screen", 5):WaitForChild("SlotGui", 5):WaitForChild("TimeLeftFrame", 5):WaitForChild("TimeText", 5)
    end)
    if not ok or not timeText then return end
    pcall(function() spinTimerLabel:Set("Time Remaining: " .. timeText.Text) end)
    timeText:GetPropertyChangedSignal("Text"):Connect(function()
        pcall(function() spinTimerLabel:Set("Time Remaining: " .. timeText.Text) end)
    end)
end)

ServerTab:CreateSection("OP")

local killAllToggle = ServerTab:CreateToggle({
    Name = "Kill All",
    CurrentValue = false,
    Flag = "kill_all_toggle",
    Callback = function(killAllEnabled)
        _G.KillAll = killAllEnabled
        if killAllEnabled then
            local ipos = nil
            local _kaChar = LP.Character
            local _kaHRP = _kaChar and _kaChar:FindFirstChild("HumanoidRootPart")
            local _kaAnchor = Instance.new("Part")
            _kaAnchor.Anchored = true
            _kaAnchor.CanCollide = false
            _kaAnchor.CastShadow = false
            _kaAnchor.Transparency = 1
            _kaAnchor.Size = Vector3.new(1, 1, 1)
            _kaAnchor.CFrame = _kaHRP and _kaHRP.CFrame or CFrame.new(0, 0, 0)
            _kaAnchor.Parent = workspace
            local _kaOrigSubject = workspace.CurrentCamera.CameraSubject
            workspace.CurrentCamera.CameraSubject = _kaAnchor
            local _kaHiddenParts = {}
            if _kaChar then
                for _, part in ipairs(_kaChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        _kaHiddenParts[part] = part.LocalTransparencyModifier
                        part.LocalTransparencyModifier = 1
                    end
                end
            end
            while _G.KillAll do
                ipos = GetPlayerCFrame()
                local playersService = Players
                local playerIterator, playerIterator3, playerIndex = pairs(playersService:GetPlayers())
                while true do
                    local player
                    playerIndex, player = playerIterator(playerIterator3, playerIndex)
                    if playerIndex == nil then break end
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
            _kaAnchor:Destroy()
            workspace.CurrentCamera.CameraSubject = (LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")) or _kaOrigSubject
            for part, origTrans in pairs(_kaHiddenParts) do
                if part and part.Parent then part.LocalTransparencyModifier = origTrans end
            end
            dialogueFunction1()
            TeleportPlayer(ipos)
        end
    end
})

local loopKickServerToggle = ServerTab:CreateToggle({
    Name = "Loop Kick Server",
    CurrentValue = false,
    Flag = "loop_kick_server",
    Callback = function(Value)
        ServerLoopKickActive = Value
        if not Value then return end

        task.spawn(function()
            Rayfield:Notify({Title = "Loop Kick Server", Content = "Starting...", Duration = 3})

            local seatParent = ensureSeatedBlobman()
            if not seatParent then
                ServerLoopKickActive = false
                if loopKickServerToggle then pcall(function() loopKickServerToggle:Set(false) end) end
                Rayfield:Notify({Title = "Loop Kick Server", Content = "Failed to seat in blobman", Duration = 3})
                return
            end

            local GE = ReplicatedStorage:WaitForChild("GrabEvents")
            local scriptObj = seatParent:FindFirstChild("BlobmanSeatAndOwnerScript")
            local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
            local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
            local L_Det = seatParent:FindFirstChild("LeftDetector")
            local L_Weld = L_Det and (L_Det:FindFirstChild("LeftWeld") or L_Det:FindFirstChildWhichIsA("Weld"))
            local R_Det = seatParent:FindFirstChild("RightDetector")
            local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))

            if not (CG and CD and L_Det and L_Weld) then
                ServerLoopKickActive = false
                if loopKickServerToggle then pcall(function() loopKickServerToggle:Set(false) end) end
                Rayfield:Notify({Title = "Loop Kick Server", Content = "Blobman refs not found", Duration = 3})
                return
            end

            local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP then
                ServerLoopKickActive = false
                if loopKickServerToggle then pcall(function() loopKickServerToggle:Set(false) end) end
                return
            end

            local hubPos = myHRP.Position + Vector3.new(0, 40, 0)
            local CIRCLE_RADIUS = 12
            local HOLD_HEIGHT   = 45

            local targets = {}
            for _, plr in pairs(Players:GetPlayers()) do
                if CheckPlayerKill(plr) then
                    local tChar = plr.Character
                    local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
                    if tHRP and tHum and tHum.Health > 0 then
                        table.insert(targets, plr)
                    end
                end
            end

            if #targets == 0 then
                ServerLoopKickActive = false
                if loopKickServerToggle then pcall(function() loopKickServerToggle:Set(false) end) end
                Rayfield:Notify({Title = "Loop Kick Server", Content = "No valid targets found", Duration = 3})
                return
            end

            Rayfield:Notify({Title = "Loop Kick Server", Content = "Grabbing " .. #targets .. " player(s)...", Duration = 4})

            for _, plr in ipairs(targets) do
                local tChar = plr.Character
                local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    pcall(function()
                        setNetworkOwnerEvent:FireServer(tHRP, CFrame.lookAt(myHRP.Position, tHRP.Position))
                    end)
                end
            end
            task.wait(0.05)

            for i, plr in ipairs(targets) do
                local tChar = plr.Character
                local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    local det = (i % 2 == 1) and L_Det or R_Det
                    local weld = (i % 2 == 1) and L_Weld or R_Weld
                    if det and weld then
                        pcall(function() CG:FireServer(det, tHRP, weld) end)
                    else
                        pcall(function() CG:FireServer(L_Det, tHRP, L_Weld) end)
                    end
                    pcall(function()
                        GE.CreateGrabLine:FireServer(tHRP, Vector3.zero, tHRP.Position, false)
                    end)
                end
                RunService.Heartbeat:Wait()
            end

            task.wait(0.1)

            local holdStart = tick()
            local HOLD_DURATION = 2.5

            for i, plr in ipairs(targets) do
                local tChar = plr.Character
                local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    local angle = ((i - 1) / #targets) * (2 * math.pi)
                    local circlePos = hubPos
                        + Vector3.new(math.cos(angle) * CIRCLE_RADIUS, HOLD_HEIGHT - 40, math.sin(angle) * CIRCLE_RADIUS)
                    tHRP.CFrame = CFrame.new(circlePos)
                    tHRP.AssemblyLinearVelocity = Vector3.zero
                    tHRP.AssemblyAngularVelocity = Vector3.zero
                end
            end

            while tick() - holdStart < HOLD_DURATION and ServerLoopKickActive do
                myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not myHRP then break end
                for i, plr in ipairs(targets) do
                    if not ServerLoopKickActive then break end
                    local tChar = plr.Character
                    local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
                    if tHRP and tHum and tHum.Health > 0 then
                        local angle = ((i - 1) / #targets) * (2 * math.pi)
                        local circlePos = myHRP.Position
                            + Vector3.new(math.cos(angle) * CIRCLE_RADIUS, HOLD_HEIGHT, math.sin(angle) * CIRCLE_RADIUS)
                        tHRP.CFrame = CFrame.new(circlePos)
                        tHRP.AssemblyLinearVelocity = Vector3.zero
                        tHRP.Velocity = Vector3.zero
                        tHum.PlatformStand = true
                        tHum.Sit = true
                        pcall(function()
                            setNetworkOwnerEvent:FireServer(tHRP, CFrame.lookAt(myHRP.Position, tHRP.Position))
                        end)
                    end
                end
                task.wait(0.05)
            end

            for i, plr in ipairs(targets) do
                local tChar = plr.Character
                local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    tHRP.AssemblyLinearVelocity = Vector3.new(0, 200, 0)
                    local det = (i % 2 == 1) and L_Det or R_Det
                    if det then
                        local weld = det:FindFirstChildWhichIsA("Weld")
                        if weld then pcall(function() CD:FireServer(weld) end) end
                    end
                    pcall(function() GE.DestroyGrabLine:FireServer(tHRP) end)
                end
                RunService.Heartbeat:Wait()
            end

            ServerLoopKickActive = false
            if loopKickServerToggle then pcall(function() loopKickServerToggle:Set(false) end) end
            Rayfield:Notify({Title = "Loop Kick Server", Content = "Done -- " .. #targets .. " player(s) kicked", Duration = 4})
        end)
    end
})

local bringalltoggle
bringalltoggle = ServerTab:CreateToggle({
    Name = "Bring All",
    CurrentValue = false,
    Flag = "bring_all_toggle",
    Callback = function(bringAllEnabled)
        _G.BringAll = bringAllEnabled
        if bringAllEnabled then
            if GetKey() ~= "Xana" then
                _G.BringAll = false
                bringalltoggle:Set(false)
                showNotification("cracked pussy")
                return
            end
            local playerCFrame = GetPlayerCFrame()
            if not playerCFrame then
                _G.BringAll = false
                bringalltoggle:Set(false)
                showNotification("Character not ready. Try again after respawn.")
                return
            end
            local cameraCFrame = CFrame.lookAt(workspaceService.CurrentCamera.CFrame.Position + Vector3.new(-15, 15, 0), playerCFrame.Position)
            workspace.CurrentCamera.CFrame = cameraCFrame
            while _G.BringAll do
                FreezeCam(cameraCFrame)
                local playersService = Players
                local playerIterator, playerIterator5, playerIndex = pairs(playersService:GetPlayers())
                while true do
                    local player
                    playerIndex, player = playerIterator(playerIterator5, playerIndex)
                    if playerIndex == nil then break end
                    if CheckPlayerBring(player) then
                        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        local ragdolledValue = humanoid and humanoid:FindFirstChild("Ragdolled")
                        if player and humanoidRootPart and humanoid then
                            for _ = 0, 50 do
                                if not _G.BringAll then break end
                                dialogueFunction2()
                                SNOWshipOnce(humanoidRootPart)
                                if not CheckNetworkOwnerShipOnPlayer(player) then SNOWshipForce(humanoidRootPart) end
                                if CheckNetworkOwnerShipOnPlayer(player) then
                                    if (not ragdolledValue or not ragdolledValue.Value) and player:DistanceFromCharacter(playerCFrame.Position) > 10 then
                                        humanoidRootPart.CFrame = playerCFrame
                                    end
                                    CreateBringBody(humanoidRootPart, playerCFrame)
                                    break
                                end
                                task.wait()
                                if humanoidRootPart.Position.Y <= -12 then
                                    TeleportPlayer(CFrame.new(humanoidRootPart.Position + Vector3.new(0, 5, -15)))
                                else
                                    TeleportPlayer(CFrame.new(humanoidRootPart.Position + Vector3.new(0, -10, -10)))
                                end
                            end
                        end
                    end
                end
                TeleportPlayer(CFrame.new(527, 123, -376))
                task.wait()
            end
            unFreezeCam()
            dialogueFunction1()
            TeleportPlayer(playerCFrame)
        end
    end
})

-- ============================================================
-- WHITELIST TAB
-- ============================================================
killAllWhitelist = killAllWhitelist or {}
local kaWhitelistDropdown = nil
local kaWhitelistToAdd = nil

local function getKAWhitelistOptions()
    local opts = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local display = p.DisplayName ~= p.Name and (p.DisplayName .. " (" .. p.Name .. ")") or p.Name
            table.insert(opts, display)
        end
    end
    return opts
end

local function isWhitelisted(playerName)
    return killAllWhitelist[playerName] == true
end

local function getWhitelistedNames()
    local names = {}
    for name in pairs(killAllWhitelist) do table.insert(names, name) end
    return names
end

function CheckPlayerAnnoyAll(p)
    if CheckPlayer(p) and not IsPlayerInsideSafeZone(p) and not isWhitelisted(p.Name) then return true end
end

WhitelistTab:CreateSection("Kill/Annoy Whitelist")

WhitelistTab:CreateParagraph({
    Title = "About Whitelist",
    Content = "Players added here will be ignored by Kill All, Annoy All, and other server-wide features."
})

kaWhitelistDropdown = WhitelistTab:CreateDropdown({
    Name = "Select Player",
    Options = getKAWhitelistOptions(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "ka_whitelist_select",
    Callback = function(option)
        local raw = type(option) == "table" and option[1] or option
        kaWhitelistToAdd = extractUsername(raw)
    end,
})

WhitelistTab:CreateButton({
    Name = "Add to Whitelist",
    Callback = function()
        if kaWhitelistToAdd and kaWhitelistToAdd ~= "" then
            killAllWhitelist[kaWhitelistToAdd] = true
            Rayfield:Notify({Title = "Whitelist", Content = kaWhitelistToAdd .. " added -- won't be targeted", Duration = 3})
        else
            Rayfield:Notify({Title = "Whitelist", Content = "Select a player first", Duration = 2})
        end
    end,
})

WhitelistTab:CreateButton({
    Name = "Remove from Whitelist",
    Callback = function()
        if kaWhitelistToAdd and kaWhitelistToAdd ~= "" then
            killAllWhitelist[kaWhitelistToAdd] = nil
            Rayfield:Notify({Title = "Whitelist", Content = kaWhitelistToAdd .. " removed", Duration = 3})
        else
            Rayfield:Notify({Title = "Whitelist", Content = "Select a player first", Duration = 2})
        end
    end,
})

WhitelistTab:CreateButton({
    Name = "Whitelist Friends",
    Callback = function()
        local added = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP then
                local ok, isFriend = pcall(function() return LP:IsFriendsWith(p.UserId) end)
                if ok and isFriend then
                    killAllWhitelist[p.Name] = true
                    added = added + 1
                end
            end
        end
        Rayfield:Notify({Title = "Whitelist", Content = added .. " friend(s) whitelisted", Duration = 3})
    end,
})

WhitelistTab:CreateButton({
    Name = "View Whitelist",
    Callback = function()
        local names = getWhitelistedNames()
        if #names == 0 then
            Rayfield:Notify({Title = "Whitelist", Content = "Whitelist is empty", Duration = 3})
        else
            Rayfield:Notify({Title = "Whitelist (" .. #names .. ")", Content = table.concat(names, ", "), Duration = 6})
        end
    end,
})

WhitelistTab:CreateButton({
    Name = "Clear Whitelist",
    Callback = function()
        killAllWhitelist = {}
        Rayfield:Notify({Title = "Whitelist", Content = "Whitelist cleared", Duration = 2})
    end,
})

Players.PlayerAdded:Connect(function()
    task.wait(1)
    if kaWhitelistDropdown then kaWhitelistDropdown:Refresh(getKAWhitelistOptions(), true) end
end)
Players.PlayerRemoving:Connect(function(p)
    if kaWhitelistDropdown then kaWhitelistDropdown:Refresh(getKAWhitelistOptions(), true) end
end)

-- ============================================================
-- Script Tab
-- ============================================================
ScriptTab:CreateSection("Script Control")

ScriptTab:CreateButton({
    Name = "Kill Script",
    Callback = function()
        Rayfield:Notify({Title = "Script", Content = "Ending script...", Duration = 3})
        task.wait(0.5)
        loopSpamKickEnabled = false
        loopBlobSpamKickEnabled = false
        _G.LoopKill = false
        _G.KillAll = false
        _G.BringAll = false
        _G.BlobGucciLoopKill = false
        _G.AntiLag = false
        _G.AntiKick = false
        _G.AntiGrab = false
        _G.SuperSpeed = false
        _G.noclip = false
        _G.infinjump = false
        _G.thirdPerson = false
        savitarStopZoomLock()
        _G.thirdPerson = false
        for name, conn in pairs(plotWatchConns or {}) do pcall(function() conn:Disconnect() end) end
        for name, conn in pairs(loopKillCharConn or {}) do pcall(function() conn:Disconnect() end) end
        pcall(function() Rayfield:Destroy() end)
    end,
})

ScriptTab:CreateButton({
    Name = "Clear Data",
    Callback = function()
        pcall(function()
            if isfile and isfile("CrimsonFTAPConfigs/Main.json") then
                writefile("CrimsonFTAPConfigs/Main.json", "{}")
            end
            if Rayfield and Rayfield.ResetConfig then Rayfield:ResetConfig() end
        end)
        Rayfield:Notify({Title = "Script", Content = "Saved data wiped. Kill and reload script to load changes.", Duration = 5})
    end,
})

local function forceDisableServerTabFeatures()
    LagServerUsingPlayers = false
    LagServerUsingMap = false
    ServerLoopKickActive = false
    _G.KillAll = false
    _G.BringAll = false
    _G.BlobGucciLoopKill = false
    if lagServerPlayersToggle then pcall(function() lagServerPlayersToggle:Set(false) end) end
    if lagServerMapToggle then pcall(function() lagServerMapToggle:Set(false) end) end
    if killAllToggle then pcall(function() killAllToggle:Set(false) end) end
    if loopKickServerToggle then pcall(function() loopKickServerToggle:Set(false) end) end
    if bringalltoggle then pcall(function() bringalltoggle:Set(false) end) end
end

Rayfield:Notify({Title = "Crimson Ready", Content = "Harm & BlueBands Loaded g - homer", Duration = 5})

task.spawn(function()
    task.wait(0.25)
    pcall(function() Rayfield:LoadConfiguration() end)
    task.wait(0.1)
    forceDisableServerTabFeatures()
end)
