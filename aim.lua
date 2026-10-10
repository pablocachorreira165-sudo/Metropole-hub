-- aim.lua | Modulo de aimbot
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local CFG = getgenv().AIM_CFG or {
    ativo = false, fov = 25, smoothing = 0.20,
    team_check = true, max_dist = 500, amigos = {}
}
getgenv().AIM_CFG = CFG
if not CFG.amigos then CFG.amigos = {} end

local function fov_px()
    local vp = Camera.ViewportSize
    local f = math.rad(Camera.FieldOfView)
    return math.tan(math.rad(CFG.fov)) * ((vp.Y / 2) / math.tan(f / 2))
end

local function parte_alvo(c)
    for _, n in ipairs({"Head", "UpperTorso", "Torso", "HumanoidRootPart"}) do
        local p = c:FindFirstChild(n)
        if p then return p end
    end
end

local function aliado(plr)
    if CFG.amigos[plr.Name] then return true end
    if not CFG.team_check then return false end
    if not LP.Team or not plr.Team then return false end
    return LP.Team == plr.Team
end

local function achar()
    local centro = Camera.ViewportSize / 2
    local raio = fov_px()
    local melhor, md = nil, math.huge
    local pc = Camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP or aliado(plr) then continue end
        local c = plr.Character
        if not c then continue end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then continue end
        local p = parte_alvo(c)
        if not p then continue end
        if (p.Position - pc).Magnitude > CFG.max_dist then continue end
        local sp, on = Camera:WorldToScreenPoint(p.Position)
        if not on then continue end
        local d = (Vector2.new(sp.X, sp.Y) - centro).Magnitude
        if d <= raio and d < md then
            md = d
            melhor = { parte = p, pos = p.Position }
        end
    end
    return melhor
end

local bind = "MetropoleAim_Cam"
pcall(function() RunService:UnbindFromRenderStep(bind) end)
RunService:BindToRenderStep(bind, 2000, function()
    if not CFG.ativo then return end
    local a = achar()
    if not a then return end
    local cp = Camera.CFrame.Position
    local dir = (a.pos - cp).Unit
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(cp, cp + dir), CFG.smoothing)
end)

print("[AIM] carregado")
