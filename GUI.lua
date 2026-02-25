-- ============================================
--   Nathan's Autofarm | GUI.lua (Dark Modern)
--   Optimized: task.* API, minimal loops
-- ============================================

-- ANTI AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local player       = Players.LocalPlayer

-- ── Shared state (dibaca Logic.lua) ─────────────────────────────────────────
_G.AF_moneyStart   = 0
_G.AF_sessionStart = tick()

task.delay(2, function()
    local ls = player:WaitForChild("leaderstats", 10)
    if ls then _G.AF_moneyStart = ls:WaitForChild("Cash").Value end
end)

-- ── Helper ───────────────────────────────────────────────────────────────────
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

-- ── Factory helpers ──────────────────────────────────────────────────────────
local function newInst(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k] = v end
    return o
end

local function corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
    return c
end

local function stroke(col, thick, parent, trans)
    local s = Instance.new("UIStroke")
    s.Color       = col
    s.Thickness   = thick or 1.5
    s.Transparency = trans or 0
    s.Parent      = parent
    return s
end

-- ════════════════════════════════════════════════════════════════════════════
--  PALETTE
-- ════════════════════════════════════════════════════════════════════════════
local C = {
    bg       = Color3.fromRGB(12,  12,  14),
    panel    = Color3.fromRGB(20,  20,  24),
    card     = Color3.fromRGB(26,  26,  32),
    border   = Color3.fromRGB(40,  40,  50),
    accent   = Color3.fromRGB(99,  179, 237),   -- soft blue
    green    = Color3.fromRGB(72,  199, 142),   -- mint green
    white    = Color3.fromRGB(230, 230, 235),
    muted    = Color3.fromRGB(120, 120, 135),
    danger   = Color3.fromRGB(252, 100, 100),
}

-- ════════════════════════════════════════════════════════════════════════════
--  ROOT ScreenGui
-- ════════════════════════════════════════════════════════════════════════════
local root = newInst("ScreenGui", {
    Name            = "AutoFarmGUI",
    DisplayOrder    = 50001,
    ResetOnSpawn    = false,
    IgnoreGuiInset  = true,
    Parent          = player.PlayerGui,
})

-- ════════════════════════════════════════════════════════════════════════════
--  MAIN FRAME  280 × 230
-- ════════════════════════════════════════════════════════════════════════════
local frame = newInst("Frame", {
    Size              = UDim2.new(0, 280, 0, 230),
    Position          = UDim2.new(0.5,-140, 0.5,-115),
    BackgroundColor3  = C.bg,
    BorderSizePixel   = 0,
    Parent            = root,
})
corner(14, frame)
stroke(C.border, 1.5, frame)

-- subtle inner shadow strip at top
local topBar = newInst("Frame", {
    Size             = UDim2.new(1,0, 0,3),
    BackgroundColor3 = C.accent,
    BorderSizePixel  = 0,
    Parent           = frame,
})
corner(14, topBar)  -- just top corners visible

-- ── TITLE ROW ────────────────────────────────────────────────────────────────
local titleLbl = newInst("TextLabel", {
    Size             = UDim2.new(1,-20, 0,38),
    Position         = UDim2.new(0,14, 0,10),
    BackgroundTransparency = 1,
    Text             = "Nathan's Autofarm",
    TextColor3       = C.white,
    TextSize         = 17,
    Font             = Enum.Font.GothamBold,
    TextXAlignment   = Enum.TextXAlignment.Left,
    Parent           = frame,
})

-- dot indicator (idle = grey, farming = green pulse)
local dot = newInst("Frame", {
    Size             = UDim2.new(0,8,0,8),
    Position         = UDim2.new(1,-18, 0,18),
    BackgroundColor3 = C.muted,
    BorderSizePixel  = 0,
    AnchorPoint      = Vector2.new(0.5,0.5),
    Parent           = frame,
})
corner(99, dot)

-- ── DIVIDER ──────────────────────────────────────────────────────────────────
local div = newInst("Frame", {
    Size             = UDim2.new(1,-28,0,1),
    Position         = UDim2.new(0,14,0,50),
    BackgroundColor3 = C.border,
    BorderSizePixel  = 0,
    Parent           = frame,
})

-- ── STATUS CARD ──────────────────────────────────────────────────────────────
local statusCard = newInst("Frame", {
    Size             = UDim2.new(1,-28,0,36),
    Position         = UDim2.new(0,14,0,60),
    BackgroundColor3 = C.card,
    BorderSizePixel  = 0,
    Parent           = frame,
})
corner(8, statusCard)

local statusIcon = newInst("TextLabel", {
    Size             = UDim2.new(0,24,1,0),
    Position         = UDim2.new(0,8,0,0),
    BackgroundTransparency = 1,
    Text             = "●",
    TextColor3       = C.muted,
    TextSize         = 10,
    Font             = Enum.Font.Gotham,
    TextXAlignment   = Enum.TextXAlignment.Center,
    Parent           = statusCard,
})

local statusText = newInst("TextLabel", {
    Name             = "StatusText",
    Size             = UDim2.new(1,-36,1,0),
    Position         = UDim2.new(0,32,0,0),
    BackgroundTransparency = 1,
    Text             = "Ready — sit in vehicle to start",
    TextColor3       = C.muted,
    TextSize         = 12,
    Font             = Enum.Font.Gotham,
    TextXAlignment   = Enum.TextXAlignment.Left,
    Parent           = statusCard,
})

-- ── MONEY TRACKER CARD ───────────────────────────────────────────────────────
local moneyCard = newInst("Frame", {
    Size             = UDim2.new(1,-28,0,64),
    Position         = UDim2.new(0,14,0,106),
    BackgroundColor3 = C.card,
    BorderSizePixel  = 0,
    Parent           = frame,
})
corner(8, moneyCard)
stroke(C.border, 1, moneyCard, 0.4)

-- label kiri atas
newInst("TextLabel", {
    Size             = UDim2.new(0.5,0,0,20),
    Position         = UDim2.new(0,10,0,6),
    BackgroundTransparency = 1,
    Text             = "BALANCE",
    TextColor3       = C.muted,
    TextSize         = 10,
    Font             = Enum.Font.GothamBold,
    TextXAlignment   = Enum.TextXAlignment.Left,
    Parent           = moneyCard,
})

-- label kanan atas
newInst("TextLabel", {
    Size             = UDim2.new(0.5,0,0,20),
    Position         = UDim2.new(0.5,-10,0,6),
    BackgroundTransparency = 1,
    Text             = "/ HOUR",
    TextColor3       = C.muted,
    TextSize         = 10,
    Font             = Enum.Font.GothamBold,
    TextXAlignment   = Enum.TextXAlignment.Right,
    Parent           = moneyCard,
})

local balanceLbl = newInst("TextLabel", {
    Name             = "BalanceLbl",
    Size             = UDim2.new(0.55,0,0,28),
    Position         = UDim2.new(0,10,0,24),
    BackgroundTransparency = 1,
    Text             = "$0",
    TextColor3       = C.white,
    TextSize         = 22,
    Font             = Enum.Font.GothamBold,
    TextXAlignment   = Enum.TextXAlignment.Left,
    Parent           = moneyCard,
})

local perHourLbl = newInst("TextLabel", {
    Name             = "PerHourLbl",
    Size             = UDim2.new(0.45,-10,0,28),
    Position         = UDim2.new(0.55,0,0,24),
    BackgroundTransparency = 1,
    Text             = "$0",
    TextColor3       = C.green,
    TextSize         = 22,
    Font             = Enum.Font.GothamBold,
    TextXAlignment   = Enum.TextXAlignment.Right,
    Parent           = moneyCard,
})

local sessionLbl = newInst("TextLabel", {
    Name             = "SessionLbl",
    Size             = UDim2.new(1,-20,0,16),
    Position         = UDim2.new(0,10,1,-18),
    BackgroundTransparency = 1,
    Text             = "Session: 0:00  ·  +$0 gained",
    TextColor3       = C.muted,
    TextSize         = 11,
    Font             = Enum.Font.Gotham,
    TextXAlignment   = Enum.TextXAlignment.Left,
    Parent           = moneyCard,
})

-- ── START / STOP BUTTON ──────────────────────────────────────────────────────
local btn = newInst("TextButton", {
    Name             = "AutoFarmToggle",
    Size             = UDim2.new(1,-28,0,42),
    Position         = UDim2.new(0,14,0,180),
    BackgroundColor3 = C.accent,
    BorderSizePixel  = 0,
    Text             = "Start AutoFarm",
    TextColor3       = C.bg,
    TextSize         = 15,
    Font             = Enum.Font.GothamBold,
    Parent           = frame,
})
corner(10, btn)
local btnStroke = stroke(Color3.fromRGB(60,120,180), 1.5, btn, 0.5)

-- hover tween
local HOVER_IN  = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
local HOVER_OUT = TweenInfo.new(0.18, Enum.EasingStyle.Quad)

btn.MouseEnter:Connect(function()
    TweenService:Create(btn, HOVER_IN, {BackgroundColor3 = Color3.fromRGB(130,200,255)}):Play()
end)
btn.MouseLeave:Connect(function()
    TweenService:Create(btn, HOVER_OUT, {BackgroundColor3 = C.accent}):Play()
end)

-- ════════════════════════════════════════════════════════════════════════════
--  DOT PULSE animation (saat farm aktif)
-- ════════════════════════════════════════════════════════════════════════════
local dotPulse
local function startDotPulse()
    if dotPulse then return end
    dot.BackgroundColor3 = C.green
    local function ping()
        if not dotPulse then return end
        TweenService:Create(dot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {
            BackgroundColor3 = Color3.fromRGB(30,180,100)
        }):Play()
        task.delay(1.4, ping)
    end
    dotPulse = true
    ping()
end

local function stopDotPulse()
    dotPulse = nil
    dot.BackgroundColor3 = C.muted
end

-- ════════════════════════════════════════════════════════════════════════════
--  PUBLIC REFERENCES  (dibaca Logic.lua via _G)
-- ════════════════════════════════════════════════════════════════════════════
_G.AF_GUI = {
    statusText  = statusText,
    statusIcon  = statusIcon,
    balanceLbl  = balanceLbl,
    perHourLbl  = perHourLbl,
    sessionLbl  = sessionLbl,
    btn         = btn,
    btnStroke   = btnStroke,
    startPulse  = startDotPulse,
    stopPulse   = stopDotPulse,
    C           = C,
}

-- ════════════════════════════════════════════════════════════════════════════
--  MONEY TRACKER LOOP  (efisien: task.spawn + heartbeat counter)
-- ════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    -- update tiap ~2 detik pakai heartbeat counter biar tidak spawn thread baru
    local elapsed = 0
    game:GetService("RunService").Heartbeat:Connect(function(dt)
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
        sessionLbl.Text = "Session: " .. fmtTime(math.floor(sesTime)) .. "  ·  +" .. "$" .. fmt(math.max(0, gained)) .. " gained"

        if sesTime > 5 then
            perHourLbl.Text = "$" .. fmt(math.floor(gained / sesTime * 3600))
        end
    end)
end)

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
