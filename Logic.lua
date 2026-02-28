-- ============================================
--   Garskirtz Premium UI | v6 (Modern Dark)
-- ============================================

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
local SCALE    = isMobile and 1.2 or 1.0
local W, H     = math.floor(340 * SCALE), math.floor(280 * SCALE)
local FS       = function(s) return math.floor(s * SCALE) end

-- ── Palette (Premium Dark) ───────────────────────────────────────────────────
local C = {
    bg      = Color3.fromRGB(15, 15, 18),
    card    = Color3.fromRGB(24, 24, 30),
    accent  = Color3.fromRGB(0, 162, 255), -- Azure Blue
    success = Color3.fromRGB(0, 255, 130),
    danger  = Color3.fromRGB(255, 70, 70),
    text    = Color3.fromRGB(255, 255, 255),
    muted   = Color3.fromRGB(140, 140, 155),
    outline = Color3.fromRGB(45, 45, 55),
}

-- ── Helpers ──────────────────────────────────────────────────────────────────
local function newInst(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k] = v end
    return o
end

local function mkCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = p
    return c
end

local function mkStroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or C.outline
    s.Thickness = thick or 1.2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function fmt(n)
    if n >= 1e9 then return ("%.2fB"):format(n/1e9)
    elseif n >= 1e6 then return ("%.2fM"):format(n/1e6)
    elseif n >= 1e3 then return ("%.1fK"):format(n/1e3)
    else return tostring(math.floor(n)) end
end

-- ════════════════════════════════════════════════════════════════════════════
--  CORE UI
-- ════════════════════════════════════════════════════════════════════════════
local root = newInst("ScreenGui", { Name = "PremiumFarm", Parent = player.PlayerGui, IgnoreGuiInset = true })

local main = newInst("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, W, 0, H),
    Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Parent = root
})
mkCorner(main, 14)
mkStroke(main, C.outline, 1.5)

-- Drop Shadow (Glow Effect)
local shadow = newInst("ImageLabel", {
    Size = UDim2.new(1, 40, 1, 40),
    Position = UDim2.new(0, -20, 0, -20),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014264795",
    ImageColor3 = Color3.new(0,0,0),
    ImageOpacity = 0.5,
    ZIndex = 0,
    Parent = main
})

-- Header
local header = newInst("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundTransparency = 1,
    Parent = main
})

local title = newInst("TextLabel", {
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.new(0, 20, 0, 0),
    Text = "GARSKIRTZ <font color='#00A2FF'>PRO</font>",
    RichText = true,
    TextColor3 = C.text,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Parent = header
})

-- Status Dot & Text
local statusContainer = newInst("Frame", {
    Size = UDim2.new(1, -40, 0, 35),
    Position = UDim2.new(0, 20, 0, 55),
    BackgroundColor3 = C.card,
    Parent = main
})
mkCorner(statusContainer, 8)
mkStroke(statusContainer, C.outline, 1)

local dot = newInst("Frame", {
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(0, 12, 0.5, -4),
    BackgroundColor3 = C.danger,
    Parent = statusContainer
})
mkCorner(dot, 100)

local statusLbl = newInst("TextLabel", {
    Size = UDim2.new(1, -35, 1, 0),
    Position = UDim2.new(0, 30, 0, 0),
    Text = "System Standby",
    TextColor3 = C.muted,
    TextSize = 13,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Parent = statusContainer
})

-- Stats Grid
local statsFrame = newInst("Frame", {
    Size = UDim2.new(1, -40, 0, 80),
    Position = UDim2.new(0, 20, 0, 100),
    BackgroundTransparency = 1,
    Parent = main
})

local function mkStatCard(name, val, pos)
    local card = newInst("Frame", {
        Size = UDim2.new(0.48, 0, 1, 0),
        Position = pos,
        BackgroundColor3 = C.card,
        Parent = statsFrame
    })
    mkCorner(card, 8)
    
    newInst("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        Text = name,
        TextColor3 = C.muted,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Parent = card
    })
    
    local v = newInst("TextLabel", {
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.new(0, 0, 0, 20),
        Text = val,
        TextColor3 = C.text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Parent = card
    })
    return v
end

local balanceVal = mkStatCard("BALANCE", "$0", UDim2.new(0, 0, 0, 0))
local rateVal    = mkStatCard("RATE / HR", "$0", UDim2.new(0.52, 0, 0, 0))

-- Main Button
local actionBtn = newInst("TextButton", {
    Size = UDim2.new(1, -40, 0, 45),
    Position = UDim2.new(0, 20, 1, -65),
    BackgroundColor3 = C.accent,
    Text = "INITIALIZE FARM",
    TextColor3 = Color3.new(1,1,1),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = main
})
mkCorner(actionBtn, 10)

-- Hover Effect
actionBtn.MouseEnter:Connect(function()
    TweenService:Create(actionBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.accent:Lerp(Color3.new(1,1,1), 0.1)}):Play()
end)
actionBtn.MouseLeave:Connect(function()
    TweenService:Create(actionBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.accent}):Play()
end)

-- ── Logic Connectors ─────────────────────────────────────────────────────────
local function updateStatus(active)
    if active then
        dot.BackgroundColor3 = C.success
        actionBtn.BackgroundColor3 = C.danger
        actionBtn.Text = "STOP OPERATIONS"
    else
        dot.BackgroundColor3 = C.danger
        actionBtn.BackgroundColor3 = C.accent
        actionBtn.Text = "INITIALIZE FARM"
    end
end

-- Export ke _G untuk Logic.lua
_G.AF_GUI = {
    statusText = statusLbl,
    btn = actionBtn,
    balanceLbl = balanceVal,
    perHourLbl = rateVal,
    startPulse = function() updateStatus(true) end,
    stopPulse  = function() updateStatus(false) end,
    C = C,
    btnStroke = { Color = Color3.new() } -- Placeholder for logic compatibility
}

-- Draggable Logic (Smooth)
local dragStart, startPos
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:GetFocusedTextBox() == nil then
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Update Session Data
RunService.Heartbeat:Connect(function()
    local ls = player:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Cash") then
        local now = ls.Cash.Value
        balanceVal.Text = "$" .. fmt(now)
        
        local gained = now - _G.AF_moneyStart
        local elapsed = tick() - _G.AF_sessionStart
        if elapsed > 1 then
            rateVal.Text = "$" .. fmt(math.floor(gained / elapsed * 3600))
        end
    end
end)
