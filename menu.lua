-- ============ UTILIDADE ============
local UTIL = getgenv().UTIL_CFG
if UTIL then
    local tabUtil = Window:CreateTab("Util")
    tabUtil:Toggle("Anti-AFK", "Nao e kickado por inatividade", UTIL.anti_afk, function(v) UTIL.anti_afk = v end)
    tabUtil:Toggle("Coordenadas", "X, Y, Z na tela", UTIL.coords, function(v) UTIL.coords = v end)
    tabUtil:Slider("FOV camera", "40-120", 40, 120, UTIL.fov, 5, function(v) UTIL.fov = v end)
    tabUtil:Button("Salvar Posicao", function()
        if getgenv().UTIL_SALVAR() then print("[UTIL] pos salva") end
    end)
    tabUtil:Button("Voltar pra Posicao", function()
        if getgenv().UTIL_VOLTAR() then print("[UTIL] teleportado") end
    end)
    tabUtil:Button("Salvar Config", function()
        if getgenv().UTIL_SALVAR_CONFIG() then print("[UTIL] config salva") end
    end)
    tabUtil:Button("Carregar Config", function()
        if getgenv().UTIL_CARREGAR_CONFIG() then print("[UTIL] config carregada") end
    end)
end

-- ============ FARM ============
local FARM = getgenv().FARM_CFG
if FARM then
    local tabFarm = Window:CreateTab("Farm")
    tabFarm:Toggle("Auto Prompt", "Dispara ProximityPrompt automatico", FARM.auto_prompt, function(v) FARM.auto_prompt = v end)
    tabFarm:Toggle("Auto Coletar", "Só pega itens", FARM.auto_collect, function(v) FARM.auto_collect = v end)
    tabFarm:Slider("Raio", "Studs de alcance", 5, 100, FARM.raio, 5, function(v) FARM.raio = v end)
    tabFarm:Slider("Delay", "Espera entre acoes (x10)", 1, 20, FARM.delay * 10, 1, function(v) FARM.delay = v / 10 end)
end
