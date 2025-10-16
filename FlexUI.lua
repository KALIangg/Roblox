-- 🌌 Lua God | Flex UI Framework - Kubca @ FiveSense 🌌
-- 🔧 UI totalmente encapsulada e automatizada
-- Nenhuma propriedade precisa ser manipulada fora das funções!

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--===[ CONFIGURAÇÃO DE TEMA ]===--
local THEME_COLOR = Color3.fromRGB(180, 40, 40) -- vermelho
local BG_COLOR = Color3.fromRGB(15, 15, 20)
local TEXT_COLOR = Color3.fromRGB(240, 240, 255)
local HIGHLIGHT_COLOR = Color3.fromRGB(255, 70, 70)

--===[ GUI PRINCIPAL ]===--
local MenuGui = Instance.new("ScreenGui", playerGui)
MenuGui.Name = "FlexMenu"
MenuGui.ResetOnSpawn = false
MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = game:GetService("Lighting")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = MenuGui

--===[ TÍTULO E BOTÕES ]===--
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = THEME_COLOR

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -100, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Flex UI"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextColor3 = TEXT_COLOR
TitleText.TextSize = 20
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local function FlexUI:SetTitle(arg)
	TitleText.Text = arg
end

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "_"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.TextColor3 = TEXT_COLOR

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✖"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = TEXT_COLOR

--===[ ANIMAÇÕES DO MENU ]===--
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	local goalSize = minimized and UDim2.new(0, 600, 0, 40) or UDim2.new(0, 600, 0, 400)
	TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = goalSize}):Play()
	TweenService:Create(Blur, TweenInfo.new(0.3), {Size = minimized and 0 or 15}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
	MenuGui.Enabled = false
	TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
end)

--===[ SIDEBAR ANIMADA ]===--
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 50, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.ZIndex = 15

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local sidebarOpen = false
Sidebar.MouseEnter:Connect(function()
	sidebarOpen = true
	TweenService:Create(Sidebar, TweenInfo.new(0.3), {Size = UDim2.new(0, 150, 1, -40)}):Play()
end)
Sidebar.MouseLeave:Connect(function()
	sidebarOpen = false
	TweenService:Create(Sidebar, TweenInfo.new(0.3), {Size = UDim2.new(0, 50, 1, -40)}):Play()
end)

--===[ CONTAINER DE TABS ]===--
local TabsContainer = Instance.new("Frame", MainFrame)
TabsContainer.Position = UDim2.new(0, 150, 0, 40)
TabsContainer.Size = UDim2.new(1, -150, 1, -40)
TabsContainer.BackgroundTransparency = 1
TabsContainer.ClipsDescendants = false
TabsContainer.ZIndex = 10

--===[ EFEITO DE HOVER GENÉRICO ]===--
local function HoverEffect(obj, color)
	obj.MouseEnter:Connect(function()
		TweenService:Create(obj, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
	end)
	obj.MouseLeave:Connect(function()
		TweenService:Create(obj, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40,40,50)}):Play()
	end)
end

--===[ SISTEMA DE TABS ENCAPSULADO ]===--
local FlexUI = {}
FlexUI.Tabs = {}
local currentTab = nil

function FlexUI:AddTab(name)
	local Button = Instance.new("TextButton", Sidebar)
	Button.Size = UDim2.new(1, -10, 0, 30)
	Button.BackgroundColor3 = Color3.fromRGB(40,40,50)
	Button.Text = name
	Button.Font = Enum.Font.GothamBold
	Button.TextSize = 14
	Button.TextColor3 = TEXT_COLOR
	Button.AutoButtonColor = false
	Button.ZIndex = 16
	HoverEffect(Button, HIGHLIGHT_COLOR)

	local Frame = Instance.new("ScrollingFrame", TabsContainer)
	Frame.Size = UDim2.new(1, 0, 1, -50)
	Frame.Position = UDim2.new(0, 0, 0, 50)
	Frame.CanvasSize = UDim2.new(0,0,0,0)
	Frame.ScrollBarThickness = 6
	Frame.BackgroundTransparency = 1
	Frame.ClipsDescendants = false
	Frame.Visible = false
	local Layout = Instance.new("UIListLayout", Frame)
	Layout.Padding = UDim.new(0, 6)

	Button.MouseButton1Click:Connect(function()
		for _, v in pairs(FlexUI.Tabs) do
			v.Frame.Visible = false
		end
		Frame.Visible = true
		currentTab = name
	end)

	FlexUI.Tabs[name] = {Frame = Frame, Button = Button}
	-- Se for a primeira tab criada, ativa automaticamente
	if not currentTab then
		currentTab = name
		Frame.Visible = true
	end
	return name
end

--===[ ELEMENTOS DE INTERFACE ]===--
function FlexUI:AddLabel(tab, text)
	local Label = Instance.new("TextLabel", self.Tabs[tab].Frame)
	Label.Size = UDim2.new(1, -20, 0, 30)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.Font = Enum.Font.GothamBold
	Label.TextColor3 = TEXT_COLOR
	Label.TextSize = 16
	Label.TextXAlignment = Enum.TextXAlignment.Left
end

function FlexUI:AddButton(tab, text, callback)
	local Btn = Instance.new("TextButton", self.Tabs[tab].Frame)
	Btn.Size = UDim2.new(1, -20, 0, 30)
	Btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
	Btn.Text = text
	Btn.Font = Enum.Font.Gotham
	Btn.TextColor3 = TEXT_COLOR
	Btn.TextSize = 14
	HoverEffect(Btn, HIGHLIGHT_COLOR)
	Btn.MouseButton1Click:Connect(callback)
end

function FlexUI:AddSeparator(tab)
	local Line = Instance.new("Frame", self.Tabs[tab].Frame)
	Line.Size = UDim2.new(1, -20, 0, 2)
	Line.BackgroundColor3 = THEME_COLOR
end

function FlexUI:AddToggle(tab, text, default, callback)
	local Btn = Instance.new("TextButton", self.Tabs[tab].Frame)
	Btn.Size = UDim2.new(1, -20, 0, 30)
	local state = default
	local function update()
		Btn.Text = text .. (state and " ✅" or " ❌")
		Btn.BackgroundColor3 = state and Color3.fromRGB(60,120,60) or Color3.fromRGB(80,50,50)
	end
	update()
	Btn.Font = Enum.Font.Gotham
	Btn.TextSize = 14
	Btn.TextColor3 = TEXT_COLOR
	Btn.MouseButton1Click:Connect(function()
		state = not state
		update()
		callback(state)
	end)
end

function FlexUI:AddDropdown(tab, text, options, callback)
	local DropFrame = Instance.new("Frame", self.Tabs[tab].Frame)
	DropFrame.Size = UDim2.new(1, -20, 0, 30)
	DropFrame.BackgroundColor3 = Color3.fromRGB(40,40,50)
	DropFrame.ZIndex = 20

	local Label = Instance.new("TextLabel", DropFrame)
	Label.Size = UDim2.new(1, -30, 1, 0)
	Label.Position = UDim2.new(0, 10, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text .. ": (nenhum)"
	Label.Font = Enum.Font.Gotham
	Label.TextColor3 = TEXT_COLOR
	Label.TextSize = 14
	Label.ZIndex = 21

	local Btn = Instance.new("TextButton", DropFrame)
	Btn.Size = UDim2.new(0, 20, 0, 20)
	Btn.Position = UDim2.new(1, -25, 0.5, -10)
	Btn.Text = "▼"
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 14
	Btn.BackgroundColor3 = THEME_COLOR
	Btn.TextColor3 = TEXT_COLOR
	Btn.ZIndex = 21
	HoverEffect(Btn, HIGHLIGHT_COLOR)

	local Open = false
	local OptionFrame = Instance.new("Frame", DropFrame)
	OptionFrame.Size = UDim2.new(1, 0, 0, 0)
	OptionFrame.Position = UDim2.new(0, 0, 1, 0)
	OptionFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
	OptionFrame.ClipsDescendants = true
	OptionFrame.ZIndex = 22

	local Layout = Instance.new("UIListLayout", OptionFrame)
	Layout.Padding = UDim.new(0, 2)

	for _, opt in ipairs(options) do
		local O = Instance.new("TextButton", OptionFrame)
		O.Size = UDim2.new(1, -4, 0, 25)
		O.Position = UDim2.new(0, 2, 0, 0)
		O.Text = opt
		O.BackgroundColor3 = Color3.fromRGB(35,35,45)
		O.Font = Enum.Font.Gotham
		O.TextSize = 13
		O.TextColor3 = TEXT_COLOR
		O.ZIndex = 23
		HoverEffect(O, HIGHLIGHT_COLOR)
		O.MouseButton1Click:Connect(function()
			Label.Text = text .. ": " .. opt
			callback(opt)
			TweenService:Create(OptionFrame, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,0)}):Play()
			Open = false
		end)
	end

	Btn.MouseButton1Click:Connect(function()
		Open = not Open
		local goal = Open and UDim2.new(1,0,0,#options*28) or UDim2.new(1,0,0,0)
		TweenService:Create(OptionFrame, TweenInfo.new(0.3), {Size = goal}):Play()
	end)
end

function FlexUI:AddWatermark(text)
	local Mark = Instance.new("TextLabel", MainFrame)
	Mark.Text = text
	Mark.Font = Enum.Font.GothamSemibold
	Mark.TextSize = 12
	Mark.BackgroundTransparency = 0.5
	Mark.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
	Mark.TextColor3 = Color3.fromRGB(255, 150, 150)
	Mark.Size = UDim2.new(0, 200, 0, 25)
	Mark.Position = UDim2.new(0, 15, 1, -35)
	Mark.ZIndex = 50
	Mark.Visible = false

	Sidebar.MouseEnter:Connect(function()
		Mark.Visible = true
		TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 15}):Play()
	end)
	Sidebar.MouseLeave:Connect(function()
		Mark.Visible = false
		TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
	end)
end

return FlexUI
