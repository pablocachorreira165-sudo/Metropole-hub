-- revistar.lua | Auto /revistar (TextChatService - chat novo)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TCS = game:GetService("TextChatService")
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

-- pega o canal de chat principal
local function pegarCanal()
    local tc = TCS:FindFirstChild("TextChannels")
    if not tc then return nil end
    -- tenta o general primeiro
    local geral = tc:FindFirstChild("RBXGeneral")
    if geral then return geral end
    -- senao pega o primeiro
    for _, c in ipairs(tc:GetChildren()) do
        if c:IsA("TextChannel") then return c end
    end
    return nil
end

-- envia mensagem no chat novo
local function enviar(msg)
    local canal = pegarCanal()
    if not canal then return false end
    local ok = pcall(function()
        canal:SendAsync(msg)
    end)
    return ok
end

getgenv().REVISTAR_TESTAR = function()
    local ok = enviar("teste")
    if ok then
        print("[REVISTAR] chat OK (TextChatService)")
        return true
    else
        print("[REVISTAR] chat falhou")
        return false
    end
end

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
        if enviar(msg) then
            CFG.ja_revistados[melhor.Name] = true
            ultimo_envio = agora
            print("[REVISTAR] " .. msg)
        end
    end
end)

print("[REVISTAR] carregado v2 (TextChatService)")
