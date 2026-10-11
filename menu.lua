-- REVISTAR
if getgenv().REVISTAR_CFG then
    local R = getgenv().REVISTAR_CFG
    local tabRev = Window:CreateTab("Revistar")

    tabRev:Toggle("Auto Revistar", "Envia /revistar no player mais proximo", R.ativo, function(v) R.ativo = v end)
    tabRev:Slider("Distancia", "Studs", 5, 50, R.distancia, 1, function(v) R.distancia = v end)
    tabRev:Slider("Delay", "Segundos entre cada revistar", 1, 15, R.delay, 1, function(v) R.delay = v end)

    tabRev:Paragraph("O script vai pegar o nome do player mais proximo e digitar /revistar NOME no chat automaticamente.")

    tabRev:Button("Testar chat", function()
        if getgenv().REVISTAR_TESTAR then getgenv().REVISTAR_TESTAR() end
    end)

    tabRev:Button("Limpar lista", function()
        if getgenv().REVISTAR_LIMPAR then getgenv().REVISTAR_LIMPAR() end
    end)

    tabRev:Paragraph("Se 'chat nao disponivel', o jogo usa o chat novo do Roblox e o script nao funciona.")
end
