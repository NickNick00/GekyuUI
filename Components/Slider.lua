-- Slider.lua
-- Componente: Slider horizontal com valor numérico

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local COLORS = {
    Element       = Color3.fromRGB(18, 18, 28),
    Accent        = Color3.fromRGB(90, 170, 255),
    Text          = Color3.fromRGB(235, 235, 245),
}

local CORNERS = {
    Medium = UDim.new(0, 10),
}

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 62)
    frame.BackgroundColor3 = COLORS.Element
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNERS.Medium
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.68, 0, 0, 26)
    label.Position = UDim2.new(0, 14, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.28, 0, 0, 26)
    valueLabel.Position = UDim2.new(0.72, 0, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = COLORS.Accent
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.92, 0, 0, 8)
    bar.Position = UDim2.new(0.04, 0, 0.68, 0)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
    bar.Parent = frame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1,0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((default - min)/(max-min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = COLORS.Accent
    fill.Parent = bar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1,0)
    fillCorner.Parent = fill

    local knobArea = Instance.new("TextButton")
    knobArea.Size = UDim2.new(0, 48, 0, 48)
    knobArea.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    knobArea.AnchorPoint = Vector2.new(0.5, 0.5)
    knobArea.BackgroundTransparency = 1
    knobArea.Text = ""
    knobArea.Parent = bar

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0.5, 0, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = knobArea
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1,0)
    knobCorner.Parent = knob

    local dragging = false

    local function updateValue(input)
        local relative = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * relative + 0.5)
        
        fill.Size = UDim2.new(relative, 0, 1, 0)
        knobArea.Position = UDim2.new(relative, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        
        callback(value)
    end

    knobArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return frame
end

return CreateSlider
