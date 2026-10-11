-- perf.lua | FPS / Ping / Memoria na tela
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local CFG = getgenv().PERF_CFG or { ativo = false }
getgenv().PERF_CFG = CFG

local gui = Instance.new("ScreenGui")
gui.Name = "PerfHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 200
gui.Parent = LP:WaitForChild("PlayerGui")

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0, 220, 0, 56)
lbl.Position = UDim2.new(0, 10, 0, 170)
lbl.BackgroundColor3 = Color3.fromRGB(0,0,0)
lbl.BackgroundTransparency = 0.4
lbl.TextColor3 = Color3.fromRGB(0,255,100)
lbl.TextSize = 12
lbl.Font = Enum.Font.Code
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.TextYAlignment = Enum.TextYAlignment.Top
lbl.Text = ""
lbl.Visible = false
lbl.Parent = gui
local lc = Instance.new("UICorner"); lc.CornerRadius = UDim.new(0,6); lc.Parent = lbl

local fps_count = 0
local fps_time = tick()
local fps_val = 0

RunService.Heartbeat:Connect(function()
    fps_count = fps_count + 1
    local agora = tick()
    if agora - fps_time >= 1 then
        fps_val = fps_count
        fps_count = 0
        fps_time = agora
    end
end)

RunService.RenderStepped:Connect(function()
    if not CFG.ativo then lbl.Visible = false return end
    lbl.Visible = true

    local ping = 0
    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)

    local memoria = 0
    pcall(function() memoria = math.floor(Stats:GetTotalMemoryUsageMb()) end)

    lbl.Text = "FPS: " .. fps_val .. "\nPing: " .. ping .. "ms\nRAM: " .. memoria .. "MB"
end)

print("[PERF] carregado")
