local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Anti-Duplikat
local old = player.PlayerGui:FindFirstChild("GarskirtzPremium")
if old then old:Destroy() end

_G.AF_moneyStart = 0
_G.AF_sessionStart = tick()

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

local root = Instance.new("ScreenGui", player.PlayerGui)
root.Name = "GarskirtzPremium"
root.IgnoreGuiInset = true

local main = Instance.new("Frame", root)
main.Size = UDim2.new(0, 320, 0, 260)
main.Position = UDim2.new(0.5, -160, 0.5, -130)
main.BackgroundColor3 = C.bg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", main).Color = C.outline

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 50); title.Position = UDim2.new(0, 20, 0, 0)
title.Text = "GARSKIRTZ <font color='#00A2FF'>PRO</font>"; title.RichText = true
title.TextColor3 = C.text; title.TextSize = 18; title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1; title.TextXAlignment = Enum.TextXAlignment.Left

local statusCard = Instance.new("Frame", main)
statusCard.Size = UDim2.new(1, -40, 0, 35); statusCard.Position = UDim2.new(0, 20, 0, 50)
statusCard.BackgroundColor3 = C.card
Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 8)

local dot = Instance.new("Frame", statusCard)
dot.Size = UDim2.new(0, 8, 0, 8); dot.Position = UDim2.new(0, 12, 0.5, -4)
dot.BackgroundColor3 = C.danger
Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 100)

local statusLbl = Instance.new("TextLabel", statusCard)
statusLbl.Size = UDim2.new(1, -40, 1, 0); statusLbl.Position = UDim2.new(0, 30, 0, 0)
statusLbl.Text = "Ready"; statusLbl.TextColor3 = C.muted
statusLbl.TextSize = 13; statusLbl.Font = Enum.Font.GothamMedium; statusLbl.BackgroundTransparency = 1
statusLbl.TextXAlignment = Enum.TextXAlignment.Left

local bal = Instance.new("TextLabel", main)
bal.Size = UDim2.new(0.5, -20, 0, 60); bal.Position = UDim2.new(0, 20, 0, 95)
bal.Text = "$0"; bal.TextColor3 = C.text; bal.TextSize = 24; bal.Font = Enum.Font.GothamBold
bal.BackgroundTransparency = 1; bal.TextXAlignment = Enum.TextXAlignment.Left

local rate = Instance.new("TextLabel", main)
rate.Size = UDim2.new(0.5, -20, 0, 60); rate.Position = UDim2.new(0.5, 0, 0, 95)
rate.Text = "$0/hr"; rate.TextColor3 = C.success; rate.TextSize = 20; rate.Font = Enum.Font.GothamBold
rate.BackgroundTransparency = 1; rate.TextXAlignment = Enum.TextXAlignment.Right

local btn = Instance.new("TextButton", main)
btn.Size = UDim2.new(1, -40, 0, 45); btn.Position = UDim2.new(0, 20, 1, -65)
btn.BackgroundColor3 = C.accent; btn.Text = "START AUTOFARM"; btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold; btn.Parent = main
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
local btnStroke = Instance.new("UIStroke", btn); btnStroke.Color = C.accent; btnStroke.Thickness = 2

-- Dragging
local dragging, dragStart, startPos
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = main.Position end end)
UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

_G.AF_GUI = {
    statusText = statusLbl, statusIcon = dot, btn = btn, btnStroke = btnStroke,
    balanceLbl = bal, perHourLbl = rate, C = C,
    startPulse = function() dot.BackgroundColor3 = C.success; btn.BackgroundColor3 = C.danger; btn.Text = "STOP" end,
    stopPulse = function() dot.BackgroundColor3 = C.danger; btn.BackgroundColor3 = C.accent; btn.Text = "START" end
}
