--[[
    ██████╗██████╗ ██╗███╗   ███╗███████╗ ██████╗ ███╗   ██╗
   ██╔════╝██╔══██╗██║████╗ ████║██╔════╝██╔═══██╗████╗  ██║
   ██║     ██████╔╝██║██╔████╔██║███████╗██║   ██║██╔██╗ ██║
   ██║     ██╔══██╗██║██║╚██╔╝██║╚════██║██║   ██║██║╚██╗██║
   ╚██████╗██║  ██║██║██║ ╚═╝ ██║███████║╚██████╔╝██║ ╚████║
    ╚═════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝
    Crimson GUI — homer and virck
    Drop-in Rayfield replacement for Crimson FTAP
    

local Crimson = {}
Crimson.__index = Crimson

local Players         = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local LP              = Players.LocalPlayer
local Mouse           = LP:GetMouse()

local Theme = {
    -- Window chrome
    Background      = Color3.fromRGB(10, 4, 4),
    Topbar          = Color3.fromRGB(16, 5, 5),
    Shadow          = Color3.fromRGB(6, 2, 2),
    Border          = Color3.fromRGB(60, 18, 18),

    -- Sidebar / tabs
    TabBackground         = Color3.fromRGB(22, 7, 7),
    TabBackgroundSelected = Color3.fromRGB(140, 20, 20),
    TabStroke             = Color3.fromRGB(70, 20, 20),
    TabText               = Color3.fromRGB(200, 160, 160),
    TabTextSelected       = Color3.fromRGB(255, 220, 220),

    -- Elements
    ElementBackground      = Color3.fromRGB(22, 7, 7),
    ElementBackgroundHover = Color3.fromRGB(34, 10, 10),
    ElementStroke          = Color3.fromRGB(70, 20, 20),
    ElementText            = Color3.fromRGB(235, 210, 210),
    SubText                = Color3.fromRGB(160, 110, 110),

    -- Accent
    Accent        = Color3.fromRGB(180, 22, 22),
    AccentBright  = Color3.fromRGB(220, 40, 40),
    AccentDim     = Color3.fromRGB(110, 15, 15),

    -- Toggles
    ToggleOn      = Color3.fromRGB(200, 28, 28),
    ToggleOff     = Color3.fromRGB(55, 20, 20),
    ToggleKnob    = Color3.fromRGB(255, 200, 200),

    -- Slider
    SliderTrack   = Color3.fromRGB(40, 10, 10),
    SliderFill    = Color3.fromRGB(180, 22, 22),
    SliderKnob    = Color3.fromRGB(240, 80, 80),

    -- Section
    SectionText   = Color3.fromRGB(160, 50, 50),
    SectionLine   = Color3.fromRGB(55, 15, 15),

    -- Notification
    NotifBackground = Color3.fromRGB(18, 5, 5),
    NotifAccent     = Color3.fromRGB(180, 22, 22),
    NotifText       = Color3.fromRGB(235, 210, 210),
    NotifSubText    = Color3.fromRGB(155, 105, 105),

    -- Scrollbar
    ScrollBar     = Color3.fromRGB(90, 20, 20),
    ScrollBarHover= Color3.fromRGB(140, 25, 25),

    -- Input / Dropdown
    InputBackground = Color3.fromRGB(18, 5, 5),
    InputStroke     = Color3.fromRGB(80, 20, 20),
    DropdownArrow   = Color3.fromRGB(180, 22, 22),
}

local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t or 0.18, style, dir), props):Play()
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            frame.Position = newPos
        end
    end)
end

local function CreateInstance(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function UICorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius  = UDim.new(0, radius or 6)
    c.Parent        = parent
    return c
end

local function UIStroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color     = color
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent    = parent
    return s
end

local function UIPadding(t, b, l, r, parent)
    local p = Instance.new("UIPaddingConstraint" ~= "x" and "UIPadding" or "UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent        = parent
    return p
end

local function UIListLayout(parent, spacing, fill, dir)
    local l = Instance.new("UIListLayout")
    l.Padding          = UDim.new(0, spacing or 4)
    l.FillDirection    = fill or Enum.FillDirection.Vertical
    l.SortOrder        = Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    if dir then l.FillDirection = dir end
    l.Parent           = parent
    return l
end

local function Label(text, size, color, font, props, parent)
    local l = CreateInstance("TextLabel", {
        Text              = text or "",
        TextSize          = size or 14,
        TextColor3        = color or Theme.ElementText,
        Font              = font  or Enum.Font.GothamSemiBold,
        BackgroundTransparency = 1,
        TextXAlignment    = Enum.TextXAlignment.Left,
        RichText          = true,
    })
    for k, v in pairs(props or {}) do l[k] = v end
    l.Parent = parent
    return l
end

local ConfigSystem = {}
ConfigSystem._flags = {}

function ConfigSystem:RegisterFlag(flag, default)
    if flag and flag ~= "" then
        ConfigSystem._flags[flag] = default
    end
end

function ConfigSystem:Save(folder, file)
    if not (writefile and isfile and makefolder) then return end
    pcall(function()
        if not isfolder(folder) then makefolder(folder) end
        writefile(folder .. "/" .. file .. ".json", game:GetService("HttpService"):JSONEncode(ConfigSystem._flags))
    end)
end

function ConfigSystem:Load(folder, file)
    if not (readfile and isfile) then return end
    pcall(function()
        local path = folder .. "/" .. file .. ".json"
        if isfile(path) then
            local data = game:GetService("HttpService"):JSONDecode(readfile(path))
            for k, v in pairs(data) do
                ConfigSystem._flags[k] = v
            end
        end
    end)
end

function ConfigSystem:Get(flag)
    return ConfigSystem._flags[flag]
end

function ConfigSystem:Set(flag, value)
    if flag then ConfigSystem._flags[flag] = value end
end

local NotifHolder = nil
local function EnsureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return end
    local sg = LP.PlayerGui:FindFirstChild("CrimsonNotifs")
        or CreateInstance("ScreenGui", { Name = "CrimsonNotifs", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = LP.PlayerGui })
    NotifHolder = CreateInstance("Frame", {
        Name = "Holder",
        Size = UDim2.new(0, 280, 1, 0),
        Position = UDim2.new(1, -290, 0, 0),
        BackgroundTransparency = 1,
        Parent = sg,
    })
    UIListLayout(NotifHolder, 8)
    UIPadding(10, 10, 0, 0, NotifHolder)
end

function Crimson:Notify(options)
    EnsureNotifHolder()
    local title    = options.Title   or "Crimson"
    local content  = options.Content or ""
    local duration = options.Duration or 4

    local card = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Theme.NotifBackground,
        ClipsDescendants = true,
        Parent           = NotifHolder,
    })
    UICorner(8, card)
    UIStroke(Theme.NotifAccent, 1.5, card)

    -- left accent bar
    CreateInstance("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Theme.NotifAccent,
        BorderSizePixel  = 0,
        Parent           = card,
    })

    local inner = CreateInstance("Frame", {
        Size             = UDim2.new(1, -12, 1, 0),
        Position         = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Parent           = card,
    })

    Label("<b>" .. title .. "</b>", 13, Theme.NotifText, Enum.Font.GothamBold, {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 8),
    }, inner)

    Label(content, 12, Theme.NotifSubText, Enum.Font.Gotham, {
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 28),
        TextWrapped = true,
    }, inner)

    -- progress bar
    local bar = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.NotifAccent,
        BorderSizePixel  = 0,
        Parent           = card,
    })
    UICorner(1, bar)

    card.Position = UDim2.new(1, 10, 0, 0)
    Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.25)
    Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration + 0.1, function()
        Tween(card, { Position = UDim2.new(1, 10, 0, 0) }, 0.2)
        task.wait(0.25)
        card:Destroy()
    end)
end

local function BuildToggle(parent, options)
    local name    = options.Name or "Toggle"
    local flag    = options.Flag or ""
    local cb      = options.Callback or function() end

    -- Resolve saved or default value
    local savedVal = ConfigSystem:Get(flag)
    local curVal   = (savedVal ~= nil) and savedVal or (options.CurrentValue == true)
    ConfigSystem:RegisterFlag(flag, curVal)

    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.ElementBackground,
        Parent           = parent,
    })
    UICorner(6, row)
    UIStroke(Theme.ElementStroke, 1, row)

    row.MouseEnter:Connect(function() Tween(row, { BackgroundColor3 = Theme.ElementBackgroundHover }, 0.12) end)
    row.MouseLeave:Connect(function() Tween(row, { BackgroundColor3 = Theme.ElementBackground }, 0.12) end)

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, row)

    -- track
    local track = CreateInstance("Frame", {
        Size             = UDim2.new(0, 40, 0, 20),
        Position         = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = curVal and Theme.ToggleOn or Theme.ToggleOff,
        Parent           = row,
    })
    UICorner(10, track)

    -- knob
    local knob = CreateInstance("Frame", {
        Size             = UDim2.new(0, 16, 0, 16),
        Position         = curVal and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Theme.ToggleKnob,
        Parent           = track,
    })
    UICorner(8, knob)

    local state = curVal

    local function SetState(val, skipCallback)
        state = val
        ConfigSystem:Set(flag, val)
        Tween(track, { BackgroundColor3 = val and Theme.ToggleOn or Theme.ToggleOff }, 0.18)
        Tween(knob, { Position = val and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2) }, 0.18)
        if not skipCallback then
            task.spawn(cb, val)
        end
    end

    if curVal then task.spawn(cb, curVal) end

    local btn = CreateInstance("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        Parent           = row,
    })
    btn.MouseButton1Click:Connect(function() SetState(not state) end)

    return {
        Set = function(_, val) SetState(val, false) end,
        Get = function() return state end,
    }
end

local function BuildButton(parent, options)
    local name = options.Name or "Button"
    local cb   = options.Callback or function() end

    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.ElementBackground,
        Parent           = parent,
    })
    UICorner(6, row)
    UIStroke(Theme.ElementStroke, 1, row)

    -- accent left line
    CreateInstance("Frame", {
        Size             = UDim2.new(0, 2, 0.6, 0),
        Position         = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        Parent           = row,
    })

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, row)

    local btn = CreateInstance("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        Parent           = row,
    })

    btn.MouseEnter:Connect(function() Tween(row, { BackgroundColor3 = Theme.ElementBackgroundHover }, 0.12) end)
    btn.MouseLeave:Connect(function() Tween(row, { BackgroundColor3 = Theme.ElementBackground }, 0.12) end)
    btn.MouseButton1Down:Connect(function() Tween(row, { BackgroundColor3 = Theme.AccentDim }, 0.08) end)
    btn.MouseButton1Up:Connect(function()
        Tween(row, { BackgroundColor3 = Theme.ElementBackgroundHover }, 0.12)
        task.spawn(cb)
    end)
end

local function BuildSlider(parent, options)
    local name  = options.Name      or "Slider"
    local min   = options.Range[1]  or 0
    local max   = options.Range[2]  or 100
    local inc   = options.Increment or 1
    local flag  = options.Flag      or ""
    local cb    = options.Callback  or function() end

    local savedVal = ConfigSystem:Get(flag)
    local curVal   = (savedVal ~= nil) and savedVal or (options.CurrentValue or min)
    ConfigSystem:RegisterFlag(flag, curVal)

    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = Theme.ElementBackground,
        Parent           = parent,
    })
    UICorner(6, row)
    UIStroke(Theme.ElementStroke, 1, row)

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size = UDim2.new(0.7, 0, 0, 22),
        Position = UDim2.new(0, 12, 0, 4),
    }, row)

    local valLabel = Label(tostring(curVal), 12, Theme.Accent, Enum.Font.GothamBold, {
        Size = UDim2.new(0.28, 0, 0, 22),
        Position = UDim2.new(0.7, 0, 0, 4),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    UIPadding(0, 0, 0, 10, valLabel)

    local trackBg = CreateInstance("Frame", {
        Size             = UDim2.new(1, -24, 0, 6),
        Position         = UDim2.new(0, 12, 0, 36),
        BackgroundColor3 = Theme.SliderTrack,
        Parent           = row,
    })
    UICorner(3, trackBg)

    local fill = CreateInstance("Frame", {
        Size             = UDim2.new((curVal - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.SliderFill,
        Parent           = trackBg,
    })
    UICorner(3, fill)

    local knob = CreateInstance("Frame", {
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new((curVal - min) / (max - min), -6, 0.5, -6),
        BackgroundColor3 = Theme.SliderKnob,
        Parent           = trackBg,
        ZIndex           = 5,
    })
    UICorner(6, knob)

    local sliding = false

    local function SetValue(val)
        val = math.clamp(math.round(val / inc) * inc, min, max)
        curVal = val
        ConfigSystem:Set(flag, val)
        local pct = (val - min) / (max - min)
        Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.05)
        Tween(knob, { Position = UDim2.new(pct, -6, 0.5, -6) }, 0.05)
        valLabel.Text = tostring(val)
        task.spawn(cb, val)
    end

    local function OnInput(input)
        local rel = (input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X
        SetValue(min + (max - min) * math.clamp(rel, 0, 1))
    end

    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            OnInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            OnInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)

    task.spawn(cb, curVal)

    return { Set = SetValue, Get = function() return curVal end }
end


local function BuildSection(parent, title)
    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent           = parent,
    })

    local line = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.SectionLine,
        BorderSizePixel  = 0,
        Parent           = row,
    })

    local bg = CreateInstance("Frame", {
        Size             = UDim2.new(0, #title * 7 + 16, 0, 18),
        Position         = UDim2.new(0, 10, 0.5, -9),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        Parent           = row,
    })

    Label(title:upper(), 11, Theme.SectionText, Enum.Font.GothamBold, {
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        LetterSpacing = 1,
    }, bg)
end


local function BuildDropdown(parent, options, windowScrollFrame)
    local name     = options.Name           or "Dropdown"
    local flag     = options.Flag           or ""
    local multi    = options.MultipleOptions or false
    local cb       = options.Callback       or function() end
    local opts     = options.Options        or {}

    local savedVal = ConfigSystem:Get(flag)
    local selected = {}
    if savedVal then
        if type(savedVal) == "table" then selected = savedVal
        elseif savedVal ~= "" then selected = { savedVal } end
    elseif options.CurrentOption then
        if type(options.CurrentOption) == "table" then selected = options.CurrentOption
        elseif options.CurrentOption ~= "" and options.CurrentOption ~= nil then selected = { options.CurrentOption } end
    end
    ConfigSystem:RegisterFlag(flag, selected)

    local open = false

    local wrapper = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.ElementBackground,
        ClipsDescendants = true,
        Parent           = parent,
    })
    UICorner(6, wrapper)
    UIStroke(Theme.ElementStroke, 1, wrapper)

    local header = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent           = wrapper,
    })

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size = UDim2.new(0.55, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, header)

    local preview = Label("None", 12, Theme.SubText, Enum.Font.Gotham, {
        Size = UDim2.new(0.35, 0, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, header)

    -- arrow
    local arrow = Label("▾", 14, Theme.Accent, Enum.Font.GothamBold, {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -24, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, header)

    local itemList = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        Position         = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Theme.InputBackground,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = wrapper,
    })
    UICorner(6, itemList)
    UIPadding(4, 4, 6, 6, itemList)
    local itemLayout = UIListLayout(itemList, 2)

    local function UpdatePreview()
        if #selected == 0 then
            preview.Text = "None"
        elseif #selected == 1 then
            preview.Text = selected[1]
        else
            preview.Text = selected[1] .. " +" .. (#selected - 1)
        end
    end

    UpdatePreview()

    local itemFrames = {}

    local function RebuildItems(newOpts)
        opts = newOpts or opts
        for _, f in pairs(itemFrames) do f:Destroy() end
        itemFrames = {}

        for _, opt in pairs(opts) do
            local isSelected = table.find(selected, opt) ~= nil
            local item = CreateInstance("TextButton", {
                Size             = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = isSelected and Theme.AccentDim or Theme.ElementBackground,
                Text             = "",
                Parent           = itemList,
            })
            UICorner(4, item)

            Label(opt, 12, isSelected and Theme.AccentBright or Theme.ElementText, Enum.Font.Gotham, {
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
            }, item)

            if isSelected then
                Label("✓", 11, Theme.AccentBright, Enum.Font.GothamBold, {
                    Size = UDim2.new(0, 18, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Center,
                }, item)
            end

            item.MouseButton1Click:Connect(function()
                if multi then
                    local idx = table.find(selected, opt)
                    if idx then table.remove(selected, idx)
                    else table.insert(selected, opt) end
                else
                    selected = { opt }
                    open = false
                    Tween(wrapper, { Size = UDim2.new(1, 0, 0, 42) }, 0.18)
                    arrow.Text = "▾"
                end
                ConfigSystem:Set(flag, selected)
                UpdatePreview()
                RebuildItems()
                local ret = multi and selected or (selected[1] or "")
                task.spawn(cb, ret)
            end)

            table.insert(itemFrames, item)
        end

        local h = math.min(#opts, 6) * 30 + 8
        itemList.Size = UDim2.new(1, 0, 0, open and h or 0)
    end

    RebuildItems()

    local headerBtn = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text = "",
        Parent = wrapper,
    })

    headerBtn.MouseButton1Click:Connect(function()
        open = not open
        local h = math.min(#opts, 6) * 30 + 8
        local targetH = open and (42 + h) or 42
        Tween(wrapper, { Size = UDim2.new(1, 0, 0, targetH) }, 0.2)
        Tween(itemList, { Size = UDim2.new(1, 0, 0, open and h or 0) }, 0.2)
        arrow.Text = open and "▴" or "▾"
    end)

    return {
        Refresh = function(_, newOpts, keepSelected)
            if not keepSelected then selected = {} end
            RebuildItems(newOpts)
            UpdatePreview()
        end,
        Set = function(_, val)
            selected = type(val) == "table" and val or { val }
            UpdatePreview()
            RebuildItems()
        end,
        Get = function() return multi and selected or (selected[1] or "") end,
    }
end

-- ── KEYBIND ─────────────────────────────────────────────────────
local function BuildKeybind(parent, options)
    local name     = options.Name           or "Keybind"
    local flag     = options.Flag           or ""
    local cb       = options.Callback       or function() end
    local hold     = options.HoldToInteract or false

    local savedKey = ConfigSystem:Get(flag)
    local curKey   = savedKey or options.CurrentKeybind or "F"
    ConfigSystem:RegisterFlag(flag, curKey)

    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.ElementBackground,
        Parent           = parent,
    })
    UICorner(6, row)
    UIStroke(Theme.ElementStroke, 1, row)

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size = UDim2.new(0.65, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, row)

    local keyBox = CreateInstance("TextButton", {
        Size             = UDim2.new(0, 60, 0, 26),
        Position         = UDim2.new(1, -68, 0.5, -13),
        BackgroundColor3 = Theme.InputBackground,
        Text             = "[" .. curKey .. "]",
        TextSize         = 11,
        TextColor3       = Theme.Accent,
        Font             = Enum.Font.GothamBold,
        Parent           = row,
    })
    UICorner(5, keyBox)
    UIStroke(Theme.InputStroke, 1, keyBox)

    local listening = false
    keyBox.MouseButton1Click:Connect(function()
        listening = true
        keyBox.Text = "..."
        keyBox.TextColor3 = Theme.SubText
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if listening then
            local keyName = input.KeyCode.Name
            if keyName ~= "Unknown" then
                curKey = keyName
                ConfigSystem:Set(flag, curKey)
                keyBox.Text = "[" .. curKey .. "]"
                keyBox.TextColor3 = Theme.Accent
                listening = false
            end
        elseif input.KeyCode.Name == curKey then
            if not hold then
                task.spawn(cb)
            end
        end
    end)

    if hold then
        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode.Name == curKey then
                task.spawn(cb)
            end
        end)
    end

    return { Get = function() return curKey end }
end

-- ── COLOR PICKER ────────────────────────────────────────────────
local function BuildColorPicker(parent, options)
    local name  = options.Name     or "Color"
    local flag  = options.Flag     or ""
    local cb    = options.Callback or function() end

    local savedC = ConfigSystem:Get(flag)
    local curColor
    if savedC and type(savedC) == "table" then
        curColor = Color3.fromRGB(savedC.r or 255, savedC.g or 255, savedC.b or 255)
    else
        curColor = options.Color or Color3.new(1, 1, 1)
    end
    ConfigSystem:RegisterFlag(flag, { r = math.round(curColor.R*255), g = math.round(curColor.G*255), b = math.round(curColor.B*255) })

    local open = false

    local wrapper = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.ElementBackground,
        ClipsDescendants = true,
        Parent           = parent,
    })
    UICorner(6, wrapper)
    UIStroke(Theme.ElementStroke, 1, wrapper)

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size = UDim2.new(0.7, 0, 0, 42),
        Position = UDim2.new(0, 12, 0, 0),
    }, wrapper)

    local swatch = CreateInstance("Frame", {
        Size             = UDim2.new(0, 28, 0, 22),
        Position         = UDim2.new(1, -40, 0.5, -11),
        BackgroundColor3 = curColor,
        Parent           = wrapper,
    })
    UICorner(5, swatch)
    UIStroke(Theme.ElementStroke, 1, swatch)

    -- RGB input panel
    local panel = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 90),
        Position         = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Theme.InputBackground,
        BorderSizePixel  = 0,
        Parent           = wrapper,
    })
    UIPadding(8, 8, 10, 10, panel)
    UIListLayout(panel, 5)

    local channels = { { "R", curColor.R }, { "G", curColor.G }, { "B", curColor.B } }
    local sliders = {}
    local rgb = { math.round(curColor.R*255), math.round(curColor.G*255), math.round(curColor.B*255) }

    local function ApplyColor()
        local c = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
        curColor = c
        swatch.BackgroundColor3 = c
        ConfigSystem:Set(flag, { r = rgb[1], g = rgb[2], b = rgb[3] })
        task.spawn(cb, c)
    end

    for i, ch in ipairs(channels) do
        local rowF = CreateInstance("Frame", {
            Size             = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Parent           = panel,
        })
        Label(ch[1], 11, Theme.SubText, Enum.Font.GothamBold, {
            Size = UDim2.new(0, 14, 1, 0),
        }, rowF)
        local trackBg = CreateInstance("Frame", {
            Size             = UDim2.new(1, -20, 0, 6),
            Position         = UDim2.new(0, 18, 0.5, -3),
            BackgroundColor3 = Theme.SliderTrack,
            Parent           = rowF,
        })
        UICorner(3, trackBg)
        local fill = CreateInstance("Frame", {
            Size             = UDim2.new(ch[2], 0, 1, 0),
            BackgroundColor3 = Theme.Accent,
            Parent           = trackBg,
        })
        UICorner(3, fill)

        local sliding2 = false
        local function SetCh(val)
            val = math.clamp(math.round(val * 255), 0, 255)
            rgb[i] = val
            fill.Size = UDim2.new(val / 255, 0, 1, 0)
            ApplyColor()
        end
        trackBg.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding2 = true
                local rel = (inp.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X
                SetCh(math.clamp(rel, 0, 1))
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if sliding2 and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = (inp.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X
                SetCh(math.clamp(rel, 0, 1))
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding2 = false end
        end)
        table.insert(sliders, fill)
    end

    local btn = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text = "",
        Parent = wrapper,
    })
    btn.MouseButton1Click:Connect(function()
        open = not open
        Tween(wrapper, { Size = UDim2.new(1, 0, 0, open and 132 or 42) }, 0.2)
    end)

    task.spawn(cb, curColor)
    return { Get = function() return curColor end, Set = function(_, c) curColor = c; swatch.BackgroundColor3 = c end }
end

-- ── LABEL ELEMENT ───────────────────────────────────────────────
local function BuildLabel(parent, options)
    local text  = options.Name or options.Text or ""
    Label(text, 12, Theme.SubText, Enum.Font.Gotham, {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 12, 0, 0),
    }, parent)
end

-- ── TEXT INPUT ──────────────────────────────────────────────────
local function BuildInput(parent, options)
    local name  = options.Name        or "Input"
    local flag  = options.Flag        or ""
    local ph    = options.PlaceholderText or "Type here..."
    local cb    = options.Callback    or function() end
    local rmb   = options.RemoveTextAfterFocusLost ~= false

    local savedVal = ConfigSystem:Get(flag)
    ConfigSystem:RegisterFlag(flag, savedVal or "")

    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.ElementBackground,
        Parent           = parent,
    })
    UICorner(6, row)
    UIStroke(Theme.ElementStroke, 1, row)

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, row)

    local box = CreateInstance("TextBox", {
        Size             = UDim2.new(0.5, -10, 0, 26),
        Position         = UDim2.new(0.48, 0, 0.5, -13),
        BackgroundColor3 = Theme.InputBackground,
        PlaceholderText  = ph,
        PlaceholderColor3 = Theme.SubText,
        Text             = savedVal or "",
        TextSize         = 12,
        TextColor3       = Theme.ElementText,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        Parent           = row,
    })
    UICorner(5, box)
    UIStroke(Theme.InputStroke, 1, box)
    UIPadding(0, 0, 6, 6, box)

    box.FocusLost:Connect(function(enter)
        if enter then
            ConfigSystem:Set(flag, box.Text)
            task.spawn(cb, box.Text)
            if rmb then box.Text = "" end
        end
    end)

    return { Get = function() return box.Text end, Set = function(_, v) box.Text = v end }
end

-- ═══════════════════════════════════════════════════════════════
-- TAB OBJECT
-- ═══════════════════════════════════════════════════════════════
local TabProto = {}
TabProto.__index = TabProto

function TabProto:CreateToggle(opts)     return BuildToggle(self._content, opts) end
function TabProto:CreateButton(opts)     BuildButton(self._content, opts) end
function TabProto:CreateSlider(opts)     return BuildSlider(self._content, opts) end
function TabProto:CreateSection(title)   BuildSection(self._content, title) end
function TabProto:CreateDropdown(opts)   return BuildDropdown(self._content, opts, self._scroll) end
function TabProto:CreateKeybind(opts)    return BuildKeybind(self._content, opts) end
function TabProto:CreateColorPicker(opts) return BuildColorPicker(self._content, opts) end
function TabProto:CreateLabel(opts)      BuildLabel(self._content, opts) end
function TabProto:CreateInput(opts)      return BuildInput(self._content, opts) end

-- ═══════════════════════════════════════════════════════════════
-- WINDOW OBJECT
-- ═══════════════════════════════════════════════════════════════
local WindowProto = {}
WindowProto.__index = WindowProto

function WindowProto:CreateTab(name, _icon)
    -- Tab button in sidebar
    local btn = CreateInstance("TextButton", {
        Size             = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = Theme.TabBackground,
        Text             = "",
        Parent           = self._sidebar,
    })
    UICorner(6, btn)

    local btnLabel = Label(name, 12, Theme.TabText, Enum.Font.GothamSemiBold, {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
    }, btn)

    local indicator = CreateInstance("Frame", {
        Size             = UDim2.new(0, 2, 0.55, 0),
        Position         = UDim2.new(0, 0, 0.22, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        Visible          = false,
        Parent           = btn,
    })
    UICorner(2, indicator)

    -- Content scroll frame
    local scroll = CreateInstance("ScrollingFrame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.ScrollBar,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible          = false,
        Parent           = self._contentArea,
    })

    local content = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent           = scroll,
    })
    UIPadding(8, 10, 8, 8, content)
    UIListLayout(content, 5)

    local tab = setmetatable({ _content = content, _scroll = scroll }, TabProto)
    table.insert(self._tabs, { btn = btn, scroll = scroll, label = btnLabel, indicator = indicator, tab = tab })

    -- Auto-select first tab
    if #self._tabs == 1 then
        self:_SelectTab(1)
    end

    btn.MouseButton1Click:Connect(function()
        for i, t in ipairs(self._tabs) do
            if t.btn == btn then self:_SelectTab(i) return end
        end
    end)

    return tab
end

function WindowProto:_SelectTab(idx)
    for i, t in ipairs(self._tabs) do
        local sel = (i == idx)
        t.scroll.Visible = sel
        Tween(t.btn, { BackgroundColor3 = sel and Theme.TabBackgroundSelected or Theme.TabBackground }, 0.15)
        t.label.TextColor3 = sel and Theme.TabTextSelected or Theme.TabText
        t.indicator.Visible = sel
    end
end

function WindowProto:Notify(opts)
    Crimson:Notify(opts)
end

function WindowProto:Destroy()
    if self._gui then self._gui:Destroy() end
end

function WindowProto:LoadConfiguration()
    if self._cfgFolder and self._cfgFile then
        ConfigSystem:Load(self._cfgFolder, self._cfgFile)
    end
end

function WindowProto:ResetConfig()
    ConfigSystem._flags = {}
    if self._cfgFolder and self._cfgFile then
        pcall(function()
            if writefile then
                writefile(self._cfgFolder .. "/" .. self._cfgFile .. ".json", "{}")
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- CREATE WINDOW  (main entry point)
-- ═══════════════════════════════════════════════════════════════
function Crimson:CreateWindow(options)
    local title       = options.Name             or "Crimson"
    local loadTitle   = options.LoadingTitle     or title
    local loadSub     = options.LoadingSubtitle  or "Loading..."
    local cfgSaving   = options.ConfigurationSaving or {}
    local cfgFolder   = cfgSaving.FolderName or "CrimsonConfigs"
    local cfgFile     = cfgSaving.FileName   or "Config"
    local cfgEnabled  = cfgSaving.Enabled    or false

    -- Merge custom theme if provided
    if options.Theme then
        for k, v in pairs(options.Theme) do
            -- We keep our dark-red Crimson theme but allow overrides
        end
    end

    -- ── Screen GUI ───────────────────────────────────────────────
    local sg = CreateInstance("ScreenGui", {
        Name             = "CrimsonGUI",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        Parent           = LP.PlayerGui,
    })

    -- ── Loading Screen ───────────────────────────────────────────
    local loadScreen = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(4, 0, 0),
        Parent           = sg,
        ZIndex           = 100,
    })

    -- Scanline effect
    for i = 1, 30 do
        CreateInstance("Frame", {
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, i / 30, 0),
            BackgroundColor3 = Color3.fromRGB(30, 0, 0),
            BackgroundTransparency = 0.85,
            BorderSizePixel  = 0,
            ZIndex           = 101,
            Parent           = loadScreen,
        })
    end

    local loadTitle_L = Label("<b>" .. loadTitle .. "</b>", 28, Theme.AccentBright, Enum.Font.GothamBlack, {
        Size = UDim2.new(0.7, 0, 0, 40),
        Position = UDim2.new(0.15, 0, 0.38, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 102,
    }, loadScreen)

    local loadSub_L = Label(loadSub, 14, Theme.SubText, Enum.Font.Gotham, {
        Size = UDim2.new(0.5, 0, 0, 24),
        Position = UDim2.new(0.25, 0, 0.48, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 102,
    }, loadScreen)

    -- Loading bar
    local barBg = CreateInstance("Frame", {
        Size             = UDim2.new(0.4, 0, 0, 4),
        Position         = UDim2.new(0.3, 0, 0.56, 0),
        BackgroundColor3 = Theme.SliderTrack,
        ZIndex           = 102,
        Parent           = loadScreen,
    })
    UICorner(2, barBg)

    local barFill = CreateInstance("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        ZIndex           = 103,
        Parent           = barBg,
    })
    UICorner(2, barFill)

    -- Animate loading bar
    task.spawn(function()
        Tween(barFill, { Size = UDim2.new(1, 0, 1, 0) }, 1.2, Enum.EasingStyle.Quart)
        task.wait(1.3)
        Tween(loadScreen, { BackgroundTransparency = 1 }, 0.4)
        for _, obj in pairs(loadScreen:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("TextLabel") then
                Tween(obj, { BackgroundTransparency = 1, TextTransparency = 1 }, 0.4)
            end
        end
        task.wait(0.5)
        loadScreen:Destroy()
    end)

    -- ── Main Window Frame ─────────────────────────────────────────
    local gui = CreateInstance("Frame", {
        Name             = "CrimsonWindow",
        Size             = UDim2.new(0, 620, 0, 420),
        Position         = UDim2.new(0.5, -310, 0.5, -210),
        BackgroundColor3 = Theme.Background,
        Parent           = sg,
    })
    UICorner(10, gui)
    UIStroke(Theme.Border, 1.5, gui)

    -- ── Top Bar ───────────────────────────────────────────────────
    local topbar = CreateInstance("Frame", {
        Name             = "Topbar",
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Topbar,
        Parent           = gui,
    })
    UICorner(10, topbar)

    -- Cover bottom corners of topbar
    CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0.5, 0),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Topbar,
        BorderSizePixel  = 0,
        Parent           = topbar,
    })

    -- accent line under topbar
    CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        Parent           = topbar,
    })

    -- Title
    Label("🔴  " .. title:upper(), 13, Theme.AccentBright, Enum.Font.GothamBlack, {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        LetterSpacing = 2,
    }, topbar)

    -- Minimize / Close buttons
    local closeBtn = CreateInstance("TextButton", {
        Size             = UDim2.new(0, 16, 0, 16),
        Position         = UDim2.new(1, -24, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(200, 30, 30),
        Text             = "",
        Parent           = topbar,
    })
    UICorner(8, closeBtn)

    local minBtn = CreateInstance("TextButton", {
        Size             = UDim2.new(0, 16, 0, 16),
        Position         = UDim2.new(1, -46, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(140, 100, 0),
        Text             = "",
        Parent           = topbar,
    })
    UICorner(8, minBtn)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Tween(gui, { Size = minimized and UDim2.new(0, 620, 0, 36) or UDim2.new(0, 620, 0, 420) }, 0.22)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(gui, { Size = UDim2.new(0, 0, 0, 0) }, 0.2)
        task.wait(0.25)
        sg:Destroy()
    end)

    MakeDraggable(gui, topbar)

    -- ── Background image layer ────────────────────────────────────
    local bgImage = CreateInstance("ImageLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ImageTransparency = 0.75,
        ScaleType        = Enum.ScaleType.Crop,
        Image            = "",
        ZIndex           = 0,
        Parent           = gui,
    })

    -- ── Body ──────────────────────────────────────────────────────
    local body = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 1, -36),
        Position         = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent           = gui,
    })

    -- ── Sidebar ───────────────────────────────────────────────────
    local sidebar = CreateInstance("ScrollingFrame", {
        Size             = UDim2.new(0, 148, 1, 0),
        BackgroundColor3 = Theme.TabBackground,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.ScrollBar,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent           = body,
    })
    UICorner(10, sidebar)
    -- cover right corners
    CreateInstance("Frame", {
        Size             = UDim2.new(0, 12, 1, 0),
        Position         = UDim2.new(1, -12, 0, 0),
        BackgroundColor3 = Theme.TabBackground,
        BorderSizePixel  = 0,
        Parent           = sidebar,
    })

    local sidebarContent = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent           = sidebar,
    })
    UIPadding(8, 8, 4, 4, sidebarContent)
    UIListLayout(sidebarContent, 4)

    -- vertical divider
    CreateInstance("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(0, 148, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        Parent           = body,
    })

    -- ── Content area ─────────────────────────────────────────────
    local contentArea = CreateInstance("Frame", {
        Size             = UDim2.new(1, -150, 1, 0),
        Position         = UDim2.new(0, 150, 0, 0),
        BackgroundTransparency = 1,
        Parent           = body,
    })

    -- ── Settings (background image) built-in section ─────────────
    -- Added to every window as the last item in the sidebar visually
    -- but as a special tab accessible via a gear icon row at the bottom

    local settingsRow = CreateInstance("TextButton", {
        Size             = UDim2.new(1, -8, 0, 30),
        BackgroundColor3 = Theme.AccentDim,
        Text             = "",
        LayoutOrder      = 9999,
        Parent           = sidebarContent,
    })
    UICorner(6, settingsRow)

    Label("⚙  BG Image", 11, Theme.SubText, Enum.Font.GothamSemiBold, {
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, settingsRow)

    -- Floating BG image editor
    local bgEditor = CreateInstance("Frame", {
        Size             = UDim2.new(0, 280, 0, 110),
        Position         = UDim2.new(0, 160, 1, -120),
        BackgroundColor3 = Theme.Topbar,
        Visible          = false,
        ZIndex           = 20,
        Parent           = gui,
    })
    UICorner(8, bgEditor)
    UIStroke(Theme.Border, 1, bgEditor)
    UIPadding(10, 10, 10, 10, bgEditor)
    UIListLayout(bgEditor, 6)

    Label("Custom Background Image", 12, Theme.AccentBright, Enum.Font.GothamBold, {
        Size = UDim2.new(1, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 21,
    }, bgEditor)

    Label("Paste rbxassetid:// or image URL", 10, Theme.SubText, Enum.Font.Gotham, {
        Size = UDim2.new(1, 0, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 21,
    }, bgEditor)

    local bgInput = CreateInstance("TextBox", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Theme.InputBackground,
        PlaceholderText  = "rbxassetid://123456789",
        PlaceholderColor3 = Theme.SubText,
        Text             = "",
        TextSize         = 11,
        TextColor3       = Theme.ElementText,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex           = 21,
        Parent           = bgEditor,
    })
    UICorner(5, bgInput)
    UIStroke(Theme.InputStroke, 1, bgInput)
    UIPadding(0, 0, 6, 6, bgInput)

    local bgBtnRow = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        ZIndex           = 21,
        Parent           = bgEditor,
    })
    UIListLayout(bgBtnRow, 6, nil, Enum.FillDirection.Horizontal)

    local function MakeSmallBtn(text, color, parentF, onClick)
        local b = CreateInstance("TextButton", {
            Size             = UDim2.new(0.48, 0, 1, 0),
            BackgroundColor3 = color,
            Text             = text,
            TextSize         = 11,
            TextColor3       = Color3.new(1,1,1),
            Font             = Enum.Font.GothamSemiBold,
            ZIndex           = 22,
            Parent           = parentF,
        })
        UICorner(5, b)
        b.MouseButton1Click:Connect(onClick)
        return b
    end

    local opacitySliderBg = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = Theme.SliderTrack,
        ZIndex           = 21,
        Parent           = bgEditor,
    })
    UICorner(5, opacitySliderBg)
    local opacityFill = CreateInstance("Frame", {
        Size             = UDim2.new(0.25, 0, 1, 0),  -- default ~75% opacity = 0.25 transparency
        BackgroundColor3 = Theme.Accent,
        ZIndex           = 22,
        Parent           = opacitySliderBg,
    })
    UICorner(5, opacityFill)
    Label("Opacity", 9, Theme.SubText, Enum.Font.Gotham, {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, -12),
        ZIndex = 21,
    }, opacitySliderBg)

    -- opacity slider interaction
    local opSliding = false
    opacitySliderBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            opSliding = true
            local rel = math.clamp((inp.Position.X - opacitySliderBg.AbsolutePosition.X) / opacitySliderBg.AbsoluteSize.X, 0, 1)
            opacityFill.Size = UDim2.new(rel, 0, 1, 0)
            bgImage.ImageTransparency = 1 - rel
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if opSliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((inp.Position.X - opacitySliderBg.AbsolutePosition.X) / opacitySliderBg.AbsoluteSize.X, 0, 1)
            opacityFill.Size = UDim2.new(rel, 0, 1, 0)
            bgImage.ImageTransparency = 1 - rel
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then opSliding = false end
    end)

    MakeSmallBtn("Apply", Theme.Accent, bgBtnRow, function()
        local id = bgInput.Text:match("(%d+)") or ""
        if id ~= "" then
            bgImage.Image = "rbxassetid://" .. id
        else
            bgImage.Image = bgInput.Text
        end
    end)

    MakeSmallBtn("Clear", Theme.AccentDim, bgBtnRow, function()
        bgImage.Image = ""
        bgInput.Text  = ""
    end)

    settingsRow.MouseButton1Click:Connect(function()
        bgEditor.Visible = not bgEditor.Visible
    end)

    -- ── Key toggle (Insert to show/hide) ─────────────────────────
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            gui.Visible = not gui.Visible
        end
    end)

    -- ── Window object ─────────────────────────────────────────────
    local window = setmetatable({
        _gui         = sg,
        _sidebar     = sidebarContent,
        _contentArea = contentArea,
        _tabs        = {},
        _cfgFolder   = cfgEnabled and cfgFolder or nil,
        _cfgFile     = cfgEnabled and cfgFile   or nil,
    }, WindowProto)

    if cfgEnabled then
        ConfigSystem:Load(cfgFolder, cfgFile)
    end

    -- Auto-save on value change every 60s
    if cfgEnabled then
        task.spawn(function()
            while sg.Parent do
                task.wait(60)
                ConfigSystem:Save(cfgFolder, cfgFile)
            end
        end)
    end

    return window
end

-- ═══════════════════════════════════════════════════════════════
-- STATIC METHODS (mirror Rayfield API)
-- ═══════════════════════════════════════════════════════════════
Crimson.Notify = Crimson.Notify  -- already defined above

function Crimson:Destroy()
    local g = LP.PlayerGui:FindFirstChild("CrimsonGUI")
    if g then g:Destroy() end
    local n = LP.PlayerGui:FindFirstChild("CrimsonNotifs")
    if n then n:Destroy() end
end

-- ═══════════════════════════════════════════════════════════════
-- RETURN
-- ═══════════════════════════════════════════════════════════════
return Crimson

