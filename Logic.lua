-- ============================================
--   Garskirtz Ganteng | Logic.lua (REVISED)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

repeat task.wait(0.5) until _G.AF_GUI
local G = _G.AF_GUI

local WAYPOINTS = {
    Vector3.new(-5900, -15, -4785), Vector3.new(-2962, -17, -5481),
    Vector3.new(-3016, -17, -6549), Vector3.new(-2906, -17, -5012),
    Vector3.new(-5180, -17, -3967), Vector3.new(-5962, -17, -4379),
    Vector3.new(-3887, -17, -5264), Vector3.new(-5870, -17, -4741),
}

local autoFarmActive = false
local noclipConn = nil

local function isSeated()
    return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.SeatPart ~= nil
end

local function setUIStart()
    G.btn.Text = "Stop AutoFarm"
    G.btn.BackgroundColor3 = G.C.red
    G.btn.TextColor3 = Color3.new(1,1,1)
    G.btnStroke.Color = Color3.fromRGB(160,30,30)
    if G.startPulse then G.startPulse() end
end

local function setUIStop()
    G.btn.Text = "Start AutoFarm"
    G.btn.BackgroundColor3 = G.C.green
    G.btn.TextColor3 = Color3.new(0,0,0)
    G.btnStroke.Color = Color3.fromRGB(40,130,80)
    if G.stopPulse then G.stopPulse() end
end

-- Noclip logic
local function setNoclip(state)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if player.Character then
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    end
end

-- Navigasi
local function navigate(car, target)
    local root = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart")
    while autoFarmActive and isSeated() and root do
        local dist = (target - root.Position).Magnitude
        if dist < 40 then break end
        root.AssemblyLinearVelocity = (target - root.Position).Unit * 650
        root.CFrame = CFrame.new(root.Position, target)
        task.wait()
    end
end

G.btn.MouseButton1Click:Connect(function()
    if not autoFarmActive then
        if not isSeated() then G.statusText.Text = "SIT IN VEHICLE!"; return end
        autoFarmActive = true
        _G.AF_moneyStart = (player.leaderstats and player.leaderstats.Cash.Value) or 0
        _G.AF_sessionStart = tick()
        setUIStart()
        
        task.spawn(function()
            setNoclip(true)
            while autoFarmActive and isSeated() do
                local car = player.Character.Humanoid.SeatPart.Parent
                for _, wp in ipairs(WAYPOINTS) do
                    if not autoFarmActive or not isSeated() then break end
                    G.statusText.Text = "Farming..."
                    navigate(car, wp)
                end
            end
            autoFarmActive = false
            setNoclip(false)
            setUIStop()
            G.statusText.Text = "Stopped"
        end)
    else
        autoFarmActive = false
    end
end)
