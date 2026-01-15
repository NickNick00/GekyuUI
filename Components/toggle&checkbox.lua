-- ToggleWithCheckboxes.lua
-- Componente: Toggle que expande e mostra vários checkboxes quando ativado

local TweenService = game:GetService("TweenService")

local COLORS = {
    Element       = Color3.fromRGB(18, 18, 28),
    Accent        = Color3.fromRGB(90, 170, 255),
    Text          = Color3.fromRGB(235, 235, 245),
    TextDim       = Color3.fromRGB(150, 150, 175),
}

local CORNERS = {
    Medium = UDim.new(0, 10),
}

local function CreateToggleWithCheckboxes(parent, toggleText, checkboxesList, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 40)
    container.BackgroundColor3 = COLORS.Element
    container.ClipsDescendants = true
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNERS.Medium
    corner.Parent = container

    -- Cabeçalho (parte sempre visível)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Parent = container

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -90, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = toggleText
    titleLabel.TextColor3 = COLORS.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    -- Toggle visual
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 44, 0, 22)
    track.Position = UDim2.new(1, -55, 0.5, -11)
    track.BackgroundColor3 = COLORS.TextDim
    track.Parent = header
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1,1,1)
    circle.Parent = track
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    -- Área dos checkboxes (expande quando toggle ligado)
    local checkboxesContainer = Instance.new("Frame")
    checkboxesContainer.Name = "CheckboxesContainer"
    checkboxesContainer.Size = UDim2.new(1, 0, 0, 0)
    checkboxesContainer.Position = UDim2.new(0, 0, 0, 40)
    checkboxesContainer.BackgroundTransparency = 1
    checkboxesContainer.Parent = container

    local checkListLayout = Instance.new("UIListLayout")
    checkListLayout.Padding = UDim.new(0, 6)
    checkListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    checkListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    checkListLayout.Parent = checkboxesContainer

    local toggleState = false

    -- Criação dos checkboxes
    local checkboxStates = {}

    for i, checkName in ipairs(checkboxesList) do
        local checkFrame = Instance.new("Frame")
        checkFrame.Size = UDim2.new(0.92, 0, 0, 32)
        checkFrame.BackgroundTransparency = 1
        checkFrame.Parent = checkboxesContainer

        local checkLabel = Instance.new("TextLabel")
        checkLabel.Size = UDim2.new(1, -60, 1, 0)
        checkLabel.Position = UDim2.new(0, 12, 0, 0)
        checkLabel.BackgroundTransparency = 1
        checkLabel.Text = checkName
        checkLabel.TextColor3 = COLORS.TextDim
        checkLabel.Font = Enum.Font.GothamSemibold
        checkLabel.TextSize = 13
        checkLabel.TextXAlignment = Enum.TextXAlignment.Left
        checkLabel.Parent = checkFrame

        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(0, 38, 0, 38)
        hitbox.Position = UDim2.new(1, -45, 0.5, -19)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = checkFrame

        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 20, 0, 20)
        box.Position = UDim2.new(0.5, -10, 0.5, -10)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        box.Parent = hitbox
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 5)
        boxCorner.Parent = box

        local mark = Instance.new("TextLabel")
        mark.Size = UDim2.new(1, 0, 1, 0)
        mark.BackgroundTransparency = 1
        mark.Text = "✓"
        mark.TextColor3 = Color3.new(1,1,1)
        mark.Font = Enum.Font.GothamBold
        mark.TextSize = 16
        mark.Visible = false
        mark.Parent = box

        local cState = false
        checkboxStates[i] = function() return cState end

        hitbox.Activated:Connect(function()
            cState = not cState
            mark.Visible = cState
            
            TweenService:Create(box, TweenInfo.new(0.18), {
                BackgroundColor3 = cState and COLORS.Accent or Color3.fromRGB(40, 40, 60)
            }):Play()
        end)
    end

    -- Clique no toggle principal
    local function toggle()
        toggleState = not toggleState
        
        TweenService:Create(track, TweenInfo.new(0.24), {
            BackgroundColor3 = toggleState and COLORS.Accent or COLORS.TextDim
        }):Play()
        
        TweenService:Create(circle, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = toggleState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()

        local contentHeight = #checkboxesList * 38 + 12
        local finalHeight = toggleState and (40 + contentHeight) or 40

        TweenService:Create(container, TweenInfo.new(0.38, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0.95, 0, 0, finalHeight)
        }):Play()

        callback(toggleState)
    end

    -- Área clicável do toggle inteiro
    local toggleHitbox = Instance.new("TextButton")
    toggleHitbox.Size = UDim2.new(1, 0, 0, 40)
    toggleHitbox.BackgroundTransparency = 1
    toggleHitbox.Text = ""
    toggleHitbox.Parent = header
    toggleHitbox.Activated:Connect(toggle)

    return container, function() return toggleState end, checkboxStates
end

return CreateToggleWithCheckboxes
