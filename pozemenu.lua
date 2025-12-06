local LocalPlayer = game.Players.LocalPlayer
local mouse = game.Players.LocalPlayer:GetMouse()
local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character
local char = player.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local humanoid = char and char:FindFirstChildOfClass("Humanoid")
local Humanoid = char and char:FindFirstChildOfClass("Humanoid")

local flingActive = false
local oldPos = nil
local antiCollideConn
local restoreCollide = nil
local CurrentTarget = nil

-- Função de estabilização original
local function stabilizeCharacter(Character, RootPart, Humanoid)
    RootPart.CFrame = oldPos * CFrame.new(0, .5, 0)
    Character:SetPrimaryPartCFrame(oldPos * CFrame.new(0, .5, 0))
    Humanoid:ChangeState("GettingUp")
    for _, bp in pairs(Character:GetChildren()) do
        if bp:IsA("BasePart") then
            bp.Velocity = Vector3.new()
            bp.RotVelocity = Vector3.new()
        end
    end
end

-- Anti-Anti-Collide
local function antiAntiCollide(Character)
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not Character or not Character.Parent then
            conn:Disconnect()
            return
        end
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") and not part.Anchored then
                if part.CanCollide == false then
                    part.CanCollide = true
                end
            end
        end
    end)
    return conn
end

-- Colisão forçada para alvo + veículo
local function forceCollide(TargetCharacter)
    local originalStates = {}

    -- Alvo (personagem)
    for _, desc in ipairs(TargetCharacter:GetDescendants()) do
        if desc:IsA("BasePart") or desc:IsA("MeshPart") then
            originalStates[desc] = desc.CanCollide
            desc.CanCollide = true
        end
    end

    -- Se estiver sentado, também ativa colisão do objeto que está sentando
    local THumanoid = TargetCharacter:FindFirstChildOfClass("Humanoid")
    if THumanoid and THumanoid.Sit and THumanoid.SeatPart then
        local seat = THumanoid.SeatPart
        for _, desc in ipairs(seat:GetDescendants()) do
            if desc:IsA("BasePart") or desc:IsA("MeshPart") then
                originalStates[desc] = desc.CanCollide
                desc.CanCollide = true
            end
        end
    end

    -- Função para restaurar
    return function()
        for part, state in pairs(originalStates) do
            if part and part:IsA("BasePart") then
                part.CanCollide = state
            end
        end
    end
end

-- Stop do fling
local function StopSkidFling()
    flingActive = false

    -- Remove BodyVelocity
    if root then
        local bv = root:FindFirstChild("EpixVel")
        if bv then
            bv:Destroy()
        end
    end

    -- Restaura colisão do alvo
    if restoreCollide then
        restoreCollide()
        restoreCollide = nil
    end

    -- Estabiliza o personagem local
    if char and root and humanoid and oldPos then
        stabilizeCharacter(char, root, humanoid)
    end

    -- Desconecta anti-collide
    if antiCollideConn then
        antiCollideConn:Disconnect()
        antiCollideConn = nil
    end
end

-- SkidFling antigo com colisão atualizada
local function SkidFling(TargetPlayer)
    if typeof(TargetPlayer) ~= "Instance" or not TargetPlayer:IsA("Player") then
        return warn("Fling: Jogador inválido")
    end

    local tries = 0
    while not TargetPlayer.Character and tries < 50 do
        task.wait(0.1)
        tries += 1
    end
    local TCharacter = TargetPlayer.Character
    if not TCharacter then
        return warn("Fling: Personagem do alvo não carregado")
    end

    local Player = Players.LocalPlayer
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        return warn("Fling: Seu personagem não está pronto")
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = TCharacter:FindFirstChild("HumanoidRootPart")
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")

    if not RootPart then return end

    oldPos = RootPart.CFrame
    antiCollideConn = antiAntiCollide(Character)
    CurrentTarget = TCharacter

    -- Colisão forçada
    if THumanoid and TRootPart then
        restoreCollide = forceCollide(TCharacter)
    end

    workspace.CurrentCamera.CameraSubject = THead or Handle or THumanoid or RootPart

    local function FPos(BasePart, Pos, Ang)
        local multiplier = 35
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        if Character.PrimaryPart then
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        end
        RootPart.Velocity = Vector3.new(1e9, 1.2e9, 1e9) * multiplier
        RootPart.RotVelocity = Vector3.new(6e8, 6e8, 6e8) * multiplier
    end

    local function SFBasePart(BasePart)
        local Angle = 0
        flingActive = true
        while flingActive and RootPart and BasePart and TargetPlayer.Character == TCharacter and THumanoid and Humanoid and Humanoid.Health > 0 do
            Angle += 150
            local vel = BasePart.Velocity.Magnitude * 1.5

            FPos(BasePart, CFrame.new(0, 2.5, 0) + THumanoid.MoveDirection * vel / 0.8, CFrame.Angles(math.rad(Angle), 0, 0))
            task.wait()
            if not flingActive then break end

            FPos(BasePart, CFrame.new(0, -2.5, 0) + THumanoid.MoveDirection * vel / 0.8, CFrame.Angles(math.rad(Angle), 0, 0))
            task.wait()
            if not flingActive then break end
        end
    end

    workspace.FallenPartsDestroyHeight = 0/0

    local BV = Instance.new("BodyVelocity")
    BV.Name = "EpixVel"
    BV.Velocity = Vector3.new(6e9, 6e9, 6e9)
    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BV.P = 1e6
    BV.Parent = RootPart

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if TRootPart and THead then
        if (TRootPart.Position - THead.Position).Magnitude > 5 then
            SFBasePart(THead)
        else
            SFBasePart(TRootPart)
        end
    elseif TRootPart then
        SFBasePart(TRootPart)
    elseif THead then
        SFBasePart(THead)
    elseif Handle then
        SFBasePart(Handle)
    end

    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

    if oldPos then
        stabilizeCharacter(Character, RootPart, Humanoid)
    end

    workspace.CurrentCamera.CameraSubject = Humanoid

    if antiCollideConn then
        antiCollideConn:Disconnect()
        antiCollideConn = nil
    end

    -- Restaura colisão
    if restoreCollide then
        restoreCollide()
        restoreCollide = nil
    end
end









-- local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Consistt/Ui/main/UnLeaked"))()
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox-UI-Libs/refs/heads/main/xsx%20Lib/xsx%20Lib%20Source.lua"))()

library.rank = "Premium"
local Wm = library:Watermark("Poze MENU | v" .. library.version ..  " | " .. library:GetUsername() .. " | rank: " .. library.rank)
local FpsWm = Wm:AddWatermark("fps: " .. library.fps)
coroutine.wrap(function()
    while wait(.75) do
        FpsWm:Text("FPS: " .. library.fps)
    end
end)()


local Notif = library:InitNotifications()

for i = 10,0,-1 do 
    task.wait(0.05)
    local LoadingXSX = Notif:Notify("Poze MENU - Carregando...", 3, "information") -- notification, alert, error, success, information
end 
library.title = "Poze MENU | ANTI-RP | TESTING | v2.1.250"
library:Introduction()
wait(1)



local Init = library:Init()

local Tab1 = Init:NewTab("PvP")
local Tab2 = Init:NewTab("Online")
local Tab3 = Init:NewTab("Player")
local Tab4 = Init:NewTab("Armas")
local Tab5 = Init:NewTab("Admin")





local lastPositions = {}
local teleportDistance = 35 -- Aumentado para carros rápidos
local matchRadius = 15
local lastViewCheck = 0
local lastTPNotify = {}
local lastFreecamState = {}
local lastFreecamCheck = 0

local MONITOR_CHECK_INTERVAL = 0.75
local TELEPORT_COOLDOWN = 2
local FREECAM_COOLDOWN = 5

local function isPlayerInFreecam(plr)
	local camType = cam.CameraType
	if plr ~= Players.LocalPlayer then
		-- Não conseguimos verificar outras câmeras, então ignoramos
		return false
	end
	local char = plr.Character
	if not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Scriptable = Câmera desacoplada do corpo
	if camType == Enum.CameraType.Scriptable then
		local dist = (cam.CFrame.Position - hrp.Position).Magnitude
		if dist > 10 then
			return true
		end
	end
	return false
end


local AdminToggle = Tab3:NewToggle("Admin Logger", false, function(val)
	MonitorExploits = val
    if val then
        local FinishedLoading = Notif:Notify("Monitoramento de exploits ativado!", 4, "success")
    else
        local FinishedLoading = Notif:Notify("Monitaramento de exploits desativado!", 4, "success")
    end
end)


-- ===== Admin Core =====
local AdminEnabled = false
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local Prefix = ":"
local Commands = {}
local Registered = {}
local Aliases = {}
local CommandMeta = {}

local HideChatCommands = false
local rpModeEnabled = false -- variável de exemplo para RP mode
local RPAnimations = {} -- tabela exemplo para animações RP

-- Função que será chamada para executar animações RP (exemplo)
local function playAnim(anim)
    -- implementação da animação aqui (exemplo)
end

local function RegisterCommand(name, func, meta)
    name = name:lower()
    if Registered[name] then return end
    Registered[name] = true
    Commands[name] = func
    CommandMeta[name] = meta or {}
end

local function RegisterAlias(alias, targetName)
    alias = alias:lower()
    targetName = targetName:lower()
    Aliases[alias] = function(...)
        local f = Commands[targetName]
        if f then return f(...) end
    end
end

local function FindPlayerByPartial(q)
    if not q or q == "" then return nil end
    q = q:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():sub(1, #q) == q then
            return plr
        end
    end
    return Players:FindFirstChild(q)
end

local function ProcessMessage(sender, message)
    if not AdminEnabled then return end
    if sender ~= LocalPlayer then return end
    if message:sub(1, #Prefix) ~= Prefix then return end

    local args = message:sub(#Prefix + 1):split(" ")
    local cmdName = (args[1] or ""):lower()
    table.remove(args, 1)

    local cmd = Commands[cmdName] or Aliases[cmdName]
    if cmd then
        task.spawn(function()
            cmd(unpack(args))
        end)
    end
end

-- ===== Logs (hook global + janelas) =====
local chatStoredLogs = {}
local cmdStoredLogs = {}
local commandPrefixes = { "!", ":", ";", ".", "/", "-" }

local function startsWithPrefix(text)
    for _, p in ipairs(commandPrefixes) do
        if text:sub(1, #p) == p then
            return true
        end
    end
    return false
end

local function createLogsGui(titleText, storedTable)
    local existing = LocalPlayer.PlayerGui:FindFirstChild(titleText)
    if existing then
        existing.Enabled = true
        return
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = titleText
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.Position = UDim2.new(0.2, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 32)
    Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Text = "📜 " .. titleText
    Title.Parent = Main

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 60, 0, 26)
    Close.Position = UDim2.new(1, -65, 0, 3)
    Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.SourceSansBold
    Close.TextSize = 16
    Close.Text = "X"
    Close.Parent = Main

    local Clear = Instance.new("TextButton")
    Clear.Size = UDim2.new(0, 80, 0, 26)
    Clear.Position = UDim2.new(1, -150, 0, 3)
    Clear.BackgroundColor3 = Color3.fromRGB(70, 70, 200)
    Clear.TextColor3 = Color3.new(1, 1, 1)
    Clear.Font = Enum.Font.SourceSansBold
    Clear.TextSize = 14
    Clear.Text = "Limpar"
    Clear.Parent = Main

    local Pause = Instance.new("TextButton")
    Pause.Size = UDim2.new(0, 110, 0, 26)
    Pause.Position = UDim2.new(0, 6, 0, 3)
    Pause.BackgroundColor3 = Color3.fromRGB(70, 200, 70)
    Pause.TextColor3 = Color3.new(1, 1, 1)
    Pause.Font = Enum.Font.SourceSansBold
    Pause.TextSize = 14
    Pause.Text = "⏸️ Pausar"
    Pause.Parent = Main

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0, 250, 0, 26)
    SearchBox.Position = UDim2.new(0, 120, 0, 3)
    SearchBox.PlaceholderText = "Pesquisar mensagens..."
    SearchBox.ClearTextOnFocus = false
    SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SearchBox.TextColor3 = Color3.new(1, 1, 1)
    SearchBox.Font = Enum.Font.SourceSans
    SearchBox.TextSize = 14
    SearchBox.Parent = Main

    local Scrolling = Instance.new("ScrollingFrame")
    Scrolling.Size = UDim2.new(1, -10, 1, -44)
    Scrolling.Position = UDim2.new(0, 5, 0, 38)
    Scrolling.BackgroundTransparency = 1
    Scrolling.ScrollBarThickness = 8
    Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scrolling.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    Scrolling.Parent = Main
    Scrolling.AutomaticCanvasSize = Enum.AutomaticSize.XY

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    UIListLayout.Parent = Scrolling

    local paused = false

    local function addLine(log)
        if paused then return end
        local line = Instance.new("TextLabel")
        line.BackgroundTransparency = 1
        line.Size = UDim2.new(0, 1, 0, 20)
        line.TextXAlignment = Enum.TextXAlignment.Left
        line.Font = Enum.Font.Code
        line.TextSize = 14
        line.TextColor3 = Color3.new(1, 1, 1)
        line.Text = string.format("[%s] %s: %s", log.time, log.author, log.message)
        line.TextWrapped = false
        line.TextTruncate = Enum.TextTruncate.None
        line.TextScaled = false
        line.Parent = Scrolling
        line.Size = UDim2.new(0, math.max(Scrolling.AbsoluteSize.X, #line.Text * 8), 0, 20)
        Scrolling.CanvasSize = UDim2.new(0, math.max(Scrolling.AbsoluteSize.X, #line.Text * 8), 0, UIListLayout.AbsoluteContentSize.Y)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, v in ipairs(Scrolling:GetChildren()) do
            if v:IsA("TextLabel") then
                local show = v.Text:lower():find(query)
                v.Visible = show and true or false
            end
        end
    end)

    for _, log in ipairs(storedTable) do
        addLine(log)
    end

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    Clear.MouseButton1Click:Connect(function()
        Scrolling:ClearAllChildren()
        UIListLayout.Parent = Scrolling
        table.clear(storedTable)
    end)

    Pause.MouseButton1Click:Connect(function()
        paused = not paused
        Pause.Text = paused and "▶️ Continuar" or "⏸️ Pausar"
    end)

    return addLine
end

do
    local channel = TextChatService:WaitForChild("TextChannels"):FindFirstChild("RBXGeneral")
    if channel then
        channel.MessageReceived:Connect(function(msg)
            local author = msg.TextSource and msg.TextSource.Name or "Sistema"
            local message = msg.Text
            local time = os.date("%H:%M:%S")
            local entry = { time = time, author = author, message = message }
            table.insert(chatStoredLogs, entry)
            if startsWithPrefix(message) then
                table.insert(cmdStoredLogs, entry)
            end
        end)
    else
        warn("Não existe channel!")
    end
end

RegisterCommand("chatlogs", function()
    createLogsGui("ChatLogs", chatStoredLogs)
end)

RegisterCommand("unchatlogs", function()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("ChatLogs")
    if gui then gui:Destroy() end
end)

RegisterCommand("logs", function()
    createLogsGui("Logs", cmdStoredLogs)
end)

RegisterCommand("unlogs", function()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("Logs")
    if gui then gui:Destroy() end
end)


-- ===== Admin Panel (Topbar icon + 3 abas) =====
local AdminPanelGui

local function openOrCreateAdminPanel()
    if AdminPanelGui and AdminPanelGui.Parent then
        AdminPanelGui.Enabled = true
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "AdminPanel"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local icon = Instance.new("ImageButton")
    icon.Name = "AdminIcon"
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 0
    icon.Image = "rbxassetid://987290052"
    icon.ImageTransparency = 0
    icon.AutoButtonColor = true
    icon.Parent = gui

    local iconcorner = Instance.new("UICorner")
    iconcorner.CornerRadius = UDim.new(0.3, 8)
    iconcorner.Parent = icon

    local win = Instance.new("Frame")
    win.Name = "Window"
    win.Size = UDim2.new(0, 560, 0, 360)
    win.Position = UDim2.new(0.5, -280, 0.5, -180)
    win.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    win.BorderSizePixel = 0
    win.Visible = false
    win.Active = true
    win.Draggable = true
    win.Parent = gui

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -36, 0, 32)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    header.Text = "🛡️ Admin Panel"
    header.TextColor3 = Color3.new(1, 1, 1)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 18
    header.Parent = win

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -32, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 16
    closeBtn.Parent = win

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 30)
    tabBar.Position = UDim2.new(0, 0, 0, 32)
    tabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tabBar.Parent = win

    local function makeTabButton(txt, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 110, 1, 0)
        b.Position = UDim2.new(0, x, 0, 0)
        b.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        b.Text = txt
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 14
        b.Parent = tabBar
        return b
    end

    local tabCmds = makeTabButton("Cmds", 6)
    local tabAliases = makeTabButton("Aliases", 122)
    local tabConfigs = makeTabButton("Configs", 238)

    local function makePage()
        local p = Instance.new("Frame")
        p.Size = UDim2.new(1, 0, 1, -62)
        p.Position = UDim2.new(0, 0, 0, 62)
        p.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        p.Visible = false
        p.Parent = win
        return p
    end

    local pageCmds = makePage()
    local pageAliases = makePage()
    local pageConfigs = makePage()

    local function showPage(p)
        pageCmds.Visible = false
        pageAliases.Visible = false
        pageConfigs.Visible = false
        p.Visible = true
    end

    tabCmds.MouseButton1Click:Connect(function()
        showPage(pageCmds)
    end)
    tabAliases.MouseButton1Click:Connect(function()
        showPage(pageAliases)
    end)
    tabConfigs.MouseButton1Click:Connect(function()
        showPage(pageConfigs)
    end)

    showPage(pageCmds)

    local function makeScroll(parent)
        local s = Instance.new("ScrollingFrame")
        s.Size = UDim2.new(1, -12, 1, -12)
        s.Position = UDim2.new(0, 6, 0, 6)
        s.BackgroundTransparency = 1
        s.ScrollBarThickness = 6
        s.CanvasSize = UDim2.new(0, 0, 0, 0)
        s.Parent = parent
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = s
        return s, layout
    end

    local cmdsScroll, cmdsLayout = makeScroll(pageCmds)
    local aliasesScroll, aliasesLayout = makeScroll(pageAliases)

    local function addRow(parent, layout, text)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, -6, 0, 22)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Font = Enum.Font.Code
        l.TextSize = 14
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Text = text
        l.Parent = parent
        parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end

    for name, meta in pairs(CommandMeta) do
        local aliasesList = {}
        for a, fn in pairs(Aliases) do
            local f = Commands[name]
            if f and debug.getinfo and debug.getinfo(fn).source == debug.getinfo(function(...) return f(...) end).source then
                table.insert(aliasesList, a)
            end
        end
        local desc = meta.desc or ""
        local usage = meta.usage and (" — " .. meta.usage) or ""
        addRow(cmdsScroll, cmdsLayout, string.format("%s%s %s", Prefix .. name, usage, desc))
    end

    for a, _ in pairs(Aliases) do
        addRow(aliasesScroll, aliasesLayout, Prefix .. a)
    end

    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0, 220, 0, 36)
    hideBtn.Position = UDim2.new(0, 12, 0, 12)
    hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
    hideBtn.TextColor3 = Color3.new(1, 1, 1)
    hideBtn.Font = Enum.Font.SourceSansBold
    hideBtn.TextSize = 14
    hideBtn.Text = "Hide Chat Commands: " .. (HideChatCommands and "ON" or "OFF")
    hideBtn.Parent = pageConfigs
    hideBtn.MouseButton1Click:Connect(function()
        HideChatCommands = not HideChatCommands
        hideBtn.Text = "Hide Chat Commands: " .. (HideChatCommands and "ON" or "OFF")
    end)

    local openChatLogs = Instance.new("TextButton")
    openChatLogs.Size = UDim2.new(0, 160, 0, 32)
    openChatLogs.Position = UDim2.new(0, 12, 0, 60)
    openChatLogs.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
    openChatLogs.TextColor3 = Color3.new(1, 1, 1)
    openChatLogs.Font = Enum.Font.SourceSansBold
    openChatLogs.TextSize = 14
    openChatLogs.Text = "Open ChatLogs"
    openChatLogs.Parent = pageConfigs
    openChatLogs.MouseButton1Click:Connect(function()
        createLogsGui("ChatLogs", chatStoredLogs)
    end)

    local openCmdLogs = Instance.new("TextButton")
    openCmdLogs.Size = UDim2.new(0, 160, 0, 32)
    openCmdLogs.Position = UDim2.new(0, 12, 0, 100)
    openCmdLogs.BackgroundColor3 = Color3.fromRGB(130, 70, 70)
    openCmdLogs.TextColor3 = Color3.new(1, 1, 1)
    openCmdLogs.Font = Enum.Font.SourceSansBold
    openCmdLogs.TextSize = 14
    openCmdLogs.Text = "Open Logs"
    openCmdLogs.Parent = pageConfigs
    openCmdLogs.MouseButton1Click:Connect(function()
        createLogsGui("Logs", cmdStoredLogs)
    end)

    icon.MouseButton1Click:Connect(function()
        win.Visible = not win.Visible
    end)

    closeBtn.MouseButton1Click:Connect(function()
        win.Visible = false
    end)

    AdminPanelGui = gui
end

local function destroyAdminPanel()
    if AdminPanelGui then
        AdminPanelGui:Destroy()
        AdminPanelGui = nil
    end
end

-- ===== Useful Commands =====

RegisterCommand("tp", function(target)
    local t = FindPlayerByPartial(target)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(t.Character.HumanoidRootPart.CFrame)
    end
end, {desc="Teleporta até o player alvo", usage="tp <player>"})

RegisterAlias("to","tp")

RegisterCommand("goto", function(target)
    local t = FindPlayerByPartial(target)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(t.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0))
    end
end, {desc="Vai até o player alvo", usage="goto <player>"})

RegisterCommand("bring", function(target)
    local t = FindPlayerByPartial(target)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
        t.Character:PivotTo(LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0))
    end
end, {desc="Traz o player alvo até você", usage="bring <player>"})

RegisterAlias("puxar","bring")

RegisterCommand("rejoin", function()
    local placeId, jobId = game.PlaceId, game.JobId
    if placeId and jobId then
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end
end, {desc="Reentrar no mesmo servidor"})

RegisterAlias("rj","rejoin")

RegisterCommand("pt", function()
    local tool = Instance.new("Tool")
    tool.RequiresHandle = false
    tool.Name = "TP Tool"
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        if mouse and mouse.Hit then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
            end
        end
    end)
    tool.Parent = LocalPlayer.Backpack
end, {desc="Cria ferramenta de teleport por clique"})

RegisterAlias("tptool","pt")

RegisterCommand("unpt", function()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local ch = LocalPlayer.Character
    if bp and bp:FindFirstChild("TP Tool") then bp["TP Tool"]:Destroy() end
    if ch and ch:FindFirstChild("TP Tool") then ch["TP Tool"]:Destroy() end
end, {desc="Remove a TP Tool"})

RegisterAlias("untptool","unpt")

RegisterCommand("puxartudo", function()
    for _, v in pairs(game.ReplicatedStorage:GetDescendants()) do
        if v:IsA("Tool") then
            v.Parent = LocalPlayer.Backpack
        end
    end
    for _, g in pairs(game.Teams:GetDescendants()) do
        if g:IsA("Tool") then
            g.Parent = LocalPlayer.Backpack
        end
    end
end, {desc="Puxa todas as Tools de ReplicatedStorage/Teams"})

RegisterAlias("giveall","puxartudo")

-- ==== PROFILE (expandido estilo Adonis) ====

RegisterCommand("profile", function(target)
    local t = FindPlayerByPartial(target)
    if not t then return end
    local teamName = t.Team and t.Team.Name or "None"
    local char = t.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local pos = hrp and hrp.Position
    local dist = (hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or nil

    local info = {
        "== PROFILE ==",
        "Name: "..t.Name,
        "DisplayName: "..t.DisplayName,
        "UserId: "..t.UserId,
        "AccountAge: "..t.AccountAge.." dias",
        "Team: "..teamName,
        "Health: "..(hum and math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) or "N/A"),
        "WalkSpeed: "..(hum and hum.WalkSpeed or "N/A"),
        "JumpPower: "..(hum and hum.JumpPower or "N/A"),
        "Pos: "..(pos and tostring(pos) or "N/A"),
        "Dist: "..(dist and string.format("%.1f", dist) or "N/A"),
        "MembershipType: "..t.MembershipType.Name,
        "FollowUserId: "..t.FollowUserId,
        "FriendStatus (com você): "..t:GetFriendStatus(LocalPlayer),
    }

    pcall(function()
        local groups = t:GetGroups()
        table.insert(info, "Groups: "..#groups.." grupos")
        for i,g in ipairs(groups) do
            if i > 5 then break end
            table.insert(info, string.format(" - %s (%s)", g.Name, g.RankName))
        end
    end)

    print(table.concat(info, "\n"))
end, {desc="Inspeciona um jogador (detalhes completos)", usage="profile <player>"})

RegisterAlias("inspect","profile")

RegisterCommand("who", function()
    local names = {}
    for _,p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    print("Players ("..#names.."):", table.concat(names, ", "))
end, {desc="Lista jogadores online"})

RegisterAlias("players","who")

RegisterCommand("serverinfo", function()
    print(("PlaceId: %d | JobId: %s | Players: %d"):format(game.PlaceId, game.JobId, #Players:GetPlayers()))
end, {desc="Info do servidor atual"})

RegisterAlias("sinfo","serverinfo")

RegisterCommand("seatbreak", function()
    local ch = LocalPlayer.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end
    local seat = hum.SeatPart
    local mdl = seat:FindFirstAncestorOfClass("Model")
    if mdl then
        mdl:Destroy()
    else
        seat:Destroy()
    end
end, {desc="Destrói o modelo do assento atual (invis improvisado)"} )

RegisterAlias("invis","seatbreak")

RegisterCommand("speed", function(val)
    val = tonumber(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and val then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
    end
end, {desc="Define a velocidade do player", usage="speed <número>"})

RegisterAlias("velocity","speed")

RegisterCommand("jumppower", function(val)
    val = tonumber(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and val then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = val
    end
end, {desc="Define a altura do pulo", usage="jump <número>"})

RegisterCommand("sit", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Sit = true
    end
end, {desc="Faz seu personagem sentar"})

local LocalPlayer = Players.LocalPlayer

-- Variáveis de controle
local lastPosition = nil
local blockOnce = false
local monitoring = false

-- Função principal de reset
RegisterCommand("reset", function()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	-- Salva a posição antes de morrer
	lastPosition = char.HumanoidRootPart.CFrame

	-- Mata o personagem
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Health = 0
	end

	-- Quando o novo personagem nascer...
	LocalPlayer.CharacterAdded:Once(function(newChar)
		blockOnce = true -- sinaliza para bloquear o primeiro teleporte
		monitoring = true

		task.spawn(function()
			task.wait(2) -- tempo para o respawn natural acontecer
			repeat task.wait() until newChar:FindFirstChild("HumanoidRootPart")

			-- Reposiciona para onde estava antes
			newChar.HumanoidRootPart.CFrame = lastPosition
			print("[✔] Reset concluído e posição restaurada.")
		end)
	end)
end, {desc = "Reset rápido mantendo posição e bloqueando o primeiro teleporte automático"})

-- Monitoramento contínuo (mecânica pura)
RunService.Heartbeat:Connect(function()
	if not monitoring or not blockOnce then return end

	local char = LocalPlayer.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Se o jogo tentar teleportar o jogador pra outro lugar logo após o respawn:
	if (root.Position - lastPosition.Position).Magnitude > 25 then
		print("[⛔] Teleporte automático detectado e revertido.")
		root.CFrame = lastPosition
		blockOnce = false
		monitoring = false
	end
end)




RegisterAlias("re","reset")

RegisterCommand("heal", function(target)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = hum.MaxHealth
    end
end, {desc="Cura seu personagem"})

RegisterCommand("noclip", function()
    local char = LocalPlayer.Character
    if not char then return end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end, {desc="Ativa noclip temporário"})

RegisterCommand("unnoclip", function()
    local char = LocalPlayer.Character
    if not char then return end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = true
        end
    end
end, {desc="Desativa noclip"})

RegisterAlias("clip","unnoclip")

RegisterCommand("cmds", function()
    print("📜 Comandos:")
    for n,m in pairs(CommandMeta) do
        local usage = m.usage and (" "..m.usage) or ""
        print(Prefix..n..usage.." — "..(m.desc or ""))
    end
end, {desc="Lista comandos disponíveis"})

RegisterCommand("aliases", function()
    print("📜 Aliases:")
    for a,_ in pairs(Aliases) do
        print(Prefix..a)
    end
end, {desc="Lista aliases"})

RegisterAlias("alias","aliases")

RegisterCommand("prefix", function(arg)
    Prefix = arg
end, {desc="Prefixo utilizado nos comandos", usage="prefix <prefix>"})

-- Comando para alterar o Field of View (FOV) da câmera
RegisterCommand("fov", function(val)
    local num = tonumber(val)
    if num and num > 0 then
        workspace.CurrentCamera.FieldOfView = num
        print("Field of View alterado para " .. num)
    else
        print("Uso correto: fov <número>")
    end
end, {desc="Altera o FOV da câmera", usage="fov <número>"})

-- Comando para resetar o FOV ao padrão 70
RegisterCommand("resetfov", function()
    workspace.CurrentCamera.FieldOfView = 70
    print("FOV resetado ao padrão (70)")
end, {desc="Reseta o FOV ao padrão"})


-- Comando para destruir todos os objetos da workspace que são BaseParts (dangeroso!)
RegisterCommand("clearparts", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj:Destroy()
        end
    end
    print("Todos BaseParts da workspace foram destruídos")
end, {desc="Destrói todos BaseParts da workspace (cuidado!)"})

-- Comando para travar/destravar câmera em primeira pessoa
RegisterCommand("fp", function()
    local cam = workspace.CurrentCamera
    if cam.CameraType == Enum.CameraType.Custom then
        cam.CameraType = Enum.CameraType.LockFirstPerson
        print("Câmera travada em primeira pessoa")
    else
        cam.CameraType = Enum.CameraType.Custom
        print("Câmera destravada")
    end
end, {desc="Trava/destrava câmera em primeira pessoa"})

-- Comando para ativar/desativar radar de jogadores próximos (exibe nomes na tela)
RegisterCommand("radar", function()
    if _G.RadarGui then
        _G.RadarGui:Destroy()
        _G.RadarGui = nil
        print("Radar desativado")
        return
    end

    local ScreenGui = Instance.new("ScreenGui")
    local textLabel = Instance.new("TextLabel")
    ScreenGui.Name = "RadarGui"
    ScreenGui.Parent = game.CoreGui

    textLabel.Size = UDim2.new(0, 200, 0, 300)
    textLabel.Position = UDim2.new(1, -210, 0, 10)
    textLabel.BackgroundColor3 = Color3.new(0,0,0)
    textLabel.BackgroundTransparency = 0.5
    textLabel.TextColor3 = Color3.new(1,1,1)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.Parent = ScreenGui

    _G.RadarGui = ScreenGui

    game:GetService("RunService").RenderStepped:Connect(function()
        if not _G.RadarGui then return end
        local namesText = "Radar:\n"
        local localPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
        if localPos then
            for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = p.Character.HumanoidRootPart.Position
                    local dist = (pos - localPos).Magnitude
                    if dist < 100 then
                        namesText = namesText .. string.format("%s (%.1f)", p.Name, dist) .. "\n"
                    end
                end
            end
        end
        textLabel.Text = namesText
    end)

    print("Radar ativado (jogadores próximos mostrados)")
end, {desc="Ativa/desativa radar simples de jogadores próximos"})


-- ===== Admin Toggle (UI icon lifecycle) =====
local AdminToggle = Tab3:NewToggle("Admin System", false, function(val)
    AdminEnabled = val
    if val then
        if not (LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")) then
            openOrCreateAdminPanel()
        else
            LocalPlayer.PlayerGui.AdminPanel.Enabled = true
        end
    else
        if LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("AdminPanel") then
            LocalPlayer.PlayerGui.AdminPanel.Enabled = false
        end
    end
end)




print("Sistema de admin carregado.")







Players.PlayerAdded:Connect(function(player)
	if MonitorExploits then
		Notif:Notify("🟢 " .. player.Name .. " entrou no jogo.", 3, sucess)
	end

	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum:GetPropertyChangedSignal("Health"):Connect(function()
				if MonitorExploits and hum.Health <= 0 then
					Notif:Notify("☠️ " .. player.Name .. " morreu.", 3, "sucess")
				end
			end)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	if MonitorExploits then
		Notif:Notify("🔴 " .. player.Name .. " saiu do jogo.", 3, "sucess")
	end
end)


-- MONITORAMENTO DE CHAT MODERNO
TextChatService.MessageReceived:Connect(function(msg)
	if not MonitorExploits then return end
	local speaker = msg.TextSource and Players:GetPlayerByUserId(msg.TextSource.UserId)
	if speaker then
		Notif:Notify("💬 " .. speaker.Name .. ": " .. msg.Text, 3, "sucess")
	end
end)

-- MONITORAMENTO GERAL
RunService.Heartbeat:Connect(function()
	if not MonitorExploits then return end

	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local now = tick()
			local currentPos = hrp.Position
			local lastPos = lastPositions[player]

			-- TELEPORTE INTELIGENTE
			if lastPos then
				local distance = (currentPos - lastPos).Magnitude
				local cooldownPassed = (not lastTPNotify[player]) or (now - lastTPNotify[player] >= TELEPORT_COOLDOWN)

				local speed = humanoid and humanoid.MoveDirection.Magnitude or 0
				local velocity = hrp.Velocity.Magnitude

				if distance > teleportDistance and cooldownPassed and velocity < 120 then
					local near = nil
					for _, other in ipairs(Players:GetPlayers()) do
						if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
							local dist = (hrp.Position - other.Character.HumanoidRootPart.Position).Magnitude
							if dist < matchRadius then
								near = other
								break
							end
						end
					end

					if near then
						Notif:Notify("📍 " .. player.Name .. " teleportou-se para perto de " .. near.Name, 3, "sucess")
					else
						Notif:Notify("📍 " .. player.Name .. " teleportou-se para área remota", 3, "sucess")
					end
					lastTPNotify[player] = now
				end
			end

			lastPositions[player] = currentPos
		end
	end
end)

-- VIEW & FREECAM CHECK
RunService.RenderStepped:Connect(function()
	if not MonitorExploits then return end
	local now = tick()
	if now - lastViewCheck < MONITOR_CHECK_INTERVAL then return end
	lastViewCheck = now

	-- VIEW
	local camSub = cam.CameraSubject
	if typeof(camSub) == "Instance" and camSub:IsA("Humanoid") then
		local targetPlr = Players:GetPlayerFromCharacter(camSub.Parent)
		if targetPlr and targetPlr ~= Players.LocalPlayer then
			Notif:Notify("🎥 " .. Players.LocalPlayer.Name .. " está observando " .. targetPlr.Name, 3, "sucess")
		end
	end

	-- FREECAM
	if now - lastFreecamCheck >= FREECAM_COOLDOWN then
		if isPlayerInFreecam(Players.LocalPlayer) then
			if not lastFreecamState[Players.LocalPlayer] then
				Notif:Notify("🛸 " .. Players.LocalPlayer.Name .. " entrou no modo Freecam!", 3, "error")
				lastFreecamState[Players.LocalPlayer] = true
			end
		else
			lastFreecamState[Players.LocalPlayer] = false
		end
		lastFreecamCheck = now
	end
end)

print("Sistema de monitoramento carregado.")



local camera = workspace.CurrentCamera

local weaponNames = {
	"AK-12", "G17", "Glock 22", "AK-47", "M45A1", "MP5",
	"PKM", "UZI", "SCAR-H", "RedlineM4A1", "R700", "QBU-88",
	"AK-12POLICIA", "Glock 22 POLICIA", "M4A1POLICIA"
}

-- Flags
ESPEnabled, ESPGun, ESPBox, ESPmoney, ESPTracer, ESPName, ESPDistance, ESPSkeleton, ESPTeams, ESPWall =
	false, false, false, false, false, false, false, false, false, false

local espElements = {}

local Administrators = {
	["guijeumelegal7575"] = true,
	["N11COLS"] = true,
	["adbr404"] = true,
	["2arthur2021"] = true,
	["matheusroriues"] = true,
	["TheBlueDevEx"] = true,
	["PODEROSO_KADU13"] = true,
	["BlackElitras"] = true,
}

local function safeRemoveDrawing(obj)
	if typeof(obj) == "table" and obj.Remove then
		pcall(function() obj:Remove() end)
	elseif typeof(obj) == "userdata" and obj.Remove then
		pcall(function() obj:Remove() end)
	end
end

local function findLowestYPart(character)
	local candidates = {
		"LeftFoot","RightFoot",
		"LeftLowerLeg","RightLowerLeg",
		"LeftUpperLeg","RightUpperLeg",
		"LowerTorso","HumanoidRootPart",
		"Torso","Left Leg","Right Leg","LeftArm","RightArm","Left Arm","Right Arm"
	}
	local lowestPart, lowestY
	for _, name in ipairs(candidates) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			local y = part.Position.Y
			if not lowestY or y < lowestY then
				lowestY = y
				lowestPart = part
			end
		end
	end
	return lowestPart
end

-- Função CORRIGIDA para verificar se o jogador está atrás de parede
local function isBehindWall(targetPosition, targetCharacter)
	if not localPlayer.Character or not targetCharacter then return false end
	
	local localHead = localPlayer.Character:FindFirstChild("Head")
	if not localHead then return false end
	
	local localPosition = localHead.Position
	
	-- Criar um raycast da câmera até o alvo
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {localPlayer.Character, targetCharacter}
	
	local direction = (targetPosition - localPosition)
	local raycastResult = workspace:Raycast(localPosition, direction.Unit * math.min(direction.Magnitude * 1.1, 1000), raycastParams)
	
	if raycastResult then
		-- Verificar se o raycast atingiu algo antes de chegar no alvo
		local distanceToTarget = (targetPosition - localPosition).Magnitude
		local distanceToHit = (raycastResult.Position - localPosition).Magnitude
		
		-- Se atingiu algo antes do alvo (com margem de erro), está atrás de parede
		return distanceToHit < distanceToTarget - 2
	end
	
	return false
end

local function removeESP(player)
	local e = espElements[player]
	if e then
		if e.conn then
			pcall(function() e.conn:Disconnect() end)
		end
		safeRemoveDrawing(e.box)
		safeRemoveDrawing(e.tracer)
		safeRemoveDrawing(e.text)
		safeRemoveDrawing(e.statusText)
		safeRemoveDrawing(e.bankText)
		safeRemoveDrawing(e.carteiraText)
		safeRemoveDrawing(e.wallText)
		if e.skeletonLines then
			for _, line in ipairs(e.skeletonLines) do safeRemoveDrawing(line) end
		end
		espElements[player] = nil
	end
end

local function getTeamColor(player)
    if not ESPTeams then return Color3.new(1,1,1) end
    
    local localTeam = localPlayer.Team
    local playerTeam = player.Team
    
    -- Se não há sistema de times ou ambos estão sem time
    if not localTeam or not playerTeam then
        return Color3.new(1,1,1) -- Branco para neutro/sem time
    end
    
    -- Se estão no mesmo time
    if localTeam == playerTeam then
        return Color3.fromRGB(0, 255, 0) -- Verde para aliados
    else
        return Color3.fromRGB(255, 0, 0) -- Vermelho para inimigos
    end
end

local function createESP(player)
	if player == localPlayer or espElements[player] then return end

	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Filled = false
	box.Color = Color3.new(1,1,1)
	box.Visible = false

	local tracer = Drawing.new("Line")
	tracer.Thickness = 1.5
	tracer.Color = Color3.new(1,1,1)
	tracer.Visible = false

	local text = Drawing.new("Text")
	text.Size = 14
	text.Center = true
	text.Outline = true
	text.Color = Color3.new(1,1,1)
	text.Visible = false

	local statusText = Drawing.new("Text")
	statusText.Size = 14
	statusText.Center = true
	statusText.Outline = true
	statusText.Visible = false

	local bankText = Drawing.new("Text")
	bankText.Size = 14
	bankText.Center = true
	bankText.Outline = true
	bankText.Color = Color3.fromRGB(0,255,255)
	bankText.Visible = false

	local carteiraText = Drawing.new("Text")
	carteiraText.Size = 14
	carteiraText.Center = true
	carteiraText.Outline = true
	carteiraText.Color = Color3.fromRGB(255,255,0)
	carteiraText.Visible = false

	local wallText = Drawing.new("Text")
	wallText.Size = 14
	wallText.Center = true
	wallText.Outline = true
	wallText.Color = Color3.fromRGB(255, 165, 0) -- Laranja para indicador de parede
	wallText.Visible = false

	local skeletonLines = {}
	local skeletonPairs = {}

	local function syncSkeletonLines(count)
		for i = #skeletonLines + 1, count do
			local ln = Drawing.new("Line")
			ln.Thickness = 1.5
			ln.Color = Color3.new(1,1,1)
			ln.Visible = false
			table.insert(skeletonLines, ln)
		end
		for i = count + 1, #skeletonLines do
			if skeletonLines[i] then skeletonLines[i].Visible = false end
		end
	end

	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not ESPEnabled or not player.Character or not player.Character:FindFirstChildOfClass("Humanoid") then
			box.Visible = false
			tracer.Visible = false
			text.Visible = false
			statusText.Visible = false
			bankText.Visible = false
			carteiraText.Visible = false
			wallText.Visible = false
			for _, l in ipairs(skeletonLines) do l.Visible = false end
			return
		end

		local char = player.Character
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then
			box.Visible = false
			for _, l in ipairs(skeletonLines) do l.Visible = false end
			wallText.Visible = false
			return
		end

		local isR15 = (char:FindFirstChild("UpperTorso") ~= nil)
		if isR15 then
			skeletonPairs = {
				{"Head","UpperTorso"},
				{"UpperTorso","LowerTorso"},
				{"UpperTorso","LeftUpperArm"},
				{"LeftUpperArm","LeftLowerArm"},
				{"LeftLowerArm","LeftHand"},
				{"UpperTorso","RightUpperArm"},
				{"RightUpperArm","RightLowerArm"},
				{"RightLowerArm","RightHand"},
				{"LowerTorso","LeftUpperLeg"},
				{"LeftUpperLeg","LeftLowerLeg"},
				{"LeftLowerLeg","LeftFoot"},
				{"LowerTorso","RightUpperLeg"},
				{"RightUpperLeg","RightLowerLeg"},
				{"RightLowerLeg","RightFoot"},
			}
		else
			skeletonPairs = {
				{"Head","Torso"},
				{"Torso","Left Arm"},
				{"Left Arm","Left Leg"},
				{"Torso","Right Arm"},
				{"Right Arm","Right Leg"},
			}
		end

		syncSkeletonLines(#skeletonPairs)

		local headPart = char:FindFirstChild("Head")
		local topWorld = headPart and headPart.Position or (root.Position + Vector3.new(0, 1.5, 0))
		local lowestPart = findLowestYPart(char)
		local bottomWorld = lowestPart and lowestPart.Position or (root.Position - Vector3.new(0, 2, 0))

		local topScreen, topVis = camera:WorldToViewportPoint(topWorld)
		local bottomScreen, bottomVis = camera:WorldToViewportPoint(bottomWorld)

		if not (topVis or bottomVis) then
			box.Visible = false
			tracer.Visible = false
			text.Visible = false
			statusText.Visible = false
			bankText.Visible = false
			carteiraText.Visible = false
			wallText.Visible = false
			for _, l in ipairs(skeletonLines) do l.Visible = false end
			return
		end

		local height = math.abs(topScreen.Y - bottomScreen.Y)
		if height < 8 then height = 8 end
		local width = height / 2
		local screenX = topScreen.X
		local screenY = topScreen.Y
		local dist = (camera.CFrame.Position - root.Position).Magnitude

        -- Aplicar cores baseadas no time
        local teamColor = getTeamColor(player)
        local isAdmin = Administrators[player.Name]
        local finalColor = isAdmin and Color3.fromRGB(255,0,0) or teamColor

		-- Verificar se está atrás de parede (ESPWall) - CORRIGIDO
		local behindWall = false
		if ESPWall then
			behindWall = isBehindWall(headPart and headPart.Position or root.Position, char)
		end

		if ESPBox then
			box.Size = Vector2.new(width, height)
			box.Position = Vector2.new(screenX - width/2, screenY)
			box.Visible = true
			-- Se estiver atrás de parede, usar cor diferente
			box.Color = behindWall and Color3.fromRGB(255, 165, 0) or finalColor
		else
			box.Visible = false
		end

		if ESPTracer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local lp = camera:WorldToViewportPoint(localPlayer.Character.HumanoidRootPart.Position)
			tracer.From = Vector2.new(lp.X, lp.Y)
			tracer.To = Vector2.new(topScreen.X, topScreen.Y + height/2)
			-- Se estiver atrás de parede, usar cor diferente
			tracer.Color = behindWall and Color3.fromRGB(255, 165, 0) or finalColor
			tracer.Visible = true
		else
			tracer.Visible = false
		end

		if ESPName or ESPDistance or ESPTeams then
			local txt = ESPName and player.Name or ""
            local teamName = player.Team and player.Team.Name or "Sem Time"
            if isAdmin then teamName = teamName .. " - [ADM]" end
			
			if ESPDistance then 
				txt = txt .. string.format(" [%.1fm]", dist) 
			end
			
			-- Só mostrar time se ESPTeams estiver ativo
			if ESPTeams then
				if txt ~= "" then
					txt = txt .. "\nTime: " .. teamName
				else
					txt = "Time: " .. teamName
				end
			end
			
			-- Adicionar indicador de parede se estiver atrás
			if behindWall then
				txt = txt .. "\n🚧 ATRÁS DE PAREDE"
			end
			
			text.Text = txt
			text.Position = Vector2.new(screenX, screenY - 15)
			text.Color = behindWall and Color3.fromRGB(255, 165, 0) or finalColor
			text.Visible = true
        else
            text.Visible = false
		end

		-- Indicador de parede separado (ESPWall)
		if ESPWall then
			if behindWall then
				wallText.Text = "🚧 PAREDE"
				wallText.Position = Vector2.new(screenX, screenY + height + 55)
				wallText.Color = Color3.fromRGB(255, 165, 0)
				wallText.Visible = true
			else
				wallText.Visible = false
			end
		else
			wallText.Visible = false
		end

		if ESPGun then
			local isArmed = false
			for _, container in ipairs({char, player:FindFirstChild("Backpack")}) do
				if container then
					for _, item in ipairs(container:GetChildren()) do
						if item:IsA("Tool") then
							for _, wname in ipairs(weaponNames) do
								if item.Name:lower():find(wname:lower()) then
									isArmed = true
									break
								end
							end
						end
						if isArmed then break end
					end
				end
				if isArmed then break end
			end
			statusText.Text = isArmed and "Armado" or "Desarmado"
			statusText.Color = isArmed and Color3.fromRGB(255,50,50) or Color3.fromRGB(50,255,50)
			statusText.Position = Vector2.new(screenX, screenY + height + 5)
			statusText.Visible = true
		else
			statusText.Visible = false
		end

		if ESPmoney then
			local stats = player:FindFirstChild("leaderstats")
			if stats then
				local bank = stats:FindFirstChild("Bank")
				local carteira = stats:FindFirstChild("Carteira")
				if bank then
					bankText.Text = "💰 Bank: R$" .. tostring(bank.Value)
					bankText.Position = Vector2.new(screenX, screenY + height + 20)
					bankText.Visible = true
				else bankText.Visible = false end
				if carteira then
					carteiraText.Text = "👜 Carteira: R$" .. tostring(carteira.Value)
					carteiraText.Position = Vector2.new(screenX, screenY + height + 35)
					carteiraText.Visible = true
				else carteiraText.Visible = false end
			else
				bankText.Visible = false
				carteiraText.Visible = false
			end
		else
			bankText.Visible = false
			carteiraText.Visible = false
		end

		if ESPSkeleton then
			for i, pair in ipairs(skeletonPairs) do
				local n1, n2 = pair[1], pair[2]
				local p1 = char:FindFirstChild(n1)
				local p2 = char:FindFirstChild(n2)
				if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
					local s1, v1 = camera:WorldToViewportPoint(p1.Position)
					local s2, v2 = camera:WorldToViewportPoint(p2.Position)
					if v1 and v2 then
						skeletonLines[i].From = Vector2.new(s1.X, s1.Y)
						skeletonLines[i].To = Vector2.new(s2.X, s2.Y)
						skeletonLines[i].Visible = true
						skeletonLines[i].Color = behindWall and Color3.fromRGB(255, 165, 0) or finalColor
					else
						skeletonLines[i].Visible = false
					end
				else
					skeletonLines[i].Visible = false
				end
			end
		else
			for _, l in ipairs(skeletonLines) do l.Visible = false end
		end
	end)

	espElements[player] = {
		box = box,
		tracer = tracer,
		text = text,
		statusText = statusText,
		bankText = bankText,
		carteiraText = carteiraText,
		wallText = wallText,
		skeletonLines = skeletonLines,
		conn = conn
	}

	-- limpa quando morrer
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Died:Connect(function()
			removeESP(player)
		end)
	end
end

-- === Sistema principal ===
local function setupPlayer(plr)
	if plr == localPlayer then return end

	local function onCharacterAdded(char)
		char:FindFirstChild("Humanoid")
		createESP(plr)

		-- remove instantâneo na morte
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Died:Connect(function()
				removeESP(plr)
			end)
		end
	end

	if plr.Character then
		onCharacterAdded(plr.Character)
	end

	plr.CharacterAdded:Connect(onCharacterAdded)
end

-- Inicializar para jogadores existentes
for _, plr in ipairs(Players:GetPlayers()) do
	setupPlayer(plr)
end

-- Conectar eventos
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(p)
	removeESP(p)
end)

print("Sistema de visuals carregado. ESPWall disponível!")







local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Configurações
local AimFovEnabled = false
local FOV = 100
local smoothness = 0.15
local aimTarget = "Head"
local aiming = false

-- Novas variáveis que você pediu
local AutoLockEnabled = false         -- mira automaticamente mesmo sem segurar LMB
local TriggerCheckEnabled = false     -- detecta se pode atirar (sem atirar)
local WallCheckEnabled = false        -- verifica se existe parede entre player e alvo

-----------------------------------------------------------
-- 🎯 FOV ESTÁTICO NO CENTRO DA TELA
-----------------------------------------------------------
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Radius = FOV
fovCircle.Visible = AimFovEnabled

local function update_fov_circle()
    if AimFovEnabled then
        local center = Camera.ViewportSize / 2
        fovCircle.Position = Vector2.new(center.X, center.Y)
        fovCircle.Radius = FOV
    end
end

-----------------------------------------------------------
-- 🔎 ENCONTRA A MENOR PART (não BasePart, só Part)
-----------------------------------------------------------
local function findSmallestPart(character)
    local smallest = nil
    local smallestSize = math.huge

    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("Part") then
            local size = part.Size.X * part.Size.Y * part.Size.Z
            if size < smallestSize then
                smallestSize = size
                smallest = part
            end
        end
    end

    return smallest
end

-----------------------------------------------------------
-- 🎯 OBTÉM A PARTE ALVO CORRETA
-----------------------------------------------------------
local function getTargetPart(character)
    if aimTarget == "HumanoidRootPart" then
        return character:FindFirstChild("HumanoidRootPart")
    end

    local head = character:FindFirstChild("Head")
    if head then
        return head
    end

    -- fallback caso a head seja renomeada
    return findSmallestPart(character)
end

-----------------------------------------------------------
-- 🔦 SISTEMA DE WALL CHECK
-----------------------------------------------------------
local function wallCheck(origin, target)
    if not WallCheckEnabled then
        return true -- se wall check off, sempre permite
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {player.Character}

    local result = Workspace:Raycast(origin, (target - origin).Unit * 5000, params)

    if not result then
        return true
    end

    -- só aceita se o hit for no próprio alvo
    return result.Instance and result.Instance:IsDescendantOf(target.Parent)
end

-----------------------------------------------------------
-- 🎯 CHECA SE ESTÁ NO FOV CENTRAL
-----------------------------------------------------------
local function is_within_fov(worldpos)
    if not AimFovEnabled then return false end

    local screenPos, visible = Camera:WorldToViewportPoint(worldpos)
    if not visible then return false end

    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

    return dist <= FOV
end

-----------------------------------------------------------
-- 🔥 FUNÇÃO PRINCIPAL DO AIMBOT
-----------------------------------------------------------
local currentTarget = nil

local function getClosestTarget()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local closest = nil
    local closestDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            
            local part = getTargetPart(plr.Character)
            if part and is_within_fov(part.Position) then

                if wallCheck(Camera.CFrame.Position, part.Position) then
                    local dist = (part.Position - char.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = part
                    end
                end
            end
        end
    end

    return closest
end

-----------------------------------------------------------
-- 🎯 AIM SMOOTH + AUTOLOCK
-----------------------------------------------------------
local function aim_at_target()
    if not AimFovEnabled then return end

    -- Se autolock estiver ligado, mira sempre
    -- Se estiver off, mira apenas quando LMB estiver pressionado
    if not AutoLockEnabled and not aiming then
        currentTarget = nil
        return
    end

    currentTarget = getClosestTarget()

    if currentTarget then
        local dir = (currentTarget.Position - Camera.CFrame.Position).Unit
        Camera.CFrame = CFrame.new(
            Camera.CFrame.Position,
            Camera.CFrame.Position + Camera.CFrame.LookVector:Lerp(dir, smoothness)
        )
    end
end

-----------------------------------------------------------
-- 🔫 TRIGGER CHECK (SEM DISPARAR!)
-----------------------------------------------------------
local CanShootTarget = false -- variável pra você usar no seu sistema de tiro

local function trigger_check()
    if not TriggerCheckEnabled then
        CanShootTarget = false
        return
    end

    if currentTarget then
        -- Já passou pelo wall check na seleção do alvo
        CanShootTarget = true
    else
        CanShootTarget = false
    end
end

-----------------------------------------------------------
-- 🖱 CONTROLE DO LMB (só ativa mira normal)
-----------------------------------------------------------
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        aiming = false
    end
end)

-----------------------------------------------------------
-- ON/OFF DO FOV
-----------------------------------------------------------
local function toggle_fov(state)
    AimFovEnabled = state
    fovCircle.Visible = state
end

-----------------------------------------------------------
-- LOOP PRINCIPAL
-----------------------------------------------------------
RunService.RenderStepped:Connect(function()
    update_fov_circle()
    aim_at_target()
    trigger_check()
end)

print("Sistema completo carregado com AutoLock, TriggerCheck e WallCheck 🔥")












-- 🟢 ESP Geral
Tab1:NewToggle("ESP Geral", false, function(val)
    ESPEnabled = val
end)

-- 🟢 ESP Box
Tab1:NewToggle("ESP Box", false, function(val)
    ESPBox = val
end)

-- 🟢 ESP Tracer
Tab1:NewToggle("ESP Tracer", false, function(val)
    ESPTracer = val
end)

-- 🟢 ESP Nome
Tab1:NewToggle("ESP Name", false, function(val)
    ESPName = val
end)

-- 🟢 ESP Distância
Tab1:NewToggle("ESP Distance", false, function(val)
    ESPDistance = val
end)

-- 🟢 ESP Através da Parede
Tab1:NewToggle("ESP Wall", false, function(val)
    ESPWall = val
end)

-- 🟢 ESP Times
Tab1:NewToggle("ESP Teams", false, function(val)
    ESPTeams = val
end)

-- 🟢 ESP Arma
Tab1:NewToggle("ESP Gun", false, function(val)
    ESPGun = val
end)

-- 🟢 ESP Esqueleto
Tab1:NewToggle("ESP Skeleton", false, function(val)
    ESPSkeleton = val
end)




-- 🟢 Aim Fov
Tab1:NewToggle("Auto Lock", false, function(val)
    AutoLockEnabled = val
end)


-- 🟢 Aim Fov
Tab1:NewToggle("Trigger Bot", false, function(val)
    TriggerCheckEnabled = val
end)


-- 🟢 Aim Fov
Tab1:NewToggle("Wall Check", false, function(val)
    WallCheckEnabled = val
end)




-- 🟢 Aim Fov
Tab1:NewToggle("Aim Fov", false, function(val)
    toggle_fov(val)
end)


-- 🟣 Aimfov Suavidade (Smoothness)
Tab1:NewSlider("Aimfov Smoothness", "Controla a suavidade do AimFOV", false, "/", {min = 1, max = 100, default = 50}, function(val)
    smoothness = val / 100 -- converte o valor pra 0.01 - 1.00
end)

-- 🟣 Aimfov Tamanho (Size)
Tab1:NewSlider("Aimfov Size", "Define o tamanho do AimFOV", false, "/", {min = 1, max = 350 , default = 50}, function(val)
    FOV = val
end)

-- 🎯 AimPart Selector
Tab1:NewSelector("AimPart", "Escolha qual parte mirar", {"Head", "HumanoidRootPart"}, function(part)
    AimTargetPart = part
end)






----------------------------------------------------------
-- 📍 SISTEMA DE SELEÇÃO DE PLAYER
----------------------------------------------------------
local selectedPlayer = nil
local SelectedPlayer = nil
local currentDropdown = nil

-- 🧠 Função para obter nomes dos jogadores
local function getPlayerNames()
	local names = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		table.insert(names, plr.Name)
	end
	return names
end

local function createDropdown()
    if currentDropdown then
        currentDropdown:Remove()
    end

    -- 🔽 Cria o seletor (dropdown) de jogadores
    currentDropdown = Tab2:NewSelector("Selecionar Player", "Escolha o jogador alvo", getPlayerNames(), function(val)
        selectedPlayer = Players:FindFirstChild(val)
        SelectedPlayer = val
    end)
end


createDropdown()


-- Atualizar dropdown em tempo real
Players.PlayerAdded:Connect(createDropdown)
Players.PlayerRemoving:Connect(createDropdown)

----------------------------------------------------------
-- 👀 LOCALIZAR JOGADOR
----------------------------------------------------------
local locateESP = Drawing.new("Text")
locateESP.Size = 16
locateESP.Color = Color3.fromRGB(255, 255, 0)
locateESP.Outline = true
locateESP.Center = true
locateESP.Visible = false
locateESP.Font = 3

Tab2:NewToggle("Localizar Jogador", false, function(state)
	if not selectedPlayer then return end
	locateESP.Visible = state

	local connection
	connection = RunService.RenderStepped:Connect(function()
		if not state or not selectedPlayer or not selectedPlayer.Character then
			locateESP.Visible = false
			if connection then connection:Disconnect() end
			return
		end

		local root = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local pos, visible = Camera:WorldToViewportPoint(root.Position)
			if visible then
				locateESP.Position = Vector2.new(pos.X, pos.Y - 20)
				locateESP.Text = "👀 " .. selectedPlayer.Name
				locateESP.Visible = true
			else
				locateESP.Visible = false
			end
		end
	end)
end)

----------------------------------------------------------
-- 🚀 TELEPORTAR / VIEW / CAMERA / COPY
----------------------------------------------------------

-- 🔘 Teleportar
Tab2:NewButton("Teleportar para Jogador", function()
	if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
		end
	end
end)

-- 🔘 View
Tab2:NewButton("View Jogador", function()
	if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
		Camera.CameraSubject = selectedPlayer.Character.Humanoid
	end
end)

-- 🔘 Resetar Câmera
Tab2:NewButton("Resetar Camera", function()
	if player.Character then
		Camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
	end
end)

-- 🔘 Copiar Path
Tab2:NewButton("Copiar Path", function()
	if selectedPlayer and selectedPlayer.Character then
		local path = selectedPlayer:GetFullName()
		setclipboard(path)
	end
end)

----------------------------------------------------------
-- 😈 TROLL SYSTEM
----------------------------------------------------------

local LocalPlayer = Players.LocalPlayer
local bang, bangAnim, bangLoop, bangDied

-- Funções utilitárias
local function getRoot(char)
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function r15(plr)
	local char = plr.Character
	return char and char:FindFirstChild("UpperTorso") ~= nil
end

-- 🚀 Animação "Bang" e "Mamar"
local function startBang(mode, targetName)
	if bang then bang:Stop() end
	if bangAnim then bangAnim:Destroy() end
	if bangDied then bangDied:Disconnect() end
	if bangLoop then bangLoop:Disconnect() end

	local char = LocalPlayer.Character
	if not char then return end
	local rootPart = getRoot(char)
	if not humanoid or not rootPart then return end

	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	humanoid.AutoRotate = false

	bangAnim = Instance.new("Animation")
	bangAnim.AnimationId = r15(LocalPlayer) and "rbxassetid://82070755455634" or "rbxassetid://82070755455634"
	bang = humanoid:LoadAnimation(bangAnim)
	bang.Looped = true
	bang:Play(0.1, 1, 1)

	bangDied = humanoid.Died:Connect(function()
		bang:Stop()
		bangAnim:Destroy()
		humanoid.AutoRotate = true
		bangLoop:Disconnect()
	end)

	local target = Players:FindFirstChild(targetName)
	if not (target and target.Character) then return end

	bangLoop = RunService.Stepped:Connect(function()
		pcall(function()
			local targetRoot = getRoot(target.Character)
			if not targetRoot then return end

			local offsetFront = (mode == "mamar") and 1.2 or 1.1
			local offsetHeight = (mode == "mamar") and 1.45 or 0
			local targetPos = targetRoot.Position + Vector3.new(0, offsetHeight, 0)
			local offsetDir = -targetRoot.CFrame.LookVector * offsetFront
			local finalPos = targetPos + offsetDir
			local lookAt = CFrame.lookAt(finalPos, targetPos)

			rootPart.Velocity = Vector3.zero
			rootPart.CFrame = lookAt
		end)
	end)
end

-- 🛑 Parar animação
local function stopBang()
	if bang then bang:Stop() bang = nil end
	if bangAnim then bangAnim:Destroy() bangAnim = nil end
	if bangDied then bangDied:Disconnect() bangDied = nil end
	if bangLoop then bangLoop:Disconnect() bangLoop = nil end

	if humanoid then
		humanoid.AutoRotate = true
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

----------------------------------------------------------
-- 🎚️ Toggles Troll
----------------------------------------------------------

-- 🍽️ Comer Player
Tab2:NewToggle("Comer Player", false, function(state)
	if state and SelectedPlayer then
		startBang("bang", SelectedPlayer)
	else
		stopBang()
	end
end)

-- 🍆 Botar pra mamar
Tab2:NewToggle("Botar pra Mamar", false, function(state)
	if state and SelectedPlayer then
		startBang("mamar", SelectedPlayer)
	else
		stopBang()
	end
end)

-- 💨 Fling / Kill
Tab2:NewToggle("Fling / Kill", false, function(state)
	local target = Players:FindFirstChild(SelectedPlayer)
	if state then
		if target then
			flingActive = true
			task.spawn(function()
				SkidFling(target)
			end)
		else
			warn("Player inválido!")
		end
	else
		StopSkidFling()
	end
end)

-- 🧲 Puxar Jogador Selecionado
Tab2:NewToggle("Puxar Selecionado", false, function(state)
	if state and selectedPlayer then
		_G.BringSelectedRunning = true
		task.spawn(function()
			while _G.BringSelectedRunning and selectedPlayer and selectedPlayer.Character do
				local targetHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
				local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if targetHRP and myHRP then
					targetHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -2)
				end
				task.wait()
			end
		end)
	else
		_G.BringSelectedRunning = false
	end
end)

-- 🌪️ Puxar Todos
Tab2:NewToggle("Puxar Todos", false, function(state)
	if state then
		_G.BringAllRunning = true
		task.spawn(function()
			while _G.BringAllRunning do
				local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if myHRP then
					for _, plr in ipairs(Players:GetPlayers()) do
						if plr ~= player and plr.Character then
							local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
							if targetHRP then
								targetHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -2)
							end
						end
					end
				end
				task.wait()
			end
		end)
	else
		_G.BringAllRunning = false
	end
end)

----------------------------------------------------------
-- 🚶‍♂️ Seguir Jogador (Loop TP)
----------------------------------------------------------
local noclipConnection
local tpLoopConnection

Tab2:NewToggle("Seguir Jogador", false, function(state)
	if state then
		noclipConnection = RunService.Stepped:Connect(function()
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				player.Character.Humanoid:ChangeState(11)
			end
		end)

		tpLoopConnection = RunService.Heartbeat:Connect(function()
			if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local char = player.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					local hrp = char.HumanoidRootPart
					hrp.Velocity = Vector3.zero
					hrp.CFrame = CFrame.new(selectedPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
				end
			end
		end)
	else
		if noclipConnection then noclipConnection:Disconnect() end
		if tpLoopConnection then tpLoopConnection:Disconnect() end
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end)







local function PuxarArmas()
    for _,v in pairs(game.ReplicatedStorage:GetDescendants()) do
        if v:IsA("Tool") then
            v.Parent = game.Players.LocalPlayer.Backpack
            print("Rep: ", v)
        end
    end

    for _,g in pairs(game.Teams:GetDescendants()) do
        if g:IsA("Tool") then
            g.Parent = game.Players.LocalPlayer.Backpack
            print("Teams: ", g)
        end
    end
end



local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local FLYING = false
local QEfly = true
local flySpeed = 5
local flyKeyDown, flyKeyUp
local bodyGyro = nil
local bodyVelocity = nil
local noclipConnection = nil

local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local targetVelocity = Vector3.zero
local currentVelocity = Vector3.zero

-- IDs das animações (substitua pelos seus)
local runAnimId = "rbxassetid://86655743171657"
local idleAnimId = "rbxassetid://107817714498111"
local runAnimation, idleAnimation = nil, nil
local runTrack, idleTrack = nil, nil
local AnimationPriority = Enum.AnimationPriority

function getRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

function smoothVelocity(bv, target)
    if bv and bv.Parent then
        local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local goal = {Velocity = target}
        local tween = TweenService:Create(bv, tweenInfo, goal)
        tween:Play()
    end
end

local function startNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = true end)
            end
        end
    end
end

local function setupAnimations()
    if not humanoid then return end
    runAnimation = Instance.new("Animation")
    runAnimation.AnimationId = runAnimId
    idleAnimation = Instance.new("Animation")
    idleAnimation.AnimationId = idleAnimId
    runTrack = humanoid:LoadAnimation(runAnimation)
    idleTrack = humanoid:LoadAnimation(idleAnimation)
    runTrack.Priority = AnimationPriority.Action4
    idleTrack.Priority = AnimationPriority.Action4
end

local function updateAnimation()
    if not runTrack or not idleTrack then return end
    local isMoving = (CONTROL.F ~= 0 or CONTROL.B ~= 0 or CONTROL.L ~= 0 or CONTROL.R ~= 0 or CONTROL.Q ~= 0 or CONTROL.E ~= 0)
    if isMoving then
        if idleTrack.IsPlaying then idleTrack:Stop() end
        if not runTrack.IsPlaying then runTrack:Play() end
    else
        if runTrack.IsPlaying then runTrack:Stop() end
        if not idleTrack.IsPlaying then idleTrack:Play() end
    end
end

function startSmoothFly(vfly)
    repeat task.wait() until player.Character and getRoot(player.Character) and player.Character:FindFirstChildOfClass("Humanoid")

    if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
    if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
    if bodyGyro then pcall(function() bodyGyro:Destroy() end) bodyGyro = nil end
    if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) bodyVelocity = nil end

    local char = player.Character
    local root = getRoot(char)
    humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    setupAnimations()

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 5e3
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    if not vfly and humanoid then humanoid.PlatformStand = true end

    startNoclip()
    FLYING = true

    task.spawn(function()
        while FLYING do
            task.wait()
            local direction = (Camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((Camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.Q + CONTROL.E) * 0.2, 0)).Position - Camera.CFrame.Position)
            if direction.Magnitude > 0 then
                targetVelocity = direction.Unit * flySpeed
            else
                targetVelocity = Vector3.zero
            end

            local maxTilt = 30
            local tiltAmount = (CONTROL.F + CONTROL.B) * maxTilt * 0.02
            smoothVelocity(bodyVelocity, targetVelocity)
            if bodyGyro and bodyGyro.Parent then
                bodyGyro.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(math.rad(-tiltAmount), 0, 0)
            end

            updateAnimation()
        end

        if runTrack and runTrack.IsPlaying then runTrack:Stop() end
        if idleTrack and idleTrack.IsPlaying then idleTrack:Stop() end
        if bodyVelocity and bodyVelocity.Parent then pcall(function() bodyVelocity:Destroy() end) end
        bodyVelocity = nil
        if bodyGyro and bodyGyro.Parent then pcall(function() bodyGyro:Destroy() end) end
        bodyGyro = nil
        if humanoid then humanoid.PlatformStand = false end
    end)

    flyKeyDown = player:GetMouse().KeyDown:Connect(function(key)
        key = key:lower()
        if key == 'w' then CONTROL.F = 1 end
        if key == 's' then CONTROL.B = -1 end
        if key == 'a' then CONTROL.L = -1 end
        if key == 'd' then CONTROL.R = 1 end
        if QEfly and key == 'e' then CONTROL.Q = 1 end
        if QEfly and key == 'q' then CONTROL.E = -1 end
        pcall(function() Camera.CameraType = Enum.CameraType.Track end)
    end)

    flyKeyUp = player:GetMouse().KeyUp:Connect(function(key)
        key = key:lower()
        if key == 'w' then CONTROL.F = 0 end
        if key == 's' then CONTROL.B = 0 end
        if key == 'a' then CONTROL.L = 0 end
        if key == 'd' then CONTROL.R = 0 end
        if key == 'e' then CONTROL.Q = 0 end
        if key == 'q' then CONTROL.E = 0 end
    end)
end

function stopFly()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
    if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
    stopNoclip()
    if bodyVelocity and bodyVelocity.Parent then pcall(function() bodyVelocity:Destroy() end) end
    bodyVelocity = nil
    if bodyGyro and bodyGyro.Parent then pcall(function() bodyGyro:Destroy() end) end
    bodyGyro = nil
    if runTrack and runTrack.IsPlaying then runTrack:Stop() end
    if idleTrack and idleTrack.IsPlaying then idleTrack:Stop() end
    pcall(function()
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        Camera.CameraType = Enum.CameraType.Custom
    end)
    CONTROL.F, CONTROL.B, CONTROL.L, CONTROL.R, CONTROL.Q, CONTROL.E = 0, 0, 0, 0, 0, 0
    targetVelocity = Vector3.zero
    currentVelocity = Vector3.zero
end

-- Noclip helpers
local function enableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
end

-- Fly toggle
local vflyEnabled = false
local function setFlyState(state)
    vflyEnabled = state
    if vflyEnabled then
        enableNoclip()
        startSmoothFly()
    else
        stopFly()
        disableNoclip()
    end
end




----------------------------------------------------------
-- 🎚️ TOGGLE: Fly / Noclip
----------------------------------------------------------
Tab3:NewToggle("Noclip / Fly", false, function(state)
	setFlyState(state)
end)

----------------------------------------------------------
-- ⌨️ KEYBIND: Ativar com RightControl
----------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		setFlyState(not vflyEnabled)
	end
end)

----------------------------------------------------------
-- 💬 Sistema de Char Keybind
----------------------------------------------------------
local function setCharState(state)
	charEnabled = state
end

Tab3:NewToggle("Char Keybind", false, function(state)
	setCharState(state)
end)

-- ✉️ Enviar comando /char pelo chat
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not charEnabled then return end
	if input.KeyCode == Enum.KeyCode.RightBracket then
		local channel = TextChatService:FindFirstChild("TextChannels")
		if channel and channel:FindFirstChild("RBXGeneral") then
			channel.RBXGeneral:SendAsync("/char Hhgefthgwe")
		end
	end
end)

----------------------------------------------------------
-- 💥 CLICK FLING
----------------------------------------------------------

-- Auxiliar: tornar todas partes colidíveis
local function setCollidable(model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = true
		end
	end
end

function setClickFlingState(state)
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if state and not clickFlingEnabled then
		clickFlingEnabled = true
		print("⚡ ClickFling ON")

		flingConn = mouse.Button1Down:Connect(function()
			local target = mouse.Target
			if not target then return end

			local originalCFrame = hrp.CFrame
			local pos = target.Position

			if target.Parent then setCollidable(target.Parent) end
			setCollidable(target)

			local flingLoop
			flingLoop = RunService.Heartbeat:Connect(function()
				if not clickFlingEnabled then flingLoop:Disconnect() return end
				hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(tick()*9999), 0)
				hrp.AssemblyAngularVelocity = Vector3.new(0, 9e9, 0)
				hrp.AssemblyLinearVelocity = Vector3.new(9e9, 9e9, 9e9)
			end)

			local release
			release = mouse.Button1Up:Connect(function()
				flingLoop:Disconnect()
				release:Disconnect()
				hrp.CFrame = originalCFrame
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end)
	else
		clickFlingEnabled = false
		if flingConn then
			flingConn:Disconnect()
			flingConn = nil
		end
		print("🛑 ClickFling OFF")
	end
end

-- 🎚️ TOGGLE: ClickFling
Tab3:NewToggle("ClickFling", false, function(state)
	setClickFlingState(state)
end)




local Camera = workspace.CurrentCamera

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local cameraFov = 85
local fcRunning = false
local stepConnection

-- SPRING
local Spring = {}
Spring.__index = Spring
function Spring.new(freq, pos)
    return setmetatable({f = freq, p = pos, v = pos * 0}, Spring)
end
function Spring:Update(dt, goal)
    local f = self.f * 2 * math.pi
    local p0, v0 = self.p, self.v
    local offset = goal - p0
    local decay = math.exp(-f * dt)
    local p1 = goal + (v0 * dt - offset * (f * dt + 1)) * decay
    local v1 = (f * dt * (offset * f - v0) + v0) * decay
    self.p, self.v = p1, v1
    return p1
end
function Spring:Reset(pos)
    self.p = pos
    self.v = pos * 0
end

local velSpring = Spring.new(5, Vector3.new())
local panSpring = Spring.new(5, Vector2.new())

-- INPUT
local keyboard = {W=0,A=0,S=0,D=0,E=0,Q=0,Up=0,Down=0}
local mouseDelta = Vector2.new()
local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
local PAN_MOUSE_SPEED = Vector2.new(1, 1)*(math.pi/64)
local NAV_ADJ_SPEED = 0.75
local NAV_SHIFT_MUL = 0.25
local navSpeed = 5

local function Vel(dt)
    navSpeed = math.clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)
    local k = Vector3.new(keyboard.D - keyboard.A, keyboard.E - keyboard.Q, keyboard.S - keyboard.W) * NAV_KEYBOARD_SPEED
    local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    return k * (navSpeed * (shift and NAV_SHIFT_MUL or 1))
end
local function Pan()
    local k = mouseDelta * PAN_MOUSE_SPEED
    mouseDelta = Vector2.new()
    return k
end

-- PLAYER STATE (guarda e restaura câmera/mouse)
local savedState = {}
local function SavePlayerState()
    savedState.cameraFov = Camera.FieldOfView
    savedState.cameraType = Camera.CameraType
    savedState.cameraCFrame = Camera.CFrame
    savedState.cameraFocus = Camera.Focus
    savedState.mouseIconEnabled = UserInputService.MouseIconEnabled
    savedState.mouseBehavior = UserInputService.MouseBehavior
end
local function RestorePlayerState()
    Camera.FieldOfView = savedState.cameraFov or 70
    Camera.CameraType = savedState.cameraType or Enum.CameraType.Custom
    Camera.CFrame = savedState.cameraCFrame or Camera.CFrame
    Camera.Focus = savedState.cameraFocus or Camera.Focus
    UserInputService.MouseIconEnabled = savedState.mouseIconEnabled
    UserInputService.MouseBehavior = savedState.mouseBehavior or Enum.MouseBehavior.Default
end

-- INPUT EVENTS
UserInputService.InputBegan:Connect(function(input, gp)
    if not fcRunning or gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if keyboard[input.KeyCode.Name] ~= nil then
            keyboard[input.KeyCode.Name] = 1
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if not fcRunning or gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if keyboard[input.KeyCode.Name] ~= nil then
            keyboard[input.KeyCode.Name] = 0
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

UserInputService.InputChanged:Connect(function(input, gp)
    if not fcRunning or gp then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        mouseDelta = Vector2.new(-input.Delta.y, -input.Delta.x)
    end
end)

-- FOCUS
local function GetFocusDistance(cf)
    local znear = 0.1
    local viewport = Camera.ViewportSize
    local projy = 2 * math.tan(math.rad(cameraFov / 2))
    local projx = viewport.X / viewport.Y * projy
    local fx, fy, fz = cf.RightVector, cf.UpVector, cf.LookVector
    local minDist, minVect = 512, Vector3.new()
    for x = 0, 1, 0.5 do
        for y = 0, 1, 0.5 do
            local cx = (x - 0.5) * projx
            local cy = (y - 0.5) * projy
            local offset = fx * cx - fy * cy + fz
            local origin = cf.Position + offset * znear
            local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.Unit * minDist))
            if hit then
                local dist = (hit.Position - origin).Magnitude
                if dist < minDist then
                    minDist = dist
                    minVect = offset.Unit
                end
            end
        end
    end
    return fz:Dot(minVect) * minDist
end

-- STEP
local function Step(dt)
    local vel = velSpring:Update(dt, Vel(dt))
    local pan = panSpring:Update(dt, Pan())

    local zoomFactor = math.sqrt(math.tan(math.rad(70 / 2)) / math.tan(math.rad(cameraFov / 2)))
    cameraRot = cameraRot + pan * Vector2.new(0.75, 1) * 8 * (dt / zoomFactor)
    cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y % (2 * math.pi))

    local camCF = CFrame.new(cameraPos) * CFrame.fromOrientation(cameraRot.X, cameraRot.Y, 0) * CFrame.new(vel * 64 * dt)
    cameraPos = camCF.Position

    Camera.CFrame = camCF
    Camera.Focus = camCF * CFrame.new(0, 0, -GetFocusDistance(camCF))
    Camera.FieldOfView = cameraFov
end

-- START / STOP
function StartFreecam(pos)
    if fcRunning then StopFreecam() end
    fcRunning = true

    SavePlayerState()

    -- trava player no lugar
    if LocalPlayer.Character then
        Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = 0
            Humanoid.JumpPower = 0
        end
    end

    local cf = Camera.CFrame
    if pos then cf = pos end
    cameraRot = Vector2.new()
    cameraPos = cf.Position
    cameraFov = Camera.FieldOfView
    velSpring:Reset(Vector3.new())
    panSpring:Reset(Vector2.new())

    stepConnection = RunService.RenderStepped:Connect(Step)
end

function StopFreecam()
    if not fcRunning then return end
    fcRunning = false

    if stepConnection then
        stepConnection:Disconnect()
        stepConnection = nil
    end

    -- restaura player
    if Humanoid then
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
    end

    RestorePlayerState()
end


-- Lista de animações de RP
local RPAnimations = {
    ["/deitar"] = 104049807204779,
    ["/ameacar"] = 124747493968285,
    ["/sarrar"] = 104826288857844,
    ["/passinho"] = 103360497719320,
    ["/balanco"] = 129357062468183,
    ["/aura"] = 122746752555782,
    ["/aura2"] = 98352002677627,
    ["/aura3"] = 87245594012846,
    ["/morrer"] = 97524873576958,
    ["/apontar"] = 88764142128140,
    ["/mirar"] = 118139871934372,
    ["/encostar"] = 125450186283254,
    ["/lean"] = 117134385802437,
    ["/gin"] = 117134385802437,
    ["/whiskky"] = 117134385802437,
    ["/sensualizar"] = 85312683743028,
    ["/ainpapai"] = 104151027065011,
    ["/nananinanão"] = 85811771512356,
    ["/remexido"] = 77100135939123,
    ["/tocar"] = 110978806315921,
    ["/parar"] = "stop"
}

-- Flags
local rpModeEnabled = false
local currentTrack -- animação atual

-- Função pra tocar animação
local function playAnim(animId)
    if currentTrack and currentTrack.IsPlaying then
        currentTrack:Stop()
    end

    if animId == "stop" then
        currentTrack = nil
        return
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://"..animId
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    currentTrack = track

    -- Para se o player andar
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if humanoid.MoveDirection.Magnitude > 0 then
            if track.IsPlaying then
                track:Stop()
            end
            conn:Disconnect()
        end
    end)
end

-- Sempre atualizar humanoid quando respawnar
local function setupCharacter(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    currentTrack = nil
end
player.CharacterAdded:Connect(setupCharacter)

TextChatService.OnIncomingMessage = function(msg)
    -- mensagens de sistema ou sem texto não devem quebrar
    if not msg or not msg.Text then
        return nil
    end

    local src = msg.TextSource
    local sender = src and Players:GetPlayerByUserId(src.UserId)
    local content = msg.Text

    -- só processa se for mensagem de player
    if sender then
        -- Admin commands
        if AdminEnabled and content then
            if sender == LocalPlayer then
                ProcessMessage(sender, content)
            end
        end

        -- RP Mode
        if rpModeEnabled and sender == LocalPlayer and content then
            local lowerText = string.lower(content)
            if RPAnimations[lowerText] then
                playAnim(RPAnimations[lowerText])
            end
        end
    end

    -- não altera a mensagem original → deixa o chat normal
    return nil
end











-- ===== Invisibilidade estilo Infinite Yield com Toggle =====
local IsInvis = false
local InvisibleCharacter, Character
local invisRunning = false
local StoredCF

-- Função principal: ativa invisibilidade
local function TurnInvisible()
    if invisRunning then return end
    invisRunning = true
    if IsInvis then return end
    IsInvis = true

    Character = Player.Character
    if not Character or not Character.Parent then
        invisRunning = false
        return
    end

    Character.Archivable = true
    local Clone = Character:Clone()
    InvisibleCharacter = Clone
    InvisibleCharacter.Parent = game:GetService("Lighting")
    InvisibleCharacter.Name = ""
    InvisibleCharacter.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame

    StoredCF = Character.HumanoidRootPart.CFrame
    Character.Parent = nil

    Player.Character = InvisibleCharacter

    -- Reatacha câmera igual Infinite Yield
    local cam = workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Scriptable
    task.wait(0.2)
    cam.CameraSubject = InvisibleCharacter:FindFirstChildWhichIsA("Humanoid")
    cam.CameraType = Enum.CameraType.Custom

    -- Checagem de void
    local Void = workspace.FallenPartsDestroyHeight
    local invisFix
    invisFix = RunService.Stepped:Connect(function()
        pcall(function()
            local posY = Player.Character.HumanoidRootPart.Position.Y
            local isInteger = tostring(Void):find('-') and true or false
            if (isInteger and posY <= Void) or (not isInteger and posY >= Void) then
                Respawn()
            end
        end)
    end)

    -- Define transparências do clone
    for _, v in pairs(InvisibleCharacter:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = v.Name == "HumanoidRootPart" and 1 or 0.5
        end
    end

    -- Função de respawn
    function Respawn()
        if IsInvis then
            pcall(function()
                Player.Character = Character
                task.wait()
                Character.Parent = workspace
                Character:FindFirstChildWhichIsA("Humanoid"):Destroy()
                InvisibleCharacter.Parent = nil
                IsInvis = false
                invisRunning = false
            end)
        else
            pcall(function()
                Player.Character = Character
                task.wait()
                Character.Parent = workspace
                TurnVisible()
            end)
        end
    end

    -- Detecta morte do clone
    local invisDied
    invisDied = InvisibleCharacter:FindFirstChildOfClass("Humanoid").Died:Connect(function()
        Respawn()
        invisDied:Disconnect()
    end)

    -- Move câmera para clone
    local CF_1 = Player.Character.HumanoidRootPart.CFrame
    Character:MoveTo(Vector3.new(0, math.pi * 1000000, 0))
    Player.Character = InvisibleCharacter
    InvisibleCharacter.Parent = workspace
    InvisibleCharacter.HumanoidRootPart.CFrame = CF_1
    Player.Character.Animate.Disabled = true
    Player.Character.Animate.Disabled = false

    -- Função para voltar visível
    function TurnVisible()
        if not IsInvis then return end
        invisFix:Disconnect()
        invisDied:Disconnect()
        local CF_1 = Player.Character.HumanoidRootPart.CFrame
        Character.HumanoidRootPart.CFrame = CF_1
        InvisibleCharacter:Destroy()
        Player.Character = Character
        Character.Parent = workspace
        IsInvis = false
        Player.Character.Animate.Disabled = true
        Player.Character.Animate.Disabled = false
        invisDied = Character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
            Respawn()
            invisDied:Disconnect()
        end)
        invisRunning = false
    end
end


-----------------------------------------------------
-- 🌀 RESET PLAYER
-----------------------------------------------------
Tab3:NewButton("Reset Player", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
    end
end)


-----------------------------------------------------
-- 💃 EMOTE PLAYER
-----------------------------------------------------


local emoteid = nil
local EmoteId = Tab3:NewTextbox("Insira o id...", "", "1", "all", "small", true, false, function(val)
    emoteid = val
end)


local danceTrack
Tab3:NewButton("Emote Player", function()
    if danceTrack then
        danceTrack:Stop()
        danceTrack:Destroy()
        danceTrack = nil
        return
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. emoteid -- Substitua pelo ID desejado
    danceTrack = Humanoid:LoadAnimation(animation)
    danceTrack.Priority = Enum.AnimationPriority.Action4
    danceTrack.Looped = true
    danceTrack:Play()

    -- Para automaticamente ao se mover
    local HRP = character:WaitForChild("HumanoidRootPart")
    local lastPos = HRP.Position
    task.spawn(function()
        while danceTrack and danceTrack.IsPlaying do
            task.wait(0.1)
            if (HRP.Position - lastPos).Magnitude > 0.05 then
                danceTrack:Stop()
                danceTrack:Destroy()
                danceTrack = nil
                break
            end
            lastPos = HRP.Position
        end
    end)
end)


----------------------------------------------------------
-- 🎥 FREECAM TOGGLE
----------------------------------------------------------
Tab3:NewToggle("Freecam", false, function(state)
    if state then
        StartFreecam()
    else
        StopFreecam()
    end
end)

----------------------------------------------------------
-- 🌀 TP TOOL TOGGLE
----------------------------------------------------------
Tab3:NewToggle("TP Tool", false, function(state)
    if state then
        -- Cria Tool
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "TP Tool"

        -- Clique para teleportar
        tool.Activated:Connect(function()
            local mouse = Players.LocalPlayer:GetMouse()
            if mouse and mouse.Hit then
                local char = Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end
        end)

        tool.Parent = Players.LocalPlayer.Backpack
    else
        -- Remove caso já exista
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        local char = Players.LocalPlayer.Character
        if backpack and backpack:FindFirstChild("TP Tool") then
            backpack["TP Tool"]:Destroy()
        end
        if char and char:FindFirstChild("TP Tool") then
            char["TP Tool"]:Destroy()
        end
    end
end)

----------------------------------------------------------
-- 👻 INVISIBILIDADE (Infinite Yield Style)
----------------------------------------------------------
Tab3:NewToggle("Invisible", false, function(state)
    if state then
        TurnInvisible()
    else
        if IsInvis then
            TurnVisible()
        end
    end
end)

-- 💥 Invisibilidade por bug (carro/moto)
Tab3:NewButton("SeatBreak", function()
    game.ReplicatedStorage.DeleteCar:FireServer()
end)

----------------------------------------------------------
-- ⚙️ SLIDERS DE VELOCIDADE
----------------------------------------------------------

-- Velocidade Fly
Tab3:NewSlider("Velocidade do Noclip", "Controla a velocidade do modo fly/noclip", true, "/", {min = 1, max = 500, default = flySpeed}, function(v)
	flySpeed = v
end)

-- Velocidade da Freecam
Tab3:NewSlider("Freecam Speed", "Ajusta velocidade da câmera livre", true, "/", {min = 1, max = 100, default = navSpeed}, function(val)
	NAV_KEYBOARD_SPEED = Vector3.new(val, val, val)
end)

----------------------------------------------------------
-- 🎭 MODO RP (Animações de Roleplay)
----------------------------------------------------------
Tab3:NewToggle("Modo RP", false, function(state)
	rpModeEnabled = state
	if state then
		print("Modo RP Ativo ✅ - Comandos: /deitar, /ameacar, /sarrar, /passinho, /balanco, /aura, /aura2, /aura3, /parar")
	else
		if currentTrack and currentTrack.IsPlaying then
			currentTrack:Stop()
		end
		currentTrack = nil
	end
end)



----------------------------------------------------------
-- 🔫 ARMAS
----------------------------------------------------------
armaSelecionada = nil

-- 🔎 Função: obter lista de armas no ReplicatedStorage
local function getGuns()
	local items = {}
	for _, v in pairs(game.ReplicatedStorage:GetDescendants()) do
		if v:IsA("Tool") then
			table.insert(items, v.Name)
		end
	end
	return items
end

-- 🔧 Função: puxar arma selecionada
local function getSelectedGun()
	local found = false
	for _, v in pairs(game.ReplicatedStorage:GetDescendants()) do
		if v.Name == tostring(armaSelecionada) then
			v.Parent = player.Backpack
			print("[PUXADA] - Arma: " .. armaSelecionada)
			found = true
			break
		end
	end
	if not found then
		warn("Arma não encontrada!")
	end
end

-- 🎯 Dropdown de seleção de armas
Tab4:NewSelector("Selecionar Arma / Item", "Escolha uma arma para puxar", getGuns(), function(val)
	armaSelecionada = val
end)

-- 🔘 Botão: puxar arma selecionada
Tab4:NewButton("Puxar Arma Selecionada", function()
	getSelectedGun()
end)

-- 🔘 Botão: puxar todas as armas
Tab4:NewButton("Puxar Todas as Armas", function()
	if PuxarArmas then
		PuxarArmas()
	else
		warn("Função 'PuxarArmas' não encontrada!")
	end
end)

-- 🔹 Separador visual
Tab4:NewLabel("──────── POZE MENU ────────")

----------------------------------------------------------
-- 🧩 DEV TOOLS (FE / Eventos / Dex)
----------------------------------------------------------

-- 🧠 Botão: executar Dex Explorer
Tab5:NewButton("Executar Dex", function()
	Notif:Notify("Carregando Dex Explorer...", 5, "sucess")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

----------------------------------------------------------
-- ⚙️ EVENTOS FE (Remotes)
----------------------------------------------------------
local selectedEvent = nil
local inputtext = ""
local textBoxActive = false
local ContextActionService = game:GetService("ContextActionService")

-- 🔍 Obter todos eventos remotos do jogo
local function getAllEvents()
	local events = {}
	for _, v in ipairs(game.ReplicatedStorage:GetDescendants()) do
		if v:IsA("RemoteEvent") then
			table.insert(events, v.Name)
		end
	end
	return events
end

----------------------------------------------------------
-- 💬 Caixa de entrada externa (GUI custom)
----------------------------------------------------------

Tab5:NewTextbox("Insira o argumento...", "", "1", "all", "small", true, false, function(val)
    inputtext = val
end)


----------------------------------------------------------
-- 📜 Lista de eventos
----------------------------------------------------------
Tab5:NewSelector("Selecionar Evento", "Escolha um RemoteEvent", getAllEvents(), function(val)
	for _, v in ipairs(game.ReplicatedStorage:GetDescendants()) do
		if v.Name == val and v:IsA("RemoteEvent") then
			selectedEvent = v
			break
		end
	end
end)

----------------------------------------------------------
-- 🔘 Botão: Disparar Evento Remoto
----------------------------------------------------------
Tab5:NewButton("Fire Event Selecionado", function()
	if selectedEvent then
		selectedEvent:FireServer(inputtext)
		print("🔥 Evento disparado:", selectedEvent.Name)
		print("📦 Argumento:", inputtext)
	else
		warn("Nenhum evento selecionado!")
	end
end)







-----------------------------------------
-- MOBILE SYSTEM INTEGRATION 📱
-----------------------------------------

local MobileOpen

local function createMobileIcon()
    if MobileOpen then
        MobileOpen:Destroy()
    end


    local gui2 = Instance.new("ScreenGui")
    gui2.Name = "OpenMobile"
    gui2.ResetOnSpawn = false
    gui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui2.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local open = Instance.new("ImageButton")
    open.Name = "MobileOpen"
    open.Size = UDim2.new(0, 50, 0, 50)
    open.Position = UDim2.new(0, 10, 0, 5)
    open.BackgroundTransparency = 0
    open.Image = "rbxassetid://76977741215928"
    open.ImageTransparency = 0
    open.AutoButtonColor = true
    open.Parent = gui2

    local openCorner = Instance.new("UICorner")
    openCorner.CornerRadius = UDim.new(0.9)
    openCorner.Parent = open


    open.MouseButton1Down:Connect(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")

        -- Simula o pressionar e soltar da tecla "G"
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightAlt, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightAlt, false, game)
    end)

    MobileOpen = gui2
end


createMobileIcon()

----------------------------------------------------------
-- ✅ NOTIFICAÇÃO FINAL
----------------------------------------------------------
Notif:Notify("✅ Armas e Dev Tools carregados com sucesso!", 4, "success")
