-- Dropdown.lua
-- Componente: Dropdown simples (lista suspensa)

local TweenService = game:GetService("TweenService")

local COLORS = {
    Element       = Color3.fromRGB(18, 18, 28),
    Accent        = Color3.fromRGB(90, 170, 255),
    Text          = Color3.fromRGB(235, 235, 245),
    TextDim       = Color3.fromRGB(150, 150, 175),
    Stroke        = Color3.fromRGB(50, 50, 75),
}

local CORNERS = {
    Medium = UDim.new(0, 10),
}

local function CreateDropdown(parent, text, options, defaultIndex, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 40)
    container.BackgroundColor3 = COLORS.Element
    container.ClipsDescendants = true
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNERS.Medium
    corner.Parent = container

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = COLORS.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

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

    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(1, -12, 1, 0)
    selectedText.Position = UDim2.new(0, 6, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.Font = Enum.Font.GothamSemibold
    selectedText.TextColor3 = COLORS.Accent
    selectedText.TextSize = 13
    selectedText.TextXAlignment = Enum.TextXAlignment.Center
    selectedText.Text = options[defaultIndex or 1] or "Selecione..."
    selectedText.Parent = selectBtn

    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 0, 40)
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.ScrollBarThickness = 3
    optionsFrame.ScrollBarImageColor3 = COLORS.Accent
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
        
        TweenService:Create(optionsFrame, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {
            Size = UDim2.new(1, 0, 0, height)
        }):Play()
        
        TweenService:Create(container, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0.95, 0, 0, 40 + height)
        }):Play()
        
        TweenService:Create(stroke, TweenInfo.new(0.3), {
            Transparency = opened and 0.35 or 0.75
        }):Play()
    end

    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.96, 0, 0, 34)
        btn.BackgroundTransparency = 1
        btn.Text = opt
        btn.TextColor3 = COLORS.TextDim
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.Parent = optionsFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 7)
        btnCorner.Parent = btn

        btn.Activated:Connect(function()
            selectedText.Text = opt
            callback(opt)
            toggle() -- fecha ao selecionar
        end)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.92,
                TextColor3 = COLORS.Text
            }):Play()
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundTransparency = 1,
                TextColor3 = COLORS.TextDim
            }):Play()
        end)
    end

    selectBtn.Activated:Connect(toggle)

    return container
end

return CreateDropdown
