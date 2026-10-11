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
local REV = getgenv().REVISTAR_CFG
local PERF = getgenv().PERF_CFG

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

local tabSafe = Window:CreateTab("Seguranca")
tabSafe:Toggle("Modo Seguro", "Desliga Speed/Fly/Noclip perto de player", MOVE.safe_mode, function(v) MOVE.safe_mode = v end)
tabSafe:Slider("Raio Deteccao", "Studs", 20, 300, MOVE.safe_radius, 10, function(v) MOVE.safe_radius = v end)

local tabCombat = Window:CreateTab("Combat")
tabCombat:Toggle("Aimbot", "Mira automatica", AIM.ativo, function(v) AIM.ativo = v end)
tabCombat:Toggle("Team Check", "Ignora aliados", AIM.team_check, function(v) AIM.team_check = v end)
tabCombat:Toggle("Wall Check", "Nao mira se tiver parede", AIM.wall_check, function(v) AIM.wall_check = v end)
tabCombat:Toggle("FOV Circle", "Mostra circulo de mira", AIM.fov_circle, function(v) AIM.fov_circle = v end)

local ddAmigos = tabCombat:Dropdown("Amigos (nao mirar)", listarPlayers(), true, function(sel)
    AIM.amigos = {}
    for n, _ in pairs(sel) do AIM.amigos[n] = true end
end)
Players.PlayerAdded:Connect(function() task.wait(1) if ddAmigos then ddAmigos:refresh(listarPlayers()) end end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) if ddAmigos then ddAmigos:refresh(listarPlayers()) end end)

tabCombat:Slider("Aim FOV", "Graus", 5, 90, AIM.fov, 5, function(v) AIM.fov = v end)
tabCombat:Slider("Smoothing", "0-100", 0, 100, math.floor(AIM.smoothing*100), 5, function(v) AIM.smoothing = v/100 end)
tabCombat:Slider("Distancia Max", "Studs", 100, 2000, AIM.max_dist, 100, function(v) AIM.max_dist = v end)

tabCombat:Button("Priority: Crosshair", function() AIM.priority = "crosshair" print("[AIM] crosshair") end)
tabCombat:Button("Priority: Distancia", function() AIM.priority = "dist" print("[AIM] dist") end)
tabCombat:Button("Priority: Vida Baixa", function() AIM.priority = "health" print("[AIM] health") end)

if TRIG then
    local tabTrig = Window:CreateTab("Trigger")
    tabTrig:Toggle("Trigger Bot", "Atira sozinho", TRIG.ativo, function(v) TRIG.ativo = v end)
    tabTrig:Slider("Angulo", "Graus", 1, 15, TRIG.raio_graus, 1, function(v) TRIG.raio_graus = v end)
    tabTrig:Slider("Delay x100", "Espera entre tiros", 1, 50, TRIG.delay*100, 1, function(v) TRIG.delay = v/100 end)
    tabTrig:Toggle("Team Check", "Nao atira em aliados", TRIG.team_check, function(v) TRIG.team_check = v end)
    tabTrig:Toggle("Hitbox", "Corpo maior", TRIG.hitbox, function(v) TRIG.hitbox = v end)
    tabTrig:Slider("Hitbox Size", "Studs", 2, 20, TRIG.hitbox_size, 1, function(v) TRIG.hitbox_size = v end)
end

local tabESP = Window:CreateTab("ESP")
tabESP:Toggle("Box", "Caixa em volta", ESP.box, function(v) ESP.box = v end)
tabESP:Toggle("Line", "Linha do crosshair", ESP.line, function(v) ESP.line = v end)
tabESP:Toggle("Name", "Nome em cima", ESP.name, function(v) ESP.name = v end)
tabESP:Toggle("Distance", "Distancia", ESP.dist, function(v) ESP.dist = v end)
tabESP:Toggle("Chams", "Contorno", ESP.chams, function(v) ESP.chams = v end)
tabESP:Toggle("Health Bar", "Barra de vida", ESP.health, function(v) ESP.health = v end)
tabESP:Toggle("Head Dot", "Bolinha na cabeca", ESP.dot, function(v) ESP.dot = v end)
tabESP:Toggle("Cor por Distancia", "Perto vermelho, longe verde", ESP.cor_dist, function(v) ESP.cor_dist = v end)
tabESP:Toggle("Team Check", "Nao mostra aliado", ESP.team_check, function(v) ESP.team_check = v end)

local tabMove = Window:CreateTab("Movement")
tabMove:Toggle("Speed Hack", "Anda mais rapido", MOVE.speed_on, function(v) MOVE.speed_on = v end)
tabMove:Slider("Speed", "Padrao 12", 12, 100, MOVE.speed, 2, function(v) MOVE.speed = v end)
tabMove:Toggle("Fly", "Joystick + camera", MOVE.fly, function(v) MOVE.fly = v end)
tabMove:Slider("Fly Speed", "20-200", 20, 200, MOVE.fly_speed, 5, function(v) MOVE.fly_speed = v end)
tabMove:Toggle("Noclip", "Atravessa paredes", MOVE.noclip, function(v) MOVE.noclip = v end)
tabMove:Toggle("Infinite Jump", "Pula infinito", MOVE.inf_jump, function(v) MOVE.inf_jump = v end)

local tabWorld = Window:CreateTab("World")
tabWorld:Toggle("Fullbright", "Ilumina o mapa", WORLD.fullbright, function(v) WORLD.fullbright = v end)
tabWorld:Toggle("No Fog", "Remove neblina", WORLD.no_fog, function(v) WORLD.no_fog = v end)
tabWorld:Slider("Hora", "0-24", 0, 24, WORLD.hora, 1, function(v) WORLD.hora = v end)

if UTIL then
    local tabUtil = Window:CreateTab("Util")
    tabUtil:Toggle("Anti-AFK", "Nao kicka por inatividade", UTIL.anti_afk, function(v) UTIL.anti_afk = v end)
    tabUtil:Toggle("Coordenadas", "X Y Z na tela", UTIL.coords, function(v) UTIL.coords = v end)
    tabUtil:Slider("FOV camera", "40-120", 40, 120, UTIL.fov, 5, function(v) UTIL.fov = v end)

    local ddTP = tabUtil:Dropdown("Escolher alvo (TP)", listarPlayers(), false, function(sel)
        for nome, _ in pairs(sel) do UTIL.alvo_tp = nome end
    end)
    Players.PlayerAdded:Connect(function() task.wait(1) if ddTP then ddTP:refresh(listarPlayers()) end end)
    Players.PlayerRemoving:Connect(function() task.wait(0.5) if ddTP then ddTP:refresh(listarPlayers()) end end)

    tabUtil:Button("TELEPORTAR pro alvo", function()
        if UTIL.alvo_tp and getgenv().UTIL_TP_PLAYER then
            getgenv().UTIL_TP_PLAYER(UTIL.alvo_tp)
        end
    end)
    tabUtil:Button("Salvar Posicao", function() if getgenv().UTIL_SALVAR then getgenv().UTIL_SALVAR() end end)
    tabUtil:Button("Voltar Posicao", function() if getgenv().UTIL_VOLTAR then getgenv().UTIL_VOLTAR() end end)
    tabUtil:Button("Salvar Config", function() if getgenv().UTIL_SALVAR_CONFIG then getgenv().UTIL_SALVAR_CONFIG() end end)
    tabUtil:Button("Carregar Config", function() if getgenv().UTIL_CARREGAR_CONFIG then getgenv().UTIL_CARREGAR_CONFIG() end end)
end

if FARM then
    local tabFarm = Window:CreateTab("Farm")
    tabFarm:Toggle("Auto ATM (perto)", "Quebra ATM quando tu ta perto", FARM.auto_atm, function(v) FARM.auto_atm = v end)
    tabFarm:Slider("Delay Quebra x10", "Espera entre quebras", 5, 50, FARM.delay*10, 1, function(v) FARM.delay = v/10 end)
    tabFarm:Toggle("Walk Auto ATM", "Anda sozinho ate o ATM", FARM.walk_atm, function(v) FARM.walk_atm = v end)
    tabFarm:Slider("Walk Speed", "35 = seguro", 12, 60, FARM.walk_speed or 35, 1, function(v) FARM.walk_speed = v end)
    tabFarm:Toggle("Panic Staff", "Desliga tudo se detectar staff", FARM.panic_staff, function(v) FARM.panic_staff = v end)
end

if REV then
    local tabRev = Window:CreateTab("Revistar")
    tabRev:Toggle("Auto Revistar", "Envia /revistar no proximo", REV.ativo, function(v) REV.ativo = v end)
    tabRev:Slider("Distancia", "Studs", 5, 50, REV.distancia, 1, function(v) REV.distancia = v end)
    tabRev:Slider("Delay", "Segundos", 1, 15, REV.delay, 1, function(v) REV.delay = v end)
    tabRev:Button("Testar Chat", function() if getgenv().REVISTAR_TESTAR then getgenv().REVISTAR_TESTAR() end end)
    tabRev:Button("Limpar Lista", function() if getgenv().REVISTAR_LIMPAR then getgenv().REVISTAR_LIMPAR() end end)
end

if PERF then
    local tabPerf = Window:CreateTab("Perf")
    tabPerf:Toggle("Mostrar FPS/Ping/RAM", "HUD na tela", PERF.ativo, function(v) PERF.ativo = v end)
end

local tabInfo = Window:CreateTab("Info")
tabInfo:Paragraph("Delta Hub v3\nAutor: pablocachorreira165")
