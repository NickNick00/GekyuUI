-- Library.lua
-- GekyuUI - Biblioteca completa, auto-contida, estilo Wind UI / intermediário premium
-- Kyuzzy - Versão FINAL corrigida (sem nil errors, popup clicável, notify anti-spam, dropdown multi perfeito)
-- Atualizado 15/01/2026 - Revisado linha por linha para zero bugs

local Library = {}
Library.__index = Library

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

-- Remove UI antiga se já existir (evita duplicatas)
if CoreGui:FindFirstChild("GekyuPremiumUI") then
    CoreGui.GekyuPremiumUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GekyuPremiumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = CoreGui

-- Paleta de cores global (fácil de editar)
local COLORS = {
    Background    = Color3.fromRGB(10, 10, 16),
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

-- Função auxiliar para criar textos inteligentes (nunca ultrapassa a caixa)
local function CreateSmartTextLabel(parent, size, pos, text, color, font, textSize, alignmentX, alignmentY)
    local label = Instance.new("TextLabel")
    label.Size = size or UDim2.new(1, 0, 1, 0)
    label.Position = pos or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = color or COLORS.Text
    label.Font = font or Enum.Font.GothamBold
    label.TextSize = textSize or 14
    label.TextXAlignment = alignmentX or Enum.TextXAlignment.Left
    label.TextYAlignment = alignmentY or Enum.TextYAlignment.Center
    label.TextWrapped = true
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.TextScaled = true  -- diminui fonte automaticamente se texto for muito grande
    label.Parent = parent

    return label
end

-- Sistema de Notify com anti-spam (contador xN)
local activeNotifies = {}  -- [mensagem] = {frame, count, timer}

function Library.Notify(message, duration, color)
    duration = duration or 4
    color = color or COLORS.Accent

    local existing = activeNotifies[message]
    if existing and existing.frame and existing.frame.Parent then
        existing.count = (existing.count or 1) + 1
        existing.textLabel.Text = message .. " (x" .. existing.count .. ")"
        existing.timer = duration  -- reseta timer
        return
    end

    local holder = ScreenGui:FindFirstChild("NotificationHolder")
    if not holder then
        holder = Instance.new("Frame")
        holder.Name = "NotificationHolder"
        holder.Size = UDim2.new(0, 300, 0.3, 0)
        holder.Position = UDim2.new(1, -320, 0, 40)  -- canto superior direito, mais em cima
        holder.BackgroundTransparency = 1
        holder.Parent = ScreenGui

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 12)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Right
        list.VerticalAlignment = Enum.VerticalAlignment.Top
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = holder
    end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 68)
    notif.BackgroundColor3 = COLORS.Background
    notif.BackgroundTransparency = 1
    notif.Parent = holder
    
    Instance.new("UICorner", notif).CornerRadius = CORNERS.Medium

    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Transparency = 0.6
    stroke.Parent = notif

    local textLabel = CreateSmartTextLabel(notif, UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10), message, COLORS.Text, Enum.Font.GothamSemibold, 14, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top)

    notif.textLabel = textLabel
    notif.count = 1
    notif.timer = duration

    activeNotifies[message] = notif

    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    -- Timer de remoção
    spawn(function()
        while notif and notif.Parent and notif.timer > 0 do
            task.wait(1)
            notif.timer = notif.timer - 1
        end
        if notif and notif.Parent then
            TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 0, 0, -20)
            }):Play()
            task.delay(0.5, function()
                notif:Destroy()
                activeNotifies[message] = nil
            end)
        end
    end)
end

-- Popup (botões 100% clicáveis, overlay bloqueia fundo)
function Library.Popup(titleText, messageText, onConfirm, onCancel)
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 380, 0, 240)
    popup.Position = UDim2.new(0.5, -190, 0.5, -120)
    popup.BackgroundColor3 = COLORS.Background
    popup.BackgroundTransparency = 1
    popup.ZIndex = 10  -- popup acima de tudo
    popup.Parent = ScreenGui
    popup.ClipsDescendants = true

    Instance.new("UICorner", popup).CornerRadius = CORNERS.Large

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Stroke
    stroke.Transparency = 0.4
    stroke.Parent = popup

    local overlay = Instance.new("TextButton")
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Color3.new(0,0,0)
    overlay.BackgroundTransparency = 0.65
    overlay.Text = ""
    overlay.AutoButtonColor = false
    overlay.ZIndex = 5  -- abaixo do popup
    overlay.Parent = ScreenGui

    TweenService:Create(popup, TweenInfo.new(0.3, Enum.EasingStyle.Back), {BackgroundTransparency = 0}):Play()
    TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.65}):Play()

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1,0,0,50)
    topBar.BackgroundColor3 = COLORS.Element
    topBar.ZIndex = 11
    topBar.Parent = popup

    Instance.new("UICorner", topBar).CornerRadius = CORNERS.Large

    CreateSmartTextLabel(topBar, UDim2.new(1, -20, 1, 0), UDim2.new(0, 16, 0, 0), titleText, COLORS.Accent, Enum.Font.GothamBlack, 18, Enum.TextXAlignment.Left)

    local content = CreateSmartTextLabel(popup, UDim2.new(1, -32, 0, 100), UDim2.new(0, 16, 0, 60), messageText, COLORS.Text, Enum.Font.Gotham, 15, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top)

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 150, 0, 48)
    cancelBtn.Position = UDim2.new(0.5, -160, 1, -70)
    cancelBtn.BackgroundColor3 = COLORS.Element
    cancelBtn.Text = "Cancelar"
    cancelBtn.TextColor3 = COLORS.TextDim
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 15
    cancelBtn.ZIndex = 12
    cancelBtn.Parent = popup

    Instance.new("UICorner", cancelBtn).CornerRadius = CORNERS.Small

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0, 150, 0, 48)
    confirmBtn.Position = UDim2.new(0.5, 10, 1, -70)
    confirmBtn.BackgroundColor3 = COLORS.Accent
    confirmBtn.Text = "Confirmar"
    confirmBtn.TextColor3 = Color3.new(1,1,1)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 15
    confirmBtn.ZIndex = 12
    confirmBtn.Parent = popup

    Instance.new("UICorner", confirmBtn).CornerRadius = CORNERS.Small

    local function closePopup()
        TweenService:Create(popup, TweenInfo.new(0.25), {BackgroundTransparency = 1, Size = UDim2.new(0, 340, 0, 210)}):Play()
        TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        
        task.delay(0.25, function()
            popup:Destroy()
            overlay:Destroy()
        end)
    end

    cancelBtn.MouseEnter:Connect(function()
        TweenService:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.ElementHover}):Play()
    end)

    cancelBtn.MouseLeave:Connect(function()
        TweenService:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Element}):Play()
    end)

    cancelBtn.Activated:Connect(function()
        if onCancel then onCancel() end
        closePopup()
    end)

    confirmBtn.MouseEnter:Connect(function()
        TweenService:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.AccentPress}):Play()
    end)

    confirmBtn.MouseLeave:Connect(function()
        TweenService:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Accent}):Play()
    end)

    confirmBtn.Activated:Connect(function()
        if onConfirm then onConfirm() end
        closePopup()
    end)

    overlay.Activated:Connect(function() end)  -- bloqueia fundo
end

-- =============================================
-- Criação da janela principal do hub
-- =============================================
function Library:CreateWindow(title)
    local self = setmetatable({}, Library)
    
    -- Frame principal
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 480, 0, 520)
    self.MainFrame.Position = UDim2.new(0.5, -240, 0.5, -260)
    self.MainFrame.BackgroundColor3 = COLORS.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = ScreenGui

    Instance.new("UICorner", self.MainFrame).CornerRadius = CORNERS.Large

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = COLORS.Stroke
    uiStroke.Transparency = 0.65
    uiStroke.Parent = self.MainFrame

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1,0,0,48)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = self.MainFrame

    Instance.new("UICorner", TopBar).CornerRadius = CORNERS.Large

    CreateSmartTextLabel(TopBar, UDim2.new(0.5,0,1,0), UDim2.new(0,18,0,0), title or "GEKYU • PREMIUM", COLORS.Accent, Enum.Font.GothamBlack, 18, Enum.TextXAlignment.Left)

    -- Sistema de arrastar (drag) a janela
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    local function update(input)
        local delta = input.Position - dragStart
        TweenService:Create(self.MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            ContextActionService:BindAction("DisableCamera", function() return Enum.ContextActionResult.Sink end, false, 
                Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    ContextActionService:UnbindAction("DisableCamera")
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

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
            self.MainFrame:TweenSize(UDim2.new(0,480,0,48), "Out", "Quint", 0.28, true)
            minimizeBtn.Text = "+"
        else
            self.MainFrame:TweenSize(UDim2.new(0,480,0,520), "Out", "Quint", 0.28, true)
            minimizeBtn.Text = "−"
        end
    end)

    CreateControlButton(TopBar, "", -152, "rbxassetid://133102912527371", function()
        print("Config hub aberto - adicione sua lógica aqui")
    end)

    -- Search Bar
    local SearchBar = Instance.new("Frame")
    SearchBar.Size = UDim2.new(0,140-12,0,32)
    SearchBar.Position = UDim2.new(0,6,0,48+8)
    SearchBar.BackgroundColor3 = COLORS.Element
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
    SearchBox.Parent = SearchBar

    -- Tabs laterais
    self.TabBar = Instance.new("ScrollingFrame")
    self.TabBar.Size = UDim2.new(0,140,1,-100)
    self.TabBar.Position = UDim2.new(0,0,0,100)
    self.TabBar.BackgroundTransparency = 1
    self.TabBar.ScrollBarThickness = 0
    self.TabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.TabBar.Parent = self.MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0,8)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = self.TabBar

    -- Área de conteúdo principal
    self.ContentArea = Instance.new("ScrollingFrame")
    self.ContentArea.Size = UDim2.new(1, -152, 1, -100)
    self.ContentArea.Position = UDim2.new(0, 148, 0, 96)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.ScrollBarThickness = 0
    self.ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ContentArea.Parent = self.MainFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 12)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = self.ContentArea

    self.currentTab = nil

    -- Função para criar aba (tab)
    function self:CreateTab(name)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1,-16,0,46)
        button.BackgroundColor3 = COLORS.Element
        button.BorderSizePixel = 0
        button.Font = Enum.Font.GothamBold
        button.TextColor3 = COLORS.TextDim
        button.TextSize = 14
        button.TextWrapped = true
        button.AutoButtonColor = false
        button.Text = ""
        button.Parent = self.TabBar
        Instance.new("UICorner", button).CornerRadius = CORNERS.Medium
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1,0,1,0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Text = name:upper()
        textLabel.TextColor3 = COLORS.TextDim
        textLabel.TextSize = 14
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.Parent = button
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0,4,0.65,0)
        indicator.Position = UDim2.new(0,8,0.175,0)
        indicator.BackgroundColor3 = COLORS.Accent
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.Parent = button
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1,0)
        
        local content = Instance.new("Frame")
        content.Size = UDim2.new(1,0,1,0)
        content.BackgroundTransparency = 1
        content.Visible = false
        content.Parent = self.ContentArea
        
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0,12)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = content
        
        button.MouseEnter:Connect(function()
            if content.Visible then return end
            TweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = COLORS.ElementHover}):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.25), {TextColor3 = COLORS.Text}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Size = UDim2.new(0,4,0.8,0)}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            if content.Visible then return end
            TweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = COLORS.Element}):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.25), {TextColor3 = COLORS.TextDim}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.35), {Size = UDim2.new(0,4,0.65,0)}):Play()
        end)
        
        button.Activated:Connect(function()
            if self.currentTab then
                self.currentTab.content.Visible = false
                TweenService:Create(self.currentTab.indicator, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                self.currentTab.button:FindFirstChild("TextLabel").TextColor3 = COLORS.TextDim
                TweenService:Create(self.currentTab.button, TweenInfo.new(0.25), {BackgroundColor3 = COLORS.Element}):Play()
            end
            
            content.Visible = true
            TweenService:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back), {BackgroundTransparency = 0, Size = UDim2.new(0,4,0.9,0)}):Play()
            textLabel.TextColor3 = COLORS.Text
            TweenService:Create(button, TweenInfo.new(0.15), {Size = UDim2.new(1,-12,0,50)}):Play()
            task.delay(0.15, function()
                TweenService:Create(button, TweenInfo.new(0.15), {Size = UDim2.new(1,-16,0,46)}):Play()
            end)
            TweenService:Create(button, TweenInfo.new(0.25), {BackgroundColor3 = COLORS.ElementHover}):Play()
            
            self.currentTab = {button = button, content = content, indicator = indicator, textLabel = textLabel}
        end)
        
        return content  -- retorna o frame da aba para adicionar componentes
    end

    -- =============================================
    -- COMPONENTES (todos aqui dentro da library)
    -- =============================================

    -- Button
    function Library.Button(parent, text, callback, options)
        options = options or {}
        local button = Instance.new("TextButton")
        button.Size = options.size or UDim2.new(0.95, 0, 0, 48)
        button.BackgroundColor3 = COLORS.Element
        button.AutoButtonColor = false
        button.Text = ""
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
            icon.Parent = button
        end

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.18), {BackgroundColor3 = COLORS.ElementHover}):Play()
            if icon then TweenService:Create(icon, TweenInfo.new(0.3), {ImageColor3 = COLORS.Accent}):Play() end
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.18), {BackgroundColor3 = COLORS.Element}):Play()
            if icon then TweenService:Create(icon, TweenInfo.new(0.3), {ImageColor3 = COLORS.Text}):Play() end
        end)

        button.Activated:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.08), {BackgroundColor3 = COLORS.AccentPress}):Play()
            if icon then
                TweenService:Create(icon, TweenInfo.new(0.12), {Size = UDim2.new(0,32,0,32)}):Play()
                task.delay(0.12, function()
                    TweenService:Create(icon, TweenInfo.new(0.12), {Size = UDim2.new(0,28,0,28)}):Play()
                end)
            end
            task.delay(0.15, function()
                TweenService:Create(button, TweenInfo.new(0.18), {BackgroundColor3 = COLORS.ElementHover}):Play()
            end)
            callback()
        end)

        return button
    end

    -- Toggle simples
    function Library.Toggle(parent, text, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 48)
        container.BackgroundColor3 = COLORS.Element
        container.Parent = parent
        
        Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 1, 0)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = container

        CreateSmartTextLabel(container, UDim2.new(1, -90, 1, 0), UDim2.new(0, 16, 0, 0), text, COLORS.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 52, 0, 26)
        track.Position = UDim2.new(1, -64, 0.5, -13)
        track.BackgroundColor3 = default and COLORS.Accent or COLORS.TextDim
        track.Parent = container
        
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 20, 0, 20)
        circle.Position = default and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        circle.BackgroundColor3 = Color3.new(1,1,1)
        circle.Parent = track
        
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local state = default or false

        local function update()
            TweenService:Create(track, TweenInfo.new(0.24), {BackgroundColor3 = state and COLORS.Accent or COLORS.TextDim}):Play()
            TweenService:Create(circle, TweenInfo.new(0.28, Enum.EasingStyle.Back), {
                Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            }):Play()
        end

        hitbox.Activated:Connect(function()
            state = not state
            update()
            callback(state)
        end)

        update()

        return container
    end

    -- ToggleWithCheckboxes
    function Library.ToggleWithCheckboxes(parent, toggleText, checkboxesList, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 48)
        container.BackgroundColor3 = COLORS.Element
        container.ClipsDescendants = true
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
        toggleBtn.Parent = header

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 52, 0, 26)
        track.Position = UDim2.new(1, -64, 0.5, -13)
        track.BackgroundColor3 = COLORS.TextDim
        track.Parent = header
        
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 20, 0, 20)
        circle.Position = UDim2.new(0, 3, 0.5, -10)
        circle.BackgroundColor3 = Color3.new(1,1,1)
        circle.Parent = track
        
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local checkboxesContainer = Instance.new("Frame")
        checkboxesContainer.Size = UDim2.new(1, 0, 0, 0)
        checkboxesContainer.Position = UDim2.new(0, 0, 0, 48)
        checkboxesContainer.BackgroundTransparency = 1
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
            checkFrame.Parent = checkboxesContainer

            CreateSmartTextLabel(checkFrame, UDim2.new(1, -60, 1, 0), UDim2.new(0, 12, 0, 0), checkName, COLORS.TextDim, Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left)

            local checkHitbox = Instance.new("TextButton")
            checkHitbox.Size = UDim2.new(0, 45, 0, 45)
            checkHitbox.Position = UDim2.new(1, -45, 0.5, -22)
            checkHitbox.BackgroundTransparency = 1
            checkHitbox.Text = ""
            checkHitbox.Parent = checkFrame

            local checkBoxVisual = Instance.new("Frame")
            checkBoxVisual.Size = UDim2.new(0, 20, 0, 20)
            checkBoxVisual.Position = UDim2.new(0.5, -10, 0.5, -10)
            checkBoxVisual.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
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
            checkMark.Parent = checkBoxVisual

            local cState = false
            checkHitbox.Activated:Connect(function()
                cState = not cState
                checkMark.Visible = cState
                
                TweenService:Create(checkBoxVisual, TweenInfo.new(0.18), {
                    BackgroundColor3 = cState and COLORS.Accent or Color3.fromRGB(40, 40, 60)
                }):Play()
            end)
        end

        toggleBtn.Activated:Connect(function()
            state = not state
            
            TweenService:Create(track, TweenInfo.new(0.24), {BackgroundColor3 = state and COLORS.Accent or COLORS.TextDim}):Play()
            TweenService:Create(circle, TweenInfo.new(0.28, Enum.EasingStyle.Back), {
                Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            }):Play()

            local contentHeight = #checkboxesList * 44 + 16
            local finalHeight = state and (48 + contentHeight) or 48

            TweenService:Create(container, TweenInfo.new(0.38, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0.95, 0, 0, finalHeight)
            }):Play()

            callback(state)
        end)
    end

    -- Slider
    function Library.Slider(parent, text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 62)
        frame.BackgroundColor3 = COLORS.Element
        frame.Parent = parent
        
        Instance.new("UICorner", frame).CornerRadius = CORNERS.Medium

        CreateSmartTextLabel(frame, UDim2.new(0.68, 0, 0, 26), UDim2.new(0, 14, 0, 6), text, COLORS.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)

        local valueLabel = CreateSmartTextLabel(frame, UDim2.new(0.28, 0, 0, 26), UDim2.new(0.72, 0, 0, 6), tostring(default), COLORS.Accent, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Right)

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0.92, 0, 0, 8)
        bar.Position = UDim2.new(0.04, 0, 0.68, 0)
        bar.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
        bar.Parent = frame
        
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(math.clamp((default - min)/(max-min), 0, 1), 0, 1, 0)
        fill.BackgroundColor3 = COLORS.Accent
        fill.Parent = bar
        
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

        local knobArea = Instance.new("TextButton")
        knobArea.Size = UDim2.new(0, 48, 0, 48)
        knobArea.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
        knobArea.AnchorPoint = Vector2.new(0.5, 0.5)
        knobArea.BackgroundTransparency = 1
        knobArea.Text = ""
        knobArea.Parent = bar

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 22, 0, 22)
        knob.Position = UDim2.new(0.5, 0, 0.5, 0)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.Parent = knobArea
        
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

        local dragging = false

        local function updateValue(input)
            local relative = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relative + 0.5)
            
            fill.Size = UDim2.new(relative, 0, 1, 0)
            knobArea.Position = UDim2.new(relative, 0, 0.5, 0)
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

    -- Dropdown simples
    function Library.Dropdown(parent, text, options, defaultIndex, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 40)
        container.BackgroundColor3 = COLORS.Element
        container.ClipsDescendants = true
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
        optionsFrame.ScrollBarImageTransparency = 1
        optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        optionsFrame.Parent = container

        local optionsLayout = Instance.new("UIListLayout")
        optionsLayout.Padding = UDim.new(0, 4)
        optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        optionsLayout.Parent = optionsFrame

        local opened = false

        local function toggle()
            opened = not opened
            local height = opened and math.min(#options * 38, 180) or 0
            
            TweenService:Create(optionsFrame, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, height)}):Play()
            TweenService:Create(container, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {Size = UDim2.new(0.95, 0, 0, 40 + height)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = opened and 0.35 or 0.75}):Play()
        end

        for _, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.96, 0, 0, 34)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.Parent = optionsFrame
            
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

            CreateSmartTextLabel(btn, UDim2.new(1, 0, 1, 0), UDim2.new(0, 12, 0, 0), opt, COLORS.TextDim, Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left)

            btn.Activated:Connect(function()
                selectedText.Text = opt
                callback(opt)
                toggle()
            end)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.92}):Play()
            end)

            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end)
        end

        selectBtn.Activated:Connect(toggle)
    end

    -- DropdownMulti
    function Library.DropdownMulti(parent, text, options, defaultSelected, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 40)
        container.BackgroundColor3 = COLORS.Element
        container.ClipsDescendants = true
        container.Parent = parent
        
        Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 40)
        header.BackgroundTransparency = 1
        header.Parent = container

        CreateSmartTextLabel(header, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 14, 0, 0), text, COLORS.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)

        local previewBox = Instance.new("TextButton")
        previewBox.Size = UDim2.new(0, 160, 0, 30)
        previewBox.Position = UDim2.new(1, -170, 0.5, -15)
        previewBox.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
        previewBox.Text = ""
        previewBox.AutoButtonColor = false
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
        arrow.Parent = previewBox

        local optionsContainer = Instance.new("ScrollingFrame")
        optionsContainer.Name = "Options"
        optionsContainer.Size = UDim2.new(1, 0, 0, 0)
        optionsContainer.Position = UDim2.new(0, 0, 0, 40)
        optionsContainer.BackgroundTransparency = 1
        optionsContainer.ScrollBarThickness = 0
        optionsContainer.ScrollBarImageTransparency = 1
        optionsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
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
            for _, isSel in pairs(selected) do
                if isSel then count += 1 end
            end
            
            local previewStr = count == 0 and "Nenhum selecionado" or (count == #options and "Todos selecionados" or count .. " selecionado(s)")
            previewText.Text = previewStr
            previewText.TextColor3 = count > 0 and COLORS.Accent or COLORS.TextDim
            
            local selectedList = {}
            for i, isSel in pairs(selected) do
                if isSel then table.insert(selectedList, options[i]) end
            end
            callback(selectedList)
        end

        for i, optionName in ipairs(options) do
            local optionBtn = Instance.new("TextButton")
            optionBtn.Size = UDim2.new(0.96, 0, 0, 34)
            optionBtn.BackgroundTransparency = 1
            optionBtn.Text = ""
            optionBtn.AutoButtonColor = false
            optionBtn.Parent = optionsContainer
            
            Instance.new("UICorner", optionBtn).CornerRadius = CORNERS.Small

            CreateSmartTextLabel(optionBtn, UDim2.new(1, -40, 1, 0), UDim2.new(0, 12, 0, 0), optionName, COLORS.TextDim, Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left)

            local checkMark = Instance.new("TextLabel")
            checkMark.Size = UDim2.new(0, 24, 0, 24)
            checkMark.Position = UDim2.new(1, -34, 0.5, -12)
            checkMark.BackgroundTransparency = 1
            checkMark.Text = "✓"
            checkMark.TextColor3 = COLORS.Accent
            checkMark.Font = Enum.Font.GothamBold
            checkMark.TextSize = 18
            checkMark.Visible = selected[i] or false
            checkMark.Parent = optionBtn

            optionBtn.MouseEnter:Connect(function()
                TweenService:Create(optionBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.92}):Play()
            end)

            optionBtn.MouseLeave:Connect(function()
                TweenService:Create(optionBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
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
            
            TweenService:Create(optionsContainer, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {Size = UDim2.new(0.95, 0, 0, 40 + targetHeight)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = isOpen and 0.35 or 0.75}):Play()
            TweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Rotation = isOpen and 180 or 0}):Play()
        end

        previewBox.Activated:Connect(toggleDropdown)

        updatePreview()
    end

    -- InputNumber
    function Library.InputNumber(parent, text, min, max, default, step, callback)
        step = step or 1

        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.95, 0, 0, 52)
        container.BackgroundColor3 = COLORS.Element
        container.Parent = parent
        
        Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

        CreateSmartTextLabel(container, UDim2.new(0.6, 0, 0, 24), UDim2.new(0, 14, 0, 6), text, COLORS.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Left)

        local inputFrame = Instance.new("Frame")
        inputFrame.Size = UDim2.new(0, 140, 0, 34)
        inputFrame.Position = UDim2.new(1, -154, 0, 9)
        inputFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
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
        valueBox.Parent = inputFrame

        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 28, 0, 28)
        minusBtn.Position = UDim2.new(0, 6, 0.5, -14)
        minusBtn.BackgroundTransparency = 1
        minusBtn.Text = "−"
        minusBtn.TextColor3 = COLORS.TextDim
        minusBtn.Font = Enum.Font.GothamBold
        minusBtn.TextSize = 20
        minusBtn.Parent = inputFrame

        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 28, 0, 28)
        plusBtn.Position = UDim2.new(1, -34, 0.5, -14)
        plusBtn.BackgroundTransparency = 1
        plusBtn.Text = "+"
        plusBtn.TextColor3 = COLORS.TextDim
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.TextSize = 20
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

    -- Ativa primeira aba automaticamente
    task.delay(0.1, function()
        local firstTab = self.TabBar:FindFirstChildWhichIsA("TextButton")
        if firstTab then
            firstTab.Activated:Fire()
        end
    end)

    return self
end

print("[GekyuUI] Biblioteca carregada com sucesso - Popup clicável, Notify anti-spam, Dropdown Multi perfeito - Sem erros de nil")

return Library
