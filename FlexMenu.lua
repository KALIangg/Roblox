--[[
    🌫 Vape V4 Style UI Library for Roblox - CORRIGIDA
    Framework: Luau (Roblox)
    Autor: Lua God 💻
    Descrição: UI Lib completa estilo Vape V4 com bugs corrigidos
]]--

-- Serviços
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Biblioteca principal
local library = {}
library.ThemeColor = Color3.fromRGB(85, 170, 255)
library.Open = true
library.Tabs = {}
library.CurrentTab = nil

-- Utilidade para Tween
local function Tween(obj, props, dur)
    TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Função de inicialização da UI
function library:init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "LuaGodUILib"
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 525, 0, 650)
    Main.Position = UDim2.new(0.5, -262, 0.5, -325)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BackgroundTransparency = 0.1
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    -- CORREÇÃO: Removido o blur conforme solicitado
    -- local Blur = Instance.new("BlurEffect", game:GetService("Lighting"))
    -- Blur.Size = 15

    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 10)

    -- CORREÇÃO: Título melhor posicionado
    local Header = Instance.new("TextLabel", Main)
    Header.Text = "LuaGod Menu 💻"
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 18
    Header.TextColor3 = Color3.new(1, 1, 1)
    Header.BackgroundTransparency = 1
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.Position = UDim2.new(0, 0, 0, 5)
    Header.TextXAlignment = Enum.TextXAlignment.Center

    local TabBar = Instance.new("Frame", Main)
    TabBar.Size = UDim2.new(0, 130, 1, -40)
    TabBar.Position = UDim2.new(0, 10, 0, 40)
    TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

    local TabListLayout = Instance.new("UIListLayout", TabBar)
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -160, 1, -50)
    Content.Position = UDim2.new(0, 150, 0, 40)
    Content.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

    library.Main = Main
    library.TabBar = TabBar
    library.Content = Content
    library.TabListLayout = TabListLayout

    -- CORREÇÃO: Botão para fechar/abrir a UI
    local ToggleButton = Instance.new("TextButton", Main)
    ToggleButton.Text = "−"
    ToggleButton.Size = UDim2.new(0, 25, 0, 25)
    ToggleButton.Position = UDim2.new(1, -30, 0, 5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 16
    ToggleButton.AutoButtonColor = false
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 4)

    ToggleButton.MouseButton1Click:Connect(function()
        library.Open = not library.Open
        Tween(Main, {Size = library.Open and UDim2.new(0, 525, 0, 650) or UDim2.new(0, 525, 0, 35)}, 0.3)
        ToggleButton.Text = library.Open and "−" or "+"
    end)

    return self
end

-- Criação de janelas
function library:NewWindow(props)
    local self = setmetatable({}, {__index = library})
    self:init()
    self.Title = props.title or "Window"
    self.Size = props.size or UDim2.new(0, 525, 0, 650)
    return self
end

-- Sistema de Tabs Corrigido
function library:AddTab(name)
    local TabButton = Instance.new("TextButton", self.TabBar)
    
    -- CORREÇÃO: Tamanho da tab se ajusta ao conteúdo
    local textSize = game:GetService("TextService"):GetTextSize(name, 14, Enum.Font.Gotham, Vector2.new(1000, 35))
    TabButton.Size = UDim2.new(0.9, 0, 0, 35)
    TabButton.Text = name
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabButton.TextColor3 = Color3.new(1, 1, 1)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.AutoButtonColor = false
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

    -- CORREÇÃO: Botão para retrair/expandir cada tab
    local CollapseButton = Instance.new("TextButton", TabButton)
    CollapseButton.Text = "−"
    CollapseButton.Size = UDim2.new(0, 20, 0, 20)
    CollapseButton.Position = UDim2.new(1, -25, 0.5, -10)
    CollapseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    CollapseButton.TextColor3 = Color3.new(1, 1, 1)
    CollapseButton.Font = Enum.Font.GothamBold
    CollapseButton.TextSize = 12
    CollapseButton.AutoButtonColor = false
    Instance.new("UICorner", CollapseButton).CornerRadius = UDim.new(0, 3)

    local TabFrame = Instance.new("ScrollingFrame", self.Content)
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.ScrollBarThickness = 3
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local TabListLayout = Instance.new("UIListLayout", TabFrame)
    TabListLayout.Padding = UDim.new(0, 10)

    local tabCollapsed = false

    CollapseButton.MouseButton1Click:Connect(function()
        tabCollapsed = not tabCollapsed
        if TabFrame.Visible then
            Tween(TabFrame, {Size = tabCollapsed and UDim2.new(1, 0, 0, 0) or UDim2.new(1, 0, 1, 0)}, 0.3)
            CollapseButton.Text = tabCollapsed and "+" or "−"
        end
    end)

    TabButton.MouseButton1Click:Connect(function()
        for _, obj in ipairs(self.Content:GetChildren()) do
            if obj:IsA("ScrollingFrame") then 
                obj.Visible = false 
            end
        end
        for _, btn in ipairs(self.TabBar:GetChildren()) do
            if btn:IsA("TextButton") then 
                Tween(btn, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.2) 
            end
        end
        TabFrame.Visible = true
        Tween(TabButton, {BackgroundColor3 = library.ThemeColor}, 0.2)
        self.CurrentTab = name
    end)

    if #self.TabBar:GetChildren() == 1 then
        TabFrame.Visible = true
        Tween(TabButton, {BackgroundColor3 = library.ThemeColor}, 0.2)
        self.CurrentTab = name
    end

    local TabObj = {}

    function TabObj:AddSection(title, side)
        local Section = Instance.new("Frame", TabFrame)
        Section.Size = UDim2.new(0.48, -5, 0, 0)
        Section.BackgroundTransparency = 1
        Section.AutomaticSize = Enum.AutomaticSize.Y
        
        if side == "right" then
            Section.Position = UDim2.new(0.52, 5, 0, 0)
        else
            Section.Position = UDim2.new(0, 0, 0, 0)
        end

        local SectionLayout = Instance.new("UIListLayout", Section)
        SectionLayout.Padding = UDim.new(0, 5)

        local Label = Instance.new("TextLabel", Section)
        Label.Text = title
        Label.Font = Enum.Font.GothamSemibold
        Label.TextColor3 = library.ThemeColor
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 0, 25)
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local SectionObj = {}

        function SectionObj:AddButton(info)
            local Button = Instance.new("TextButton", Section)
            Button.Size = UDim2.new(1, 0, 0, 30)
            Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Button.Text = info.text or "Button"
            Button.TextColor3 = info.risky and Color3.new(1, 0.3, 0.3) or Color3.new(1, 1, 1)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 14
            Button.AutoButtonColor = false
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

            Button.MouseButton1Click:Connect(function()
                Tween(Button, {BackgroundColor3 = library.ThemeColor}, 0.15)
                task.wait(0.15)
                Tween(Button, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.15)
                if info.callback then 
                    pcall(info.callback, true) 
                end
            end)
            
            return Button
        end

        function SectionObj:AddToggle(info)
            local ToggleFrame = Instance.new("Frame", Section)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
            ToggleFrame.BackgroundTransparency = 1

            local Toggle = Instance.new("TextButton", ToggleFrame)
            Toggle.Size = UDim2.new(1, 0, 1, 0)
            Toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Toggle.Text = info.text or "Toggle"
            Toggle.TextColor3 = Color3.new(1, 1, 1)
            Toggle.Font = Enum.Font.Gotham
            Toggle.TextSize = 14
            Toggle.AutoButtonColor = false
            Toggle.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)

            local ToggleIndicator = Instance.new("Frame", Toggle)
            ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
            ToggleIndicator.Position = UDim2.new(1, -25, 0.5, -10)
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Instance.new("UICorner", ToggleIndicator).CornerRadius = UDim.new(0, 4)

            local enabled = info.enabled or false
            
            local function updateToggle()
                Tween(ToggleIndicator, {BackgroundColor3 = enabled and library.ThemeColor or Color3.fromRGB(60, 60, 60)}, 0.15)
                Tween(Toggle, {BackgroundColor3 = enabled and Color3.fromRGB(30, 30, 40) or Color3.fromRGB(25, 25, 25)}, 0.15)
            end
            
            updateToggle()
            
            Toggle.MouseButton1Click:Connect(function()
                enabled = not enabled
                updateToggle()
                if info.callback then 
                    pcall(info.callback, enabled) 
                end
            end)
            
            return {
                Set = function(_, state)
                    enabled = state
                    updateToggle()
                end,
                Get = function()
                    return enabled
                end
            }
        end

        function SectionObj:AddSlider(info)
            local Frame = Instance.new("Frame", Section)
            Frame.Size = UDim2.new(1, 0, 0, 50)
            Frame.BackgroundTransparency = 1

            local Label = Instance.new("TextLabel", Frame)
            Label.Text = info.text or "Slider"
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel", Frame)
            ValueLabel.Text = tostring(info.default or info.min or 0)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 12
            ValueLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Size = UDim2.new(0, 40, 0, 20)
            ValueLabel.Position = UDim2.new(1, -40, 0, 0)
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local SliderBack = Instance.new("Frame", Frame)
            SliderBack.Size = UDim2.new(1, 0, 0, 6)
            SliderBack.Position = UDim2.new(0, 0, 1, -15)
            SliderBack.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", SliderBack).CornerRadius = UDim.new(1, 0)

            local SliderFill = Instance.new("Frame", SliderBack)
            SliderFill.BackgroundColor3 = library.ThemeColor
            SliderFill.Size = UDim2.new(0, 0, 1, 0)
            Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

            local SliderButton = Instance.new("TextButton", SliderBack)
            SliderButton.Size = UDim2.new(1, 0, 1, 0)
            SliderButton.BackgroundTransparency = 1
            SliderButton.Text = ""
            SliderButton.AutoButtonColor = false

            local min = info.min or 0
            local max = info.max or 100
            local default = info.default or min
            local value = default
            
            local function updateSlider(val)
                value = math.clamp(val, min, max)
                local percentage = (value - min) / (max - min)
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                ValueLabel.Text = string.format("%.1f", value)
                if info.callback then 
                    pcall(info.callback, value) 
                end
            end
            
            updateSlider(default)
            
            local dragging = false
            
            SliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            SliderButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local relativeX = (input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X
                    local newValue = min + (max - min) * math.clamp(relativeX, 0, 1)
                    updateSlider(newValue)
                end
            end)
            
            return {
                Set = function(_, val)
                    updateSlider(val)
                end,
                Get = function()
                    return value
                end
            }
        end

        function SectionObj:AddDropdown(info)
            local DropdownFrame = Instance.new("Frame", Section)
            DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
            DropdownFrame.BackgroundTransparency = 1

            local Drop = Instance.new("TextButton", DropdownFrame)
            Drop.Size = UDim2.new(1, 0, 1, 0)
            Drop.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Drop.Text = info.text or "Dropdown"
            Drop.TextColor3 = Color3.new(1, 1, 1)
            Drop.Font = Enum.Font.Gotham
            Drop.TextSize = 14
            Drop.AutoButtonColor = false
            Drop.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", Drop).CornerRadius = UDim.new(0, 6)

            local Arrow = Instance.new("TextLabel", Drop)
            Arrow.Text = "▼"
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Position = UDim2.new(1, -25, 0.5, -10)
            Arrow.BackgroundTransparency = 1
            Arrow.TextColor3 = Color3.new(1, 1, 1)
            Arrow.Font = Enum.Font.Gotham
            Arrow.TextSize = 12

            local ListFrame = Instance.new("ScrollingFrame", DropdownFrame)
            ListFrame.Size = UDim2.new(1, 0, 0, 0)
            ListFrame.Position = UDim2.new(0, 0, 1, 5)
            ListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            ListFrame.ScrollBarThickness = 3
            ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ListFrame.Visible = false
            Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)

            local ListLayout = Instance.new("UIListLayout", ListFrame)
            ListLayout.Padding = UDim.new(0, 1)

            local opened = false
            local selected = info.default or (info.values and info.values[1]) or ""

            local function updateDropdown()
                Drop.Text = selected
                if info.callback then 
                    pcall(info.callback, selected) 
                end
            end

            local function toggleDropdown()
                opened = not opened
                ListFrame.Visible = opened
                Tween(ListFrame, {Size = opened and UDim2.new(1, 0, 0, math.min(#info.values * 30, 150)) or UDim2.new(1, 0, 0, 0)}, 0.2)
                Arrow.Text = opened and "▲" or "▼"
            end

            if info.values then
                for i, value in ipairs(info.values) do
                    local Item = Instance.new("TextButton", ListFrame)
                    Item.Text = value
                    Item.Size = UDim2.new(1, 0, 0, 30)
                    Item.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    Item.TextColor3 = Color3.new(1, 1, 1)
                    Item.Font = Enum.Font.Gotham
                    Item.TextSize = 14
                    Item.AutoButtonColor = false
                    
                    Item.MouseButton1Click:Connect(function()
                        selected = value
                        updateDropdown()
                        toggleDropdown()
                    end)
                    
                    Item.MouseEnter:Connect(function()
                        Tween(Item, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.1)
                    end)
                    
                    Item.MouseLeave:Connect(function()
                        Tween(Item, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.1)
                    end)
                end
            end

            Drop.MouseButton1Click:Connect(toggleDropdown)
            updateDropdown()

            return {
                Set = function(_, val)
                    if table.find(info.values, val) then
                        selected = val
                        updateDropdown()
                    end
                end,
                Get = function()
                    return selected
                end
            }
        end

        return SectionObj
    end

    table.insert(self.Tabs, TabObj)
    return TabObj
end

-- Sistema de notificações
function library:SendNotification(msg, duration, color)
    local NotifyFrame = Instance.new("Frame", self.Main)
    NotifyFrame.Size = UDim2.new(0, 200, 0, 40)
    NotifyFrame.Position = UDim2.new(0.5, -100, 1, -50)
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NotifyFrame.BackgroundTransparency = 0.2
    Instance.new("UICorner", NotifyFrame).CornerRadius = UDim.new(0, 6)

    local NotifyLabel = Instance.new("TextLabel", NotifyFrame)
    NotifyLabel.Text = msg
    NotifyLabel.Font = Enum.Font.Gotham
    NotifyLabel.TextColor3 = color or library.ThemeColor
    NotifyLabel.TextSize = 14
    NotifyLabel.BackgroundTransparency = 1
    NotifyLabel.Size = UDim2.new(1, -10, 1, 0)
    NotifyLabel.Position = UDim2.new(0, 5, 0, 0)
    NotifyLabel.TextXAlignment = Enum.TextXAlignment.Left

    Tween(NotifyFrame, {Position = UDim2.new(0.5, -100, 1, -100)}, 0.3)
    
    task.delay(duration or 3, function()
        Tween(NotifyFrame, {Position = UDim2.new(0.5, -100, 1, -50)}, 0.3)
        task.wait(0.3)
        NotifyFrame:Destroy()
    end)
end

-- Função para criar exemplo de uso
function library:CreateExample()
    local window = self:NewWindow({
        title = "LuaGod UI Library",
        size = UDim2.new(0, 525, 0, 650)
    })
    
    local mainTab = window:AddTab("Principal")
    
    local combatSection = mainTab:AddSection("Combate", "left")
    local movementSection = mainTab:AddSection("Movimento", "right")
    
    combatSection:AddButton({
        text = "Ativar Aimbot",
        callback = function(state)
            window:SendNotification("Aimbot " .. (state and "ativado" or "desativado"))
        end
    })
    
    local toggle = combatSection:AddToggle({
        text = "Trigger Bot",
        enabled = false,
        callback = function(state)
            window:SendNotification("Trigger Bot " .. (state and "ativado" or "desativado"))
        end
    })
    
    local slider = combatSection:AddSlider({
        text = "Campo de Visão",
        min = 1,
        max = 360,
        default = 90,
        callback = function(value)
            print("FOV alterado para:", value)
        end
    })
    
    local dropdown = combatSection:AddDropdown({
        text = "Alvo Preferido",
        values = {"Cabeça", "Torso", "Pernas", "Aleatório"},
        default = "Cabeça",
        callback = function(value)
            window:SendNotification("Alvo: " .. value)
        end
    })
    
    movementSection:AddButton({
        text = "Bunny Hop",
        callback = function(state)
            window:SendNotification("Bunny Hop " .. (state and "ativado" or "desativado"))
        end
    })
    
    local speedToggle = movementSection:AddToggle({
        text = "Speed Hack",
        enabled = true,
        callback = function(state)
            window:SendNotification("Speed Hack " .. (state and "ativado" or "desativado"))
        end
    })
    
    window:SendNotification("UI Library carregada com sucesso!", 5, Color3.fromRGB(0, 255, 0))
    
    return window
end

return library
