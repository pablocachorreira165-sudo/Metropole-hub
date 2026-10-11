-- revistar.lua | Auto /revistar em quem ta perto
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = workspace
local LP = Players.LocalPlayer

local CFG = getgenv().REVISTAR_CFG or {
    ativo = false,
    distancia = 15,
    delay = 3,
    comando = "/revistar",
    ja_revistados = {},
}
getgenv().REVISTAR_CFG = CFG
if not CFG.ja_revistados then CFG.ja_revistados = {} end

local ultimo_envio = 0

-- envia mensagem no chat
local function enviarChat(msg)
    local RS = game:GetService("ReplicatedStorage")
    -- chat antigo (DefaultChatSystemChatEvents)
    local chatEvents = RS:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        local sayReq = chatEvents:FindFirstChild("SayMessageRequest")
        if sayReq then
            local ok = pcall(function()
                sayReq:FireServer(msg, "All")
            end)
            if ok then return true end
        end
    end
    return false
end

-- testa se o chat funciona ao ligar
getgenv().REVISTAR_TESTAR = function()
    local ok = enviarChat("/revistar")
    if ok then
        print("[REVISTAR] chat OK")
        return true
    else
        warn("[REVISTAR] chat nao disponivel (jogo usa TextChatService novo)")
        return false
    end
end

-- limpa lista (pode revistar de novo)
getgenv().REVISTAR_LIMPAR = function()
    CFG.ja_revistados = {}
    print("[REVISTAR] lista limpa")
end

RunService.Heartbeat:Connect(function()
    if not CFG.ativo then return end
    local agora = tick()
    if agora - ultimo_envio < CFG.delay then return end

    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local melhor, melhor_d = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not CFG.ja_revistados[plr.Name] then
            local c = plr.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (r.Position - hrp.Position).Magnitude
                if d <= CFG.distancia and d < melhor_d then
                    melhor_d = d
                    melhor = plr
                end
            end
        end
    end

    if melhor then
        local msg = CFG.comando .. " " .. melhor.Name
        if enviarChat(msg) then
            CFG.ja_revistados[melhor.Name] = true
            ultimo_envio = agora
            print("[REVISTAR] " .. msg)
        end
    end
end)

print("[REVISTAR] carregado")
