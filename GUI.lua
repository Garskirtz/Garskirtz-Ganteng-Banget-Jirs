-- ============================================
--   Garskirtz Ganteng | GUI.lua  v4
--   + bigger text, dot next to title,
--   + single minimize button, free resize
-- ============================================

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

-- ── Responsive base scale ────────────────────────────────────────────────────
local vp       = workspace.CurrentCamera.ViewportSize
local isMobile = vp.X < 1000
local SCALE    = isMobile and 1.45 or 1.0

-- Base dimensions
local BASE_W = 310
local BASE_H = 250
local W = math.floor(BASE_W * SCALE)
local H = math.floor(BASE_H * SCALE)
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
    bg     = Color3.fromRGB(12,  12,  14),
    card   = Color3.fromRGB(22,  22,  28),
    border = Color3.fromRGB(45,  45,  58),
    white  = Color3.fromRGB(230, 230, 235),
    muted  = Color3.fromRGB(110, 110, 130),
    red    = Color3.fromRGB(255, 75,  75),
    green  = Color3.fromRGB(72,  220, 130),
    danger = Color3.fromRGB(255, 75,  75),
    accent = Color3.fromRGB(60,  170, 110),
    r1 = Color3.fromRGB(255, 80,  80),
    r2 = Color3.fromRGB(255, 165, 0),
    r3 = Color3.fromRGB(245, 225, 0),
    r4 = Color3.fromRGB(80,  210, 80),
    r5 = Color3.fromRGB(80,  155, 255),
    r6 = Color3.fromRGB(180, 80,  255),
}

-- ════════════════════════════════════════════════════════════════════════════
--  ROOT
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
    Size                   = UDim2.new(1,0,1,0),
    BackgroundColor3       = Color3.new(0,0,0),
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
    ClipsDescendants = true,
    Parent           = root,
})
corner(12, frame)
mkStroke(C.border, 1.5, frame)

-- Rainbow top accent bar
local topBar = newInst("Frame", {
    Size             = UDim2.new(1,0,0,3),
    BackgroundColor3 = C.r1,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})
corner(12, topBar)
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

-- ── TITLE BAR ────────────────────────────────────────────────────────────────
-- Heart emoji
local loveLbl = newInst("TextLabel", {
    Size                   = UDim2.new(0, FS(22), 0, FS(48)),
    Position               = UDim2.new(0, FS(12), 0, FS(4)),
    BackgroundTransparency = 1,
    Text                   = "❤",
    TextColor3             = C.r1,
    TextSize               = FS(16),
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Center,
    ZIndex                 = 12,
    Parent                 = frame,
})

-- Title label
local titleLbl = newInst("TextLabel", {
    Size                   = UDim2.new(0, FS(155), 0, FS(48)),
    Position               = UDim2.new(0, FS(36), 0, FS(4)),
    BackgroundTransparency = 1,
    Text                   = "Garskirtz Ganteng",
    TextColor3             = C.white,
    TextSize               = FS(16),   -- LEBIH BESAR
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 12,
    Parent                 = frame,
})
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

-- Dot indicator — tepat di sebelah kanan judul, berdekatan
local dot = newInst("Frame", {
    Size             = UDim2.new(0, FS(9), 0, FS(9)),
    -- posisi: setelah titleLbl (x=36+155=191) + gap kecil 5px
    Position         = UDim2.new(0, FS(194), 0, FS(23)),
    AnchorPoint      = Vector2.new(0, 0.5),
    BackgroundColor3 = C.red,   -- MERAH saat idle
    BorderSizePixel  = 0,
    ZIndex           = 12,
    Parent           = frame,
})
corner(99, dot)

-- Minimize button (−) pojok kanan atas
local minBtn = newInst("TextButton", {
    Size             = UDim2.new(0, FS(28), 0, FS(24)),
    Position         = UDim2.new(1, -FS(10), 0, FS(12)),
    AnchorPoint      = Vector2.new(1, 0),
    BackgroundColor3 = Color3.fromRGB(35, 35, 42),
    BorderSizePixel  = 0,
    Text             = "−",
    TextColor3       = C.muted,
    TextSize         = FS(18),
    Font             = Enum.Font.GothamBold,
    ZIndex           = 13,
    Parent           = frame,
})
corner(6, minBtn)
minBtn.MouseEnter:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(60,60,70)}):Play()
end)
minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(35,35,42)}):Play()
end)

-- ── DIVIDER ──────────────────────────────────────────────────────────────────
local divider = newInst("Frame", {
    Size             = UDim2.new(1,-FS(28),0,1),
    Position         = UDim2.new(0,FS(14),0,FS(55)),
    BackgroundColor3 = C.border,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})

-- ── STATUS CARD ──────────────────────────────────────────────────────────────
local statusCard = newInst("Frame", {
    Size             = UDim2.new(1,-FS(28),0,FS(38)),
    Position         = UDim2.new(0,FS(14),0,FS(65)),
    BackgroundColor3 = C.card,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})
corner(8, statusCard)

local statusIcon = newInst("TextLabel", {
    Size                   = UDim2.new(0,FS(24),1,0),
    Position               = UDim2.new(0,FS(8),0,0),
    BackgroundTransparency = 1,
    Text                   = "●",
    TextColor3             = C.red,
    TextSize               = FS(11),
    Font                   = Enum.Font.Gotham,
    TextXAlignment         = Enum.TextXAlignment.Center,
    ZIndex                 = 12,
    Parent                 = statusCard,
})

local statusText = newInst("TextLabel", {
    Name                   = "StatusText",
    Size                   = UDim2.new(1,-FS(36),1,0),
    Position               = UDim2.new(0,FS(32),0,0),
    BackgroundTransparency = 1,
    Text                   = "Stopped — sit in vehicle to start",
    TextColor3             = C.muted,
    TextSize               = FS(13),   -- LEBIH BESAR
    Font                   = Enum.Font.Gotham,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 12,
    Parent                 = statusCard,
})

-- ── MONEY CARD ───────────────────────────────────────────────────────────────
local moneyCard = newInst("Frame", {
    Size             = UDim2.new(1,-FS(28),0,FS(72)),
    Position         = UDim2.new(0,FS(14),0,FS(113)),
    BackgroundColor3 = C.card,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})
corner(8, moneyCard)
mkStroke(C.border, 1, moneyCard, 0.4)

-- Labels atas
newInst("TextLabel",{
    Size=UDim2.new(0.5,0,0,FS(20)), Position=UDim2.new(0,FS(10),0,FS(6)),
    BackgroundTransparency=1, Text="BALANCE", TextColor3=C.muted,
    TextSize=FS(11), Font=Enum.Font.GothamBold,  -- LEBIH BESAR
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=moneyCard
})
newInst("TextLabel",{
    Size=UDim2.new(0.5,-FS(10),0,FS(20)), Position=UDim2.new(0.5,0,0,FS(6)),
    BackgroundTransparency=1, Text="/ HOUR", TextColor3=C.muted,
    TextSize=FS(11), Font=Enum.Font.GothamBold,  -- LEBIH BESAR
    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12, Parent=moneyCard
})

local balanceLbl = newInst("TextLabel",{
    Name="BalanceLbl",
    Size=UDim2.new(0.55,0,0,FS(32)), Position=UDim2.new(0,FS(10),0,FS(24)),
    BackgroundTransparency=1, Text="$0", TextColor3=C.white,
    TextSize=FS(25), Font=Enum.Font.GothamBold,  -- LEBIH BESAR
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=moneyCard
})
local perHourLbl = newInst("TextLabel",{
    Name="PerHourLbl",
    Size=UDim2.new(0.45,-FS(10),0,FS(32)), Position=UDim2.new(0.55,0,0,FS(24)),
    BackgroundTransparency=1, Text="$0", TextColor3=C.green,
    TextSize=FS(25), Font=Enum.Font.GothamBold,  -- LEBIH BESAR
    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12, Parent=moneyCard
})
local sessionLbl = newInst("TextLabel",{
    Name="SessionLbl",
    Size=UDim2.new(1,-FS(20),0,FS(18)), Position=UDim2.new(0,FS(10),1,-FS(20)),
    BackgroundTransparency=1, Text="Session: 0:00  ·  +$0 gained",
    TextColor3=C.muted, TextSize=FS(12), Font=Enum.Font.Gotham,  -- LEBIH BESAR
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=moneyCard
})

-- ── MAIN BUTTON ──────────────────────────────────────────────────────────────
local btn = newInst("TextButton", {
    Name             = "AutoFarmToggle",
    Size             = UDim2.new(1,-FS(28),0,FS(44)),
    Position         = UDim2.new(0,FS(14),0,FS(196)),
    BackgroundColor3 = C.accent,
    BorderSizePixel  = 0,
    Text             = "Start AutoFarm",
    TextColor3       = Color3.fromRGB(10,10,12),
    TextSize         = FS(16),   -- LEBIH BESAR
    Font             = Enum.Font.GothamBold,
    ZIndex           = 11,
    Parent           = frame,
})
corner(10, btn)
local btnStroke = mkStroke(Color3.fromRGB(40,130,80), 1.5, btn, 0.4)

local btnGrad = Instance.new("UIGradient")
btnGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   C.r4),
    ColorSequenceKeypoint.new(0.5, C.r5),
    ColorSequenceKeypoint.new(1.0, C.r6),
}
btnGrad.Rotation = 45
btnGrad.Parent = btn

btn.MouseEnter:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(80,190,130)}):Play()
end)
btn.MouseLeave:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=C.accent}):Play()
end)

-- ════════════════════════════════════════════════════════════════════════════
--  MINIMIZE (tombol tunggal − di kanan, frame mengecil + layar gelap)
-- ════════════════════════════════════════════════════════════════════════════
local minimized  = false
local miniH      = FS(55)
local TWEEN_MIN  = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local contentItems = {divider, statusCard, moneyCard, btn}

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- ciutkan
        for _, v in ipairs(contentItems) do v.Visible = false end
        TweenService:Create(frame, TWEEN_MIN, {Size = UDim2.new(0, frame.AbsoluteSize.X, 0, miniH)}):Play()
        TweenService:Create(dimOverlay, TWEEN_MIN, {BackgroundTransparency = 0.5}):Play()
        dimOverlay.Visible = true
        minBtn.Text        = "+"
    else
        -- buka kembali
        TweenService:Create(frame, TWEEN_MIN, {Size = UDim2.new(0, frame.AbsoluteSize.X, 0, math.max(frame.AbsoluteSize.Y, H))}):Play()
        TweenService:Create(dimOverlay, TWEEN_MIN, {BackgroundTransparency = 1}):Play()
        minBtn.Text = "−"
        task.delay(0.32, function()
            dimOverlay.Visible = false
            for _, v in ipairs(contentItems) do v.Visible = true end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  FREE RESIZE — drag dari sudut/tepi frame
--  Overhead: 1 Heartbeat connection, hanya aktif saat tombol ditekan
-- ════════════════════════════════════════════════════════════════════════════
local MIN_W, MIN_H = FS(220), FS(200)  -- ukuran minimum
local EDGE         = FS(14)            -- lebar zona resize di tepi

-- Handle resize sudut kanan-bawah (paling umum dipakai)
local resizeHandle = newInst("TextButton", {
    Size             = UDim2.new(0, FS(20), 0, FS(20)),
    Position         = UDim2.new(1, -FS(20), 1, -FS(20)),
    AnchorPoint      = Vector2.new(1, 1),
    BackgroundColor3 = Color3.fromRGB(50, 50, 60),
    BackgroundTransparency = 0.5,
    BorderSizePixel  = 0,
    Text             = "⌟",
    TextColor3       = C.muted,
    TextSize         = FS(14),
    Font             = Enum.Font.GothamBold,
    ZIndex           = 20,
    Parent           = frame,
})
corner(4, resizeHandle)

-- Resize state
local resizing     = false
local resize_startX, resize_startY = 0, 0
local resize_startW, resize_startH = 0, 0

resizeHandle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        resizing       = true
        resize_startX  = inp.Position.X
        resize_startY  = inp.Position.Y
        resize_startW  = frame.AbsoluteSize.X
        resize_startH  = frame.AbsoluteSize.Y
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(inp)
    if resizing and (inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch) then
        local dx = inp.Position.X - resize_startX
        local dy = inp.Position.Y - resize_startY
        local newW = math.max(MIN_W, resize_startW + dx)
        local newH = math.max(MIN_H, resize_startH + dy)
        frame.Size = UDim2.new(0, newW, 0, newH)
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
            BackgroundColor3 = Color3.fromRGB(30,155,85)
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
--  RAINBOW SHIMMER  (20fps, hemat CPU)
-- ════════════════════════════════════════════════════════════════════════════
local rT, rEl = 0, 0
RunService.Heartbeat:Connect(function(dt)
    rEl += dt
    if rEl < 0.05 then return end
    rEl = 0
    rT  = (rT + 0.018) % 1
    local ox = math.sin(rT * math.pi * 2) * 0.5
    titleGrad.Offset = Vector2.new(ox,  0)
    topGrad.Offset   = Vector2.new(-ox, 0)
    local cols = {C.r1,C.r2,C.r3,C.r4,C.r5,C.r6}
    loveLbl.TextColor3 = cols[math.floor(rT*6)+1] or C.r1
end)

-- ════════════════════════════════════════════════════════════════════════════
--  MONEY TRACKER  (update tiap 2 detik via Heartbeat)
-- ════════════════════════════════════════════════════════════════════════════
local mEl = 0
RunService.Heartbeat:Connect(function(dt)
    mEl += dt
    if mEl < 2 then return end
    mEl = 0
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end
    local cash = ls:FindFirstChild("Cash")
    if not cash then return end
    local now     = cash.Value
    local gained  = now - (_G.AF_moneyStart or 0)
    local sesTime = tick() - (_G.AF_sessionStart or tick())
    balanceLbl.Text = "$" .. fmt(now)
    sessionLbl.Text = "Session: " .. fmtTime(math.floor(sesTime)) .. "  ·  +$" .. fmt(math.max(0,gained)) .. " gained"
    if sesTime > 5 then
        perHourLbl.Text = "$" .. fmt(math.floor(gained / sesTime * 3600))
    end
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
--  DRAGGABLE  (drag dari area title bar, tidak konflik dengan resize)
-- ════════════════════════════════════════════════════════════════════════════
do
    local dragging, dragStart, startPos, dragInput

    frame.InputBegan:Connect(function(inp)
        -- jangan drag kalau sedang resize
        if resizing then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            -- hanya drag kalau klik di area title bar (Y < 55)
            local relY = inp.Position.Y - frame.AbsolutePosition.Y
            if relY > FS(55) then return end
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
        if inp == dragInput and dragging and not resizing then
            local d = inp.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end-- ============================================
--   Garskirtz Ganteng | GUI.lua  v4
--   + bigger text, dot next to title,
--   + single minimize button, free resize
-- ============================================

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

-- ── Responsive base scale ────────────────────────────────────────────────────
local vp       = workspace.CurrentCamera.ViewportSize
local isMobile = vp.X < 1000
local SCALE    = isMobile and 1.45 or 1.0

-- Base dimensions
local BASE_W = 310
local BASE_H = 250
local W = math.floor(BASE_W * SCALE)
local H = math.floor(BASE_H * SCALE)
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
    bg     = Color3.fromRGB(12,  12,  14),
    card   = Color3.fromRGB(22,  22,  28),
    border = Color3.fromRGB(45,  45,  58),
    white  = Color3.fromRGB(230, 230, 235),
    muted  = Color3.fromRGB(110, 110, 130),
    red    = Color3.fromRGB(255, 75,  75),
    green  = Color3.fromRGB(72,  220, 130),
    danger = Color3.fromRGB(255, 75,  75),
    accent = Color3.fromRGB(60,  170, 110),
    r1 = Color3.fromRGB(255, 80,  80),
    r2 = Color3.fromRGB(255, 165, 0),
    r3 = Color3.fromRGB(245, 225, 0),
    r4 = Color3.fromRGB(80,  210, 80),
    r5 = Color3.fromRGB(80,  155, 255),
    r6 = Color3.fromRGB(180, 80,  255),
}

-- ════════════════════════════════════════════════════════════════════════════
--  ROOT
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
    Size                   = UDim2.new(1,0,1,0),
    BackgroundColor3       = Color3.new(0,0,0),
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
    ClipsDescendants = true,
    Parent           = root,
})
corner(12, frame)
mkStroke(C.border, 1.5, frame)

-- Rainbow top accent bar
local topBar = newInst("Frame", {
    Size             = UDim2.new(1,0,0,3),
    BackgroundColor3 = C.r1,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})
corner(12, topBar)
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

-- ── TITLE BAR ────────────────────────────────────────────────────────────────
-- Heart emoji
local loveLbl = newInst("TextLabel", {
    Size                   = UDim2.new(0, FS(22), 0, FS(48)),
    Position               = UDim2.new(0, FS(12), 0, FS(4)),
    BackgroundTransparency = 1,
    Text                   = "❤",
    TextColor3             = C.r1,
    TextSize               = FS(16),
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Center,
    ZIndex                 = 12,
    Parent                 = frame,
})

-- Title label
local titleLbl = newInst("TextLabel", {
    Size                   = UDim2.new(0, FS(155), 0, FS(48)),
    Position               = UDim2.new(0, FS(36), 0, FS(4)),
    BackgroundTransparency = 1,
    Text                   = "Garskirtz Ganteng",
    TextColor3             = C.white,
    TextSize               = FS(16),   -- LEBIH BESAR
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 12,
    Parent                 = frame,
})
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

-- Dot indicator — tepat di sebelah kanan judul, berdekatan
local dot = newInst("Frame", {
    Size             = UDim2.new(0, FS(9), 0, FS(9)),
    -- posisi: setelah titleLbl (x=36+155=191) + gap kecil 5px
    Position         = UDim2.new(0, FS(194), 0, FS(23)),
    AnchorPoint      = Vector2.new(0, 0.5),
    BackgroundColor3 = C.red,   -- MERAH saat idle
    BorderSizePixel  = 0,
    ZIndex           = 12,
    Parent           = frame,
})
corner(99, dot)

-- Minimize button (−) pojok kanan atas
local minBtn = newInst("TextButton", {
    Size             = UDim2.new(0, FS(28), 0, FS(24)),
    Position         = UDim2.new(1, -FS(10), 0, FS(12)),
    AnchorPoint      = Vector2.new(1, 0),
    BackgroundColor3 = Color3.fromRGB(35, 35, 42),
    BorderSizePixel  = 0,
    Text             = "−",
    TextColor3       = C.muted,
    TextSize         = FS(18),
    Font             = Enum.Font.GothamBold,
    ZIndex           = 13,
    Parent           = frame,
})
corner(6, minBtn)
minBtn.MouseEnter:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(60,60,70)}):Play()
end)
minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(35,35,42)}):Play()
end)

-- ── DIVIDER ──────────────────────────────────────────────────────────────────
local divider = newInst("Frame", {
    Size             = UDim2.new(1,-FS(28),0,1),
    Position         = UDim2.new(0,FS(14),0,FS(55)),
    BackgroundColor3 = C.border,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})

-- ── STATUS CARD ──────────────────────────────────────────────────────────────
local statusCard = newInst("Frame", {
    Size             = UDim2.new(1,-FS(28),0,FS(38)),
    Position         = UDim2.new(0,FS(14),0,FS(65)),
    BackgroundColor3 = C.card,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})
corner(8, statusCard)

local statusIcon = newInst("TextLabel", {
    Size                   = UDim2.new(0,FS(24),1,0),
    Position               = UDim2.new(0,FS(8),0,0),
    BackgroundTransparency = 1,
    Text                   = "●",
    TextColor3             = C.red,
    TextSize               = FS(11),
    Font                   = Enum.Font.Gotham,
    TextXAlignment         = Enum.TextXAlignment.Center,
    ZIndex                 = 12,
    Parent                 = statusCard,
})

local statusText = newInst("TextLabel", {
    Name                   = "StatusText",
    Size                   = UDim2.new(1,-FS(36),1,0),
    Position               = UDim2.new(0,FS(32),0,0),
    BackgroundTransparency = 1,
    Text                   = "Stopped — sit in vehicle to start",
    TextColor3             = C.muted,
    TextSize               = FS(13),   -- LEBIH BESAR
    Font                   = Enum.Font.Gotham,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 12,
    Parent                 = statusCard,
})

-- ── MONEY CARD ───────────────────────────────────────────────────────────────
local moneyCard = newInst("Frame", {
    Size             = UDim2.new(1,-FS(28),0,FS(72)),
    Position         = UDim2.new(0,FS(14),0,FS(113)),
    BackgroundColor3 = C.card,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})
corner(8, moneyCard)
mkStroke(C.border, 1, moneyCard, 0.4)

-- Labels atas
newInst("TextLabel",{
    Size=UDim2.new(0.5,0,0,FS(20)), Position=UDim2.new(0,FS(10),0,FS(6)),
    BackgroundTransparency=1, Text="BALANCE", TextColor3=C.muted,
    TextSize=FS(11), Font=Enum.Font.GothamBold,  -- LEBIH BESAR
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=moneyCard
})
newInst("TextLabel",{
    Size=UDim2.new(0.5,-FS(10),0,FS(20)), Position=UDim2.new(0.5,0,0,FS(6)),
    BackgroundTransparency=1, Text="/ HOUR", TextColor3=C.muted,
    TextSize=FS(11), Font=Enum.Font.GothamBold,  -- LEBIH BESAR
    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12, Parent=moneyCard
})

local balanceLbl = newInst("TextLabel",{
    Name="BalanceLbl",
    Size=UDim2.new(0.55,0,0,FS(32)), Position=UDim2.new(0,FS(10),0,FS(24)),
    BackgroundTransparency=1, Text="$0", TextColor3=C.white,
    TextSize=FS(25), Font=Enum.Font.GothamBold,  -- LEBIH BESAR
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=moneyCard
})
local perHourLbl = newInst("TextLabel",{
    Name="PerHourLbl",
    Size=UDim2.new(0.45,-FS(10),0,FS(32)), Position=UDim2.new(0.55,0,0,FS(24)),
    BackgroundTransparency=1, Text="$0", TextColor3=C.green,
    TextSize=FS(25), Font=Enum.Font.GothamBold,  -- LEBIH BESAR
    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12, Parent=moneyCard
})
local sessionLbl = newInst("TextLabel",{
    Name="SessionLbl",
    Size=UDim2.new(1,-FS(20),0,FS(18)), Position=UDim2.new(0,FS(10),1,-FS(20)),
    BackgroundTransparency=1, Text="Session: 0:00  ·  +$0 gained",
    TextColor3=C.muted, TextSize=FS(12), Font=Enum.Font.Gotham,  -- LEBIH BESAR
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=moneyCard
})

-- ── MAIN BUTTON ──────────────────────────────────────────────────────────────
local btn = newInst("TextButton", {
    Name             = "AutoFarmToggle",
    Size             = UDim2.new(1,-FS(28),0,FS(44)),
    Position         = UDim2.new(0,FS(14),0,FS(196)),
    BackgroundColor3 = C.accent,
    BorderSizePixel  = 0,
    Text             = "Start AutoFarm",
    TextColor3       = Color3.fromRGB(10,10,12),
    TextSize         = FS(16),   -- LEBIH BESAR
    Font             = Enum.Font.GothamBold,
    ZIndex           = 11,
    Parent           = frame,
})
corner(10, btn)
local btnStroke = mkStroke(Color3.fromRGB(40,130,80), 1.5, btn, 0.4)

local btnGrad = Instance.new("UIGradient")
btnGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   C.r4),
    ColorSequenceKeypoint.new(0.5, C.r5),
    ColorSequenceKeypoint.new(1.0, C.r6),
}
btnGrad.Rotation = 45
btnGrad.Parent = btn

btn.MouseEnter:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(80,190,130)}):Play()
end)
btn.MouseLeave:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=C.accent}):Play()
end)

-- ════════════════════════════════════════════════════════════════════════════
--  MINIMIZE (tombol tunggal − di kanan, frame mengecil + layar gelap)
-- ════════════════════════════════════════════════════════════════════════════
local minimized  = false
local miniH      = FS(55)
local TWEEN_MIN  = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local contentItems = {divider, statusCard, moneyCard, btn}

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- ciutkan
        for _, v in ipairs(contentItems) do v.Visible = false end
        TweenService:Create(frame, TWEEN_MIN, {Size = UDim2.new(0, frame.AbsoluteSize.X, 0, miniH)}):Play()
        TweenService:Create(dimOverlay, TWEEN_MIN, {BackgroundTransparency = 0.5}):Play()
        dimOverlay.Visible = true
        minBtn.Text        = "+"
    else
        -- buka kembali
        TweenService:Create(frame, TWEEN_MIN, {Size = UDim2.new(0, frame.AbsoluteSize.X, 0, math.max(frame.AbsoluteSize.Y, H))}):Play()
        TweenService:Create(dimOverlay, TWEEN_MIN, {BackgroundTransparency = 1}):Play()
        minBtn.Text = "−"
        task.delay(0.32, function()
            dimOverlay.Visible = false
            for _, v in ipairs(contentItems) do v.Visible = true end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  FREE RESIZE — drag dari sudut/tepi frame
--  Overhead: 1 Heartbeat connection, hanya aktif saat tombol ditekan
-- ════════════════════════════════════════════════════════════════════════════
local MIN_W, MIN_H = FS(220), FS(200)  -- ukuran minimum
local EDGE         = FS(14)            -- lebar zona resize di tepi

-- Handle resize sudut kanan-bawah (paling umum dipakai)
local resizeHandle = newInst("TextButton", {
    Size             = UDim2.new(0, FS(20), 0, FS(20)),
    Position         = UDim2.new(1, -FS(20), 1, -FS(20)),
    AnchorPoint      = Vector2.new(1, 1),
    BackgroundColor3 = Color3.fromRGB(50, 50, 60),
    BackgroundTransparency = 0.5,
    BorderSizePixel  = 0,
    Text             = "⌟",
    TextColor3       = C.muted,
    TextSize         = FS(14),
    Font             = Enum.Font.GothamBold,
    ZIndex           = 20,
    Parent           = frame,
})
corner(4, resizeHandle)

-- Resize state
local resizing     = false
local resize_startX, resize_startY = 0, 0
local resize_startW, resize_startH = 0, 0

resizeHandle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        resizing       = true
        resize_startX  = inp.Position.X
        resize_startY  = inp.Position.Y
        resize_startW  = frame.AbsoluteSize.X
        resize_startH  = frame.AbsoluteSize.Y
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(inp)
    if resizing and (inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch) then
        local dx = inp.Position.X - resize_startX
        local dy = inp.Position.Y - resize_startY
        local newW = math.max(MIN_W, resize_startW + dx)
        local newH = math.max(MIN_H, resize_startH + dy)
        frame.Size = UDim2.new(0, newW, 0, newH)
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
            BackgroundColor3 = Color3.fromRGB(30,155,85)
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
--  RAINBOW SHIMMER  (20fps, hemat CPU)
-- ════════════════════════════════════════════════════════════════════════════
local rT, rEl = 0, 0
RunService.Heartbeat:Connect(function(dt)
    rEl += dt
    if rEl < 0.05 then return end
    rEl = 0
    rT  = (rT + 0.018) % 1
    local ox = math.sin(rT * math.pi * 2) * 0.5
    titleGrad.Offset = Vector2.new(ox,  0)
    topGrad.Offset   = Vector2.new(-ox, 0)
    local cols = {C.r1,C.r2,C.r3,C.r4,C.r5,C.r6}
    loveLbl.TextColor3 = cols[math.floor(rT*6)+1] or C.r1
end)

-- ════════════════════════════════════════════════════════════════════════════
--  MONEY TRACKER  (update tiap 2 detik via Heartbeat)
-- ════════════════════════════════════════════════════════════════════════════
local mEl = 0
RunService.Heartbeat:Connect(function(dt)
    mEl += dt
    if mEl < 2 then return end
    mEl = 0
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end
    local cash = ls:FindFirstChild("Cash")
    if not cash then return end
    local now     = cash.Value
    local gained  = now - (_G.AF_moneyStart or 0)
    local sesTime = tick() - (_G.AF_sessionStart or tick())
    balanceLbl.Text = "$" .. fmt(now)
    sessionLbl.Text = "Session: " .. fmtTime(math.floor(sesTime)) .. "  ·  +$" .. fmt(math.max(0,gained)) .. " gained"
    if sesTime > 5 then
        perHourLbl.Text = "$" .. fmt(math.floor(gained / sesTime * 3600))
    end
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
--  DRAGGABLE  (drag dari area title bar, tidak konflik dengan resize)
-- ════════════════════════════════════════════════════════════════════════════
do
    local dragging, dragStart, startPos, dragInput

    frame.InputBegan:Connect(function(inp)
        -- jangan drag kalau sedang resize
        if resizing then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            -- hanya drag kalau klik di area title bar (Y < 55)
            local relY = inp.Position.Y - frame.AbsolutePosition.Y
            if relY > FS(55) then return end
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
        if inp == dragInput and dragging and not resizing then
            local d = inp.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end
