-- Button.lua
-- Componente: Botão simples com efeito de clique e hover bem legal

local TweenService = game:GetService("TweenService")

local COLORS = {
    Element       = Color3.fromRGB(18, 18, 28),
    ElementHover  = Color3.fromRGB(28, 28, 44),
    Accent        = Color3.fromRGB(90, 170, 255),
    AccentPress   = Color3.fromRGB(110, 190, 255),
    Text          = Color3.fromRGB(235, 235, 245),
}

local CORNERS = {
    Medium = UDim.new(0, 10),
}

local function CreateButton(parent, text, callback, options)
    -- options é opcional: {icon = "rbxassetid://...", size = UDim2, textSize = number}
    options = options or {}

    local button = Instance.new("TextButton")
    button.Size = options.size or UDim2.new(0.95, 0, 0, 48)
    button.BackgroundColor3 = COLORS.Element
    button.AutoButtonColor = false
    button.Text = ""
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNERS.Medium
    corner.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, options.icon and -60 or 0, 1, 0)
    label.Position = UDim2.new(0, options.icon and 16 or 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = options.textSize or 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button

    -- Ícone (opcional)
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

    -- Efeitos
    local function onEnter()
        TweenService:Create(button, TweenInfo.new(0.18), {
            BackgroundColor3 = COLORS.ElementHover
        }):Play()
        if icon then
            TweenService:Create(icon, TweenInfo.new(0.3), {
                ImageColor3 = COLORS.Accent
            }):Play()
        end
    end

    local function onLeave()
        TweenService:Create(button, TweenInfo.new(0.18), {
            BackgroundColor3 = COLORS.Element
        }):Play()
        if icon then
            TweenService:Create(icon, TweenInfo.new(0.3), {
                ImageColor3 = COLORS.Text
            }):Play()
        end
    end

    local function onClick()
        TweenService:Create(button, TweenInfo.new(0.08), {
            BackgroundColor3 = COLORS.AccentPress
        }):Play()
        
        if icon then
            TweenService:Create(icon, TweenInfo.new(0.12), {
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(1, -44, 0.5, -16)
            }):Play()
            
            task.delay(0.12, function()
                TweenService:Create(icon, TweenInfo.new(0.12), {
                    Size = UDim2.new(0, 28, 0, 28),
                    Position = UDim2.new(1, -42, 0.5, -14)
                }):Play()
            end)
        end
        
        task.delay(0.15, function()
            TweenService:Create(button, TweenInfo.new(0.18), {
                BackgroundColor3 = COLORS.ElementHover
            }):Play()
        end)
        
        callback()
    end

    button.MouseEnter:Connect(onEnter)
    button.MouseLeave:Connect(onLeave)
    button.Activated:Connect(onClick)

    return button
end

return CreateButton
