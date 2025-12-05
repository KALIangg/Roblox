-- 🔥 Carrega a Criminality Paste UI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox-UI-Libs/refs/heads/main/Criminality%20Lib/Criminality%20Lib%20Source.lua"))()






-- ============================================================
-- 🌐 AUTO-LOADER TIPO INFINITE YIELD (LUA GOD VERSION) 😎🔥
-- ============================================================

if not _G.PozeExecutorLoaded then
    _G.PozeExecutorLoaded = true

    local function loadExecutor()
        print("🔥 [Poze Executor] Carregando...")

        -- URL DO SEU ARQUIVO PRINCIPAL (pode ser o próprio script)
        local source = game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox/refs/heads/main/poze_executor.lua")
        local ok, err = pcall(loadstring(source))

        if not ok then
            warn("🚨 Erro ao carregar Executor:", err)
        else
            print("🧠 Poze Executor carregado com sucesso!")
        end
    end

    task.spawn(loadExecutor)

    -- ============================================================
    -- 📌 SISTEMA DE AUTO-RELOAD
    -- ============================================================

    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")

    -- 1️⃣ Quando o jogador for teleportado (antes de sair)
    TeleportService.TeleportInitFailed:Connect(function()
        task.wait(1)
        loadExecutor()
    end)

    -- 2️⃣ Quando chegar no novo servidor
    Players.LocalPlayer.OnTeleport:Connect(function(State)
        if State == Enum.TeleportState.Started then
            print("✈️ Entrando em outro servidor, recarregando executor...")
            _G.PozeExecutorLoaded = false
        end
    end)

    -- 4️⃣ Caso o executor seja reinjetado manualmente
    if shared.PozeReloadFlag then
        shared.PozeReloadFlag = false
        loadExecutor()
    end

else
    print("⚠️ [Poze Executor] Já carregado, ignorando duplicata...")
end







-- 🪟 Cria a janela
local window = library.new("Blade Executor 💻", "leadmarker 🔥")

-- =================================================================
--                             CUSTOM TEXTBOX
-- =================================================================

local function CreateTextEditor(titleText)
    local gui = Instance.new("ScreenGui")
    gui.Name = "PozeEditor"
    gui.Parent = game.CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 350)
    frame.Position = UDim2.new(0.5, -250, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 1, -50)
    box.Position = UDim2.new(0, 10, 0, 40)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 14
    box.Font = Enum.Font.Code
    box.ClearTextOnFocus = false
    box.MultiLine = true
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.TextWrapped = false
    box.Text = "-- Digite seu código aqui"
    box.Parent = frame

    return gui, box
end

-- Criar editor principal
local codeEditorGui, codeEditorBox = CreateTextEditor("SCRIPTING AREA")
codeEditorGui.Enabled = true

local argumentsGui = nil
local argumentsBox = nil

-- =================================================================
--                               ABAS
-- =================================================================

local executorTab = window.new_tab("rbxassetid://16481845020")
local menusTab    = window.new_tab("rbxassetid://2600491131")
local triggersTab = window.new_tab("rbxassetid://16717281575")
local configTab   = window.new_tab("rbxassetid://6953992690")

-- =================================================================
--                               EXECUTOR
-- =================================================================

local execSection = executorTab.new_section("Executor")
local execSector  = execSection.new_sector("Script Executor", "Left")

execSector.element("Button", "Abrir Editor", nil, function()
    codeEditorGui.Enabled = not codeEditorGui.Enabled
end)

execSector.element("Button", "Executar Script", nil, function()
    local code = codeEditorBox.Text
    if code == "" then
        warn("Nenhum código no editor!")
        return
    end

    local ok, err = pcall(loadstring(code))
    if ok then
        print("Executado com sucesso!")
    else
        warn("Erro:", err)
    end
end)

-- =================================================================
--                               MENUS FREE
-- =================================================================

local menuSection = menusTab.new_section("Menus")
local menuSector  = menuSection.new_sector("Mod Menus", "Left")

menuSector.element("Button", "Poze Menu", nil, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox/refs/heads/main/pozemenu.lua"))()
end)

menuSector.element("Button", "Sun Menu", nil, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox/refs/heads/main/sunpiece.lua"))()
end)

-- =================================================================
--                               TRIGGERS
-- =================================================================

local trigSection = triggersTab.new_section("Misc")
local trigSector  = trigSection.new_sector("Funções Extras", "Left")

-- REJOIN
trigSector.element("Button", "Rejoin Server", nil, function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

-- Coletar Remotes
local remoteList = {}
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        table.insert(remoteList, obj:GetFullName())
    end
end

local selectedRemote = nil

trigSector.element("Dropdown", "Selecionar Remote", {options = remoteList}, function(v)
    selectedRemote = game:GetService("Workspace"):FindFirstChild(v.Dropdown, true)
        or game:GetService("ReplicatedStorage"):FindFirstChild(v.Dropdown, true)
        or game:FindFirstChild(v.Dropdown, true)
    print("Remote selecionado:", v.Dropdown)
end)

-- Criar Argument Editor
trigSector.element("Toggle", "Usar Argumentos", false, function(v)
    if v.Toggle then
        if not argumentsGui then
            argumentsGui, argumentsBox = CreateTextEditor("ARGUMENTOS (TABELA LUA)")
        end
        argumentsGui.Enabled = true
    else
        if argumentsGui then
            argumentsGui.Enabled = false
        end
    end
end)

-- Ativar remoto
trigSector.element("Button", "Ativar Remote", nil, function()
    if not selectedRemote then
        warn("Nenhum remote selecionado!")
        return
    end

    local args = {}

    if argumentsGui and argumentsGui.Enabled then
        local txt = argumentsBox.Text
        local ok, parsed = pcall(function() return loadstring("return " .. txt)() end)
        if ok then
            args = parsed
        end
    end

    if type(args) == "table" then
        selectedRemote:FireServer(unpack(args))
    else
        selectedRemote:FireServer()
    end

    print("Remote enviado!")
end)

-- =================================================================
--                               CONFIG
-- =================================================================

local cfgSection = configTab.new_section("Configurações")
local cfgSector  = cfgSection.new_sector("Geral", "Left")

cfgSector.element("Slider", "Volume", {default = {min = 0, max = 100, default = 50}}, function(v)
    game:GetService("SoundService").Volume = v.Slider / 100
end)

cfgSector.element("Dropdown", "FPS Cap", {options = {"30", "60", "120", "144", "240"}}, function(v)
    setfpscap(tonumber(v.Dropdown))
end)

cfgSector.element("Toggle", "Anti-AFK", false, function(v)
    if v.Toggle then
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
            wait(1)
            game:GetService("VirtualUser"):Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
        end)
        print("Anti-AFK ativado")
    else
        print("Anti-AFK desativado")
    end
end)

-- =================================================================
print("🔥 Poze Executor injetado com sucesso!")
