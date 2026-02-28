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

-- Sistem Noclip agar tidak nyangkut bangunan
local function setNoclip(state)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if player.Character then
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
                local seat = player.Character.Humanoid.SeatPart
                if seat and seat.Parent then
                    for _, v in pairs(seat.Parent:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end
        end)
    end
end

local function startFarming()
    setNoclip(true)
    task.spawn(function()
        while autoFarmActive do
            if not isSeated() then break end
            local car = player.Character.Humanoid.SeatPart.Parent
            local root = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart")
            
            for _, wp in ipairs(WAYPOINTS) do
                if not autoFarmActive or not isSeated() then break end
                G.statusText.Text = "Driving..."
                
                -- Gerakan Halus
                while (root.Position - wp).Magnitude > 35 and autoFarmActive do
                    root.AssemblyLinearVelocity = (wp - root.Position).Unit * 600
                    root.CFrame = CFrame.new(root.Position, wp)
                    task.wait()
                end
            end
            task.wait()
        end
        setNoclip(false)
        G.stopPulse()
        G.statusText.Text = "Stopped"
    end)
end

G.btn.MouseButton1Click:Connect(function()
    if not autoFarmActive then
        if not isSeated() then G.statusText.Text = "SIT IN CAR!"; return end
        autoFarmActive = true
        G.startPulse()
        startFarming()
    else
        autoFarmActive = false
    end
end)

-- Money Tracker
task.spawn(function()
    while true do
        local ls = player:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild("Cash") then
            G.balanceLbl.Text = "$" .. ls.Cash.Value
            local gained = ls.Cash.Value - _G.AF_moneyStart
            local elapsed = tick() - _G.AF_sessionStart
            if elapsed > 2 then G.perHourLbl.Text = "$" .. math.floor(gained/elapsed * 3600) .. "/hr" end
        end
        task.wait(1)
    end
end)
