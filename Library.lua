-- Library.lua
-- Versão FINAL corrigida - sem requires internos para evitar nil em loadstring
-- Kyuzzy - 15/01/2026

local Library = {}
Library.__index = Library

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

-- Destroi UI antiga
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

-- Função auxiliar para botões do TopBar
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
        icon.Parent = btn
    end
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.AccentPress}):Play()
        if icon then TweenService:Create(icon, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360}):Play() end
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(15, 15, 21)}):Play()
        if icon then TweenService:Create(icon, TweenInfo.new(0.3), {Rotation = 0}):Play() end
    end)
    
    btn.Activated:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = COLORS.Accent}):Play()
        if icon then
            TweenService:Create(icon, TweenInfo.new(0.15), {Size = UDim2.new(0,28,0,28)}):Play()
            task.delay(0.15, function()
                TweenService:Create(icon, TweenInfo.new(0.15), {Size = UDim2.new(0,24,0,24)}):Play()
            end)
        end
        task.delay(0.12, function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(15, 15, 21)}):Play()
        end)
        callback()
    end)
    
    return btn
end

function Library:CreateWindow(title)
    local self = setmetatable({}, Library)
    
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

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.5,0,1,0)
    titleLabel.Position = UDim2.new(0,18,0,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.Text = title or "GEKYU • PREMIUM"
    titleLabel.TextColor3 = COLORS.Accent
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = TopBar

    -- Drag
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

    -- Botões TopBar
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
        print("Config hub aberto")
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

    -- Tabs
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

    -- Content Area
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
        
        return content
    end

    task.delay(0.1, function()
        local firstTab = self.TabBar:FindFirstChildWhichIsA("TextButton")
        if firstTab then firstTab.Activated:Fire() end
    end)

    return self
end

-- Função para carregar componentes (chame depois do loadstring)
function Library:LoadComponents()
    -- Lista com nomes exatos dos seus arquivos na pasta Components/
    local comps = {
        Button = "button.lua",
        Toggle = "toggle.lua",
        Slider = "Slider.lua",
        Dropdown = "Dropdown.lua",
        DropdownMulti = "DropdownMulti.lua",
        InputNumber = "inputNumber.lua",
        Notify = "Notify.lua",
        Popup = "popup.lua",
        ToggleWithCheckboxes = "toggl&checkox.lua"  -- ajuste se o nome for diferente (ex: "toggle&checkbox.lua")
    }

    for name, file in pairs(comps) do
        local success, result = pcall(function()
            -- Aqui usamos um caminho que funciona em loadstring (ajuste se necessário)
            -- Se você estiver executando em executor que carrega tudo como LocalScript, use game.Players.LocalPlayer.PlayerGui ou outro local
            return require(script.Parent.Components[file])
        end)

        if success then
            Library[name] = result
            print("[GekyuUI] Carregado: " .. name .. " (" .. file .. ")")
        else
            warn("[GekyuUI] Falha ao carregar " .. file .. ": " .. tostring(result))
        end
    end
end

print("[GekyuUI] Library carregada. Chame :LoadComponents() para ativar os módulos")

return Library
