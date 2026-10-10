local UILib = getgenv().MinhaUILib
if not UILib then warn("[MENU] UILib nao carregou"); return end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local AIM = getgenv().AIM_CFG
local ESP = getgenv().ESP_CFG
local MOVE = getgenv().MOVE_CFG
local WORLD = getgenv().WORLD_CFG
local UTIL = getgenv().UTIL_CFG
local FARM = getgenv().FARM_CFG
local TRIG = getgenv().TRIGGER_CFG

if not (AIM and ESP and MOVE and WORLD) then
    warn("[MENU] configs nao carregaram")
    return
end

local Window = UILib:CreateWindow({Title = "Delta Hub", Author = "Metrópole RP"})

local function listarPlayers()
    local l = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(l, p.Name) end
    end
    return l
end

-- SEGURANCA
local tabSafe = Window:CreateTab("Seguranca")
tabSafe:Toggle("Modo Seguro", "Desliga Speed/Fly/Noclip perto de player", MOVE.safe_mode, function(v) MOVE.safe_mode = v end)
tabSafe:Slider("Raio Deteccao", "Studs", 20, 300, MOVE.safe_radius, 10, function(v) MOVE.safe_radius = v end)
tabSafe:Paragraph("Quando um player entra no raio, Speed/Fly/Noclip desligam.")

-- COMBAT
local tabCombat = Window:CreateTab("Combat")
tabCombat:Toggle("Aimbot", "Mira automatica", AIM.ativo, function(v) AIM.ativo = v end)
tabCombat:Toggle("Team Check", "Ignora aliados", AIM.team_check, function(v) AIM.team_check = v end)

local ddAmigos = tabCombat:Dropdown("Amigos (nao mirar)", listarPlayers(), true, function(sel)
    AIM.amigos = {}
    for n, _ in pairs(sel) do AIM.amigos[n] = true end
end)
Players.PlayerAdded:Connect(function() task.wait(1) if ddAmigos then ddAmigos:refresh(listarPlayers()) end end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) if ddAmigos then ddAmigos:refresh(listarPlayers()) end end)

tabCombat:Slider("Aim FOV", "Graus", 5, 90, AIM.fov, 5, function(v) AIM.fov = v end)
tabCombat:Slider("Smoothing", "0-100", 0, 100, math.floor(AIM.smoothing*100), 5, function(v) AIM.smoothing = v/100 end)
tabCombat:Slider("Distancia Max", "Studs", 100, 2000, AIM.max_dist, 100, function(v) AIM.max_dist = v end)

-- TRIGGER
if TRIG then
    local tabTrig = Window:CreateTab("Trigger")
    tabTrig:Toggle("Trigger Bot", "Atira sozinho no alvo mais proximo do crosshair", TRIG.ativo, function(v) TRIG.ativo = v end)
    tabTrig:Slider("Angulo", "Graus", 1, 15, TRIG.raio_graus, 1, function(v) TRIG.raio_graus = v end)
    tabTrig:Slider("Delay x100", "Espera entre tiros", 1, 50, TRIG.delay*100, 1, function(v) TRIG.delay = v/100 end)
    tabTrig:Toggle("Team Check", "Nao atira em aliados", TRIG.team_check, function(v) TRIG.team_check = v end)
    tabTrig:Toggle("Hitbox", "Aumenta corpo dos inimigos", TRIG.hitbox, function(v) TRIG.hitbox = v end)
    tabTrig:Slider("Hitbox Size", "Studs", 2, 20, TRIG.hitbox_size, 1, function(v) TRIG.hitbox_size = v end)
end

-- ESP
local tabESP = Window:CreateTab("ESP")
tabESP:Toggle("Box", "Caixa em volta", ESP.box, function(v) ESP.box = v end)
tabESP:Toggle("Line", "Linha do crosshair", ESP.line, function(v) ESP.line = v end)
tabESP:Toggle("Name", "Nome em cima", ESP.name, function(v) ESP.name = v end)
tabESP:Toggle("Distance", "Distancia", ESP.dist, function(v) ESP.dist = v end)
tabESP:Toggle("Chams", "Contorno", ESP.chams, function(v) ESP.chams = v end)

-- MOVEMENT
local tabMove = Window:CreateTab("Movement")
tabMove:Toggle("Speed Hack", "Anda mais rapido", MOVE.speed_on, function(v) MOVE.speed_on = v end)
tabMove:Slider("Speed", "Padrao 12", 12, 100, MOVE.speed, 2, function(v) MOVE.speed = v end)
tabMove:Toggle("Fly", "Joystick + camera", MOVE.fly, function(v) MOVE.fly = v end)
tabMove:Slider("Fly Speed", "20-200", 20, 200, MOVE.fly_speed, 5, function(v) MOVE.fly_speed = v end)
tabMove:Toggle("Noclip", "Atravessa paredes", MOVE.noclip, function(v) MOVE.noclip = v end)
tabMove:Toggle("Infinite Jump", "Pula infinito", MOVE.inf_jump, function(v) MOVE.inf_jump = v end)

-- WORLD
local tabWorld = Window:CreateTab("World")
tabWorld:Toggle("Fullbright", "Ilumina o mapa", WORLD.fullbright, function(v) WORLD.fullbright = v end)
tabWorld:Toggle("No Fog", "Remove neblina", WORLD.no_fog, function(v) WORLD.no_fog = v end)
tabWorld:Slider("Hora", "0-24", 0, 24, WORLD.hora, 1, function(v) WORLD.hora = v end)

-- UTIL (com TP)
if UTIL then
    local tabUtil = Window:CreateTab("Util")
    tabUtil:Toggle("Anti-AFK", "Nao kicka por inatividade", UTIL.anti_afk, function(v) UTIL.anti_afk = v end)
    tabUtil:Toggle("Coordenadas", "X Y Z na tela", UTIL.coords, function(v) UTIL.coords = v end)
    tabUtil:Slider("FOV camera", "40-120", 40, 120, UTIL.fov, 5, function(v) UTIL.fov = v end)

    local ddTP = tabUtil:Dropdown("Escolher alvo (TP)", listarPlayers(), false, function(sel)
        for nome, _ in pairs(sel) do
            UTIL.alvo_tp = nome
            print("[UTIL] alvo: " .. nome)
        end
    end)
    Players.PlayerAdded:Connect(function() task.wait(1) if ddTP then ddTP:refresh(listarPlayers()) end end)
    Players.PlayerRemoving:Connect(function() task.wait(0.5) if ddTP then ddTP:refresh(listarPlayers()) end end)

    tabUtil:Button("TELEPORTAR pro alvo", function()
        if not UTIL.alvo_tp then
            print("[UTIL] escolhe alvo primeiro")
            return
        end
        if getgenv().UTIL_TP_PLAYER and getgenv().UTIL_TP_PLAYER(UTIL.alvo_tp) then
            print("[UTIL] tp pra " .. UTIL.alvo_tp)
        end
    end)

    tabUtil:Button("Salvar Posicao", function() if getgenv().UTIL_SALVAR() then print("[UTIL] salva") end end)
    tabUtil:Button("Voltar Posicao", function() if getgenv().UTIL_VOLTAR() then print("[UTIL] voltou") end end)
    tabUtil:Button("Salvar Config", function() if getgenv().UTIL_SALVAR_CONFIG() then print("[UTIL] salva") end end)
    tabUtil:Button("Carregar Config", function() if getgenv().UTIL_CARREGAR_CONFIG() then print("[UTIL] carregada") end end)
end

-- FARM
if FARM then
    local tabFarm = Window:CreateTab("Farm")
    tabFarm:Toggle("Auto Prompt", "Dispara ProximityPrompt", FARM.auto_prompt, function(v) FARM.auto_prompt = v end)
    tabFarm:Toggle("Auto Coletar", "So pega itens", FARM.auto_collect, function(v) FARM.auto_collect = v end)
    tabFarm:Slider("Raio", "Studs", 5, 100, FARM.raio, 5, function(v) FARM.raio = v end)
    tabFarm:Slider("Delay x10", "Espera entre acoes", 1, 20, FARM.delay*10, 1, function(v) FARM.delay = v/10 end)
end

-- INFO
local tabInfo = Window:CreateTab("Info")
tabInfo:Paragraph("Delta Hub\nAutor: pablocachorreira165\n\nTP: escolhe alvo no dropdown, toca TELEPORTAR")
