-- ============================================
--   Garskirtz Ganteng | GUI.lua  v5
--   Fixes: floating minimize, dot alignment,
--   dot color instant, responsive content resize
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

-- ── Responsive scale ─────────────────────────────────────────────────────────
local vp       = workspace.CurrentCamera.ViewportSize
local isMobile = vp.X < 1000
local SCALE    = isMobile and 1.45 or 1.0
local W        = math.floor(310 * SCALE)
local H        = math.floor(250 * SCALE)
local FS       = function(s) return math.floor(s * SCALE) end

-- ════════════════════════════════════════════════════════════════════════════
-- GANTI GAMBAR DI SINI:
-- Isi dengan rbxassetid://IDKAMU untuk pakai gambar sendiri
-- ════════════════════════════════════════════════════════════════════════════
local FLOAT_IMAGE = "rbxassetid://6031075938" -- default: atom icon biru

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
--  FLOATING MINIMIZE BUTTON (muncul saat minimize, draggable)
-- ════════════════════════════════════════════════════════════════════════════
local floatSize = FS(58)

local floatBtn = newInst("ImageButton", {
    Size             = UDim2.new(0, floatSize, 0, floatSize),
    Position         = UDim2.new(0, FS(20), 0.5, -floatSize/2),
    BackgroundColor3 = Color3.fromRGB(30, 30, 40),
    BorderSizePixel  = 0,
    Image            = FLOAT_IMAGE,
    ScaleType        = Enum.ScaleType.Fit,
    ZIndex           = 50,
    Visible          = false,
    Parent           = root,
})
corner(16, floatBtn)
mkStroke(C.border, 2, floatBtn, 0.3)

-- dot status kecil di sudut kanan atas floatBtn
local floatDot = newInst("Frame", {
    Size             = UDim2.new(0, FS(10), 0, FS(10)),
    Position         = UDim2.new(1, -FS(4), 0, FS(4)),
    AnchorPoint      = Vector2.new(1, 0),
    BackgroundColor3 = C.red,
    BorderSizePixel  = 0,
    ZIndex           = 51,
    Parent           = floatBtn,
})
corner(99, floatDot)
mkStroke(Color3.fromRGB(12,12,14), 1.5, floatDot)

-- Draggable floatBtn
do
    local fDrag, fStart, fPos, fInput = false, nil, nil, nil
    floatBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            fDrag  = true
            fStart = inp.Position
            fPos   = floatBtn.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then fDrag = false end
            end)
        end
    end)
    floatBtn.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            fInput = inp
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if inp == fInput and fDrag then
            local d = inp.Position - fStart
            floatBtn.Position = UDim2.new(
                fPos.X.Scale, fPos.X.Offset + d.X,
                fPos.Y.Scale, fPos.Y.Offset + d.Y
            )
        end
    end)
end

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

-- Rainbow top bar
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
-- Tinggi title bar = FS(52)
local TITLE_H = FS(52)

local loveLbl = newInst("TextLabel", {
    Size                   = UDim2.new(0, FS(22), 0, TITLE_H),
    Position               = UDim2.new(0, FS(12), 0, FS(3)),
    BackgroundTransparency = 1,
    Text                   = "❤",
    TextColor3             = C.r1,
    TextSize               = FS(16),
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Center,
    TextYAlignment         = Enum.TextYAlignment.Center,
    ZIndex                 = 12,
    Parent                 = frame,
})

local titleLbl = newInst("TextLabel", {
    Size                   = UDim2.new(0, FS(158), 0, TITLE_H),
    Position               = UDim2.new(0, FS(36), 0, FS(3)),
    BackgroundTransparency = 1,
    Text                   = "Garskirtz Ganteng",
    TextColor3             = C.white,
    TextSize               = FS(16),
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Left,
    TextYAlignment         = Enum.TextYAlignment.Center,
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

-- FIX: dot sejajar vertikal dengan teks title
-- Pakai AnchorPoint Y=0.5 dan posisi Y relatif ke tengah title bar
local dot = newInst("Frame", {
    Size             = UDim2.new(0, FS(9), 0, FS(9)),
    -- X: setelah title (36 + 158 + 6 gap = 200)
    -- Y: tengah title bar = (TITLE_H/2 + 3) - dot_radius
    Position         = UDim2.new(0, FS(200), 0, FS(3) + TITLE_H/2 - FS(4)),
    BackgroundColor3 = C.red,
    BorderSizePixel  = 0,
    ZIndex           = 12,
    Parent           = frame,
})
corner(99, dot)

-- Minimize button (−/+) pojok kanan
local minBtn = newInst("TextButton", {
    Size             = UDim2.new(0, FS(28), 0, FS(24)),
    Position         = UDim2.new(1, -FS(10), 0, FS(3) + TITLE_H/2 - FS(12)),
    AnchorPoint      = Vector2.new(1, 0),
    BackgroundColor3 = Color3.fromRGB(35,35,42),
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
    TweenService:Create(minBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(60,60,70)}):Play()
end)
minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(35,35,42)}):Play()
end)

-- ── DIVIDER ──────────────────────────────────────────────────────────────────
local DIVIDER_Y = FS(3) + TITLE_H + FS(2)

local divider = newInst("Frame", {
    Size             = UDim2.new(1,-FS(28),0,1),
    Position         = UDim2.new(0,FS(14),0, DIVIDER_Y),
    BackgroundColor3 = C.border,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})

-- ── STATUS CARD ──────────────────────────────────────────────────────────────
-- Semua elemen pakai UDim2 relative (Scale) agar menyesuaikan saat resize

local STATUS_Y = DIVIDER_Y + FS(8)
local STATUS_H = FS(38)

local statusCard = newInst("Frame", {
    -- FIX RESIZE: pakai scale width agar ikut lebar frame
    Size             = UDim2.new(1,-FS(28), 0, STATUS_H),
    Position         = UDim2.new(0,FS(14),  0, STATUS_Y),
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
    TextYAlignment         = Enum.TextYAlignment.Center,
    ZIndex                 = 12,
    Parent                 = statusCard,
})

local statusText = newInst("TextLabel", {
    Name                   = "StatusText",
    -- Scale width agar teks tidak terpotong saat resize
    Size                   = UDim2.new(1,-FS(36),1,0),
    Position               = UDim2.new(0,FS(32),0,0),
    BackgroundTransparency = 1,
    Text                   = "Stopped — sit in vehicle to start",
    TextColor3             = C.muted,
    TextSize               = FS(13),
    Font                   = Enum.Font.Gotham,
    TextXAlignment         = Enum.TextXAlignment.Left,
    TextYAlignment         = Enum.TextYAlignment.Center,
    ZIndex                 = 12,
    Parent                 = statusCard,
})

-- ── MONEY CARD ───────────────────────────────────────────────────────────────
local MONEY_Y = STATUS_Y + STATUS_H + FS(8)
local MONEY_H = FS(72)

local moneyCard = newInst("Frame", {
    Size             = UDim2.new(1,-FS(28), 0, MONEY_H),
    Position         = UDim2.new(0,FS(14),  0, MONEY_Y),
    BackgroundColor3 = C.card,
    BorderSizePixel  = 0,
    ZIndex           = 11,
    Parent           = frame,
})
corner(8, moneyCard)
mkStroke(C.border, 1, moneyCard, 0.4)

-- Header labels (scale width)
newInst("TextLabel",{
    Size=UDim2.new(0.5,0,0,FS(20)), Position=UDim2.new(0,FS(10),0,FS(6)),
    BackgroundTransparency=1, Text="BALANCE", TextColor3=C.muted,
    TextSize=FS(11), Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=moneyCard
})
newInst("TextLabel",{
    Size=UDim2.new(0.5,-FS(10),0,FS(20)), Position=UDim2.new(0.5,0,0,FS(6)),
    BackgroundTransparency=1, Text="/ HOUR", TextColor3=C.muted,
    TextSize=FS(11), Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12, Parent=moneyCard
})

-- Value labels — scale width agar simetris saat resize
local balanceLbl = newInst("TextLabel",{
    Name="BalanceLbl",
    Size=UDim2.new(0.5,0,0,FS(32)), Position=UDim2.new(0,FS(10),0,FS(24)),
    BackgroundTransparency=1, Text="$0", TextColor3=C.white,
    TextSize=FS(25), Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=moneyCard
})
local perHourLbl = newInst("TextLabel",{
    Name="PerHourLbl",
    Size=UDim2.new(0.5,-FS(10),0,FS(32)), Position=UDim2.new(0.5,0,0,FS(24)),
    BackgroundTransparency=1, Text="$0", TextColor3=C.green,
    TextSize=FS(25), Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=12, Parent=moneyCard
})
local sessionLbl = newInst("TextLabel",{
    Name="SessionLbl",
    Size=UDim2.new(1,-FS(20),0,FS(18)), Position=UDim2.new(0,FS(10),1,-FS(20)),
    BackgroundTransparency=1, Text="Session: 0:00  ·  +$0 gained",
    TextColor3=C.muted, TextSize=FS(12), Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=moneyCard
})

-- ── MAIN BUTTON ──────────────────────────────────────────────────────────────
local BTN_Y = MONEY_Y + MONEY_H + FS(8)
local BTN_H = FS(44)

local btn = newInst("TextButton", {
    Name             = "AutoFarmToggle",
    Size             = UDim2.new(1,-FS(28), 0, BTN_H),
    Position         = UDim2.new(0,FS(14),  0, BTN_Y),
    BackgroundColor3 = C.accent,
    BorderSizePixel  = 0,
    Text             = "Start AutoFarm",
    TextColor3       = Color3.fromRGB(10,10,12),
    TextSize         = FS(16),
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
    TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(80,190,130)}):Play()
end)
btn.MouseLeave:Connect(function()
    TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=C.accent}):Play()
end)

-- ── RESIZE HANDLE ────────────────────────────────────────────────────────────
local resizeHandle = newInst("TextButton", {
    Size                   = UDim2.new(0,FS(20),0,FS(20)),
    Position               = UDim2.new(1,-FS(20),1,-FS(20)),
    AnchorPoint            = Vector2.new(1,1),
    BackgroundColor3       = Color3.fromRGB(50,50,60),
    BackgroundTransparency = 0.5,
    BorderSizePixel        = 0,
    Text                   = "⌟",
    TextColor3             = C.muted,
    TextSize               = FS(14),
    Font                   = Enum.Font.GothamBold,
    ZIndex                 = 20,
    Parent                 = frame,
})
corner(4, resizeHandle)

-- ════════════════════════════════════════════════════════════════════════════
--  MINIMIZE LOGIC — floating button
-- ════════════════════════════════════════════════════════════════════════════
local minimized = false
local TWEEN_MIN = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

minBtn.MouseButton1Click:Connect(function()
    minimized = true
    -- simpan posisi floating btn dekat posisi frame
    floatBtn.Position = UDim2.new(
        0, frame.AbsolutePosition.X + FS(10),
        0, frame.AbsolutePosition.Y + FS(10)
    )
    -- animasi frame menghilang
    TweenService:Create(frame, TWEEN_MIN, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, frame.AbsoluteSize.X, 0, 0)
    }):Play()
    TweenService:Create(dimOverlay, TWEEN_MIN, {BackgroundTransparency = 0.5}):Play()
    dimOverlay.Visible = true
    task.delay(0.28, function()
        frame.Visible  = false
        floatBtn.Visible = true
    end)
end)

-- Klik floating button → buka kembali frame
floatBtn.MouseButton1Click:Connect(function()
    -- cek apakah ini click atau drag (kalau drag jangan buka)
    minimized = false
    floatBtn.Visible = false
    frame.Visible    = true
    frame.Size       = UDim2.new(0, W, 0, 0)
    frame.BackgroundTransparency = 0
    TweenService:Create(frame, TWEEN_MIN, {Size = UDim2.new(0, W, 0, H)}):Play()
    TweenService:Create(dimOverlay, TWEEN_MIN, {BackgroundTransparency = 1}):Play()
    task.delay(0.3, function() dimOverlay.Visible = false end)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  FREE RESIZE (drag sudut kanan bawah)
-- ════════════════════════════════════════════════════════════════════════════
local MIN_W, MIN_H_R = FS(240), FS(220)
local resizing = false
local rStartX, rStartY, rStartW, rStartH = 0,0,0,0

resizeHandle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        rStartX  = inp.Position.X
        rStartY  = inp.Position.Y
        rStartW  = frame.AbsoluteSize.X
        rStartH  = frame.AbsoluteSize.Y
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(inp)
    if not resizing then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement
    and inp.UserInputType ~= Enum.UserInputType.Touch then return end

    local newW = math.max(MIN_W, rStartW + (inp.Position.X - rStartX))
    local newH = math.max(MIN_H_R, rStartH + (inp.Position.Y - rStartY))
    frame.Size = UDim2.new(0, newW, 0, newH)

    -- FIX RESIZE CONTENT: tombol ikut posisi bawah frame
    -- Status card & money card sudah pakai Size scale=1 jadi otomatis ikut lebar
    -- Hanya posisi Y tombol yang perlu di-recompute agar tidak ada space kosong
    local usableH    = newH
    local newBtnY    = usableH - BTN_H - FS(14)
    local newMoneyY  = newBtnY - MONEY_H - FS(8)
    local newStatusY = newMoneyY - STATUS_H - FS(8)
    local newDivY    = newStatusY - FS(10)

    divider.Position    = UDim2.new(0, FS(14), 0, newDivY)
    statusCard.Position = UDim2.new(0, FS(14), 0, newStatusY)
    moneyCard.Position  = UDim2.new(0, FS(14), 0, newMoneyY)
    btn.Position        = UDim2.new(0, FS(14), 0, newBtnY)
end)

-- ════════════════════════════════════════════════════════════════════════════
--  DOT PULSE + FIX: update dot & floatDot bersama
-- ════════════════════════════════════════════════════════════════════════════
local dotPulse = false

local function setDotColor(col)
    -- FIX: langsung set tanpa tween agar perubahan instan
    dot.BackgroundColor3      = col
    floatDot.BackgroundColor3 = col
    statusIcon.TextColor3     = col
end

local function startDotPulse()
    if dotPulse then return end
    dotPulse = true
    setDotColor(C.green)
    local function ping()
        if not dotPulse then return end
        TweenService:Create(dot, TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,true),{
            BackgroundColor3 = Color3.fromRGB(30,155,85)
        }):Play()
        TweenService:Create(floatDot, TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,true),{
            BackgroundColor3 = Color3.fromRGB(30,155,85)
        }):Play()
        task.delay(1.2, ping)
    end
    ping()
end

local function stopDotPulse()
    dotPulse = false
    -- FIX: langsung merah, tidak perlu tunggu tween
    setDotColor(C.red)
end

-- ════════════════════════════════════════════════════════════════════════════
--  RAINBOW SHIMMER (20fps)
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
--  MONEY TRACKER (update tiap 2 detik)
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
--  DRAGGABLE (title bar area saja, tidak konflik dengan resize)
-- ════════════════════════════════════════════════════════════════════════════
do
    local dragging, dragStart, startPos, dragInput

    frame.InputBegan:Connect(function(inp)
        if resizing then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            local relY = inp.Position.Y - frame.AbsolutePosition.Y
            if relY > TITLE_H + FS(3) then return end  -- hanya title bar
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
