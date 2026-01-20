-- Library.lua
-- GekyuUI - Versão FINAL corrigida + DRAG DUPLO (topo + base)
-- Kyuzzy - Atualizado 16/01/2026

local Library = {}
Library.__index = Library

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

-- Destroi UI antiga se existir
if CoreGui:FindFirstChild("GekyuPremiumUI") then
    CoreGui.GekyuPremiumUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GekyuPremiumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = CoreGui

-- Cores globais
local COLORS = {
    Background    = Color3.fromRGB(5, 5, 10),
    Accent        = Color3.fromRGB(90, 170, 255),
    AccentPress   = Color3.fromRGB(110, 190, 255),
    Element       = Color3.fromRGB(18, 18, 28),
    ElementHover  = Color3.fromRGB(28, 28, 44),
    Text          = Color3.fromRGB(235, 235, 245),
    TextDim       = Color3.fromRGB(150, 150, 175),
    Stroke        = Color3.fromRGB(50, 50, 75),
}

local CORNERS = {
    Medium = UDim.new(0, 10),
    Large  = UDim.new(0, 14),
    Small  = UDim.new(0, 6),
}

-- Última posição salva do painel de config
local lastConfigPosition = UDim2.new(0.5, -200, 0.5, -250)

-- Tween seguro
local function safeTween(obj, tweenInfo, properties)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, tweenInfo, properties):Play()
end

-- TextLabel inteligente
local function CreateSmartTextLabel(parent, size, pos, text, color, font, textSize, alignmentX, alignmentY)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = pos
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or COLORS.Text
    label.Font = font or Enum.Font.GothamBold
    label.TextSize = textSize or 14
    label.TextXAlignment = alignmentX or Enum.TextXAlignment.Left
    label.TextYAlignment = alignmentY or Enum.TextYAlignment.Center
    label.TextWrapped = true
    label.TextTruncate = Enum.TextTruncate.SplitWord
    label.ZIndex = 10
    label.Parent = parent

    task.spawn(function()
        task.wait()
        local maxWidth = label.AbsoluteSize.X - 20
        if maxWidth > 10 and label.TextBounds.X > maxWidth then
            local scale = maxWidth / label.TextBounds.X
            label.TextSize = math.max(8, math.floor(label.TextSize * scale * 0.92))
        end
    end)

    return label
end

local function LimitDropdownText(text)
    if #text > 30 then
        return text:sub(1, 27) .. "..."
    end
    return text
end

-- Botão de controle do TopBar
local function CreateControlButton(parent, text, posX, iconAssetId, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,42,0,42)
    btn.Position = UDim2.new(1, posX, 0.5, -21)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 21)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(215, 215, 225)
    btn.TextSize = 20
    btn.ZIndex = 10
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    
    local icon
    if iconAssetId then
        icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0,24,0,24)
        icon.Position = UDim2.new(0.5, -12, 0.5, -12)
        icon.BackgroundTransparency = 1
        icon.Image = iconAssetId
        icon.ImageColor3 = Color3.fromRGB(215, 215, 225)
        icon.ScaleType = Enum.ScaleType.Fit
        icon.ZIndex = 11
        icon.Parent = btn
    end
    
    btn.MouseEnter:Connect(function()
        safeTween(btn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.AccentPress})
        if icon then safeTween(icon, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360}) end
    end)
    
    btn.MouseLeave:Connect(function()
        safeTween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(15, 15, 21)})
        if icon then safeTween(icon, TweenInfo.new(0.3), {Rotation = 0}) end
    end)
    
    btn.Activated:Connect(function()
        safeTween(btn, TweenInfo.new(0.08), {BackgroundColor3 = COLORS.Accent})
        if icon then
            safeTween(icon, TweenInfo.new(0.15), {Size = UDim2.new(0,28,0,28)})
            task.delay(0.15, function()
                safeTween(icon, TweenInfo.new(0.15), {Size = UDim2.new(0,24,0,24)})
            end)
        end
        task.delay(0.12, function()
            safeTween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(15, 15, 21)})
        end)
        callback()
    end)
    
    return btn
end

function Library:CreateWindow(title)
    local self = setmetatable({}, Library)
self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = self.SavedSize
    self.MainFrame.Position = UDim2.new(0.5, -self.SavedSize.X.Offset/2, 0.5, -self.SavedSize.Y.Offset/2)
    self.MainFrame.BackgroundColor3 = COLORS.Background
    self.MainFrame.BorderSizePixel = 0                  -- desativa borda nativa padrão
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.ZIndex = 5
    self.MainFrame.Parent = ScreenGui

    Instance.new("UICorner", self.MainFrame).CornerRadius = CORNERS.Large

    -- UIStroke do MainFrame: MANTENHA se quiser glow geral, mas com transparência alta
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = COLORS.Stroke
    uiStroke.Transparency = 0.8                         -- sutil, não interfere na base
    uiStroke.Parent = self.MainFrame
    
    -- Área de drag inferior
    local BottomDrag = Instance.new("Frame")
    BottomDrag.Name = "BottomDrag"
    BottomDrag.Size = UDim2.new(1, 0, 0, 24)
    BottomDrag.Position = UDim2.new(0, 0, 1, -24)
    BottomDrag.BackgroundTransparency = 1
    BottomDrag.ZIndex = 15
    BottomDrag.Parent = self.MainFrame

    local DragIcon = Instance.new("Frame")
    DragIcon.Size = UDim2.new(0, 40, 0, 6)
    DragIcon.Position = UDim2.new(0.5, -20, 0.5, -3)
    DragIcon.BackgroundColor3 = COLORS.TextDim
    DragIcon.BackgroundTransparency = 0.8
    DragIcon.ZIndex = 16
    DragIcon.Parent = BottomDrag

    local DragIconCorner = Instance.new("UICorner")
    DragIconCorner.CornerRadius = UDim.new(1, 0)
    DragIconCorner.Parent = DragIcon

    BottomDrag.MouseEnter:Connect(function()
        safeTween(DragIcon, TweenInfo.new(0.25), {BackgroundTransparency = 0.3, BackgroundColor3 = COLORS.Accent})
    end)

    BottomDrag.MouseLeave:Connect(function()
        safeTween(DragIcon, TweenInfo.new(0.25), {BackgroundTransparency = 0.8, BackgroundColor3 = COLORS.TextDim})
    end)

    -- Linha preta sólida na base (agora com altura 1 pixel para precisão)
    local BottomLine = Instance.new("Frame")
    BottomLine.Name = "BottomLine"
    BottomLine.Size = UDim2.new(1, 0, 0, 1)             -- 1 pixel para ficar fina e nítida
    BottomLine.Position = UDim2.new(0, 0, 1, -25)       -- exatamente acima do drag (-24 drag -1 linha)
    BottomLine.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BottomLine.BorderSizePixel = 0
    BottomLine.BackgroundTransparency = 0
    BottomLine.ZIndex = 17                              -- alto para ficar por cima do conteúdo
    BottomLine.Parent = self.MainFrame

    -- Redimensionamento (mantido igual)
    local function updateResize()
        local resizing = false
        local resizeStartPos
        local startSize

-- Resize Handle - Canto inferior direito (com ícone VISÍVEL e efeito hover)
local ResizeHandle = Instance.new("ImageButton")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.Size = UDim2.new(0, 32, 0, 32)          -- maior para melhor clique
ResizeHandle.Position = UDim2.new(1, -34, 1, -34)    -- ajustado para não ficar colado na borda
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Image = "rbxassetid://7733715400"       -- Ícone de "engrenagem" padrão do Roblox (sempre carrega)
ResizeHandle.ImageColor3 = COLORS.Accent
ResizeHandle.ImageTransparency = 0.4                 -- sutil quando não hover
ResizeHandle.ZIndex = 25
ResizeHandle.Parent = self.MainFrame

-- Efeito ao passar o mouse (fica totalmente visível e gira levemente)
ResizeHandle.MouseEnter:Connect(function()
    safeTween(ResizeHandle, TweenInfo.new(0.2), {ImageTransparency = 0})
    safeTween(ResizeHandle, TweenInfo.new(0.4), {Rotation = 90})  -- gira 90° ao hover (legal)
end)

ResizeHandle.MouseLeave:Connect(function()
    safeTween(ResizeHandle, TweenInfo.new(0.2), {ImageTransparency = 0.4})
    safeTween(ResizeHandle, TweenInfo.new(0.3), {Rotation = 0})
end)

        local BlockOverlay = Instance.new("TextButton")
        BlockOverlay.Size = UDim2.new(1, 0, 1, 0)
        BlockOverlay.BackgroundTransparency = 1
        BlockOverlay.Text = ""
        BlockOverlay.Visible = false
        BlockOverlay.ZIndex = 19
        BlockOverlay.Parent = self.MainFrame

        ResizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                resizeStartPos = input.Position
                startSize = self.MainFrame.Size
                BlockOverlay.Visible = true
            end
        end)

        local resizeConnection = UserInputService.InputChanged:Connect(function(input)
            if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - resizeStartPos
                local newWidth = math.max(450, startSize.X.Offset + delta.X)
                local newHeight = math.max(300, startSize.Y.Offset + delta.Y)
                local newSize = UDim2.new(0, newWidth, 0, newHeight)
                self.MainFrame.Size = newSize
                self.SavedSize = newSize
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
                BlockOverlay.Visible = false
            end
        end)
    end

    updateResize()

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1,0,0,48)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 6
    TopBar.Parent = self.MainFrame

    Instance.new("UICorner", TopBar).CornerRadius = CORNERS.Large

    CreateSmartTextLabel(TopBar, UDim2.new(0.5,0,1,0), UDim2.new(0,18,0,0), title or "GEKYU • PREMIUM", COLORS.Accent, Enum.Font.GothamBlack, 18, Enum.TextXAlignment.Left)

    -- Sistema de Drag (unificado para topo e base)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    local function update(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local function setupDrag(dragObject)
        dragObject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = self.MainFrame.Position
                
                ContextActionService:BindAction("GekyuDrag", function() return Enum.ContextActionResult.Sink end, false, 
                    Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)
                
                local conn
                conn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        ContextActionService:UnbindAction("GekyuDrag")
                        conn:Disconnect()
                    end
                end)
            end
        end)
    end

    -- Conecta o drag no TopBar e no BottomDrag
    setupDrag(TopBar)
    setupDrag(BottomDrag)

    -- Atualiza posição durante movimento
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    -- Botões do TopBar
    CreateControlButton(TopBar, "X", -52, nil, function()
        ScreenGui:Destroy()
    end)

    local minimized = false
    local minimizeBtn = CreateControlButton(TopBar, "−", -102, nil, function()
        minimized = not minimized
        if minimized then
            safeTween(self.MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {Size = UDim2.new(0, self.SavedSize.X.Offset, 0, 48)})
            minimizeBtn.Text = "+"
        else
            safeTween(self.MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {Size = self.SavedSize})
            minimizeBtn.Text = "−"
        end
    end)

    local configBtn = CreateControlButton(TopBar, "", -152, "rbxassetid://3926305904", function()
        self:ToggleConfigPanel()
    end)

    local switchHubBtn = CreateControlButton(TopBar, "", -202, "rbxassetid://7072718362", function()
        self:ShowSwitchHubPopup()
    end)

    -- Search Bar (continua igual)
    local SearchBar = Instance.new("Frame")
    SearchBar.Size = UDim2.new(0,140-12,0,32)
    SearchBar.Position = UDim2.new(0,6,0,48+8)
    SearchBar.BackgroundColor3 = COLORS.Element
    SearchBar.ZIndex = 6
    SearchBar.Parent = self.MainFrame
    Instance.new("UICorner", SearchBar).CornerRadius = CORNERS.Medium

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1,-12,1,-8)
    SearchBox.Position = UDim2.new(0,6,0,4)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.PlaceholderColor3 = COLORS.TextDim
    SearchBox.TextColor3 = COLORS.Text
    SearchBox.Font = Enum.Font.GothamBold
    SearchBox.TextSize = 14
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 7
    SearchBox.Parent = SearchBar

    -- Tabs e Content (continua igual)
    self.TabBar = Instance.new("ScrollingFrame")
    self.TabBar.Size = UDim2.new(0,140,1,-100)
    self.TabBar.Position = UDim2.new(0,0,0,100)
    self.TabBar.BackgroundTransparency = 1
    self.TabBar.ScrollBarThickness = 0
    self.TabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.TabBar.ZIndex = 6
    self.TabBar.Parent = self.MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0,8)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = self.TabBar

    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Size = UDim2.new(1, -152, 1, -100)
    self.ContentArea.Position = UDim2.new(0, 148, 0, 96)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.ZIndex = 6
    self.ContentArea.Parent = self.MainFrame

-- Adicione UIPadding no ContentArea para criar espaço na base
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 28)      -- espaço maior para a linha preta + drag
    contentPadding.PaddingLeft = UDim.new(0, 14)
    contentPadding.PaddingRight = UDim.new(0, 48)       -- espaço para resize handle
    contentPadding.Parent = self.ContentArea

    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 12)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = self.ContentArea

    self.currentTab = nil
    self.tabs = {}

    -- Painel de Configuração (completo)
    self.ConfigPanel = nil
    self.ConfigMinimized = false

    function self:ToggleConfigPanel()
        if self.ConfigPanel and self.ConfigPanel.Parent then
            safeTween(self.ConfigPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(1.5, 0, 0.5, -250)})
            task.delay(0.35, function()
                if self.ConfigPanel then
                    self.ConfigPanel:Destroy()
                    self.ConfigPanel = nil
                end
            end)
        else
            local panel = Instance.new("Frame")
            panel.Name = "ConfigPanel"
            panel.Size = self.ConfigMinimized and UDim2.new(0,400,0,40) or UDim2.new(0,400,0,500)
            panel.Position = lastConfigPosition
            panel.BackgroundColor3 = COLORS.Background
            panel.ZIndex = 50
            panel.Parent = ScreenGui
            Instance.new("UICorner", panel).CornerRadius = CORNERS.Large

            local stroke = Instance.new("UIStroke")
            stroke.Color = COLORS.Stroke
            stroke.Transparency = 0.5
            stroke.Parent = panel

            local configTopBar = Instance.new("Frame")
            configTopBar.Size = UDim2.new(1,0,0,40)
            configTopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
            configTopBar.ZIndex = 51
            configTopBar.Parent = panel

            Instance.new("UICorner", configTopBar).CornerRadius = CORNERS.Large

            CreateSmartTextLabel(configTopBar, UDim2.new(0.5,0,1,0), UDim2.new(0,15,0,0), "Configurações", COLORS.Accent, Enum.Font.GothamBlack, 16, Enum.TextXAlignment.Left)

            local configMinimizeBtn = Instance.new("TextButton")
            configMinimizeBtn.Size = UDim2.new(0,30,0,30)
            configMinimizeBtn.Position = UDim2.new(1, -70, 0.5, -15)
            configMinimizeBtn.BackgroundTransparency = 1
            configMinimizeBtn.Text = self.ConfigMinimized and "+" or "−"
            configMinimizeBtn.TextColor3 = COLORS.Text
            configMinimizeBtn.Font = Enum.Font.GothamBold
            configMinimizeBtn.TextSize = 20
            configMinimizeBtn.ZIndex = 52
            configMinimizeBtn.Parent = configTopBar

            configMinimizeBtn.Activated:Connect(function()
                self.ConfigMinimized = not self.ConfigMinimized
                if self.ConfigMinimized then
                    safeTween(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0,400,0,40)})
                    configMinimizeBtn.Text = "+"
                else
                    safeTween(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0,400,0,500)})
                    configMinimizeBtn.Text = "−"
                end
            end)

            local configCloseBtn = Instance.new("TextButton")
            configCloseBtn.Size = UDim2.new(0,30,0,30)
            configCloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
            configCloseBtn.BackgroundTransparency = 1
            configCloseBtn.Text = "X"
            configCloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            configCloseBtn.Font = Enum.Font.GothamBold
            configCloseBtn.TextSize = 18
            configCloseBtn.ZIndex = 52
            configCloseBtn.Parent = configTopBar

            configCloseBtn.Activated:Connect(function()
                self:ToggleConfigPanel()
            end)

            local configTabBar = Instance.new("Frame")
            configTabBar.Size = UDim2.new(1,0,0,40)
            configTabBar.Position = UDim2.new(0,0,0,40)
            configTabBar.BackgroundColor3 = COLORS.Element
            configTabBar.ZIndex = 51
            configTabBar.Parent = panel

            Instance.new("UICorner", configTabBar).CornerRadius = CORNERS.Medium

            local infoTabBtn = Instance.new("TextButton")
            infoTabBtn.Size = UDim2.new(0.5,0,1,0)
            infoTabBtn.BackgroundTransparency = 1
            infoTabBtn.Text = "Info"
            infoTabBtn.TextColor3 = COLORS.Accent
            infoTabBtn.Font = Enum.Font.GothamBold
            infoTabBtn.TextSize = 14
            infoTabBtn.ZIndex = 52
            infoTabBtn.Parent = configTabBar

            local configTabBtn = Instance.new("TextButton")
            configTabBtn.Size = UDim2.new(0.5,0,1,0)
            configTabBtn.Position = UDim2.new(0.5,0,0,0)
            configTabBtn.BackgroundTransparency = 1
            configTabBtn.Text = "Config"
            configTabBtn.TextColor3 = COLORS.TextDim
            configTabBtn.Font = Enum.Font.GothamBold
            configTabBtn.TextSize = 14
            configTabBtn.ZIndex = 52
            configTabBtn.Parent = configTabBar

            local infoContent = Instance.new("Frame")
            infoContent.Size = UDim2.new(1,0,1,-80)
            infoContent.Position = UDim2.new(0,0,0,80)
            infoContent.BackgroundTransparency = 1
            infoContent.ZIndex = 51
            infoContent.Visible = true
            infoContent.Parent = panel

            CreateSmartTextLabel(infoContent, UDim2.new(1,-20,1,-20), UDim2.new(0,10,0,10), "GekyuUI v1.0\nFeito por Kyuzzy\nPremium Dark Theme", COLORS.Text, Enum.Font.Gotham, 14, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top)

            local configContent = Instance.new("Frame")
            configContent.Size = UDim2.new(1,0,1,-80)
            configContent.Position = UDim2.new(0,0,0,80)
            configContent.BackgroundTransparency = 1
            configContent.ZIndex = 51
            configContent.Visible = false
            configContent.Parent = panel

            CreateSmartTextLabel(configContent, UDim2.new(1,-20,0,30), UDim2.new(0,10,0,10), "Configurações Gerais", COLORS.Accent, Enum.Font.GothamBold, 16, Enum.TextXAlignment.Left)

            infoTabBtn.Activated:Connect(function()
                infoContent.Visible = true
                configContent.Visible = false
                infoTabBtn.TextColor3 = COLORS.Accent
                configTabBtn.TextColor3 = COLORS.TextDim
            end)

            configTabBtn.Activated:Connect(function()
                infoContent.Visible = false
                configContent.Visible = true
                infoTabBtn.TextColor3 = COLORS.TextDim
                configTabBtn.TextColor3 = COLORS.Accent
            end)

            -- Drag do painel de config
            local configDragging, configDragStart, configStartPos = false, nil, nil

            local function configUpdate(input)
                local delta = input.Position - configDragStart
                safeTween(panel, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(configStartPos.X.Scale, configStartPos.X.Offset + delta.X, configStartPos.Y.Scale, configStartPos.Y.Offset + delta.Y)
                })
            end

            configTopBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    configDragging = true
                    configDragStart = input.Position
                    configStartPos = panel.Position
                    
                    ContextActionService:BindAction("ConfigDrag", function() return Enum.ContextActionResult.Sink end, false, 
                        Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)
                    
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            configDragging = false
                            ContextActionService:UnbindAction("ConfigDrag")
                            lastConfigPosition = panel.Position
                        end
                    end)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if configDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    configUpdate(input)
                end
            end)

            panel.Position = UDim2.new(1.5, 0, 0.5, -250)
            safeTween(panel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = lastConfigPosition})

            self.ConfigPanel = panel
        end
    end

    function self:ShowSwitchHubPopup()
        Library.Popup(
            "Trocar de Hub",
            "Deseja abrir o Hub de Jogos/Scripts?\n\nIsso vai **fechar automaticamente** o GekyuUI atual.",
            function()
                -- Coloque aqui o loadstring do seu outro hub
                -- loadstring(game:HttpGet("URL_AQUI"))()
                ScreenGui:Destroy()
            end,
            function() end
        )
    end

    -- Criação de Tabs com scroll individual
    function self:CreateTab(name)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1,-16,0,46)
        button.BackgroundColor3 = COLORS.Element
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Text = ""
        button.ZIndex = 7
        button.ClipsDescendants = true
        button.Parent = self.TabBar
        Instance.new("UICorner", button).CornerRadius = CORNERS.Medium
        
        local textLabel = CreateSmartTextLabel(button, UDim2.new(1,-44,1,0), UDim2.new(0, 24, 0, 0), name:upper(), COLORS.TextDim, Enum.Font.GothamBold, 13, Enum.TextXAlignment.Left)
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0,4,0.7,0)
        indicator.Position = UDim2.new(0, 4, 0.15, 0)
        indicator.BackgroundColor3 = COLORS.Accent
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.ZIndex = 8
        indicator.Parent = button
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1,0)
        
        local content = Instance.new("ScrollingFrame")
        content.Name = "TabContent_" .. name
        content.Size = UDim2.new(1,0,1,0)
        content.BackgroundTransparency = 1
        content.Visible = false
        content.ZIndex = 6
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = COLORS.Stroke
        content.CanvasSize = UDim2.new(0,0,0,0)
        content.Parent = self.ContentArea
        
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0,12)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = content

        local lastScrollPos = Vector2.new(0, 0)
        
        content:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if content.Visible then
                lastScrollPos = content.CanvasPosition
            end
        end)

        table.insert(self.tabs, {
            button = button,
            textLabel = textLabel,
            indicator = indicator,
            content = content,
            name = name:upper(),
            lastScrollPos = lastScrollPos
        })
        
        button.MouseEnter:Connect(function()
            if content.Visible then return end
            safeTween(button, TweenInfo.new(0.25), {BackgroundColor3 = COLORS.ElementHover})
            safeTween(textLabel, TweenInfo.new(0.25), {TextColor3 = COLORS.Text})
            safeTween(indicator, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Size = UDim2.new(0,4,0.85,0)})
        end)
        
        button.MouseLeave:Connect(function()
            if content.Visible then return end
            safeTween(button, TweenInfo.new(0.25), {BackgroundColor3 = COLORS.Element})
            safeTween(textLabel, TweenInfo.new(0.25), {TextColor3 = COLORS.TextDim})
            safeTween(indicator, TweenInfo.new(0.35), {Size = UDim2.new(0,4,0.7,0)})
        end)
        
        button.Activated:Connect(function()
            if self.currentTab then
                self.currentTab.content.Visible = false
                self.currentTab.lastScrollPos = self.currentTab.content.CanvasPosition
                safeTween(self.currentTab.indicator, TweenInfo.new(0.25), {BackgroundTransparency = 1})
                self.currentTab.textLabel.TextColor3 = COLORS.TextDim
                safeTween(self.currentTab.button, TweenInfo.new(0.25), {BackgroundColor3 = COLORS.Element})
            end
            
            content.CanvasPosition = lastScrollPos
            content.Visible = true
            
            safeTween(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back), {BackgroundTransparency = 0, Size = UDim2.new(0,4,0.95,0)})
            textLabel.TextColor3 = COLORS.Text
            safeTween(button, TweenInfo.new(0.15), {Size = UDim2.new(1,-12,0,50)})
            task.delay(0.15, function()
                safeTween(button, TweenInfo.new(0.15), {Size = UDim2.new(1,-16,0,46)})
            end)
            safeTween(button, TweenInfo.new(0.25), {BackgroundColor3 = COLORS.ElementHover})
            
            self.currentTab = {button = button, content = content, indicator = indicator, textLabel = textLabel, lastScrollPos = lastScrollPos}
        end)

        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
        end)
        
        return content
    end

    -- Filtro de busca
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        if query == "" then
            for _, tab in ipairs(self.tabs) do
                tab.button.Visible = true
            end
            return
        end

        local foundAny = false
        for _, tab in ipairs(self.tabs) do
            local match = tab.name:lower():find(query, 1, true)

            if not match then
                for _, child in ipairs(tab.content:GetChildren()) do
                    if child:IsA("Frame") or child:IsA("TextButton") then
                        local lbl = child:FindFirstChildWhichIsA("TextLabel")
                        if lbl and lbl.Text:lower():find(query, 1, true) then
                            match = true
                            break
                        end
                    end
                end
            end

            tab.button.Visible = match
            if match then foundAny = true end
        end

        if foundAny then
            for _, tab in ipairs(self.tabs) do
                if tab.button.Visible then
                    tab.button.Activated:Fire()
                    break
                end
            end
        end
    end)

    -- =============================================
    -- COMPONENTES COMPLETOS
    -- =============================================

    function Library.Button(parent, text, callback, options)
        options = options or {}
        local button = Instance.new("TextButton")
        button.Size = options.size or UDim2.new(0.95, 0, 0, 48)
        button.BackgroundColor3 = COLORS.Element
        button.AutoButtonColor = false
        button.Text = ""
        button.ZIndex = 7
        button.Parent = parent
        
        Instance.new("UICorner", button).CornerRadius = CORNERS.Medium

        local label = CreateSmartTextLabel(button, UDim2.new(1, options.icon and -60 or 0, 1, 0), UDim2.new(0, options.icon and 16 or 0, 0, 0), text, COLORS.Text, Enum.Font.GothamBold, options.textSize or 15, Enum.TextXAlignment.Left)

        local icon
        if options.icon then
            icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 28, 0, 28)
            icon.Position = UDim2.new(1, -42, 0.5, -14)
            icon.BackgroundTransparency = 1
            icon.Image = options.icon
            icon.ImageColor3 = COLORS.Text
            icon.ScaleType = Enum.ScaleType.Fit
            icon.ZIndex = 8
            icon.Parent = button
        end

        button.MouseEnter:Connect(function()
            safeTween(button, TweenInfo.new(0.18), {BackgroundColor3 = COLORS.ElementHover})
            if icon then safeTween(icon, TweenInfo.new(0.3), {ImageColor3 = COLORS.Accent}) end
        end)

        button.MouseLeave:Connect(function()
            safeTween(button, TweenInfo.new(0.18), {BackgroundColor3 = COLORS.Element})
            if icon then safeTween(icon, TweenInfo.new(0.3), {ImageColor3 = COLORS.Text}) end
        end)

        button.Activated:Connect(function()
            safeTween(button, TweenInfo.new(0.08), {BackgroundColor3 = COLORS.AccentPress})
            if icon then
                safeTween(icon, TweenInfo.new(0.12), {Size = UDim2.new(0,32,0,32)})
                task.delay(0.12, function()
                    safeTween(icon, TweenInfo.new(0.12), {Size = UDim2.new(0,28,0,28)})
                end)
            end
            task.delay(0.15, function()
                safeTween(button, TweenInfo.new(0.18), {BackgroundColor3 = COLORS.ElementHover})
            end)
            callback()
        end)

        return button
    end

    function Library.Toggle(parent, text, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 48)
        container.BackgroundColor3 = COLORS.Element
        container.ZIndex = 7
        container.Parent = parent
        
        Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 1, 0)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.ZIndex = 8
        hitbox.Parent = container

        CreateSmartTextLabel(container, UDim2.new(1, -90, 1, 0), UDim2.new(0, 16, 0, 0), text, COLORS.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 52, 0, 26)
        track.Position = UDim2.new(1, -64, 0.5, -13)
        track.BackgroundColor3 = default and COLORS.Accent or COLORS.TextDim
        track.ZIndex = 8
        track.Parent = container
        
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 20, 0, 20)
        circle.Position = default and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        circle.BackgroundColor3 = Color3.new(1,1,1)
        circle.ZIndex = 9
        circle.Parent = track
        
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local state = default or false

        local function update()
            safeTween(track, TweenInfo.new(0.24), {BackgroundColor3 = state and COLORS.Accent or COLORS.TextDim})
            safeTween(circle, TweenInfo.new(0.28, Enum.EasingStyle.Back), {
                Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            })
        end

        hitbox.Activated:Connect(function()
            state = not state
            update()
            callback(state)
        end)

        update()

        return container
    end

    function Library.ToggleWithCheckboxes(parent, toggleText, checkboxesList, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 48)
        container.BackgroundColor3 = COLORS.Element
        container.ClipsDescendants = true
        container.ZIndex = 7
        container.Parent = parent
        
        Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 48)
        header.BackgroundTransparency = 1
        header.Parent = container

        CreateSmartTextLabel(header, UDim2.new(1, -90, 1, 0), UDim2.new(0, 16, 0, 0), toggleText, COLORS.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(1, 0, 1, 0)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Text = ""
        toggleBtn.ZIndex = 8
        toggleBtn.Parent = header

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 52, 0, 26)
        track.Position = UDim2.new(1, -64, 0.5, -13)
        track.BackgroundColor3 = COLORS.TextDim
        track.ZIndex = 8
        track.Parent = header
        
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 20, 0, 20)
        circle.Position = UDim2.new(0, 3, 0.5, -10)
        circle.BackgroundColor3 = Color3.new(1,1,1)
        circle.ZIndex = 9
        circle.Parent = track
        
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local checkboxesContainer = Instance.new("Frame")
        checkboxesContainer.Size = UDim2.new(1, 0, 0, 0)
        checkboxesContainer.Position = UDim2.new(0, 0, 0, 48)
        checkboxesContainer.BackgroundTransparency = 1
        checkboxesContainer.ZIndex = 8
        checkboxesContainer.Parent = container

        local checkListLayout = Instance.new("UIListLayout")
        checkListLayout.Padding = UDim.new(0, 8)
        checkListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        checkListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        checkListLayout.Parent = checkboxesContainer

        local state = false

        for _, checkName in ipairs(checkboxesList) do
            local checkFrame = Instance.new("Frame")
            checkFrame.Size = UDim2.new(0.92, 0, 0, 36)
            checkFrame.BackgroundTransparency = 1
            checkFrame.ZIndex = 8
            checkFrame.Parent = checkboxesContainer

            CreateSmartTextLabel(checkFrame, UDim2.new(1, -60, 1, 0), UDim2.new(0, 12, 0, 0), checkName, COLORS.TextDim, Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left)

            local checkHitbox = Instance.new("TextButton")
            checkHitbox.Size = UDim2.new(0, 45, 0, 45)
            checkHitbox.Position = UDim2.new(1, -45, 0.5, -22)
            checkHitbox.BackgroundTransparency = 1
            checkHitbox.Text = ""
            checkHitbox.ZIndex = 9
            checkHitbox.Parent = checkFrame

            local checkBoxVisual = Instance.new("Frame")
            checkBoxVisual.Size = UDim2.new(0, 20, 0, 20)
            checkBoxVisual.Position = UDim2.new(0.5, -10, 0.5, -10)
            checkBoxVisual.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            checkBoxVisual.ZIndex = 9
            checkBoxVisual.Parent = checkHitbox
            
            Instance.new("UICorner", checkBoxVisual).CornerRadius = UDim.new(0, 5)

            local checkMark = Instance.new("TextLabel")
            checkMark.Size = UDim2.new(1, 0, 1, 0)
            checkMark.BackgroundTransparency = 1
            checkMark.Text = "✓"
            checkMark.TextColor3 = Color3.new(1,1,1)
            checkMark.Font = Enum.Font.GothamBold
            checkMark.TextSize = 16
            checkMark.Visible = false
            checkMark.ZIndex = 10
            checkMark.Parent = checkBoxVisual

            local cState = false
            checkHitbox.Activated:Connect(function()
                cState = not cState
                checkMark.Visible = cState
                
                safeTween(checkBoxVisual, TweenInfo.new(0.18), {
                    BackgroundColor3 = cState and COLORS.Accent or Color3.fromRGB(40, 40, 60)
                })
            end)
        end

        toggleBtn.Activated:Connect(function()
            state = not state
            
            safeTween(track, TweenInfo.new(0.24), {BackgroundColor3 = state and COLORS.Accent or COLORS.TextDim})
            safeTween(circle, TweenInfo.new(0.28, Enum.EasingStyle.Back), {
                Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            })

            local contentHeight = #checkboxesList * 44 + 16
            local finalHeight = state and (48 + contentHeight) or 48

            safeTween(container, TweenInfo.new(0.38, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0.95, 0, 0, finalHeight)
            })

            callback(state)
        end)
    end

    function Library.Slider(parent, text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 62)
        frame.BackgroundColor3 = COLORS.Element
        frame.ZIndex = 7
        frame.Parent = parent
        
        Instance.new("UICorner", frame).CornerRadius = CORNERS.Medium

        CreateSmartTextLabel(frame, UDim2.new(0.68, 0, 0, 26), UDim2.new(0, 14, 0, 6), text, COLORS.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)

        local valueLabel = CreateSmartTextLabel(frame, UDim2.new(0.28, 0, 0, 26), UDim2.new(0.72, 0, 0, 6), tostring(default), COLORS.Accent, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Right)

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0.92, 0, 0, 8)
        bar.Position = UDim2.new(0.04, 0, 0.68, 0)
        bar.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
        bar.ZIndex = 8
        bar.Parent = frame
        
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(math.clamp((default - min)/(max-min), 0, 1), 0, 1, 0)
        fill.BackgroundColor3 = COLORS.Accent
        fill.ZIndex = 9
        fill.Parent = bar
        
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

        local knobArea = Instance.new("TextButton")
        knobArea.Size = UDim2.new(0, 48, 0, 48)
        knobArea.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
        knobArea.AnchorPoint = Vector2.new(0.5, 0.5)
        knobArea.BackgroundTransparency = 1
        knobArea.Text = ""
        knobArea.ZIndex = 10
        knobArea.Parent = bar

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 22, 0, 22)
        knob.Position = UDim2.new(0.5, 0, 0.5, 0)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.ZIndex = 11
        knob.Parent = knobArea
        
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

        local dragging = false

        local function updateValue(input)
            local relative = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relative + 0.5)
            
            safeTween(fill, TweenInfo.new(0.1), {Size = UDim2.new(relative, 0, 1, 0)})
            safeTween(knobArea, TweenInfo.new(0.1), {Position = UDim2.new(relative, 0, 0.5, 0)})
            valueLabel.Text = tostring(value)
            
            callback(value)
        end

        knobArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateValue(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateValue(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    function Library.Dropdown(parent, text, options, defaultIndex, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 40)
        container.BackgroundColor3 = COLORS.Element
        container.ClipsDescendants = true
        container.ZIndex = 7
        container.Parent = parent
        Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 40)
        header.BackgroundTransparency = 1
        header.Parent = container

        CreateSmartTextLabel(header, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 14, 0, 0), text, COLORS.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)

        local selectBtn = Instance.new("TextButton")
        selectBtn.Size = UDim2.new(0, 130, 0, 30)
        selectBtn.Position = UDim2.new(1, -140, 0.5, -15)
        selectBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
        selectBtn.Text = ""
        selectBtn.AutoButtonColor = false
        selectBtn.ZIndex = 8
        selectBtn.Parent = header

        local stroke = Instance.new("UIStroke")
        stroke.Color = COLORS.Stroke
        stroke.Transparency = 0.75
        stroke.Parent = selectBtn

        local selectCorner = Instance.new("UICorner")
        selectCorner.CornerRadius = UDim.new(0, 8)
        selectCorner.Parent = selectBtn

        local selectedText = CreateSmartTextLabel(selectBtn, UDim2.new(1, -12, 1, 0), UDim2.new(0, 6, 0, 0), options[defaultIndex or 1] or "Selecione...", COLORS.Accent, Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Center)

        local optionsFrame = Instance.new("ScrollingFrame")
        optionsFrame.Name = "Options"
        optionsFrame.Size = UDim2.new(1, 0, 0, 0)
        optionsFrame.Position = UDim2.new(0, 0, 0, 40)
        optionsFrame.BackgroundTransparency = 1
        optionsFrame.ScrollBarThickness = 0
        optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        optionsFrame.ZIndex = 9
        optionsFrame.Parent = container

        local optionsLayout = Instance.new("UIListLayout")
        optionsLayout.Padding = UDim.new(0, 4)
        optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        optionsLayout.Parent = optionsFrame

        local opened = false

        local function toggle()
            opened = not opened
            local height = opened and math.min(#options * 38, 180) or 0
            
            safeTween(optionsFrame, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, height)})
            safeTween(container, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {Size = UDim2.new(0.95, 0, 0, 40 + height)})
            safeTween(stroke, TweenInfo.new(0.3), {Transparency = opened and 0.35 or 0.75})
        end

        for _, opt in ipairs(options) do
            local limitedOpt = LimitDropdownText(opt)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.96, 0, 0, 34)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.ZIndex = 10
            btn.Parent = optionsFrame
            
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

           local label = CreateSmartTextLabel(btn, UDim2.new(1, -120, 1, 0), UDim2.new(0, 12, 0, 0), limitedOpt, COLORS.TextDim, Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left)
label.TextTruncate = Enum.TextTruncate.AtEnd

            btn.Activated:Connect(function()
                selectedText.Text = limitedOpt
                callback(opt)
                toggle()
            end)

            btn.MouseEnter:Connect(function()
                safeTween(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.92})
            end)

            btn.MouseLeave:Connect(function()
                safeTween(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1})
            end)
        end

        selectBtn.Activated:Connect(toggle)
    end

    function Library.DropdownMulti(parent, text, options, defaultSelected, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 40)
        container.BackgroundColor3 = COLORS.Element
        container.ClipsDescendants = true
        container.ZIndex = 7
        container.Parent = parent
        
        Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 40)
        header.BackgroundTransparency = 1
        header.Parent = container

        CreateSmartTextLabel(header, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 14, 0, 0), text, COLORS.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)

        local previewBox = Instance.new("TextButton")
        previewBox.Size = UDim2.new(0, 130, 0, 30)
        previewBox.Position = UDim2.new(1, -140, 0.5, -15)
        previewBox.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
        previewBox.Text = ""
        previewBox.AutoButtonColor = false
        previewBox.ZIndex = 8
        previewBox.Parent = header

        local stroke = Instance.new("UIStroke")
        stroke.Color = COLORS.Stroke
        stroke.Transparency = 0.75
        stroke.Parent = previewBox

        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 8)
        previewCorner.Parent = previewBox

        local previewText = CreateSmartTextLabel(previewBox, UDim2.new(1, -36, 1, 0), UDim2.new(0, 8, 0, 0), "Nenhum selecionado", COLORS.TextDim, Enum.Font.GothamSemibold, 12, Enum.TextXAlignment.Left)

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 24, 1, 0)
        arrow.Position = UDim2.new(1, -28, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = COLORS.TextDim
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 14
        arrow.ZIndex = 9
        arrow.Parent = previewBox

        local optionsContainer = Instance.new("ScrollingFrame")
        optionsContainer.Name = "Options"
        optionsContainer.Size = UDim2.new(1, 0, 0, 0)
        optionsContainer.Position = UDim2.new(0, 0, 0, 40)
        optionsContainer.BackgroundTransparency = 1
        optionsContainer.ScrollBarThickness = 0
        optionsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
        optionsContainer.ZIndex = 9
        optionsContainer.Parent = container

        local optionsLayout = Instance.new("UIListLayout")
        optionsLayout.Padding = UDim.new(0, 4)
        optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        optionsLayout.Parent = optionsContainer

        local isOpen = false
        local selected = {}

        if defaultSelected then
            for _, v in ipairs(defaultSelected) do
                for i, opt in ipairs(options) do
                    if opt == v then
                        selected[i] = true
                        break
                    end
                end
            end
        end

        local function updatePreview()
            local count = 0
            for _, isSel in pairs(selected) do if isSel then count += 1 end end
            
            local previewStr = count == 0 and "Nenhum selecionado" or (count == #options and "Todos selecionados" or count .. " selecionado(s)")
            previewText.Text = LimitDropdownText(previewStr)
            previewText.TextColor3 = count > 0 and COLORS.Accent or COLORS.TextDim
            
            local selectedList = {}
            for i, isSel in pairs(selected) do
                if isSel then table.insert(selectedList, options[i]) end
            end
            callback(selectedList)
        end

        for i, optionName in ipairs(options) do
            local limitedOpt = LimitDropdownText(optionName)
            local optionBtn = Instance.new("TextButton")
            optionBtn.Size = UDim2.new(0.96, 0, 0, 34)
            optionBtn.BackgroundTransparency = 1
            optionBtn.Text = ""
            optionBtn.AutoButtonColor = false
            optionBtn.ZIndex = 10
            optionBtn.Parent = optionsContainer
            
            Instance.new("UICorner", optionBtn).CornerRadius = CORNERS.Small

            local label = CreateSmartTextLabel(optionBtn, UDim2.new(1, -120, 1, 0), UDim2.new(0, 12, 0, 0), limitedOpt, COLORS.TextDim, Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left)
label.TextTruncate = Enum.TextTruncate.AtEnd

            local checkMark = Instance.new("TextLabel")
            checkMark.Size = UDim2.new(0, 24, 0, 24)
            checkMark.Position = UDim2.new(1, -34, 0.5, -12)
            checkMark.BackgroundTransparency = 1
            checkMark.Text = "✓"
            checkMark.TextColor3 = COLORS.Accent
            checkMark.Font = Enum.Font.GothamBold
            checkMark.TextSize = 18
            checkMark.Visible = selected[i] or false
            checkMark.ZIndex = 11
            checkMark.Parent = optionBtn

            optionBtn.MouseEnter:Connect(function()
                safeTween(optionBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.92})
            end)

            optionBtn.MouseLeave:Connect(function()
                safeTween(optionBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1})
            end)

            optionBtn.Activated:Connect(function()
                selected[i] = not selected[i]
                checkMark.Visible = selected[i]
                updatePreview()
            end)
        end

        local function toggleDropdown()
            isOpen = not isOpen
            local maxHeight = math.min(#options * 38 + 8, 180)
            local targetHeight = isOpen and maxHeight or 0
            
            safeTween(optionsContainer, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, targetHeight)})
            safeTween(container, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {Size = UDim2.new(0.95, 0, 0, 40 + targetHeight)})
            safeTween(stroke, TweenInfo.new(0.3), {Transparency = isOpen and 0.35 or 0.75})
            safeTween(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Rotation = isOpen and 180 or 0})
        end

        previewBox.Activated:Connect(toggleDropdown)

        updatePreview()
    end

    function Library.InputNumber(parent, text, min, max, default, step, callback)
        step = step or 1

        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 52)
        container.BackgroundColor3 = COLORS.Element
        container.ZIndex = 7
        container.Parent = parent
        
        Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

        CreateSmartTextLabel(container, UDim2.new(0.6, 0, 0, 24), UDim2.new(0, 14, 0, 6), text, COLORS.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)

        local inputFrame = Instance.new("Frame")
        inputFrame.Size = UDim2.new(0, 140, 0, 34)
        inputFrame.Position = UDim2.new(1, -154, 0, 9)
        inputFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
        inputFrame.ZIndex = 8
        inputFrame.Parent = container
        
        Instance.new("UICorner", inputFrame).CornerRadius = CORNERS.Small

        local valueBox = Instance.new("TextBox")
        valueBox.Size = UDim2.new(0, 80, 0.8, 0)
        valueBox.Position = UDim2.new(0.5, 0, 0.5, 0)
        valueBox.AnchorPoint = Vector2.new(0.5, 0.5)
        valueBox.BackgroundTransparency = 1
        valueBox.Text = tostring(default)
        valueBox.TextColor3 = COLORS.Accent
        valueBox.Font = Enum.Font.GothamBold
        valueBox.TextSize = 16
        valueBox.TextXAlignment = Enum.TextXAlignment.Center
        valueBox.ZIndex = 9
        valueBox.Parent = inputFrame

        valueBox:GetPropertyChangedSignal("Text"):Connect(function()
            local currentText = valueBox.Text
            if valueBox.TextBounds.X > valueBox.AbsoluteSize.X - 10 then
                valueBox.Text = currentText:sub(1, #currentText - 1)
            end
        end)

        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 28, 0, 28)
        minusBtn.Position = UDim2.new(0, 6, 0.5, -14)
        minusBtn.BackgroundTransparency = 1
        minusBtn.Text = "−"
        minusBtn.TextColor3 = COLORS.TextDim
        minusBtn.Font = Enum.Font.GothamBold
        minusBtn.TextSize = 20
        minusBtn.ZIndex = 9
        minusBtn.Parent = inputFrame

        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 28, 0, 28)
        plusBtn.Position = UDim2.new(1, -34, 0.5, -14)
        plusBtn.BackgroundTransparency = 1
        plusBtn.Text = "+"
        plusBtn.TextColor3 = COLORS.TextDim
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.TextSize = 20
        plusBtn.ZIndex = 9
        plusBtn.Parent = inputFrame

        local currentValue = default

        local function updateValue(newVal)
            currentValue = math.clamp(newVal, min, max)
            valueBox.Text = tostring(currentValue)
            callback(currentValue)
        end

        minusBtn.Activated:Connect(function()
            updateValue(currentValue - step)
        end)

        plusBtn.Activated:Connect(function()
            updateValue(currentValue + step)
        end)

        valueBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local num = tonumber(valueBox.Text)
                if num then
                    updateValue(num)
                else
                    valueBox.Text = tostring(currentValue)
                end
            end
        end)

        valueBox:GetPropertyChangedSignal("Text"):Connect(function()
            local num = tonumber(valueBox.Text)
            if num then currentValue = num end
        end)

        updateValue(default)
    end

    local activeNotifications = {}

    function Library.Notify(message, duration, color)
        duration = duration or 4
        color = color or COLORS.Accent

        local holder = ScreenGui:FindFirstChild("NotificationHolder")
        if not holder then
            holder = Instance.new("Frame")
            holder.Name = "NotificationHolder"
            holder.Size = UDim2.new(0, 320, 0.4, 0)
            holder.Position = UDim2.new(1, -340, 0, 20)
            holder.BackgroundTransparency = 1
            holder.ZIndex = 100
            holder.Parent = ScreenGui

            local list = Instance.new("UIListLayout")
            list.Padding = UDim.new(0, 10)
            list.HorizontalAlignment = Enum.HorizontalAlignment.Right
            list.VerticalAlignment = Enum.VerticalAlignment.Top
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list.Parent = holder
        end

        if activeNotifications[message] then
            local data = activeNotifications[message]
            data.count = (data.count or 1) + 1
            
            local label = data.frame:FindFirstChildWhichIsA("TextLabel")
            label.RichText = true
            label.Text = message .. "  <font color='rgb(200,220,255)'>x" .. data.count .. "</font>"
            
            if data.destroyTime then task.cancel(data.destroyTime) end
            
            data.destroyTime = task.delay(duration, function()
                safeTween(data.frame, TweenInfo.new(0.5), {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, 0, 0, -40)
                })
                task.delay(0.5, function()
                    data.frame:Destroy()
                    activeNotifications[message] = nil
                end)
            end)
            
            safeTween(data.frame, TweenInfo.new(0.2), {BackgroundColor3 = color})
            task.delay(0.2, function()
                safeTween(data.frame, TweenInfo.new(0.4), {BackgroundColor3 = COLORS.Background})
            end)
            
            return
        end

        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(1, 0, 0, 64)
        notif.BackgroundColor3 = COLORS.Background
        notif.BackgroundTransparency = 0
        notif.ZIndex = 102
        notif.Parent = holder
        
        Instance.new("UICorner", notif).CornerRadius = CORNERS.Medium

        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Transparency = 0.4
        stroke.Parent = notif

        local label = CreateSmartTextLabel(notif, UDim2.new(1, -24, 1, -20), UDim2.new(0, 12, 0, 10), message, COLORS.Text, Enum.Font.GothamSemibold, 15, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top)
        label.ZIndex = 103

        safeTween(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0, 0, 0, 0)})

        activeNotifications[message] = {
            frame = notif,
            count = 1,
            destroyTime = task.delay(duration, function()
                safeTween(notif, TweenInfo.new(0.5), {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, 0, 0, -40)
                })
                task.delay(0.5, function()
                    notif:Destroy()
                    activeNotifications[message] = nil
                end)
            end)
        }
    end

    function Library.Popup(titleText, messageText, onConfirm, onCancel)
        local popupHolder = Instance.new("Frame")
        popupHolder.Name = "PopupLayer"
        popupHolder.Size = UDim2.new(1,0,1,0)
        popupHolder.BackgroundTransparency = 1
        popupHolder.ZIndex = 200
        popupHolder.Parent = ScreenGui

        local overlay = Instance.new("TextButton")
        overlay.Size = UDim2.new(1,0,1,0)
        overlay.BackgroundColor3 = Color3.new(0,0,0)
        overlay.BackgroundTransparency = 0.85
        overlay.Text = ""
        overlay.AutoButtonColor = false
        overlay.ZIndex = 201
        overlay.Parent = popupHolder

        local popup = Instance.new("Frame")
        popup.Size = UDim2.new(0, 390, 0, 250)
        popup.Position = UDim2.new(0.5, -195, 0.5, -125)
        popup.BackgroundColor3 = COLORS.Background
        popup.ZIndex = 202
        popup.Parent = popupHolder
        
        Instance.new("UICorner", popup).CornerRadius = CORNERS.Large

        local stroke = Instance.new("UIStroke")
        stroke.Color = COLORS.Stroke
        stroke.Transparency = 0.45
        stroke.Parent = popup

        local topBar = Instance.new("Frame")
        topBar.Size = UDim2.new(1,0,0,52)
        topBar.BackgroundColor3 = COLORS.Element
        topBar.ZIndex = 204
        topBar.Parent = popup

        Instance.new("UICorner", topBar).CornerRadius = CORNERS.Large

        CreateSmartTextLabel(topBar, UDim2.new(1, -20, 1, 0), UDim2.new(0, 18, 0, 0), titleText, COLORS.Accent, Enum.Font.GothamBlack, 18, Enum.TextXAlignment.Left)

        local content = CreateSmartTextLabel(popup, UDim2.new(1, -40, 0, 110), UDim2.new(0, 20, 0, 70), messageText, COLORS.Text, Enum.Font.Gotham, 15, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top)
        content.ZIndex = 205

        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0, 158, 0, 52)
        cancelBtn.Position = UDim2.new(0.5, -168, 1, -80)
        cancelBtn.BackgroundColor3 = COLORS.Element
        cancelBtn.Text = "Cancelar"
        cancelBtn.TextColor3 = COLORS.TextDim
        cancelBtn.Font = Enum.Font.GothamBold
        cancelBtn.TextSize = 15
        cancelBtn.ZIndex = 206
        cancelBtn.Parent = popup

        Instance.new("UICorner", cancelBtn).CornerRadius = CORNERS.Small

        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Size = UDim2.new(0, 158, 0, 52)
        confirmBtn.Position = UDim2.new(0.5, 10, 1, -80)
        confirmBtn.BackgroundColor3 = COLORS.Accent
        confirmBtn.Text = "Confirmar"
        confirmBtn.TextColor3 = Color3.new(1,1,1)
        confirmBtn.Font = Enum.Font.GothamBold
        confirmBtn.TextSize = 15
        confirmBtn.ZIndex = 206
        confirmBtn.Parent = popup

        Instance.new("UICorner", confirmBtn).CornerRadius = CORNERS.Small

        local function closePopup()
            safeTween(popup, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 340, 0, 210)
            })
            
            safeTween(overlay, TweenInfo.new(0.28), {BackgroundTransparency = 1})
            
            task.delay(0.3, function()
                popupHolder:Destroy()
            end)
        end

        cancelBtn.MouseEnter:Connect(function()
            safeTween(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.ElementHover})
        end)
        
        cancelBtn.MouseLeave:Connect(function()
            safeTween(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Element})
        end)

        confirmBtn.MouseEnter:Connect(function()
            safeTween(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.AccentPress})
        end)
        
        confirmBtn.MouseLeave:Connect(function()
            safeTween(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Accent})
        end)

        cancelBtn.Activated:Connect(function()
            if onCancel then onCancel() end
            closePopup()
        end)

        confirmBtn.Activated:Connect(function()
            if onConfirm then onConfirm() end
            closePopup()
        end)
    end

    task.delay(0.1, function()
        local firstTab = self.TabBar:FindFirstChildWhichIsA("TextButton")
        if firstTab then firstTab.Activated:Fire() end
    end)

    return self
end

print("[GekyuUI] Versão COMPLETA e corrigida - 16/01/2026 - Config minimiza, scroll por tab, todos componentes incluídos")

return Library
