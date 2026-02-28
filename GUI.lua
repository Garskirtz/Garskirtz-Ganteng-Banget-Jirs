-- ============================================
--   Garskirtz Premium UI | FIX VERSION
-- ============================================

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local player       = Players.LocalPlayer

-- Hapus UI lama jika ada agar tidak tumpang tindih
local oldGui = player.PlayerGui:FindFirstChild("PremiumFarm")
if oldGui then oldGui:Destroy() end

_G.AF_moneyStart   = 0
_G.AF_sessionStart = tick()

-- Responsive Scale
local vp = workspace.CurrentCamera.ViewportSize
local SCALE = (vp.X < 1000) and 1.2 or 1.0
local W, H = math.floor(320 * SCALE), math.floor(260 * SCALE)

local C = {
    bg = Color3.fromRGB(18, 18, 22),
    card = Color3.fromRGB(28, 28, 34),
    accent = Color3.fromRGB(0, 162, 255),
    success = Color3.fromRGB(0, 255, 130),
    danger = Color3.fromRGB(255, 70, 70),
    text = Color3.fromRGB(255, 255, 255),
    muted = Color3.fromRGB(140, 140, 155),
    outline = Color3.fromRGB(45, 45, 55),
}

local function newInst(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k] = v end
    return o
end

-- ROOT
local root = newInst("ScreenGui", { Name = "PremiumFarm", Parent = player.PlayerGui, IgnoreGuiInset = true })

-- MAIN FRAME (Tanpa DimOverlay bermasalah)
local main = newInst("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, W, 0, H),
    Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Parent = root
})
newInst("UICorner", { CornerRadius = UDim.new(0, 12), Parent = main })
newInst("UIStroke", { Color = C.outline, Thickness = 1.5, Parent = main })

-- HEADER
local title = newInst("TextLabel", {
    Size = UDim2.new(1, -40, 0, 50),
    Position = UDim2.new(0, 20, 0, 0),
    Text = "GARSKIRTZ <font color='#00A2FF'>PRO</font>",
    RichText = true,
    TextColor3 = C.text,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Parent = main
})

-- STATUS
local statusCard = newInst("Frame", {
    Size = UDim2.new(1, -40, 0, 35),
    Position = UDim2.new(0, 20, 0, 50),
    BackgroundColor3 = C.card,
    Parent = main
})
newInst("UICorner", { CornerRadius = UDim.new(0, 8), Parent = statusCard })

local dot = newInst("Frame", {
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(0, 12, 0.5, -4),
    BackgroundColor3 = C.danger,
    Parent = statusCard
})
newInst("UICorner", { CornerRadius = UDim.new(0, 100), Parent = dot })

local statusLbl = newInst("TextLabel", {
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.new(0, 30, 0, 0),
    Text = "Ready to Farm",
    TextColor3 = C.muted,
    TextSize = 13,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Parent = statusCard
})

-- MONEY INFO
local balanceLbl = newInst("TextLabel", {
    Size = UDim2.new(0.5, -25, 0, 60),
    Position = UDim2.new(0, 20, 0, 95),
    Text = "$0",
    TextColor3 = C.text,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Parent = main
})

local perHourLbl = newInst("TextLabel", {
    Size = UDim2.new(0.5, -25, 0, 60),
    Position = UDim2.new(0.5, 5, 0, 95),
    Text = "$0/hr",
    TextColor3 = C.success,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1,
    Parent = main
})

-- ACTION BUTTON
local btn = newInst("TextButton", {
    Size = UDim2.new(1, -40, 0, 45),
    Position = UDim2.new(0, 20, 1, -65),
    BackgroundColor3 = C.accent,
    Text = "START AUTOFARM",
    TextColor3 = Color3.new(1,1,1),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = main
})
newInst("UICorner", { CornerRadius = UDim.new(0, 10), Parent = btn })
local btnStroke = newInst("UIStroke", { Color = C.accent, Thickness = 2, Parent = btn })

-- EXPORT KE LOGIC
_G.AF_GUI = {
    statusText = statusLbl,
    statusIcon = dot, -- Di Logic ini dipakai untuk warna icon
    btn = btn,
    btnStroke = btnStroke,
    balanceLbl = balanceLbl,
    perHourLbl = perHourLbl,
    startPulse = function() 
        dot.BackgroundColor3 = C.success
        btn.BackgroundColor3 = C.danger
        btn.Text = "STOP AUTOFARM"
    end,
    stopPulse = function() 
        dot.BackgroundColor3 = C.danger
        btn.BackgroundColor3 = C.accent
        btn.Text = "START AUTOFARM"
    end,
    C = C
}

-- Dragging logic
local dStart, sPos
btn.Parent.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dStart = i.Position sPos = main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dStart and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dStart
        main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
    end
end)
