local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = workspace
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

local CFG = getgenv().TRIGGER_CFG or {
    ativo=false, hitbox=false, hitbox_size=8,
    raio_graus=3, delay=0.08, team_check=true, amigos={}
}
getgenv().TRIGGER_CFG = CFG

local ultimo = 0

local function pegarParte(char)
    for _, n in ipairs({"Head","UpperTorso","Torso","HumanoidRootPart"}) do
        local p = char:FindFirstChild(n)
        if p then return p end
    end
end

local function aliado(plr)
    if CFG.amigos[plr.Name] then return true end
    if not CFG.team_check then return false end
    if not LP.Team or not plr.Team then return false end
    return LP.Team == plr.Team
end

local function acharProximo()
    local lookVec = Camera.CFrame.LookVector
    local camPos = Camera.CFrame.Position
    local melhor, melhor_ang = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP or aliado(plr) then continue end
        local c = plr.Character
        if not c then continue end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then continue end
        local p = pegarParte(c)
        if not p then continue end
        local dir = (p.Position - camPos).Unit
        local dot = lookVec:Dot(dir)
        if dot > 0 then
            local ang = math.deg(math.acos(math.clamp(dot, -1, 1)))
            if ang <= CFG.raio_graus and ang < melhor_ang then
                melhor_ang = ang
                melhor = {parte = p, pos = p.Position, nome = plr.Name}
            end
        end
    end
    return melhor
end

local function clicar()
    local vp = Camera.ViewportSize
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:Button1Down(Vector2.new(vp.X/2, vp.Y/2))
        task.wait(0.02)
        vu:Button1Up(Vector2.new(vp.X/2, vp.Y/2))
    end)
end

local orig_hb = {}

local function aplicarHitbox()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local c = plr.Character
        if not c then continue end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                if not orig_hb[p] then orig_hb[p] = p.Size end
                p.Size = Vector3.new(CFG.hitbox_size, CFG.hitbox_size, CFG.hitbox_size)
            end
        end
    end
end

local function limparHitbox()
    for part, size in pairs(orig_hb) do
        pcall(function() part.Size = size end)
    end
    orig_hb = {}
end

RunService.Heartbeat:Connect(function()
    if CFG.ativo then
        local agora = tick()
        if agora - ultimo >= CFG.delay then
            local alvo = acharProximo()
            if alvo then
                clicar()
                ultimo = agora
            end
        end
    end
    if CFG.hitbox then aplicarHitbox()
    elseif next(orig_hb) then limparHitbox() end
end)

print("[TRIGGER] carregado")
