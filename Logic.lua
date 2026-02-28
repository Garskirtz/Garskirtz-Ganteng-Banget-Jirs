-- ============================================
--   Garskirtz Ganteng | Logic.lua (SINKRON)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

repeat task.wait(0.5) until _G.AF_GUI
local G = _G.AF_GUI

local WAYPOINTS = {
    Vector3.new(-5900, -15, -4785),
    Vector3.new(-2962, -17, -5481),
    Vector3.new(-3016, -17, -6549),
    Vector3.new(-2906, -17, -5012),
    Vector3.new(-5180, -17, -3967),
    Vector3.new(-5962, -17, -4379),
    Vector3.new(-3887, -17, -5264),
    Vector3.new(-5870, -17, -4741),
}

local autoFarmActive = false

local function isSeated()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    return hum and hum.SeatPart ~= nil
end

local function setStatus(msg, color)
    G.statusText.Text = msg
    G.statusText.TextColor3 = color
    G.statusIcon.BackgroundColor3 = color
end

-- Money Tracker
task.spawn(function()
    while true do
        task.wait(1)
        local ls = player:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild("Cash") then
            local now = ls.Cash.Value
            G.balanceLbl.Text = "$" .. tostring(now)
            
            local gained = now - _G.AF_moneyStart
            local elapsed = tick() - _G.AF_sessionStart
            if elapsed > 5 then
                G.perHourLbl.Text = "$" .. math.floor(gained/elapsed * 3600) .. "/hr"
            end
        end
    end
end)

-- Main Loop
local function startFarming()
    task.spawn(function()
        while autoFarmActive do
            if not isSeated() then
                autoFarmActive = false
                G.stopPulse()
                setStatus("Stopped - No Vehicle", G.C.danger)
                break
            end

            local car = player.Character.Humanoid.SeatPart.Parent
            local root = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart")
            
            if root then
                for _, wp in ipairs(WAYPOINTS) do
                    if not autoFarmActive or not isSeated() then break end
                    setStatus("Farming Active...", G.C.success)
                    
                    while (root.Position - wp).Magnitude > 40 and autoFarmActive do
                        root.AssemblyLinearVelocity = (wp - root.Position).Unit * 650
                        root.CFrame = CFrame.new(root.Position, wp)
                        task.wait()
                    end
                end
            end
            task.wait()
        end
    end)
end

G.btn.MouseButton1Click:Connect(function()
    if not autoFarmActive and not isSeated() then
        setStatus("SIT IN VEHICLE FIRST!", G.C.danger)
        return
    end

    autoFarmActive = not autoFarmActive
    
    if autoFarmActive then
        _G.AF_moneyStart = (player.leaderstats and player.leaderstats.Cash.Value) or 0
        _G.AF_sessionStart = tick()
        G.startPulse()
        startFarming()
    else
        G.stopPulse()
        setStatus("System Standby", G.C.muted)
    end
end)
