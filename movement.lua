-- movement.lua | Modulo de movimento com fly estilo MoveDirection
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace
local LP = Players.LocalPlayer

local CFG = getgenv().MOVE_CFG or {
    speed_on = false, speed = 16, fly = false, fly_speed = 60,
    noclip = false, inf_jump = false,
    safe_mode = true, safe_radius = 100
}
getgenv().MOVE_CFG = CFG

local flyBV, flyConn
local desejado = { speed_on = false, fly = false, noclip = false }
local bloqueado = false

-- ============ MODO SEGURO ============
local function checar_perigo()
    if not CFG.safe_mode then return false end
    local c = LP.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local oc = plr.Character
        local oR = oc and oc:FindFirstChild("HumanoidRootPart")
        if oR and (r.Position - oR.Position).Magnitude <= CFG.safe_radius then
            return true
        end
    end
    return false
end

-- ============ FLY (estilo Claude) ============
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand = false end
end

local function startFly()
    stopFly()
    local c = LP.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not r or not h then return end

    h.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = r

    flyConn = RunService.RenderStepped:Connect(function()
        local cc = LP.Character
        local hh = cc and cc:FindFirstChildOfClass("Humanoid")
        local cam = Workspace.CurrentCamera
        if not (hh and cam and flyBV and flyBV.Parent) then return end

        local move = hh.MoveDirection
        if move.Magnitude > 0 then
            local look = cam.CFrame.LookVector
            local flat = Vector3.new(look.X, 0, look.Z)
            local forward = 0
            if flat.Magnitude > 0 then
                forward = move:Dot(flat.Unit)
            end
            flyBV.Velocity = move * CFG.fly_speed + Vector3.new(0, look.Y * CFG.fly_speed * forward, 0)
        else
            flyBV.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

-- ============ SPEED + MODO SEGURO ============
RunService.RenderStepped:Connect(function()
    if not bloqueado then
        desejado.speed_on = CFG.speed_on
        desejado.fly = CFG.fly
        desejado.noclip = CFG.noclip
    end

    local perigo = checar_perigo()
    if perigo and not bloqueado then
        bloqueado = true
    elseif not perigo and bloqueado then
        bloqueado = false
        CFG.speed_on = desejado.speed_on
        CFG.fly = desejado.fly
        CFG.noclip = desejado.noclip
        if CFG.fly then startFly() else stopFly() end
    end

    if bloqueado then
        CFG.speed_on = false
        if CFG.fly then
            CFG.fly = false
            stopFly()
        end
        CFG.noclip = false
    end

    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h and CFG.speed_on then h.WalkSpeed = CFG.speed end
end)

-- ============ FLY toggle via config ============
local flyAntes = false
RunService.Heartbeat:Connect(function()
    if CFG.fly and not flyAntes then
        startFly()
    elseif not CFG.fly and flyAntes then
        stopFly()
    end
    flyAntes = CFG.fly
end)

-- ============ NOCLIP ============
RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c = LP.Character
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ============ INFINITE JUMP ============
UserInputService.JumpRequest:Connect(function()
    if not CFG.inf_jump then return end
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ============ RESPAWN ============
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if CFG.fly then startFly() end
end)

print("[MOVEMENT] carregado")
