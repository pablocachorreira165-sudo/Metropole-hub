-- world.lua | Modulo de ambiente
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local CFG = getgenv().WORLD_CFG or {
    fullbright = false, no_fog = false, hora = 14
}
getgenv().WORLD_CFG = CFG

RunService.Heartbeat:Connect(function()
    if CFG.fullbright then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.GlobalShadows = false
    end
    if CFG.no_fog then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    end
    Lighting.ClockTime = CFG.hora
end)

print("[WORLD] carregado")
