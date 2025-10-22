--[[
    🌫 Vape V4 Style UI Library for Roblox
    Framework: Luau (Roblox)
    Autor: Lua God 💻
    Descrição: UI Lib completa estilo Vape V4 com organização tipo Informant.Wtf.
]]--

-- Serviços e configurações iniciais
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local library = {}
library.ThemeColor = Color3.fromRGB(85, 170, 255)
library.Open = true

-- Utilidade para Tween
local function Tween(obj, props, dur)
    TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Função de inicialização da UI
function library:init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "LuaGodUILib"

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 525, 0, 650)
    Main.Position = UDim2.new(0.5, -262, 0.5, -325)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BackgroundTransparency = 0.1
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    local Blur = Instance.new("BlurEffect", game:GetService("Lighting"))
    Blur.Size = 15

    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 10)

    local Header = Instance.new("TextLabel", Main)
    Header.Text = "LuaGod Menu 💻"
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 18
    Header.TextColor3 = Color3.new(1, 1, 1)
    Header.BackgroundTransparency = 1
    Header.Position = UDim2.new(0, 15, 0, 10)

    local TabBar = Instance.new("Frame", Main)
    TabBar.Size = UDim2.new(0, 130, 1, -40)
    TabBar.Position = UDim2.new(0, 10, 0, 40)
    TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -160, 1, -50)
    Content.Position = UDim2.new(0, 150, 0, 40)
    Content.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

    library.Main = Main
    library.TabBar = TabBar
    library.Content = Content
end

-- Criação de janelas estilo Informant
function library.NewWindow(props)
    local self = setmetatable({}, {__index = library})
    self:init()
    self.Title = props.title or "Window"
    self.Size = props.size or UDim2.new(0, 525, 0, 650)
    return self
end

-- Sistema de Tabs
function library:AddTab(name)
    local TabButton = Instance.new("TextButton", self.TabBar)
    TabButton.Text = name
    TabButton.Size = UDim2.new(1, -20, 0, 35)
    TabButton.Position = UDim2.new(0, 10, 0, (#self.TabBar:GetChildren() - 1) * 40)
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabButton.TextColor3 = Color3.new(1, 1, 1)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.AutoButtonColor = false
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

    local TabFrame = Instance.new("ScrollingFrame", self.Content)
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.ScrollBarThickness = 3

    TabButton.MouseButton1Click:Connect(function()
        for _, obj in ipairs(self.Content:GetChildren()) do
            if obj:IsA("ScrollingFrame") then obj.Visible = false end
        end
        for _, btn in ipairs(self.TabBar:GetChildren()) do
            if btn:IsA("TextButton") then Tween(btn, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.2) end
        end
        TabFrame.Visible = true
        Tween(TabButton, {BackgroundColor3 = library.ThemeColor}, 0.2)
    end)

    if #self.Content:GetChildren() == 1 then
        TabFrame.Visible = true
        Tween(TabButton, {BackgroundColor3 = library.ThemeColor}, 0.2)
    end

    local TabObj = {}

    function TabObj:AddSection(title, side)
        local Section = Instance.new("Frame", TabFrame)
        Section.Size = UDim2.new(0.48, 0, 0, 40)
        Section.BackgroundTransparency = 1
        Section.Position = side == 2 and UDim2.new(0.52, 0, 0, 0) or UDim2.new(0, 0, 0, 0)

        local Label = Instance.new("TextLabel", Section)
        Label.Text = title
        Label.Font = Enum.Font.GothamSemibold
        Label.TextColor3 = library.ThemeColor
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 0, 25)
        Label.Position = UDim2.new(0, 5, 0, 0)

        local SectionObj = {}

        function SectionObj:AddButton(info)
            local Button = Instance.new("TextButton", Section)
            Button.Size = UDim2.new(1, -10, 0, 30)
            Button.Position = UDim2.new(0, 5, 0, 25)
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
                if info.callback then info.callback(true) end
            end)
        end

        function SectionObj:AddToggle(info)
            local Toggle = Instance.new("TextButton", Section)
            Toggle.Size = UDim2.new(1, -10, 0, 30)
            Toggle.Position = UDim2.new(0, 5, 0, 60)
            Toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Toggle.Text = info.text or "Toggle"
            Toggle.TextColor3 = Color3.new(1, 1, 1)
            Toggle.Font = Enum.Font.Gotham
            Toggle.TextSize = 14
            Toggle.AutoButtonColor = false
            Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)

            local enabled = info.enabled or false
            Toggle.MouseButton1Click:Connect(function()
                enabled = not enabled
                Tween(Toggle, {BackgroundColor3 = enabled and library.ThemeColor or Color3.fromRGB(25, 25, 25)}, 0.15)
                if info.callback then info.callback(enabled) end
            end)
        end

        return SectionObj
    end

    return TabObj
end

function library:SendNotification(msg, duration, color)
    local Notify = Instance.new("TextLabel", self.Main)
    Notify.Text = msg
    Notify.Font = Enum.Font.GothamBold
    Notify.TextColor3 = color or library.ThemeColor
    Notify.TextSize = 16
    Notify.BackgroundTransparency = 1
    Notify.Position = UDim2.new(0.5, -100, 1, -40)
    Notify.Size = UDim2.new(0, 200, 0, 30)
    Tween(Notify, {Position = UDim2.new(0.5, -100, 1, -70)}, 0.4)
    task.delay(duration or 3, function()
        Tween(Notify, {Position = UDim2.new(0.5, -100, 1, 10)}, 0.4)
        task.wait(0.4)
        Notify:Destroy()
    end)
end

return library
