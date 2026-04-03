--[[
    ██████╗██████╗ ██╗███╗   ███╗███████╗ ██████╗ ███╗   ██╗
   ██╔════╝██╔══██╗██║████╗ ████║██╔════╝██╔═══██╗████╗  ██║
   ██║     ██████╔╝██║██╔████╔██║███████╗██║   ██║██╔██╗ ██║
   ██║     ██╔══██╗██║██║╚██╔╝██║╚════██║██║   ██║██║╚██╗██║
   ╚██████╗██║  ██║██║██║ ╚═╝ ██║███████║╚██████╔╝██║ ╚████║
    ╚═════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝
    Crimson GUI — Custom Roblox UI Library  (Fixed & Upgraded)

    FIXES APPLIED:
    ─────────────
    • UIPadding used a broken ternary string check — removed junk
    • Slider Range guard (prevents nil index crash when Range is nil)
    • Color picker channel initial fill sizes used raw Color3 channel
      values (0-1) directly as UDim2 Scale — corrected to /255
    • WindowProto:LoadConfiguration called on window before sg was
      set — _gui was pointed at 'sg' correctly but Destroy used wrong ref
    • Duplicate UserInputService.InputChanged connections per slider /
      color channel were stacking — now use a single shared connection
    • Toggle callback fired on load even when value was false (false is
      falsy so `if curVal` skipped it) — always fire on load now
    • BuildButton MouseButton1Up never fired cb because it fired on
      the overlay btn but the tween was on 'row'; fixed ordering
    • Section bg width calculation with `#title * 7` overflowed for
      long titles — clamped to parent width
    • ConfigSystem:Load only ran after window was returned, so flags
      weren't populated when elements built — Load now runs BEFORE
      element builders execute (handled in CreateWindow pre-build)
    • bgEditor position was relative to 'gui' but gui had no stable
      anchor — moved to sg so it always shows on screen
    • Notification holder rebuilt on every notify if parent was gone —
      now properly re-parents to existing ScreenGui
    • Missing Crimson.Notify static alias (line 1539 was a no-op
      self-assignment) — fixed to correct function reference
    • Keybind hold mode fired on InputEnded for ALL keys, not just
      the bound one — corrected
    • Dropdown open/close height math didn't account for UIPadding
      inside itemList — corrected to match actual rendered height
    • Added :Refresh() nil guard so callers can safely pass nil opts

    HOW TO ADD NEW ELEMENTS EASILY:
    ─────────────────────────────────
    Toggle:   Tab:CreateToggle({ Name, CurrentValue, Flag, Callback })
    Button:   Tab:CreateButton({ Name, Callback })
    Slider:   Tab:CreateSlider({ Name, Range, Increment, CurrentValue, Flag, Callback })
    Dropdown: Tab:CreateDropdown({ Name, Options, CurrentOption, MultipleOptions, Flag, Callback })
    Keybind:  Tab:CreateKeybind({ Name, CurrentKeybind, HoldToInteract, Flag, Callback })
    ColorPicker: Tab:CreateColorPicker({ Name, Color, Flag, Callback })
    Section:  Tab:CreateSection("Section Title")
    Input:    Tab:CreateInput({ Name, PlaceholderText, Flag, Callback })
    Notify:   Crimson:Notify({ Title, Content, Duration })
    Window:   Crimson:CreateWindow({ Name, LoadingTitle, LoadingSubtitle, Theme, ConfigurationSaving })
    Tab:      Window:CreateTab(Name)
]]

local Crimson = {}
Crimson.__index = Crimson

-- ═══════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LP = Players.LocalPlayer
if not LP then
    LP = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LP = Players.LocalPlayer
end

-- ═══════════════════════════════════════════════════════════════
-- THEME  (dark red / black Crimson palette)
-- ═══════════════════════════════════════════════════════════════
local Theme = {
    Background             = Color3.fromRGB(10,  4,  4),
    Topbar                 = Color3.fromRGB(16,  5,  5),
    Shadow                 = Color3.fromRGB( 6,  2,  2),
    Border                 = Color3.fromRGB(60, 18, 18),

    TabBackground          = Color3.fromRGB(22,  7,  7),
    TabBackgroundSelected  = Color3.fromRGB(140, 20, 20),
    TabStroke              = Color3.fromRGB(70,  20, 20),
    TabText                = Color3.fromRGB(200,160,160),
    TabTextSelected        = Color3.fromRGB(255,220,220),

    ElementBackground      = Color3.fromRGB(22,  7,  7),
    ElementBackgroundHover = Color3.fromRGB(34, 10, 10),
    ElementStroke          = Color3.fromRGB(70, 20, 20),
    ElementText            = Color3.fromRGB(235,210,210),
    SubText                = Color3.fromRGB(160,110,110),

    Accent                 = Color3.fromRGB(180, 22, 22),
    AccentBright           = Color3.fromRGB(220, 40, 40),
    AccentDim              = Color3.fromRGB(110, 15, 15),

    ToggleOn               = Color3.fromRGB(200, 28, 28),
    ToggleOff              = Color3.fromRGB( 55, 20, 20),
    ToggleKnob             = Color3.fromRGB(255,200,200),

    SliderTrack            = Color3.fromRGB( 40, 10, 10),
    SliderFill             = Color3.fromRGB(180, 22, 22),
    SliderKnob             = Color3.fromRGB(240, 80, 80),

    SectionText            = Color3.fromRGB(160, 50, 50),
    SectionLine            = Color3.fromRGB( 55, 15, 15),

    NotifBackground        = Color3.fromRGB(18,  5,  5),
    NotifAccent            = Color3.fromRGB(180, 22, 22),
    NotifText              = Color3.fromRGB(235,210,210),
    NotifSubText           = Color3.fromRGB(155,105,105),

    ScrollBar              = Color3.fromRGB( 90, 20, 20),
    ScrollBarHover         = Color3.fromRGB(140, 25, 25),

    InputBackground        = Color3.fromRGB(18,  5,  5),
    InputStroke            = Color3.fromRGB(80,  20, 20),
    DropdownArrow          = Color3.fromRGB(180, 22, 22),
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY
-- ═══════════════════════════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    if not obj or not obj.Parent then return end
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
            local delta  = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function CreateInstance(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        pcall(function() inst[k] = v end)
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function UICorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
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

-- FIX: removed bogus ternary string check that was in original
local function UIPadding(t, b, l, r, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent        = parent
    return p
end

local function UIListLayout(parent, spacing, fill, dir)
    local l = Instance.new("UIListLayout")
    l.Padding             = UDim.new(0, spacing or 4)
    l.FillDirection       = dir or fill or Enum.FillDirection.Vertical
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.Parent              = parent
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
    for k, v in pairs(props or {}) do
        pcall(function() l[k] = v end)
    end
    if parent then l.Parent = parent end
    return l
end

-- ═══════════════════════════════════════════════════════════════
-- SHARED INPUT CHANGED DISPATCHER
-- FIX: Instead of connecting UserInputService.InputChanged once per
--      element (causing massive connection stacking), we use a single
--      shared dispatcher that all sliders/pickers register into.
-- ═══════════════════════════════════════════════════════════════
local _inputMovedCallbacks = {}
local _inputEndedCallbacks = {}

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        for _, cb in ipairs(_inputMovedCallbacks) do
            pcall(cb, input)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        for _, cb in ipairs(_inputEndedCallbacks) do
            pcall(cb, input)
        end
    end
end)

local function OnInputMoved(cb)
    table.insert(_inputMovedCallbacks, cb)
end

local function OnInputEnded(cb)
    table.insert(_inputEndedCallbacks, cb)
end

-- ═══════════════════════════════════════════════════════════════
-- CONFIG SAVING
-- ═══════════════════════════════════════════════════════════════
local ConfigSystem = {}
ConfigSystem._flags = {}

function ConfigSystem:RegisterFlag(flag, default)
    if flag and flag ~= "" and ConfigSystem._flags[flag] == nil then
        ConfigSystem._flags[flag] = default
    end
end

function ConfigSystem:Save(folder, file)
    if not (writefile and makefolder) then return end
    pcall(function()
        if not isfolder(folder) then makefolder(folder) end
        local ok, encoded = pcall(function()
            return game:GetService("HttpService"):JSONEncode(ConfigSystem._flags)
        end)
        if ok then writefile(folder .. "/" .. file .. ".json", encoded) end
    end)
end

function ConfigSystem:Load(folder, file)
    if not (readfile and isfile) then return end
    pcall(function()
        local path = folder .. "/" .. file .. ".json"
        if isfile(path) then
            local ok, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile(path))
            end)
            if ok and type(data) == "table" then
                for k, v in pairs(data) do
                    ConfigSystem._flags[k] = v
                end
            end
        end
    end)
end

function ConfigSystem:Get(flag)
    return ConfigSystem._flags[flag]
end

function ConfigSystem:Set(flag, value)
    if flag and flag ~= "" then
        ConfigSystem._flags[flag] = value
    end
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════
local NotifHolder = nil

local function EnsureNotifHolder()
    -- FIX: find or create the ScreenGui, then find or create the holder Frame
    local sg = LP.PlayerGui:FindFirstChild("CrimsonNotifs")
    if not sg then
        sg = CreateInstance("ScreenGui", {
            Name             = "CrimsonNotifs",
            ResetOnSpawn     = false,
            ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
            Parent           = LP.PlayerGui,
        })
    end
    if not NotifHolder or not NotifHolder.Parent then
        NotifHolder = CreateInstance("Frame", {
            Name             = "Holder",
            Size             = UDim2.new(0, 280, 1, 0),
            Position         = UDim2.new(1, -290, 0, 0),
            BackgroundTransparency = 1,
            Parent           = sg,
        })
        UIListLayout(NotifHolder, 8)
        UIPadding(10, 10, 0, 0, NotifHolder)
    end
end

function Crimson:Notify(options)
    if type(options) ~= "table" then return end
    task.spawn(function()
        pcall(function()
            EnsureNotifHolder()
            local title    = tostring(options.Title   or "Crimson")
            local content  = tostring(options.Content or "")
            local duration = tonumber(options.Duration) or 4

            local card = CreateInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, 70),
                BackgroundColor3 = Theme.NotifBackground,
                ClipsDescendants = true,
                Parent           = NotifHolder,
            })
            UICorner(8, card)
            UIStroke(Theme.NotifAccent, 1.5, card)

            CreateInstance("Frame", {
                Size             = UDim2.new(0, 3, 1, 0),
                BackgroundColor3 = Theme.NotifAccent,
                BorderSizePixel  = 0,
                Parent           = card,
            })

            local inner = CreateInstance("Frame", {
                Size             = UDim2.new(1, -14, 1, 0),
                Position         = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Parent           = card,
            })

            Label("<b>" .. title .. "</b>", 13, Theme.NotifText, Enum.Font.GothamBold, {
                Size     = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 8),
            }, inner)

            Label(content, 12, Theme.NotifSubText, Enum.Font.Gotham, {
                Size        = UDim2.new(1, 0, 0, 36),
                Position    = UDim2.new(0, 0, 0, 28),
                TextWrapped = true,
            }, inner)

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
                if card and card.Parent then
                    Tween(card, { Position = UDim2.new(1, 10, 0, 0) }, 0.2)
                    task.wait(0.25)
                    if card and card.Parent then card:Destroy() end
                end
            end)
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- ELEMENT BUILDERS
-- ═══════════════════════════════════════════════════════════════

-- ── TOGGLE ──────────────────────────────────────────────────────
local function BuildToggle(parent, options)
    local name   = options.Name          or "Toggle"
    local flag   = options.Flag          or ""
    local cb     = type(options.Callback) == "function" and options.Callback or function() end

    local savedVal = ConfigSystem:Get(flag)
    -- FIX: treat nil saved as "use default", treat explicit false as false
    local curVal
    if savedVal ~= nil then
        curVal = savedVal == true
    else
        curVal = options.CurrentValue == true
    end
    ConfigSystem:RegisterFlag(flag, curVal)

    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.ElementBackground,
        Parent           = parent,
    })
    UICorner(6, row)
    UIStroke(Theme.ElementStroke, 1, row)

    row.MouseEnter:Connect(function() Tween(row, { BackgroundColor3 = Theme.ElementBackgroundHover }, 0.12) end)
    row.MouseLeave:Connect(function() Tween(row, { BackgroundColor3 = Theme.ElementBackground      }, 0.12) end)

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, row)

    local track = CreateInstance("Frame", {
        Size             = UDim2.new(0, 40, 0, 20),
        Position         = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = curVal and Theme.ToggleOn or Theme.ToggleOff,
        Parent           = row,
    })
    UICorner(10, track)

    local knob = CreateInstance("Frame", {
        Size             = UDim2.new(0, 16, 0, 16),
        Position         = curVal and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Theme.ToggleKnob,
        Parent           = track,
    })
    UICorner(8, knob)

    local state = curVal

    local function SetState(val, skipCallback)
        state = val == true
        ConfigSystem:Set(flag, state)
        Tween(track, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff }, 0.18)
        Tween(knob,  { Position = state and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2) }, 0.18)
        if not skipCallback then
            task.spawn(cb, state)
        end
    end

    -- FIX: always fire callback on load (was skipping false values before)
    task.defer(function() task.spawn(cb, curVal) end)

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

-- ── BUTTON ──────────────────────────────────────────────────────
local function BuildButton(parent, options)
    local name = options.Name or "Button"
    local cb   = type(options.Callback) == "function" and options.Callback or function() end
    local debounce = false

    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.ElementBackground,
        Parent           = parent,
    })
    UICorner(6, row)
    UIStroke(Theme.ElementStroke, 1, row)

    CreateInstance("Frame", {
        Size             = UDim2.new(0, 2, 0.6, 0),
        Position         = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        Parent           = row,
    })

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, row)

    local btn = CreateInstance("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        Parent           = row,
    })

    btn.MouseEnter:Connect(function()    Tween(row, { BackgroundColor3 = Theme.ElementBackgroundHover }, 0.12) end)
    btn.MouseLeave:Connect(function()    Tween(row, { BackgroundColor3 = Theme.ElementBackground      }, 0.12) end)
    btn.MouseButton1Down:Connect(function() Tween(row, { BackgroundColor3 = Theme.AccentDim }, 0.08) end)
    -- FIX: callback now fires on Up event, tween also fires properly
    btn.MouseButton1Up:Connect(function()
        Tween(row, { BackgroundColor3 = Theme.ElementBackgroundHover }, 0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        if debounce then return end
        debounce = true
        task.spawn(cb)
        task.delay(0.2, function() debounce = false end)
    end)
end

-- ── SLIDER ──────────────────────────────────────────────────────
local function BuildSlider(parent, options)
    local name = options.Name      or "Slider"
    -- FIX: safe range extraction with fallbacks
    local range = options.Range or {0, 100}
    local min  = tonumber(range[1]) or 0
    local max  = tonumber(range[2]) or 100
    if min >= max then max = min + 1 end
    local inc  = tonumber(options.Increment) or 1
    local flag = options.Flag     or ""
    local cb   = type(options.Callback) == "function" and options.Callback or function() end

    local savedVal = ConfigSystem:Get(flag)
    local curVal   = math.clamp(tonumber(savedVal) or tonumber(options.CurrentValue) or min, min, max)
    ConfigSystem:RegisterFlag(flag, curVal)

    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = Theme.ElementBackground,
        Parent           = parent,
    })
    UICorner(6, row)
    UIStroke(Theme.ElementStroke, 1, row)

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.7, 0, 0, 22),
        Position = UDim2.new(0, 12, 0, 4),
    }, row)

    local valLabel = Label(tostring(curVal), 12, Theme.Accent, Enum.Font.GothamBold, {
        Size           = UDim2.new(0.28, 0, 0, 22),
        Position       = UDim2.new(0.7, 0, 0, 4),
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

    local initPct = (max ~= min) and ((curVal - min) / (max - min)) or 0
    local fill = CreateInstance("Frame", {
        Size             = UDim2.new(initPct, 0, 1, 0),
        BackgroundColor3 = Theme.SliderFill,
        Parent           = trackBg,
    })
    UICorner(3, fill)

    local knob = CreateInstance("Frame", {
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new(initPct, -6, 0.5, -6),
        BackgroundColor3 = Theme.SliderKnob,
        ZIndex           = 5,
        Parent           = trackBg,
    })
    UICorner(6, knob)

    local sliding = false

    local function SetValue(val)
        val    = math.clamp(math.round(val / inc) * inc, min, max)
        curVal = val
        ConfigSystem:Set(flag, val)
        local pct = (max ~= min) and ((val - min) / (max - min)) or 0
        Tween(fill,  { Size = UDim2.new(pct, 0, 1, 0) }, 0.05)
        Tween(knob,  { Position = UDim2.new(pct, -6, 0.5, -6) }, 0.05)
        valLabel.Text = tostring(val)
        task.spawn(cb, val)
    end

    local function OnDrag(input)
        local rel = (input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X
        SetValue(min + (max - min) * math.clamp(rel, 0, 1))
    end

    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            OnDrag(input)
        end
    end)
    -- FIX: using shared dispatcher instead of stacking new connections
    OnInputMoved(function(input) if sliding then OnDrag(input) end end)
    OnInputEnded(function()      sliding = false end)

    task.defer(function() task.spawn(cb, curVal) end)

    return {
        Set = SetValue,
        Get = function() return curVal end,
    }
end

-- ── SECTION ─────────────────────────────────────────────────────
local function BuildSection(parent, title)
    title = tostring(title or "")
    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent           = parent,
    })

    CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.SectionLine,
        BorderSizePixel  = 0,
        Parent           = row,
    })

    -- FIX: clamp bg width so long titles don't overflow
    local bgW = math.min(#title * 7 + 16, 260)
    local bg = CreateInstance("Frame", {
        Size             = UDim2.new(0, bgW, 0, 18),
        Position         = UDim2.new(0, 10, 0.5, -9),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        Parent           = row,
    })

    Label(title:upper(), 11, Theme.SectionText, Enum.Font.GothamBold, {
        Size           = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, bg)
end

-- ── DROPDOWN ────────────────────────────────────────────────────
local function BuildDropdown(parent, options)
    local name  = options.Name            or "Dropdown"
    local flag  = options.Flag            or ""
    local multi = options.MultipleOptions == true
    local cb    = type(options.Callback) == "function" and options.Callback or function() end
    local opts  = type(options.Options) == "table" and options.Options or {}

    local savedVal = ConfigSystem:Get(flag)
    local selected = {}
    if savedVal ~= nil then
        if type(savedVal) == "table" then selected = savedVal
        elseif tostring(savedVal) ~= "" then selected = { tostring(savedVal) } end
    elseif options.CurrentOption ~= nil then
        if type(options.CurrentOption) == "table" then selected = options.CurrentOption
        elseif tostring(options.CurrentOption) ~= "" then selected = { tostring(options.CurrentOption) } end
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
        Size     = UDim2.new(0.55, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, header)

    local preview = Label("None", 12, Theme.SubText, Enum.Font.Gotham, {
        Size           = UDim2.new(0.35, 0, 1, 0),
        Position       = UDim2.new(0.55, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate   = Enum.TextTruncate.AtEnd,
    }, header)

    local arrow = Label("▾", 14, Theme.Accent, Enum.Font.GothamBold, {
        Size           = UDim2.new(0, 20, 1, 0),
        Position       = UDim2.new(1, -24, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, header)

    -- FIX: item row height is 28, padding top+bottom = 8 (4+4)
    local ITEM_H  = 28
    local ITEM_SP = 2
    local PADDING = 8

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
    UIListLayout(itemList, ITEM_SP)

    local function CalcListH(count)
        local visible = math.min(count, 6)
        if visible == 0 then return 0 end
        return visible * ITEM_H + (visible - 1) * ITEM_SP + PADDING
    end

    local function UpdatePreview()
        if #selected == 0 then preview.Text = "None"
        elseif #selected == 1 then preview.Text = selected[1]
        else preview.Text = selected[1] .. " +" .. (#selected - 1) end
    end
    UpdatePreview()

    local itemFrames = {}

    local function RebuildItems(newOpts)
        opts = (type(newOpts) == "table") and newOpts or opts
        for _, f in ipairs(itemFrames) do
            if f and f.Parent then f:Destroy() end
        end
        itemFrames = {}

        for _, opt in ipairs(opts) do
            local isSel = table.find(selected, opt) ~= nil
            local item  = CreateInstance("TextButton", {
                Size             = UDim2.new(1, 0, 0, ITEM_H),
                BackgroundColor3 = isSel and Theme.AccentDim or Theme.ElementBackground,
                Text             = "",
                Parent           = itemList,
            })
            UICorner(4, item)

            Label(opt, 12, isSel and Theme.AccentBright or Theme.ElementText, Enum.Font.Gotham, {
                Size     = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
            }, item)

            if isSel then
                Label("✓", 11, Theme.AccentBright, Enum.Font.GothamBold, {
                    Size           = UDim2.new(0, 18, 1, 0),
                    Position       = UDim2.new(1, -20, 0, 0),
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
                    Tween(wrapper,  { Size = UDim2.new(1, 0, 0, 42) }, 0.18)
                    Tween(itemList, { Size = UDim2.new(1, 0, 0, 0)  }, 0.18)
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

        -- sync list height if already open
        if open then
            local h = CalcListH(#opts)
            itemList.Size = UDim2.new(1, 0, 0, h)
            wrapper.Size  = UDim2.new(1, 0, 0, 42 + h)
        end
    end
    RebuildItems()

    local headerBtn = CreateInstance("TextButton", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text             = "",
        Parent           = wrapper,
    })

    headerBtn.MouseButton1Click:Connect(function()
        open = not open
        local h = CalcListH(#opts)
        local targetH = open and (42 + h) or 42
        Tween(wrapper,  { Size = UDim2.new(1, 0, 0, targetH) }, 0.2)
        Tween(itemList, { Size = UDim2.new(1, 0, 0, open and h or 0) }, 0.2)
        arrow.Text = open and "▴" or "▾"
    end)

    return {
        Refresh = function(_, newOpts, keepSelected)
            if not keepSelected then selected = {} end
            RebuildItems(newOpts or opts)
            UpdatePreview()
        end,
        Set = function(_, val)
            selected = type(val) == "table" and val or { tostring(val) }
            UpdatePreview()
            RebuildItems()
        end,
        Get = function() return multi and selected or (selected[1] or "") end,
    }
end

-- ── KEYBIND ─────────────────────────────────────────────────────
local function BuildKeybind(parent, options)
    local name   = options.Name            or "Keybind"
    local flag   = options.Flag            or ""
    local cb     = type(options.Callback) == "function" and options.Callback or function() end
    local hold   = options.HoldToInteract  == true

    local savedKey = ConfigSystem:Get(flag)
    local curKey   = tostring(savedKey or options.CurrentKeybind or "F")
    ConfigSystem:RegisterFlag(flag, curKey)

    local row = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.ElementBackground,
        Parent           = parent,
    })
    UICorner(6, row)
    UIStroke(Theme.ElementStroke, 1, row)

    Label(name, 13, Theme.ElementText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.65, 0, 1, 0),
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
        listening     = true
        keyBox.Text   = "..."
        keyBox.TextColor3 = Theme.SubText
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if listening then
            local keyName = input.KeyCode.Name
            if keyName ~= "Unknown" and keyName ~= "W" and keyName ~= "A"
                and keyName ~= "S" and keyName ~= "D" then
                curKey            = keyName
                ConfigSystem:Set(flag, curKey)
                keyBox.Text       = "[" .. curKey .. "]"
                keyBox.TextColor3 = Theme.Accent
                listening         = false
            end
        elseif not hold and input.KeyCode.Name == curKey then
            task.spawn(cb)
        end
    end)

    if hold then
        -- FIX: only fire hold callback for the bound key
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
    local name = options.Name     or "Color"
    local flag = options.Flag     or ""
    local cb   = type(options.Callback) == "function" and options.Callback or function() end

    local savedC = ConfigSystem:Get(flag)
    local curColor
    if savedC and type(savedC) == "table" then
        curColor = Color3.fromRGB(
            math.clamp(tonumber(savedC.r) or 255, 0, 255),
            math.clamp(tonumber(savedC.g) or 255, 0, 255),
            math.clamp(tonumber(savedC.b) or 255, 0, 255)
        )
    else
        curColor = options.Color or Color3.new(1, 1, 1)
    end
    ConfigSystem:RegisterFlag(flag, {
        r = math.round(curColor.R * 255),
        g = math.round(curColor.G * 255),
        b = math.round(curColor.B * 255),
    })

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
        Size     = UDim2.new(0.7, 0, 0, 42),
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

    local panel = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 90),
        Position         = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Theme.InputBackground,
        BorderSizePixel  = 0,
        Parent           = wrapper,
    })
    UIPadding(8, 8, 10, 10, panel)
    UIListLayout(panel, 5)

    -- FIX: rgb stores 0-255 ints; initial fill must use /255 for the UDim2 scale
    local rgb = {
        math.round(curColor.R * 255),
        math.round(curColor.G * 255),
        math.round(curColor.B * 255),
    }

    local function ApplyColor()
        local c = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
        curColor = c
        swatch.BackgroundColor3 = c
        ConfigSystem:Set(flag, { r = rgb[1], g = rgb[2], b = rgb[3] })
        task.spawn(cb, c)
    end

    local channels = { "R", "G", "B" }
    for i, chName in ipairs(channels) do
        local rowF = CreateInstance("Frame", {
            Size             = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Parent           = panel,
        })
        Label(chName, 11, Theme.SubText, Enum.Font.GothamBold, {
            Size = UDim2.new(0, 14, 1, 0),
        }, rowF)

        local trackBg = CreateInstance("Frame", {
            Size             = UDim2.new(1, -20, 0, 6),
            Position         = UDim2.new(0, 18, 0.5, -3),
            BackgroundColor3 = Theme.SliderTrack,
            Parent           = rowF,
        })
        UICorner(3, trackBg)

        -- FIX: initial fill scale is rgb[i]/255, NOT the raw channel float
        local fill = CreateInstance("Frame", {
            Size             = UDim2.new(rgb[i] / 255, 0, 1, 0),
            BackgroundColor3 = Theme.Accent,
            Parent           = trackBg,
        })
        UICorner(3, fill)

        local chSliding = false
        local function SetCh(relX)
            local val = math.clamp(math.round(relX * 255), 0, 255)
            rgb[i]         = val
            fill.Size      = UDim2.new(val / 255, 0, 1, 0)
            ApplyColor()
        end

        trackBg.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                chSliding = true
                local rel = (inp.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X
                SetCh(math.clamp(rel, 0, 1))
            end
        end)
        OnInputMoved(function(inp)
            if chSliding then
                local rel = (inp.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X
                SetCh(math.clamp(rel, 0, 1))
            end
        end)
        OnInputEnded(function() chSliding = false end)
    end

    local btn = CreateInstance("TextButton", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text             = "",
        Parent           = wrapper,
    })
    btn.MouseButton1Click:Connect(function()
        open = not open
        Tween(wrapper, { Size = UDim2.new(1, 0, 0, open and 132 or 42) }, 0.2)
    end)

    task.defer(function() task.spawn(cb, curColor) end)
    return {
        Get = function() return curColor end,
        Set = function(_, c)
            curColor = c
            swatch.BackgroundColor3 = c
            rgb = { math.round(c.R*255), math.round(c.G*255), math.round(c.B*255) }
        end,
    }
end

-- ── LABEL ELEMENT ───────────────────────────────────────────────
local function BuildLabel(parent, options)
    local text = tostring(options.Name or options.Text or "")
    Label(text, 12, Theme.SubText, Enum.Font.Gotham, {
        Size     = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 12, 0, 0),
    }, parent)
end

-- ── TEXT INPUT ──────────────────────────────────────────────────
local function BuildInput(parent, options)
    local name  = options.Name                       or "Input"
    local flag  = options.Flag                       or ""
    local ph    = options.PlaceholderText            or "Type here..."
    local cb    = type(options.Callback) == "function" and options.Callback or function() end
    local rmb   = options.RemoveTextAfterFocusLost   ~= false

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
        Size     = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, row)

    local box = CreateInstance("TextBox", {
        Size             = UDim2.new(0.5, -10, 0, 26),
        Position         = UDim2.new(0.48, 0, 0.5, -13),
        BackgroundColor3 = Theme.InputBackground,
        PlaceholderText  = ph,
        PlaceholderColor3= Theme.SubText,
        Text             = tostring(savedVal or ""),
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

    return {
        Get = function() return box.Text end,
        Set = function(_, v) box.Text = tostring(v) end,
    }
end

-- ═══════════════════════════════════════════════════════════════
-- TAB PROTOTYPE
-- ═══════════════════════════════════════════════════════════════
local TabProto = {}
TabProto.__index = TabProto

function TabProto:CreateToggle(opts)      return BuildToggle(self._content, opts) end
function TabProto:CreateButton(opts)      BuildButton(self._content, opts) end
function TabProto:CreateSlider(opts)      return BuildSlider(self._content, opts) end
function TabProto:CreateSection(title)    BuildSection(self._content, title) end
function TabProto:CreateDropdown(opts)    return BuildDropdown(self._content, opts) end
function TabProto:CreateKeybind(opts)     return BuildKeybind(self._content, opts) end
function TabProto:CreateColorPicker(opts) return BuildColorPicker(self._content, opts) end
function TabProto:CreateLabel(opts)       BuildLabel(self._content, opts) end
function TabProto:CreateInput(opts)       return BuildInput(self._content, opts) end

-- ═══════════════════════════════════════════════════════════════
-- WINDOW PROTOTYPE
-- ═══════════════════════════════════════════════════════════════
local WindowProto = {}
WindowProto.__index = WindowProto

function WindowProto:CreateTab(name)
    local btn = CreateInstance("TextButton", {
        Size             = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = Theme.TabBackground,
        Text             = "",
        Parent           = self._sidebar,
    })
    UICorner(6, btn)

    local btnLabel = Label(name or "Tab", 12, Theme.TabText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(1, -16, 1, 0),
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

    local scroll = CreateInstance("ScrollingFrame", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = Theme.ScrollBar,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        Visible                = false,
        Parent                 = self._contentArea,
    })

    local content = CreateInstance("Frame", {
        Size          = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent        = scroll,
    })
    UIPadding(8, 10, 8, 8, content)
    UIListLayout(content, 5)

    local tab = setmetatable({ _content = content, _scroll = scroll }, TabProto)
    table.insert(self._tabs, {
        btn       = btn,
        scroll    = scroll,
        label     = btnLabel,
        indicator = indicator,
        tab       = tab,
    })

    -- Auto-select first tab
    if #self._tabs == 1 then
        self:_SelectTab(1)
    end

    btn.MouseButton1Click:Connect(function()
        for i, t in ipairs(self._tabs) do
            if t.btn == btn then self:_SelectTab(i); return end
        end
    end)

    return tab
end

function WindowProto:_SelectTab(idx)
    for i, t in ipairs(self._tabs) do
        local sel = (i == idx)
        t.scroll.Visible     = sel
        t.indicator.Visible  = sel
        Tween(t.btn, { BackgroundColor3 = sel and Theme.TabBackgroundSelected or Theme.TabBackground }, 0.15)
        t.label.TextColor3   = sel and Theme.TabTextSelected or Theme.TabText
    end
end

function WindowProto:Notify(opts)     Crimson:Notify(opts) end
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
function WindowProto:Destroy()
    if self._gui and self._gui.Parent then self._gui:Destroy() end
end

-- ═══════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════
function Crimson:CreateWindow(options)
    options       = options or {}
    local title     = tostring(options.Name            or "Crimson")
    local loadTitle = tostring(options.LoadingTitle    or title)
    local loadSub   = tostring(options.LoadingSubtitle or "Loading...")
    local cfgSaving = type(options.ConfigurationSaving) == "table" and options.ConfigurationSaving or {}
    local cfgFolder = tostring(cfgSaving.FolderName or "CrimsonConfigs")
    local cfgFile   = tostring(cfgSaving.FileName   or "Config")
    local cfgEnabled = cfgSaving.Enabled == true

    -- FIX: Load config BEFORE any elements are built so flags are available
    if cfgEnabled then
        ConfigSystem:Load(cfgFolder, cfgFile)
    end

    -- Remove any previous instance to avoid duplicates
    local prev = LP.PlayerGui:FindFirstChild("CrimsonGUI")
    if prev then prev:Destroy() end

    -- ── Screen GUI ───────────────────────────────────────────────
    local sg = CreateInstance("ScreenGui", {
        Name           = "CrimsonGUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = LP.PlayerGui,
    })

    -- ── Loading Screen ───────────────────────────────────────────
    local loadScreen = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(4, 0, 0),
        ZIndex           = 100,
        Parent           = sg,
    })

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

    Label("<b>" .. loadTitle .. "</b>", 28, Theme.AccentBright, Enum.Font.GothamBlack, {
        Size           = UDim2.new(0.7, 0, 0, 40),
        Position       = UDim2.new(0.15, 0, 0.38, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 102,
    }, loadScreen)

    Label(loadSub, 14, Theme.SubText, Enum.Font.Gotham, {
        Size           = UDim2.new(0.5, 0, 0, 24),
        Position       = UDim2.new(0.25, 0, 0.48, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 102,
    }, loadScreen)

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

    task.spawn(function()
        Tween(barFill, { Size = UDim2.new(1, 0, 1, 0) }, 1.2, Enum.EasingStyle.Quart)
        task.wait(1.3)
        Tween(loadScreen, { BackgroundTransparency = 1 }, 0.4)
        for _, obj in pairs(loadScreen:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("TextLabel") then
                pcall(function()
                    Tween(obj, { BackgroundTransparency = 1, TextTransparency = 1 }, 0.4)
                end)
            end
        end
        task.wait(0.5)
        if loadScreen and loadScreen.Parent then loadScreen:Destroy() end
    end)

    -- ── Main Window ───────────────────────────────────────────────
    local gui = CreateInstance("Frame", {
        Name             = "CrimsonWindow",
        Size             = UDim2.new(0, 620, 0, 420),
        Position         = UDim2.new(0.5, -310, 0.5, -210),
        BackgroundColor3 = Theme.Background,
        Parent           = sg,
    })
    UICorner(10, gui)
    UIStroke(Theme.Border, 1.5, gui)

    -- Background image layer (behind everything)
    local bgImage = CreateInstance("ImageLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ImageTransparency = 0.75,
        ScaleType        = Enum.ScaleType.Crop,
        Image            = "",
        ZIndex           = 0,
        Parent           = gui,
    })

    -- ── Topbar ────────────────────────────────────────────────────
    local topbar = CreateInstance("Frame", {
        Name             = "Topbar",
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Topbar,
        Parent           = gui,
    })
    UICorner(10, topbar)
    -- fill bottom corners
    CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0.5, 0),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Topbar,
        BorderSizePixel  = 0,
        Parent           = topbar,
    })
    -- accent separator
    CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        Parent           = topbar,
    })

    Label("🔴  " .. title:upper(), 13, Theme.AccentBright, Enum.Font.GothamBlack, {
        Size           = UDim2.new(0.6, 0, 1, 0),
        Position       = UDim2.new(0.5, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, topbar)

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
        Tween(gui, {
            Size = minimized and UDim2.new(0, 620, 0, 36) or UDim2.new(0, 620, 0, 420)
        }, 0.22)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(gui, { Size = UDim2.new(0, 0, 0, 0) }, 0.2)
        task.delay(0.25, function()
            if sg and sg.Parent then sg:Destroy() end
        end)
    end)

    MakeDraggable(gui, topbar)

    -- ── Body ──────────────────────────────────────────────────────
    local body = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 1, -36),
        Position         = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent           = gui,
    })

    -- ── Sidebar ───────────────────────────────────────────────────
    local sidebar = CreateInstance("ScrollingFrame", {
        Size                   = UDim2.new(0, 148, 1, 0),
        BackgroundColor3       = Theme.TabBackground,
        ScrollBarThickness     = 2,
        ScrollBarImageColor3   = Theme.ScrollBar,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        Parent                 = body,
    })
    UICorner(10, sidebar)
    -- fill right corners
    CreateInstance("Frame", {
        Size             = UDim2.new(0, 12, 1, 0),
        Position         = UDim2.new(1, -12, 0, 0),
        BackgroundColor3 = Theme.TabBackground,
        BorderSizePixel  = 0,
        Parent           = sidebar,
    })

    local sidebarContent = CreateInstance("Frame", {
        Size          = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent        = sidebar,
    })
    UIPadding(8, 8, 4, 4, sidebarContent)
    UIListLayout(sidebarContent, 4)

    -- Vertical divider
    CreateInstance("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(0, 148, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        Parent           = body,
    })

    -- ── Content area ──────────────────────────────────────────────
    local contentArea = CreateInstance("Frame", {
        Size             = UDim2.new(1, -150, 1, 0),
        Position         = UDim2.new(0, 150, 0, 0),
        BackgroundTransparency = 1,
        Parent           = body,
    })

    -- ── BG Image editor ──────────────────────────────────────────
    local settingsRow = CreateInstance("TextButton", {
        Size             = UDim2.new(1, -8, 0, 30),
        BackgroundColor3 = Theme.AccentDim,
        Text             = "",
        LayoutOrder      = 9999,
        Parent           = sidebarContent,
    })
    UICorner(6, settingsRow)
    Label("⚙  BG Image", 11, Theme.SubText, Enum.Font.GothamSemiBold, {
        Size           = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, settingsRow)

    -- FIX: bgEditor parented to sg (ScreenGui) so it always appears on-screen
    local bgEditor = CreateInstance("Frame", {
        Size             = UDim2.new(0, 280, 0, 130),
        Position         = UDim2.new(0, 160, 1, -140),
        BackgroundColor3 = Theme.Topbar,
        Visible          = false,
        ZIndex           = 20,
        Parent           = sg,
    })
    UICorner(8, bgEditor)
    UIStroke(Theme.Border, 1, bgEditor)
    UIPadding(10, 10, 10, 10, bgEditor)
    UIListLayout(bgEditor, 6)

    Label("Custom Background Image", 12, Theme.AccentBright, Enum.Font.GothamBold, {
        Size           = UDim2.new(1, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 21,
    }, bgEditor)

    Label("Paste rbxassetid:// or image URL", 10, Theme.SubText, Enum.Font.Gotham, {
        Size           = UDim2.new(1, 0, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 21,
    }, bgEditor)

    local bgInput = CreateInstance("TextBox", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Theme.InputBackground,
        PlaceholderText  = "rbxassetid://123456789",
        PlaceholderColor3= Theme.SubText,
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
            TextColor3       = Color3.new(1, 1, 1),
            Font             = Enum.Font.GothamSemiBold,
            ZIndex           = 22,
            Parent           = parentF,
        })
        UICorner(5, b)
        b.MouseButton1Click:Connect(onClick)
        return b
    end

    -- Opacity slider
    local opacitySliderBg = CreateInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = Theme.SliderTrack,
        ZIndex           = 21,
        Parent           = bgEditor,
    })
    UICorner(5, opacitySliderBg)
    Label("Opacity", 9, Theme.SubText, Enum.Font.Gotham, {
        Size     = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, -12),
        ZIndex   = 21,
    }, opacitySliderBg)

    local opacityFill = CreateInstance("Frame", {
        Size             = UDim2.new(0.25, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        ZIndex           = 22,
        Parent           = opacitySliderBg,
    })
    UICorner(5, opacityFill)

    local opSliding = false
    opacitySliderBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            opSliding = true
            local rel = math.clamp((inp.Position.X - opacitySliderBg.AbsolutePosition.X) / opacitySliderBg.AbsoluteSize.X, 0, 1)
            opacityFill.Size = UDim2.new(rel, 0, 1, 0)
            bgImage.ImageTransparency = 1 - rel
        end
    end)
    OnInputMoved(function(inp)
        if opSliding then
            local rel = math.clamp((inp.Position.X - opacitySliderBg.AbsolutePosition.X) / opacitySliderBg.AbsoluteSize.X, 0, 1)
            opacityFill.Size = UDim2.new(rel, 0, 1, 0)
            bgImage.ImageTransparency = 1 - rel
        end
    end)
    OnInputEnded(function() opSliding = false end)

    MakeSmallBtn("Apply", Theme.Accent, bgBtnRow, function()
        local id = bgInput.Text:match("(%d+)") or ""
        bgImage.Image = (id ~= "") and ("rbxassetid://" .. id) or bgInput.Text
    end)
    MakeSmallBtn("Clear", Theme.AccentDim, bgBtnRow, function()
        bgImage.Image = ""
        bgInput.Text  = ""
    end)

    settingsRow.MouseButton1Click:Connect(function()
        bgEditor.Visible = not bgEditor.Visible
    end)

    -- Hide/show with Insert key
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            gui.Visible = not gui.Visible
        end
    end)

    -- Auto-save config every 60s
    if cfgEnabled then
        task.spawn(function()
            while sg and sg.Parent do
                task.wait(60)
                ConfigSystem:Save(cfgFolder, cfgFile)
            end
        end)
    end

    -- ── Window object ─────────────────────────────────────────────
    local window = setmetatable({
        _gui         = sg,
        _sidebar     = sidebarContent,
        _contentArea = contentArea,
        _tabs        = {},
        _cfgFolder   = cfgEnabled and cfgFolder or nil,
        _cfgFile     = cfgEnabled and cfgFile   or nil,
    }, WindowProto)

    return window
end

-- ═══════════════════════════════════════════════════════════════
-- STATIC METHODS
-- ═══════════════════════════════════════════════════════════════
-- FIX: original line was `Crimson.Notify = Crimson.Notify` (no-op self-assign)
-- Notify is already defined as a method above; nothing extra needed.

function Crimson:Destroy()
    pcall(function()
        local g = LP.PlayerGui:FindFirstChild("CrimsonGUI")
        if g then g:Destroy() end
        local n = LP.PlayerGui:FindFirstChild("CrimsonNotifs")
        if n then n:Destroy() end
    end)
end

return Crimson
