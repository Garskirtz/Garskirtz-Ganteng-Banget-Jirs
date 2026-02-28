-- ============================================
--   Garskirtz Ganteng | Logic.lua
--   v3: bug fixes, clean state management
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local player     = Players.LocalPlayer

-- Tunggu GUI siap
repeat task.wait(0.1) until _G.AF_GUI
local G = _G.AF_GUI

local statusText = G.statusText
local statusIcon = G.statusIcon
local btn        = G.btn
local btnStroke  = G.btnStroke
local C          = G.C

-- ── Warna tombol (pakai warna yang ada di C) ─────────────────────────────────
local COL_STOP   = Color3.fromRGB(60,  170, 110)  -- hijau = start
local COL_START  = Color3.fromRGB(200, 50,  50)   -- merah = stop

-- ════════════════════════════════════════════════════════════════════════════
--  WAYPOINTS
-- ════════════════════════════════════════════════════════════════════════════
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

-- ════════════════════════════════════════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════════════════════════════════════════
local autoFarmActive   = false
local carStabilizeConn = nil
local noclipConn       = nil

-- ════════════════════════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════════════════════════
local function setStatus(msg, color)
    statusText.Text       = msg
    statusText.TextColor3 = color or C.muted
    statusIcon.TextColor3 = color or C.muted
end

local function isSeated()
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    return hum ~= nil and hum.SeatPart ~= nil
end

local function stopConnections()
    if carStabilizeConn then
        carStabilizeConn:Disconnect()
        carStabilizeConn = nil
    end
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

local function setUIStop()
    btn.Text             = "Start AutoFarm"
    btn.BackgroundColor3 = COL_STOP
    btn.TextColor3       = Color3.fromRGB(10,10,12)
    btnStroke.Color      = Color3.fromRGB(40,130,80)
    G.stopPulse()
end

local function setUIStart()
    btn.Text             = "Stop AutoFarm"
    btn.BackgroundColor3 = COL_START
    btn.TextColor3       = Color3.fromRGB(255,255,255)
    btnStroke.Color      = Color3.fromRGB(160,30,30)
    G.startPulse()
end

-- ── Noclip ───────────────────────────────────────────────────────────────────
local function enableNoclip(car)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    noclipConn = RunService.Stepped:Connect(function()
        if not autoFarmActive or not car or not car.Parent then
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            return
        end
        for _, p in ipairs(car:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
                p.CustomPhysicalProperties = PhysicalProperties.new(0.7,0,0,100,1)
            end
        end
    end)
end

-- ── Stabilize ────────────────────────────────────────────────────────────────
local function stabilizeCar(car)
    if carStabilizeConn then carStabilizeConn:Disconnect(); carStabilizeConn = nil end
    carStabilizeConn = RunService.Heartbeat:Connect(function()
        if not autoFarmActive or not car or not car.Parent or not car.PrimaryPart then
            if carStabilizeConn then carStabilizeConn:Disconnect(); carStabilizeConn = nil end
            return
        end
        local pp  = car.PrimaryPart
        local pos = pp.CFrame.Position
        local lv  = pp.CFrame.LookVector
        pp.CFrame = pp.CFrame:Lerp(
            CFrame.new(pos, pos + Vector3.new(lv.X, 0, lv.Z)), 0.2
        )
        pp.AssemblyAngularVelocity = Vector3.new(0, pp.AssemblyAngularVelocity.Y * 0.6, 0)
    end)
end

-- ── Navigate ─────────────────────────────────────────────────────────────────
local function navigate(car, target, speed)
    while autoFarmActive and isSeated() and car and car.Parent and car.PrimaryPart do
        local pos = car.PrimaryPart.Position
        if (target - pos).Magnitude < 60 then break end
        local dir = (target - pos).Unit
        car.PrimaryPart.AssemblyLinearVelocity = dir * speed
        car.PrimaryPart.CFrame = CFrame.new(pos, pos + Vector3.new(dir.X, 0, dir.Z))
        task.wait()
    end
end

-- ════════════════════════════════════════════════════════════════════════════
--  SAFETY MONITOR
-- ════════════════════════════════════════════════════════════════════════════
local safetyEl = 0
RunService.Heartbeat:Connect(function(dt)
    safetyEl += dt
    if safetyEl < 1 then return end
    safetyEl = 0
    if autoFarmActive and not isSeated() then
        autoFarmActive = false
        stopConnections()
        setUIStop()
        setStatus("Stopped — left vehicle", C.red)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  CLEANUP LOOP
-- ════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(2)
        if autoFarmActive then
            for _, v in ipairs(workspace:GetChildren()) do
                if (v.ClassName == "Model" and v:FindFirstChild("Container"))
                or v.Name == "PortCraneOversized" then
                    v:Destroy()
                end
            end
            -- FIX: workspace.Buildings langsung, bukan workspace.Workspace.Buildings
            local b = workspace:FindFirstChild("Buildings")
            if b then b:Destroy() end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  MAIN TOGGLE
-- ════════════════════════════════════════════════════════════════════════════
btn.MouseButton1Click:Connect(function()
    if not autoFarmActive and not isSeated() then
        setStatus("Sit in a vehicle first!", C.red)
        return
    end

    autoFarmActive = not autoFarmActive

    -- reset tracker tiap toggle
    _G.AF_sessionStart = tick()
    local ls = player:FindFirstChild("leaderstats")
    _G.AF_moneyStart = (ls and ls:FindFirstChild("Cash") and ls.Cash.Value) or 0

    if autoFarmActive then
        setUIStart()
        setStatus("Farming  ·  speed 650  ·  noclip ON", C.green)

        task.spawn(function()
            while autoFarmActive do
                if not isSeated() then break end

                local hum = player.Character and player.Character:FindFirstChild("Humanoid")
                if not hum or not hum.SeatPart then break end

                local car = hum.SeatPart.Parent
                if not car then break end

                -- FIX: cari PrimaryPart dengan aman
                local body = car:FindFirstChild("Body")
                local weight = body and body:FindFirstChild("#Weight")
                if weight then
                    car.PrimaryPart = weight
                elseif not car.PrimaryPart then
                    -- fallback: pakai BasePart pertama
                    for _, p in ipairs(car:GetDescendants()) do
                        if p:IsA("BasePart") then
                            car.PrimaryPart = p
                            break
                        end
                    end
                end

                if not car.PrimaryPart then break end

                enableNoclip(car)
                stabilizeCar(car)

                -- teleport ke waypoint 1
                car.PrimaryPart.Anchored = true
                car:PivotTo(CFrame.new(WAYPOINTS[1]))
                task.wait(0.15)
                car.PrimaryPart.Anchored = false
                car.PrimaryPart.AssemblyLinearVelocity = Vector3.zero

                -- traverse waypoints
                for i = 2, #WAYPOINTS do
                    if not autoFarmActive or not isSeated() then break end
                    setStatus("Farming  ·  noclip ON", C.green)
                    navigate(car, WAYPOINTS[i], 650)
                end
            end

            stopConnections()
        end)

    else
        setUIStop()
        setStatus("Stopped", C.muted)
        stopConnections()
    end
end)
