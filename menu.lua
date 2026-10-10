-- menu.lua | Menu do Metrópole Hub usando MinhaUILib
local UILib = getgenv().MinhaUILib
if not UILib then warn("[MENU] UILib nao carregou"); return end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local AIM = getgenv().AIM_CFG
local ESP = getgenv().ESP_CFG
local MOVE = getgenv().MOVE_CFG
local WORLD = getgenv().WORLD_CFG

if not (AIM and ESP and MOVE and WORLD) then
    warn("[MENU] configs nao carregaram")
    return
end

local Window = UILib:CreateWindow({
    Title = "Metrópole Hub",
    Author = "pablocachorreira165",
})

-- ============ SEGURANCA ============
local tabSafe = Window:CreateTab("Segurança")

tabSafe:Toggle("Modo Seguro",
    "Desliga Speed/Fly/Noclip quando alguem chega perto",
    MOVE.safe_mode,
    function(v) MOVE.safe_mode = v end
)

tabSafe:Slider("Raio de Detecção",
    "Distancia em studs",
    20, 300,
    MOVE.safe_radius,
    10,
    function(v) MOVE.safe_radius = v end
)

tabSafe:Paragraph("Quando um player entra no raio, Speed, Fly e Noclip desligam sozinhos. Quando ele sai, voltam ao normal.")

-- ============ COMBAT ============
local tabCombat = Window:CreateTab("Combat")

tabCombat:Toggle("Aimbot", "Mira automatica", AIM.ativo, function(v) AIM.ativo = v end)
tabCombat:Toggle("Team Check", "Ignora aliados", AIM.team_check, function(v) AIM.team_check = v end)

local function listarPlayers()
    local lista = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(lista, p.Name) end
    end
    return lista
end

local dropdown = tabCombat:Dropdown("Amigos (não mirar)", listarPlayers(), true, function(sel)
    AIM.amigos = {}
    for nome, _ in pairs(sel) do
        AIM.amigos[nome] = true
    end
end)

Players.PlayerAdded:Connect(function()
    task.wait(1)
    if dropdown then dropdown:refresh(listarPlayers()) end
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    if dropdown then dropdown:refresh(listarPlayers()) end
end)

tabCombat:Slider("Aim FOV", "Raio em graus", 5, 90, AIM.fov, 5,
    function(v) AIM.fov = v end)

tabCombat:Slider("Smoothing", "0 = instantaneo, 100 = suave", 0, 100,
    math.floor(AIM.smoothing * 100), 5,
    function(v) AIM.smoothing = v / 100 end)

tabCombat:Slider("Distância Máxima", "Studs", 100, 2000, AIM.max_dist, 100,
    function(v) AIM.max_dist = v end)

-- ============ ESP ============
local tabESP = Window:CreateTab("ESP")

tabESP:Toggle("Box", "Caixa em volta", ESP.box, function(v) ESP.box = v end)
tabESP:Toggle("Line", "Linha ate o alvo", ESP.line, function(v) ESP.line = v end)
tabESP:Toggle("Name", "Nome em cima", ESP.name, function(v) ESP.name = v end)
tabESP:Toggle("Distance", "Distancia em metros", ESP.dist, function(v) ESP.dist = v end)
tabESP:Toggle("Chams", "Contorno colorido", ESP.chams, function(v) ESP.chams = v end)

-- ============ MOVEMENT ============
local tabMove = Window:CreateTab("Movement")

tabMove:Toggle("Speed Hack", "Anda mais rapido", MOVE.speed_on, function(v) MOVE.speed_on = v end)
tabMove:Slider("Speed", "Padrao do jogo: 12", 12, 100, MOVE.speed, 2,
    function(v) MOVE.speed = v end)

tabMove:Toggle("Fly", "Use os botoes na tela", MOVE.fly, function(v) MOVE.fly = v end)
tabMove:Slider("Fly Speed x10", "1 = lento, 50 = rapido", 5, 50,
    math.floor(MOVE.fly_speed * 10), 1,
    function(v) MOVE.fly_speed = v / 10 end)

tabMove:Toggle("Noclip", "Atravessa paredes", MOVE.noclip, function(v) MOVE.noclip = v end)
tabMove:Toggle("Infinite Jump", "Pula quantas vezes quiser", MOVE.inf_jump, function(v) MOVE.inf_jump = v end)

-- ============ WORLD ============
local tabWorld = Window:CreateTab("World")

tabWorld:Toggle("Fullbright", "Ilumina o mapa", WORLD.fullbright, function(v) WORLD.fullbright = v end)
tabWorld:Toggle("No Fog", "Remove a neblina", WORLD.no_fog, function(v) WORLD.no_fog = v end)
tabWorld:Slider("Hora do dia", "0 = meia-noite", 0, 24, WORLD.hora, 1,
    function(v) WORLD.hora = v end)

-- ============ INFO ============
local tabInfo = Window:CreateTab("Info")

tabInfo:Paragraph("Metrópole Hub\nAutor: pablocachorreira165\n\nDicas:\nSpeed: 16-25 seguro\nFly: use em area privada\nNoclip: cuidado com players por perto\nESP e Aimbot: baixo risco")
