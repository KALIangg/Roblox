-- 🌌 Lua God | Flex UI Framework - Kubca @ FiveSense 🌌
-- 🚀 Versão Corrigida: Slider funcionando corretamente

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--===[ CONFIGURAÇÃO DE TEMA AVANÇADA ]===--
local THEME = {
    Primary = Color3.fromRGB(180, 40, 40),
    Secondary = Color3.fromRGB(25, 25, 35),
    Background = Color3.fromRGB(15, 15, 20),
    Card = Color3.fromRGB(30, 30, 40),
    Text = Color3.fromRGB(240, 240, 255),
    Highlight = Color3.fromRGB(255, 70, 70),
    Success = Color3.fromRGB(50, 180, 60),
    Error = Color3.fromRGB(200, 40, 40),
    Warning = Color3.fromRGB(255, 180, 50),
    Info = Color3.fromRGB(50, 150, 255)
}

--===[ SISTEMA DE ANIMAÇÕES ]===--
local EasingStyles = {
    Smooth = Enum.EasingStyle.Quint,
    Bouncy = Enum.EasingStyle.Back,
    Elastic = Enum.EasingStyle.Elastic
}

local function CreateTween(object, properties, duration, easingStyle)
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    local tweenInfo = TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out)
    return TweenService:Create(object, tweenInfo, properties)
end

--===[ GUI PRINCIPAL RESPONSIVA ]===--
local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "FlexMenuPro"
MenuGui.ResetOnSpawn = false
MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MenuGui.Parent = playerGui

-- Efeito de blur dinâmico
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = game:GetService("Lighting")

-- Frame principal com responsividade
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = MenuGui

-- Adicionar sombra ao frame principal
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.8
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = MainFrame

--===[ BARRA DE TÍTULO MODERNA ]===--
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = THEME.Primary
TitleBar.ZIndex = 5
TitleBar.Parent = MainFrame

-- Gradiente na barra de título
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, THEME.Primary),
    ColorSequenceKeypoint.new(1, THEME.Primary:Lerp(Color3.new(0,0,0), 0.3))
})
TitleGradient.Rotation = -15
TitleGradient.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -120, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Flex UI Pro"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextColor3 = THEME.Text
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 6
TitleText.Parent = TitleBar

-- Botões de controle modernos
local ControlButtons = Instance.new("Frame")
ControlButtons.Size = UDim2.new(0, 80, 1, 0)
ControlButtons.Position = UDim2.new(1, -80, 0, 0)
ControlButtons.BackgroundTransparency = 1
ControlButtons.ZIndex = 6
ControlButtons.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "─"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.TextColor3 = THEME.Text
MinBtn.Parent = ControlButtons

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = THEME.Text
CloseBtn.Parent = ControlButtons

--===[ SIDEBAR INTELIGENTE ]===--
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 60, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = THEME.Secondary
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.ZIndex = 10
Sidebar.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 8)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.Parent = Sidebar

-- Indicador de tab ativa
local ActiveTabIndicator = Instance.new("Frame")
ActiveTabIndicator.Size = UDim2.new(0, 4, 0, 25)
ActiveTabIndicator.BackgroundColor3 = THEME.Primary
ActiveTabIndicator.BorderSizePixel = 0
ActiveTabIndicator.ZIndex = 12
ActiveTabIndicator.Visible = false
ActiveTabIndicator.Parent = Sidebar

--===[ CONTAINER DE TABS RESPONSIVO ]===--
local TabsContainer = Instance.new("Frame")
TabsContainer.Position = UDim2.new(0, 60, 0, 45)
TabsContainer.Size = UDim2.new(1, -60, 1, -45)
TabsContainer.BackgroundTransparency = 1
TabsContainer.ClipsDescendants = true
TabsContainer.ZIndex = 8
TabsContainer.Parent = MainFrame

--===[ SISTEMA DE ANIMAÇÃO DA SIDEBAR ]===--
local sidebarOpen = false
local sidebarDebounce = false

local function ToggleSidebar(open)
    if sidebarDebounce then return end
    sidebarDebounce = true
    
    sidebarOpen = open
    local goalSize = open and UDim2.new(0, 180, 1, -45) or UDim2.new(0, 60, 1, -45)
    local goalTabPos = open and UDim2.new(0, 180, 0, 45) or UDim2.new(0, 60, 0, 45)
    local goalTabSize = open and UDim2.new(1, -180, 1, -45) or UDim2.new(1, -60, 1, -45)
    
    CreateTween(Sidebar, {Size = goalSize}, 0.4, EasingStyles.Smooth):Play()
    CreateTween(TabsContainer, {Position = goalTabPos, Size = goalTabSize}, 0.4, EasingStyles.Smooth):Play()
    
    -- Animar elementos da sidebar
    for _, child in ipairs(Sidebar:GetChildren()) do
        if child:IsA("TextButton") and child.Name == "TabButton" then
            local tabName = child:FindFirstChild("TabName")
            if tabName then
                CreateTween(tabName, {TextTransparency = open and 0 or 1}, 0.3):Play()
            end
        end
    end
    
    wait(0.4)
    sidebarDebounce = false
end

-- Hover inteligente na sidebar
Sidebar.MouseEnter:Connect(function()
    if not sidebarOpen then
        ToggleSidebar(true)
    end
end)

Sidebar.MouseLeave:Connect(function()
    if sidebarOpen then
        ToggleSidebar(false)
    end
end)

--===[ CONTROLES PRINCIPAIS ]===--
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local goalSize = minimized and UDim2.new(0, 650, 0, 45) or UDim2.new(0, 650, 0, 450)
    local goalBlur = minimized and 0 or 10
    
    CreateTween(MainFrame, {Size = goalSize}, 0.3, EasingStyles.Bouncy):Play()
    CreateTween(Blur, {Size = goalBlur}, 0.3):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    CreateTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, EasingStyles.Elastic):Play()
    CreateTween(Blur, {Size = 0}, 0.3):Play()
    wait(0.3)
    MenuGui.Enabled = false
end)

--===[ SISTEMA DE UI ENCAPSULADO ]===--
local FlexUI = {}
FlexUI.Tabs = {}
FlexUI.Connections = {}
local currentTab = nil

-- Função para criar efeitos de hover
local function CreateHoverEffect(button, normalColor, hoverColor)
    local connection1 = button.MouseEnter:Connect(function()
        CreateTween(button, {BackgroundColor3 = hoverColor}, 0.2):Play()
    end)
    
    local connection2 = button.MouseLeave:Connect(function()
        CreateTween(button, {BackgroundColor3 = normalColor}, 0.2):Play()
    end)
    
    table.insert(FlexUI.Connections, connection1)
    table.insert(FlexUI.Connections, connection2)
end

-- Função para criar cantos arredondados
local function ApplyCornerRadius(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
    return corner
end

--===[ SISTEMA DE NOTIFICAÇÕES AVANÇADO ]===--
local NotificationsFolder = Instance.new("Frame")
NotificationsFolder.Size = UDim2.new(0, 320, 0, 500)
NotificationsFolder.Position = UDim2.new(1, -330, 0, 20)
NotificationsFolder.BackgroundTransparency = 1
NotificationsFolder.ClipsDescendants = true
NotificationsFolder.ZIndex = 100
NotificationsFolder.Parent = MenuGui

local NotificationTypes = {
    Success = {Color = THEME.Success, Icon = "✓"},
    Error = {Color = THEME.Error, Icon = "✗"},
    Warning = {Color = THEME.Warning, Icon = "⚠"},
    Info = {Color = THEME.Info, Icon = "ℹ"}
}

function FlexUI:Notify(type, title, message, duration)
    duration = duration or 5
    
    local TypeData = NotificationTypes[type] or NotificationTypes.Info
    local notificationCount = #NotificationsFolder:GetChildren()
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(1, -10, 0, 80)
    Notification.Position = UDim2.new(0, 5, 0, notificationCount * 85)
    Notification.BackgroundColor3 = THEME.Card
    Notification.BorderSizePixel = 0
    Notification.ClipsDescendants = true
    Notification.ZIndex = 101
    Notification.Parent = NotificationsFolder
    
    ApplyCornerRadius(Notification, 8)
    
    -- Barra lateral colorida
    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(0, 4, 1, -10)
    AccentBar.Position = UDim2.new(0, 0, 0, 5)
    AccentBar.BackgroundColor3 = TypeData.Color
    AccentBar.BorderSizePixel = 0
    AccentBar.ZIndex = 102
    AccentBar.Parent = Notification
    
    ApplyCornerRadius(AccentBar, 2)
    
    -- Ícone
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 40, 0, 40)
    Icon.Position = UDim2.new(0, 15, 0, 15)
    Icon.BackgroundTransparency = 1
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 20
    Icon.TextColor3 = TypeData.Color
    Icon.Text = TypeData.Icon
    Icon.ZIndex = 102
    Icon.Parent = Notification
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 0, 20)
    Title.Position = UDim2.new(0, 65, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextColor3 = THEME.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 102
    Title.Parent = Notification
    
    -- Mensagem
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -70, 0, 35)
    Message.Position = UDim2.new(0, 65, 0, 35)
    Message.BackgroundTransparency = 1
    Message.Text = message
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 12
    Message.TextColor3 = THEME.Text
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.TextWrapped = true
    Message.ZIndex = 102
    Message.Parent = Notification
    
    -- Barra de progresso
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(1, 0, 0, 3)
    ProgressBar.Position = UDim2.new(0, 0, 1, -3)
    ProgressBar.BackgroundColor3 = TypeData.Color
    ProgressBar.BorderSizePixel = 0
    ProgressBar.ZIndex = 102
    ProgressBar.Parent = Notification
    
    -- Animação de entrada
    Notification.Position = UDim2.new(1, 5, 0, notificationCount * 85)
    CreateTween(Notification, {Position = UDim2.new(0, 5, 0, notificationCount * 85)}, 0.5, EasingStyles.Bouncy):Play()
    
    -- Animação da barra de progresso
    CreateTween(ProgressBar, {Size = UDim2.new(0, 0, 0, 3)}, duration):Play()
    
    -- Auto-remover após o tempo
    task.delay(duration, function()
        CreateTween(Notification, {Position = UDim2.new(1, 5, 0, notificationCount * 85)}, 0.5, EasingStyles.Smooth):Play()
        task.delay(0.5, function()
            Notification:Destroy()
        end)
    end)
end

--===[ SISTEMA DE TABS ]===--
function FlexUI:SetTitle(title)
    TitleText.Text = title
end

function FlexUI:AddTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = "TabButton"
    TabButton.Size = UDim2.new(1, -10, 0, 40)
    TabButton.BackgroundColor3 = THEME.Card
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    TabButton.ZIndex = 11
    TabButton.Parent = Sidebar
    
    -- Aplicar cantos arredondados
    ApplyCornerRadius(TabButton, 12)
    
    -- Ícone da tab
    local TabIcon = Instance.new("TextLabel")
    TabIcon.Size = UDim2.new(0, 24, 0, 24)
    TabIcon.Position = UDim2.new(0.5, -12, 0, 8)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Text = icon or "◉"
    TabIcon.Font = Enum.Font.GothamBold
    TabIcon.TextSize = 14
    TabIcon.TextColor3 = THEME.Text
    TabIcon.ZIndex = 12
    TabIcon.Parent = TabButton
    
    -- Nome da tab (visível apenas quando expandido)
    local TabName = Instance.new("TextLabel")
    TabName.Name = "TabName"
    TabName.Size = UDim2.new(1, -10, 0, 20)
    TabName.Position = UDim2.new(0, 5, 0, 30)
    TabName.BackgroundTransparency = 1
    TabName.Text = name
    TabName.Font = Enum.Font.Gotham
    TabName.TextSize = 11
    TabName.TextColor3 = THEME.Text
    TabName.TextXAlignment = Enum.TextXAlignment.Center
    TabName.ZIndex = 12
    TabName.TextTransparency = 1 -- Inicialmente transparente
    TabName.Parent = TabButton
    
    -- Frame da tab
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, -50)
    TabFrame.Position = UDim2.new(0, 0, 0, 50)
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.ScrollBarThickness = 6
    TabFrame.ScrollBarImageColor3 = THEME.Primary
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.ZIndex = 9
    TabFrame.Parent = TabsContainer
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = TabFrame
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 10)
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.Parent = TabFrame
    
    -- Atualizar canvas size automaticamente
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Sistema de clique
    TabButton.MouseButton1Click:Connect(function()
        for tabName, tabData in pairs(FlexUI.Tabs) do
            tabData.Frame.Visible = false
            CreateTween(tabData.Button, {BackgroundColor3 = THEME.Card}, 0.2):Play()
        end
        
        TabFrame.Visible = true
        CreateTween(TabButton, {BackgroundColor3 = THEME.Primary}, 0.2):Play()
        
        -- Mover indicador
        ActiveTabIndicator.Visible = true
        CreateTween(ActiveTabIndicator, {Position = UDim2.new(0, 3, 0, TabButton.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y + 8)}, 0.3, EasingStyles.Bouncy):Play()
        
        currentTab = name
    end)
    
    FlexUI.Tabs[name] = {
        Frame = TabFrame,
        Button = TabButton,
        Icon = TabIcon
    }
    
    CreateHoverEffect(TabButton, THEME.Card, THEME.Primary:Lerp(Color3.new(1,1,1), 0.1))
    
    -- Ativar primeira tab automaticamente
    if not currentTab then
        currentTab = name
        TabFrame.Visible = true
        TabButton.BackgroundColor3 = THEME.Primary
        ActiveTabIndicator.Visible = true
        ActiveTabIndicator.Position = UDim2.new(0, 3, 0, 8)
    end
    
    return name
end

--===[ ELEMENTOS DE INTERFACE MODERNOS ]===--
function FlexUI:AddSection(tab, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -20, 0, 40)
    Section.BackgroundColor3 = THEME.Card
    Section.BorderSizePixel = 0
    Section.ZIndex = 9
    Section.Parent = self.Tabs[tab].Frame
    
    ApplyCornerRadius(Section, 8)
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -20, 1, 0)
    SectionTitle.Position = UDim2.new(0, 10, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = title
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextColor3 = THEME.Text
    SectionTitle.TextSize = 14
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.ZIndex = 10
    SectionTitle.Parent = Section
    
    return Section
end

function FlexUI:AddLabel(tab, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = THEME.Text
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.ZIndex = 9
    Label.Parent = self.Tabs[tab].Frame
end

function FlexUI:AddButton(tab, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.BackgroundColor3 = THEME.Card
    Button.Text = text
    Button.Font = Enum.Font.GothamSemibold
    Button.TextColor3 = THEME.Text
    Button.TextSize = 13
    Button.AutoButtonColor = false
    Button.ZIndex = 9
    Button.Parent = self.Tabs[tab].Frame
    
    ApplyCornerRadius(Button, 8)
    
    CreateHoverEffect(Button, THEME.Card, THEME.Primary)
    
    Button.MouseButton1Click:Connect(function()
        CreateTween(Button, {BackgroundColor3 = THEME.Highlight}, 0.1):Play()
        task.wait(0.1)
        CreateTween(Button, {BackgroundColor3 = THEME.Primary}, 0.1):Play()
        callback()
    end)
    
    return Button
end

function FlexUI:AddToggle(tab, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.ZIndex = 9
    ToggleFrame.Parent = self.Tabs[tab].Frame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextColor3 = THEME.Text
    ToggleLabel.TextSize = 13
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.ZIndex = 10
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleButton.BackgroundColor3 = default and THEME.Success or THEME.Error
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.ZIndex = 10
    ToggleButton.Parent = ToggleFrame
    
    ApplyCornerRadius(ToggleButton, 10)
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 16, 0, 16)
    ToggleKnob.Position = UDim2.new(0, default and 22 or 2, 0.5, -8)
    ToggleKnob.BackgroundColor3 = THEME.Text
    ToggleKnob.BorderSizePixel = 0
    ToggleKnob.ZIndex = 11
    ToggleKnob.Parent = ToggleButton
    
    ApplyCornerRadius(ToggleKnob, 8)
    
    local state = default
    
    local function UpdateToggle()
        local goalPos = state and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local goalColor = state and THEME.Success or THEME.Error
        
        CreateTween(ToggleKnob, {Position = goalPos}, 0.2, EasingStyles.Bouncy):Play()
        CreateTween(ToggleButton, {BackgroundColor3 = goalColor}, 0.2):Play()
        
        callback(state)
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        UpdateToggle()
    end)
    
    CreateHoverEffect(ToggleButton, state and THEME.Success or THEME.Error, 
                     state and THEME.Success:Lerp(Color3.new(1,1,1), 0.2) or THEME.Error:Lerp(Color3.new(1,1,1), 0.2))
    
    return ToggleFrame
end

--===[ SISTEMA DE SLIDER CORRIGIDO ]===--
function FlexUI:AddSlider(tab, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.ZIndex = 9
    SliderFrame.Parent = self.Tabs[tab].Frame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. default
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextColor3 = THEME.Text
    SliderLabel.TextSize = 13
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.ZIndex = 10
    SliderLabel.Parent = SliderFrame
    
    -- Container do slider track com TextButton para capturar cliques
    local SliderContainer = Instance.new("TextButton")
    SliderContainer.Size = UDim2.new(1, 0, 0, 6)
    SliderContainer.Position = UDim2.new(0, 0, 0, 30)
    SliderContainer.BackgroundTransparency = 1
    SliderContainer.Text = ""
    SliderContainer.AutoButtonColor = false
    SliderContainer.ZIndex = 10
    SliderContainer.Parent = SliderFrame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, 0, 1, 0)
    SliderTrack.BackgroundColor3 = THEME.Card
    SliderTrack.BorderSizePixel = 0
    SliderTrack.ZIndex = 10
    SliderTrack.Parent = SliderContainer
    
    ApplyCornerRadius(SliderTrack, 3)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = THEME.Primary
    SliderFill.BorderSizePixel = 0
    SliderFill.ZIndex = 11
    SliderFill.Parent = SliderTrack
    
    ApplyCornerRadius(SliderFill, 3)
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    SliderButton.BackgroundColor3 = THEME.Text
    SliderButton.Text = ""
    SliderButton.AutoButtonColor = false
    SliderButton.ZIndex = 12
    SliderButton.Parent = SliderContainer
    
    ApplyCornerRadius(SliderButton, 8)
    
    local dragging = false
    
    local function UpdateSlider(value)
        value = math.clamp(value, min, max)
        local ratio = (value - min) / (max - min)
        
        SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        SliderButton.Position = UDim2.new(ratio, -8, 0.5, -8)
        SliderLabel.Text = text .. ": " .. math.floor(value)
        
        callback(value)
    end
    
    -- Sistema de arrastar CORRETO usando TextButton
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Clique no track para definir valor - AGORA FUNCIONA porque SliderContainer é TextButton
    SliderContainer.MouseButton1Down:Connect(function(x, y)
        local relativeX = x - SliderTrack.AbsolutePosition.X
        local ratio = math.clamp(relativeX / SliderTrack.AbsoluteSize.X, 0, 1)
        UpdateSlider(min + ratio * (max - min))
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = input.Position.X - SliderTrack.AbsolutePosition.X
            local ratio = math.clamp(relativeX / SliderTrack.AbsoluteSize.X, 0, 1)
            UpdateSlider(min + ratio * (max - min))
        end
    end)
    
    CreateHoverEffect(SliderButton, THEME.Text, THEME.Highlight)
    
    return SliderFrame
end

function FlexUI:AddDropdown(tab, text, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -20, 0, 30)
    DropdownFrame.BackgroundColor3 = THEME.Card
    DropdownFrame.ZIndex = 15
    DropdownFrame.Parent = self.Tabs[tab].Frame
    
    ApplyCornerRadius(DropdownFrame, 6)
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Size = UDim2.new(1, -30, 1, 0)
    DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = text .. ": " .. (default or "Selecionar")
    DropdownLabel.Font = Enum.Font.Gotham
    DropdownLabel.TextColor3 = THEME.Text
    DropdownLabel.TextSize = 13
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.ZIndex = 16
    DropdownLabel.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(0, 20, 0, 20)
    DropdownButton.Position = UDim2.new(1, -25, 0.5, -10)
    DropdownButton.Text = "▼"
    DropdownButton.Font = Enum.Font.GothamBold
    DropdownButton.TextSize = 12
    DropdownButton.BackgroundColor3 = THEME.Primary
    DropdownButton.TextColor3 = THEME.Text
    DropdownButton.AutoButtonColor = false
    DropdownButton.ZIndex = 16
    DropdownButton.Parent = DropdownFrame
    
    ApplyCornerRadius(DropdownButton, 4)
    
    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 2)
    OptionsFrame.BackgroundColor3 = THEME.Secondary
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ScrollBarThickness = 4
    OptionsFrame.ScrollBarImageColor3 = THEME.Primary
    OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.ZIndex = 20
    OptionsFrame.Parent = DropdownFrame
    
    ApplyCornerRadius(OptionsFrame, 6)
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.Parent = OptionsFrame
    
    local open = false
    local selected = default
    
    for _, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, -4, 0, 25)
        OptionButton.Position = UDim2.new(0, 2, 0, 0)
        OptionButton.Text = option
        OptionButton.BackgroundColor3 = THEME.Card
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 12
        OptionButton.TextColor3 = THEME.Text
        OptionButton.AutoButtonColor = false
        OptionButton.ZIndex = 21
        OptionButton.Parent = OptionsFrame
        
        ApplyCornerRadius(OptionButton, 4)
        
        CreateHoverEffect(OptionButton, THEME.Card, THEME.Primary)
        
        OptionButton.MouseButton1Click:Connect(function()
            selected = option
            DropdownLabel.Text = text .. ": " .. option
            callback(option)
            ToggleDropdown(false)
        end)
    end
    
    local function ToggleDropdown(forceState)
        open = forceState or not open
        local goalSize = open and UDim2.new(1, 0, 0, math.min(#options * 27, 135)) or UDim2.new(1, 0, 0, 0)
        
        CreateTween(OptionsFrame, {Size = goalSize}, 0.3, EasingStyles.Smooth):Play()
        CreateTween(DropdownButton, {Rotation = open and 180 or 0}, 0.3):Play()
        
        if open then
            OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 27)
        end
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        ToggleDropdown()
    end)
    
    CreateHoverEffect(DropdownButton, THEME.Primary, THEME.Highlight)
    
    return DropdownFrame
end

function FlexUI:AddTextBox(tab, text, placeholder, callback)
    local TextBoxFrame = Instance.new("Frame")
    TextBoxFrame.Size = UDim2.new(1, -20, 0, 35)
    TextBoxFrame.BackgroundTransparency = 1
    TextBoxFrame.ZIndex = 9
    TextBoxFrame.Parent = self.Tabs[tab].Frame
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.BackgroundColor3 = THEME.Card
    TextBox.BorderSizePixel = 0
    TextBox.Text = text or ""
    TextBox.PlaceholderText = placeholder or "Digite aqui..."
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextColor3 = THEME.Text
    TextBox.TextSize = 13
    TextBox.ZIndex = 10
    TextBox.Parent = TextBoxFrame
    
    ApplyCornerRadius(TextBox, 6)
    
    local function Focus()
        CreateTween(TextBox, {BackgroundColor3 = THEME.Primary}, 0.2):Play()
    end
    
    local function Unfocus()
        CreateTween(TextBox, {BackgroundColor3 = THEME.Card}, 0.2):Play()
    end
    
    TextBox.Focused:Connect(Focus)
    TextBox.FocusLost:Connect(function(enterPressed)
        Unfocus()
        if enterPressed then
            callback(TextBox.Text)
        end
    end)
    
    return TextBox
end

function FlexUI:AddKeybind(tab, text, defaultKey, callback)
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Size = UDim2.new(1, -20, 0, 30)
    KeybindFrame.BackgroundTransparency = 1
    KeybindFrame.ZIndex = 9
    KeybindFrame.Parent = self.Tabs[tab].Frame
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Size = UDim2.new(1, -80, 1, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = text
    KeybindLabel.Font = Enum.Font.Gotham
    KeybindLabel.TextColor3 = THEME.Text
    KeybindLabel.TextSize = 13
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.ZIndex = 10
    KeybindLabel.Parent = KeybindFrame
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(0, 70, 0, 25)
    KeybindButton.Position = UDim2.new(1, -70, 0.5, -12.5)
    KeybindButton.BackgroundColor3 = THEME.Card
    KeybindButton.Text = defaultKey.Name
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.TextColor3 = THEME.Text
    KeybindButton.TextSize = 12
    KeybindButton.AutoButtonColor = false
    KeybindButton.ZIndex = 10
    KeybindButton.Parent = KeybindFrame
    
    ApplyCornerRadius(KeybindButton, 6)
    
    local listening = false
    local currentKey = defaultKey
    
    local function StartListening()
        listening = true
        KeybindButton.Text = "..."
        CreateTween(KeybindButton, {BackgroundColor3 = THEME.Highlight}, 0.2):Play()
    end
    
    local function StopListening(newKey)
        listening = false
        currentKey = newKey or currentKey
        KeybindButton.Text = currentKey.Name
        CreateTween(KeybindButton, {BackgroundColor3 = THEME.Card}, 0.2):Play()
        callback(currentKey)
    end
    
    KeybindButton.MouseButton1Click:Connect(StartListening)
    
    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                StopListening(input.KeyCode)
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
            callback(currentKey)
        end
    end)
    
    table.insert(FlexUI.Connections, inputConnection)
    CreateHoverEffect(KeybindButton, THEME.Card, THEME.Primary)
    
    return KeybindFrame
end

--===[ SISTEMA DE RESPONSIVIDADE PARA MOBILE ]===--
local function UpdateResponsiveLayout()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    
    if viewportSize.X <= 600 then -- Mobile
        MainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
        MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
        
        -- Sidebar menor para mobile
        Sidebar.Size = UDim2.new(0, 50, 1, -45)
        TabsContainer.Position = UDim2.new(0, 50, 0, 45)
        TabsContainer.Size = UDim2.new(1, -50, 1, -45)
        
    else -- Desktop
        MainFrame.Size = UDim2.new(0, 650, 0, 450)
        MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
        
        Sidebar.Size = UDim2.new(0, 60, 1, -45)
        TabsContainer.Position = UDim2.new(0, 60, 0, 45)
        TabsContainer.Size = UDim2.new(1, -60, 1, -45)
    end
end

-- Atualizar layout quando a tela mudar de tamanho
UserInputService.WindowFocusReleased:Connect(UpdateResponsiveLayout)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateResponsiveLayout)
UpdateResponsiveLayout()

--===[ FUNÇÕES UTILITÁRIAS ]===--
function FlexUI:Show()
    MenuGui.Enabled = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    CreateTween(MainFrame, {Size = UDim2.new(0, 650, 0, 450)}, 0.5, EasingStyles.Elastic):Play()
    CreateTween(Blur, {Size = 10}, 0.3):Play()
end

function FlexUI:Hide()
    CreateTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, EasingStyles.Smooth):Play()
    CreateTween(Blur, {Size = 0}, 0.3):Play()
    wait(0.3)
    MenuGui.Enabled = false
end

function FlexUI:Destroy()
    for _, connection in ipairs(FlexUI.Connections) do
        connection:Disconnect()
    end
    MenuGui:Destroy()
    Blur:Destroy()
end

--===[ INICIALIZAÇÃO ]===--
CreateTween(Blur, {Size = 10}, 0.5):Play()

return FlexUI
