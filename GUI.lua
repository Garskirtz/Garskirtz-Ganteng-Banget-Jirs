-- ============================================
--   Garskirtz Premium UI | REVISED STABLE
-- ============================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Clean up old UI
local old = player.PlayerGui:FindFirstChild("GarskirtzPremium")
if old then old:Destroy() end

-- Shared State
_G.AF_moneyStart = 0
_G.AF_sessionStart = tick()

-- UI Theme
local C = {
    bg = Color3.fromRGB(15, 15, 18),
    card = Color3.fromRGB(24, 24, 30),
    accent = Color3.fromRGB(0, 162, 255),
    success = Color3.fromRGB(0, 255, 130),
    danger = Color3.fromRGB(255, 70, 70),
    text = Color3.fromRGB(255, 255, 255),
    muted = Color3.fromRGB(140, 140, 155),
    outline = Color3.fromRGB(45, 45, 55),
}

local root = Instance.new("ScreenGui")
root.Name = "GarskirtzPremium"
root.IgnoreGuiInset = true
root.Parent = player.PlayerGui

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 320, 0, 260)
main.Position = UDim2.new(0.5, -160, 0.5, -130)
main.BackgroundColor3 = C.bg
main.Parent = root

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = C.outline
stroke.Thickness = 1.5
stroke.Parent = main

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 50)
title.Position = UDim2.new(0, 20, 0, 0)
title.Text = "GARSKIRTZ <font color='#00A2FF'>PRO</font>"
title.RichText = true
title.TextColor3 = C.text
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

-- Status Dot & Text
local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, -40, 0, 35)
statusCard.Position = UDim2.new(0, 20, 0, 50)
statusCard.BackgroundColor3 = C.card
statusCard.Parent = main
Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 8)

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(0, 12, 0.5, -4)
dot.BackgroundColor3 = C.danger
dot.Parent = statusCard
Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 100)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -40, 1, 0)
statusLbl.Position = UDim2.new(0, 30, 0, 0)
statusLbl.Text = "System Standby"
statusLbl.TextColor3 = C.muted
statusLbl.TextSize = 13
statusLbl.Font = Enum.Font.GothamMedium
statusLbl.BackgroundTransparency = 1
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Parent = statusCard

-- Balance & Rate
local bal = Instance.new("TextLabel")
bal.Size = UDim2.new(0.5, -20, 0, 60)
bal.Position = UDim2.new(0, 20, 0, 95)
bal.Text = "$0"
bal.TextColor3 = C.text
bal.TextSize = 24
bal.Font = Enum.Font.GothamBold
bal.BackgroundTransparency = 1
bal.TextXAlignment = Enum.TextXAlignment.Left
bal.Parent = main

local rate = Instance.new("TextLabel")
rate.Size = UDim2.new(0.5, -20, 0, 60)
rate.Position = UDim2.new(0.5, 0, 0, 95)
rate.Text = "$0/hr"
rate.TextColor3 = C.success
rate.TextSize = 20
rate.Font = Enum.Font.GothamBold
rate.BackgroundTransparency = 1
rate.TextXAlignment = Enum.TextXAlignment.Right
rate.Parent = main

-- Button
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -40, 0, 45)
btn.Position = UDim2.new(0, 20, 1, -65)
btn.BackgroundColor3 = C.accent
btn.Text = "START AUTOFARM"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.Parent = main
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
local btnStroke = Instance.new("UIStroke", btn)
btnStroke.Color = C.accent
btnStroke.Thickness = 2

-- Draggable logic
local dragging, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Export to _G
_G.AF_GUI = {
    statusText = statusLbl,
    statusIcon = dot,
    btn = btn,
    btnStroke = btnStroke,
    balanceLbl = bal,
    perHourLbl = rate,
    C = C,
    startPulse = function()
        dot.BackgroundColor3 = C.success
        btn.BackgroundColor3 = C.danger
        btn.Text = "STOP AUTOFARM"
    end,
    stopPulse = function()
        dot.BackgroundColor3 = C.danger
        btn.BackgroundColor3 = C.accent
        btn.Text = "START AUTOFARM"
    end
}
