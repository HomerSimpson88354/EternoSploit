--[[
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   ██████╗██████╗ ██╗███╗   ███╗███████╗ ██████╗ ███╗   ██╗      ║
║  ██╔════╝██╔══██╗██║████╗ ████║██╔════╝██╔═══██╗████╗  ██║      ║
║  ██║     ██████╔╝██║██╔████╔██║███████╗██║   ██║██╔██╗ ██║      ║
║  ██║     ██╔══██╗██║██║╚██╔╝██║╚════██║██║   ██║██║╚██╗██║      ║
║  ╚██████╗██║  ██║██║██║ ╚═╝ ██║███████║╚██████╔╝██║ ╚████║      ║
║   ╚═════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝     ║
║                                                                   ║
║   Crimson GUI                           ║
║   crimson-accented Roblox UI library              ║
║                                                                   ║
║   API REFERENCE:                                                  ║
║   ─────────────────────────────────────────────────────────────  ║
║   local Crimson = loadstring(game:HttpGet("URL"))()              ║
║                                                                   ║
║   local Win = Crimson:CreateWindow({                             ║
║       Name            = "My Script",                             ║
║       LoadingTitle    = "My Script",                             ║
║       LoadingSubtitle = "Loading...",                            ║
║       ConfigurationSaving = {                                    ║
║           Enabled    = true,                                     ║
║           FolderName = "MyConfigs",                              ║
║           FileName   = "Config",                                 ║
║       },                                                         ║
║   })                                                             ║
║                                                                   ║
║   local Tab = Win:CreateTab("Tab Name")                          ║
║                                                                   ║
║   Tab:CreateSection("Section Name")                              ║
║   Tab:CreateToggle({ Name, CurrentValue, Flag, Callback })       ║
║   Tab:CreateButton({ Name, Callback })                           ║
║   Tab:CreateSlider({ Name, Range, Increment, CurrentValue,       ║
║                      Flag, Callback })                           ║
║   Tab:CreateDropdown({ Name, Options, CurrentOption,             ║
║                        MultipleOptions, Flag, Callback })        ║
║   Tab:CreateKeybind({ Name, CurrentKeybind, HoldToInteract,      ║
║                       Flag, Callback })                          ║
║   Tab:CreateColorPicker({ Name, Color, Flag, Callback })         ║
║   Tab:CreateInput({ Name, PlaceholderText, Flag, Callback })     ║
║   Tab:CreateLabel({ Name })                                      ║
║                                                                   ║
║   Crimson:Notify({ Title, Content, Duration })                   ║
║   Crimson:Destroy()                                              ║
╚═══════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")

local LP = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════
-- THEME  — Obsidian / Crimson palette
-- All color decisions live here. Swap these to reskin the entire UI.
-- ═══════════════════════════════════════════════════════════════════
local T = {
    -- Window chrome
    WindowBg        = Color3.fromRGB(13, 13, 15),     -- near-black base
    WindowBorder    = Color3.fromRGB(40, 10, 10),
    TopbarBg        = Color3.fromRGB(18, 8, 8),
    TopbarBorder    = Color3.fromRGB(120, 20, 20),

    -- Sidebar
    SidebarBg       = Color3.fromRGB(16, 7, 7),
    SidebarBorder   = Color3.fromRGB(35, 10, 10),
    TabIdle         = Color3.fromRGB(16, 7, 7),
    TabHover        = Color3.fromRGB(30, 10, 10),
    TabActive       = Color3.fromRGB(120, 18, 18),
    TabTextIdle     = Color3.fromRGB(170, 120, 120),
    TabTextActive   = Color3.fromRGB(255, 210, 210),

    -- Elements
    ElemBg          = Color3.fromRGB(20, 9, 9),
    ElemBgHover     = Color3.fromRGB(28, 12, 12),
    ElemBgPress     = Color3.fromRGB(90, 14, 14),
    ElemBorder      = Color3.fromRGB(45, 14, 14),
    ElemText        = Color3.fromRGB(230, 205, 205),
    SubText         = Color3.fromRGB(150, 100, 100),

    -- Accent (crimson)
    Accent          = Color3.fromRGB(185, 22, 22),
    AccentBright    = Color3.fromRGB(230, 50, 50),
    AccentDim       = Color3.fromRGB(100, 14, 14),
    AccentGlow      = Color3.fromRGB(255, 80, 80),

    -- Toggle
    ToggleOn        = Color3.fromRGB(200, 25, 25),
    ToggleOff       = Color3.fromRGB(45, 15, 15),
    ToggleKnob      = Color3.fromRGB(240, 210, 210),

    -- Slider
    SliderTrack     = Color3.fromRGB(30, 10, 10),
    SliderFill      = Color3.fromRGB(185, 22, 22),
    SliderKnob      = Color3.fromRGB(235, 80, 80),

    -- Input / Dropdown
    InputBg         = Color3.fromRGB(11, 5, 5),
    InputBorder     = Color3.fromRGB(55, 16, 16),

    -- Section divider
    SectionLine     = Color3.fromRGB(40, 12, 12),
    SectionText     = Color3.fromRGB(140, 45, 45),

    -- Notification
    NotifBg         = Color3.fromRGB(16, 6, 6),
    NotifBorder     = Color3.fromRGB(170, 22, 22),
    NotifText       = Color3.fromRGB(235, 210, 210),
    NotifSub        = Color3.fromRGB(150, 100, 100),

    -- Scrollbar
    ScrollBar       = Color3.fromRGB(80, 18, 18),
}

-- ═══════════════════════════════════════════════════════════════════
-- UTILITY HELPERS
-- ═══════════════════════════════════════════════════════════════════

-- Tween shorthand — always pcall'd so destroyed instances don't error
local function Tween(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    local ok, tw = pcall(function()
        return TweenService:Create(
            obj,
            TweenInfo.new(
                t     or 0.18,
                style or Enum.EasingStyle.Quart,
                dir   or Enum.EasingDirection.Out
            ),
            props
        )
    end)
    if ok and tw then tw:Play() end
end

-- Friendly instance constructor — sets all props, parents last
local function New(class, props)
    local inst = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            pcall(function() inst[k] = v end)
        end
    end
    if parent then inst.Parent = parent end
    return inst
end

-- Attach UICorner
local function Corner(r, inst)
    return New("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = inst })
end

-- Attach UIStroke
local function Stroke(color, thick, inst)
    return New("UIStroke", {
        Color             = color or Color3.new(1,1,1),
        Thickness         = thick or 1,
        ApplyStrokeMode   = Enum.ApplyStrokeMode.Border,
        Parent            = inst,
    })
end

-- Attach UIPadding
local function Pad(t, b, l, r, inst)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
        Parent        = inst,
    })
end

-- Attach UIListLayout
local function List(inst, spacing, dir, halign)
    return New("UIListLayout", {
        Padding              = UDim.new(0, spacing or 4),
        FillDirection        = dir    or Enum.FillDirection.Vertical,
        SortOrder            = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment  = halign or Enum.HorizontalAlignment.Center,
        Parent               = inst,
    })
end

-- TextLabel shorthand
local function Lbl(text, size, color, font, props, parent)
    local l = New("TextLabel", {
        Text                  = tostring(text or ""),
        TextSize              = size  or 13,
        TextColor3            = color or T.ElemText,
        Font                  = font  or Enum.Font.GothamSemiBold,
        BackgroundTransparency = 1,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextTruncate          = Enum.TextTruncate.AtEnd,
        RichText              = true,
        Size                  = UDim2.new(1, 0, 1, 0),
    })
    for k, v in pairs(props or {}) do pcall(function() l[k] = v end) end
    if parent then l.Parent = parent end
    return l
end

-- Make a frame draggable by a handle
local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging  = true
        dragStart = inp.Position
        startPos  = frame.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end)

    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = inp
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if inp ~= dragInput or not dragging then return end
        local d = inp.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- SHARED INPUT DISPATCHER
-- Instead of connecting UserInputService per-element (which stacks),
-- we use a single global connection and let elements register handlers.
-- ═══════════════════════════════════════════════════════════════════
local _movedCBs = {}
local _endedCBs = {}

UserInputService.InputChanged:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    for i = 1, #_movedCBs do pcall(_movedCBs[i], inp) end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    for i = 1, #_endedCBs do pcall(_endedCBs[i], inp) end
end)

local function OnMoved(cb) table.insert(_movedCBs, cb) end
local function OnEnded(cb) table.insert(_endedCBs, cb) end

-- ═══════════════════════════════════════════════════════════════════
-- CONFIG SYSTEM  (writefile / readfile, gracefully degraded)
-- ═══════════════════════════════════════════════════════════════════
local Cfg = { _data = {} }

function Cfg:reg(flag, default)
    if flag and flag ~= "" and self._data[flag] == nil then
        self._data[flag] = default
    end
end

function Cfg:get(flag) return self._data[flag] end

function Cfg:set(flag, val)
    if flag and flag ~= "" then self._data[flag] = val end
end

function Cfg:save(folder, file)
    if not (writefile and makefolder) then return end
    pcall(function()
        if not isfolder(folder) then makefolder(folder) end
        local ok, enc = pcall(HttpService.JSONEncode, HttpService, self._data)
        if ok then writefile(folder .. "/" .. file .. ".json", enc) end
    end)
end

function Cfg:load(folder, file)
    if not (readfile and isfile) then return end
    pcall(function()
        local path = folder .. "/" .. file .. ".json"
        if not isfile(path) then return end
        local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(path))
        if ok and type(data) == "table" then
            for k, v in pairs(data) do self._data[k] = v end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════
local _notifSG     = nil
local _notifHolder = nil

local function EnsureNotifLayer()
    -- Re-use existing ScreenGui if still alive
    local existing = LP.PlayerGui:FindFirstChild("CrimsonNotifs_v2")
    if not existing then
        existing = New("ScreenGui", {
            Name           = "CrimsonNotifs_v2",
            ResetOnSpawn   = false,
            DisplayOrder   = 999998,         -- just below main GUI
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            IgnoreGuiInset = true,
            Parent         = LP.PlayerGui,
        })
    end
    _notifSG = existing

    if not _notifHolder or not _notifHolder.Parent then
        _notifHolder = New("Frame", {
            Name                  = "Holder",
            Size                  = UDim2.new(0, 290, 1, -20),
            Position              = UDim2.new(1, -300, 0, 10),
            BackgroundTransparency = 1,
            Parent                = _notifSG,
        })
        List(_notifHolder, 8)
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- LIBRARY ROOT OBJECT
-- ═══════════════════════════════════════════════════════════════════
local Crimson = {}
Crimson.__index = Crimson

-- ───────────────────────────────────────────────────────────────────
-- Crimson:Notify({ Title, Content, Duration })
-- ───────────────────────────────────────────────────────────────────
function Crimson:Notify(opts)
    if type(opts) ~= "table" then return end
    task.spawn(function()
        pcall(function()
            EnsureNotifLayer()

            local title    = tostring(opts.Title   or "Crimson")
            local content  = tostring(opts.Content or "")
            local duration = tonumber(opts.Duration) or 4

            -- Card
            local card = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 74),
                BackgroundColor3 = T.NotifBg,
                ClipsDescendants = true,
                BackgroundTransparency = 0,
                Parent           = _notifHolder,
            })
            Corner(10, card)
            Stroke(T.NotifBorder, 1, card)

            -- Left accent bar
            New("Frame", {
                Size             = UDim2.new(0, 3, 1, 0),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = card,
            })

            -- Inner padding frame
            local inner = New("Frame", {
                Size             = UDim2.new(1, -16, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                ZIndex           = 2,
                Parent           = card,
            })

            Lbl("<b>" .. title .. "</b>", 13, T.NotifText, Enum.Font.GothamBold, {
                Size     = UDim2.new(1, 0, 0, 22),
                Position = UDim2.new(0, 0, 0, 10),
                ZIndex   = 3,
            }, inner)

            Lbl(content, 12, T.NotifSub, Enum.Font.Gotham, {
                Size        = UDim2.new(1, 0, 0, 32),
                Position    = UDim2.new(0, 0, 0, 32),
                TextWrapped = true,
                ZIndex      = 3,
            }, inner)

            -- Progress bar (shrinks to 0 over duration)
            local bar = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 2),
                Position         = UDim2.new(0, 0, 1, -2),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 3,
                Parent           = card,
            })
            Corner(1, bar)

            -- Slide in from right
            card.Position = UDim2.new(1, 10, 0, 0)
            Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Back)
            Tween(bar,  { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

            -- Slide out after duration
            task.delay(duration + 0.05, function()
                if not card or not card.Parent then return end
                Tween(card, { Position = UDim2.new(1, 10, 0, 0) }, 0.22)
                task.wait(0.25)
                if card and card.Parent then card:Destroy() end
            end)
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- ELEMENT BUILDERS (private — called by TabProto methods)
-- ═══════════════════════════════════════════════════════════════════

-- ────────────────────────────────────────────────────────────────────
-- SECTION DIVIDER
-- ────────────────────────────────────────────────────────────────────
local function BuildSection(parent, title)
    title = tostring(title or ""):upper()

    local row = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent           = parent,
    })

    -- Full-width line
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = T.SectionLine,
        BorderSizePixel  = 0,
        Parent           = row,
    })

    -- Label pill that sits on top of the line
    local pill = New("Frame", {
        Size             = UDim2.new(0, math.min(#title * 7 + 20, 280), 0, 18),
        Position         = UDim2.new(0, 8, 0.5, -9),
        BackgroundColor3 = T.WindowBg,
        BorderSizePixel  = 0,
        Parent           = row,
    })
    Corner(4, pill)

    Lbl(title, 10, T.SectionText, Enum.Font.GothamBold, {
        Size           = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, pill)
end

-- ────────────────────────────────────────────────────────────────────
-- TOGGLE
-- ────────────────────────────────────────────────────────────────────
local function BuildToggle(parent, opts)
    local name = opts.Name          or "Toggle"
    local flag = opts.Flag          or ""
    local cb   = type(opts.Callback) == "function" and opts.Callback or function() end

    -- Resolve value: saved → default
    local saved = Cfg:get(flag)
    local state = (saved ~= nil) and (saved == true) or (opts.CurrentValue == true)
    Cfg:reg(flag, state)

    -- Row card
    local row = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = T.ElemBg,
        Parent           = parent,
    })
    Corner(8, row)
    Stroke(T.ElemBorder, 1, row)

    -- Hover / press animation on the row
    local function rowHover(on)
        Tween(row, { BackgroundColor3 = on and T.ElemBgHover or T.ElemBg }, 0.12)
    end

    -- Name label
    Lbl(name, 13, T.ElemText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(1, -64, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, row)

    -- Track (pill background)
    local track = New("Frame", {
        Size             = UDim2.new(0, 42, 0, 22),
        Position         = UDim2.new(1, -54, 0.5, -11),
        BackgroundColor3 = state and T.ToggleOn or T.ToggleOff,
        Parent           = row,
    })
    Corner(11, track)

    -- Knob
    local knob = New("Frame", {
        Size             = UDim2.new(0, 18, 0, 18),
        Position         = state and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = T.ToggleKnob,
        Parent           = track,
    })
    Corner(9, knob)

    -- Apply state visually + fire callback
    local function SetState(val, silent)
        state = val == true
        Cfg:set(flag, state)
        Tween(track, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff }, 0.18)
        Tween(knob,  { Position = state and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2) }, 0.18)
        if not silent then task.spawn(cb, state) end
    end

    -- Fire callback on load
    task.defer(function() task.spawn(cb, state) end)

    -- Invisible click overlay
    local btn = New("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 3,
        Parent           = row,
    })
    btn.MouseEnter:Connect(function()     rowHover(true) end)
    btn.MouseLeave:Connect(function()     rowHover(false) end)
    btn.MouseButton1Click:Connect(function() SetState(not state) end)

    return {
        Set = function(_, v) SetState(v, false) end,
        Get = function()     return state end,
    }
end

-- ────────────────────────────────────────────────────────────────────
-- BUTTON
-- ────────────────────────────────────────────────────────────────────
local function BuildButton(parent, opts)
    local name = opts.Name or "Button"
    local cb   = type(opts.Callback) == "function" and opts.Callback or function() end

    local row = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = T.ElemBg,
        Parent           = parent,
    })
    Corner(8, row)
    Stroke(T.ElemBorder, 1, row)

    -- Crimson left-edge accent bar
    New("Frame", {
        Size             = UDim2.new(0, 3, 0.55, 0),
        Position         = UDim2.new(0, 0, 0.225, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = row,
    })

    -- Centered label
    Lbl(name, 13, T.ElemText, Enum.Font.GothamSemiBold, {
        Size           = UDim2.new(1, -16, 1, 0),
        Position       = UDim2.new(0, 14, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local debounce = false
    local btn = New("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 3,
        Parent           = row,
    })

    btn.MouseEnter:Connect(function()
        Tween(row, { BackgroundColor3 = T.ElemBgHover }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween(row, { BackgroundColor3 = T.ElemBg }, 0.12)
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(row, { BackgroundColor3 = T.ElemBgPress }, 0.07)
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(row, { BackgroundColor3 = T.ElemBgHover }, 0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        if debounce then return end
        debounce = true
        task.spawn(cb)
        task.delay(0.25, function() debounce = false end)
    end)
end

-- ────────────────────────────────────────────────────────────────────
-- SLIDER
-- ────────────────────────────────────────────────────────────────────
local function BuildSlider(parent, opts)
    local name = opts.Name      or "Slider"
    local rng  = opts.Range     or {0, 100}
    local min  = tonumber(rng[1]) or 0
    local max  = tonumber(rng[2]) or 100
    if min >= max then max = min + 1 end
    local inc  = tonumber(opts.Increment) or 1
    local flag = opts.Flag      or ""
    local cb   = type(opts.Callback) == "function" and opts.Callback or function() end

    local saved = Cfg:get(flag)
    local curVal = math.clamp(
        tonumber(saved) or tonumber(opts.CurrentValue) or min,
        min, max
    )
    Cfg:reg(flag, curVal)

    -- Card (taller to fit label + track)
    local row = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = T.ElemBg,
        Parent           = parent,
    })
    Corner(8, row)
    Stroke(T.ElemBorder, 1, row)

    -- Name
    Lbl(name, 13, T.ElemText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.65, 0, 0, 22),
        Position = UDim2.new(0, 12, 0, 6),
    }, row)

    -- Live value label (right-aligned)
    local valLbl = Lbl(tostring(curVal), 12, T.Accent, Enum.Font.GothamBold, {
        Size           = UDim2.new(0.32, 0, 0, 22),
        Position       = UDim2.new(0.66, 0, 0, 6),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)

    -- Track background
    local track = New("Frame", {
        Size             = UDim2.new(1, -24, 0, 6),
        Position         = UDim2.new(0, 12, 0, 38),
        BackgroundColor3 = T.SliderTrack,
        ZIndex           = 2,
        Parent           = row,
    })
    Corner(3, track)

    -- Percentage helper
    local function pct()
        return (max ~= min) and ((curVal - min) / (max - min)) or 0
    end

    -- Fill bar
    local fill = New("Frame", {
        Size             = UDim2.new(pct(), 0, 1, 0),
        BackgroundColor3 = T.SliderFill,
        ZIndex           = 3,
        Parent           = track,
    })
    Corner(3, fill)

    -- Knob dot
    local knob = New("Frame", {
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = UDim2.new(pct(), -7, 0.5, -7),
        BackgroundColor3 = T.SliderKnob,
        ZIndex           = 4,
        Parent           = track,
    })
    Corner(7, knob)

    local sliding = false

    local function SetVal(v)
        v = math.clamp(math.round(v / inc) * inc, min, max)
        curVal = v
        Cfg:set(flag, v)
        local p = pct()
        Tween(fill,  { Size = UDim2.new(p, 0, 1, 0) }, 0.06)
        Tween(knob,  { Position = UDim2.new(p, -7, 0.5, -7) }, 0.06)
        valLbl.Text = tostring(v)
        task.spawn(cb, v)
    end

    local function DragTo(inp)
        local rel = (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        SetVal(min + (max - min) * math.clamp(rel, 0, 1))
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        sliding = true
        DragTo(inp)
    end)
    OnMoved(function(inp) if sliding then DragTo(inp) end end)
    OnEnded(function()    sliding = false end)

    -- Knob hover glow
    knob.MouseEnter:Connect(function() Tween(knob, { BackgroundColor3 = T.AccentGlow }, 0.12) end)
    knob.MouseLeave:Connect(function() Tween(knob, { BackgroundColor3 = T.SliderKnob }, 0.12) end)

    task.defer(function() task.spawn(cb, curVal) end)

    return {
        Set = SetVal,
        Get = function() return curVal end,
    }
end

-- ────────────────────────────────────────────────────────────────────
-- DROPDOWN
-- ────────────────────────────────────────────────────────────────────
local function BuildDropdown(parent, opts)
    local name  = opts.Name             or "Dropdown"
    local flag  = opts.Flag             or ""
    local multi = opts.MultipleOptions  == true
    local cb    = type(opts.Callback) == "function" and opts.Callback or function() end
    local options = type(opts.Options) == "table" and opts.Options or {}

    local saved = Cfg:get(flag)
    local sel   = {}
    if saved ~= nil then
        sel = type(saved) == "table" and saved or (tostring(saved) ~= "" and { tostring(saved) } or {})
    elseif opts.CurrentOption ~= nil then
        sel = type(opts.CurrentOption) == "table" and opts.CurrentOption
              or (tostring(opts.CurrentOption) ~= "" and { tostring(opts.CurrentOption) } or {})
    end
    Cfg:reg(flag, sel)

    local ITEM_H = 28
    local open   = false

    -- Wrapper (clips to 44 when closed, expands when open)
    local wrap = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = T.ElemBg,
        ClipsDescendants = true,
        Parent           = parent,
    })
    Corner(8, wrap)
    Stroke(T.ElemBorder, 1, wrap)

    -- Header row
    local header = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        ZIndex           = 2,
        Parent           = wrap,
    })

    Lbl(name, 13, T.ElemText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.52, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        ZIndex   = 3,
    }, header)

    local preview = Lbl("None", 12, T.SubText, Enum.Font.Gotham, {
        Size           = UDim2.new(0.38, 0, 1, 0),
        Position       = UDim2.new(0.52, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = 3,
    }, header)

    local arrow = Lbl("▾", 14, T.Accent, Enum.Font.GothamBold, {
        Size           = UDim2.new(0, 22, 1, 0),
        Position       = UDim2.new(1, -26, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 3,
    }, header)

    -- Item list container
    local listFrame = New("Frame", {
        Size             = UDim2.new(1, -16, 0, 0),
        Position         = UDim2.new(0, 8, 0, 48),
        BackgroundTransparency = 1,
        ZIndex           = 3,
        ClipsDescendants = false,
        Parent           = wrap,
    })
    List(listFrame, 3)

    local function UpdatePreview()
        if #sel == 0 then
            preview.Text      = "None"
            preview.TextColor3 = T.SubText
        elseif #sel == 1 then
            preview.Text      = sel[1]
            preview.TextColor3 = T.ElemText
        else
            preview.Text      = sel[1] .. " +" .. (#sel - 1)
            preview.TextColor3 = T.ElemText
        end
    end
    UpdatePreview()

    local itemFrames = {}

    local function RebuildItems(newOpts)
        options = (type(newOpts) == "table") and newOpts or options
        for _, f in ipairs(itemFrames) do if f and f.Parent then f:Destroy() end end
        itemFrames = {}

        for _, opt in ipairs(options) do
            local isSel = table.find(sel, opt) ~= nil

            local item = New("TextButton", {
                Size             = UDim2.new(1, 0, 0, ITEM_H),
                BackgroundColor3 = isSel and T.AccentDim or T.InputBg,
                Text             = "",
                ZIndex           = 4,
                Parent           = listFrame,
            })
            Corner(6, item)
            if isSel then Stroke(T.Accent, 1, item) end

            Lbl(opt, 12, isSel and T.AccentBright or T.ElemText, Enum.Font.Gotham, {
                Size     = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                ZIndex   = 5,
            }, item)

            if isSel then
                Lbl("✓", 11, T.AccentBright, Enum.Font.GothamBold, {
                    Size           = UDim2.new(0, 18, 1, 0),
                    Position       = UDim2.new(1, -22, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex         = 5,
                }, item)
            end

            item.MouseEnter:Connect(function()
                if not isSel then Tween(item, { BackgroundColor3 = T.ElemBgHover }, 0.1) end
            end)
            item.MouseLeave:Connect(function()
                if not isSel then Tween(item, { BackgroundColor3 = T.InputBg }, 0.1) end
            end)

            item.MouseButton1Click:Connect(function()
                if multi then
                    local idx = table.find(sel, opt)
                    if idx then table.remove(sel, idx) else table.insert(sel, opt) end
                else
                    sel  = { opt }
                    open = false
                    local targetH = 44
                    Tween(wrap, { Size = UDim2.new(1, 0, 0, targetH) }, 0.2)
                    arrow.Text = "▾"
                end
                Cfg:set(flag, sel)
                UpdatePreview()
                RebuildItems()
                task.spawn(cb, multi and sel or (sel[1] or ""))
            end)

            table.insert(itemFrames, item)
        end
    end
    RebuildItems()

    -- Calculate open height
    local function OpenH()
        return 44 + math.min(#options, 6) * (ITEM_H + 3) + 8
    end

    -- Click header to open/close
    local hBtn = New("TextButton", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 4,
        Parent           = wrap,
    })
    hBtn.MouseEnter:Connect(function() Tween(wrap, { BackgroundColor3 = T.ElemBgHover }, 0.12) end)
    hBtn.MouseLeave:Connect(function() Tween(wrap, { BackgroundColor3 = T.ElemBg      }, 0.12) end)
    hBtn.MouseButton1Click:Connect(function()
        open = not open
        Tween(wrap, { Size = UDim2.new(1, 0, 0, open and OpenH() or 44) }, 0.22, Enum.EasingStyle.Quart)
        arrow.Text = open and "▴" or "▾"
        Tween(arrow, { TextColor3 = open and T.AccentBright or T.Accent }, 0.12)
    end)

    return {
        Refresh = function(_, newOpts, keepSel)
            if not keepSel then sel = {} end
            RebuildItems(newOpts)
            UpdatePreview()
            if open then
                wrap.Size = UDim2.new(1, 0, 0, OpenH())
            end
        end,
        Set = function(_, v)
            sel = type(v) == "table" and v or { tostring(v) }
            UpdatePreview()
            RebuildItems()
        end,
        Get = function()
            return multi and sel or (sel[1] or "")
        end,
    }
end

-- ────────────────────────────────────────────────────────────────────
-- KEYBIND
-- ────────────────────────────────────────────────────────────────────
local function BuildKeybind(parent, opts)
    local name  = opts.Name            or "Keybind"
    local flag  = opts.Flag            or ""
    local hold  = opts.HoldToInteract  == true
    local cb    = type(opts.Callback) == "function" and opts.Callback or function() end

    local saved = Cfg:get(flag)
    local curKey = tostring(saved or opts.CurrentKeybind or "F")
    Cfg:reg(flag, curKey)

    local row = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = T.ElemBg,
        Parent           = parent,
    })
    Corner(8, row)
    Stroke(T.ElemBorder, 1, row)

    Lbl(name, 13, T.ElemText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, row)

    local keyBtn = New("TextButton", {
        Size             = UDim2.new(0, 64, 0, 26),
        Position         = UDim2.new(1, -74, 0.5, -13),
        BackgroundColor3 = T.InputBg,
        Text             = "[" .. curKey .. "]",
        TextSize         = 11,
        TextColor3       = T.Accent,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 3,
        Parent           = row,
    })
    Corner(6, keyBtn)
    Stroke(T.InputBorder, 1, keyBtn)

    local listening = false
    keyBtn.MouseButton1Click:Connect(function()
        listening         = true
        keyBtn.Text       = "[ ... ]"
        keyBtn.TextColor3 = T.SubText
        Tween(keyBtn, { BackgroundColor3 = T.ElemBgHover }, 0.1)
    end)

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if listening then
            local kn = inp.KeyCode.Name
            -- Ignore movement keys to prevent accidental binding
            if kn ~= "Unknown" and kn ~= "W" and kn ~= "A" and kn ~= "S" and kn ~= "D" then
                curKey            = kn
                Cfg:set(flag, kn)
                keyBtn.Text       = "[" .. kn .. "]"
                keyBtn.TextColor3 = T.Accent
                Tween(keyBtn, { BackgroundColor3 = T.InputBg }, 0.1)
                listening         = false
            end
        elseif not hold and inp.KeyCode.Name == curKey then
            task.spawn(cb)
        end
    end)

    if hold then
        UserInputService.InputEnded:Connect(function(inp)
            if inp.KeyCode.Name == curKey and not listening then
                task.spawn(cb)
            end
        end)
    end

    return { Get = function() return curKey end }
end

-- ────────────────────────────────────────────────────────────────────
-- COLOR PICKER
-- ────────────────────────────────────────────────────────────────────
local function BuildColorPicker(parent, opts)
    local name = opts.Name     or "Color"
    local flag = opts.Flag     or ""
    local cb   = type(opts.Callback) == "function" and opts.Callback or function() end

    local saved = Cfg:get(flag)
    local curColor
    if saved and type(saved) == "table" then
        curColor = Color3.fromRGB(
            math.clamp(tonumber(saved.r) or 255, 0, 255),
            math.clamp(tonumber(saved.g) or 255, 0, 255),
            math.clamp(tonumber(saved.b) or 255, 0, 255)
        )
    else
        curColor = opts.Color or Color3.new(1, 1, 1)
    end
    local rgb = {
        math.round(curColor.R * 255),
        math.round(curColor.G * 255),
        math.round(curColor.B * 255),
    }
    Cfg:reg(flag, { r = rgb[1], g = rgb[2], b = rgb[3] })

    local open = false

    local wrap = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = T.ElemBg,
        ClipsDescendants = true,
        Parent           = parent,
    })
    Corner(8, wrap)
    Stroke(T.ElemBorder, 1, wrap)

    Lbl(name, 13, T.ElemText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.68, 0, 0, 44),
        Position = UDim2.new(0, 12, 0, 0),
        ZIndex   = 2,
    }, wrap)

    -- Color swatch preview
    local swatch = New("Frame", {
        Size             = UDim2.new(0, 30, 0, 22),
        Position         = UDim2.new(1, -42, 0.5, -11),
        BackgroundColor3 = curColor,
        ZIndex           = 3,
        Parent           = wrap,
    })
    Corner(6, swatch)
    Stroke(T.ElemBorder, 1, swatch)

    -- Panel for RGB sliders
    local panel = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 96),
        Position         = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = T.InputBg,
        ZIndex           = 2,
        Parent           = wrap,
    })
    Pad(8, 8, 12, 12, panel)
    List(panel, 6)

    local function ApplyColor()
        curColor = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
        swatch.BackgroundColor3 = curColor
        Cfg:set(flag, { r = rgb[1], g = rgb[2], b = rgb[3] })
        task.spawn(cb, curColor)
    end

    -- Build one RGB channel slider
    local chLabels = { "R", "G", "B" }
    local chColors = {
        Color3.fromRGB(220, 60, 60),
        Color3.fromRGB(60, 200, 60),
        Color3.fromRGB(60, 100, 220),
    }
    for i = 1, 3 do
        local chRow = New("Frame", {
            Size             = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            ZIndex           = 3,
            Parent           = panel,
        })
        Lbl(chLabels[i], 10, chColors[i], Enum.Font.GothamBold, {
            Size   = UDim2.new(0, 12, 1, 0),
            ZIndex = 4,
        }, chRow)

        local chTrack = New("Frame", {
            Size             = UDim2.new(1, -18, 0, 6),
            Position         = UDim2.new(0, 16, 0.5, -3),
            BackgroundColor3 = T.SliderTrack,
            ZIndex           = 4,
            Parent           = chRow,
        })
        Corner(3, chTrack)

        local chFill = New("Frame", {
            Size             = UDim2.new(rgb[i] / 255, 0, 1, 0),
            BackgroundColor3 = chColors[i],
            ZIndex           = 5,
            Parent           = chTrack,
        })
        Corner(3, chFill)

        local chSliding = false

        local function SetCh(relX)
            local v = math.clamp(math.round(relX * 255), 0, 255)
            rgb[i]      = v
            chFill.Size = UDim2.new(v / 255, 0, 1, 0)
            ApplyColor()
        end

        chTrack.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            chSliding = true
            SetCh(math.clamp((inp.Position.X - chTrack.AbsolutePosition.X) / chTrack.AbsoluteSize.X, 0, 1))
        end)
        OnMoved(function(inp)
            if chSliding then
                SetCh(math.clamp((inp.Position.X - chTrack.AbsolutePosition.X) / chTrack.AbsoluteSize.X, 0, 1))
            end
        end)
        OnEnded(function() chSliding = false end)
    end

    -- Toggle open/close
    local hBtn = New("TextButton", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 4,
        Parent           = wrap,
    })
    hBtn.MouseButton1Click:Connect(function()
        open = not open
        Tween(wrap, { Size = UDim2.new(1, 0, 0, open and 148 or 44) }, 0.22, Enum.EasingStyle.Quart)
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

-- ────────────────────────────────────────────────────────────────────
-- TEXT INPUT
-- ────────────────────────────────────────────────────────────────────
local function BuildInput(parent, opts)
    local name  = opts.Name                   or "Input"
    local flag  = opts.Flag                   or ""
    local ph    = opts.PlaceholderText        or "Type here..."
    local cb    = type(opts.Callback) == "function" and opts.Callback or function() end
    local clear = opts.RemoveTextAfterFocusLost ~= false

    local saved = Cfg:get(flag)
    Cfg:reg(flag, saved or "")

    local row = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = T.ElemBg,
        Parent           = parent,
    })
    Corner(8, row)
    Stroke(T.ElemBorder, 1, row)

    Lbl(name, 13, T.ElemText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.42, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        ZIndex   = 2,
    }, row)

    local box = New("TextBox", {
        Size             = UDim2.new(0.52, -8, 0, 28),
        Position         = UDim2.new(0.46, 0, 0.5, -14),
        BackgroundColor3 = T.InputBg,
        PlaceholderText  = ph,
        PlaceholderColor3= T.SubText,
        Text             = tostring(saved or ""),
        TextSize         = 12,
        TextColor3       = T.ElemText,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex           = 3,
        Parent           = row,
    })
    Corner(6, box)
    Stroke(T.InputBorder, 1, box)
    Pad(0, 0, 8, 8, box)

    box.Focused:Connect(function()
        Tween(box, { BackgroundColor3 = T.ElemBgHover }, 0.12)
    end)
    box.FocusLost:Connect(function(enter)
        Tween(box, { BackgroundColor3 = T.InputBg }, 0.12)
        if enter then
            Cfg:set(flag, box.Text)
            task.spawn(cb, box.Text)
            if clear then box.Text = "" end
        end
    end)

    return {
        Get = function() return box.Text end,
        Set = function(_, v) box.Text = tostring(v) end,
    }
end

-- ────────────────────────────────────────────────────────────────────
-- LABEL
-- ────────────────────────────────────────────────────────────────────
local function BuildLabel(parent, opts)
    local text = tostring(opts.Name or opts.Text or "")
    Lbl(text, 12, T.SubText, Enum.Font.Gotham, {
        Size        = UDim2.new(1, 0, 0, 30),
        Position    = UDim2.new(0, 12, 0, 0),
        TextWrapped = true,
    }, parent)
end

-- ═══════════════════════════════════════════════════════════════════
-- TAB PROTOTYPE — exposed API for adding elements to a tab
-- ═══════════════════════════════════════════════════════════════════
local TabProto = {}
TabProto.__index = TabProto

function TabProto:CreateSection(t)      BuildSection(self._c, t)           end
function TabProto:CreateToggle(o)       return BuildToggle(self._c, o)     end
function TabProto:CreateButton(o)       BuildButton(self._c, o)            end
function TabProto:CreateSlider(o)       return BuildSlider(self._c, o)     end
function TabProto:CreateDropdown(o)     return BuildDropdown(self._c, o)   end
function TabProto:CreateKeybind(o)      return BuildKeybind(self._c, o)    end
function TabProto:CreateColorPicker(o)  return BuildColorPicker(self._c, o)end
function TabProto:CreateInput(o)        return BuildInput(self._c, o)      end
function TabProto:CreateLabel(o)        BuildLabel(self._c, o)             end

-- ═══════════════════════════════════════════════════════════════════
-- WINDOW PROTOTYPE
-- ═══════════════════════════════════════════════════════════════════
local WinProto = {}
WinProto.__index = WinProto

function WinProto:CreateTab(name)
    -- ── Sidebar button ────────────────────────────────────────────
    local btn = New("TextButton", {
        Size             = UDim2.new(1, -10, 0, 38),
        BackgroundColor3 = T.TabIdle,
        Text             = "",
        ZIndex           = 3,
        Parent           = self._sidebar,
    })
    Corner(8, btn)

    -- Active indicator bar on the left edge
    local indicator = New("Frame", {
        Size             = UDim2.new(0, 3, 0.5, 0),
        Position         = UDim2.new(0, 0, 0.25, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 4,
        Parent           = btn,
    })
    Corner(2, indicator)

    local btnLbl = Lbl(tostring(name or "Tab"), 12, T.TabTextIdle, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        ZIndex   = 4,
    }, btn)

    -- ── Scroll frame for content ───────────────────────────────────
    local scroll = New("ScrollingFrame", {
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = T.ScrollBar,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ScrollingDirection   = Enum.ScrollingDirection.Y,
        Visible              = false,
        ZIndex               = 2,
        Parent               = self._content,
    })

    local contentFrame = New("Frame", {
        Size          = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex        = 2,
        Parent        = scroll,
    })
    Pad(8, 12, 10, 10, contentFrame)
    List(contentFrame, 6)

    -- Register tab
    local tabObj = setmetatable({ _c = contentFrame, _scroll = scroll }, TabProto)
    local entry  = { btn = btn, scroll = scroll, lbl = btnLbl, indicator = indicator }
    table.insert(self._tabs, entry)

    -- Auto-select first tab
    if #self._tabs == 1 then self:_Select(1) end

    btn.MouseEnter:Connect(function()
        if entry ~= self._active then
            Tween(btn, { BackgroundColor3 = T.TabHover }, 0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        if entry ~= self._active then
            Tween(btn, { BackgroundColor3 = T.TabIdle }, 0.12)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        for i, t in ipairs(self._tabs) do
            if t == entry then self:_Select(i); return end
        end
    end)

    return tabObj
end

function WinProto:_Select(idx)
    for i, t in ipairs(self._tabs) do
        local sel = (i == idx)
        t.scroll.Visible    = sel
        t.indicator.Visible = sel
        Tween(t.btn, {
            BackgroundColor3 = sel and T.TabActive or T.TabIdle
        }, 0.15)
        Tween(t.lbl, {
            TextColor3 = sel and T.TabTextActive or T.TabTextIdle
        }, 0.15)
        if sel then self._active = t end
    end
end

function WinProto:Notify(o)       Crimson:Notify(o)                        end
function WinProto:LoadConfiguration()
    if self._cfgFolder and self._cfgFile then
        Cfg:load(self._cfgFolder, self._cfgFile)
    end
end
function WinProto:ResetConfig()
    Cfg._data = {}
    if self._cfgFolder and self._cfgFile then
        pcall(function()
            if writefile then
                writefile(self._cfgFolder .. "/" .. self._cfgFile .. ".json", "{}")
            end
        end)
    end
end
function WinProto:Destroy()
    if self._sg and self._sg.Parent then self._sg:Destroy() end
end

-- ═══════════════════════════════════════════════════════════════════
-- Crimson:CreateWindow  — MAIN ENTRY POINT
-- ═══════════════════════════════════════════════════════════════════
function Crimson:CreateWindow(options)
    options = options or {}

    local title   = tostring(options.Name            or "Crimson")
    local ldTitle = tostring(options.LoadingTitle    or title)
    local ldSub   = tostring(options.LoadingSubtitle or "Loading...")
    local cfgOpts = type(options.ConfigurationSaving) == "table" and options.ConfigurationSaving or {}
    local cfgDir  = tostring(cfgOpts.FolderName or "CrimsonConfigs")
    local cfgFile = tostring(cfgOpts.FileName   or "Config")
    local cfgOn   = cfgOpts.Enabled == true

    -- Load config BEFORE building elements so flags are populated
    if cfgOn then Cfg:load(cfgDir, cfgFile) end

    -- Remove stale instance
    local stale = LP.PlayerGui:FindFirstChild("CrimsonGUI_v2")
    if stale then stale:Destroy() end

    -- ── ScreenGui — CRITICAL RENDERING FLAGS ──────────────────────
    -- DisplayOrder 999999 puts this above every default Roblox UI.
    -- ZIndexBehavior.Global means ZIndex is absolute, not relative.
    -- IgnoreGuiInset removes the top inset bar offset.
    local sg = New("ScreenGui", {
        Name             = "CrimsonGUI_v2",
        ResetOnSpawn     = false,
        DisplayOrder     = 999999,
        ZIndexBehavior   = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset   = true,
        Parent           = LP.PlayerGui,
    })

    -- ── Loading screen ─────────────────────────────────────────────
    local loadBg = New("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(6, 2, 2),
        ZIndex           = 200,
        Parent           = sg,
    })

    -- Scan-line texture overlay (cheap atmosphere)
    for i = 1, 40 do
        New("Frame", {
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, i / 40, 0),
            BackgroundColor3 = Color3.fromRGB(40, 5, 5),
            BackgroundTransparency = 0.88,
            BorderSizePixel  = 0,
            ZIndex           = 201,
            Parent           = loadBg,
        })
    end

    -- Crimson dot accent top-center
    local dot = New("Frame", {
        Size             = UDim2.new(0, 8, 0, 8),
        Position         = UDim2.new(0.5, -4, 0.33, -4),
        BackgroundColor3 = T.Accent,
        ZIndex           = 202,
        Parent           = loadBg,
    })
    Corner(4, dot)

    Lbl("<b>" .. ldTitle .. "</b>", 26, T.AccentBright, Enum.Font.GothamBlack, {
        Size           = UDim2.new(0.7, 0, 0, 38),
        Position       = UDim2.new(0.15, 0, 0.38, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 202,
    }, loadBg)

    Lbl(ldSub, 13, T.SubText, Enum.Font.Gotham, {
        Size           = UDim2.new(0.5, 0, 0, 22),
        Position       = UDim2.new(0.25, 0, 0.49, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 202,
    }, loadBg)

    local barBg = New("Frame", {
        Size             = UDim2.new(0.38, 0, 0, 3),
        Position         = UDim2.new(0.31, 0, 0.57, 0),
        BackgroundColor3 = T.SliderTrack,
        ZIndex           = 202,
        Parent           = loadBg,
    })
    Corner(2, barBg)

    local barFill = New("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.Accent,
        ZIndex           = 203,
        Parent           = barBg,
    })
    Corner(2, barFill)

    -- Animate out loading screen
    task.spawn(function()
        Tween(barFill, { Size = UDim2.new(1, 0, 1, 0) }, 1.1, Enum.EasingStyle.Quart)
        task.wait(1.2)
        Tween(loadBg, { BackgroundTransparency = 1 }, 0.35)
        for _, d in ipairs(loadBg:GetDescendants()) do
            pcall(function()
                Tween(d, { BackgroundTransparency = 1, TextTransparency = 1 }, 0.35)
            end)
        end
        task.wait(0.4)
        if loadBg and loadBg.Parent then loadBg:Destroy() end
    end)

    -- ── Main window frame ─────────────────────────────────────────
    local win = New("Frame", {
        Name             = "Window",
        Size             = UDim2.new(0, 640, 0, 440),
        Position         = UDim2.new(0.5, -320, 0.5, -220),
        BackgroundColor3 = T.WindowBg,
        ZIndex           = 10,
        Parent           = sg,
    })
    Corner(12, win)
    Stroke(T.WindowBorder, 1.5, win)

    -- Subtle inner shadow (faked with a slightly lighter inner frame)
    New("Frame", {
        Size             = UDim2.new(1, -2, 1, -2),
        Position         = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = Color3.fromRGB(20, 8, 8),
        BackgroundTransparency = 0.85,
        ZIndex           = 10,
        Parent           = win,
    })

    -- Optional background image layer (set via BG Image button)
    local bgImg = New("ImageLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ImageTransparency = 0.78,
        ScaleType        = Enum.ScaleType.Crop,
        Image            = "",
        ZIndex           = 10,
        Parent           = win,
    })

    -- ── Topbar ────────────────────────────────────────────────────
    local topbar = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = T.TopbarBg,
        ZIndex           = 15,
        Parent           = win,
    })
    Corner(12, topbar)
    -- Fill bottom corners so topbar is flat at the bottom
    New("Frame", {
        Size             = UDim2.new(1, 0, 0.5, 0),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = T.TopbarBg,
        BorderSizePixel  = 0,
        ZIndex           = 15,
        Parent           = topbar,
    })
    -- Bottom border line
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.TopbarBorder,
        BorderSizePixel  = 0,
        ZIndex           = 16,
        Parent           = topbar,
    })

    -- Crimson "pill" logo dot
    local logoDot = New("Frame", {
        Size             = UDim2.new(0, 10, 0, 10),
        Position         = UDim2.new(0, 12, 0.5, -5),
        BackgroundColor3 = T.Accent,
        ZIndex           = 17,
        Parent           = topbar,
    })
    Corner(5, logoDot)

    -- Title text
    Lbl(title:upper(), 12, T.AccentBright, Enum.Font.GothamBlack, {
        Size           = UDim2.new(0.5, 0, 1, 0),
        Position       = UDim2.new(0, 28, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 17,
    }, topbar)

    -- Window controls (minimize / close)
    local function MakeWinBtn(xOffset, color)
        local b = New("TextButton", {
            Size             = UDim2.new(0, 14, 0, 14),
            Position         = UDim2.new(1, xOffset, 0.5, -7),
            BackgroundColor3 = color,
            Text             = "",
            ZIndex           = 17,
            Parent           = topbar,
        })
        Corner(7, b)
        b.MouseEnter:Connect(function() Tween(b, { BackgroundColor3 = T.AccentGlow }, 0.1) end)
        b.MouseLeave:Connect(function() Tween(b, { BackgroundColor3 = color }, 0.1) end)
        return b
    end

    local closeBtn = MakeWinBtn(-20, Color3.fromRGB(210, 35, 35))
    local minBtn   = MakeWinBtn(-40, Color3.fromRGB(180, 120, 0))

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Tween(win, { Size = UDim2.new(0, 640, 0, minimized and 38 or 440) }, 0.24, Enum.EasingStyle.Quart)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(win, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.18)
        task.delay(0.2, function() if sg and sg.Parent then sg:Destroy() end end)
    end)

    -- Make draggable by the topbar
    MakeDraggable(win, topbar)

    -- Insert key toggles visibility
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or inp.KeyCode ~= Enum.KeyCode.Insert then return end
        win.Visible = not win.Visible
    end)

    -- ── Body layout ───────────────────────────────────────────────
    local body = New("Frame", {
        Size             = UDim2.new(1, 0, 1, -38),
        Position         = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
        ZIndex           = 11,
        Parent           = win,
    })

    -- ── Sidebar ───────────────────────────────────────────────────
    local sidebar = New("ScrollingFrame", {
        Size                 = UDim2.new(0, 152, 1, -8),
        Position             = UDim2.new(0, 4, 0, 4),
        BackgroundColor3     = T.SidebarBg,
        ScrollBarThickness   = 2,
        ScrollBarImageColor3 = T.ScrollBar,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ZIndex               = 12,
        Parent               = body,
    })
    Corner(10, sidebar)
    Stroke(T.SidebarBorder, 1, sidebar)

    -- Inner layout container for tab buttons
    local sidebarInner = New("Frame", {
        Size          = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex        = 13,
        Parent        = sidebar,
    })
    Pad(6, 6, 5, 5, sidebarInner)
    List(sidebarInner, 4)

    -- Vertical divider line
    New("Frame", {
        Size             = UDim2.new(0, 1, 1, -8),
        Position         = UDim2.new(0, 158, 0, 4),
        BackgroundColor3 = T.SidebarBorder,
        BorderSizePixel  = 0,
        ZIndex           = 12,
        Parent           = body,
    })

    -- ── Content area ──────────────────────────────────────────────
    local contentArea = New("Frame", {
        Size             = UDim2.new(1, -166, 1, -8),
        Position         = UDim2.new(0, 162, 0, 4),
        BackgroundTransparency = 1,
        ZIndex           = 12,
        Parent           = body,
    })

    -- ── BG Image editor (floating panel) ──────────────────────────
    local bgRow = New("TextButton", {
        Size             = UDim2.new(1, -10, 0, 28),
        BackgroundColor3 = T.AccentDim,
        Text             = "",
        LayoutOrder      = 9999,
        ZIndex           = 13,
        Parent           = sidebarInner,
    })
    Corner(8, bgRow)
    Lbl("⚙  BG Image", 10, T.SubText, Enum.Font.GothamSemiBold, {
        Size           = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 14,
    }, bgRow)

    local bgEditor = New("Frame", {
        Size             = UDim2.new(0, 290, 0, 118),
        Position         = UDim2.new(0, 166, 1, -126),
        BackgroundColor3 = T.TopbarBg,
        Visible          = false,
        ZIndex           = 150,
        Parent           = sg,  -- parent to ScreenGui so it's always on top
    })
    Corner(10, bgEditor)
    Stroke(T.TopbarBorder, 1, bgEditor)
    Pad(10, 10, 10, 10, bgEditor)
    List(bgEditor, 6)

    Lbl("Custom Background Image", 11, T.AccentBright, Enum.Font.GothamBold, {
        Size           = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 151,
    }, bgEditor)

    Lbl("Paste rbxassetid:// or URL", 9, T.SubText, Enum.Font.Gotham, {
        Size           = UDim2.new(1, 0, 0, 13),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 151,
    }, bgEditor)

    local bgInput = New("TextBox", {
        Size             = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = T.InputBg,
        PlaceholderText  = "rbxassetid://...",
        PlaceholderColor3 = T.SubText,
        Text             = "",
        TextSize         = 11,
        TextColor3       = T.ElemText,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex           = 151,
        Parent           = bgEditor,
    })
    Corner(6, bgInput)
    Stroke(T.InputBorder, 1, bgInput)
    Pad(0, 0, 6, 6, bgInput)

    local bgBtnRow = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        ZIndex           = 151,
        Parent           = bgEditor,
    })
    List(bgBtnRow, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left)

    local function SmallBtn(text, color, parent2, onClick)
        local b = New("TextButton", {
            Size             = UDim2.new(0.48, 0, 1, 0),
            BackgroundColor3 = color,
            Text             = text,
            TextSize         = 10,
            TextColor3       = Color3.new(1, 1, 1),
            Font             = Enum.Font.GothamSemiBold,
            ZIndex           = 152,
            Parent           = parent2,
        })
        Corner(6, b)
        b.MouseButton1Click:Connect(onClick)
        return b
    end

    SmallBtn("Apply", T.Accent,    bgBtnRow, function()
        local id = bgInput.Text:match("(%d+)") or ""
        bgImg.Image = id ~= "" and ("rbxassetid://" .. id) or bgInput.Text
    end)
    SmallBtn("Clear", T.AccentDim, bgBtnRow, function()
        bgImg.Image = ""
        bgInput.Text = ""
    end)

    bgRow.MouseButton1Click:Connect(function()
        bgEditor.Visible = not bgEditor.Visible
    end)

    -- ── Auto-save ─────────────────────────────────────────────────
    if cfgOn then
        task.spawn(function()
            while sg and sg.Parent do
                task.wait(60)
                Cfg:save(cfgDir, cfgFile)
            end
        end)
    end

    -- ── Return window object ──────────────────────────────────────
    local winObj = setmetatable({
        _sg        = sg,
        _sidebar   = sidebarInner,
        _content   = contentArea,
        _tabs      = {},
        _active    = nil,
        _cfgFolder = cfgOn and cfgDir  or nil,
        _cfgFile   = cfgOn and cfgFile or nil,
    }, WinProto)

    return winObj
end

-- ═══════════════════════════════════════════════════════════════════
-- STATIC HELPERS
-- ═══════════════════════════════════════════════════════════════════
function Crimson:Destroy()
    pcall(function()
        local g = LP.PlayerGui:FindFirstChild("CrimsonGUI_v2")
        if g then g:Destroy() end
        local n = LP.PlayerGui:FindFirstChild("CrimsonNotifs_v2")
        if n then n:Destroy() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════
return Crimson
