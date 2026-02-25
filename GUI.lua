-- ============================================
--   Garskirtz Ganteng | GUI.lua
--   Optimized: task.* API, responsive, rainbow
-- ============================================

-- ANTI AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local player       = Players.LocalPlayer

-- ── Shared state ─────────────────────────────────────────────────────────────
_G.AF_moneyStart   = 0
_G.AF_sessionStart = tick()

task.delay(2, function()
    local ls = player:WaitForChild("leaderstats", 10)
    if ls then _G.AF_moneyStart = ls:WaitForChild("Cash").Value end
end)

-- ── Responsive scale ─────────────────────────────────────────────────────────
local vp       = workspace.CurrentCamera.ViewportSize
local isMobile = vp.X < 1000
local SCALE    = isMobile and 1.45 or 1.0

local W  = math.floor(300 * SCALE)
local H  = math.floor(240 * SCALE)
local FS = function(s) return math.floor(s * SCALE) end

-- ── Helpers ──────────────────────────────────────────────────────────────────
local function fmt(n)
    if     n >= 1e12 then return ("%.1fT"):format(n/1e12)
    elseif n >= 1e9  then return ("%.1fB"):format(n/1e9)
    elseif n >= 1e6  then return ("%.1fM"):format(n/1e6)
    elseif n >= 1e3  then return ("%.1fK"):format(n/1e3)
    else                  return tostring(math.floor(n)) end
end

local function fmtTime(s)
    return ("%d:%02d"):format(math.floor(s/60), s%60)
end

local function newInst(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k] = v end
    return o
end

local function corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, math.floor(r * SCALE))
    c.Parent = p
    return c
end

local function mkStroke(col, thick, parent, trans)
    local s = Instance.new("UIStroke")
    s.Color        = col
    s.Thickness    = thick or 1.5
    s.Transparency = trans or 0
    s.Parent       = parent
    return s
end

-- ── Palette ──────────────────────────────────────────────────────────────────
local C = {
    bg     = Color3.fromRGB(12, 12, 14),
    card   = Color3.fromRGB(22, 22, 28),
    border = Color3.fromRGB(45, 45, 58),
    white  = Color3.fromRGB(230, 230, 235),
    muted  = Color3.fromRGB(110, 110, 130),
    red    = Color3.fromRGB(255, 75,  75),
    green  = Color3.fromRGB(72,  220, 130),
    r1 = Color3.fromRGB(255, 80,  80),
    r2 = Color3.fromRGB(255, 165, 0),
    r3 = Color3.fromRGB(255, 230, 0),
    r4 = Color3.fromRGB(80,  220, 80),
    r5 = Color3.fromRGB(80,  160, 255),
    r6 = Color3.fromRGB(180, 80,  255),
}

-- ════════════════════════════════════════════════════════════════════════════
--  ROOT ScreenGui
-- ════════════════════════════════════════════════════════════════════════════
local root = newInst("ScreenGui", {
    Name           = "AutoFarmGUI",
    DisplayOrder   = 50001,
    ResetOnSpawn   = false,
    IgnoreGuiInset = true,
    Parent         = player.PlayerGui,
})

-- DIM OVERLAY
local dimOverlay = newInst("Frame", {
    Size                   = UDim2.new(1, 0, 1, 0),
    BackgroundColor3       = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel        = 0,
    ZIndex                 = 5,
    Visible                = false,
    Parent                 = root,
})

-- ════════════════════════════════════════════════════════════════════════════
--  MAIN FRAME
-- ════════════════════════════════════════════════════════════════════════════
local frame = newInst("Frame", {
    Size             = UDim2.new(0, W, 0, H),
    Position         = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = C.bg,
    BorderSizePixel  = 0,
    ZIndex           = 10,
    Parent           = root,
})
corner(14, frame)
mkStroke(C.border, 1.5, frame)

-- Rainbow top bar
local topBar = newInst("Frame", {
    Size             = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = C.r1,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})
corner(14, topBar)
local topGrad = Instance.new("UIGradient")
topGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   C.r1),
    ColorSequenceKeypoint.new(0.2, C.r2),
    ColorSequenceKeypoint.new(0.4, C.r3),
    ColorSequenceKeypoint.new(0.6, C.r4),
    ColorSequenceKeypoint.new(0.8, C.r5),
    ColorSequenceKeypoint.new(1.0, C.r6),
}
topGrad.Parent = topBar

-- ── TITLE ROW ────────────────────────────────────────────────────────────────
-- Rainbow heart emoji
local loveLbl = newInst("TextLabel", {
    Size                   = UDim2.new(0, FS(24), 0, FS(38)),
    Position               = UDim2.new(0, FS(12), 0, FS(8)),
    BackgroundTransparency = 1,
    Text                   = "❤",
    TextColor3             = C.r1,
    TextSize               = FS(16),
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Center,
    ZIndex                 = 12,
    Parent                 = frame,
})

local titleLbl = newInst("TextLabel", {
    Size                   = UDim2.new(1, -FS(95), 0, FS(38)),
    Position               = UDim2.new(0, FS(38), 0, FS(8)),
    BackgroundTransparency = 1,
    Text                   = "Garskirtz Ganteng",
    TextColor3             = C.white,
    TextSize               = FS(15),
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 12,
    Parent                 = frame,
})

-- Animated rainbow gradient on title
local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   C.r1),
    ColorSequenceKeypoint.new(0.2, C.r2),
    ColorSequenceKeypoint.new(0.4, C.r3),
    ColorSequenceKeypoint.new(0.6, C.r4),
    ColorSequenceKeypoint.new(0.8, C.r5),
    ColorSequenceKeypoint.new(1.0, C.r6),
}
titleGrad.Parent = titleLbl

-- Dot indicator
local dot = newInst("Frame", {
    Size             = UDim2.new(0, FS(9), 0, FS(9)),
    Position         = UDim2.new(1, -FS(42), 0, FS(18)),
    AnchorPoint      = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.red,
    BorderSizePixel  = 0,
    ZIndex           = 12,
    Parent           = frame,
})
corner(99, dot)

-- Minimize button
local minBtn = newInst("TextButton", {
    Size             = UDim2.new(0, FS(26), 0, FS(26)),
    Position         = UDim2.new(1, -FS(12), 0, FS(12)),
    AnchorPoint      = Vector2.new(1, 0),
    BackgroundColor3 = Color3.fromRGB(35, 35, 42),
    BorderSizePixel  = 0,
    Text             = "−",
    TextColor3       = C.muted,
    TextSize         = FS(18),
    Font             = Enum.Font.GothamBold,
    ZIndex           = 12,
    Parent           = frame,
})
corner(8, minBtn)

-- ── DIVIDER ──────────────────────────────────────────────────────────────────
local divider = newInst("Frame", {
    Size             = UDim2.new(1, -FS(28), 0, 1),
    Position         = UDim2.new(0, FS(14), 0, FS(50)),
    BackgroundColor3 = C.border,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})

-- ── STATUS CARD ──────────────────────────────────────────────────────────────
local statusCard = newInst("Frame", {
    Size             = UDim2.new(1, -FS(28), 0, FS(36)),
    Position         = UDim2.new(0, FS(14), 0, FS(60)),
    BackgroundColor3 = C.card,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})
corner(8, statusCard)

local statusIcon = newInst("TextLabel", {
    Size                   = UDim2.new(0, FS(24), 1, 0),
    Position               = UDim2.new(0, FS(8), 0, 0),
    BackgroundTransparency = 1,
    Text                   = "●",
    TextColor3             = C.red,
    TextSize               = FS(10),
    Font                   = Enum.Font.Gotham,
    TextXAlignment         = Enum.TextXAlignment.Center,
    ZIndex                 = 12,
    Parent                 = statusCard,
})

local statusText = newInst("TextLabel", {
    Name                   = "StatusText",
    Size                   = UDim2.new(1, -FS(36), 1, 0),
    Position               = UDim2.new(0, FS(32), 0, 0),
    BackgroundTransparency = 1,
    Text                   = "Stopped — sit in vehicle to start",
    TextColor3             = C.muted,
    TextSize               = FS(12),
    Font                   = Enum.Font.Gotham,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 12,
    Parent                 = statusCard,
})

-- ── MONEY CARD ───────────────────────────────────────────────────────────────
local moneyCard = newInst("Frame", {
    Size             = UDim2.new(1, -FS(28), 0, FS(68)),
    Position         = UDim2.new(0, FS(14), 0, FS(106)),
    BackgroundColor3 = C.card,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})
corner(8, moneyCard)
mkStroke(C.border, 1, moneyCard, 0.4)

newInst("TextLabel", {
    Size                   = UDim2.new(0.5, 0, 0, FS(20)),
    Position               = UDim2.new(0, FS(10), 0, FS(6)),
    BackgroundTransparency = 1,
    Text                   = "BALANCE",
    TextColor3             = C.muted,
    TextSize               = FS(10),
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 12,
    Parent                 = moneyCard,
})

newInst("TextLabel", {
    Size                   = UDim2.new(0.5, -FS(10), 0, FS(20)),
    Position               = UDim2.new(0.5, 0, 0, FS(6)),
    BackgroundTransparency = 1,
    Text                   = "/ HOUR",
    TextColor3             = C.muted,
    TextSize               = FS(10),
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Right,
    ZIndex                 = 12,
    Parent                 = moneyCard,
})

local balanceLbl = newInst("TextLabel", {
    Name                   = "BalanceLbl",
    Size                   = UDim2.new(0.55, 0, 0, FS(30)),
    Position               = UDim2.new(0, FS(10), 0, FS(22)),
    BackgroundTransparency = 1,
    Text                   = "$0",
    TextColor3             = C.white,
    TextSize               = FS(22),
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 12,
    Parent                 = moneyCard,
})

local perHourLbl = newInst("TextLabel", {
    Name                   = "PerHourLbl",
    Size                   = UDim2.new(0.45, -FS(10), 0, FS(30)),
    Position               = UDim2.new(0.55, 0, 0, FS(22)),
    BackgroundTransparency = 1,
    Text                   = "$0",
    TextColor3             = C.green,
    TextSize               = FS(22),
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Right,
    ZIndex                 = 12,
    Parent                 = moneyCard,
})

local sessionLbl = newInst("TextLabel", {
    Name                   = "SessionLbl",
    Size                   = UDim2.new(1, -FS(20), 0, FS(16)),
    Position               = UDim2.new(0, FS(10), 1, -FS(18)),
    BackgroundTransparency = 1,
    Text                   = "Session: 0:00  ·  +$0 gained",
    TextColor3             = C.muted,
    TextSize               = FS(11),
    Font                   = Enum.Font.Gotham,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 12,
    Parent                 = moneyCard,
})

-- ── BUTTON ───────────────────────────────────────────────────────────────────
local btn = newInst("TextButton", {
    Name             = "AutoFarmToggle",
    Size             = UDim2.new(1, -FS(28), 0, FS(42)),
    Position         = UDim2.new(0, FS(14), 0, FS(185)),
    BackgroundColor3 = Color3.fromRGB(60, 170, 110),
    BorderSizePixel  = 0,
    Text             = "Start AutoFarm",
    TextColor3       = Color3.fromRGB(10, 10, 12),
    TextSize         = FS(15),
    Font             = Enum.Font.GothamBold,
    ZIndex           = 11,
    Parent           = frame,
})
corner(10, btn)
local btnStroke = mkStroke(Color3.fromRGB(40, 130, 80), 1.5, btn, 0.4)

local btnGrad = Instance.new("UIGradient")
btnGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   C.r4),
    ColorSequenceKeypoint.new(0.5, C.r5),
    ColorSequenceKeypoint.new(1.0, C.r6),
}
btnGrad.Rotation = 45
btnGrad.Parent = btn

btn.MouseEnter:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80,190,130)}):Play()
end)
btn.MouseLeave:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60,170,110)}):Play()
end)

-- ════════════════════════════════════════════════════════════════════════════
--  MINIMIZE
-- ════════════════════════════════════════════════════════════════════════════
local minimized  = false
local miniH      = FS(52)
local TWEEN_MIN  = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local contentItems = {divider, statusCard, moneyCard, btn}

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(frame, TWEEN_MIN, {Size = UDim2.new(0, W, 0, miniH)}):Play()
        TweenService:Create(dimOverlay, TWEEN_MIN, {BackgroundTransparency = 0.45}):Play()
        dimOverlay.Visible = true
        minBtn.Text = "+"
        for _, v in ipairs(contentItems) do v.Visible = false end
    else
        TweenService:Create(frame, TWEEN_MIN, {Size = UDim2.new(0, W, 0, H)}):Play()
        TweenService:Create(dimOverlay, TWEEN_MIN, {BackgroundTransparency = 1}):Play()
        minBtn.Text = "−"
        for _, v in ipairs(contentItems) do v.Visible = true end
        task.delay(0.35, function() dimOverlay.Visible = false end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  DOT PULSE
-- ════════════════════════════════════════════════════════════════════════════
local dotPulse = false

local function startDotPulse()
    if dotPulse then return end
    dotPulse = true
    dot.BackgroundColor3  = C.green
    statusIcon.TextColor3 = C.green
    local function ping()
        if not dotPulse then return end
        TweenService:Create(dot, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {
            BackgroundColor3 = Color3.fromRGB(30, 155, 85)
        }):Play()
        task.delay(1.2, ping)
    end
    ping()
end

local function stopDotPulse()
    dotPulse = false
    dot.BackgroundColor3  = C.red
    statusIcon.TextColor3 = C.red
end

-- ════════════════════════════════════════════════════════════════════════════
--  RAINBOW ANIMATION (shimmer gradient offset)
-- ════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    local t = 0
    RunService.Heartbeat:Connect(function(dt)
        t = (t + dt * 0.35) % 1
        local ox = math.sin(t * math.pi * 2) * 0.5
        titleGrad.Offset = Vector2.new(ox, 0)
        topGrad.Offset   = Vector2.new(-ox, 0)
        -- cycle heart color through rainbow
        local idx = math.floor(t * 6) + 1
        local cols = {C.r1, C.r2, C.r3, C.r4, C.r5, C.r6}
        loveLbl.TextColor3 = cols[idx] or C.r1
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  MONEY TRACKER LOOP
-- ════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    local elapsed = 0
    RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed < 2 then return end
        elapsed = 0

        local ls = player:FindFirstChild("leaderstats")
        if not ls then return end
        local cash = ls:FindFirstChild("Cash")
        if not cash then return end

        local now     = cash.Value
        local gained  = now - _G.AF_moneyStart
        local sesTime = tick() - _G.AF_sessionStart

        balanceLbl.Text = "$" .. fmt(now)
        sessionLbl.Text = "Session: " .. fmtTime(math.floor(sesTime)) .. "  ·  +$" .. fmt(math.max(0, gained)) .. " gained"
        if sesTime > 5 then
            perHourLbl.Text = "$" .. fmt(math.floor(gained / sesTime * 3600))
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  PUBLIC _G
-- ════════════════════════════════════════════════════════════════════════════
_G.AF_GUI = {
    statusText = statusText,
    statusIcon = statusIcon,
    balanceLbl = balanceLbl,
    perHourLbl = perHourLbl,
    sessionLbl = sessionLbl,
    btn        = btn,
    btnStroke  = btnStroke,
    startPulse = startDotPulse,
    stopPulse  = stopDotPulse,
    C          = C,
}

-- ════════════════════════════════════════════════════════════════════════════
--  DRAGGABLE
-- ════════════════════════════════════════════════════════════════════════════
do
    local dragging, dragStart, startPos, dragInput

    frame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then
            local d = inp.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end
