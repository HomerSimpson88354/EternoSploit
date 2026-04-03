-- 🔹 Custom Crimson Obsidian-style UI Library
local Library = {}
Library.Windows = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Default Theme
Library.Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(200, 0, 0),
    TextColor = Color3.new(1,1,1),
    Hover = Color3.fromRGB(255, 50, 50)
}

-- Helper: Create ScreenGui
local function createScreenGui()
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = LP:WaitForChild("PlayerGui")
    return gui
end

-- Create Window
function Library:CreateWindow(config)
    local window = {}
    local gui = createScreenGui()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 400)
    frame.Position = UDim2.new(0, 50, 0, 50)
    frame.BackgroundColor3 = self.Theme.Background
    frame.BorderSizePixel = 0
    frame.Parent = gui
    frame.Name = config.Name or "Window"

    -- Title
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,30)
    title.BackgroundTransparency = 1
    title.Text = config.Name or "Window"
    title.TextColor3 = self.Theme.TextColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18

    -- Tabs container
    local Tabs = {}
    local TabFrames = {}

    -- Function to create tabs
    function window:CreateTab(name)
        local tab = {}
        local tabFrame = Instance.new("Frame")
        tabFrame.Size = UDim2.new(1,0,1,-30)
        tabFrame.Position = UDim2.new(0,0,0,30)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = true
        tabFrame.Parent = frame

        TabFrames[#TabFrames+1] = tabFrame

        function tab:CreateButton(opts)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9,0,0,30)
            btn.Position = UDim2.new(0.05,0,0,10 + (#tabFrame:GetChildren()-1)*40)
            btn.BackgroundColor3 = Library.Theme.Accent
            btn.TextColor3 = Library.Theme.TextColor
            btn.Text = opts.Name or "Button"
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.Parent = tabFrame

            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Library.Theme.Hover end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Library.Theme.Accent end)
            btn.MouseButton1Click:Connect(function()
                if opts.Callback then pcall(opts.Callback) end
            end)
        end

        function tab:CreateSlider(opts)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(0.9,0,0,20)
            sliderFrame.Position = UDim2.new(0.05,0,0,50 + (#tabFrame:GetChildren()-1)*40)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
            sliderFrame.Parent = tabFrame

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0.5,0,1,0)
            fill.BackgroundColor3 = Library.Theme.Accent
            fill.Parent = sliderFrame

            local dragging = false
            sliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            sliderFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local x = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X)/sliderFrame.AbsoluteSize.X,0,1)
                    fill.Size = UDim2.new(x,0,1,0)
                    if opts.Callback then pcall(opts.Callback,x*(opts.Range[2]-opts.Range[1])+opts.Range[1]) end
                end
            end)
        end

        function tab:CreateToggle(opts)
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0.9,0,0,30)
            toggleBtn.Position = UDim2.new(0.05,0,0,90 + (#tabFrame:GetChildren()-1)*40)
            toggleBtn.BackgroundColor3 = Library.Theme.Accent
            toggleBtn.TextColor3 = Library.Theme.TextColor
            toggleBtn.Text = (opts.Name or "Toggle").." OFF"
            toggleBtn.Parent = tabFrame

            local state = false
            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                toggleBtn.Text = (opts.Name or "Toggle").." "..(state and "ON" or "OFF")
                if opts.Callback then pcall(opts.Callback,state) end
            end)
        end

        function tab:CreateKeybind(opts)
            UIS.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.KeyCode == opts.Key then
                    if opts.Callback then pcall(opts.Callback) end
                end
            end)
        end

        return tab
    end

    self.Windows[#self.Windows+1] = window
    return window
end

-- Notification
function Library:Notify(opts)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0,250,0,50)
    notif.Position = UDim2.new(1,-260,0,50)
    notif.BackgroundColor3 = Library.Theme.Accent
    notif.TextColor3 = Library.Theme.TextColor
    notif.Text = (opts.Title or "").."\n"..(opts.Content or "")
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 16
    notif.Parent = LP.PlayerGui
    spawn(function()
        wait(opts.Duration or 3)
        notif:Destroy()
    end)
end

return Library
