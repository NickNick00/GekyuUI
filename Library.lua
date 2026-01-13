-- Library.lua
-- https://raw.githubusercontent.com/NickNick00/GekyuUI/main/Library.lua

local Library = {}
Library.__index = Library

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

if CoreGui:FindFirstChild("GekyuPremiumUI") then
    CoreGui.GekyuPremiumUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GekyuPremiumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = CoreGui

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
}

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
    local window = setmetatable({}, Library)
    
    window.MainFrame = Instance.new("Frame")
    window.MainFrame.Size = UDim2.new(0, 480, 0, 520)
    window.MainFrame.Position = UDim2.new(0.5, -240, 0.5, -260)
    window.MainFrame.BackgroundColor3 = COLORS.Background
    window.MainFrame.BorderSizePixel = 0
    window.MainFrame.ClipsDescendants = true
    window.MainFrame.Parent = ScreenGui

    Instance.new("UICorner", window.MainFrame).CornerRadius = CORNERS.Large

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = COLORS.Stroke
    uiStroke.Transparency = 0.65
    uiStroke.Parent = window.MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1,0,0,48)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = window.MainFrame

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

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function update(input)
        local delta = input.Position - dragStart
        TweenService:Create(window.MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.MainFrame.Position
            
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

    CreateControlButton(TopBar, "X", -52, nil, function()
        ScreenGui:Destroy()
    end)

    local minimized = false
    local minimizeBtn = CreateControlButton(TopBar, "−", -102, nil, function()
        minimized = not minimized
        if minimized then
            window.MainFrame:TweenSize(UDim2.new(0,480,0,48), "Out", "Quint", 0.28, true)
            minimizeBtn.Text = "+"
        else
            window.MainFrame:TweenSize(UDim2.new(0,480,0,520), "Out", "Quint", 0.28, true)
            minimizeBtn.Text = "−"
        end
    end)

    -- Config Hub pequeno
    local ConfigHub = nil
    local configOpen = false

    local function ToggleConfigHub()
        if ConfigHub then
            configOpen = not configOpen
            ConfigHub.Visible = configOpen
            window.SearchBar.Visible = not configOpen
            window.TabBar.Visible = not configOpen
            window.ContentArea.Visible = not configOpen
            return
        end

        ConfigHub = Instance.new("Frame")
        ConfigHub.Size = UDim2.new(0, 320, 0, 380)
        ConfigHub.Position = UDim2.new(0.5, -160, 0.5, -190)
        ConfigHub.BackgroundColor3 = COLORS.Background
        ConfigHub.BorderSizePixel = 0
        ConfigHub.ClipsDescendants = true
        ConfigHub.Visible = true
        ConfigHub.Parent = ScreenGui

        Instance.new("UICorner", ConfigHub).CornerRadius = CORNERS.Large

        local stroke = Instance.new("UIStroke")
        stroke.Color = COLORS.Stroke
        stroke.Transparency = 0.65
        stroke.Parent = ConfigHub

        local ConfigTop = Instance.new("Frame")
        ConfigTop.Size = UDim2.new(1,0,0,42)
        ConfigTop.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
        ConfigTop.BorderSizePixel = 0
        ConfigTop.Parent = ConfigHub

        Instance.new("UICorner", ConfigTop).CornerRadius = CORNERS.Large

        local configTitle = Instance.new("TextLabel")
        configTitle.Size = UDim2.new(1, -16, 1, 0)
        configTitle.Position = UDim2.new(0, 12, 0, 0)
        configTitle.BackgroundTransparency = 1
        configTitle.Font = Enum.Font.GothamBlack
        configTitle.Text = "GEKYU | CONFIG"
        configTitle.TextColor3 = COLORS.Accent
        configTitle.TextSize = 17
        configTitle.TextXAlignment = Enum.TextXAlignment.Left
        configTitle.Parent = ConfigTop

        CreateControlButton(ConfigTop, "", -54, "rbxassetid://133102912527371", function()
            configOpen = false
            ConfigHub.Visible = false
            window.SearchBar.Visible = true
            window.TabBar.Visible = true
            window.ContentArea.Visible = true
        end).Position = UDim2.new(1, -54, 0.5, -21)

        local ConfigTabBar = Instance.new("Frame")
        ConfigTabBar.Size = UDim2.new(1,0,0,40)
        ConfigTabBar.Position = UDim2.new(0,0,0,42)
        ConfigTabBar.BackgroundTransparency = 1
        ConfigTabBar.Parent = ConfigHub

        local tabLayout = Instance.new("UIListLayout")
        tabLayout.FillDirection = Enum.FillDirection.Horizontal
        tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        tabLayout.Padding = UDim.new(0,12)
        tabLayout.Parent = ConfigTabBar

        local ConfigContent = Instance.new("Frame")
        ConfigContent.Size = UDim2.new(1,0,1,-82)
        ConfigContent.Position = UDim2.new(0,0,0,82)
        ConfigContent.BackgroundTransparency = 1
        ConfigContent.Parent = ConfigHub

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0,10)
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = ConfigContent

        local currentConfigTab = nil

        local function CreateConfigTab(name, isFirst)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 100, 0, 32)
            btn.BackgroundColor3 = COLORS.Element
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.GothamBold
            btn.Text = name
            btn.TextColor3 = isFirst and COLORS.Text or COLORS.TextDim
            btn.TextSize = 14
            btn.AutoButtonColor = false
            btn.Parent = ConfigTabBar
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

            local contentFrame = Instance.new("ScrollingFrame")
            contentFrame.Size = UDim2.new(1,0,1,0)
            contentFrame.BackgroundTransparency = 1
            contentFrame.ScrollBarThickness = 3
            contentFrame.ScrollBarImageColor3 = COLORS.Accent
            contentFrame.Visible = isFirst
            contentFrame.Parent = ConfigContent

            btn.Activated:Connect(function()
                if currentConfigTab then
                    currentConfigTab.content.Visible = false
                    currentConfigTab.button.TextColor3 = COLORS.TextDim
                    currentConfigTab.button.BackgroundColor3 = COLORS.Element
                end
                contentFrame.Visible = true
                btn.TextColor3 = COLORS.Text
                btn.BackgroundColor3 = COLORS.ElementHover
                currentConfigTab = {button = btn, content = contentFrame}
            end)

            btn.MouseEnter:Connect(function()
                if contentFrame.Visible then return end
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.ElementHover, TextColor3 = COLORS.Text}):Play()
            end)

            btn.MouseLeave:Connect(function()
                if contentFrame.Visible then return end
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Element, TextColor3 = COLORS.TextDim}):Play()
            end)

            return contentFrame
        end

        local InfoTab = CreateConfigTab("Info", true)
        local SettingsTab = CreateConfigTab("Config", false)
        currentConfigTab = {button = ConfigTabBar:FindFirstChildWhichIsA("TextButton"), content = InfoTab}

        -- Conteúdo Info
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(0.92, 0, 0, 180)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "GEKYU PREMIUM\n\nVersão: 1.0\nData: Janeiro 2026\nDesenvolvedor: Kyuzzy\nDiscord: em breve"
        infoLabel.TextColor3 = COLORS.Text
        infoLabel.TextSize = 15
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextYAlignment = Enum.TextYAlignment.Top
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.TextWrapped = true
        infoLabel.Parent = InfoTab

        -- Conteúdo Config (exemplo)
        local configLabel = Instance.new("TextLabel")
        configLabel.Size = UDim2.new(0.92, 0, 0, 40)
        configLabel.BackgroundTransparency = 1
        configLabel.Text = "Configurações em breve..."
        configLabel.TextColor3 = COLORS.TextDim
        configLabel.TextSize = 14
        configLabel.Font = Enum.Font.GothamBold
        configLabel.Parent = SettingsTab

        configOpen = true
    end

    CreateControlButton(TopBar, "", -152, "rbxassetid://133102912527371", ToggleConfigHub)

    window.SearchBar = Instance.new("Frame")
    window.SearchBar.Size = UDim2.new(0,140-12,0,32)
    window.SearchBar.Position = UDim2.new(0,6,0,48+8)
    window.SearchBar.BackgroundColor3 = COLORS.Element
    window.SearchBar.Parent = window.MainFrame
    Instance.new("UICorner", window.SearchBar).CornerRadius = CORNERS.Medium

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
    SearchBox.Parent = window.SearchBar

    window.TabBar = Instance.new("ScrollingFrame")
    window.TabBar.Size = UDim2.new(0,140,1,-100)
    window.TabBar.Position = UDim2.new(0,0,0,100)
    window.TabBar.BackgroundTransparency = 1
    window.TabBar.ScrollBarThickness = 0
    window.TabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    window.TabBar.ScrollingDirection = Enum.ScrollingDirection.Y
    window.TabBar.Parent = window.MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0,8)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = window.TabBar

    window.TabBar:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
        local needed = TabLayout.AbsoluteContentSize.Y + 20
        if needed > window.TabBar.AbsoluteSize.Y then
            window.TabBar.ScrollBarThickness = 3
            window.TabBar.ScrollBarImageTransparency = 0.6
            window.TabBar.ScrollBarImageColor3 = COLORS.Accent
        else
            window.TabBar.ScrollBarThickness = 0
            window.TabBar.ScrollBarImageTransparency = 1
        end
    end)

    window.ContentArea = Instance.new("ScrollingFrame")
    window.ContentArea.Size = UDim2.new(1, -152, 1, -100)
    window.ContentArea.Position = UDim2.new(0, 148, 0, 96)
    window.ContentArea.BackgroundTransparency = 1
    window.ContentArea.ScrollBarThickness = 0 
    window.ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    window.ContentArea.Parent = window.MainFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 12)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = window.ContentArea

    local currentTab = nil

    function window:CreateTab(name)
        local tab = {}

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
        button.Parent = window.TabBar
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
        content.Parent = window.ContentArea
        
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
            if currentTab then
                currentTab.content.Visible = false
                TweenService:Create(currentTab.indicator, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                currentTab.button:FindFirstChild("TextLabel").TextColor3 = COLORS.TextDim
                TweenService:Create(currentTab.button, TweenInfo.new(0.25), {BackgroundColor3 = COLORS.Element}):Play()
            end
            
            content.Visible = true
            TweenService:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back), {BackgroundTransparency = 0, Size = UDim2.new(0,4,0.9,0)}):Play()
            textLabel.TextColor3 = COLORS.Text
            TweenService:Create(button, TweenInfo.new(0.15), {Size = UDim2.new(1,-12,0,50)}):Play()
            task.delay(0.15, function()
                TweenService:Create(button, TweenInfo.new(0.15), {Size = UDim2.new(1,-16,0,46)}):Play()
            end)
            TweenService:Create(button, TweenInfo.new(0.25), {BackgroundColor3 = COLORS.ElementHover}):Play()
            
            currentTab = {button = button, content = content, indicator = indicator, textLabel = textLabel}
        end)

        function tab:Toggle(options)
            local name = options.Name or "Toggle"
            local checkboxes = options.Checkboxes or {}
            local callback = options.Callback or function() end
            
            local container = Instance.new("Frame")
            container.Size = UDim2.new(0.95, 0, 0, 40)
            container.BackgroundColor3 = COLORS.Element
            container.ClipsDescendants = true
            container.Parent = content
            Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, 0, 0, 40)
            header.BackgroundTransparency = 1
            header.Parent = container

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -80, 1, 0)
            titleLabel.Position = UDim2.new(0, 15, 0, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = name
            titleLabel.TextColor3 = COLORS.Text
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = header

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1, 0, 1, 0)
            toggleBtn.BackgroundTransparency = 1
            toggleBtn.Text = ""
            toggleBtn.Parent = header

            local track = Instance.new("Frame")
            track.Size = UDim2.new(0, 44, 0, 22)
            track.Position = UDim2.new(1, -55, 0.5, -11)
            track.BackgroundColor3 = COLORS.TextDim
            track.Parent = header
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 16, 0, 16)
            circle.Position = UDim2.new(0, 3, 0.5, -8)
            circle.BackgroundColor3 = Color3.new(1, 1, 1)
            circle.Parent = track
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            local checkboxesContainer = Instance.new("Frame")
            checkboxesContainer.Size = UDim2.new(1, 0, 0, 0)
            checkboxesContainer.Position = UDim2.new(0, 0, 0, 40)
            checkboxesContainer.BackgroundTransparency = 1
            checkboxesContainer.Parent = container

            local checkListLayout = Instance.new("UIListLayout")
            checkListLayout.Padding = UDim.new(0, 5)
            checkListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            checkListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            checkListLayout.Parent = checkboxesContainer

            local state = false

            for _, checkName in ipairs(checkboxes) do
                local checkFrame = Instance.new("Frame")
                checkFrame.Size = UDim2.new(0.9, 0, 0, 30)
                checkFrame.BackgroundTransparency = 1
                checkFrame.Parent = checkboxesContainer

                local checkLabel = Instance.new("TextLabel")
                checkLabel.Size = UDim2.new(1, -60, 1, 0)
                checkLabel.Position = UDim2.new(0, 10, 0, 0)
                checkLabel.BackgroundTransparency = 1
                checkLabel.Text = checkName
                checkLabel.TextColor3 = COLORS.TextDim
                checkLabel.Font = Enum.Font.GothamBold
                checkLabel.TextSize = 13
                checkLabel.TextXAlignment = Enum.TextXAlignment.Left
                checkLabel.Parent = checkFrame

                local checkHitbox = Instance.new("TextButton")
                checkHitbox.Size = UDim2.new(0, 45, 0, 45)
                checkHitbox.Position = UDim2.new(1, -42, 0.5, -22)
                checkHitbox.BackgroundTransparency = 1
                checkHitbox.Text = ""
                checkHitbox.Parent = checkFrame

                local checkBoxVisual = Instance.new("Frame")
                checkBoxVisual.Size = UDim2.new(0, 20, 0, 20)
                checkBoxVisual.Position = UDim2.new(0.5, -10, 0.5, -10)
                checkBoxVisual.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                checkBoxVisual.Parent = checkHitbox
                Instance.new("UICorner", checkBoxVisual).CornerRadius = UDim.new(0, 4)

                local checkMark = Instance.new("TextLabel")
                checkMark.Size = UDim2.new(1, 0, 1, 0)
                checkMark.BackgroundTransparency = 1
                checkMark.Text = "✓"
                checkMark.TextColor3 = Color3.new(1, 1, 1)
                checkMark.Font = Enum.Font.GothamBold
                checkMark.TextSize = 14
                checkMark.Visible = false
                checkMark.Parent = checkBoxVisual

                local cState = false
                checkHitbox.Activated:Connect(function()
                    cState = not cState
                    checkMark.Visible = cState
                    
                    TweenService:Create(checkBoxVisual, TweenInfo.new(0.2), {
                        BackgroundColor3 = cState and COLORS.Accent or Color3.fromRGB(40, 40, 60)
                    }):Play()
                end)
            end

            toggleBtn.Activated:Connect(function()
                state = not state
                
                TweenService:Create(track, TweenInfo.new(0.25), {BackgroundColor3 = state and COLORS.Accent or COLORS.TextDim}):Play()
                TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
                    Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                }):Play()

                local targetContentHeight = #checkboxes * 35 + 10
                local finalHeight = state and (40 + targetContentHeight) or 40

                TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                    Size = UDim2.new(0.95, 0, 0, finalHeight)
                }):Play()

                callback(state)
            end)
        end

        function tab:Slider(options)
            local name = options.Name or "Slider"
            local min = options.Min or 0
            local max = options.Max or 100
            local default = options.Default or 50
            local callback = options.Callback or function() end
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0.95, 0, 0, 60)
            frame.BackgroundColor3 = COLORS.Element
            frame.Parent = content
            Instance.new("UICorner", frame).CornerRadius = CORNERS.Medium
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, 0, 0, 30)
            label.Position = UDim2.new(0, 15, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = COLORS.Text
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.3, 0, 0, 30)
            valueLabel.Position = UDim2.new(0.65, 0, 0, 5)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = COLORS.Accent
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 14
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = frame
            
            local sliderBar = Instance.new("TextButton")
            sliderBar.Name = "SliderBar"
            sliderBar.Size = UDim2.new(0.9, 0, 0, 6)
            sliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
            sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            sliderBar.Text = ""
            sliderBar.AutoButtonColor = false
            sliderBar.Parent = frame
            Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
            fill.BackgroundColor3 = COLORS.Accent
            fill.BorderSizePixel = 0
            fill.Parent = sliderBar
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            
            local knobHitbox = Instance.new("TextButton")
            knobHitbox.Size = UDim2.new(0, 40, 0, 40)
            knobHitbox.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
            knobHitbox.AnchorPoint = Vector2.new(0.5, 0.5)
            knobHitbox.BackgroundTransparency = 1
            knobHitbox.Text = ""
            knobHitbox.Parent = sliderBar

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 20, 0, 20)
            knob.Position = UDim2.new(0.5, 0, 0.5, 0)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.Parent = knobHitbox
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local dragging = false

            local function update(input)
                local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                
                fill.Size = UDim2.new(pos, 0, 1, 0)
                knobHitbox.Position = UDim2.new(pos, 0, 0.5, 0)
                valueLabel.Text = tostring(value)
                
                callback(value)
            end

            knobHitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        function tab:Dropdown(options)
            local name = options.Name or "Dropdown"
            local opts = options.Options or {}
            local default = options.Default or 1
            local callback = options.Callback or function() end
            
            local container = Instance.new("Frame")
            container.Size = UDim2.new(0.95, 0, 0, 40)
            container.BackgroundColor3 = COLORS.Element
            container.ClipsDescendants = true
            container.Parent = content
            Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, 0, 0, 40)
            header.BackgroundTransparency = 1
            header.Parent = container

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(0, 100, 1, 0)
            titleLabel.Position = UDim2.new(0, 15, 0, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = name
            titleLabel.TextColor3 = COLORS.Text
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = header

            local selectBox = Instance.new("TextButton")
            selectBox.Size = UDim2.new(0, 120, 0, 28)
            selectBox.Position = UDim2.new(1, -135, 0.5, -14)
            selectBox.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
            selectBox.Text = ""
            selectBox.AutoButtonColor = false
            selectBox.Parent = header
            
            local selectStroke = Instance.new("UIStroke")
            selectStroke.Color = COLORS.Stroke
            selectStroke.Transparency = 0.8
            selectStroke.Parent = selectBox
            
            Instance.new("UICorner", selectBox).CornerRadius = UDim.new(0, 8)

            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(1, -10, 1, 0)
            selectedLabel.Position = UDim2.new(0, 5, 0, 0)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Font = Enum.Font.GothamBold
            selectedLabel.TextColor3 = COLORS.Accent
            selectedLabel.TextSize = 12
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Center
            selectedLabel.Text = opts[default] or "Nenhum"
            selectedLabel.Parent = selectBox

            local scrollOptions = Instance.new("ScrollingFrame")
            scrollOptions.Name = "OptionsScroll"
            scrollOptions.Size = UDim2.new(1, 0, 0, 0)
            scrollOptions.Position = UDim2.new(0, 0, 0, 40)
            scrollOptions.BackgroundTransparency = 1
            scrollOptions.ScrollBarThickness = 2
            scrollOptions.ScrollBarImageColor3 = COLORS.Accent
            scrollOptions.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scrollOptions.CanvasSize = UDim2.new(0, 0, 0, 0)
            scrollOptions.Parent = container

            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.Padding = UDim.new(0, 3)
            optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            optionsLayout.Parent = scrollOptions

            local isOpen = false

            local function toggleDropdown()
                isOpen = not isOpen
                local targetScrollHeight = isOpen and math.min(#opts * 36, 150) or 0
                local targetContainerHeight = 40 + targetScrollHeight

                TweenService:Create(scrollOptions, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, targetScrollHeight)}):Play()
                TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0.95, 0, 0, targetContainerHeight)}):Play()
                TweenService:Create(selectStroke, TweenInfo.new(0.3), {Transparency = isOpen and 0.4 or 0.8}):Play()
            end

            for _, opt in ipairs(opts) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.96, 0, 0, 34)
                btn.BackgroundTransparency = 1
                btn.BackgroundColor3 = COLORS.Accent
                btn.Font = Enum.Font.GothamBold
                btn.Text = opt
                btn.TextColor3 = COLORS.TextDim
                btn.TextSize = 13
                btn.AutoButtonColor = false
                btn.Parent = scrollOptions
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                
                btn.Activated:Connect(function()
                    selectedLabel.Text = opt
                    selectedLabel.TextColor3 = COLORS.Accent
                    callback(opt)
                end)

                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, TextColor3 = COLORS.Text}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = COLORS.TextDim}):Play()
                end)
            end

            selectBox.Activated:Connect(toggleDropdown)
        end

        function tab:MultiDropdown(options)
            local name = options.Name or "Multi Dropdown"
            local opts = options.Options or {}
            local callback = options.Callback or function() end
            
            local container = Instance.new("Frame")
            container.Size = UDim2.new(0.95, 0, 0, 40)
            container.BackgroundColor3 = COLORS.Element
            container.ClipsDescendants = true
            container.Parent = content
            Instance.new("UICorner", container).CornerRadius = CORNERS.Medium

            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, 0, 0, 40)
            header.BackgroundTransparency = 1
            header.Parent = container

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(0, 100, 1, 0)
            titleLabel.Position = UDim2.new(0, 15, 0, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = name
            titleLabel.TextColor3 = COLORS.Text
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = header

            local selectBox = Instance.new("TextButton")
            selectBox.Size = UDim2.new(0, 120, 0, 28)
            selectBox.Position = UDim2.new(1, -135, 0.5, -14)
            selectBox.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
            selectBox.Text = ""
            selectBox.AutoButtonColor = false
            selectBox.Parent = header
            
            local selectStroke = Instance.new("UIStroke")
            selectStroke.Color = COLORS.Stroke
            selectStroke.Transparency = 0.8
            selectStroke.Parent = selectBox
            
            Instance.new("UICorner", selectBox).CornerRadius = UDim.new(0, 8)

            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Size = UDim2.new(1, -10, 1, 0)
            selectedLabel.Position = UDim2.new(0, 5, 0, 0)
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.Font = Enum.Font.GothamBold
            selectedLabel.TextColor3 = COLORS.Accent
            selectedLabel.TextSize = 12
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Center
            selectedLabel.Text = "Selecionar..."
            selectedLabel.Parent = selectBox

            local scrollOptions = Instance.new("ScrollingFrame")
            scrollOptions.Name = "OptionsScroll"
            scrollOptions.Size = UDim2.new(1, 0, 0, 0)
            scrollOptions.Position = UDim2.new(0, 0, 0, 40)
            scrollOptions.BackgroundTransparency = 1
            scrollOptions.ScrollBarThickness = 2
            scrollOptions.ScrollBarImageColor3 = COLORS.Accent
            scrollOptions.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scrollOptions.CanvasSize = UDim2.new(0, 0, 0, 0)
            scrollOptions.Parent = container

            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.Padding = UDim.new(0, 3)
            optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            optionsLayout.Parent = scrollOptions

            local isOpen = false
            local selectedOptions = {}

            local function toggleDropdown()
                isOpen = not isOpen
                local targetScrollHeight = isOpen and math.min(#opts * 36, 150) or 0
                local targetContainerHeight = 40 + targetScrollHeight

                TweenService:Create(scrollOptions, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, targetScrollHeight)}):Play()
                TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0.95, 0, 0, targetContainerHeight)}):Play()
                TweenService:Create(selectStroke, TweenInfo.new(0.3), {Transparency = isOpen and 0.4 or 0.8}):Play()
            end

            local function updateSelectedDisplay()
                if #selectedOptions == 0 then
                    selectedLabel.Text = "Selecionar..."
                elseif #selectedOptions == 1 then
                    selectedLabel.Text = selectedOptions[1]
                else
                    selectedLabel.Text = #selectedOptions .. " selecionados"
                end
                
                callback(selectedOptions)
            end

            for _, opt in ipairs(opts) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.96, 0, 0, 34)
                btn.BackgroundTransparency = 1
                btn.BackgroundColor3 = COLORS.Accent
                btn.Font = Enum.Font.GothamBold
                btn.Text = opt
                btn.TextColor3 = COLORS.TextDim
                btn.TextSize = 13
                btn.AutoButtonColor = false
                btn.Parent = scrollOptions
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                
                local selected = false
                
                btn.Activated:Connect(function()
                    selected = not selected
                    btn.TextColor3 = selected and COLORS.Accent or COLORS.TextDim
                    btn.BackgroundTransparency = selected and 0.85 or 1
                    
                    if selected then
                        table.insert(selectedOptions, opt)
                    else
                        for j, v in ipairs(selectedOptions) do
                            if v == opt then
                                table.remove(selectedOptions, j)
                                break
                            end
                        end
                    end
                    
                    updateSelectedDisplay()
                end)

                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, TextColor3 = COLORS.Text}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = selected and 0.85 or 1, TextColor3 = selected and COLORS.Accent or COLORS.TextDim}):Play()
                end)
            end

            selectBox.Activated:Connect(toggleDropdown)
        end

        return tab
    end

    local firstTab = window.TabBar:FindFirstChildWhichIsA("TextButton")
    if firstTab then firstTab:Activate() end

    return window
end

return Library
