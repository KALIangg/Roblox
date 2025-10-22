--[[
    🌫 Vape V4 Style UI Library for Roblox - CORRIGIDA
    Framework: Luau (Roblox)
    Autor: Lua God 💻
    Versão: 2.0 - Bugs Corrigidos
]]--

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local library = {}
library.__index = library

library.ThemeColor = Color3.fromRGB(85, 170, 255)
library.Open = true
library.Tabs = {}

-- Utilidade para Tween
local function Tween(obj, props, dur)
    local tweenInfo = TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

-- Função de inicialização da UI
function library:init()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "LuaGodUILib"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui

    self.Main = Instance.new("Frame")
    self.Main.Size = UDim2.new(0, 525, 0, 650)
    self.Main.Position = UDim2.new(0.5, -262, 0.5, -325)
    self.Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.Main.BackgroundTransparency = 0.1
    self.Main.BorderSizePixel = 0
    self.Main.Active = true
    self.Main.Draggable = true
    self.Main.Parent = self.ScreenGui

    local UICorner = Instance.new("UICorner", self.Main)
    UICorner.CornerRadius = UDim.new(0, 10)

    -- Título corrigido
    local Header = Instance.new("TextLabel")
    Header.Text = "LuaGod Menu 💻"
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 18
    Header.TextColor3 = Color3.new(1, 1, 1)
    Header.BackgroundTransparency = 1
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.Position = UDim2.new(0, 0, 0, 5)
    Header.TextXAlignment = Enum.TextXAlignment.Center
    Header.Parent = self.Main

    self.TabBar = Instance.new("Frame")
    self.TabBar.Size = UDim2.new(0, 130, 1, -40)
    self.TabBar.Position = UDim2.new(0, 10, 0, 40)
    self.TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.TabBar.Parent = self.Main
    Instance.new("UICorner", self.TabBar).CornerRadius = UDim.new(0, 8)

    local TabListLayout = Instance.new("UIListLayout", self.TabBar)
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    self.Content = Instance.new("Frame")
    self.Content.Size = UDim2.new(1, -160, 1, -50)
    self.Content.Position = UDim2.new(0, 150, 0, 40)
    self.Content.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    self.Content.Parent = self.Main
    Instance.new("UICorner", self.Content).CornerRadius = UDim.new(0, 8)

    -- Botão para fechar/abrir
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Text = "−"
    ToggleButton.Size = UDim2.new(0, 25, 0, 25)
    ToggleButton.Position = UDim2.new(1, -30, 0, 5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 16
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = self.Main
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 4)

    ToggleButton.MouseButton1Click:Connect(function()
        self.Open = not self.Open
        Tween(self.Main, {
            Size = self.Open and UDim2.new(0, 525, 0, 650) or UDim2.new(0, 525, 0, 35)
        }, 0.3)
        ToggleButton.Text = self.Open and "−" or "+"
    end)

    return self
end

-- Criação de janelas CORRIGIDA
function library:NewWindow(props)
    local newWindow = setmetatable({}, library)
    newWindow:init()
    newWindow.Title = props and props.title or "Window"
    newWindow.Size = props and props.size or UDim2.new(0, 525, 0, 650)
    newWindow.Tabs = {}
    return newWindow
end

-- Sistema de Tabs
function library:AddTab(name)
    local TabButton = Instance.new("TextButton")
    
    -- Tamanho adaptável ao texto
    local textSize = TextService:GetTextSize(name, 14, Enum.Font.Gotham, Vector2.new(1000, 35))
    TabButton.Size = UDim2.new(0.9, 0, 0, 35)
    TabButton.Text = name
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabButton.TextColor3 = Color3.new(1, 1, 1)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.AutoButtonColor = false
    TabButton.Parent = self.TabBar
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

    -- Botão de colapso
    local CollapseButton = Instance.new("TextButton")
    CollapseButton.Text = "−"
    CollapseButton.Size = UDim2.new(0, 20, 0, 20)
    CollapseButton.Position = UDim2.new(1, -25, 0.5, -10)
    CollapseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    CollapseButton.TextColor3 = Color3.new(1, 1, 1)
    CollapseButton.Font = Enum.Font.GothamBold
    CollapseButton.TextSize = 12
    CollapseButton.AutoButtonColor = false
    CollapseButton.Parent = TabButton
    Instance.new("UICorner", CollapseButton).CornerRadius = UDim.new(0, 3)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.ScrollBarThickness = 3
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabFrame.Parent = self.Content

    local TabListLayout = Instance.new("UIListLayout", TabFrame)
    TabListLayout.Padding = UDim.new(0, 10)

    local tabCollapsed = false

    CollapseButton.MouseButton1Click:Connect(function()
        tabCollapsed = not tabCollapsed
        if TabFrame.Visible then
            Tween(TabFrame, {
                Size = tabCollapsed and UDim2.new(1, 0, 0, 0) or UDim2.new(1, 0, 1, 0)
            }, 0.3)
            CollapseButton.Text = tabCollapsed and "+" or "−"
        end
    end)

    TabButton.MouseButton1Click:Connect(function()
        -- Esconder todas as tabs
        for _, obj in ipairs(self.Content:GetChildren()) do
            if obj:IsA("ScrollingFrame") then 
                obj.Visible = false 
            end
        end
        
        -- Resetar cores dos botões
        for _, btn in ipairs(self.TabBar:GetChildren()) do
            if btn:IsA("TextButton") then 
                Tween(btn, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.2) 
            end
        end
        
        -- Mostrar tab atual
        TabFrame.Visible = true
        Tween(TabButton, {BackgroundColor3 = self.ThemeColor}, 0.2)
        self.CurrentTab = name
    end)

    -- Primeira tab é ativada automaticamente
    if #self.TabBar:GetChildren() == 1 then
        TabFrame.Visible = true
        Tween(TabButton, {BackgroundColor3 = self.ThemeColor}, 0.2)
        self.CurrentTab = name
    end

    local TabObj = {}

    function TabObj:AddSection(title, side)
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(0.48, -5, 0, 0)
        Section.BackgroundTransparency = 1
        Section.AutomaticSize = Enum.AutomaticSize.Y
        
        if side == "right" then
            Section.Position = UDim2.new(0.52, 5, 0, 0)
        else
            Section.Position = UDim2.new(0, 0, 0, 0)
        end
        Section.Parent = TabFrame

        local SectionLayout = Instance.new("UIListLayout", Section)
        SectionLayout.Padding = UDim.new(0, 5)

        local Label = Instance.new("TextLabel")
        Label.Text = title
        Label.Font = Enum.Font.GothamSemibold
        Label.TextColor3 = self.ThemeColor
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 0, 25)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Section

        local SectionObj = {}

        function SectionObj:AddButton(info)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 30)
            Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Button.Text = info.text or "Button"
            Button.TextColor3 = info.risky and Color3.new(1, 0.3, 0.3) or Color3.new(1, 1, 1)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 14
            Button.AutoButtonColor = false
            Button.Parent = Section
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

            Button.MouseButton1Click:Connect(function()
                Tween(Button, {BackgroundColor3 = self.ThemeColor}, 0.15)
                task.wait(0.15)
                Tween(Button, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.15)
                if info.callback then 
                    pcall(info.callback, true) 
                end
            end)
            
            return Button
        end

        function SectionObj:AddToggle(info)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = Section

            local Toggle = Instance.new("TextButton")
            Toggle.Size = UDim2.new(1, 0, 1, 0)
            Toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Toggle.Text = "  " .. (info.text or "Toggle")
            Toggle.TextColor3 = Color3.new(1, 1, 1)
            Toggle.Font = Enum.Font.Gotham
            Toggle.TextSize = 14
            Toggle.AutoButtonColor = false
            Toggle.TextXAlignment = Enum.TextXAlignment.Left
            Toggle.Parent = ToggleFrame
            Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)

            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
            ToggleIndicator.Position = UDim2.new(1, -25, 0.5, -10)
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            ToggleIndicator.Parent = Toggle
            Instance.new("UICorner", ToggleIndicator).CornerRadius = UDim.new(0, 4)

            local enabled = info.enabled or false
            
            local function updateToggle()
                Tween(ToggleIndicator, {
                    BackgroundColor3 = enabled and self.ThemeColor or Color3.fromRGB(60, 60, 60)
                }, 0.15)
                Tween(Toggle, {
                    BackgroundColor3 = enabled and Color3.fromRGB(30, 30, 40) or Color3.fromRGB(25, 25, 25)
                }, 0.15)
            end
            
            updateToggle()
            
            Toggle.MouseButton1Click:Connect(function()
                enabled = not enabled
                updateToggle()
                if info.callback then 
                    pcall(info.callback, enabled) 
                end
            end)
            
            local toggleObj = {}
            function toggleObj:Set(state)
                enabled = state
                updateToggle()
            end
            function toggleObj:Get()
                return enabled
            end
            
            return toggleObj
        end

        return SectionObj
    end

    table.insert(self.Tabs, TabObj)
    return TabObj
end

-- Sistema de notificações
function library:SendNotification(msg, duration, color)
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Size = UDim2.new(0, 200, 0, 40)
    NotifyFrame.Position = UDim2.new(0.5, -100, 1, -50)
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NotifyFrame.BackgroundTransparency = 0.2
    NotifyFrame.Parent = self.Main
    Instance.new("UICorner", NotifyFrame).CornerRadius = UDim.new(0, 6)

    local NotifyLabel = Instance.new("TextLabel")
    NotifyLabel.Text = msg
    NotifyLabel.Font = Enum.Font.Gotham
    NotifyLabel.TextColor3 = color or self.ThemeColor
    NotifyLabel.TextSize = 14
    NotifyLabel.BackgroundTransparency = 1
    NotifyLabel.Size = UDim2.new(1, -10, 1, 0)
    NotifyLabel.Position = UDim2.new(0, 5, 0, 0)
    NotifyLabel.TextXAlignment = Enum.TextXAlignment.Left
    NotifyLabel.Parent = NotifyFrame

    Tween(NotifyFrame, {Position = UDim2.new(0.5, -100, 1, -100)}, 0.3)
    
    task.delay(duration or 3, function()
        Tween(NotifyFrame, {Position = UDim2.new(0.5, -100, 1, -50)}, 0.3)
        task.wait(0.3)
        NotifyFrame:Destroy()
    end)
end

return library
