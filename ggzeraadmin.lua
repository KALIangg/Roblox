-- ===== Admin Core =====
local AdminEnabled = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local Prefix = "/"

local Commands = {}
local Registered = {}
local Aliases = {}
local CommandMeta = {}
local HideChatCommands = false

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
    for _,plr in ipairs(Players:GetPlayers()) do
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
        if text:sub(1, #p) == p then return true end
    end
    return false
end


---- CREATE LOGS GUI ----

local function createLogsGui(titleText, storedTable)
    local existing = LocalPlayer.PlayerGui:FindFirstChild(titleText)
    if existing then existing.Enabled = true return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = titleText
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.Position = UDim2.new(0.2, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 32)
    Title.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Text = "📜 "..titleText
    Title.Parent = Main

    -- Botões de controle
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 60, 0, 26)
    Close.Position = UDim2.new(1, -65, 0, 3)
    Close.BackgroundColor3 = Color3.fromRGB(200,50,50)
    Close.TextColor3 = Color3.new(1,1,1)
    Close.Font = Enum.Font.SourceSansBold
    Close.TextSize = 16
    Close.Text = "X"
    Close.Parent = Main

    local Clear = Instance.new("TextButton")
    Clear.Size = UDim2.new(0, 80, 0, 26)
    Clear.Position = UDim2.new(1, -150, 0, 3)
    Clear.BackgroundColor3 = Color3.fromRGB(70,70,200)
    Clear.TextColor3 = Color3.new(1,1,1)
    Clear.Font = Enum.Font.SourceSansBold
    Clear.TextSize = 14
    Clear.Text = "Limpar"
    Clear.Parent = Main

    local Pause = Instance.new("TextButton")
    Pause.Size = UDim2.new(0, 110, 0, 26)
    Pause.Position = UDim2.new(0, 6, 0, 3)
    Pause.BackgroundColor3 = Color3.fromRGB(70,200,70)
    Pause.TextColor3 = Color3.new(1,1,1)
    Pause.Font = Enum.Font.SourceSansBold
    Pause.TextSize = 14
    Pause.Text = "⏸️ Pausar"
    Pause.Parent = Main

    -- Campo de pesquisa
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0, 250, 0, 26)
    SearchBox.Position = UDim2.new(0, 120, 0, 3)
    SearchBox.PlaceholderText = "Pesquisar mensagens..."
    SearchBox.ClearTextOnFocus = false
    SearchBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    SearchBox.TextColor3 = Color3.new(1,1,1)
    SearchBox.Font = Enum.Font.SourceSans
    SearchBox.TextSize = 14
    SearchBox.Parent = Main

    -- ScrollingFrame com rolagem horizontal e vertical
    local Scrolling = Instance.new("ScrollingFrame")
    Scrolling.Size = UDim2.new(1, -10, 1, -44)
    Scrolling.Position = UDim2.new(0, 5, 0, 38)
    Scrolling.BackgroundTransparency = 1
    Scrolling.ScrollBarThickness = 8
    Scrolling.CanvasSize = UDim2.new(0,0,0,0)
    Scrolling.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    Scrolling.Parent = Main
    Scrolling.AutomaticCanvasSize = Enum.AutomaticSize.XY

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    UIListLayout.Parent = Scrolling

    local paused = false

    -- Função para adicionar linha de log
    local function addLine(log)
        if paused then return end
        local line = Instance.new("TextLabel")
        line.BackgroundTransparency = 1
        line.Size = UDim2.new(0, 1, 0, 20) -- ajuste para CanvasSize dinâmico
        line.TextXAlignment = Enum.TextXAlignment.Left
        line.Font = Enum.Font.Code
        line.TextSize = 14
        line.TextColor3 = Color3.new(1,1,1)
        line.Text = string.format("[%s] %s: %s", log.time, log.author, log.message)
        line.TextWrapped = false
        line.TextTruncate = Enum.TextTruncate.None
        line.TextScaled = false
        line.Parent = Scrolling
        line.Size = UDim2.new(0, math.max(Scrolling.AbsoluteSize.X, #line.Text*8), 0, 20)
        Scrolling.CanvasSize = UDim2.new(0, math.max(Scrolling.AbsoluteSize.X, #line.Text*8), 0, UIListLayout.AbsoluteContentSize.Y)
    end

    -- Atualiza linhas ao digitar na pesquisa
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _,v in ipairs(Scrolling:GetChildren()) do
            if v:IsA("TextLabel") then
                local show = v.Text:lower():find(query)
                v.Visible = show and true or false
            end
        end
    end)

    -- Adiciona logs já armazenados
    for _,log in ipairs(storedTable) do addLine(log) end

    Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
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
    local channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
    channel.MessageReceived:Connect(function(msg)
        local author = msg.TextSource and msg.TextSource.Name or "Sistema"
        local message = msg.Text
        local time = os.date("%H:%M:%S")
        local entry = {time = time, author = author, message = message}
        table.insert(chatStoredLogs, entry)
        if startsWithPrefix(message) then table.insert(cmdStoredLogs, entry) end
    end)
end

RegisterCommand("chatlogs", function() createLogsGui("ChatLogs", chatStoredLogs) end)
RegisterCommand("unchatlogs", function()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("ChatLogs")
    if gui then gui:Destroy() end
end)
RegisterCommand("logs", function() createLogsGui("Logs", cmdStoredLogs) end)
RegisterCommand("unlogs", function()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("Logs")
    if gui then gui:Destroy() end
end)

-- ===== Outgoing -> Commands exec & Incoming -> Hide local display =====
TextChatService.OnIncomingMessage = function(message)
    local props = Instance.new("TextChatMessageProperties")
    local src = message.TextSource
    local sender = src and Players:GetPlayerByUserId(src.UserId)
    local content = message.Text

    if sender and content then
        task.spawn(ProcessMessage, sender, content)
        if HideChatCommands and sender == LocalPlayer and content:sub(1, #Prefix) == Prefix then
            props.Text = ""
            props.PrefixText = ""
            props.TextTransparency = 1
            props.PrefixTextTransparency = 1
            return props
        end
    end
end

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
    icon.Size = UDim2.new(0, 96, 0, 96) -- diminuí o tamanho de 128x128 para 96x96
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://965496596"
    icon.AutoButtonColor = true
    icon.Parent = gui
    
    -- Deixar redondo
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0) -- 100% arredondado (círculo)
    corner.Parent = icon
    

    local win = Instance.new("Frame")
    win.Name = "Window"
    win.Size = UDim2.new(0, 560, 0, 360)
    win.Position = UDim2.new(0.5, -280, 0.5, -180)
    win.BackgroundColor3 = Color3.fromRGB(25,25,25)
    win.BorderSizePixel = 0
    win.Visible = false
    win.Active = true
    win.Draggable = true
    win.Parent = gui

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -36, 0, 32)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(40,40,40)
    header.Text = "🛡️ Admin Panel"
    header.TextColor3 = Color3.new(1,1,1)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 18
    header.Parent = win

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -32, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 16
    closeBtn.Parent = win

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 30)
    tabBar.Position = UDim2.new(0, 0, 0, 32)
    tabBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
    tabBar.Parent = win

    local function makeTabButton(txt, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 110, 1, 0)
        b.Position = UDim2.new(0, x, 0, 0)
        b.BackgroundColor3 = Color3.fromRGB(55,55,55)
        b.Text = txt
        b.TextColor3 = Color3.new(1,1,1)
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
        p.BackgroundColor3 = Color3.fromRGB(20,20,20)
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

    tabCmds.MouseButton1Click:Connect(function() showPage(pageCmds) end)
    tabAliases.MouseButton1Click:Connect(function() showPage(pageAliases) end)
    tabConfigs.MouseButton1Click:Connect(function() showPage(pageConfigs) end)

    showPage(pageCmds)

    local function makeScroll(parent)
        local s = Instance.new("ScrollingFrame")
        s.Size = UDim2.new(1, -12, 1, -12)
        s.Position = UDim2.new(0, 6, 0, 6)
        s.BackgroundTransparency = 1
        s.ScrollBarThickness = 6
        s.CanvasSize = UDim2.new(0,0,0,0)
        s.Parent = parent
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = s
        return s, layout
    end

    local cmdsScroll, cmdsLayout = makeScroll(pageCmds)
    local aliasesScroll, aliasesLayout = makeScroll(pageAliases)

    local function addRow(parent, text)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, -6, 0, 22)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Font = Enum.Font.Code
        l.TextSize = 14
        l.TextColor3 = Color3.new(1,1,1)
        l.Text = text
        l.Parent = parent
        parent.CanvasSize = UDim2.new(0,0,0,parent.UIListLayout.AbsoluteContentSize.Y)
    end

    for name,meta in pairs(CommandMeta) do
        local aliasesList = {}
        for a,fn in pairs(Aliases) do
            local f = Commands[name]
            if f and debug.getinfo and debug.getinfo(fn).source == debug.getinfo(function(...) return f(...) end).source then
                table.insert(aliasesList, a)
            end
        end
        local desc = meta.desc or ""
        local usage = meta.usage and (" — "..meta.usage) or ""
        addRow(cmdsScroll, string.format("%s%s  %s", Prefix..name, usage, desc))
    end

    for a,_ in pairs(Aliases) do
        addRow(aliasesScroll, Prefix..a)
    end

    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0, 220, 0, 36)
    hideBtn.Position = UDim2.new(0, 12, 0, 12)
    hideBtn.BackgroundColor3 = Color3.fromRGB(60,60,120)
    hideBtn.TextColor3 = Color3.new(1,1,1)
    hideBtn.Font = Enum.Font.SourceSansBold
    hideBtn.TextSize = 14
    hideBtn.Text = "Hide Chat Commands: "..(HideChatCommands and "ON" or "OFF")
    hideBtn.Parent = pageConfigs

    hideBtn.MouseButton1Click:Connect(function()
        HideChatCommands = not HideChatCommands
        hideBtn.Text = "Hide Chat Commands: "..(HideChatCommands and "ON" or "OFF")
    end)

    local openChatLogs = Instance.new("TextButton")
    openChatLogs.Size = UDim2.new(0, 160, 0, 32)
    openChatLogs.Position = UDim2.new(0, 12, 0, 60)
    openChatLogs.BackgroundColor3 = Color3.fromRGB(70,130,70)
    openChatLogs.TextColor3 = Color3.new(1,1,1)
    openChatLogs.Font = Enum.Font.SourceSansBold
    openChatLogs.TextSize = 14
    openChatLogs.Text = "Open ChatLogs"
    openChatLogs.Parent = pageConfigs
    openChatLogs.MouseButton1Click:Connect(function() createLogsGui("ChatLogs", chatStoredLogs) end)

    local openCmdLogs = Instance.new("TextButton")
    openCmdLogs.Size = UDim2.new(0, 160, 0, 32)
    openCmdLogs.Position = UDim2.new(0, 12, 0, 100)
    openCmdLogs.BackgroundColor3 = Color3.fromRGB(130,70,70)
    openCmdLogs.TextColor3 = Color3.new(1,1,1)
    openCmdLogs.Font = Enum.Font.SourceSansBold
    openCmdLogs.TextSize = 14
    openCmdLogs.Text = "Open Logs"
    openCmdLogs.Parent = pageConfigs
    openCmdLogs.MouseButton1Click:Connect(function() createLogsGui("Logs", cmdStoredLogs) end)

    icon.MouseButton1Click:Connect(function() win.Visible = not win.Visible end)
    closeBtn.MouseButton1Click:Connect(function() win.Visible = false end)

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
RegisterAlias("goto","tp")
RegisterAlias("to","tp")





RegisterCommand("goto", function(target)
    local t = FindPlayerByPartial(target)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(t.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0))
    end
end, {desc="Vai até o player alvo", usage="goto <player>"})
RegisterAlias("to","goto")





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
        if v:IsA("Tool") then v.Parent = LocalPlayer.Backpack end
    end
    for _, g in pairs(game.Teams:GetDescendants()) do
        if g:IsA("Tool") then g.Parent = LocalPlayer.Backpack end
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
    local dist = (hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
        and (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or nil

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

    -- tentar pegar grupos
    pcall(function()
        local groups = t:GetGroups()
        table.insert(info, "Groups: "..#groups.." grupos")
        for i,g in ipairs(groups) do
            if i > 5 then break end -- limitar a 5 grupos
            table.insert(info, string.format(" - %s (%s)", g.Name, g.RankName))
        end
    end)

    -- mostrar
    print(table.concat(info, "\n"))
end, {desc="Inspeciona um jogador (detalhes completos)", usage="profile <player>"})
RegisterAlias("inspect","profile")




RegisterCommand("who", function()
    local names = {}
    for _,p in ipairs(Players:GetPlayers()) do table.insert(names, p.Name) end
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
    if mdl then mdl:Destroy() else seat:Destroy() end
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
RegisterAlias("jumpheight","jumppower")



RegisterCommand("sit", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Sit = true end
end, {desc="Faz seu personagem sentar"})


RegisterCommand("reset", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end, {desc="Reseta seu personagem"})
RegisterAlias("re","reset")
RegisterAlias("respawn","reset")


RegisterCommand("heal", function(target)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = hum.MaxHealth end
end, {desc="Cura seu personagem"})


RegisterCommand("noclip", function()
    local char = LocalPlayer.Character
    if not char then return end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end, {desc="Ativa noclip temporário"})
RegisterAlias("phase","noclip")

RegisterCommand("unnoclip", function()
    local char = LocalPlayer.Character
    if not char then return end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = true end
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
    for a,_ in pairs(Aliases) do print(Prefix..a) end
end, {desc="Lista aliases"})
RegisterAlias("alias","aliases")



RegisterCommand("prefix", function(arg)
    Prefix = arg
end, {desc="Prefixo utilizado nos comandos", usage="prefix <prefix>"})



-------------------------------------------------------------------------------
--- WORKING HARD ON THIS SHI. Dont steal it, if you wanna use it, just ask me.
-------------------------------------------------------------------------------

-- Prod By GomesDev

-- ===== Ativar admin automaticamente =====
local function EnableAdmin()
    if not (LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")) then
        openOrCreateAdminPanel()
    else
        LocalPlayer.PlayerGui.AdminPanel.Enabled = true
    end
end

-- Chama a ativação assim que o script rodar
EnableAdmin()
