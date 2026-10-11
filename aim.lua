local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = workspace
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

local CFG = getgenv().AIM_CFG or {
    ativo=false, fov=25, smoothing=0.20, team_check=true,
    max_dist=500, wall_check=true, fov_circle=true,
    priority="crosshair", amigos={}
}
getgenv().AIM_CFG = CFG
if CFG.fov_circle == nil then CFG.fov_circle = true end
if not CFG.priority then CFG.priority = "crosshair" end
if not CFG.amigos then CFG.amigos = {} end

-- FOV CIRCLE VISUAL
local gui = Instance.new("ScreenGui")
gui.Name = "AimFOV"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 99
gui.Parent = LP:WaitForChild("PlayerGui")

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Size = UDim2.new(0, 200, 0, 200)
fovCircle.Parent = gui
local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fovCircle
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(0,200,255)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.4
fovStroke.Parent = fovCircle

local function fov_px()
    local vp = Camera.ViewportSize
    local f = math.rad(Camera.FieldOfView)
    return math.tan(math.rad(CFG.fov)) * ((vp.Y/2) / math.tan(f/2))
end

RunService.RenderStepped:Connect(function()
    fovCircle.Visible = CFG.fov_circle
    local r = fov_px()
    fovCircle.Size = UDim2.new(0, r*2, 0, r*2)
end)

local function parte_alvo(c)
    for _, n in ipairs({"Head","UpperTorso","Torso","HumanoidRootPart"}) do
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

local function temParede(o, d)
    if not CFG.wall_check then return false end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = {LP.Character, Camera}
    p.IgnoreWater = true
    return Workspace:Raycast(o, d - o, p) ~= nil
end

local function achar()
    local centro = Camera.ViewportSize / 2
    local raio = fov_px()
    local pc = Camera.CFrame.Position
    local melhor, melhor_score = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP or aliado(plr) then continue end
        local c = plr.Character
        if not c then continue end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then continue end
        local p = parte_alvo(c)
        if not p then continue end
        local dist = (p.Position - pc).Magnitude
        if dist > CFG.max_dist then continue end
        local sp, on = Camera:WorldToScreenPoint(p.Position)
        if not on then continue end
        local d = (Vector2.new(sp.X, sp.Y) - centro).Magnitude
        if d > raio then continue end
        if temParede(pc, p.Position) then continue end

        local score
        if CFG.priority == "dist" then
            score = dist
        elseif CFG.priority == "health" then
            score = h.Health
        else
            score = d
        end

        if score < melhor_score then
            melhor_score = score
            melhor = {parte=p, pos=p.Position, nome=plr.Name}
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

print("[AIM] carregado v2 (fov circle + priority)")
