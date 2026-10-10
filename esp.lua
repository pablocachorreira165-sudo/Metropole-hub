-- esp.lua | ESP v2 (ScreenGui Frames, sempre visivel)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local CFG = getgenv().ESP_CFG
if not CFG then
    CFG = { box = false, line = false, name = false, dist = false, chams = false,
        cor = Color3.fromRGB(0, 255, 100), max_dist = 500 }
    getgenv().ESP_CFG = CFG
end

local gui = Instance.new("ScreenGui")
gui.Name = "MetropoleESP"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")

local slots = {}

local function criarSlot(plr)
    if slots[plr] then return slots[plr] end
    local s = {}

    s.box = Instance.new("Frame")
    s.box.BackgroundTransparency = 1
    s.box.BorderSizePixel = 0
    s.box.Visible = false
    s.box.ZIndex = 50
    s.box.Parent = gui
    s.stroke = Instance.new("UIStroke")
    s.stroke.Color = CFG.cor
    s.stroke.Thickness = 1.5
    s.stroke.Parent = s.box

    s.info = Instance.new("TextLabel")
    s.info.BackgroundTransparency = 1
    s.info.TextColor3 = CFG.cor
    s.info.TextStrokeTransparency = 0
    s.info.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    s.info.TextSize = 13
    s.info.Font = Enum.Font.GothamBold
    s.info.TextXAlignment = Enum.TextXAlignment.Center
    s.info.Visible = false
    s.info.ZIndex = 51
    s.info.Parent = gui

    s.line = Instance.new("Frame")
    s.line.BorderSizePixel = 0
    s.line.BackgroundColor3 = CFG.cor
    s.line.AnchorPoint = Vector2.new(0, 0.5)
    s.line.Position = UDim2.new(0.5, 0, 0.5, 0)
    s.line.Visible = false
    s.line.ZIndex = 49
    s.line.Parent = gui

    slots[plr] = s
    return s
end

local function removerSlot(plr)
    local s = slots[plr]
    if not s then return end
    pcall(function() s.box:Destroy() end)
    pcall(function() s.info:Destroy() end)
    pcall(function() s.line:Destroy() end)
    slots[plr] = nil
end

local chams = {}

local function atualizarChams(plr, char)
    if CFG.chams and char then
        if not chams[plr] or chams[plr].Parent ~= char then
            if chams[plr] then chams[plr]:Destroy() end
            local hl = Instance.new("Highlight")
            hl.FillColor = CFG.cor
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.6
            hl.OutlineTransparency = 0
            hl.Parent = char
            chams[plr] = hl
        end
    else
        if chams[plr] then chams[plr]:Destroy() chams[plr] = nil end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    removerSlot(plr)
    if chams[plr] then chams[plr]:Destroy() chams[plr] = nil end
end)

RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end

        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")

        if not char or not hum or hum.Health <= 0 or not hrp or not head then
            local s = slots[plr]
            if s then s.box.Visible = false; s.info.Visible = false; s.line.Visible = false end
            if chams[plr] then chams[plr]:Destroy() chams[plr] = nil end
            continue
        end

        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist > (CFG.max_dist or 500) then
            local s = slots[plr]
            if s then s.box.Visible = false; s.info.Visible = false; s.line.Visible = false end
            continue
        end

        local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
        local hrpPos, hrpOn = Camera:WorldToViewportPoint(hrp.Position)

        if not headOn or not hrpOn then
            local s = slots[plr]
            if s then s.box.Visible = false; s.info.Visible = false; s.line.Visible = false end
            continue
        end

        local s = criarSlot(plr)

        -- tamanho do box baseado na distancia (px por stud)
        local fov_rad = math.rad(Camera.FieldOfView)
        local px_per_stud = (vp.Y / 2) / (math.tan(fov_rad / 2) * dist)
        local box_h = 5 * px_per_stud
        local box_w = box_h * 0.55

        s.box.Size = UDim2.new(0, box_w, 0, box_h)
        s.box.Position = UDim2.new(0, hrpPos.X - box_w / 2, 0, hrpPos.Y - box_h / 2)
        s.box.Visible = CFG.box
        s.stroke.Color = CFG.cor

        -- info (nome + distancia)
        local texto = ""
        if CFG.name then texto = plr.Name end
        if CFG.dist then
            if texto ~= "" then texto = texto .. "  " end
            texto = texto .. math.floor(dist) .. "m"
        end
        s.info.Text = texto
        s.info.Size = UDim2.new(0, 250, 0, 16)
        s.info.Position = UDim2.new(0, hrpPos.X - 125, 0, hrpPos.Y - box_h / 2 - 20)
        s.info.Visible = (CFG.name or CFG.dist)
        s.info.TextColor3 = CFG.cor

        -- line: do centro da tela (crosshair) ate o alvo
        if CFG.line then
            local orig = Vector2.new(vp.X / 2, vp.Y / 2)
            local alvo2 = Vector2.new(headPos.X, headPos.Y)
            local diff = alvo2 - orig
            s.line.Size = UDim2.new(0, diff.Magnitude, 0, 1)
            s.line.Position = UDim2.new(0.5, 0, 0.5, 0)
            s.line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
            s.line.BackgroundColor3 = CFG.cor
            s.line.Visible = true
        else
            s.line.Visible = false
        end

        atualizarChams(plr, char)
    end
end)

print("[ESP] carregado v2")
