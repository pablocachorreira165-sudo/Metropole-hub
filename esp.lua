-- esp.lua | Modulo de ESP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local CFG = getgenv().ESP_CFG or {
    box = false, line = false, name = false, dist = false, chams = false,
    cor = Color3.fromRGB(0, 255, 100)
}
getgenv().ESP_CFG = CFG

local gui = Instance.new("ScreenGui")
gui.Name = "MetropoleESP"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = LP:WaitForChild("PlayerGui")

local objs = {}

local function criar(plr)
    local c = plr.Character
    if not c then return end
    local lista = {}

    if CFG.chams then
        local hl = Instance.new("Highlight")
        hl.FillColor = CFG.cor
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.Parent = c
        table.insert(lista, hl)
    end

    local head = c:FindFirstChild("Head")
    if head then
        if CFG.box then
            local bg = Instance.new("BillboardGui")
            bg.Name = "box"
            bg.Size = UDim2.new(2.5, 0, 3.5, 0)
            bg.StudsOffset = Vector3.new(0, 2, 0)
            bg.AlwaysOnTop = false
            bg.Parent = head
            local b = Instance.new("Frame")
            b.Size = UDim2.new(1, 0, 1, 0)
            b.BackgroundTransparency = 1
            b.Parent = bg
            local st = Instance.new("UIStroke")
            st.Color = CFG.cor
            st.Thickness = 1.5
            st.Parent = b
            table.insert(lista, bg)
        end

        if CFG.name or CFG.dist then
            local bg2 = Instance.new("BillboardGui")
            bg2.Name = "info"
            bg2.Size = UDim2.new(0, 180, 0, 16)
            bg2.StudsOffset = Vector3.new(0, 4.5, 0)
            bg2.AlwaysOnTop = true
            bg2.LightInfluence = 0
            bg2.Parent = head
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = CFG.cor
            txt.TextStrokeTransparency = 0
            txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            txt.TextScaled = false
            txt.TextSize = 14
            txt.Font = Enum.Font.GothamBold
            txt.Text = plr.Name
            txt.Parent = bg2
            table.insert(lista, bg2)
        end
    end

    objs[plr] = lista
end

local linhas = {}

RunService.Heartbeat:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local c = plr.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if not c or not h or h.Health <= 0 then
            if objs[plr] then
                for _, o in ipairs(objs[plr]) do if o then o:Destroy() end end
                objs[plr] = nil
            end
            continue
        end
        if not objs[plr] then criar(plr) end

        local lista = objs[plr]
        if lista then
            for _, o in ipairs(lista) do
                if o and o.Name == "info" then
                    local t = o:FindFirstChildOfClass("TextLabel")
                    if t then
                        local p = {}
                        if CFG.name then table.insert(p, plr.Name) end
                        if CFG.dist then
                            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            local tr = c:FindFirstChild("HumanoidRootPart")
                            if hrp and tr then
                                table.insert(p, math.floor((hrp.Position - tr.Position).Magnitude) .. "m")
                            end
                        end
                        t.Text = table.concat(p, " | ")
                    end
                end
            end
        end
    end

    for _, l in ipairs(linhas) do if l then l:Destroy() end end
    linhas = {}

    if CFG.line then
        local vp = Camera.ViewportSize
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LP then continue end
            local c = plr.Character
            local hd = c and c:FindFirstChild("Head")
            if not hd then continue end
            local pos, on = Camera:WorldToScreenPoint(hd.Position)
            if not on then continue end
            local orig = Vector2.new(vp.X/2, vp.Y)
            local diff = Vector2.new(pos.X, pos.Y) - orig
            local lin = Instance.new("Frame")
            lin.Size = UDim2.new(0, diff.Magnitude, 0, 1)
            lin.Position = UDim2.new(0.5, 0, 1, 0)
            lin.AnchorPoint = Vector2.new(0, 0.5)
            lin.Rotation = math.deg(math.atan2(diff.Y, diff.X))
            lin.BackgroundColor3 = CFG.cor
            lin.BorderSizePixel = 0
            lin.Parent = gui
            table.insert(linhas, lin)
        end
    end
end)

print("[ESP] carregado")
