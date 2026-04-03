--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ██████╗██████╗ ██╗███╗   ███╗███████╗ ██████╗ ███╗   ██╗
 ██╔════╝██╔══██╗██║████╗ ████║██╔════╝██╔═══██╗████╗  ██║
 ██║     ██████╔╝██║██╔████╔██║███████╗██║   ██║██╔██╗ ██║
 ██║     ██╔══██╗██║██║╚██╔╝██║╚════██║██║   ██║██║╚██╗██║
 ╚██████╗██║  ██║██║██║ ╚═╝ ██║███████║╚██████╔╝██║ ╚████║
  ╚═════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝
 Crimson GUI  ·  v3.0  ·  Obsidian Edition
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 QUICK-START
 ───────────
   local Lib = loadstring(game:HttpGet("YOUR_RAW_URL"))()

   local Win = Lib:CreateWindow({
       Name            = "My Script",
       LoadingTitle    = "My Script",
       LoadingSubtitle = "Initializing...",
       ConfigurationSaving = { Enabled = true, FolderName = "MyCfg", FileName = "cfg" },
   })

   local Tab = Win:CreateTab("Combat")

   Tab:CreateSection("Header")
   Tab:CreateToggle({ Name="Toggle",   CurrentValue=false, Flag="t1", Callback=function(v) end })
   Tab:CreateButton({ Name="Button",   Callback=function() end })
   Tab:CreateSlider({ Name="Slider",   Range={0,100}, Increment=1, CurrentValue=50, Flag="s1", Callback=function(v) end })
   Tab:CreateDropdown({ Name="Drop",  Options={"A","B"}, CurrentOption={}, MultipleOptions=false, Flag="d1", Callback=function(v) end })
   Tab:CreateKeybind({ Name="Keybind", CurrentKeybind="F", HoldToInteract=false, Flag="k1", Callback=function() end })
   Tab:CreateColorPicker({ Name="Color", Color=Color3.new(1,0,0), Flag="c1", Callback=function(c) end })
   Tab:CreateInput({ Name="Input",    PlaceholderText="...", Flag="i1", Callback=function(s) end })
   Tab:CreateLabel({ Name="Some label text" })

   Lib:Notify({ Title="Hello", Content="World", Duration=4 })
   Lib:Destroy()
   Win:LoadConfiguration()
   Win:ResetConfig()

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]

-- ─────────────────────────────────────────────────────────────────────────────
-- [1]  SERVICES
-- ─────────────────────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")

local LP = Players.LocalPlayer

-- ─────────────────────────────────────────────────────────────────────────────
-- [2]  THEME  — every color decision in one place; easy to reskin
-- ─────────────────────────────────────────────────────────────────────────────
local C = {
    -- ── Window ──────────────────────────────────────────────────────────────
    WinBg           = Color3.fromRGB(12, 12, 14),   -- near-black obsidian
    WinBorder       = Color3.fromRGB(38,  9,  9),
    TopBg           = Color3.fromRGB(17,  7,  7),
    TopBorder       = Color3.fromRGB(130, 22, 22),
    TopTitle        = Color3.fromRGB(240, 200, 200),

    -- ── Sidebar ─────────────────────────────────────────────────────────────
    SideBg          = Color3.fromRGB(15,  6,  6),
    SideBorder      = Color3.fromRGB(33,  9,  9),
    TabIdle         = Color3.fromRGB(15,  6,  6),
    TabHover        = Color3.fromRGB(28, 10, 10),
    TabActive       = Color3.fromRGB(130, 18, 18),
    TabTextIdle     = Color3.fromRGB(160, 110, 110),
    TabTextActive   = Color3.fromRGB(255, 218, 218),
    TabIndicator    = Color3.fromRGB(210, 30, 30),

    -- ── Element cards ────────────────────────────────────────────────────────
    CardBg          = Color3.fromRGB(19,  8,  8),
    CardBgHover     = Color3.fromRGB(26, 11, 11),
    CardBgPress     = Color3.fromRGB(85, 14, 14),
    CardBorder      = Color3.fromRGB(42, 13, 13),
    CardText        = Color3.fromRGB(232, 210, 210),
    CardSub         = Color3.fromRGB(145, 95, 95),

    -- ── Accent (crimson) ─────────────────────────────────────────────────────
    Accent          = Color3.fromRGB(190, 24, 24),
    AccentHi        = Color3.fromRGB(235, 55, 55),
    AccentDim       = Color3.fromRGB(95,  13, 13),
    AccentGlow      = Color3.fromRGB(255, 85, 85),

    -- ── Toggle ───────────────────────────────────────────────────────────────
    TglOn           = Color3.fromRGB(205, 26, 26),
    TglOff          = Color3.fromRGB(42,  14, 14),
    TglKnob         = Color3.fromRGB(245, 215, 215),

    -- ── Slider ───────────────────────────────────────────────────────────────
    SlTrack         = Color3.fromRGB(28,  9,  9),
    SlFill          = Color3.fromRGB(190, 24, 24),
    SlKnob          = Color3.fromRGB(238, 82, 82),

    -- ── Input / Dropdown ─────────────────────────────────────────────────────
    InputBg         = Color3.fromRGB(10,  4,  4),
    InputBorder     = Color3.fromRGB(52,  15, 15),

    -- ── Section ──────────────────────────────────────────────────────────────
    SecLine         = Color3.fromRGB(36,  11, 11),
    SecText         = Color3.fromRGB(135, 42, 42),

    -- ── Notification ─────────────────────────────────────────────────────────
    NotifBg         = Color3.fromRGB(15,  5,  5),
    NotifBorder     = Color3.fromRGB(175, 24, 24),
    NotifTitle      = Color3.fromRGB(238, 212, 212),
    NotifSub        = Color3.fromRGB(148, 98, 98),

    -- ── Scroll bar ───────────────────────────────────────────────────────────
    Scroll          = Color3.fromRGB(75,  17, 17),
}

-- ─────────────────────────────────────────────────────────────────────────────
-- [3]  LOW-LEVEL UTILITIES
-- ─────────────────────────────────────────────────────────────────────────────

--[[
  New(className, properties)
  Creates an Instance and sets every property before parenting,
  which avoids the one-frame flicker that occurs when Parent is set first.
]]
local function New(cls, props)
    local obj    = Instance.new(cls)
    local parent = nil
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v          -- defer parenting until all props are set
        else
            pcall(function() obj[k] = v end)
        end
    end
    if parent then obj.Parent = parent end
    return obj
end

-- Shorthand UICorner
local function Rnd(r, obj)
    New("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = obj })
end

-- Shorthand UIStroke
local function Strk(col, thk, obj)
    New("UIStroke", {
        Color           = col or Color3.new(1, 1, 1),
        Thickness       = thk or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent          = obj,
    })
end

-- Shorthand UIPadding
local function Pad(t, b, l, r, obj)
    New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
        Parent        = obj,
    })
end

-- Shorthand UIListLayout (vertical by default)
local function VList(obj, gap)
    New("UIListLayout", {
        Padding             = UDim.new(0, gap or 4),
        FillDirection       = Enum.FillDirection.Vertical,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent              = obj,
    })
end

-- Shorthand UIListLayout (horizontal)
local function HList(obj, gap)
    New("UIListLayout", {
        Padding             = UDim.new(0, gap or 4),
        FillDirection       = Enum.FillDirection.Horizontal,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        Parent              = obj,
    })
end

--[[
  Txt(text, size, color, font, extraProps, parent)
  Creates a TextLabel with sane defaults.
  extraProps table overrides individual properties.
]]
local function Txt(text, size, color, font, extra, parent)
    local lbl = New("TextLabel", {
        Text                   = tostring(text  or ""),
        TextSize               = size            or 13,
        TextColor3             = color           or C.CardText,
        Font                   = font            or Enum.Font.GothamSemiBold,
        BackgroundTransparency = 1,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        RichText               = true,
        Size                   = UDim2.new(1, 0, 1, 0),
    })
    for k, v in pairs(extra or {}) do pcall(function() lbl[k] = v end) end
    if parent then lbl.Parent = parent end
    return lbl
end

--[[
  Tween(obj, goals, t, style, dir)
  Safe TweenService wrapper. Silently skips if obj is destroyed.
]]
local function Tween(obj, goals, t, style, dir)
    if not (obj and obj.Parent) then return end
    TweenService:Create(
        obj,
        TweenInfo.new(
            t     or 0.18,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out
        ),
        goals
    ):Play()
end

--[[
  Drag(frame, handle)
  Makes `frame` draggable by clicking and dragging `handle`.
  Uses a single UIS.InputChanged connection (not per-element).
]]
local function Drag(frame, handle)
    local active, origin, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        active   = true
        origin   = i.Position
        startPos = frame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then active = false end
        end)
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not active or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = i.Position - origin
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [4]  GLOBAL INPUT DISPATCHER
--      One connection for mouse-move and mouse-release that every
--      draggable element (sliders, color pickers) subscribes to.
--      This prevents N connections stacking up for N elements.
-- ─────────────────────────────────────────────────────────────────────────────
local _moveSubs = {} -- { fn }
local _upSubs   = {} -- { fn }

UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    for _, fn in ipairs(_moveSubs) do pcall(fn, i) end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    for _, fn in ipairs(_upSubs) do pcall(fn) end
end)

local function OnMove(fn)  table.insert(_moveSubs, fn) end
local function OnUp(fn)    table.insert(_upSubs,   fn) end

-- ─────────────────────────────────────────────────────────────────────────────
-- [5]  CONFIG / FLAG SYSTEM
--      Persists toggle/slider/dropdown values to a JSON file on disk
--      (writefile / readfile). Gracefully degrades if unavailable.
-- ─────────────────────────────────────────────────────────────────────────────
local Config = {}
Config._store = {}

function Config:reg(flag, default)
    -- Only set the default if not already present (don't overwrite loaded data)
    if flag and flag ~= "" and self._store[flag] == nil then
        self._store[flag] = default
    end
end

function Config:get(flag)
    return self._store[flag]
end

function Config:set(flag, val)
    if flag and flag ~= "" then self._store[flag] = val end
end

function Config:save(dir, file)
    if not writefile then return end
    pcall(function()
        if not isfolder(dir) then makefolder(dir) end
        local ok, enc = pcall(HttpService.JSONEncode, HttpService, self._store)
        if ok then writefile(dir .. "/" .. file .. ".json", enc) end
    end)
end

function Config:load(dir, file)
    if not (readfile and isfile) then return end
    pcall(function()
        local path = dir .. "/" .. file .. ".json"
        if not isfile(path) then return end
        local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(path))
        if ok and type(data) == "table" then
            for k, v in pairs(data) do self._store[k] = v end
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [6]  NOTIFICATION LAYER
--      Lives in its own ScreenGui at DisplayOrder 999998 so it never
--      overlaps with modal dropdowns but always sits above game UI.
-- ─────────────────────────────────────────────────────────────────────────────
local _notifGui    = nil
local _notifColumn = nil

local function EnsureNotifGui()
    -- Re-use if still alive
    local existing = LP.PlayerGui:FindFirstChild("_CrimsonNotifs")
    if not existing then
        existing = New("ScreenGui", {
            Name           = "_CrimsonNotifs",
            ResetOnSpawn   = false,
            DisplayOrder   = 999998,
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            IgnoreGuiInset = true,
            Parent         = LP.PlayerGui,
        })
    end
    _notifGui = existing

    if not _notifColumn or not _notifColumn.Parent then
        _notifColumn = New("Frame", {
            Name                   = "Column",
            Size                   = UDim2.new(0, 295, 1, -16),
            Position               = UDim2.new(1, -305, 0, 8),
            BackgroundTransparency = 1,
            Parent                 = _notifGui,
        })
        VList(_notifColumn, 8)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [7]  ELEMENT BUILDERS  (private, called via TabProto methods)
-- ─────────────────────────────────────────────────────────────────────────────

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  SECTION DIVIDER                                                        │
-- └─────────────────────────────────────────────────────────────────────────┘
local function BuildSection(parent, title)
    title = tostring(title or ""):upper()

    local row = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent                 = parent,
    })

    -- Full-width rule line
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = C.SecLine,
        BorderSizePixel  = 0,
        Parent           = row,
    })

    -- Text pill sitting on the rule
    local pillW = math.min(#title * 7 + 22, 260)
    local pill  = New("Frame", {
        Size             = UDim2.new(0, pillW, 0, 17),
        Position         = UDim2.new(0, 8, 0.5, -8),
        BackgroundColor3 = C.WinBg,
        BorderSizePixel  = 0,
        Parent           = row,
    })
    Rnd(4, pill)

    Txt(title, 10, C.SecText, Enum.Font.GothamBold, {
        Size           = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, pill)
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  TOGGLE                                                                 │
-- └─────────────────────────────────────────────────────────────────────────┘
local function BuildToggle(parent, opts)
    local name = opts.Name    or "Toggle"
    local flag = opts.Flag    or ""
    local cb   = type(opts.Callback) == "function" and opts.Callback or function() end

    -- Resolve initial value: saved config → option default → false
    local saved = Config:get(flag)
    local state = (saved ~= nil) and (saved == true) or (opts.CurrentValue == true)
    Config:reg(flag, state)

    -- ── Card ──────────────────────────────────────────────────────────────
    local card = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.CardBg,
        Parent           = parent,
    })
    Rnd(8, card)
    Strk(C.CardBorder, 1, card)

    -- Element name
    Txt(name, 13, C.CardText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(1, -68, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
    }, card)

    -- ── Toggle track (pill shape) ────────────────────────────────────────
    local track = New("Frame", {
        Size             = UDim2.new(0, 44, 0, 23),
        Position         = UDim2.new(1, -56, 0.5, -11),
        BackgroundColor3 = state and C.TglOn or C.TglOff,
        Parent           = card,
    })
    Rnd(12, track)

    -- ── Knob ────────────────────────────────────────────────────────────
    local knob = New("Frame", {
        Size             = UDim2.new(0, 19, 0, 19),
        Position         = state and UDim2.new(0, 23, 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = C.TglKnob,
        ZIndex           = 2,
        Parent           = track,
    })
    Rnd(10, knob)

    -- ── State setter (used by both click and external :Set) ──────────────
    local function Apply(val, silent)
        state = val == true
        Config:set(flag, state)
        Tween(track, { BackgroundColor3 = state and C.TglOn or C.TglOff }, 0.17)
        Tween(knob,  { Position = state and UDim2.new(0, 23, 0, 2) or UDim2.new(0, 2, 0, 2) }, 0.17)
        if not silent then task.spawn(cb, state) end
    end

    -- Fire callback on load (deferred so all tabs finish building first)
    task.defer(function() task.spawn(cb, state) end)

    -- ── Transparent click overlay ────────────────────────────────────────
    local btn = New("TextButton", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "",
        ZIndex                 = 4,
        Parent                 = card,
    })
    btn.MouseEnter:Connect(function()    Tween(card, { BackgroundColor3 = C.CardBgHover }, 0.12) end)
    btn.MouseLeave:Connect(function()    Tween(card, { BackgroundColor3 = C.CardBg      }, 0.12) end)
    btn.MouseButton1Click:Connect(function() Apply(not state) end)

    return {
        Set = function(_, v) Apply(v, false) end,
        Get = function()     return state    end,
    }
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  BUTTON                                                                 │
-- └─────────────────────────────────────────────────────────────────────────┘
local function BuildButton(parent, opts)
    local name = opts.Name or "Button"
    local cb   = type(opts.Callback) == "function" and opts.Callback or function() end
    local busy = false -- debounce

    local card = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = C.CardBg,
        Parent           = parent,
    })
    Rnd(8, card)
    Strk(C.CardBorder, 1, card)

    -- Crimson left-edge accent bar
    New("Frame", {
        Size             = UDim2.new(0, 3, 0.52, 0),
        Position         = UDim2.new(0, 0, 0.24, 0),
        BackgroundColor3 = C.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = card,
    })

    Txt(name, 13, C.CardText, Enum.Font.GothamSemiBold, {
        Size           = UDim2.new(1, -18, 1, 0),
        Position       = UDim2.new(0, 16, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    local btn = New("TextButton", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "",
        ZIndex                 = 3,
        Parent                 = card,
    })
    btn.MouseEnter:Connect(function()
        Tween(card, { BackgroundColor3 = C.CardBgHover }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween(card, { BackgroundColor3 = C.CardBg }, 0.12)
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(card, { BackgroundColor3 = C.CardBgPress }, 0.07)
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(card, { BackgroundColor3 = C.CardBgHover }, 0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        task.spawn(cb)
        task.delay(0.22, function() busy = false end)
    end)
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  SLIDER                                                                 │
-- └─────────────────────────────────────────────────────────────────────────┘
local function BuildSlider(parent, opts)
    local name = opts.Name    or "Slider"
    local rng  = opts.Range   or {0, 100}
    local mn   = tonumber(rng[1]) or 0
    local mx   = tonumber(rng[2]) or 100
    if mn >= mx then mx = mn + 1 end
    local step = tonumber(opts.Increment) or 1
    local flag = opts.Flag    or ""
    local cb   = type(opts.Callback) == "function" and opts.Callback or function() end

    local saved = Config:get(flag)
    local val   = math.clamp(tonumber(saved) or tonumber(opts.CurrentValue) or mn, mn, mx)
    Config:reg(flag, val)

    -- ── Card (taller to accommodate track) ──────────────────────────────
    local card = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = C.CardBg,
        Parent           = parent,
    })
    Rnd(8, card)
    Strk(C.CardBorder, 1, card)

    -- Name (top-left)
    Txt(name, 13, C.CardText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.62, 0, 0, 24),
        Position = UDim2.new(0, 14, 0, 6),
    }, card)

    -- Live value (top-right, crimson)
    local valLbl = Txt(tostring(val), 12, C.Accent, Enum.Font.GothamBold, {
        Size           = UDim2.new(0.35, 0, 0, 24),
        Position       = UDim2.new(0.63, 0, 0, 6),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, card)

    -- ── Track background ─────────────────────────────────────────────────
    local track = New("Frame", {
        Size             = UDim2.new(1, -28, 0, 6),
        Position         = UDim2.new(0, 14, 0, 40),
        BackgroundColor3 = C.SlTrack,
        ZIndex           = 2,
        Parent           = card,
    })
    Rnd(3, track)

    -- Proportion helper
    local function pct() return (mx ~= mn) and ((val - mn) / (mx - mn)) or 0 end

    -- ── Fill bar ─────────────────────────────────────────────────────────
    local fill = New("Frame", {
        Size             = UDim2.new(pct(), 0, 1, 0),
        BackgroundColor3 = C.SlFill,
        ZIndex           = 3,
        Parent           = track,
    })
    Rnd(3, fill)

    -- ── Draggable knob circle ────────────────────────────────────────────
    local knob = New("Frame", {
        Size             = UDim2.new(0, 15, 0, 15),
        Position         = UDim2.new(pct(), -7, 0.5, -7),
        BackgroundColor3 = C.SlKnob,
        ZIndex           = 4,
        Parent           = track,
    })
    Rnd(8, knob)

    -- ── Commit a new value ───────────────────────────────────────────────
    local function SetVal(v)
        v   = math.clamp(math.round(v / step) * step, mn, mx)
        val = v
        Config:set(flag, v)
        local p = pct()
        Tween(fill, { Size = UDim2.new(p, 0, 1, 0) },          0.06)
        Tween(knob, { Position = UDim2.new(p, -7, 0.5, -7) },  0.06)
        valLbl.Text = tostring(v)
        task.spawn(cb, v)
    end

    -- ── Drag logic ───────────────────────────────────────────────────────
    local dragging = false

    local function DragTo(i)
        local rel = (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        SetVal(mn + (mx - mn) * math.clamp(rel, 0, 1))
    end

    -- Click anywhere on track
    track.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging = true
        DragTo(i)
    end)
    -- Global move/up listeners (shared dispatcher, zero extra connections)
    OnMove(function(i) if dragging then DragTo(i) end end)
    OnUp(function()    dragging = false end)

    -- Knob glow on hover
    knob.MouseEnter:Connect(function() Tween(knob, { BackgroundColor3 = C.AccentGlow }, 0.1) end)
    knob.MouseLeave:Connect(function() Tween(knob, { BackgroundColor3 = C.SlKnob     }, 0.1) end)

    task.defer(function() task.spawn(cb, val) end)

    return {
        Set = SetVal,
        Get = function() return val end,
    }
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  DROPDOWN                                                               │
-- └─────────────────────────────────────────────────────────────────────────┘
local function BuildDropdown(parent, opts)
    local name    = opts.Name            or "Dropdown"
    local flag    = opts.Flag            or ""
    local multi   = opts.MultipleOptions == true
    local cb      = type(opts.Callback) == "function" and opts.Callback or function() end
    local options = type(opts.Options) == "table" and opts.Options or {}

    local saved = Config:get(flag)
    local sel   = {}
    if saved ~= nil then
        sel = type(saved) == "table" and saved
              or (tostring(saved) ~= "" and {tostring(saved)} or {})
    elseif opts.CurrentOption ~= nil then
        sel = type(opts.CurrentOption) == "table" and opts.CurrentOption
              or (tostring(opts.CurrentOption) ~= "" and {tostring(opts.CurrentOption)} or {})
    end
    Config:reg(flag, sel)

    local ITEM_H  = 30   -- height of each option row
    local ITEM_SP = 3    -- gap between rows
    local PAD_V   = 8    -- top+bottom inner padding of list
    local open    = false

    -- ── Outer wrapper (clips when closed) ──────────────────────────────
    local wrap = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.CardBg,
        ClipsDescendants = true,
        Parent           = parent,
    })
    Rnd(8, wrap)
    Strk(C.CardBorder, 1, wrap)

    -- ── Header (always visible) ──────────────────────────────────────────
    Txt(name, 13, C.CardText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.5, 0, 0, 46),
        Position = UDim2.new(0, 14, 0, 0),
        ZIndex   = 2,
    }, wrap)

    local preview = Txt("None", 12, C.CardSub, Enum.Font.Gotham, {
        Size           = UDim2.new(0.38, 0, 0, 46),
        Position       = UDim2.new(0.5, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = 2,
    }, wrap)

    local arrow = Txt("▾", 14, C.Accent, Enum.Font.GothamBold, {
        Size           = UDim2.new(0, 24, 0, 46),
        Position       = UDim2.new(1, -28, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 2,
    }, wrap)

    -- ── Option list (shown below header when open) ────────────────────
    local listFrame = New("Frame", {
        Size             = UDim2.new(1, -16, 0, 0),
        Position         = UDim2.new(0, 8, 0, 50),
        BackgroundTransparency = 1,
        ZIndex           = 3,
        Parent           = wrap,
    })
    VList(listFrame, ITEM_SP)

    -- How tall the open state should be
    local function OpenHeight()
        local rows = math.min(#options, 6)
        local listH = rows * ITEM_H + math.max(0, rows - 1) * ITEM_SP + PAD_V
        return 46 + listH + 8  -- 8 = bottom gap
    end

    -- Update the preview label text
    local function RefreshPreview()
        if #sel == 0 then
            preview.Text      = "None"
            preview.TextColor3 = C.CardSub
        elseif #sel == 1 then
            preview.Text       = sel[1]
            preview.TextColor3 = C.CardText
        else
            preview.Text       = sel[1] .. "  +" .. (#sel - 1)
            preview.TextColor3 = C.CardText
        end
    end
    RefreshPreview()

    local itemObjs = {}

    -- Rebuild option rows (called on init and whenever options change)
    local function RebuildList(newOpts)
        options = type(newOpts) == "table" and newOpts or options
        for _, f in ipairs(itemObjs) do if f and f.Parent then f:Destroy() end end
        itemObjs = {}

        for _, opt in ipairs(options) do
            local isSel = table.find(sel, opt) ~= nil

            local row = New("TextButton", {
                Size             = UDim2.new(1, 0, 0, ITEM_H),
                BackgroundColor3 = isSel and C.AccentDim or C.InputBg,
                Text             = "",
                ZIndex           = 4,
                Parent           = listFrame,
            })
            Rnd(6, row)
            if isSel then Strk(C.Accent, 1, row) end

            Txt(opt, 12, isSel and C.AccentHi or C.CardText, Enum.Font.Gotham, {
                Size     = UDim2.new(1, -32, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                ZIndex   = 5,
            }, row)

            -- Checkmark for selected items
            if isSel then
                Txt("✓", 11, C.AccentHi, Enum.Font.GothamBold, {
                    Size           = UDim2.new(0, 20, 1, 0),
                    Position       = UDim2.new(1, -24, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex         = 5,
                }, row)
            end

            row.MouseEnter:Connect(function()
                if not isSel then Tween(row, { BackgroundColor3 = C.CardBgHover }, 0.1) end
            end)
            row.MouseLeave:Connect(function()
                if not isSel then Tween(row, { BackgroundColor3 = C.InputBg }, 0.1) end
            end)

            row.MouseButton1Click:Connect(function()
                if multi then
                    local idx = table.find(sel, opt)
                    if idx then table.remove(sel, idx) else table.insert(sel, opt) end
                else
                    sel  = {opt}
                    open = false
                    Tween(wrap, { Size = UDim2.new(1, 0, 0, 46) }, 0.2)
                    Tween(arrow, { TextColor3 = C.Accent }, 0.12)
                    arrow.Text = "▾"
                end
                Config:set(flag, sel)
                RefreshPreview()
                RebuildList()
                task.spawn(cb, multi and sel or (sel[1] or ""))
            end)

            table.insert(itemObjs, row)
        end

        -- Re-size list if already open
        if open then
            listFrame.Size = UDim2.new(1, -16, 0, OpenHeight() - 54)
        end
    end
    RebuildList()

    -- ── Header click → open / close ──────────────────────────────────────
    local hBtn = New("TextButton", {
        Size                   = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Text                   = "",
        ZIndex                 = 3,
        Parent                 = wrap,
    })
    hBtn.MouseEnter:Connect(function() Tween(wrap, { BackgroundColor3 = C.CardBgHover }, 0.12) end)
    hBtn.MouseLeave:Connect(function() Tween(wrap, { BackgroundColor3 = C.CardBg      }, 0.12) end)

    hBtn.MouseButton1Click:Connect(function()
        open = not open
        Tween(wrap,  { Size = UDim2.new(1, 0, 0, open and OpenHeight() or 46) }, 0.22, Enum.EasingStyle.Quart)
        Tween(arrow, { TextColor3 = open and C.AccentHi or C.Accent }, 0.12)
        arrow.Text = open and "▴" or "▾"
    end)

    return {
        Refresh = function(_, newOpts, keepSel)
            if not keepSel then sel = {} end
            RebuildList(newOpts)
            RefreshPreview()
        end,
        Set = function(_, v)
            sel = type(v) == "table" and v or {tostring(v)}
            RefreshPreview()
            RebuildList()
        end,
        Get = function()
            return multi and sel or (sel[1] or "")
        end,
    }
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  KEYBIND                                                                │
-- └─────────────────────────────────────────────────────────────────────────┘
local function BuildKeybind(parent, opts)
    local name = opts.Name           or "Keybind"
    local flag = opts.Flag           or ""
    local hold = opts.HoldToInteract == true
    local cb   = type(opts.Callback) == "function" and opts.Callback or function() end

    local saved  = Config:get(flag)
    local curKey = tostring(saved or opts.CurrentKeybind or "F")
    Config:reg(flag, curKey)

    local card = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.CardBg,
        Parent           = parent,
    })
    Rnd(8, card)
    Strk(C.CardBorder, 1, card)

    Txt(name, 13, C.CardText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
    }, card)

    -- Pill button showing the current key
    local keyBtn = New("TextButton", {
        Size             = UDim2.new(0, 68, 0, 27),
        Position         = UDim2.new(1, -78, 0.5, -13),
        BackgroundColor3 = C.InputBg,
        Text             = "[" .. curKey .. "]",
        TextSize         = 11,
        TextColor3       = C.Accent,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 3,
        Parent           = card,
    })
    Rnd(7, keyBtn)
    Strk(C.InputBorder, 1, keyBtn)

    local listening = false

    keyBtn.MouseButton1Click:Connect(function()
        listening         = true
        keyBtn.Text       = "[ ··· ]"
        keyBtn.TextColor3 = C.CardSub
        Tween(keyBtn, { BackgroundColor3 = C.CardBgHover }, 0.1)
    end)

    -- Single UIS.InputBegan connection (not per-element)
    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if listening then
            local kn = i.KeyCode.Name
            -- Ignore WASD so accidental move binds don't happen
            local ignore = {Unknown=true, W=true, A=true, S=true, D=true}
            if not ignore[kn] then
                curKey            = kn
                Config:set(flag, kn)
                keyBtn.Text       = "[" .. kn .. "]"
                keyBtn.TextColor3 = C.Accent
                Tween(keyBtn, { BackgroundColor3 = C.InputBg }, 0.1)
                listening         = false
            end
        elseif not hold and i.KeyCode.Name == curKey then
            task.spawn(cb)
        end
    end)

    if hold then
        UserInputService.InputEnded:Connect(function(i)
            if not listening and i.KeyCode.Name == curKey then
                task.spawn(cb)
            end
        end)
    end

    return { Get = function() return curKey end }
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  COLOR PICKER  (R / G / B sliders)                                      │
-- └─────────────────────────────────────────────────────────────────────────┘
local function BuildColorPicker(parent, opts)
    local name = opts.Name    or "Color"
    local flag = opts.Flag    or ""
    local cb   = type(opts.Callback) == "function" and opts.Callback or function() end

    -- Resolve saved color
    local saved = Config:get(flag)
    local curC
    if saved and type(saved) == "table" then
        curC = Color3.fromRGB(
            math.clamp(tonumber(saved.r) or 255, 0, 255),
            math.clamp(tonumber(saved.g) or 255, 0, 255),
            math.clamp(tonumber(saved.b) or 255, 0, 255)
        )
    else
        curC = (type(opts.Color) == "userdata" and opts.Color) or Color3.new(1, 1, 1)
    end
    local rgb = { math.round(curC.R*255), math.round(curC.G*255), math.round(curC.B*255) }
    Config:reg(flag, { r = rgb[1], g = rgb[2], b = rgb[3] })

    local open = false

    local wrap = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.CardBg,
        ClipsDescendants = true,
        Parent           = parent,
    })
    Rnd(8, wrap)
    Strk(C.CardBorder, 1, wrap)

    Txt(name, 13, C.CardText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.65, 0, 0, 46),
        Position = UDim2.new(0, 14, 0, 0),
        ZIndex   = 2,
    }, wrap)

    -- Color swatch
    local swatch = New("Frame", {
        Size             = UDim2.new(0, 32, 0, 22),
        Position         = UDim2.new(1, -44, 0.5, -11),
        BackgroundColor3 = curC,
        ZIndex           = 3,
        Parent           = wrap,
    })
    Rnd(6, swatch)
    Strk(C.CardBorder, 1, swatch)

    -- ── RGB channel panel ─────────────────────────────────────────────
    local panel = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 102),
        Position         = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = C.InputBg,
        ZIndex           = 2,
        Parent           = wrap,
    })
    Pad(8, 8, 14, 14, panel)
    VList(panel, 6)

    local function PushColor()
        curC = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
        swatch.BackgroundColor3 = curC
        Config:set(flag, { r = rgb[1], g = rgb[2], b = rgb[3] })
        task.spawn(cb, curC)
    end

    -- Channel labels and their accent colors
    local channels = {
        { "R", Color3.fromRGB(218, 58, 58)  },
        { "G", Color3.fromRGB(58,  200, 78) },
        { "B", Color3.fromRGB(58,  110, 220)},
    }
    for i, ch in ipairs(channels) do
        local chRow = New("Frame", {
            Size                   = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            ZIndex                 = 3,
            Parent                 = panel,
        })
        Txt(ch[1], 10, ch[2], Enum.Font.GothamBold, {
            Size   = UDim2.new(0, 12, 1, 0),
            ZIndex = 4,
        }, chRow)

        local chTrack = New("Frame", {
            Size             = UDim2.new(1, -18, 0, 6),
            Position         = UDim2.new(0, 16, 0.5, -3),
            BackgroundColor3 = C.SlTrack,
            ZIndex           = 4,
            Parent           = chRow,
        })
        Rnd(3, chTrack)

        local chFill = New("Frame", {
            Size             = UDim2.new(rgb[i]/255, 0, 1, 0),
            BackgroundColor3 = ch[2],
            ZIndex           = 5,
            Parent           = chTrack,
        })
        Rnd(3, chFill)

        local chDrag = false
        local function SetCh(relX)
            local v   = math.clamp(math.round(relX * 255), 0, 255)
            rgb[i]    = v
            chFill.Size = UDim2.new(v/255, 0, 1, 0)
            PushColor()
        end

        chTrack.InputBegan:Connect(function(i2)
            if i2.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            chDrag = true
            SetCh(math.clamp((i2.Position.X - chTrack.AbsolutePosition.X)/chTrack.AbsoluteSize.X, 0, 1))
        end)
        OnMove(function(i2)
            if chDrag then
                SetCh(math.clamp((i2.Position.X - chTrack.AbsolutePosition.X)/chTrack.AbsoluteSize.X, 0, 1))
            end
        end)
        OnUp(function() chDrag = false end)
    end

    -- Header click toggles panel
    local hBtn = New("TextButton", {
        Size                   = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Text                   = "",
        ZIndex                 = 4,
        Parent                 = wrap,
    })
    hBtn.MouseButton1Click:Connect(function()
        open = not open
        Tween(wrap, { Size = UDim2.new(1, 0, 0, open and 156 or 46) }, 0.22, Enum.EasingStyle.Quart)
    end)

    task.defer(function() task.spawn(cb, curC) end)
    return {
        Get = function() return curC end,
        Set = function(_, c)
            curC   = c
            swatch.BackgroundColor3 = c
            rgb    = { math.round(c.R*255), math.round(c.G*255), math.round(c.B*255) }
        end,
    }
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  TEXT INPUT                                                             │
-- └─────────────────────────────────────────────────────────────────────────┘
local function BuildInput(parent, opts)
    local name  = opts.Name                   or "Input"
    local flag  = opts.Flag                   or ""
    local ph    = opts.PlaceholderText        or "Type here..."
    local cb    = type(opts.Callback) == "function" and opts.Callback or function() end
    local clear = opts.RemoveTextAfterFocusLost ~= false

    local saved = Config:get(flag)
    Config:reg(flag, saved or "")

    local card = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.CardBg,
        Parent           = parent,
    })
    Rnd(8, card)
    Strk(C.CardBorder, 1, card)

    Txt(name, 13, C.CardText, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        ZIndex   = 2,
    }, card)

    local box = New("TextBox", {
        Size             = UDim2.new(0.54, -8, 0, 28),
        Position         = UDim2.new(0.44, 0, 0.5, -14),
        BackgroundColor3 = C.InputBg,
        PlaceholderText  = ph,
        PlaceholderColor3= C.CardSub,
        Text             = tostring(saved or ""),
        TextSize         = 12,
        TextColor3       = C.CardText,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex           = 3,
        Parent           = card,
    })
    Rnd(6, box)
    Strk(C.InputBorder, 1, box)
    Pad(0, 0, 8, 8, box)

    -- Focus glow
    box.Focused:Connect(function()
        Tween(box, { BackgroundColor3 = C.CardBgHover }, 0.12)
    end)
    box.FocusLost:Connect(function(enter)
        Tween(box, { BackgroundColor3 = C.InputBg }, 0.12)
        if enter then
            Config:set(flag, box.Text)
            task.spawn(cb, box.Text)
            if clear then box.Text = "" end
        end
    end)

    return {
        Get = function() return box.Text end,
        Set = function(_, v) box.Text = tostring(v) end,
    }
end

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  LABEL                                                                  │
-- └─────────────────────────────────────────────────────────────────────────┘
local function BuildLabel(parent, opts)
    Txt(tostring(opts.Name or opts.Text or ""), 12, C.CardSub, Enum.Font.Gotham, {
        Size        = UDim2.new(1, 0, 0, 32),
        Position    = UDim2.new(0, 14, 0, 0),
        TextWrapped = true,
    }, parent)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [8]  TAB PROTOTYPE
-- ─────────────────────────────────────────────────────────────────────────────
local TabProto = {}
TabProto.__index = TabProto

-- Route each public method to the matching builder
function TabProto:CreateSection(t)       BuildSection(self._c, t)            end
function TabProto:CreateToggle(o)        return BuildToggle(self._c, o)      end
function TabProto:CreateButton(o)        BuildButton(self._c, o)             end
function TabProto:CreateSlider(o)        return BuildSlider(self._c, o)      end
function TabProto:CreateDropdown(o)      return BuildDropdown(self._c, o)    end
function TabProto:CreateKeybind(o)       return BuildKeybind(self._c, o)     end
function TabProto:CreateColorPicker(o)   return BuildColorPicker(self._c, o) end
function TabProto:CreateInput(o)         return BuildInput(self._c, o)       end
function TabProto:CreateLabel(o)         BuildLabel(self._c, o)              end

-- ─────────────────────────────────────────────────────────────────────────────
-- [9]  WINDOW PROTOTYPE
-- ─────────────────────────────────────────────────────────────────────────────
local WinProto = {}
WinProto.__index = WinProto

--[[
  Win:CreateTab(name)
  Adds a sidebar button and a paired ScrollingFrame in the content area.
  Returns a TabProto object.
]]
function WinProto:CreateTab(name)
    -- ── Sidebar pill button ──────────────────────────────────────────────
    local btn = New("TextButton", {
        Size             = UDim2.new(1, -10, 0, 38),
        BackgroundColor3 = C.TabIdle,
        Text             = "",
        ZIndex           = 12,
        Parent           = self._side,
    })
    Rnd(8, btn)

    -- Active indicator bar (left edge, hidden by default)
    local bar = New("Frame", {
        Size             = UDim2.new(0, 3, 0.46, 0),
        Position         = UDim2.new(0, 0, 0.27, 0),
        BackgroundColor3 = C.TabIndicator,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 13,
        Parent           = btn,
    })
    Rnd(2, bar)

    local lbl = Txt(tostring(name or "Tab"), 12, C.TabTextIdle, Enum.Font.GothamSemiBold, {
        Size     = UDim2.new(1, -18, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        ZIndex   = 13,
    }, btn)

    -- ── Content scroll frame ─────────────────────────────────────────────
    local scroll = New("ScrollingFrame", {
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = C.Scroll,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ScrollingDirection   = Enum.ScrollingDirection.Y,
        Visible              = false,
        ZIndex               = 11,
        Parent               = self._body,
    })

    -- Inner content frame with padding and list layout
    local content = New("Frame", {
        Size          = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex        = 12,
        Parent        = scroll,
    })
    Pad(8, 14, 10, 10, content)
    VList(content, 6)

    -- Register
    local entry = { btn = btn, scroll = scroll, lbl = lbl, bar = bar }
    table.insert(self._tabs, entry)

    -- Auto-select the very first tab
    if #self._tabs == 1 then self:_Select(1) end

    -- Hover animations
    btn.MouseEnter:Connect(function()
        if self._active ~= entry then
            Tween(btn, { BackgroundColor3 = C.TabHover }, 0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._active ~= entry then
            Tween(btn, { BackgroundColor3 = C.TabIdle }, 0.12)
        end
    end)

    -- Click → select
    btn.MouseButton1Click:Connect(function()
        for i, t in ipairs(self._tabs) do
            if t == entry then self:_Select(i); return end
        end
    end)

    return setmetatable({ _c = content }, TabProto)
end

-- Switch visible tab
function WinProto:_Select(idx)
    for i, t in ipairs(self._tabs) do
        local on = (i == idx)
        t.scroll.Visible = on
        t.bar.Visible    = on
        Tween(t.btn, { BackgroundColor3 = on and C.TabActive or C.TabIdle }, 0.15)
        Tween(t.lbl, { TextColor3 = on and C.TabTextActive or C.TabTextIdle }, 0.15)
        if on then self._active = t end
    end
end

function WinProto:Notify(o)          Lib:Notify(o)  end  -- forward to library-level
function WinProto:LoadConfiguration()
    if self._cfgDir and self._cfgFile then
        Config:load(self._cfgDir, self._cfgFile)
    end
end
function WinProto:ResetConfig()
    Config._store = {}
    if self._cfgDir and self._cfgFile then
        pcall(function()
            if writefile then
                writefile(self._cfgDir .. "/" .. self._cfgFile .. ".json", "{}")
            end
        end)
    end
end
function WinProto:Destroy()
    if self._sg and self._sg.Parent then self._sg:Destroy() end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [10]  LIBRARY OBJECT
-- ─────────────────────────────────────────────────────────────────────────────
Lib = {}
Lib.__index = Lib

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  Lib:Notify({ Title, Content, Duration })                               ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
function Lib:Notify(opts)
    if type(opts) ~= "table" then return end
    task.spawn(function()
        pcall(function()
            EnsureNotifGui()
            local title    = tostring(opts.Title   or "Crimson")
            local content  = tostring(opts.Content or "")
            local duration = tonumber(opts.Duration) or 4

            -- ── Notification card ──────────────────────────────────────────
            local card = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 76),
                BackgroundColor3 = C.NotifBg,
                ClipsDescendants = true,
                Parent           = _notifColumn,
            })
            Rnd(10, card)
            Strk(C.NotifBorder, 1, card)

            -- Left accent stripe
            New("Frame", {
                Size             = UDim2.new(0, 3, 1, 0),
                BackgroundColor3 = C.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = card,
            })

            -- Inner content
            local inner = New("Frame", {
                Size                   = UDim2.new(1, -16, 1, 0),
                Position               = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                ZIndex                 = 2,
                Parent                 = card,
            })
            Txt("<b>"..title.."</b>", 13, C.NotifTitle, Enum.Font.GothamBold, {
                Size     = UDim2.new(1, 0, 0, 22),
                Position = UDim2.new(0, 0, 0, 10),
                ZIndex   = 3,
            }, inner)
            Txt(content, 12, C.NotifSub, Enum.Font.Gotham, {
                Size        = UDim2.new(1, 0, 0, 34),
                Position    = UDim2.new(0, 0, 0, 32),
                TextWrapped = true,
                ZIndex      = 3,
            }, inner)

            -- Progress bar (shrinks linearly over `duration` seconds)
            local bar = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 2),
                Position         = UDim2.new(0, 0, 1, -2),
                BackgroundColor3 = C.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 3,
                Parent           = card,
            })
            Rnd(1, bar)

            -- Slide in from the right
            card.Position = UDim2.new(1, 10, 0, 0)
            Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.28, Enum.EasingStyle.Back)
            Tween(bar,  { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

            -- Auto-dismiss
            task.delay(duration + 0.05, function()
                if not (card and card.Parent) then return end
                Tween(card, { Position = UDim2.new(1, 10, 0, 0) }, 0.2)
                task.wait(0.24)
                if card and card.Parent then card:Destroy() end
            end)
        end)
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  Lib:CreateWindow(opts)  — main entry point                             ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
function Lib:CreateWindow(opts)
    opts       = opts or {}
    local title   = tostring(opts.Name            or "Crimson")
    local ldTitle = tostring(opts.LoadingTitle    or title)
    local ldSub   = tostring(opts.LoadingSubtitle or "Initializing...")
    local cfgT    = type(opts.ConfigurationSaving) == "table" and opts.ConfigurationSaving or {}
    local cfgDir  = tostring(cfgT.FolderName or "CrimsonConfigs")
    local cfgFile = tostring(cfgT.FileName   or "Config")
    local cfgOn   = cfgT.Enabled == true

    --[[
      Load config BEFORE building any elements so that Config:get()
      returns saved values when each toggle / slider registers itself.
    ]]
    if cfgOn then Config:load(cfgDir, cfgFile) end

    -- Kill any previous instance (prevents duplicates on re-execute)
    local old = LP.PlayerGui:FindFirstChild("_CrimsonGUI")
    if old then old:Destroy() end

    -- ═══════════════════════════════════════════════════════════════════════
    --  SCREENGUI  — the three critical flags that guarantee it renders
    --  above every game UI, CoreGui overlay, and default Roblox menu.
    -- ═══════════════════════════════════════════════════════════════════════
    local sg = New("ScreenGui", {
        Name           = "_CrimsonGUI",
        ResetOnSpawn   = false,        -- survives character death / respawn
        DisplayOrder   = 999999,       -- renders above everything
        ZIndexBehavior = Enum.ZIndexBehavior.Global,   -- absolute ZIndex
        IgnoreGuiInset = true,         -- no top-bar offset
        Parent         = LP.PlayerGui,
    })

    -- ── Loading screen ─────────────────────────────────────────────────
    local loadFrame = New("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(7, 2, 2),
        ZIndex           = 500,
        Parent           = sg,
    })

    -- Scanline atmosphere (low cost, good feel)
    for i = 1, 36 do
        New("Frame", {
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, i/36, 0),
            BackgroundColor3 = Color3.fromRGB(50, 8, 8),
            BackgroundTransparency = 0.86,
            BorderSizePixel  = 0,
            ZIndex           = 501,
            Parent           = loadFrame,
        })
    end

    -- Central dot
    local dot = New("Frame", {
        Size             = UDim2.new(0, 10, 0, 10),
        Position         = UDim2.new(0.5, -5, 0.36, -5),
        BackgroundColor3 = C.Accent,
        ZIndex           = 502,
        Parent           = loadFrame,
    })
    Rnd(5, dot)

    Txt("<b>"..ldTitle.."</b>", 28, C.AccentHi, Enum.Font.GothamBlack, {
        Size           = UDim2.new(0.72, 0, 0, 42),
        Position       = UDim2.new(0.14, 0, 0.4, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 502,
    }, loadFrame)

    Txt(ldSub, 13, C.CardSub, Enum.Font.Gotham, {
        Size           = UDim2.new(0.52, 0, 0, 20),
        Position       = UDim2.new(0.24, 0, 0.51, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 502,
    }, loadFrame)

    -- Loading bar
    local barBg = New("Frame", {
        Size             = UDim2.new(0.36, 0, 0, 3),
        Position         = UDim2.new(0.32, 0, 0.59, 0),
        BackgroundColor3 = C.SlTrack,
        ZIndex           = 502,
        Parent           = loadFrame,
    })
    Rnd(2, barBg)
    local barFill = New("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.Accent,
        ZIndex           = 503,
        Parent           = barBg,
    })
    Rnd(2, barFill)

    task.spawn(function()
        Tween(barFill, { Size = UDim2.new(1, 0, 1, 0) }, 1.1, Enum.EasingStyle.Quart)
        task.wait(1.2)
        Tween(loadFrame, { BackgroundTransparency = 1 }, 0.34)
        for _, d in ipairs(loadFrame:GetDescendants()) do
            pcall(function()
                Tween(d, { BackgroundTransparency = 1, TextTransparency = 1 }, 0.34)
            end)
        end
        task.wait(0.38)
        if loadFrame and loadFrame.Parent then loadFrame:Destroy() end
    end)

    -- ── Main window ────────────────────────────────────────────────────
    local win = New("Frame", {
        Name             = "Win",
        Size             = UDim2.new(0, 650, 0, 450),
        Position         = UDim2.new(0.5, -325, 0.5, -225),
        BackgroundColor3 = C.WinBg,
        ZIndex           = 10,
        Parent           = sg,
    })
    Rnd(12, win)
    Strk(C.WinBorder, 1.5, win)

    -- Optional custom background image
    local bgImg = New("ImageLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ImageTransparency = 0.80,
        ScaleType        = Enum.ScaleType.Crop,
        Image            = "",
        ZIndex           = 10,
        Parent           = win,
    })

    -- ── Top bar ───────────────────────────────────────────────────────
    local top = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.TopBg,
        ZIndex           = 20,
        Parent           = win,
    })
    Rnd(12, top)
    -- Patch bottom corners of topbar to be square
    New("Frame", {
        Size             = UDim2.new(1, 0, 0.55, 0),
        Position         = UDim2.new(0, 0, 0.45, 0),
        BackgroundColor3 = C.TopBg,
        BorderSizePixel  = 0,
        ZIndex           = 20,
        Parent           = top,
    })
    -- Accent bottom border on topbar
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.TopBorder,
        BorderSizePixel  = 0,
        ZIndex           = 21,
        Parent           = top,
    })

    -- Crimson dot logo
    local logoDot = New("Frame", {
        Size             = UDim2.new(0, 10, 0, 10),
        Position         = UDim2.new(0, 13, 0.5, -5),
        BackgroundColor3 = C.Accent,
        ZIndex           = 22,
        Parent           = top,
    })
    Rnd(5, logoDot)

    -- Pulsing glow on the dot (subtle)
    task.spawn(function()
        while logoDot and logoDot.Parent do
            Tween(logoDot, { BackgroundColor3 = C.AccentGlow }, 1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.1)
            Tween(logoDot, { BackgroundColor3 = C.Accent     }, 1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.1)
        end
    end)

    -- Window title
    Txt(title:upper(), 12, C.TopTitle, Enum.Font.GothamBlack, {
        Size           = UDim2.new(0.55, 0, 1, 0),
        Position       = UDim2.new(0, 28, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 22,
    }, top)

    -- Window control buttons (close / minimize)
    local function CtrlBtn(xOff, col)
        local b = New("TextButton", {
            Size             = UDim2.new(0, 13, 0, 13),
            Position         = UDim2.new(1, xOff, 0.5, -6),
            BackgroundColor3 = col,
            Text             = "",
            ZIndex           = 22,
            Parent           = top,
        })
        Rnd(7, b)
        b.MouseEnter:Connect(function() Tween(b, { BackgroundColor3 = C.AccentGlow }, 0.1) end)
        b.MouseLeave:Connect(function() Tween(b, { BackgroundColor3 = col }, 0.1) end)
        return b
    end
    local closeBtn = CtrlBtn(-20, Color3.fromRGB(215, 34, 34))
    local minBtn   = CtrlBtn(-40, Color3.fromRGB(185, 125, 0))

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Tween(win, { Size = UDim2.new(0, 650, 0, minimized and 40 or 450) }, 0.24, Enum.EasingStyle.Quart)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(win, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.18)
        task.delay(0.2, function()
            if sg and sg.Parent then sg:Destroy() end
        end)
    end)

    -- Drag by topbar
    Drag(win, top)

    -- Insert key → show/hide
    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe or i.KeyCode ~= Enum.KeyCode.Insert then return end
        win.Visible = not win.Visible
    end)

    -- ── Body ──────────────────────────────────────────────────────────
    local body = New("Frame", {
        Size             = UDim2.new(1, 0, 1, -40),
        Position         = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ZIndex           = 11,
        Parent           = win,
    })

    -- ── Sidebar ────────────────────────────────────────────────────────
    --   Parented to body, width 155px, slight inner glow at the right edge.
    local sidebar = New("ScrollingFrame", {
        Size                 = UDim2.new(0, 155, 1, -8),
        Position             = UDim2.new(0, 4, 0, 4),
        BackgroundColor3     = C.SideBg,
        ScrollBarThickness   = 0,   -- hidden scrollbar (cleaner look)
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ZIndex               = 12,
        Parent               = body,
    })
    Rnd(10, sidebar)
    Strk(C.SideBorder, 1, sidebar)

    -- Layout container inside sidebar
    local sideInner = New("Frame", {
        Size          = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex        = 13,
        Parent        = sidebar,
    })
    Pad(6, 6, 5, 5, sideInner)
    VList(sideInner, 4)

    -- Divider line between sidebar and content
    New("Frame", {
        Size             = UDim2.new(0, 1, 1, -8),
        Position         = UDim2.new(0, 161, 0, 4),
        BackgroundColor3 = C.SideBorder,
        BorderSizePixel  = 0,
        ZIndex           = 12,
        Parent           = body,
    })

    -- ── Content area ───────────────────────────────────────────────────
    local contentArea = New("Frame", {
        Size             = UDim2.new(1, -170, 1, -8),
        Position         = UDim2.new(0, 166, 0, 4),
        BackgroundTransparency = 1,
        ZIndex           = 12,
        Parent           = body,
    })

    -- ── BG-Image editor ─────────────────────────────────────────────────
    --   Small gear button at the bottom of the sidebar.
    local bgBtn = New("TextButton", {
        Size             = UDim2.new(1, -10, 0, 28),
        BackgroundColor3 = C.AccentDim,
        Text             = "",
        LayoutOrder      = 9999,
        ZIndex           = 13,
        Parent           = sideInner,
    })
    Rnd(8, bgBtn)
    Txt("⚙  BG Image", 10, C.CardSub, Enum.Font.GothamSemiBold, {
        Size           = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 14,
    }, bgBtn)

    --   Floating editor panel — parented to sg so it always floats on top
    local bgPanel = New("Frame", {
        Size             = UDim2.new(0, 298, 0, 124),
        Position         = UDim2.new(0, 170, 1, -132),
        BackgroundColor3 = C.TopBg,
        Visible          = false,
        ZIndex           = 300,
        Parent           = sg,
    })
    Rnd(10, bgPanel)
    Strk(C.TopBorder, 1, bgPanel)
    Pad(10, 10, 10, 10, bgPanel)
    VList(bgPanel, 7)

    Txt("Background Image", 11, C.AccentHi, Enum.Font.GothamBold, {
        Size           = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 301,
    }, bgPanel)

    local bgInput = New("TextBox", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = C.InputBg,
        PlaceholderText  = "rbxassetid://...",
        PlaceholderColor3= C.CardSub,
        Text             = "",
        TextSize         = 11,
        TextColor3       = C.CardText,
        Font             = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex           = 301,
        Parent           = bgPanel,
    })
    Rnd(6, bgInput)
    Strk(C.InputBorder, 1, bgInput)
    Pad(0, 0, 6, 6, bgInput)

    -- Opacity slider inside bgPanel
    local opTrack = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = C.SlTrack,
        ZIndex           = 301,
        Parent           = bgPanel,
    })
    Rnd(4, opTrack)
    local opFill = New("Frame", {
        Size             = UDim2.new(0.2, 0, 1, 0), -- default 80 % opacity
        BackgroundColor3 = C.Accent,
        ZIndex           = 302,
        Parent           = opTrack,
    })
    Rnd(4, opFill)

    local opDrag = false
    opTrack.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        opDrag = true
        local rel = math.clamp((i.Position.X - opTrack.AbsolutePosition.X)/opTrack.AbsoluteSize.X, 0, 1)
        opFill.Size = UDim2.new(rel, 0, 1, 0)
        bgImg.ImageTransparency = 1 - rel
    end)
    OnMove(function(i)
        if opDrag then
            local rel = math.clamp((i.Position.X - opTrack.AbsolutePosition.X)/opTrack.AbsoluteSize.X, 0, 1)
            opFill.Size = UDim2.new(rel, 0, 1, 0)
            bgImg.ImageTransparency = 1 - rel
        end
    end)
    OnUp(function() opDrag = false end)

    -- Apply / Clear buttons
    local bgBtnRow = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        ZIndex                 = 301,
        Parent                 = bgPanel,
    })
    HList(bgBtnRow, 6)

    local function MiniBtn(text, col, par, fn)
        local b = New("TextButton", {
            Size             = UDim2.new(0.48, 0, 1, 0),
            BackgroundColor3 = col,
            Text             = text,
            TextSize         = 11,
            TextColor3       = Color3.new(1, 1, 1),
            Font             = Enum.Font.GothamSemiBold,
            ZIndex           = 302,
            Parent           = par,
        })
        Rnd(6, b)
        b.MouseButton1Click:Connect(fn)
        return b
    end
    MiniBtn("Apply", C.Accent,    bgBtnRow, function()
        local id = bgInput.Text:match("(%d+)") or ""
        bgImg.Image = id ~= "" and ("rbxassetid://"..id) or bgInput.Text
    end)
    MiniBtn("Clear", C.AccentDim, bgBtnRow, function()
        bgImg.Image  = ""
        bgInput.Text = ""
    end)

    bgBtn.MouseButton1Click:Connect(function()
        bgPanel.Visible = not bgPanel.Visible
    end)

    -- ── Auto-save ────────────────────────────────────────────────────────
    if cfgOn then
        task.spawn(function()
            while sg and sg.Parent do
                task.wait(60)
                Config:save(cfgDir, cfgFile)
            end
        end)
    end

    -- ── Return window object ────────────────────────────────────────────
    return setmetatable({
        _sg      = sg,
        _side    = sideInner,
        _body    = contentArea,
        _tabs    = {},
        _active  = nil,
        _cfgDir  = cfgOn and cfgDir  or nil,
        _cfgFile = cfgOn and cfgFile or nil,
    }, WinProto)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [11]  TOP-LEVEL DESTROY
-- ─────────────────────────────────────────────────────────────────────────────
function Lib:Destroy()
    pcall(function()
        local g = LP.PlayerGui:FindFirstChild("_CrimsonGUI")
        if g then g:Destroy() end
        local n = LP.PlayerGui:FindFirstChild("_CrimsonNotifs")
        if n then n:Destroy() end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
return setmetatable(Lib, Lib)
