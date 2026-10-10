local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local CFG = getgenv().UTIL_CFG or {anti_afk=false,coords=false,fov=70,pos_salva=nil}
getgenv().UTIL_CFG = CFG

local conn_afk
local function setAntiAFK(on)
    if conn_afk then conn_afk:Disconnect() conn_afk = nil end
    if on then
        conn_afk = LP.Idled:Connect(function()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new(0, 0))
            end)
        end)
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "UtilityHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = LP:WaitForChild("PlayerGui")

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0, 260, 0, 24)
lbl.Position = UDim2.new(0, 10, 0, 80)
lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lbl.BackgroundTransparency = 0.4
lbl.TextColor3 = Color3.fromRGB(0, 255, 100)
lbl.TextSize = 12
lbl.Font = Enum.Font.Code
lbl.Text = ""
lbl.Visible = false
lbl.Parent = gui
local lc = Instance.new("UICorner"); lc.CornerRadius = UDim.new(0, 6); lc.Parent = lbl

RunService.Heartbeat:Connect(function()
    local c = LP.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if CFG.coords and r then
        lbl.Visible = true
        lbl.Text = string.format("X:%.0f  Y:%.0f  Z:%.0f", r.Position.X, r.Position.Y, r.Position.Z)
    else
        lbl.Visible = false
    end
    if Camera and Camera.FieldOfView ~= CFG.fov then Camera.FieldOfView = CFG.fov end
    if CFG.anti_afk and not conn_afk then setAntiAFK(true)
    elseif not CFG.anti_afk and conn_afk then setAntiAFK(false) end
end)

-- SALVAR/VOLTAR POSICAO
getgenv().UTIL_SALVAR = function()
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if r then CFG.pos_salva = r.CFrame return true end
    return false
end
getgenv().UTIL_VOLTAR = function()
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if r and CFG.pos_salva then r.CFrame = CFG.pos_salva return true end
    return false
end

-- TP PRA PLAYER
getgenv().UTIL_TP_PLAYER = function(nome)
    if not nome or nome == "" then return false end
    local alvo = Players:FindFirstChild(nome)
    if not alvo then return false end
    local hrp = alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart")
    local meu = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not meu then return false end
    -- teleporta 3 studs pro lado do alvo (evita colisão)
    meu.CFrame = CFrame.new(hrp.Position + hrp.CFrame.RightVector * 3)
    return true
end

-- LISTA DE PLAYERS
getgenv().UTIL_LISTAR = function()
    local l = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(l, p.Name) end
    end
    return l
end

-- SALVAR/CARREGAR CONFIG
getgenv().UTIL_SALVAR_CONFIG = function()
    if not writefile then return false end
    local d = "fov="..CFG.fov
    if getgenv().AIM_CFG then d=d.."\naim_fov="..getgenv().AIM_CFG.fov.."\naim_smooth="..getgenv().AIM_CFG.smoothing end
    if getgenv().MOVE_CFG then d=d.."\nspeed="..getgenv().MOVE_CFG.speed.."\nfly_speed="..getgenv().MOVE_CFG.fly_speed end
    return pcall(function() writefile("metropole_config.txt", d) end)
end
getgenv().UTIL_CARREGAR_CONFIG = function()
    if not readfile then return false end
    local ok, txt = pcall(function() return readfile("metropole_config.txt") end)
    if not ok or not txt then return false end
    for line in txt:gmatch("[^\n]+") do
        local k, v = line:match("([^=]+)=(.+)")
        local n = tonumber(v)
        if n then
            if k=="fov" then CFG.fov=n end
            if k=="aim_fov" and getgenv().AIM_CFG then getgenv().AIM_CFG.fov=n end
            if k=="aim_smooth" and getgenv().AIM_CFG then getgenv().AIM_CFG.smoothing=n end
            if k=="speed" and getgenv().MOVE_CFG then getgenv().MOVE_CFG.speed=n end
            if k=="fly_speed" and getgenv().MOVE_CFG then getgenv().MOVE_CFG.fly_speed=n end
        end
    end
    return true
end

print("[UTILITY] carregado")
