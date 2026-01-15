-- Toggle.lua
-- Componente: Toggle simples (on/off) - ideal para ativação de features únicas

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

local function CreateToggle(parent, text, defaultState, callback)
    -- parent     → o frame/pai onde o toggle vai ser adicionado (geralmente o content de uma aba)
    -- text       → nome da função/feature
    -- defaultState → true/false (estado inicial)
    -- callback   → function(state) chamada toda vez que muda o estado

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 48)
    container.BackgroundColor3 = COLORS.Element
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNERS.Medium
    corner.Parent = container

    -- Área clicável inteira
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.AutoButtonColor = false
    hitbox.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = COLORS.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    -- Track (barra do toggle)
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 52, 0, 26)
    track.Position = UDim2.new(1, -64, 0.5, -13)
    track.BackgroundColor3 = defaultState and COLORS.Accent or COLORS.TextDim
    track.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    -- Círculo que se move
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = defaultState and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    circle.AnchorPoint = Vector2.new(0, 0.5)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.Parent = track
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    local state = defaultState or false

    local function updateVisual()
        TweenService:Create(track, TweenInfo.new(0.24, Enum.EasingStyle.Quad), {
            BackgroundColor3 = state and COLORS.Accent or COLORS.TextDim
        }):Play()
        
        TweenService:Create(circle, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        }):Play()
    end

    hitbox.Activated:Connect(function()
        state = not state
        updateVisual()
        callback(state)
    end)

    -- Inicializa visual no estado default
    updateVisual()

    return container, function() return state end  -- retorna o objeto e uma função para pegar o estado atual
end

return CreateToggle
