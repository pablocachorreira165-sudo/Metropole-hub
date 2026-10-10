-- utility.lua | Utilidades (anti-afk, coords, salvar pos, config)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local CFG = getgenv().UTIL_CFG or {
    anti_afk = false,
    coords = false,
    fov = 70,
    pos_salva = nil,
}
getgenv().UTIL_CFG = CFG

-- Anti-AFK
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

-- GUI de coordenadas
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

    if Camera and Camera.FieldOfView ~= CFG.fov then
        Camera.FieldOfView = CFG.fov
    end

    if CFG.anti_afk and not conn_afk then setAntiAFK(true)
    elseif not CFG.anti_afk and conn_afk then setAntiAFK(false) end
end)

-- API global
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

-- Salvar/carregar configs (Delta tem writefile)
getgenv().UTIL_SALVAR_CONFIG = function()
    if not writefile then return false end
    local dados = {
        fov = CFG.fov,
        aim_fov = getgenv().AIM_CFG and getgenv().AIM_CFG.fov,
        aim_smooth = getgenv().AIM_CFG and getgenv().AIM_CFG.smoothing,
        speed = getgenv().MOVE_CFG and getgenv().MOVE_CFG.speed,
        fly_speed = getgenv().MOVE_CFG and getgenv().MOVE_CFG.fly_speed,
        esp_cor = "0,255,100",
    }
    local str = ""
    for k, v in pairs(dados) do
        str = str .. k .. "=" .. tostring(v) .. "\n"
    end
    local ok = pcall(function() writefile("metropole_config.txt", str) end)
    return ok
end

getgenv().UTIL_CARREGAR_CONFIG = function()
    if not readfile then return false end
    local ok, conteudo = pcall(function() return readfile("metropole_config.txt") end)
    if not ok or not conteudo then return false end
    for linha in conteudo:gmatch("[^\n]+") do
        local k, v = linha:match("([^=]+)=(.+)")
        if k and v then
            local num = tonumber(v)
            if k == "fov" and num then CFG.fov = num end
            if k == "aim_fov" and num and getgenv().AIM_CFG then getgenv().AIM_CFG.fov = num end
            if k == "aim_smooth" and num and getgenv().AIM_CFG then getgenv().AIM_CFG.smoothing = num end
            if k == "speed" and num and getgenv().MOVE_CFG then getgenv().MOVE_CFG.speed = num end
            if k == "fly_speed" and num and getgenv().MOVE_CFG then getgenv().MOVE_CFG.fly_speed = num end
        end
    end
    return true
end

print("[UTILITY] carregado")
