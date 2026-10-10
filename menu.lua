--[[
    menu.lua - Interface para Metrópole RP
    Usa MinhaUILib criada anteriormente
]]

if not getgenv().MinhaUILib then
    warn("[HUB] MinhaUILib não encontrada. Carregue a uilib.lua primeiro!")
    return
end

if not getgenv().AIM_CFG then
    warn("[HUB] AIM_CFG não encontrada!")
    return
end

if not getgenv().ESP_CFG then
    warn("[HUB] ESP_CFG não encontrada!")
    return
end

if not getgenv().MOVE_CFG then
    warn("[HUB] MOVE_CFG não encontrada!")
    return
end

if not getgenv().WORLD_CFG then
    warn("[HUB] WORLD_CFG não encontrada!")
    return
end

local AIM = getgenv().AIM_CFG
local ESP = getgenv().ESP_CFG
local MOVE = getgenv().MOVE_CFG
local WORLD = getgenv().WORLD_CFG

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Cria a janela (corrigido: dois pontos + tabela)
local Janela = getgenv().MinhaUILib:CreateWindow({
    Title = "Delta Hub",
    Author = "Metrópole RP",
})

-- Botao flutuante: NAO precisa chamar (a uilib ja cria sozinha)

-- ============================================================
-- ABA SEGURANÇA
-- ============================================================
local AbaSeguranca = Janela:CreateTab("Segurança")

AbaSeguranca:Toggle("Modo Seguro", "Ativa proteção automática", MOVE.safe_mode, function(valor)
    MOVE.safe_mode = valor
end)

AbaSeguranca:Slider("Raio de Detecção", "Distância para detectar ameaças", 20, 300, MOVE.safe_radius, 10, function(valor)
    MOVE.safe_radius = valor
end)

AbaSeguranca:Paragraph("O modo seguro monitora jogadores próximos e reage a possíveis ameaças automaticamente.")

-- ============================================================
-- ABA COMBAT
-- ============================================================
local AbaCombat = Janela:CreateTab("Combat")

AbaCombat:Toggle("Aimbot", "Ativa mira automática", AIM.ativo, function(valor)
    AIM.ativo = valor
end)

AbaCombat:Toggle("Team Check", "Não mira em aliados", AIM.team_check, function(valor)
    AIM.team_check = valor
end)

local function obterJogadores()
    local lista = {}
    for _, jogador in ipairs(Players:GetPlayers()) do
        if jogador ~= LocalPlayer then
            table.insert(lista, jogador.Name)
        end
    end
    return lista
end

local DropdownAmigos = AbaCombat:Dropdown("Amigos (não mirar)", obterJogadores(), true, function(selecionados)
    AIM.amigos = selecionados
end)

Players.PlayerAdded:Connect(function()
    task.wait(1)
    DropdownAmigos:refresh(obterJogadores())
end)

Players.PlayerRemoving:Connect(function()
    task.wait(1)
    DropdownAmigos:refresh(obterJogadores())
end)

AbaCombat:Slider("Aim FOV", "Campo de visão da mira", 5, 90, AIM.fov, 5, function(valor)
    AIM.fov = valor
end)

AbaCombat:Slider("Smoothing", "Suavidade da mira (0-1)", 0, 100, AIM.smoothing * 100, 5, function(valor)
    AIM.smoothing = valor / 100
end)

AbaCombat:Slider("Distância Máxima", "Alcance máximo da mira", 100, 2000, AIM.max_dist, 100, function(valor)
    AIM.max_dist = valor
end)

-- ============================================================
-- ABA ESP
-- ============================================================
local AbaESP = Janela:CreateTab("ESP")

AbaESP:Toggle("Box ESP", "Caixa ao redor dos jogadores", ESP.box, function(valor) ESP.box = valor end)
AbaESP:Toggle("Line ESP", "Linha até os jogadores", ESP.line, function(valor) ESP.line = valor end)
AbaESP:Toggle("Name ESP", "Mostra nomes", ESP.name, function(valor) ESP.name = valor end)
AbaESP:Toggle("Distance ESP", "Mostra distância", ESP.dist, function(valor) ESP.dist = valor end)
AbaESP:Toggle("Chams", "Ver através de paredes", ESP.chams, function(valor) ESP.chams = valor end)

-- ============================================================
-- ABA MOVEMENT
-- ============================================================
local AbaMovement = Janela:CreateTab("Movement")

AbaMovement:Toggle("Speed Hack", "Aumenta velocidade", MOVE.speed_on, function(valor) MOVE.speed_on = valor end)
AbaMovement:Slider("Velocidade", "Velocidade do jogador", 12, 100, MOVE.speed, 2, function(valor) MOVE.speed = valor end)
AbaMovement:Toggle("Fly", "Ativa modo voo", MOVE.fly, function(valor) MOVE.fly = valor end)
AbaMovement:Slider("Fly Speed x10", "Velocidade do voo", 5, 50, MOVE.fly_speed * 10, 1, function(valor) MOVE.fly_speed = valor / 10 end)
AbaMovement:Toggle("Noclip", "Atravessa paredes", MOVE.noclip, function(valor) MOVE.noclip = valor end)
AbaMovement:Toggle("Infinite Jump", "Pulo infinito", MOVE.inf_jump, function(valor) MOVE.inf_jump = valor end)

-- ============================================================
-- ABA WORLD
-- ============================================================
local AbaWorld = Janela:CreateTab("World")

AbaWorld:Toggle("Fullbright", "Ilumina todo o mapa", WORLD.fullbright, function(valor) WORLD.fullbright = valor end)
AbaWorld:Toggle("No Fog", "Remove névoa", WORLD.no_fog, function(valor) WORLD.no_fog = valor end)
AbaWorld:Slider("Hora do Dia", "Altera hora do jogo", 0, 24, WORLD.hora, 1, function(valor) WORLD.hora = valor end)

-- ============================================================
-- ABA INFO
-- ============================================================
local AbaInfo = Janela:CreateTab("Info")

AbaInfo:Paragraph("Delta Hub v1.0\n\nHub completo para Metrópole RP\nFeito com MinhaUILib\n\nUse com responsabilidade")

print("[HUB] Menu carregado com sucesso!")
