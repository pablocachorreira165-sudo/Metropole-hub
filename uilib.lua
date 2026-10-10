--[[
    MinhaUILib - Biblioteca de UI própria para Delta Executor
    Visual inspirado na WindUI, código 100% original
    Suporte: PC e Mobile (toque)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local CORES = {
    Fundo = Color3.fromRGB(15, 15, 20),
    Borda = Color3.fromRGB(0, 180, 240),
    AbaAtiva = Color3.fromRGB(0, 150, 200),
    AbaInativa = Color3.fromRGB(30, 30, 40),
    TextoAbaAtiva = Color3.fromRGB(255, 255, 255),
    TextoAbaInativa = Color3.fromRGB(150, 150, 150),
    Elemento = Color3.fromRGB(22, 22, 30),
    Texto = Color3.fromRGB(255, 255, 255),
    TextoDesc = Color3.fromRGB(150, 150, 150),
    Verde = Color3.fromRGB(0, 200, 100),
    Cinza = Color3.fromRGB(60, 60, 60),
}

local FONTES = {
    Titulo = Enum.Font.GothamBold,
    Elemento = Enum.Font.GothamMedium,
    Descricao = Enum.Font.Gotham,
}

local function CriarInstancia(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

-- ==================== ELEMENTO BASE ====================
local ElementoBase = {}
ElementoBase.__index = ElementoBase

function ElementoBase:novo(parent, titulo, descricao, altura)
    local self = setmetatable({}, ElementoBase)
    self.Altura = altura or 50

    self.Container = CriarInstancia("Frame", {
        Parent = parent,
        BackgroundColor3 = CORES.Elemento,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, self.Altura),
    })

    CriarInstancia("UICorner", {
        Parent = self.Container,
        CornerRadius = UDim.new(0, 8),
    })

    if titulo then
        self.Titulo = CriarInstancia("TextLabel", {
            Parent = self.Container,
            BackgroundTransparency = 1,
            Font = FONTES.Elemento,
            Text = titulo,
            TextColor3 = CORES.Texto,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 15, 0, 5),
            Size = UDim2.new(1, -30, 0, 20),
        })
    end

    if descricao then
        self.Descricao = CriarInstancia("TextLabel", {
            Parent = self.Container,
            BackgroundTransparency = 1,
            Font = FONTES.Descricao,
            Text = descricao,
            TextColor3 = CORES.TextoDesc,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 15, 0, 25),
            Size = UDim2.new(1, -30, 0, 15),
        })
    end

    return self
end

-- ==================== TOGGLE ====================
local Toggle = setmetatable({}, {__index = ElementoBase})
Toggle.__index = Toggle

function Toggle:novo(parent, titulo, descricao, padrao, callback)
    local self = ElementoBase:novo(parent, titulo, descricao, 50)
    setmetatable(self, Toggle)

    self.Valor = padrao or false
    self.Callback = callback or function() end

    self.FundoSwitch = CriarInstancia("Frame", {
        Parent = self.Container,
        BackgroundColor3 = CORES.Cinza,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -55, 0, 15),
        Size = UDim2.new(0, 40, 0, 20),
    })

    CriarInstancia("UICorner", { Parent = self.FundoSwitch, CornerRadius = UDim.new(1, 0) })

    self.Bolinha = CriarInstancia("Frame", {
        Parent = self.FundoSwitch,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(0, 16, 0, 16),
    })

    CriarInstancia("UICorner", { Parent = self.Bolinha, CornerRadius = UDim.new(1, 0) })

    local Input = CriarInstancia("TextButton", {
        Parent = self.FundoSwitch,
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
    })

    Input.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            self:alternar()
        end
    end)

    self:atualizarVisual(true)
    return self
end

function Toggle:alternar()
    self.Valor = not self.Valor
    self:atualizarVisual(false)
    self.Callback(self.Valor)
end

function Toggle:atualizarVisual(inst)
    local cor = self.Valor and CORES.Verde or CORES.Cinza
    local pos = self.Valor and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    if inst then
        self.FundoSwitch.BackgroundColor3 = cor
        self.Bolinha.Position = pos
    else
        TweenService:Create(self.FundoSwitch, TweenInfo.new(0.15), {BackgroundColor3 = cor}):Play()
        TweenService:Create(self.Bolinha, TweenInfo.new(0.15), {Position = pos}):Play()
    end
end

-- ==================== SLIDER ====================
local Slider = setmetatable({}, {__index = ElementoBase})
Slider.__index = Slider

function Slider:novo(parent, titulo, descricao, min, max, padrao, step, callback)
    local self = ElementoBase:novo(parent, titulo, descricao, 78)
    setmetatable(self, Slider)

    self.Min = min or 0
    self.Max = max or 100
    self.Step = step or 1
    self.Valor = padrao or min
    self.Callback = callback or function() end
    self.Arrastando = false

    self.LabelValor = CriarInstancia("TextLabel", {
        Parent = self.Container,
        BackgroundTransparency = 1,
        Font = FONTES.Elemento,
        Text = tostring(self.Valor),
        TextColor3 = CORES.Borda,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.new(1, -55, 0, 5),
        Size = UDim2.new(0, 40, 0, 20),
    })

    self.AreaToque = CriarInstancia("TextButton", {
        Parent = self.Container,
        BackgroundTransparency = 1,
        Text = "",
        Position = UDim2.new(0, 15, 0, 32),
        Size = UDim2.new(1, -30, 0, 44),
    })

    self.Trilha = CriarInstancia("Frame", {
        Parent = self.AreaToque,
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 4),
    })

    CriarInstancia("UICorner", { Parent = self.Trilha, CornerRadius = UDim.new(1, 0) })

    self.Preenchimento = CriarInstancia("Frame", {
        Parent = self.Trilha,
        BackgroundColor3 = CORES.Borda,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
    })

    CriarInstancia("UICorner", { Parent = self.Preenchimento, CornerRadius = UDim.new(1, 0) })

    self.Bolinha = CriarInstancia("Frame", {
        Parent = self.AreaToque,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 17),
        Size = UDim2.new(0, 10, 0, 10),
        ZIndex = 2,
    })

    CriarInstancia("UICorner", { Parent = self.Bolinha, CornerRadius = UDim.new(1, 0) })

    self.AreaToque.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Arrastando = true
            self:atualizarPosicao(i.Position)
        end
    end)

    self.AreaToque.InputChanged:Connect(function(i)
        if self.Arrastando and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            self:atualizarPosicao(i.Position)
        end
    end)

    self.AreaToque.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Arrastando = false
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if self.Arrastando and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            self:atualizarPosicao(i.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Arrastando = false
        end
    end)

    self:setValor(self.Valor)
    return self
end

function Slider:atualizarPosicao(pos)
    local abs = self.Trilha.AbsolutePosition
    local tam = self.Trilha.AbsoluteSize.X
    if tam <= 0 then return end

    local pct = math.clamp((pos.X - abs.X) / tam, 0, 1)
    local valor = self.Min + (self.Max - self.Min) * pct
    if self.Step > 0 then
        valor = math.floor(valor / self.Step + 0.5) * self.Step
    end
    valor = math.clamp(valor, self.Min, self.Max)

    self:setValor(valor)
    self.Callback(self.Valor)
end

function Slider:setValor(v)
    self.Valor = v
    local pct = (v - self.Min) / (self.Max - self.Min)
    self.Preenchimento.Size = UDim2.new(pct, 0, 1, 0)
    self.Bolinha.Position = UDim2.new(pct, -5, 0, 17)
    if self.Step and self.Step >= 1 then
        self.LabelValor.Text = tostring(math.floor(v))
    else
        self.LabelValor.Text = string.format("%.1f", v)
    end
end

-- ==================== BUTTON ====================
local Botao = setmetatable({}, {__index = ElementoBase})
Botao.__index = Botao

function Botao:novo(parent, titulo, callback)
    local self = ElementoBase:novo(parent, nil, nil, 46)
    setmetatable(self, Botao)

    self.Callback = callback or function() end

    self.BotaoVisual = CriarInstancia("TextButton", {
        Parent = self.Container,
        BackgroundColor3 = CORES.Borda,
        BorderSizePixel = 0,
        Font = FONTES.Elemento,
        Text = titulo,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 0, 30),
    })

    CriarInstancia("UICorner", { Parent = self.BotaoVisual, CornerRadius = UDim.new(0, 6) })

    self.BotaoVisual.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            self.BotaoVisual.BackgroundColor3 = CORES.AbaAtiva
            task.wait(0.08)
            self.BotaoVisual.BackgroundColor3 = CORES.Borda
            self.Callback()
        end
    end)

    return self
end

-- ==================== PARAGRAPH ====================
local Paragrafo = setmetatable({}, {__index = ElementoBase})
Paragrafo.__index = Paragrafo

function Paragrafo:novo(parent, texto)
    local self = ElementoBase:novo(parent, nil, nil, 0)
    setmetatable(self, Paragrafo)

    self.Container.AutomaticSize = Enum.AutomaticSize.Y

    self.Texto = CriarInstancia("TextLabel", {
        Parent = self.Container,
        BackgroundTransparency = 1,
        Font = FONTES.Descricao,
        Text = texto,
        TextColor3 = CORES.TextoDesc,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(1, -20, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    return self
end

-- ==================== DROPDOWN ====================
local Dropdown = setmetatable({}, {__index = ElementoBase})
Dropdown.__index = Dropdown

function Dropdown:novo(parent, titulo, valores, multi, callback)
    local self = ElementoBase:novo(parent, nil, nil, 0)
    setmetatable(self, Dropdown)

    self.Valores = valores or {}
    self.Multi = multi or false
    self.Callback = callback or function() end
    self.Selecionados = {}
    self.Expandido = false

    self.Container.AutomaticSize = Enum.AutomaticSize.Y

    self.BotaoPrincipal = CriarInstancia("TextButton", {
        Parent = self.Container,
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BorderSizePixel = 0,
        Font = FONTES.Elemento,
        Text = titulo or "Selecione...",
        TextColor3 = CORES.Texto,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 0, 34),
    })

    CriarInstancia("UICorner", { Parent = self.BotaoPrincipal, CornerRadius = UDim.new(0, 6) })
    CriarInstancia("UIPadding", { Parent = self.BotaoPrincipal, PaddingLeft = UDim.new(0, 10) })

    self.Seta = CriarInstancia("TextLabel", {
        Parent = self.BotaoPrincipal,
        BackgroundTransparency = 1,
        Font = FONTES.Elemento,
        Text = "v",
        TextColor3 = CORES.TextoDesc,
        TextSize = 12,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
    })

    self.FrameOpcoes = CriarInstancia("Frame", {
        Parent = self.Container,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 46),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
    })

    CriarInstancia("UIListLayout", {
        Parent = self.FrameOpcoes,
        Padding = UDim.new(0, 2),
    })

    self.BotaoPrincipal.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            self:alternar()
        end
    end)

    self:refresh(self.Valores)
    return self
end

function Dropdown:alternar()
    self.Expandido = not self.Expandido
    self.FrameOpcoes.Visible = self.Expandido
    self.Seta.Text = self.Expandido and "^" or "v"
end

function Dropdown:refresh(novos)
    self.Valores = novos or self.Valores
    for _, f in ipairs(self.FrameOpcoes:GetChildren()) do
        if f:IsA("TextButton") then f:Destroy() end
    end

    for _, v in ipairs(self.Valores) do
        local opc = CriarInstancia("TextButton", {
            Parent = self.FrameOpcoes,
            BackgroundColor3 = Color3.fromRGB(35, 35, 45),
            BorderSizePixel = 0,
            Font = FONTES.Elemento,
            Text = (self.Selecionados[v] and "[X] " or "[  ] ") .. tostring(v),
            TextColor3 = CORES.Texto,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 28),
        })

        CriarInstancia("UICorner", { Parent = opc, CornerRadius = UDim.new(0, 4) })
        CriarInstancia("UIPadding", { Parent = opc, PaddingLeft = UDim.new(0, 8) })

        opc.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                self:selecionar(v, opc)
            end
        end)
    end
end

function Dropdown:selecionar(v, opc)
    if self.Multi then
        if self.Selecionados[v] then
            self.Selecionados[v] = nil
            opc.Text = "[  ] " .. tostring(v)
        else
            self.Selecionados[v] = true
            opc.Text = "[X] " .. tostring(v)
        end
    else
        for _, f in ipairs(self.FrameOpcoes:GetChildren()) do
            if f:IsA("TextButton") then
                f.Text = "[  ] " .. f.Text:gsub("%[[X ]+%] ", "")
            end
        end
        self.Selecionados = {[v] = true}
        opc.Text = "[X] " .. tostring(v)
        self.BotaoPrincipal.Text = tostring(v)
        self:alternar()
    end
    self.Callback(self.Selecionados)
end

-- ==================== ABA ====================
local Aba = {}
Aba.__index = Aba

function Aba:novo(parentBarra, parentConteudo, titulo, janelaRef)
    local self = setmetatable({}, Aba)
    self.Titulo = titulo
    self.JanelaRef = janelaRef

    self.Botao = CriarInstancia("TextButton", {
        Parent = parentBarra,
        BackgroundColor3 = CORES.AbaInativa,
        BorderSizePixel = 0,
        Font = FONTES.Elemento,
        Text = titulo,
        TextColor3 = CORES.TextoAbaInativa,
        TextSize = 13,
        Size = UDim2.new(0, 90, 0, 30),
    })

    CriarInstancia("UICorner", { Parent = self.Botao, CornerRadius = UDim.new(0, 6) })

    self.Conteudo = CriarInstancia("ScrollingFrame", {
        Parent = parentConteudo,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -16, 1, -8),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = CORES.Borda,
        Visible = false,
    })

    CriarInstancia("UIListLayout", {
        Parent = self.Conteudo,
        Padding = UDim.new(0, 6),
    })

    self.Botao.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            self.JanelaRef:ativarAba(self)
        end
    end)

    return self
end

function Aba:Toggle(t, d, p, cb) return Toggle:novo(self.Conteudo, t, d, p, cb) end
function Aba:Slider(t, d, mn, mx, p, s, cb) return Slider:novo(self.Conteudo, t, d, mn, mx, p, s, cb) end
function Aba:Button(t, cb) return Botao:novo(self.Conteudo, t, cb) end
function Aba:Paragraph(txt) return Paragrafo:novo(self.Conteudo, txt) end
function Aba:Dropdown(t, v, m, cb) return Dropdown:novo(self.Conteudo, t, v, m, cb) end

-- ==================== JANELA ====================
local Janela = {}
Janela.__index = Janela

function Janela:novo(nomeHub, autor)
    local self = setmetatable({}, Janela)
    self.Abas = {}

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    self.ScreenGui = CriarInstancia("ScreenGui", {
        Parent = playerGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 2147483647,
    })

    self.BotaoFlutuante = CriarInstancia("TextButton", {
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 55, 0, 55),
        Position = UDim2.new(1, -70, 0, 150),
        BackgroundColor3 = CORES.Fundo,
        BackgroundTransparency = 0.1,
        Text = "HUB",
        TextColor3 = CORES.Borda,
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        ZIndex = 10,
    })

    CriarInstancia("UICorner", { Parent = self.BotaoFlutuante, CornerRadius = UDim.new(1, 0) })
    CriarInstancia("UIStroke", { Parent = self.BotaoFlutuante, Color = CORES.Borda, Thickness = 2 })

    self.Janela = CriarInstancia("Frame", {
        Parent = self.ScreenGui,
        BackgroundColor3 = CORES.Fundo,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -180, 0.5, -170),
        Size = UDim2.new(0, 360, 0, 340),
        Visible = false,
        ZIndex = 5,
    })

    CriarInstancia("UICorner", { Parent = self.Janela, CornerRadius = UDim.new(0, 14) })
    CriarInstancia("UIStroke", { Parent = self.Janela, Color = CORES.Borda, Thickness = 1.5 })

    self.BarraTitulo = CriarInstancia("Frame", {
        Parent = self.Janela,
        BackgroundColor3 = CORES.AbaInativa,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 6,
    })

    CriarInstancia("UICorner", { Parent = self.BarraTitulo, CornerRadius = UDim.new(0, 14) })

    CriarInstancia("TextLabel", {
        Parent = self.BarraTitulo,
        BackgroundTransparency = 1,
        Font = FONTES.Titulo,
        Text = nomeHub,
        TextColor3 = CORES.Texto,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 14, 0, 6),
        Size = UDim2.new(1, -60, 0, 20),
        ZIndex = 7,
    })

    CriarInstancia("TextLabel", {
        Parent = self.BarraTitulo,
        BackgroundTransparency = 1,
        Font = FONTES.Descricao,
        Text = autor or "",
        TextColor3 = CORES.TextoDesc,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 14, 0, 24),
        Size = UDim2.new(1, -60, 0, 12),
        ZIndex = 7,
    })

    local btnFechar = CriarInstancia("TextButton", {
        Parent = self.BarraTitulo,
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -32, 0, 7),
        BackgroundColor3 = Colo
