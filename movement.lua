-- movement.lua | Modulo de movimento
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local CFG = getgenv().MOVE_CFG or {
    speed_on = false, speed = 16, fly = false, fly_speed = 1.5,
    noclip = false, inf_jump = false,
    safe_mode = true, safe_radius = 100
}
getgenv().MOVE_CFG = CFG

local desejado = { speed_on = false, fly = false, noclip = false }
local bloqueado = false

-- checa se tem player perto
local function checar_perigo()
    if not CFG.safe_mode then return false end
    local c = LP.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not r then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local oc = plr.Character
        local oR = oc and oc:FindFirstChild("HumanoidRootPart")
        if oR then
            if (r.Position - oR.Position).Magnitude <= CFG.safe_radius then
                return true
            end
        end
    end
    return false
end

-- guarda o que o usuario ligou
local function sincronizar()
    if not bloqueado then
        desejado.speed_on = CFG.speed_on
        desejado.fly = CFG.fly
        desejado.noclip = CFG.noclip
    end
end

-- SPEED
RunService.RenderStepped:Connect(function()
    sincronizar()

    local perigo = checar_perigo()
    if perigo and not bloqueado then
        bloqueado = true
    elseif not perigo and bloqueado then
        bloqueado = false
        CFG.speed_on = desejado.speed_on
        CFG.fly = desejado.fly
        CFG.noclip = desejado.noclip
    end

    if bloqueado then
        CFG.speed_on = false
        CFG.fly = false
        CFG.noclip = false
    end

    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h and CFG.speed_on then h.WalkSpeed = CFG.speed end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c = LP.Character
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if not CFG.inf_jump then return end
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- FLY com botoes na tela
local gui = Instance.new("ScreenGui")
gui.Name = "MetropoleFlyCtrl"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 150
gui.Parent = LP:WaitForChild("PlayerGui")

local controles = Instance.new("Frame")
controles.Size = UDim2.new(0, 240, 0, 240)
controles.Position = UDim2.new(0, 20, 0.5, -120)
controles.BackgroundTransparency = 1
controles.Visible = false
controles.Parent = gui

-- aviso modo seguro
local aviso = Instance.new("TextLabel")
aviso.Size = UDim2.new(0, 220, 0, 40)
aviso.Position = UDim2.new(0.5, -110, 0, 100)
aviso.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
aviso.BackgroundTransparency = 0.1
aviso.Text = "MODO SEGURO ATIVO\nPlayer por perto!"
aviso.TextColor3 = Color3.fromRGB(255, 255, 255)
aviso.TextScaled = true
aviso.Font = Enum.Font.GothamBold
aviso.BorderSizePixel = 0
aviso.Visible = false
aviso.Parent = gui
local avc = Instance.new("UICorner"); avc.CornerRadius = UDim.new(0, 8); avc.Parent = aviso

task.spawn(function()
    while aviso.Parent do
        task.wait(0.3)
        aviso.Visible = bloqueado
    end
end)

-- botoes de fly
local function btnFly(txt, x, y, cor)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 55, 0, 55)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    b.BackgroundTransparency = 0.2
    b.Text = txt
    b.TextColor3 = cor
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = controles
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = b
    local s = Instance.new("UIStroke"); s.Color = cor; s.Thickness = 2; s.Parent = b

    local pressed = false
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            pressed = true
            b.BackgroundColor3 = cor
        end
    end)
    b.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            pressed = false
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        end
    end)
    return function() return pressed end
end

local getSubir  = btnFly("+", 92, 0, Color3.fromRGB(80, 255, 120))
local getFrente = btnFly("^", 92, 62, Color3.fromRGB(0, 220, 255))
local getEsq    = btnFly("<", 30, 62, Color3.fromRGB(0, 220, 255))
local getDir    = btnFly(">", 154, 62, Color3.fromRGB(0, 220, 255))
local getDescer = btnFly("-", 92, 124, Color3.fromRGB(255, 120, 80))
local getTras   = btnFly("v", 154, 124, Color3.fromRGB(0, 220, 255))

local bind = "MetropoleFly"
pcall(function() RunService:UnbindFromRenderStep(bind) end)
RunService:BindToRenderStep(bind, 2001, function()
    local c = LP.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not r or not h then return end

    controles.Visible = CFG.fly

    if not CFG.fly then
        if h.PlatformStand then h.PlatformStand = false end
        return
    end

    h.PlatformStand = true

    local look = Camera.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude > 0.01 then flat = flat.Unit else flat = Vector3.new(0,0,-1) end

    local right = Camera.CFrame.RightVector
    local rflat = Vector3.new(right.X, 0, right.Z)
    if rflat.Magnitude > 0.01 then rflat = rflat.Unit else rflat = Vector3.new(1,0,0) end

    local dir = Vector3.new(0, 0, 0)
    if getFrente() then dir = dir + flat end
    if getTras() then dir = dir - flat end
    if getEsq() then dir = dir - rflat end
    if getDir() then dir = dir + rflat end
    if getSubir() then dir = dir + Vector3.new(0,1,0) end
    if getDescer() then dir = dir - Vector3.new(0,1,0) end

    if dir.Magnitude > 0 then dir = dir.Unit end
    r.CFrame = r.CFrame + dir * CFG.fly_speed
end)

print("[MOVEMENT] carregado")
