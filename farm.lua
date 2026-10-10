local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = workspace
local LP = Players.LocalPlayer

local CFG = getgenv().FARM_CFG or {auto_prompt=false,auto_collect=false,raio=25,delay=0.3}
getgenv().FARM_CFG = CFG

local ultimo = 0

local function disparar(prompt)
    if fireproximityprompt then
        pcall(function() fireproximityprompt(prompt) end)
        return true
    end
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration or 0.1)
        prompt:InputHoldEnd()
    end)
    return true
end

RunService.Heartbeat:Connect(function()
    if not (CFG.auto_prompt or CFG.auto_collect) then return end
    local agora = tick()
    if agora - ultimo < CFG.delay then return end
    ultimo = agora
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local parent = obj.Parent
            local pos = parent and (parent:IsA("BasePart") and parent.Position or (parent:IsA("Model") and parent:GetPivot().Position))
            if pos and (pos - hrp.Position).Magnitude <= CFG.raio then
                if CFG.auto_prompt then
                    disparar(obj)
                    task.wait(0.1)
                end
                if CFG.auto_collect then
                    local n = (obj.ActionText or ""):lower()
                    if n:find("pegar") or n:find("coletar") or n:find("collect") or n:find("pick") then
                        disparar(obj)
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end)

print("[FARM] carregado")
