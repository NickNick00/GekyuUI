-- InputNumber.lua
-- Componente: Caixa de input numérico com botões de + e - (ideal para valores como velocidade, distância, etc)

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local COLORS = {
    Element       = Color3.fromRGB(18, 18, 28),
    Accent        = Color3.fromRGB(90, 170, 255),
    Text          = Color3.fromRGB(235, 235, 245),
    TextDim       = Color3.fromRGB(150, 150, 175),
}

local CORNERS = {
    Medium = UDim.new(0, 10),
    Small  = UDim.new(0, 6),
}

local function CreateInputNumber(parent, text, min, max, default, step, callback)
    -- step = quanto aumenta/diminui por clique (padrão 1)
    step = step or 1

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 52)
    container.BackgroundColor3 = COLORS.Element
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNERS.Medium
    corner.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 0, 24)
    title.Position = UDim2.new(0, 14, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = COLORS.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    -- Caixa de valor + botões +/- 
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0, 140, 0, 34)
    inputFrame.Position = UDim2.new(1, -154, 0, 9)
    inputFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    inputFrame.Parent = container
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = CORNERS.Small
    inputCorner.Parent = inputFrame

    local valueBox = Instance.new("TextBox")
    valueBox.Size = UDim2.new(0, 80, 1, -4)
    valueBox.Position = UDim2.new(0.5, -40, 0.5, 0)
    valueBox.AnchorPoint = Vector2.new(0.5, 0.5)
    valueBox.BackgroundTransparency = 1
    valueBox.Text = tostring(default)
    valueBox.TextColor3 = COLORS.Accent
    valueBox.Font = Enum.Font.GothamBold
    valueBox.TextSize = 16
    valueBox.TextXAlignment = Enum.TextXAlignment.Center
    valueBox.Parent = inputFrame

    -- Botões + e -
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
        if num then
            currentValue = num
        end
    end)

    -- Inicializa
    updateValue(default)

    return container
end

return CreateInputNumber
