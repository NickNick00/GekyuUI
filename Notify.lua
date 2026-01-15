-- Notify.lua
-- Sistema de notificações no canto superior direito (tipo toast)

local TweenService = game:GetService("TweenService")

local COLORS = {
    Background    = Color3.fromRGB(18, 18, 28),
    Accent        = Color3.fromRGB(90, 170, 255),
    Text          = Color3.fromRGB(235, 235, 245),
}

local CORNERS = {
    Medium = UDim.new(0, 10),
}

local notificationHolder = nil

local function initHolder()
    if notificationHolder then return end
    
    local screenGui = game.CoreGui:FindFirstChild("GekyuPremiumUI")
    if not screenGui then return end

    notificationHolder = Instance.new("Frame")
    notificationHolder.Size = UDim2.new(0, 300, 1, 0)
    notificationHolder.Position = UDim2.new(1, -320, 0, 20)
    notificationHolder.BackgroundTransparency = 1
    notificationHolder.Parent = screenGui

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 12)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Right
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = notificationHolder
end

local function CreateNotify(message, duration, accentColor)
    -- duration padrão = 4 segundos
    duration = duration or 4
    accentColor = accentColor or COLORS.Accent

    initHolder()
    if not notificationHolder then return end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 68)
    notif.BackgroundColor3 = COLORS.Background
    notif.BackgroundTransparency = 1
    notif.Parent = notificationHolder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNERS.Medium
    corner.Parent = notif

    local stroke = Instance.new("UIStroke")
    stroke.Color = accentColor
    stroke.Transparency = 0.6
    stroke.Parent = notif

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, -20)
    text.Position = UDim2.new(0, 10, 0, 10)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = COLORS.Text
    text.Font = Enum.Font.GothamSemibold
    text.TextSize = 14
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.Parent = notif

    -- Animação de entrada
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, -20)
        }):Play()
        
        task.delay(0.5, function()
            notif:Destroy()
        end)
    end)
end

-- Função exportada
return function(message, duration, color)
    CreateNotify(message, duration, color)
end
