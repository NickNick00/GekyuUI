-- Example.lua

local Library = require(script:WaitForChild("Library"))

-- Cria uma nova janela
local MyWindow = Library:CreateWindow("My First Window")

-- Cria uma nova aba
local MyTab = MyWindow:CreateTab("General")

-- Adiciona um toggle na aba com um exemplo de callback
MyTab:Toggle({
    Name = "Example Toggle",
    Default = false,
    Callback = function(value)
        print("Toggle changed to:", value)
    end
})

-- Adiciona um slider na aba com um exemplo de callback
MyTab:Slider({
    Name = "Example Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Slider value:", value)
    end
})

-- Adiciona um dropdown na aba com um exemplo de callback
MyTab:Dropdown({
    Name = "Example Dropdown",
    Options = {"Option 1", "Option 2", "Option 3"},
    Callback = function(value)
        print("Dropdown selected:", value)
    end
})