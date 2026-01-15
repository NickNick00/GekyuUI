-- Popup.lua
-- Componente: Janela popup central com título, mensagem e botões OK/Cancel

local TweenService = game:GetService("TweenService")

local COLORS = {
    Background    = Color3.fromRGB(10, 10, 16),
    Element       = Color3.fromRGB(18, 18, 28),
    Accent        = Color3.fromRGB(90, 170, 255),
    Text          = Color3.fromRGB(235, 235, 245),
}

local CORNERS = {
    Large = UDim.new(0, 14),
    Medium = UDim.new(0, 10),
}

local function CreatePopup(titleText, messageText, onConfirm, onCancel)
    -- onConfirm e onCancel são funções opcionais

    local screenGui = game.CoreGui:FindFirstChild("GekyuPremiumUI") or game.CoreGui:FindFirstChildWhichIsA("ScreenGui")
    if not screenGui then return end

    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 360, 0, 220)
    popup.Position = UDim2.new(0.5, -180, 0.5, -110)
    popup.BackgroundColor3 = COLORS.Background
    popup.BackgroundTransparency = 1
    popup.Parent = screenGui
    popup.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNERS.Large
    corner.Parent = popup

    -- Fundo escuro (overlay)
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Color3.new(0,0,0)
    overlay.BackgroundTransparency = 0.6
    overlay.Parent = screenGui

    -- Animação de entrada
    TweenService:Create(popup, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 360, 0, 220)
    }):Play()
    TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1,0,0,48)
    topBar.BackgroundColor3 = COLORS.Element
    topBar.Parent = popup

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = CORNERS.Large
    topCorner.Parent = topBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = COLORS.Accent
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar

    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -32, 0, 80)
    content.Position = UDim2.new(0, 16, 0, 60)
    content.BackgroundTransparency = 1
    content.Text = messageText
    content.TextColor3 = COLORS.Text
    content.Font = Enum.Font.Gotham
    content.TextSize = 15
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.Parent = popup

    -- Botões
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 140, 0, 42)
    cancelBtn.Position = UDim2.new(0.5, -150, 1, -60)
    cancelBtn.BackgroundColor3 = COLORS.Element
    cancelBtn.Text = "Cancelar"
    cancelBtn.TextColor3 = COLORS.TextDim
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 15
    cancelBtn.Parent = popup

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0, 140, 0, 42)
    confirmBtn.Position = UDim2.new(0.5, 10, 1, -60)
    confirmBtn.BackgroundColor3 = COLORS.Accent
    confirmBtn.Text = "Confirmar"
    confirmBtn.TextColor3 = Color3.new(1,1,1)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 15
    confirmBtn.Parent = popup

    local function closePopup()
        TweenService:Create(popup, TweenInfo.new(0.25), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 320, 0, 180)
        }):Play()
        TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        
        task.delay(0.25, function()
            popup:Destroy()
            overlay:Destroy()
        end)
    end

    cancelBtn.Activated:Connect(function()
        if onCancel then onCancel() end
        closePopup()
    end)

    confirmBtn.Activated:Connect(function()
        if onConfirm then onConfirm() end
        closePopup()
    end)

    -- Fecha ao clicar fora (opcional)
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            closePopup()
        end
    end)
end

return CreatePopup
