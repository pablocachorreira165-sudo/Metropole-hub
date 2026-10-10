-- loader.lua | Metropole-hub
local BASE = "https://raw.githubusercontent.com/pablocachorreira165-sudo/Metropole-hub/main/"

local function carregar(nome)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(BASE .. nome .. ".lua"))()
    end)
    if ok then
        print("[HUB] " .. nome .. " ok")
    else
        warn("[HUB] erro em " .. nome .. ": " .. tostring(err))
    end
end

task.spawn(function()
    carregar("esp")
    task.wait(0.5)
    carregar("aim")
    task.wait(0.5)
    carregar("movement")
    task.wait(0.5)
    carregar("world")
    task.wait(0.5)
    carregar("uilib")
    task.wait(0.5)
    carregar("menu")
    task.wait(0.3)
    print("[HUB] tudo carregado")
end)
