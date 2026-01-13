-- Library.lua

local Library = {}
Library.__index = Library

-- Serviços
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

-- Limpa GUI antiga se existir
if CoreGui:FindFirstChild("GekyuPremiumUI") then
    CoreGui.GekyuPremiumUI:Destroy()
end

-- Cria ScreenGui uma única vez
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GekyuPremiumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = CoreGui

-- Suas cores e cantos (copie do seu código)
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

-- Função principal que o usuário vai chamar
function Library:CreateWindow(title)
    local window = setmetatable({}, Library)

    -- Aqui você coloca TODA a criação da janela (MainFrame, TopBar, drag, botões X/minimizar/engrenagem, SearchBar, TabBar, ContentArea)
    -- Copie tudo do seu código atual que cria o MainFrame até o ContentArea

    -- Exemplo mínimo (você substitui pelo seu código completo depois):
    window.MainFrame = Instance.new("Frame")
    window.MainFrame.Size = UDim2.new(0, 480, 0, 520)
    window.MainFrame.Position = UDim2.new(0.5, -240, 0.5, -260)
    window.MainFrame.BackgroundColor3 = COLORS.Background
    window.MainFrame.Parent = ScreenGui
    -- ... continue com UICorner, UIStroke, TopBar, drag, etc

    -- Guarda referências importantes
    window.TabBar = -- seu TabBar
    window.ContentArea = -- seu ContentArea

    -- Métodos que o usuário vai usar
    function window:CreateTab(tabName)
        local tab = {}

        -- Crie o botão da aba e o container de conteúdo aqui (copie sua lógica do CreateTab)

        function tab:Toggle(options)
            -- options = {Name = "Texto", Default = false, Callback = function(value) end}
            -- Coloque aqui sua função CreateToggleWithCheckboxes adaptada
        end

        function tab:Slider(options)
            -- options = {Name, Min, Max, Default, Callback}
            -- Coloque sua função CreateSlider adaptada
        end

        function tab:Dropdown(options)
            -- Coloque sua função CreateDropdown adaptada
        end

        -- Adicione outros elementos depois (Keybind, Button, Colorpicker, etc)

        return tab
    end

    return window
end

return Library
