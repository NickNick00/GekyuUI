-- DropdownMulti.lua
-- Componente: Dropdown com múltipla seleção (pode escolher vários itens)
-- Ideal para opções como: ESP Parts, Team Checks, Weapon Categories, etc.

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
    Small  = UDim.new(0, 6),
}

local function CreateDropdownMulti(parent, text, options, defaultSelected, callback)
    -- defaultSelected = tabela com índices ou nomes que começam selecionados (opcional)
    -- callback = function(selectedTable)  -- recebe tabela com os itens atualmente selecionados

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 40)
    container.BackgroundColor3 = COLORS.Element
    container.ClipsDescendants = true
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNERS.Medium
    corner.Parent = container

    -- Cabeçalho sempre visível
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Parent = container

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 14, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = text
    titleLabel.TextColor3 = COLORS.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    -- Área que mostra os itens selecionados (ou "Selecionar...")
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

    local previewText = Instance.new("TextLabel")
    previewText.Size = UDim2.new(1, -36, 1, 0)
    previewText.Position = UDim2.new(0, 8, 0, 0)
    previewText.BackgroundTransparency = 1
    previewText.Font = Enum.Font.GothamSemibold
    previewText.TextColor3 = COLORS.TextDim
    previewText.TextSize = 12
    previewText.TextXAlignment = Enum.TextXAlignment.Left
    previewText.TextTruncate = Enum.TextTruncate.SplitWord
    previewText.Parent = previewBox

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 24, 1, 0)
    arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = COLORS.TextDim
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.Parent = previewBox

    -- Container das opções (expande)
    local optionsContainer = Instance.new("ScrollingFrame")
    optionsContainer.Name = "Options"
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.Position = UDim2.new(0, 0, 0, 40)
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.ScrollBarThickness = 3
    optionsContainer.ScrollBarImageColor3 = COLORS.Accent
    optionsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    optionsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    optionsContainer.Parent = container

    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Padding = UDim.new(0, 4)
    optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    optionsLayout.Parent = optionsContainer

    -- Estado interno
    local isOpen = false
    local selected = {} -- [index] = true

    -- Inicializa seleções padrão
    if defaultSelected then
        if type(defaultSelected) == "table" then
            for _, v in ipairs(defaultSelected) do
                if type(v) == "number" and v >= 1 and v <= #options then
                    selected[v] = true
                elseif type(v) == "string" then
                    for i, opt in ipairs(options) do
                        if opt == v then
                            selected[i] = true
                            break
                        end
                    end
                end
            end
        end
    end

    -- Atualiza texto de preview
    local function updatePreview()
        local count = 0
        local names = {}
        
        for i, opt in ipairs(options) do
            if selected[i] then
                count += 1
                table.insert(names, opt)
            end
        end
        
        if count == 0 then
            previewText.Text = "Nenhum selecionado"
            previewText.TextColor3 = COLORS.TextDim
        elseif count == 1 then
            previewText.Text = names[1]
            previewText.TextColor3 = COLORS.Accent
        elseif count == #options then
            previewText.Text = "Todos selecionados"
            previewText.TextColor3 = COLORS.Accent
        else
            previewText.Text = count .. " selecionado(s)"
            previewText.TextColor3 = COLORS.Accent
        end
        
        -- Chama callback com lista atual de selecionados
        local selectedList = {}
        for i, isSel in pairs(selected) do
            if isSel then
                table.insert(selectedList, options[i])
            end
        end
        callback(selectedList)
    end

    -- Cria cada opção
    for i, optionName in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(0.96, 0, 0, 34)
        optionBtn.BackgroundTransparency = 1
        optionBtn.Text = ""
        optionBtn.AutoButtonColor = false
        optionBtn.Parent = optionsContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = CORNERS.Small
        btnCorner.Parent = optionBtn

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -40, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = optionName
        label.TextColor3 = COLORS.TextDim
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = optionBtn

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
            TweenService:Create(optionBtn, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.92
            }):Play()
            TweenService:Create(label, TweenInfo.new(0.15), {
                TextColor3 = COLORS.Text
            }):Play()
        end)

        optionBtn.MouseLeave:Connect(function()
            TweenService:Create(optionBtn, TweenInfo.new(0.15), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(label, TweenInfo.new(0.15), {
                TextColor3 = selected[i] and COLORS.Text or COLORS.TextDim
            }):Play()
        end)

        optionBtn.Activated:Connect(function()
            selected[i] = not selected[i]
            checkMark.Visible = selected[i]
            
            TweenService:Create(label, TweenInfo.new(0.2), {
                TextColor3 = selected[i] and COLORS.Text or COLORS.TextDim
            }):Play()
            
            updatePreview()
        end)
    end

    -- Função de abrir/fechar
    local function toggleDropdown()
        isOpen = not isOpen
        
        local maxHeight = math.min(#options * 38 + 8, 220) -- limite razoável
        local targetHeight = isOpen and maxHeight or 0
        
        TweenService:Create(optionsContainer, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {
            Size = UDim2.new(1, 0, 0, targetHeight)
        }):Play()
        
        TweenService:Create(container, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0.95, 0, 0, 40 + targetHeight)
        }):Play()
        
        TweenService:Create(stroke, TweenInfo.new(0.3), {
            Transparency = isOpen and 0.35 or 0.75
        }):Play()
        
        TweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Rotation = isOpen and 180 or 0
        }):Play()
    end

    previewBox.Activated:Connect(toggleDropdown)

    -- Inicializa preview na criação
    updatePreview()

    -- Métodos úteis que você pode retornar se quiser usar fora
    local dropdown = {
        Container = container,
        Toggle = toggleDropdown,
        GetSelected = function()
            local list = {}
            for i, isSel in pairs(selected) do
                if isSel then table.insert(list, options[i]) end
            end
            return list
        end,
        SetSelected = function(newSelected)
            selected = {}
            for _, v in ipairs(newSelected) do
                for i, opt in ipairs(options) do
                    if opt == v or i == v then
                        selected[i] = true
                        break
                    end
                end
            end
            -- Atualiza visual dos checks
            for i = 1, #options do
                local btn = optionsContainer:GetChildren()[i]
                if btn and btn:IsA("TextButton") then
                    local check = btn:FindFirstChildWhichIsA("TextLabel", true)
                    if check then
                        check.Visible = selected[i] or false
                    end
                end
            end
            updatePreview()
        end
    }

    return dropdown
end

return CreateDropdownMulti
