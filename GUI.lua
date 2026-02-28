-- ============================================
--   Garskirtz Ganteng | GUI.lua (FIXED)
-- ============================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Hapus UI lama agar tidak menumpuk
local old = player.PlayerGui:FindFirstChild("GarskirtzPremium")
if old then old:Destroy() end

_G.AF_moneyStart = 0
_G.AF_sessionStart = tick()

local C = {
    bg = Color3.fromRGB(15, 15, 18),
    card = Color3.fromRGB(24, 24, 30),
    accent = Color3.fromRGB(0, 162, 255),
    green = Color3.fromRGB(60, 170, 110),
    red = Color3.fromRGB(200, 50, 50),
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
local stroke = Instance.new("UIStroke", main)
stroke.Color = C.outline
stroke.Thickness = 1.5

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 50); title.Position = UDim2.new(0, 20, 0, 0)
title.Text = "GARSKIRTZ <font color='#00A2FF'>PRO</font>"; title.RichText = true
title.TextColor3 = C.text; title.TextSize = 18; title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1; title.TextXAlignment = Enum.TextXAlignment.Left

-- Status
local statusCard = Instance.new("Frame", main)
statusCard.Size = UDim2.new(1, -40, 0, 35); statusCard.Position = UDim2.new(0, 20, 0, 50)
statusCard.BackgroundColor3 = C.card
Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 8)

local statusIcon = Instance.new("TextLabel", statusCard)
statusIcon.Size = UDim2.new(0, 25, 1, 0); statusIcon.Position = UDim2.new(0, 10, 0, 0)
statusIcon.Text = "●"; statusIcon.TextColor3 = C.red; statusIcon.TextSize = 14
statusIcon.BackgroundTransparency = 1

local statusText = Instance.new("TextLabel", statusCard)
statusText.Size = UDim2.new(1, -45, 1, 0); statusText.Position = UDim2.new(0, 35, 0, 0)
statusText.Text = "Ready"; statusText.TextColor3 = C.muted; statusText.TextSize = 13
statusText.Font = Enum.Font.GothamMedium; statusText.BackgroundTransparency = 1
statusText.TextXAlignment = Enum.TextXAlignment.Left

-- Stats
local bal = Instance.new("TextLabel", main)
bal.Size = UDim2.new(0.5, -20, 0, 60); bal.Position = UDim2.new(0, 20, 0, 100)
bal.Text = "$0"; bal.TextColor3 = C.text; bal.TextSize = 22; bal.Font = Enum.Font.GothamBold
bal.BackgroundTransparency = 1; bal.TextXAlignment = Enum.TextXAlignment.Left

local rate = Instance.new("TextLabel", main)
rate.Size = UDim2.new(0.5, -20, 0, 60); rate.Position = UDim2.new(0.5, 0, 0, 100)
rate.Text = "$0/hr"; rate.TextColor3 = C.green; rate.TextSize = 18; rate.Font = Enum.Font.GothamBold
rate.BackgroundTransparency = 1; rate.TextXAlignment = Enum.TextXAlignment.Right

-- Button
local btn = Instance.new("TextButton", main)
btn.Size = UDim2.new(1, -40, 0, 45); btn.Position = UDim2.new(0, 20, 1, -65)
btn.BackgroundColor3 = C.green; btn.Text = "Start AutoFarm"; btn.TextColor3 = Color3.new(0,0,0)
btn.Font = Enum.Font.GothamBold
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
local btnStroke = Instance.new("UIStroke", btn); btnStroke.Color = Color3.fromRGB(40,130,80); btnStroke.Thickness = 2

-- Export ke _G (Wajib ada startPulse/stopPulse agar Logic.lua tidak error)
_G.AF_GUI = {
    statusText = statusText,
    statusIcon = statusIcon,
    btn = btn,
    btnStroke = btnStroke,
    balanceLbl = bal,
    perHourLbl = rate,
    C = C,
    startPulse = function() statusIcon.TextColor3 = C.green end,
    stopPulse = function() statusIcon.TextColor3 = C.red end
}

-- Draggable logic
local dragging, dragStart, startPos
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = main.Position end end)
UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Money Tracker Loop
task.spawn(function()
    while true do
        local ls = player:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild("Cash") then
            local val = ls.Cash.Value
            bal.Text = "$" .. tostring(val)
            local gained = val - _G.AF_moneyStart
            local elapsed = tick() - _G.AF_sessionStart
            if elapsed > 5 then rate.Text = "$" .. math.floor(gained/elapsed * 3600) .. "/hr" end
        end
        task.wait(1)
    end
end)
