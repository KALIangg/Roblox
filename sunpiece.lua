local library = loadstring(game:HttpGet("https://rawcdn.githack.com/KALIangg/Roblox-UI-Libs/refs/heads/main/xsx%20Lib/xsx%20Lib%20Source.lua"))()

library.rank = "Pro User"
local Wm = library:Watermark("V4mpz V3 - Sun Piece | v" .. library.version .. " | " .. library:GetUsername() .. " | User: " .. library.rank)
local FpsWm = Wm:AddWatermark("FPS: " .. library.fps)

coroutine.wrap(function()
    while wait(.75) do
        FpsWm:Text("FPS: " .. library.fps)
    end
end)()

local Notif = library:InitNotifications()

for i = 20,0,-1 do 
    task.wait(0.05)
    local LoadingXSX = Notif:Notify("Loading Hypex Revamp V3 - Sun Piece", 3, "information")
end 

library.title = "V4mpz V3 | Sun Piece"

library:Introduction()
wait(1)
local Init = library:Init()

-- Services
local HttpService = game:GetService("HttpService")
local plr = game.Players.LocalPlayer
local players = game:GetService("Players")
local player = players.LocalPlayer
local Players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")

-- Announce function
local function sendAnnounce(text, color, duration)
	local announces = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Announces")
	if not announces then return end

	local frame = announces:FindFirstChild("Frame")
	local template = announces:FindFirstChild("TextLabel")

	if not frame or not template then return end

	local msg = template:Clone()
	msg.Parent = frame
	msg.Visible = true
	msg.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	msg.Text = text
	wait(duration or 3)
	msg:Destroy()
end

sendAnnounce("💻 Bem vindo(a) ao painel Hypex Revamp! Seu script premium para <Sun Piece>.", Color3.fromRGB(255, 255, 255), 4)

------------------------------------
-- MAIN TAB
------------------------------------
local MainTab = Init:NewTab("🎮 Main")
local MainSection1 = MainTab:NewSection("Player Controls")

-- Anti AFK
MainTab:NewToggle("Anti AFK", false, function(state)
    if state then
        -- Ativar anti AFK
        getgenv().antiAfk = true
        local virtualInput = game:GetService('VirtualInputManager')
        
        coroutine.wrap(function()
            while getgenv().antiAfk do
                wait(60) -- Envia input a cada 60 segundos
                virtualInput:SendKeyEvent(true, "Insert", false, game)
                wait(0.1)
                virtualInput:SendKeyEvent(false, "Insert", false, game)
            end
        end)()
    else
        -- Desativar anti AFK
        getgenv().antiAfk = false
    end
end)

-- WalkSpeed
local WalkSpeedBox = MainTab:NewTextbox("WalkSpeed", "Set player walkspeed", "16", "all", "small", true, false, function(val)
    local num = tonumber(val)
    if num then
        game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = num
    end
end)

-- JumpHeight
local JumpHeightBox = MainTab:NewTextbox("JumpHeight", "Set player jump height", "50", "all", "small", true, false, function(val)
    local num = tonumber(val)
    if num then
        game.Players.LocalPlayer.Character:WaitForChild("Humanoid").JumpHeight = num
    end
end)







-- SKILLS TAB
------------------------------------
local SkillsTab = Init:NewTab("🔥 Exploits")


----------------------------------------------------------
-- 📍 SISTEMA DE SELEÇÃO DE PLAYER
----------------------------------------------------------
local selectedPlayer = nil
local SelectedPlayer = nil
local currentDropdown = nil

-- 🧠 Função para obter nomes dos jogadores
local function getPlayerNames()
	local names = {}
	for _, plr in ipairs(game.Players:GetPlayers()) do
		table.insert(names, plr.Name)
	end
	return names
end

local function createDropdown()
    if currentDropdown then
        currentDropdown:Remove()
    end

    -- 🔽 Cria o seletor (dropdown) de jogadores
    currentDropdown = SkillsTab:NewSelector("Selecionar Player", "Escolha o jogador alvo", getPlayerNames(), function(val)
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

SkillsTab:NewToggle("Localizar Jogador", false, function(state)
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
SkillsTab:NewButton("Teleport", function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)


-- 🔘 View
SkillsTab:NewButton("View", function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = selectedPlayer.Character.Humanoid
    end
end)

-- 🔘 Resetar Câmera
SkillsTab:NewButton("Unview", function()
    if player.Character then
        Camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
    end
end)


----------------------------------------------------------
-- 🎚️ Toggles Troll
----------------------------------------------------------


----------------------------------------------------------
-- 🔥 KILL SELECTED PLAYER (Tween + Instant Stop)
----------------------------------------------------------

local TweenService = game:GetService("TweenService")
local chasing = false
local chaseTween = nil
local attackLoop = nil

local function stopTween()
	if chaseTween then
		chaseTween:Cancel()
		chaseTween = nil
	end
end

local selectedSkill = "Z"
SkillsTab:NewToggle("Kill (Fruit)", false, function(state)
	if state then
		if not selectedPlayer then return end
		chasing = true

		-- 🔁 LOOP DE SEGUIR COM TWEEN
		task.spawn(function()
			while chasing do
				if not selectedPlayer or not selectedPlayer.Character then
					stopTween()
					break
				end

				local myChar = player.Character
				local targetChar = selectedPlayer.Character
				if not myChar or not targetChar then
					stopTween()
					break
				end

				local myHRP = myChar:FindFirstChild("HumanoidRootPart")
				local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
				if not myHRP or not targetHRP then
					stopTween()
					break
				end

				local distance = (myHRP.Position - targetHRP.Position).Magnitude

				-- 🔥 Se estiver muito perto → para tween e começa ataque
				if distance <= 5 then
					stopTween()
					task.wait(0.05)
				else
					-- ⚡ Cria Tween rápido e direto, sem easing lento
					stopTween()
					local travelTime = distance / 500 -- velocidade (80 studs/s)
					
					chaseTween = TweenService:Create(
						myHRP,
						TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
						{ CFrame = CFrame.new(targetHRP.Position + Vector3.new(0, 3, 0)) }
					)

					chaseTween:Play()
				end

				task.wait(0.05)
			end
		end)

		-- 🔁 LOOP DE ATAQUE
		attackLoop = task.spawn(function()
			while chasing do
				if not selectedPlayer then break end

				local tool = findValidTool("Fruits")
				if tool then
					if tool.Parent ~= player.Character then
						tool.Parent = player.Character
					end

					if selectedSkill2 == "Click" then
						tool:Activate()
					else
						local folder = (selectedType == "Fruits") and rs.FruitSkills or rs.SwordSkills
						local skillFolder = folder:FindFirstChild(tool.Name)
						if skillFolder then
							local skill = skillFolder:FindFirstChild(selectedSkill)
							if skill then
								skill:FireServer()
							end
						end
					end
				end

				task.wait(interval)
			end
		end)

	else
		-- ❌ DESLIGAR TUDO
		chasing = false
		stopTween()
	end
end)




-- 🧲 Puxar Jogador Selecionado
SkillsTab:NewToggle("Puxar", false, function(state)
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
SkillsTab:NewToggle("Puxar Todos", false, function(state)
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

SkillsTab:NewToggle("Teleport Loop", false, function(state)
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





SkillsTab:NewButton("No Cooldown", function()
    local plr = game.Players.LocalPlayer
    local keys = {"Z", "X", "C", "V"}

    local replicated = game:GetService("ReplicatedStorage")

    local fruitFolder = replicated:FindFirstChild("FruitSkills")
    local swordFolder = replicated:FindFirstChild("SwordSkills")
    local gunFolder = replicated:FindFirstChild("GunSkills")
    local bloodlineFolder = replicated:FindFirstChild("BloodlineSkills")

    local function detectToolName(folder)
        for _,v in pairs(plr.Backpack:GetChildren()) do
            if folder:FindFirstChild(v.Name) then return v.Name end
        end
        for _,v in pairs(plr.Character:GetChildren()) do
            if folder:FindFirstChild(v.Name) then return v.Name end
        end
        return nil
    end

    local function applyCooldown(folder, toolName)
        if toolName and folder then
            local skillFolder = folder:FindFirstChild(toolName)
            if skillFolder then
                for _,key in pairs(keys) do
                    local skill = skillFolder:FindFirstChild(key)
                    if skill and skill:FindFirstChild("Cooldown") then
                        skill.Cooldown.Value = 0
                    end
                end
            end
        end
    end

    local function applyBloodlineCooldown()
        if not bloodlineFolder then return end

        for _,style in pairs(bloodlineFolder:GetChildren()) do
            for _,v in pairs(plr.Backpack:GetChildren()) do
                local bloodSkills = style:FindFirstChild(v.Name)
                if bloodSkills then
                    for _,key in pairs(keys) do
                        local skill = bloodSkills:FindFirstChild(key)
                        if skill and skill:FindFirstChild("Cooldown") then
                            skill.Cooldown.Value = 0
                        end
                    end
                end
            end

            for _,v in pairs(plr.Character:GetChildren()) do
                local bloodSkills = style:FindFirstChild(v.Name)
                if bloodSkills then
                    for _,key in pairs(keys) do
                        local skill = bloodSkills:FindFirstChild(key)
                        if skill and skill:FindFirstChild("Cooldown") then
                            skill.Cooldown.Value = 0
                        end
                    end
                end
            end
        end
    end

    local activeFruit = fruitFolder and detectToolName(fruitFolder)
    local activeSword = swordFolder and detectToolName(swordFolder)
    local activeGun = gunFolder and detectToolName(gunFolder)

    applyCooldown(fruitFolder, activeFruit)
    applyCooldown(swordFolder, activeSword)
    applyCooldown(gunFolder, activeGun)
    applyBloodlineCooldown()

    Notif:Notify("🔥 No Cooldown aplicado com sucesso em todas skills!", 4, "success")
end)


SkillsTab:NewToggle("Ken V1", false, function(state)
	local Ken = game:GetService("Players").LocalPlayer.values.Ken
	local KenValue = Ken.Value
    if not Ken then return end

	if Ken then
		if state then
			Ken.Value = 1
		else
			Ken.Value = KenValue
		end
	end
end)







----------------------------------------------------------
-- 🔥 KEN V2 — LUA GOD REBUILD (COM NOTES)
----------------------------------------------------------

-- Serviços necessários
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Toggle do ESP
local KenEnabled = false
local Connections = {}

----------------------------------------------------------
-- CONFIGURAÇÃO DOS ÍCONES (tamanho médio)
----------------------------------------------------------
local ITEM_SIZE = 26
local ITEM_SPACING = 3
local MAX_ITEM_ROW = 15

----------------------------------------------------------
-- 🧹 Remove ESPs antigos de um player
----------------------------------------------------------
local function cleanESP(char)
	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("Highlight") or v:IsA("BillboardGui") then
			if v.Name == "KenV2Highlight" or v.Name == "KenV2Thumb" then
				v:Destroy()
			end
		end
	end
end

----------------------------------------------------------
-- 🔍 Detectar textureId do item (5 métodos diferentes)
----------------------------------------------------------
local function getTextureId(tool)
	-- 1: TextureId direto
	if tool.TextureId then
		return tool.TextureId
	end
	
	-- Caso não tenha: ícone invisível
	return "0"
end

----------------------------------------------------------
-- 🧪 Pega TODOS os itens (Backpack + Character)
----------------------------------------------------------
local function getAllItems(plr)
	local items = {}
	
	-- Backpack
	for _, v in ipairs(plr.Backpack:GetChildren()) do
		if v:IsA("Tool") then table.insert(items, v) end
	end
	
	-- Character
	if plr.Character then
		for _, v in ipairs(plr.Character:GetChildren()) do
			if v:IsA("Tool") then table.insert(items, v) end
		end
	end
	
	return items
end

----------------------------------------------------------
-- 🖼 Criar/Atualizar ícones com tamanho médio
----------------------------------------------------------
local function createItemIcons(frame, plr)
	-- Remove ícones antigos
	for _, v in ipairs(frame:GetChildren()) do
		if v:IsA("ImageLabel") then v:Destroy() end
	end
	
	-- Items
	local items = getAllItems(plr)
	
	local col, row = 0, 0
	
	for _, tool in ipairs(items) do
		local texture = getTextureId(tool)
		
		local img = Instance.new("ImageLabel")
		img.Parent = frame
		img.BackgroundTransparency = 1
		img.Size = UDim2.fromOffset(ITEM_SIZE, ITEM_SIZE)
		img.Image = tostring(texture)
		
		img.Position = UDim2.fromOffset(
			col * (ITEM_SIZE + ITEM_SPACING),
			row * (ITEM_SIZE + ITEM_SPACING)
		)
		
		col += 1
		if col >= MAX_ITEM_ROW then
			col = 0
			row += 1
		end
	end
end

----------------------------------------------------------
-- 🌀 Criar ESP completo do Ken V2
----------------------------------------------------------
local function applyKen(char, plr)
	cleanESP(char)
	
	-- BILLBOARDGUI
	local bb = Instance.new("BillboardGui")
	bb.Parent = char
	bb.Name = "KenV2Thumb"
	bb.AlwaysOnTop = true
	bb.MaxDistance = math.huge
	bb.Size = UDim2.new(0, 220, 0, 110)
	bb.Adornee = char:FindFirstChild("Head") or char.PrimaryPart
	
	-- FRAME PRINCIPAL (transparente)
	local bg = Instance.new("Frame")
	bg.Parent = bb
	bg.BackgroundTransparency = 1
	bg.Size = UDim2.fromScale(1, 1)
	
	------------------------------------------------------
	-- LABEL DO NOME
	------------------------------------------------------
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Parent = bg
	nameLbl.Size = UDim2.new(1, 0, 0, 18)
	nameLbl.BackgroundTransparency = 1
	nameLbl.TextScaled = true
	nameLbl.Text = plr.Name
	nameLbl.TextColor3 = Color3.new(1,1,1)
	nameLbl.TextStrokeTransparency = 0.4
	
	------------------------------------------------------
	-- HP LABEL
	------------------------------------------------------
	local hpLbl = Instance.new("TextLabel")
	hpLbl.Parent = bg
	hpLbl.Position = UDim2.new(0, 0, 0, 16)
	hpLbl.Size = UDim2.new(1, 0, 0, 18)
	hpLbl.BackgroundTransparency = 1
	hpLbl.TextScaled = true
	hpLbl.TextColor3 = Color3.fromRGB(0,255,0)
	hpLbl.TextStrokeTransparency = 0.4
	
	------------------------------------------------------
	-- LEVEL
	------------------------------------------------------
	local lvlLbl = Instance.new("TextLabel")
	lvlLbl.Parent = bg
	lvlLbl.Position = UDim2.new(0, 0, 0, 32)
	lvlLbl.Size = UDim2.new(1, 0, 0, 18)
	lvlLbl.BackgroundTransparency = 1
	lvlLbl.TextScaled = true
	lvlLbl.TextColor3 = Color3.fromRGB(0,170,255)
	lvlLbl.TextStrokeTransparency = 0.4
	
	------------------------------------------------------
	-- BELI
	------------------------------------------------------
	local beliLbl = Instance.new("TextLabel")
	beliLbl.Parent = bg
	beliLbl.Position = UDim2.new(0, 0, 0, 48)
	beliLbl.Size = UDim2.new(1, 0, 0, 18)
	beliLbl.BackgroundTransparency = 1
	beliLbl.TextScaled = true
	beliLbl.TextColor3 = Color3.fromRGB(255,205,0)
	beliLbl.TextStrokeTransparency = 0.4
	
	------------------------------------------------------
	-- FRAME DOS ÍCONES
	------------------------------------------------------
	local iconFrame = Instance.new("Frame")
	iconFrame.Parent = bg
	iconFrame.Position = UDim2.new(0, 4, 0, 70)
	iconFrame.Size = UDim2.new(1, -8, 0, 35)
	iconFrame.BackgroundTransparency = 1
	
	-- Criar ícones
	createItemIcons(iconFrame, plr)
	
	------------------------------------------------------
	-- Highlight (Outline Vermelho)
	------------------------------------------------------
	local h = Instance.new("Highlight")
	h.Parent = char
	h.Name = "KenV2Highlight"
	h.FillColor = Color3.fromRGB(226,0,0)
	h.OutlineColor = Color3.fromRGB(255,0,0)
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	
	------------------------------------------------------
	-- Atualização em tempo real
	------------------------------------------------------
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if hum then
		hpLbl.Text = "HP: " .. math.floor(hum.Health)
		table.insert(Connections, hum.HealthChanged:Connect(function()
			hpLbl.Text = "HP: " .. math.floor(hum.Health)
		end))
	end
	
	-- Level + Beli (values folder)
	local values = plr:FindFirstChild("Values") or plr:FindFirstChild("values")
	if values then
		if values:FindFirstChild("Level") then
			lvlLbl.Text = "LVL: " .. values.Level.Value
			
			table.insert(Connections, values.Level:GetPropertyChangedSignal("Value"):Connect(function()
				lvlLbl.Text = "LVL: " .. values.Level.Value
			end))
		end
		
		if values:FindFirstChild("Beli") then
			beliLbl.Text = "Beli: " .. values.Beli.Value
			
			table.insert(Connections, values.Beli:GetPropertyChangedSignal("Value"):Connect(function()
				beliLbl.Text = "Beli: " .. values.Beli.Value
			end))
		end
	end
end

----------------------------------------------------------
-- 🌀 Aplicar ESP em todos players
----------------------------------------------------------
local function setupKen()
	-- Desconectar tudo
	for _, c in ipairs(Connections) do c:Disconnect() end
	Connections = {}
	
	if not KenEnabled then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character then cleanESP(plr.Character) end
		end
		return
	end
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if plr.Character then applyKen(plr.Character, plr) end
			
			table.insert(Connections, plr.CharacterAdded:Connect(function(c)
				task.wait(1)
				if KenEnabled then applyKen(c, plr) end
			end))
		end
	end
end

----------------------------------------------------------
-- 🔘 Toggle no menu
----------------------------------------------------------
SkillsTab:NewToggle("Ken V2", false, function(state)
	KenEnabled = state
	setupKen()
end)




local FlashPath = game.Players.LocalPlayer.Character:WaitForChild("FlashStep")
local FlashMax = FlashPath:FindFirstChild("MaxFlashSteps")
local FlashRemote = FlashPath:FindFirstChild("RemoteEvent")

local function FlashCooldown()
	print("--- FLASH STEP HACKING... ---")
	if FlashPath and FlashMax then
		FlashMax.Value = 10000
		print("[DEBUG] FlashMax.Value = 10000 (No Cooldown)")
	else
		print("[DEBUG] FlashMax hacking failure - Can't find the correct path, player problably don't have the necessary abilities.")
	end
end

local function FlashUnCooldown()
	print("--- FLASH STEP UNHACKING ---")
	if FlashPath and FlashMax then
		FlashMax.Value = 1
		print("[DEBUG] FlashMax.Value = 0 (No Cooldown Turned Off)")
	else
		print("[DEBUG] If you're reading this, i don't fucking know what happened. You should never see this message.")
	end
end



SkillsTab:NewToggle("Infinite Flash Step", false, function(val)
	if val then
		FlashCooldown()
	else
		FlashUnCooldown()
	end
end)

------------------------------------
-- MISSIONS TAB
------------------------------------
local AutoFarmTab = Init:NewTab("💻 Farm")

local plr = game.Players.LocalPlayer
local farming = false
local selectedType = nil
local selectedSkill = "Click"
local interval = 1.5

local rs = game:GetService("ReplicatedStorage")
local vim = game:GetService("VirtualInputManager")

local farmThread = nil
local antiAFKThread = nil


-- Encontrar espada ou fruta válida
local function findValidTool(toolType)
    local src = (toolType == "Fruits") and rs:FindFirstChild("Fruits") or rs:FindFirstChild("Swords")
    if not src then return nil end

    local valid = {}
    for _, v in ipairs(src:GetChildren()) do
        table.insert(valid, v.Name)
    end

    for _, t in ipairs(plr.Backpack:GetChildren()) do
        if table.find(valid, t.Name) then
            return t
        end
    end

    for _, t in ipairs(plr.Character:GetChildren()) do
        if table.find(valid, t.Name) then
            return t
        end
    end

    return nil
end


-- LOOP PRINCIPAL DO AUTOFARM
local function startFarm()
    if farming then return end
    farming = true
    print("AutoFarm iniciado!")

    -- LOOP DE FARM
    farmThread = task.spawn(function()
        while farming do

            if not selectedType then 
                task.wait(0.3)
                continue
            end

            local tool = findValidTool(selectedType)
            if not tool then 
                task.wait(0.3)
                continue
            end

            if tool.Parent ~= plr.Character then
                tool.Parent = plr.Character
                task.wait(0.15)
            end

            if selectedSkill == "Click" then
                tool:Activate()

            else
                local folder = (selectedType == "Fruits") and rs:FindFirstChild("FruitSkills") or rs:FindFirstChild("SwordSkills")
                if folder then
                    local skillFolder = folder:FindFirstChild(tool.Name)
                    if skillFolder then
                        local skill = skillFolder:FindFirstChild(selectedSkill)
                        if skill then
                            skill:FireServer()
                        end
                    end
                end
            end

            task.wait(interval)
        end
    end)

    -- LOOP DE ANTI-AFK
    antiAFKThread = task.spawn(function()
        print("Anti-AFK iniciado!")
        while farming do
            vim:SendKeyEvent(true, "Insert", false, game)
            task.wait(0.05)
            vim:SendKeyEvent(false, "Insert", false, game)
            task.wait(240)
        end
        print("Anti-AFK parado!")
    end)
end


-- PARAR AUTOFARM E ANTI-AFK
local function stopFarm()
    if not farming then return end
    print("AutoFarm parado!")
    farming = false
end


-- UI
local AutoFarmSection1 = AutoFarmTab:NewSection("Configurações AutoFarm")

AutoFarmTab:NewSelector("Tipo de Ataque", "Fruits", {"Fruits", "Swords"}, function(opt)
    selectedType = opt
end)

AutoFarmTab:NewSelector("Skill para usar", "Click", {"Click", "Z", "X", "C", "V"}, function(option)
    selectedSkill = option
end)


local AutoFarmSection2 = AutoFarmTab:NewSection("Controles")

AutoFarmTab:NewToggle("Ativar AutoFarm", false, function(state)
    if state then
        startFarm()
    else
        stopFarm()
    end
end)



------------------------------------
-- SERVER TAB
------------------------------------
local AdminTab = Init:NewTab("💣 Destruição")

local crashing = false
local crashConn
local selectedWeapon = nil
local selectedSkillCrash = nil
local currentSkillObject = nil

local replicated = game:GetService("ReplicatedStorage")
local allWeapons = {}
for _,v in pairs(replicated:FindFirstChild("FruitSkills"):GetChildren()) do
    table.insert(allWeapons, v.Name)
end
for _,v in pairs(replicated:FindFirstChild("SwordSkills"):GetChildren()) do
    table.insert(allWeapons, v.Name)
end

local AdminSection1 = AdminTab:NewSection("Crash Server FE")
AdminTab:NewLabel("💣 Crash Server FE - Legacy Mode (Skill Manual)", "center")

AdminTab:NewSelector("Selecionar Arma:", "Fruits", allWeapons, function(wpn)
    selectedWeapon = wpn
    selectedSkillCrash = nil
    currentSkillObject = nil

    local folder = replicated.FruitSkills:FindFirstChild(wpn) or replicated.SwordSkills:FindFirstChild(wpn)
    if folder then
        local skillNames = {}
        for _, skill in pairs(folder:GetChildren()) do
            if skill:IsA("RemoteEvent") then
                table.insert(skillNames, skill.Name)
            end
        end
        
        AdminTab:NewSelector("Selecionar Skill:", "Z", skillNames, function(skill)
            selectedSkillCrash = skill
            currentSkillObject = folder:FindFirstChild(skill)
        end)
    end
end)

AdminTab:NewButton("🔥 Iniciar Crash FE (Normal)", function()
    if crashing then
        Notif:Notify("Crash FE já está ativo!", 3, "alert")
        return
    end
    if not currentSkillObject then
        Notif:Notify("Selecione arma e skill primeiro!", 3, "error")
        return
    end

    crashing = true
    Notif:Notify("🔥 Crash FE iniciado com skill "..selectedSkillCrash.."!", 4, "success")

    crashConn = game:GetService("RunService").RenderStepped:Connect(function()
        currentSkillObject:FireServer(plr.Name)
        task.wait(0.05)
    end)
end)

AdminTab:NewButton("🛑 Parar Crash FE", function()
    if crashing then
        crashing = false
        if crashConn then crashConn:Disconnect() end
        Notif:Notify("Crash FE parado com sucesso!", 4, "success")
    end
end)


------------------------------------
-- INVENTORY TAB
------------------------------------
local InventoryTab = Init:NewTab("⚔️ Items")


local InventorySection2 = InventoryTab:NewSection("Espadas 🔪")
for i = 1, 20 do
    InventoryTab:NewButton("Ativar Sword"..i, function()
        local v = plr.values:FindFirstChild("Sword"..i)
        if v then
            v.Value = 1
            local swordClone = game:GetService("ReplicatedStorage").Weapons:FindFirstChild("Sword"..i)
            if swordClone then
                swordClone:Clone().Parent = plr.Backpack
            end
        end
        Notif:Notify("Sword"..i.." ativada e clonada!", 4, "success")
    end)
end

InventoryTab:NewButton("Ativar Todas Swords", function()
    for _,v in pairs(plr.values:GetChildren()) do
        if v.Name:match("^Sword%d+") then
            v.Value = 1
        end
    end
    Notif:Notify("Todas Swords ativadas!", 4, "success")
end)

local InventorySection3 = InventoryTab:NewSection("Armas 🔫")
for i = 1, 6 do
    InventoryTab:NewButton("Ativar Gun"..i, function()
        local v = plr.values:FindFirstChild("Gun"..i)
        if v then
            v.Value = 1
        end
        Notif:Notify("Gun"..i.." ativada!", 4, "success")
    end)
end

InventoryTab:NewButton("Ativar Todas Guns", function()
    for _,v in pairs(plr.values:GetChildren()) do
        if v.Name:match("^Gun%d+") then
            v.Value = 1
        end
    end
    Notif:Notify("Todas Guns ativadas!", 4, "success")
end)

local InventorySection4 = InventoryTab:NewSection("Emotes 💃")
for i = 1, 15 do
    InventoryTab:NewButton("Ativar Emote"..i, function()
        local v = plr.values:FindFirstChild("Emote"..i)
        if v then
            v.Value = 1
        end
        Notif:Notify("Emote"..i.." ativado!", 4, "success")
    end)
end

InventoryTab:NewButton("Ativar Todos Emotes", function()
    for _,v in pairs(plr.values:GetChildren()) do
        if v.Name:match("^Emote%d+") then
            v.Value = 1
        end
    end
    Notif:Notify("Todos Emotes ativados!", 4, "success")
end)

local InventorySection5 = InventoryTab:NewSection("Acessórios 🎭")
for i = 1, 10 do
    InventoryTab:NewButton("Ativar Acc"..i, function()
        local v = plr.values:FindFirstChild("Acc"..i)
        if v then
            v.Value = 1
            local accClone = game:GetService("ReplicatedStorage").Accessories:FindFirstChild("Acc"..i)
            if accClone then
                accClone:Clone().Parent = plr.Backpack
            end
        end
        Notif:Notify("Acc"..i.." ativado e clonado!", 4, "success")
    end)
end

InventoryTab:NewButton("Ativar Todos Accs", function()
    for i = 1, 10 do
        local v = plr.values:FindFirstChild("Acc"..i)
        if v then
            v.Value = 1
            local accClone = game:GetService("ReplicatedStorage").Accessories:FindFirstChild("Acc"..i)
            if accClone then
                accClone:Clone().Parent = plr.Backpack
            end
        end
    end
    Notif:Notify("Todos Accs ativados e clonados!", 4, "success")
end)


------------------------------------
-- NPC MENUS TAB
------------------------------------
local NPCGuiTab = Init:NewTab("📱 Guis")

local npcsFolder = plr.PlayerGui["Npc's"]

local NPCSection1 = NPCGuiTab:NewSection("🍇 Fruta / Perms")
NPCGuiTab:NewToggle("FruitDealer 🍇", false, function(state)
    local gui = npcsFolder:FindFirstChild("FruitDealer")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("Soul Guitar 🎸", false, function(state)
    local gui = npcsFolder:FindFirstChild("SkullGuitarDealer")
    if gui then gui.Enabled = state end
end)

local NPCSection2 = NPCGuiTab:NewSection("🗡️ Espadas / Acessórios")
NPCGuiTab:NewToggle("SwordDealer 🗡️", false, function(state)
    local gui = npcsFolder:FindFirstChild("SwordDealer")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("True Triple Katana ⚔️", false, function(state)
    local gui = npcsFolder:FindFirstChild("TtkDealer")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("AccDealer1 🎭", false, function(state)
    local gui = npcsFolder:FindFirstChild("AccDealer1")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("EmmaDealer 🗡️", false, function(state)
    local gui = npcsFolder:FindFirstChild("EmmaDealer")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("ArmorDealer1 🛡️", false, function(state)
    local gui = npcsFolder:FindFirstChild("ArmorDealer1")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("ArmorDealer2 🛡️", false, function(state)
    local gui = npcsFolder:FindFirstChild("ArmorDealer2")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("ArmorDealer3 🛡️", false, function(state)
    local gui = npcsFolder:FindFirstChild("ArmorDealer3")
    if gui then gui.Enabled = state end
end)

local NPCSection3 = NPCGuiTab:NewSection("🌌 Raças / Awakenings")
NPCGuiTab:NewToggle("RaceAwakener 🌌", false, function(state)
    local gui = npcsFolder:FindFirstChild("RaceAwakener")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("RaceAwakenerV3 💠", false, function(state)
    local gui = npcsFolder:FindFirstChild("RaceAwakenerV3")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("DragonRaceDealer 🐲", false, function(state)
    local gui = npcsFolder:FindFirstChild("DragonRaceDealer")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("V4 Awakener", false, function(state)
    local gui = npcsFolder:FindFirstChild("AncientAwakener")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("LeviathanRaceDealer 🌊", false, function(state)
    local gui = npcsFolder:FindFirstChild("LeviathanRaceDealer")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("SpinRace 🎡", false, function(state)
    local gui = npcsFolder:FindFirstChild("SpinRace")
    if gui then gui.Enabled = state end
end)

local NPCSection4 = NPCGuiTab:NewSection("⚔️ Haki / Estilos")
NPCGuiTab:NewToggle("KenTeacher 👁️", false, function(state)
    local gui = npcsFolder:FindFirstChild("KenTeacher")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("Ability Teacher 👊", false, function(state)
    local gui = npcsFolder:FindFirstChild("AbilityTeacher")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("Buso V2 🔥", false, function(state)
    local gui = npcsFolder:FindFirstChild("DrachHaki")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("HakiColor 🌈", false, function(state)
    local gui = npcsFolder:FindFirstChild("HakiColor")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("MonkeyStyleDealer 🐒", false, function(state)
    local gui = npcsFolder:FindFirstChild("MonkeyStyleDealer")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("DarkStepDealer 👣", false, function(state)
    local gui = npcsFolder:FindFirstChild("DarkStepDealer")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("DragonTalonDealer 🔥", false, function(state)
    local gui = npcsFolder:FindFirstChild("DragonTalonDealer")
    if gui then gui.Enabled = state end
end)


local NPCSection5 = NPCGuiTab:NewSection("🌀 Portais / Áreas / Exploração")
NPCGuiTab:NewToggle("GetBackToFirst 🌍", false, function(state)
    local gui = npcsFolder:FindFirstChild("GetBackToFirst")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("GetBackToSecond 🌊", false, function(state)
    local gui = npcsFolder:FindFirstChild("GetBackToSecond")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("SecondSeaExpert 🌊", false, function(state)
    local gui = npcsFolder:FindFirstChild("SecondSeaExpert")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("ThirdSeaExpert 🌋", false, function(state)
    local gui = npcsFolder:FindFirstChild("ThirdSeaExpert")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("Dough King Spawner ❄️", false, function(state)
    local gui = npcsFolder:FindFirstChild("DoughKingSpawner")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("Shenron 🐉", false, function(state)
    local gui = npcsFolder:FindFirstChild("Shenron")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("OkarunNPC 👻", false, function(state)
    local gui = npcsFolder:FindFirstChild("OkarunNPC")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("Snowman ☃️", false, function(state)
    local gui = npcsFolder:FindFirstChild("Snowman")
    if gui then gui.Enabled = state end
end)

------------------------------------
-- CMD SYSTEM TAB
------------------------------------
local CmdTab = Init:NewTab("🛡️ Admin")

local crashingCmd = false
local crashThread = nil
local notifierStarted = false

local function crash()
    local fruit = nil
    local rs = game:GetService("ReplicatedStorage")

    for _,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        for _,f in pairs(rs.Fruits:GetChildren()) do
            if v.Name == f.Name then
                fruit = f.Name
            end
        end
    end

    if not fruit then
        sendAnnounce("❌ Nenhuma fruta encontrada no Backpack!", Color3.fromRGB(255, 0, 0), 3)
        return
    end

    local skill = rs.FruitSkills:FindFirstChild(fruit)
    local skillz = skill and (fruit == "Dragon" and skill:FindFirstChild("C") or skill:FindFirstChild("Z"))

    if not skillz then
        sendAnnounce("❌ Skill Z/C não encontrada para "..fruit, Color3.fromRGB(255, 0, 0), 3)
        return
    end

    if crashingCmd then
        sendAnnounce("⚠️ Crash já está ativo!", Color3.fromRGB(255, 255, 0), 3)
        return
    end

    crashingCmd = true
    sendAnnounce("💥 Iniciando crash infinito com "..fruit, Color3.fromRGB(255, 0, 0), 3)

    crashThread = task.spawn(function()
        while crashingCmd do
            skillz:FireServer(game.Players.LocalPlayer.Name)
            task.wait(0.01)
        end
    end)
end

local function stopCrash()
    if crashingCmd then
        crashingCmd = false
        sendAnnounce("🛑 Crash interrompido com sucesso.", Color3.fromRGB(0, 255, 0), 3)
    else
        sendAnnounce("⚠️ Nenhum crash ativo no momento.", Color3.fromRGB(255, 255, 0), 3)
    end
end

---------------------------------------------------------
-- 👁️ Ken Haki
---------------------------------------------------------
local function giveKen()
    local ken = plr:FindFirstChild("values") and plr.values:FindFirstChild("Ken")

    if ken then
        ken.Value = 1
        Notif:Notify("👁️ Ken ativado!", 3, "success")
    else
        Notif:Notify("❌ Ken não encontrado!", 3, "error")
    end
end

---------------------------------------------------------
-- ⏱️ NoCooldown (client side)
---------------------------------------------------------
local function noCooldown()
    -- nota: isso não remove cooldown real, só local (client-side)
    for _, folder in pairs({"FruitSkills","SwordSkills"}) do
        local mainFolder = rs:FindFirstChild(folder)
        if mainFolder then
            for _, skillFolder in ipairs(mainFolder:GetChildren()) do
                for _, skill in ipairs(skillFolder:GetChildren()) do
                    if skill:FindFirstChild("Cooldown") then
                        skill.Cooldown.Value = 0
                    end
                end
            end
        end
    end

    Notif:Notify("⏱️ Cooldown resetado localmente!", 4, "success")
end

---------------------------------------------------------
-- ⚔️ Todas espadas (client)
---------------------------------------------------------
local function allSwords()
    for _,v in pairs(plr.values:GetChildren()) do
        if v.Name:match("^Sword%d+") then
            v.Value = 1
        end
    end
    Notif:Notify("⚔️ Todas swords ativadas!", 4, "success")
end

---------------------------------------------------------
-- 🎒 Todos acessórios (client)
---------------------------------------------------------
local function allAccs()
    for _,v in pairs(plr.values:GetChildren()) do
        if v.Name:match("^Acc%d+") then
            v.Value = 1
        end
    end
    Notif:Notify("🎩 Todos acessórios ativados!", 4, "success")
end

---------------------------------------------------------
-- 🔔 Notificador de Boss / Evento
---------------------------------------------------------
local notifierStarted = false

local function createHighlight(target)
    local hl = Instance.new("Highlight")
    hl.Name = "BossHighlight"
    hl.FillColor = Color3.fromRGB(255,80,80)
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255,0,0)
    hl.Parent = target
end

local function eventNotifier()
    for _, enemy in ipairs(workspace:GetDescendants()) do
        if enemy.Name == "Shark [Lvl 2500]" then
            sendAnnounce("🚨 Evento Detectado: Shark Spawnou!", Color3.fromRGB(0,255,0), 4)
            createHighlight(enemy)
        end
    end
end

local function startNotifier()
    if notifierStarted then
        sendAnnounce("⚠️ Notifier já ativo!", Color3.fromRGB(255,255,0))
        return
    end

    notifierStarted = true
    sendAnnounce("🔔 Notifier ativado!", Color3.fromRGB(0,255,0))

    workspace.DescendantAdded:Connect(function(obj)
        if obj.Name == "Shark [Lvl 2500]" then
            eventNotifier()
        end
    end)

    eventNotifier()
end

---------------------------------------------------------
-- 🤮 Vomitar Frutas
---------------------------------------------------------
local function vomit()
    local backpack = plr.Backpack
    local fruits = rs:WaitForChild("RandomFruits")

    local count = 0
    for _, tool in ipairs(backpack:GetChildren()) do
        if fruits:FindFirstChild(tool.Name) then
            tool.Parent = workspace
            count += 1
        end
    end

    if count == 0 then
        Notif:Notify("❌ Nenhuma fruta para vomitar!", 3, "error")
    else
        Notif:Notify("🤮 Vomitadas: "..count.." frutas!", 3, "success")
    end
end

---------------------------------------------------------
-- ⭐ NOVAS FUNÇÕES CLIENT
---------------------------------------------------------

-- 🎯 Highlight no Player Local  
local function highlightSelf()
    local char = plr.Character
    if char then
        createHighlight(char)
        Notif:Notify("✨ Highlight ativado no seu personagem!", 3, "success")
    end
end

-- 🔆 Iluminar o mapa inteiro
local function fullbright()
    for _,v in pairs(game.Lighting:GetChildren()) do
        if v:IsA("ColorCorrectionEffect") then v:Destroy() end
    end
    local fx = Instance.new("ColorCorrectionEffect", game.Lighting)
    fx.Brightness = 0.2
    fx.Contrast = 1
    fx.Saturation = 0.3

    Notif:Notify("🔆 FullBright ativado!", 3, "success")
end

-- ⚡ Dash infinito (client)
local function infiniteDash()
    plr.Character.Humanoid.WalkSpeed = 35
    Notif:Notify("⚡ Infinite Dash ativado (client)!", 3, "success")
end

---------------------------------------------------------
-- 📜 Lista de comandos
---------------------------------------------------------
local commands = {
    ["!g Ken"] = giveKen,
    ["!g NoCooldown"] = noCooldown,
    ["!g AllSwords"] = allSwords,
    ["!g AllAccs"] = allAccs,
    ["!notifier"] = startNotifier,
    ["!vomit"] = vomit,
    ["!highlight"] = highlightSelf,
    ["!bright"] = fullbright,
    ["!dash"] = infiniteDash,
    ["/disconnect all"] = crash,
    ["/stop crash"] = stopCrash,
}

--// 🔘 Botões individuais para cada comando
local CmdButtons = CmdTab:NewSection("Botões de Comandos")

CmdTab:NewButton("⚔️ Ativar Ken", function()
    pcall(commands["!g Ken"])
end)

CmdTab:NewButton("⏱️ NoCooldown (Client)", function()
    pcall(commands["!g NoCooldown"])
end)

CmdTab:NewButton("🗡️ Ativar Todas Swords", function()
    pcall(commands["!g AllSwords"])
end)

CmdTab:NewButton("🎩 Ativar Todos Acessórios", function()
    pcall(commands["!g AllAccs"])
end)

CmdTab:NewButton("🔔 Ativar Notificador", function()
    pcall(commands["!notifier"])
end)

CmdTab:NewButton("🤮 Vomitar Frutas", function()
    pcall(commands["!vomit"])
end)

CmdTab:NewButton("✨ Highlight no Player", function()
    pcall(commands["!highlight"])
end)

CmdTab:NewButton("🔆 Full Bright", function()
    pcall(commands["!bright"])
end)

CmdTab:NewButton("⚡ Dash Infinito", function()
    pcall(commands["!dash"])
end)

CmdTab:NewButton("💥 Ativar Crash", function()
    pcall(commands["/disconnect all"])
end)

CmdTab:NewButton("🛑 Parar Crash", function()
    pcall(commands["/stop crash"])
end)


local CmdMisc = CmdTab:NewSection("Misc", "center")

CmdTab:NewButton("💻 - Dex Explorer", function()
    Notif:Notify("Carregando Dex Explorer...", 5, "sucess")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)


---------------------------------------------------------
-- 🔊 Handler do novo Chat
---------------------------------------------------------
TextChatService.OnIncomingMessage = function(msg)
    local content = msg.Text
    if commands[content] then
        pcall(commands[content])
    end
end

---------------------------------------------------------
-- 🎉 Loaded
---------------------------------------------------------
Notif:Notify("Admin Tab V2 - Carregado com sucesso! ⚡🔥", 4, "success")
