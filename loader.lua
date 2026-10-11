local BASE = "https://raw.githubusercontent.com/pablocachorreira165-sudo/Metropole-hub/main/"

local function carregar(nome)
    local ok, err = pcall(function()
        local code = game:HttpGet(BASE .. nome .. ".lua")
        local func = loadstring(code)
        if func then func() end
    end)
    if ok then print("[HUB] " .. nome .. " ok")
    else warn("[HUB] erro em " .. nome .. ": " .. tostring(err)) end
end

task.spawn(function()
    carregar("esp")      task.wait(0.4)
    carregar("aim")      task.wait(0.4)
    carregar("movement") task.wait(0.4)
    carregar("world")    task.wait(0.4)
    carregar("utility")  task.wait(0.4)
    carregar("farm")     task.wait(0.4)
    carregar("trigger")  task.wait(0.4)
    carregar("revistar") task.wait(0.4)
    carregar("uilib")    task.wait(0.4)
    carregar("menu")     task.wait(0.3)
    print("[HUB] tudo carregado")
end)
