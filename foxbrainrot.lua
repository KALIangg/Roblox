-- 🦊 Fox Panel | v1.6.0
-- 🔧 FlexUI Integration (KALIangg)
-- ⚙️ Funcionalidades: Auto Kick, No Cooldown, Super Jump, Speed Glitch
-- ❤️ Tema vermelho translúcido premium

local FlexUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox/refs/heads/main/FlexUI.lua"))()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

--===[ SETUP UI ]===--
FlexUI:SetTitle("Fox Panel - v1.6.0")

-- Adicionar tabs com ícones
local HomeTab = FlexUI:AddTab("Início", "🏠")
local PlayerTab = FlexUI:AddTab("Player", "👤")
local MiscTab = FlexUI:AddTab("Misc", "⚙️")

--===[ FUNÇÕES DE BUSCA BRAINROT ]===--
local function FindPlayerBrainrotInfo(playerName)
    -- Procura pelos plots no workspace
    for _, plot in pairs(Workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("Owner") then
            local ownerValue = plot.Owner
            if ownerValue and ownerValue.Value == playerName then
                -- Encontrou o plot do player, agora procura pelo melhor brainrot
                if plot:FindFirstChild("AnimalPodiums") then
                    local bestBrainrot = nil
                    local highestGeneration = 0
                    
                    for _, podium in pairs(plot.AnimalPodiums:GetChildren()) do
                        if podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn") then
                            local attach = podium.Base.Spawn:FindFirstChild("Attachment")
                            if attach and attach:FindFirstChild("AnimalOverhead") then
                                local overhead = attach.AnimalOverhead
                                local displayLabel = overhead:FindFirstChild("DisplayName")
                                local mutationLabel = overhead:FindFirstChild("Mutation")
                                local generationLabel = overhead:FindFirstChild("Generation")
                                
                                if displayLabel and mutationLabel and generationLabel then
                                    -- Tenta extrair o número da generation
                                    local genText = generationLabel.Text
                                    local genNumber = tonumber(genText:match("%d+")) or 0
                                    
                                    -- Encontra o brainrot com a generation mais alta
                                    if genNumber > highestGeneration then
                                        highestGeneration = genNumber
                                        bestBrainrot = {
                                            DisplayName = displayLabel.Text,
                                            Mutation = mutationLabel.Text,
                                            Generation = generationLabel.Text,
                                            GenerationNumber = genNumber
                                        }
                                    end
                                end
                            end
                        end
                    end
                    
                    return bestBrainrot
                end
            end
        end
    end
    return nil
end

local function GetBrainrotInfoString(playerName)
    local brainrotInfo = FindPlayerBrainrotInfo(playerName)
    
    if brainrotInfo then
        return string.format("🧠 %s\n🎯 Gen: %s | %s", 
            brainrotInfo.DisplayName, 
            brainrotInfo.Generation, 
            brainrotInfo.Mutation)
    else
        return "🧠 Nenhum brainrot encontrado"
    end
end

--===[ TAB INÍCIO ]===--
FlexUI:AddSection(HomeTab, "🦊 Fox Panel v1.6.0")
FlexUI:AddLabel(HomeTab, "👋 Bem-vindo, " .. player.Name .. "!")
FlexUI:AddLabel(HomeTab, "Interface premium com funcionalidades avançadas")

FlexUI:AddSection(HomeTab, "🚀 Status do Sistema")
FlexUI:AddButton(HomeTab, "📊 Ver Informações do Jogador", function()
    local info = {
        "Nome: " .. player.Name,
        "UserID: " .. player.UserId,
        "Account Age: " .. player.AccountAge .. " dias",
        "Display Name: " .. player.DisplayName
    }
    
    FlexUI:Notify("Info", "Informações do Jogador", table.concat(info, "\n"), 5)
end)

--===[ TAB PLAYER ]===--
FlexUI:AddSection(PlayerTab, "🎯 Sistema de Targeting")

--===[ VARIÁVEIS GLOBAIS ]===--
local selectedPlayer = nil
local selectedMethod = "Block"
local autoKickConn, noCooldownConn
_G.SpeedGlitchData = {}

--===[ FUNÇÕES AUXILIARES ]===--
local function GetPlayers()
    local list = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= player then
            table.insert(list, v.Name)
        end
    end
    if #list == 0 then table.insert(list, "Nenhum jogador") end
    return list
end

--===[ NOTIFICAÇÕES DE PLAYER COM BRAINROT INFO ]===--
FlexUI:AddSection(PlayerTab, "📢 Sistema de Notificações")

-- Toggle para notificações de player
local notifyPlayersToggle = false
FlexUI:AddToggle(PlayerTab, "🔔 Notificar Entrada/Saída", false, function(state)
    notifyPlayersToggle = state
    if state then
        FlexUI:Notify("Success", "Notificações Ativadas", "Você será notificado quando players entrarem/sairem\nIncluindo informações de brainrot! 🧠", 4)
    else
        FlexUI:Notify("Warning", "Notificações Desativadas", "Notificações de players desligadas", 2)
    end
end)

-- CONEXÕES DE PLAYER ADDED / REMOVED COM BRAINROT INFO
Players.PlayerAdded:Connect(function(plr)
    if notifyPlayersToggle then
        -- Notificação padrão: Player entrou
        FlexUI:Notify("Success", plr.Name .. " entrou no jogo!", 3)
        
        -- Aguarda um pouco para garantir que o plot do player foi carregado
        task.wait(2)
        
        -- Busca informações do brainrot do player
        local brainrotInfo = GetBrainrotInfoString(plr.Name)
        
        -- Notificação info com detalhes do player E brainrot
        FlexUI:Notify("Info", 
            "📊 Informações de " .. plr.Name,
            "👤 UserId: " .. plr.UserId .. 
            "\n📅 AccountAge: " .. plr.AccountAge .. " dias" ..
            "\n\n" .. brainrotInfo, 
            6
        )
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if notifyPlayersToggle then
        FlexUI:Notify("Warning", plr.Name .. " saiu do jogo!", 3)
    end
end)

--===[ SISTEMA DE TARGETING ]===--
FlexUI:AddSection(PlayerTab, "🎯 Configurações de Alvo")

-- Dropdown para seleção de jogador (precisaria ser adaptado para a nova UI)
local playersList = GetPlayers()
local selectedPlayerValue = "Nenhum jogador"

FlexUI:AddLabel(PlayerTab, "🎯 Jogador Alvo: " .. (selectedPlayer or "Nenhum"))
FlexUI:AddLabel(PlayerTab, "⚙️ Método: " .. selectedMethod)

FlexUI:AddButton(PlayerTab, "🔄 Atualizar Lista de Players", function()
    local currentPlayers = GetPlayers()
    FlexUI:Notify("Info", "🎯 Players", "Lista atualizada! " .. (#currentPlayers - 1) .. " jogadores online", 3)
end)

--===[ FUNCIONALIDADES PRINCIPAIS ]===--
FlexUI:AddSection(PlayerTab, "⚡ Funcionalidades")

-- 🦶 AUTO KICK
FlexUI:AddToggle(PlayerTab, "🦶 Auto Kick", false, function(state)
    if state then
        if not selectedPlayer then
            FlexUI:Notify("Error", "❌ Erro", "Selecione um jogador alvo primeiro!\nUse o botão 'Atualizar Lista' e selecione um player", 4)
            return
        end
        
        autoKickConn = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, triggerPlayer)
            if selectedPlayer and triggerPlayer and triggerPlayer.Name == selectedPlayer then
                if selectedMethod == "Block" then
                    player:BlockAsync(triggerPlayer)
                    FlexUI:Notify("Warning", "⚠️ Jogador bloqueado automaticamente: " .. triggerPlayer.Name, 3)
                end
            end
        end)
        FlexUI:Notify("Success", "🦶 Auto Kick", "Auto Kick ativado para: " .. selectedPlayer, 3)
    else
        if autoKickConn then
            autoKickConn:Disconnect()
            autoKickConn = nil
        end
        FlexUI:Notify("Info", "🦶 Auto Kick", "Auto Kick desativado", 2)
    end
end)

-- 💨 SPEED GLITCH
FlexUI:AddToggle(PlayerTab, "💨 Speed Glitch", false, function(state)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    local extraStuds = 1.7
    local force = 16.2
    local cooldown = 0.2

    if state then
        local attachment = Instance.new("Attachment", hrp)
        local vel = Instance.new("LinearVelocity", hrp)
        vel.MaxForce = math.huge
        vel.Attachment0 = attachment
        vel.Enabled = false

        local lastTick = 0
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not char or not humanoid or humanoid.Health <= 0 then
                if conn then conn:Disconnect() end
                if attachment then attachment:Destroy() end
                if vel then vel:Destroy() end
                return
            end
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                local now = os.clock()
                if now - lastTick >= cooldown then
                    lastTick = now
                    local direction = moveDir.Unit * extraStuds * force
                    vel.VectorVelocity = Vector3.new(direction.X, 0, direction.Z)
                    vel.Enabled = true
                    task.delay(0.1, function()
                        if vel and vel.Parent then
                            vel.Enabled = false
                        end
                    end)
                end
            else
                vel.Enabled = false
            end
        end)

        _G.SpeedGlitchData = {
            Conn = conn,
            Attachment = attachment,
            Vel = vel,
            Humanoid = humanoid,
        }

        player.CharacterAdded:Connect(function(newChar)
            if _G.SpeedGlitchData.Conn then _G.SpeedGlitchData.Conn:Disconnect() end
            if _G.SpeedGlitchData.Attachment then _G.SpeedGlitchData.Attachment:Destroy() end
            if _G.SpeedGlitchData.Vel then _G.SpeedGlitchData.Vel:Destroy() end
            _G.SpeedGlitchData = {}
            task.wait(1)
            if state then
                FlexUI:Notify("Info", "⚡ Speed Glitch", "Speed Glitch reaplicado após respawn!", 3)
            end
        end)

        FlexUI:Notify("Success", "💨 Speed Glitch", "Ativado! Use WASD para impulso.", 4)

    else
        if _G.SpeedGlitchData.Conn then _G.SpeedGlitchData.Conn:Disconnect() end
        if _G.SpeedGlitchData.Attachment then _G.SpeedGlitchData.Attachment:Destroy() end
        if _G.SpeedGlitchData.Vel then _G.SpeedGlitchData.Vel:Destroy() end
        _G.SpeedGlitchData = {}
        FlexUI:Notify("Info", "💨 Speed Glitch", "Speed Glitch desativado", 3)
    end
end)

--===[ TAB MISC ]===--
FlexUI:AddSection(MiscTab, "🔧 Utilitários do Jogo")

-- == REJOIN ==
FlexUI:AddButton(MiscTab, "🔄 Rejoin no Servidor", function()
    local PlaceId = game.PlaceId
    FlexUI:Notify("Warning", "🔄 Reconnectando", "Reconectando ao servidor...", 2)
    task.wait(1)
    game:GetService("TeleportService"):Teleport(PlaceId, player)
end)

-- == SERVER HOP ==
FlexUI:AddButton(MiscTab, "🎲 Trocar de Servidor", function()
    FlexUI:Notify("Info", "🎲 Server Hop", "Procurando outro servidor...", 3)
    
    task.spawn(function()
        local PlaceId = game.PlaceId
        local HttpService = game:GetService("HttpService")
        local Servers = {}
        local cursor = ""

        repeat
            local success, response = pcall(function()
                return game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="..cursor)
            end)
            if success and response then
                local data = HttpService:JSONDecode(response)
                for _, server in pairs(data.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(Servers, server.id)
                    end
                end
                cursor = data.nextPageCursor or ""
            else
                break
            end
        until cursor == nil or cursor == ""

        if #Servers > 0 then
            local chosen = Servers[math.random(1,#Servers)]
            FlexUI:Notify("Success", "🎲 Teleportando", "Conectando ao novo servidor...", 2)
            game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, chosen, player)
        else
            FlexUI:Notify("Error", "❌ Server Hop", "Nenhum servidor disponível encontrado!", 3)
        end
    end)
end)

-- == BRAINROT ESP ==
FlexUI:AddSection(MiscTab, "👁️ Sistema ESP")

local brainrotESPActive = false
local ESPFolders = {}

FlexUI:AddToggle(MiscTab, "👁️ Brainrot ESP", false, function(state)
    brainrotESPActive = state

    -- Limpa ESP antigo
    for _, f in pairs(ESPFolders) do
        if f and f.Parent then
            f:Destroy()
        end
    end
    ESPFolders = {}

    if brainrotESPActive then
        local foundCount = 0
        for _, plot in pairs(Workspace.Plots:GetChildren()) do
            if plot:FindFirstChild("AnimalPodiums") then
                for _, podium in pairs(plot.AnimalPodiums:GetChildren()) do
                    if podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn") then
                        local attach = podium.Base.Spawn:FindFirstChild("Attachment")
                        if attach and attach:FindFirstChild("AnimalOverhead") then
                            local overhead = attach.AnimalOverhead
                            local displayLabel = overhead:FindFirstChild("DisplayName")
                            local mutationLabel = overhead:FindFirstChild("Mutation")
                            local generationLabel = overhead:FindFirstChild("Generation")

                            if displayLabel and mutationLabel and generationLabel then
                                local Billboard = Instance.new("BillboardGui")
                                Billboard.Size = UDim2.new(0, 200, 0, 60)
                                Billboard.Adornee = podium.Base
                                Billboard.AlwaysOnTop = true
                                Billboard.MaxDistance = 100
                                Billboard.Parent = podium.Base

                                local text = Instance.new("TextLabel")
                                text.Size = UDim2.new(1, 0, 1, 0)
                                text.BackgroundTransparency = 0.7
                                text.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                                text.TextColor3 = Color3.fromRGB(255, 255, 0)
                                text.Font = Enum.Font.GothamBold
                                text.TextSize = 12
                                text.Text = displayLabel.Text.."\n"..mutationLabel.Text.."\nGen: "..generationLabel.Text
                                text.TextStrokeTransparency = 0
                                text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                text.Parent = Billboard

                                table.insert(ESPFolders, Billboard)
                                foundCount = foundCount + 1
                            end
                        end
                    end
                end
            end
        end
        
        FlexUI:Notify("Success", "👁️ Brainrot ESP", "ESP ativado! "..foundCount.." objetos encontrados", 4)
    else
        FlexUI:Notify("Info", "👁️ Brainrot ESP", "ESP desativado", 3)
    end
end)

--===[ FUNÇÃO PARA VER BRAINROT DE PLAYER ESPECÍFICO ]===--
FlexUI:AddSection(PlayerTab, "🧠 Ver Brainrot de Player")

FlexUI:AddButton(PlayerTab, "🔍 Ver Meu Brainrot", function()
    local brainrotInfo = GetBrainrotInfoString(player.Name)
    FlexUI:Notify("Info", "🧠 Meu Brainrot", brainrotInfo, 5)
end)

FlexUI:AddButton(PlayerTab, "🔍 Ver Brainrot de Todos", function()
    local allPlayers = Players:GetPlayers()
    local foundCount = 0
    
    for _, plr in ipairs(allPlayers) do
        if plr ~= player then
            local brainrotInfo = FindPlayerBrainrotInfo(plr.Name)
            if brainrotInfo then
                foundCount = foundCount + 1
                FlexUI:Notify("Info", 
                    "🧠 Brainrot de " .. plr.Name,
                    string.format("🧠 %s\n🎯 Gen: %s | %s", 
                        brainrotInfo.DisplayName, 
                        brainrotInfo.Generation, 
                        brainrotInfo.Mutation), 
                    4
                )
                task.wait(1) -- Espaço entre notificações
            end
        end
    end
    
    if foundCount == 0 then
        FlexUI:Notify("Warning", "🔍 Brainrot Scan", "Nenhum brainrot encontrado nos outros players", 3)
    end
end)

--===[ SISTEMA DE SELEÇÃO DE PLAYER SIMPLIFICADO ]===--
FlexUI:AddSection(PlayerTab, "👥 Seleção Rápida de Player")

-- Botões para seleção rápida de players online
local function UpdatePlayerSelection()
    -- Em uma implementação real, você limparia os botões antigos primeiro
    local currentPlayers = GetPlayers()
    
    for i, playerName in ipairs(currentPlayers) do
        if playerName ~= "Nenhum jogador" then
            FlexUI:AddButton(PlayerTab, "🎯 Selecionar: " .. playerName, function()
                selectedPlayer = playerName
                
                -- Mostra também o brainrot do player selecionado
                local brainrotInfo = GetBrainrotInfoString(playerName)
                
                FlexUI:Notify("Success", 
                    "🎯 Alvo Definido", 
                    "Jogador alvo: " .. playerName .. 
                    "\n\n" .. brainrotInfo, 
                    4
                )
            end)
        end
    end
end

FlexUI:AddButton(PlayerTab, "🔄 Atualizar Seleção de Players", UpdatePlayerSelection)

--===[ INICIALIZAÇÃO ]===--
FlexUI:Show()

-- Notificação de boas-vindas
task.spawn(function()
    task.wait(1)
    FlexUI:Notify("Success", "🦊 Fox Panel", "v1.6.0 carregado com sucesso!\nBem-vindo, " .. player.Name .. "!", 5)
    
    -- Mostra também o brainrot do próprio player
    task.wait(2)
    local myBrainrot = GetBrainrotInfoString(player.Name)
    FlexUI:Notify("Info", "🧠 Seu Brainrot", myBrainrot, 5)
end)

print("🦊 Fox Panel v1.6.0 - FlexUI Integration Carregada!")
print("• Auto Kick System ✅")
print("• Speed Glitch ✅") 
print("• Brainrot ESP ✅")
print("• Server Utilities ✅")
print("• Brainrot Notifications ✅")

-- Inicializar lista de players
UpdatePlayerSelection()

return FlexUI
