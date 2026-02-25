-- ============================================
--   Nathan's Autofarm | Logic.lua
--   Optimized: task.* API, clean connections
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local player     = Players.LocalPlayer

-- Tunggu GUI siap
repeat task.wait(0.1) until _G.AF_GUI
local G = _G.AF_GUI   -- shorthand

local statusText = G.statusText
local statusIcon = G.statusIcon
local btn        = G.btn
local btnStroke  = G.btnStroke
local C          = G.C

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
local autoFarmActive         = false
local carStabilizeConn       = nil
local noclipConn             = nil

-- ════════════════════════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════════════════════════
local function setStatus(msg, color)
    statusText.Text      = msg
    statusText.TextColor3 = color or C.muted
    statusIcon.TextColor3 = color or C.muted
end

local function isSeated()
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    return hum and hum.SeatPart ~= nil
end

local function stopConnections()
    if carStabilizeConn then carStabilizeConn:Disconnect(); carStabilizeConn = nil end
    if noclipConn       then noclipConn:Disconnect();       noclipConn = nil end
end

-- ── Noclip ───────────────────────────────────────────────────────────────────
local function enableNoclip(car)
    stopConnections()  -- clear old first
    noclipConn = RunService.Stepped:Connect(function()
        if not autoFarmActive or not car or not car.Parent then
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            return
        end
        for _, p in car:GetDescendants() do
            if p:IsA("BasePart") then
                p.CanCollide = false
                p.CustomPhysicalProperties = PhysicalProperties.new(0.7,0,0,100,1)
            end
        end
    end)
end

-- ── Stabilize ────────────────────────────────────────────────────────────────
local function stabilizeCar(car)
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
        local pos  = car.PrimaryPart.Position
        if (target - pos).Magnitude < 60 then break end
        local dir  = (target - pos).Unit
        car.PrimaryPart.AssemblyLinearVelocity = dir * speed
        car.PrimaryPart.CFrame = CFrame.new(pos, pos + Vector3.new(dir.X, 0, dir.Z))
        task.wait()
    end
end

-- ════════════════════════════════════════════════════════════════════════════
--  SAFETY MONITOR  (1 connection, no extra spawns)
-- ════════════════════════════════════════════════════════════════════════════
local safetyElapsed = 0
RunService.Heartbeat:Connect(function(dt)
    safetyElapsed += dt
    if safetyElapsed < 1 then return end
    safetyElapsed = 0

    if autoFarmActive and not isSeated() then
        autoFarmActive = false
        stopConnections()
        btn.Text             = "Start AutoFarm"
        btn.BackgroundColor3 = C.accent
        btn.TextColor3       = C.bg
        btnStroke.Color      = Color3.fromRGB(60,120,180)
        setStatus("Stopped — left vehicle", C.danger)
        G.stopPulse()
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  CLEANUP LOOP  (1 task, bukan spawn baru tiap toggle)
-- ════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(2)
        if autoFarmActive then
            for _, v in workspace:GetChildren() do
                if (v.ClassName == "Model" and v:FindFirstChild("Container"))
                or v.Name == "PortCraneOversized" then
                    v:Destroy()
                end
            end
            -- hapus Buildings kalau ada
            local wb = workspace:FindFirstChild("Workspace")
            if wb then
                local b = wb:FindFirstChild("Buildings")
                if b then b:Destroy() end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  MAIN TOGGLE
-- ════════════════════════════════════════════════════════════════════════════
btn.MouseButton1Click:Connect(function()
    -- cek duduk saat mau mulai
    if not autoFarmActive and not isSeated() then
        setStatus("Sit in a vehicle first!", C.danger)
        return
    end

    autoFarmActive = not autoFarmActive
    _G.AF_sessionStart = tick()
    _G.AF_moneyStart   = (player:FindFirstChild("leaderstats") and
                          player.leaderstats:FindFirstChild("Cash") and
                          player.leaderstats.Cash.Value) or 0

    if autoFarmActive then
        -- UI → aktif
        btn.Text             = "Stop AutoFarm"
        btn.BackgroundColor3 = C.danger
        btn.TextColor3       = Color3.fromRGB(255,255,255)
        btnStroke.Color      = Color3.fromRGB(200,60,60)
        setStatus("Farming  ·  speed 650  ·  noclip ON", C.green)
        G.startPulse()

        -- Farm coroutine
        task.spawn(function()
            while autoFarmActive do
                if not isSeated() then break end

                local hum = player.Character.Humanoid
                local car = hum.SeatPart and hum.SeatPart.Parent
                if not car then break end

                -- set primary part
                car.PrimaryPart = car:FindFirstChild("Body") and
                                  car.Body:FindFirstChild("#Weight") or car.PrimaryPart

                enableNoclip(car)
                stabilizeCar(car)

                -- teleport ke waypoint 1
                car.PrimaryPart.Anchored = true
                car:PivotTo(CFrame.new(WAYPOINTS[1]))
                task.wait(0.1)
                car.PrimaryPart.Anchored = false
                car.PrimaryPart.AssemblyLinearVelocity = Vector3.zero

                -- traverse waypoints
                for i = 2, #WAYPOINTS do
                    if not autoFarmActive or not isSeated() then break end
                    setStatus("Waypoint " .. i .. "/" .. #WAYPOINTS .. "  ·  noclip ON", C.green)
                    navigate(car, WAYPOINTS[i], 650)
                end
            end

            stopConnections()
        end)

    else
        -- UI → berhenti
        btn.Text             = "Start AutoFarm"
        btn.BackgroundColor3 = C.accent
        btn.TextColor3       = C.bg
        btnStroke.Color      = Color3.fromRGB(60,120,180)
        setStatus("Stopped", C.muted)
        G.stopPulse()
        stopConnections()
    end
end)
