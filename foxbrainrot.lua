-- 🦊 Fox Panel | v2.0.0
-- 🔧 FlexUI Integration (KALIangg) - Versão Corrigida
-- ⚙️ Funcionalidades: Auto Kick, No Cooldown, Super Jump, Speed Glitch
-- ❤️ Tema vermelho translúcido premium

local FlexUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox/refs/heads/main/FlexUI.lua"))()

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

--===[ CONFIGURAÇÃO DE TEMA PERSONALIZADO ]===--
local CUSTOM_THEME = {
    Primary = Color3.fromRGB(220, 60, 60),    -- Vermelho mais vibrante
    Secondary = Color3.fromRGB(30, 25, 35),   -- Fundo escuro com tom roxo
    Background = Color3.fromRGB(20, 15, 25),  -- Fundo mais escuro
    Card = Color3.fromRGB(40, 35, 50),        -- Cards com tom roxo
    Text = Color3.fromRGB(255, 255, 255),     -- Texto branco puro
    Highlight = Color3.fromRGB(255, 100, 100),-- Destaque mais suave
    Success = Color3.fromRGB(80, 200, 80),    -- Verde sucesso
    Error = Color3.fromRGB(220, 80, 80),      -- Vermelho erro
    Warning = Color3.fromRGB(255, 200, 80),   -- Amarelo alerta
    Info = Color3.fromRGB(80, 170, 255)       -- Azul informação
}

--===[ SETUP UI PREMIUM ]===--
FlexUI:SetTitle("🦊 Fox Panel Premium v2.0.0")

-- Adicionar tabs com ícones modernos
local HomeTab = FlexUI:AddTab("Início", "🏠")
local PlayerTab = FlexUI:AddTab("Player", "🎯")
local BrainrotTab = FlexUI:AddTab("Brainrot", "🧠")
local MiscTab = FlexUI:AddTab("Utilitários", "⚡")

--===[ SISTEMA DE CONFIGURAÇÃO ]===--
local Config = {
    AutoKick = {
        Enabled = false,
        Target = nil,
        Method = "Block"
    },
    SpeedGlitch = {
        Enabled = false,
        Force = 16.2,
        Cooldown = 0.2
    },
    Notifications = {
        PlayerJoinLeave = true,
        BrainrotInfo = true
    },
    ESP = {
        Enabled = false,
        Range = 100
    }
}

--===[ FUNÇÕES DE BUSCA BRAINROT OTIMIZADAS ]===--
local BrainrotCache = {}
local function FindPlayerBrainrotInfo(playerName)
    -- Verificar cache primeiro
    if BrainrotCache[playerName] then
        return BrainrotCache[playerName]
    end

    local startTime = os.clock()
    
    for _, plot in pairs(Workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("Owner") and plot.Owner.Value == playerName then
            if plot:FindFirstChild("AnimalPodiums") then
                local bestBrainrot = nil
                local highestGeneration = 0
                
                for _, podium in pairs(plot.AnimalPodiums:GetChildren()) do
                    local base = podium:FindFirstChild("Base")
                    if base then
                        local spawn = base:FindFirstChild("Spawn")
                        if spawn then
                            local attach = spawn:FindFirstChild("Attachment")
                            if attach then
                                local overhead = attach:FindFirstChild("AnimalOverhead")
                                if overhead then
                                    local displayLabel = overhead:FindFirstChild("DisplayName")
                                    local mutationLabel = overhead:FindFirstChild("Mutation")
                                    local generationLabel = overhead:FindFirstChild("Generation")
                                    
                                    if displayLabel and mutationLabel and generationLabel then
                                        local genText = generationLabel.Text
                                        local genNumber = tonumber(genText:match("%d+")) or 0
                                        
                                        if genNumber > highestGeneration then
                                            highestGeneration = genNumber
                                            bestBrainrot = {
                                                DisplayName = displayLabel.Text,
                                                Mutation = mutationLabel.Text,
                                                Generation = generationLabel.Text,
                                                GenerationNumber = genNumber,
                                                Plot = plot.Name
                                            }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Cache do resultado
                if bestBrainrot then
                    BrainrotCache[playerName] = bestBrainrot
                end
                
                return bestBrainrot
            end
        end
    end
    return nil
end

local function GetBrainrotInfoString(playerName)
    local brainrotInfo = FindPlayerBrainrotInfo(playerName)
    
    if brainrotInfo then
        return string.format("🧠 %s\n🎯 Gen: %s | %s\n📌 Plot: %s", 
            brainrotInfo.DisplayName, 
            brainrotInfo.Generation, 
            brainrotInfo.Mutation,
            brainrotInfo.Plot)
    else
        return "🧠 Nenhum brainrot encontrado"
    end
end

--===[ SISTEMA DE NOTIFICAÇÕES AVANÇADO ]===--
local function SendEnhancedNotification(title, message, duration, notificationType)
    local emoji = ""
    local color = CUSTOM_THEME.Info
    
    if notificationType == "success" then
        emoji = "✅"
        color = CUSTOM_THEME.Success
    elseif notificationType == "error" then
        emoji = "❌"
        color = CUSTOM_THEME.Error
    elseif notificationType == "warning" then
        emoji = "⚠️"
        color = CUSTOM_THEME.Warning
    else
        emoji = "ℹ️"
        color = CUSTOM_THEME.Info
    end
    
    FlexUI:Notify(notificationType:upper(), emoji .. " " .. title, message, duration or 4)
end

--===[ TAB INÍCIO PREMIUM ]===--
FlexUI:AddSection(HomeTab, "🌟 Fox Panel Premium v2.0.0")

-- Status do player com design melhorado
local playerInfoSection = FlexUI:AddSection(HomeTab, "👤 Suas Informações")
FlexUI:AddLabel(HomeTab, "🎮 Nome: " .. player.DisplayName)
FlexUI:AddLabel(HomeTab, "🆔 UserID: " .. player.UserId)
FlexUI:AddLabel(HomeTab, "📅 Idade da Conta: " .. player.AccountAge .. " dias")

-- Sistema de status em tempo real
local statusSection = FlexUI:AddSection(HomeTab, "📊 Status do Sistema")

local function UpdateSystemStatus()
    local playerCount = #Players:GetPlayers()
    local brainrotCount = 0
    
    -- Contar brainrots encontrados
    for _, plr in pairs(Players:GetPlayers()) do
        if FindPlayerBrainrotInfo(plr.Name) then
            brainrotCount = brainrotCount + 1
        end
    end
    
    return string.format("👥 Players Online: %d\n🧠 Brainrots Ativos: %d\n⚡ Funcionalidades: 4", 
        playerCount, brainrotCount)
end

FlexUI:AddLabel(HomeTab, UpdateSystemStatus())

-- Botão de atualização de status
FlexUI:AddButton(HomeTab, "🔄 Atualizar Status", function()
    FlexUI:AddLabel(HomeTab, UpdateSystemStatus())
    SendEnhancedNotification("Status Atualizado", "Informações do sistema atualizadas com sucesso!", 3, "success")
end)

--===[ TAB PLAYER AVANÇADO ]===--
FlexUI:AddSection(PlayerTab, "🎯 Sistema de Targeting Avançado")

-- Sistema de seleção de player com dropdown
local playersList = {}
local function UpdatePlayersList()
    playersList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(playersList, plr.Name)
        end
    end
    if #playersList == 0 then
        table.insert(playersList, "Nenhum jogador online")
    end
    return playersList
end

-- Dropdown para seleção de player
local selectedPlayer = nil
FlexUI:AddDropdown(PlayerTab, "Selecionar Jogador Alvo", UpdatePlayersList(), "Nenhum", function(selected)
    if selected ~= "Nenhum jogador online" and selected ~= "Nenhum" then
        selectedPlayer = selected
        Config.AutoKick.Target = selected
        
        -- Mostrar informações do player selecionado
        local targetPlayer = Players:FindFirstChild(selected)
        if targetPlayer then
            local brainrotInfo = GetBrainrotInfoString(selected)
            SendEnhancedNotification("🎯 Alvo Definido", 
                string.format("Jogador: %s\nUserID: %s\n%s", 
                    selected, 
                    targetPlayer.UserId, 
                    brainrotInfo), 
                5, "success")
        end
    else
        selectedPlayer = nil
        Config.AutoKick.Target = nil
    end
end)

-- Botão para atualizar lista
FlexUI:AddButton(PlayerTab, "🔄 Atualizar Lista de Players", function()
    local currentPlayers = UpdatePlayersList()
    SendEnhancedNotification("Lista Atualizada", 
        string.format("%d jogadores online", #currentPlayers - 1), 3, "info")
end)

--===[ FUNCIONALIDADES PRINCIPAIS ATUALIZADAS ]===--
FlexUI:AddSection(PlayerTab, "⚡ Funcionalidades Premium")

-- 🦶 AUTO KICK MELHORADO
local autoKickConnection = nil
FlexUI:AddToggle(PlayerTab, "🦶 Auto Kick Automático", false, function(state)
    Config.AutoKick.Enabled = state
    
    if state then
        if not selectedPlayer then
            SendEnhancedNotification("Erro de Configuração", 
                "Selecione um jogador alvo primeiro!", 4, "error")
            return
        end
        
        autoKickConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, triggerPlayer)
            if triggerPlayer and triggerPlayer.Name == selectedPlayer then
                player:BlockAsync(triggerPlayer)
                SendEnhancedNotification("Auto Kick Ativado", 
                    string.format("Jogador %s bloqueado automaticamente!", triggerPlayer.Name), 
                    3, "warning")
            end
        end)
        
        SendEnhancedNotification("Auto Kick Ativado", 
            string.format("Monitorando interações com: %s", selectedPlayer), 
            4, "success")
    else
        if autoKickConnection then
            autoKickConnection:Disconnect()
            autoKickConnection = nil
        end
        SendEnhancedNotification("Auto Kick Desativado", 
            "Sistema de auto kick desligado", 3, "info")
    end
end)

-- 💨 SPEED GLITCH OTIMIZADO
local speedGlitchData = {
    Connection = nil,
    Attachment = nil,
    Velocity = nil
}

FlexUI:AddToggle(PlayerTab, "💨 Speed Glitch Premium", false, function(state)
    Config.SpeedGlitch.Enabled = state
    
    local function SetupSpeedGlitch()
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
        local humanoid = char:WaitForChild("Humanoid")
        
        -- Limpar instâncias antigas
        if speedGlitchData.Attachment then speedGlitchData.Attachment:Destroy() end
        if speedGlitchData.Velocity then speedGlitchData.Velocity:Destroy() end
        
        -- Criar novos componentes
        local attachment = Instance.new("Attachment", humanoidRootPart)
        local velocity = Instance.new("LinearVelocity", humanoidRootPart)
        velocity.MaxForce = math.huge
        velocity.Attachment0 = attachment
        velocity.Enabled = false
        
        speedGlitchData.Attachment = attachment
        speedGlitchData.Velocity = velocity
        
        local lastActivation = 0
        
        speedGlitchData.Connection = RunService.Heartbeat:Connect(function()
            if not char or not humanoid or humanoid.Health <= 0 then
                return
            end
            
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                local currentTime = os.clock()
                if currentTime - lastActivation >= Config.SpeedGlitch.Cooldown then
                    lastActivation = currentTime
                    local boost = moveDirection.Unit * 1.7 * Config.SpeedGlitch.Force
                    velocity.VectorVelocity = Vector3.new(boost.X, 0, boost.Z)
                    velocity.Enabled = true
                    
                    task.delay(0.1, function()
                        if velocity and velocity.Parent then
                            velocity.Enabled = false
                        end
                    end)
                end
            else
                velocity.Enabled = false
            end
        end)
    end
    
    if state then
        SetupSpeedGlitch()
        
        -- Reconectar quando o character respawnar
        player.CharacterAdded:Connect(function()
            if Config.SpeedGlitch.Enabled then
                task.wait(1)
                SetupSpeedGlitch()
                SendEnhancedNotification("Speed Glitch", "Sistema reaplicado após respawn!", 3, "info")
            end
        end)
        
        SendEnhancedNotification("Speed Glitch Ativado", 
            "Use WASD para impulso premium!\nForça: " .. Config.SpeedGlitch.Force, 4, "success")
    else
        if speedGlitchData.Connection then
            speedGlitchData.Connection:Disconnect()
            speedGlitchData.Connection = nil
        end
        if speedGlitchData.Attachment then
            speedGlitchData.Attachment:Destroy()
            speedGlitchData.Attachment = nil
        end
        if speedGlitchData.Velocity then
            speedGlitchData.Velocity:Destroy()
            speedGlitchData.Velocity = nil
        end
        
        SendEnhancedNotification("Speed Glitch Desativado", 
            "Movimento normal restaurado", 3, "info")
    end
end)

-- Configuração do Speed Glitch usando o slider CORRETO
FlexUI:AddSlider(PlayerTab, "⚡ Força do Speed Glitch", 10, 25, 16.2, function(value)
    Config.SpeedGlitch.Force = value
    SendEnhancedNotification("Configuração Atualizada", 
        "Força do Speed Glitch: " .. value, 3, "info")
end)

--===[ TAB BRAINROT ESPECIALIZADO ]===--
FlexUI:AddSection(BrainrotTab, "🧠 Sistema de Brainrot Avançado")

-- Scanner de brainrot em tempo real
FlexUI:AddButton(BrainrotTab, "🔍 Scanner Completo de Brainrots", function()
    local foundCount = 0
    local playersScanned = 0
    
    SendEnhancedNotification("Scanner Iniciado", 
        "Procurando brainrots em todos os players...", 3, "info")
    
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        playersScanned = playersScanned + 1
        local brainrotInfo = FindPlayerBrainrotInfo(targetPlayer.Name)
        
        if brainrotInfo then
            foundCount = foundCount + 1
            SendEnhancedNotification("🧠 Brainrot Encontrado", 
                string.format("Player: %s\n%s (Gen %s)\n%s", 
                    targetPlayer.Name,
                    brainrotInfo.DisplayName,
                    brainrotInfo.Generation,
                    brainrotInfo.Mutation), 
                4, "info")
            task.wait(0.5) -- Delay entre notificações
        end
    end
    
    SendEnhancedNotification("Scanner Finalizado", 
        string.format("Resultados: %d/%d players com brainrot", foundCount, playersScanned), 
        5, "success")
end)

-- Ver brainrot próprio
FlexUI:AddButton(BrainrotTab, "👀 Ver Meu Brainrot", function()
    local brainrotInfo = GetBrainrotInfoString(player.Name)
    SendEnhancedNotification("🧠 Seu Brainrot", brainrotInfo, 6, "info")
end)

-- Sistema de ESP para brainrots
local espInstances = {}
FlexUI:AddToggle(BrainrotTab, "👁️ Brainrot ESP Visual", false, function(state)
    Config.ESP.Enabled = state
    
    -- Limpar ESP anterior
    for _, esp in pairs(espInstances) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    espInstances = {}
    
    if state then
        local espCount = 0
        for _, plot in pairs(Workspace.Plots:GetChildren()) do
            if plot:FindFirstChild("AnimalPodiums") then
                for _, podium in pairs(plot.AnimalPodiums:GetChildren()) do
                    local base = podium:FindFirstChild("Base")
                    if base then
                        local spawn = base:FindFirstChild("Spawn")
                        if spawn then
                            local attach = spawn:FindFirstChild("Attachment")
                            if attach then
                                local overhead = attach:FindFirstChild("AnimalOverhead")
                                if overhead then
                                    local displayLabel = overhead:FindFirstChild("DisplayName")
                                    local generationLabel = overhead:FindFirstChild("Generation")
                                    
                                    if displayLabel and generationLabel then
                                        -- Criar ESP
                                        local billboard = Instance.new("BillboardGui")
                                        billboard.Size = UDim2.new(0, 200, 0, 80)
                                        billboard.Adornee = base
                                        billboard.AlwaysOnTop = true
                                        billboard.MaxDistance = Config.ESP.Range
                                        billboard.Parent = base
                                        
                                        local frame = Instance.new("Frame")
                                        frame.Size = UDim2.new(1, 0, 1, 0)
                                        frame.BackgroundTransparency = 0.7
                                        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                                        frame.BorderSizePixel = 0
                                        frame.Parent = billboard
                                        
                                        local label = Instance.new("TextLabel")
                                        label.Size = UDim2.new(1, -10, 1, -10)
                                        label.Position = UDim2.new(0, 5, 0, 5)
                                        label.BackgroundTransparency = 1
                                        label.TextColor3 = Color3.fromRGB(255, 255, 0)
                                        label.Font = Enum.Font.GothamBold
                                        label.TextSize = 12
                                        label.Text = string.format("🧠 %s\n🎯 %s", 
                                            displayLabel.Text, 
                                            generationLabel.Text)
                                        label.TextStrokeTransparency = 0
                                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                        label.Parent = frame
                                        
                                        table.insert(espInstances, billboard)
                                        espCount = espCount + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        SendEnhancedNotification("ESP Ativado", 
            string.format("%d brainrots marcados no mapa", espCount), 4, "success")
    else
        SendEnhancedNotification("ESP Desativado", 
            "Marcadores removidos do mapa", 3, "info")
    end
end)

--===[ TAB UTILITÁRIOS AVANÇADOS ]===--
FlexUI:AddSection(MiscTab, "🚀 Utilitários do Servidor")

-- Sistema de notificações
FlexUI:AddSection(MiscTab, "🔔 Sistema de Notificações")

FlexUI:AddToggle(MiscTab, "👥 Notificar Entrada/Saída", true, function(state)
    Config.Notifications.PlayerJoinLeave = state
    SendEnhancedNotification("Notificações", 
        state and "Notificações de players ativadas" or "Notificações de players desativadas", 
        3, state and "success" or "info")
end)

FlexUI:AddToggle(MiscTab, "🧠 Info de Brainrot Automática", true, function(state)
    Config.Notifications.BrainrotInfo = state
    SendEnhancedNotification("Info Brainrot", 
        state and "Informações de brainrot ativadas" or "Informações de brainrot desativadas", 
        3, state and "success" or "info")
end)

-- Serviços de servidor
FlexUI:AddSection(MiscTab, "🌐 Gerenciamento de Servidor")

FlexUI:AddButton(MiscTab, "🔄 Rejoin Rápido", function()
    SendEnhancedNotification("Reconectando", "Reconectando ao servidor atual...", 2, "warning")
    task.wait(1)
    TeleportService:Teleport(game.PlaceId, player)
end)

FlexUI:AddButton(MiscTab, "🎲 Server Hop Inteligente", function()
    SendEnhancedNotification("Server Hop", "Procurando servidor ideal...", 3, "info")
    
    task.spawn(function()
        local placeId = game.PlaceId
        local servers = {}
        local cursor = ""
        
        repeat
            local success, result = pcall(function()
                return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100&cursor="..cursor)
            end)
            
            if success and result then
                local data = HttpService:JSONDecode(result)
                for _, server in ipairs(data.data) do
                    if server.playing < server.maxPlayers - 2 and server.id ~= game.JobId then
                        table.insert(servers, server.id)
                    end
                end
                cursor = data.nextPageCursor or ""
            else
                break
            end
        until cursor == ""
        
        if #servers > 0 then
            local targetServer = servers[math.random(1, #servers)]
            SendEnhancedNotification("Servidor Encontrado", "Conectando ao novo servidor...", 2, "success")
            TeleportService:TeleportToPlaceInstance(placeId, targetServer, player)
        else
            SendEnhancedNotification("Sem Servidores", "Nenhum servidor adequado encontrado", 3, "error")
        end
    end)
end)

--===[ SISTEMA DE EVENTOS ]===--
-- Notificações de players entrando/saindo
Players.PlayerAdded:Connect(function(newPlayer)
    if Config.Notifications.PlayerJoinLeave then
        SendEnhancedNotification("👤 Player Entrou", newPlayer.Name .. " entrou no jogo!", 3, "info")
        
        if Config.Notifications.BrainrotInfo then
            task.wait(3) -- Aguardar carregamento
            local brainrotInfo = GetBrainrotInfoString(newPlayer.Name)
            if brainrotInfo:find("Nenhum") == nil then
                SendEnhancedNotification("🧠 Brainrot Detectado", 
                    newPlayer.Name .. " possui:\n" .. brainrotInfo, 5, "info")
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(leftPlayer)
    if Config.Notifications.PlayerJoinLeave then
        SendEnhancedNotification("👤 Player Saiu", leftPlayer.Name .. " saiu do jogo!", 3, "warning")
    end
end)

--===[ INICIALIZAÇÃO PREMIUM ]===--
FlexUI:Show()

-- Sequência de inicialização premium
task.spawn(function()
    task.wait(1)
    SendEnhancedNotification("🦊 Fox Panel Premium", 
        "v2.0.0 carregado com sucesso!\nBem-vindo, " .. player.DisplayName .. "! 🎉", 
        5, "success")
    
    task.wait(2)
    
    -- Mostrar brainrot do próprio player
    local myBrainrot = GetBrainrotInfoString(player.Name)
    if myBrainrot:find("Nenhum") == nil then
        SendEnhancedNotification("🧠 Seu Brainrot Premium", myBrainrot, 6, "info")
    end
    
    -- Status inicial do sistema
    task.wait(1)
    local status = UpdateSystemStatus()
    SendEnhancedNotification("📊 Status do Sistema", status, 4, "info")
end)

-- Atualizar lista de players inicial
UpdatePlayersList()

print("🎯 Fox Panel Premium v2.0.0 - Sistema Carregado!")
print("• Auto Kick System ✅")
print("• Speed Glitch Premium ✅") 
print("• Brainrot Scanner Avançado ✅")
print("• ESP Visual ✅")
print("• Notificações Inteligentes ✅")
print("• Interface Moderna ✅")

return {
    Config = Config,
    BrainrotCache = BrainrotCache,
    UpdatePlayersList = UpdatePlayersList,
    GetBrainrotInfoString = GetBrainrotInfoString
}
