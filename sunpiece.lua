local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox-UI-Libs/refs/heads/main/xsx%20Lib/xsx%20Lib%20Source.lua"))()

library.rank = "developer"
local Wm = library:Watermark("🥷Hypex Revamp V3 - Sun Piece | v" .. library.version .. " | " .. library:GetUsername() .. " | rank: " .. library.rank)
local FpsWm = Wm:AddWatermark("fps: " .. library.fps)

coroutine.wrap(function()
    while wait(.75) do
        FpsWm:Text("fps: " .. library.fps)
    end
end)()

local Notif = library:InitNotifications()

for i = 20,0,-1 do 
    task.wait(0.05)
    local LoadingXSX = Notif:Notify("Loading Hypex Revamp V3 - Sun Piece", 3, "information")
end 

library.title = "Hypex Revamp V3"

library:Introduction()
wait(1)
local Init = library:Init()

-- Services
local HttpService = game:GetService("HttpService")
local plr = game.Players.LocalPlayer
local players = game:GetService("Players")
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
local MainTab = Init:NewTab("🧾 Credits")

local MainSection1 = MainTab:NewSection("Main Controls")
MainTab:NewLabel("Creditos: Feito por Gomes Dev, versão 2.1.5", "center")

------------------------------------
-- SKILLS TAB
------------------------------------
local SkillsTab = Init:NewTab("🔥 Exploits")


SkillsTab:NewButton("🔥 No Cooldown Skills", function()
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


SkillsTab:NewButton("🔥 Puxar Haki da Observação - Habilidades", function()
    local Ken = game:GetService("Players").LocalPlayer.values.Ken
    if not Ken then
        print('Something went wrong. - Error: Ken not found.')
        return
    end

    if Ken then
        print("ESP - Built In (Enabled)")
        Ken.Value = 1
        Notif:Notify("Haki da Observação puxado e spoofado com sucesso.", 4, "success")
    end
end)



SkillsTab:NewButton("🔥 Kill All", function()

    local RunService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer

    local function waitForChar(plr)
        if not plr.Character then plr.CharacterAdded:Wait() end
        plr.Character:WaitForChild("HumanoidRootPart")
        plr.Character:WaitForChild("Humanoid")
        return plr.Character
    end

    local char = waitForChar(lp)
    local hrp = char:FindFirstChild("HumanoidRootPart")

    -- GET PLAYERS
    local function getPlayers()
        local players = {}
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(players, plr)
            end
        end
        return players
    end

    -- GET SWORD
    local function getSword()
        for _, tool in ipairs(lp.Backpack:GetChildren()) do
            if game.ReplicatedStorage.Swords:FindFirstChild(tool.Name) then
                return tool
            end
        end
    end

    -- GET SKILL
    local function getSkill(swordName)
        return game.ReplicatedStorage.SwordSkills:FindFirstChild(swordName)
    end

    -- FOLLOW REAL-TIME + ATTACK WHEN CLOSE
    local function chaseAndAttack(targetChar, skill)
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end

        -- LOOP DE SEGUIR
        while targetChar:FindFirstChild("Humanoid") 
        and targetChar.Humanoid.Health > 0 
        and lp.Character:FindFirstChild("HumanoidRootPart") do
            
            local myPos = hrp.Position
            local targetPos = targetHRP.Position
            local distance = (myPos - targetPos).Magnitude

            -- SEGUIR SUAVE COM LERP
            local newPos = myPos:Lerp(targetPos + Vector3.new(0, 3, 0), 0.15)
            hrp.CFrame = CFrame.new(newPos, targetPos)

            -- QUANDO ESTIVER PERTO → ATACAR
            if distance < 100 then
                if skill and skill:FindFirstChild("Z") then
                    skill.Z:FireServer()
                end
            end

            task.wait(0.05)
        end
    end


    -- MAIN EXECUTION
    local function KillAll()
        local sword = getSword()
        if not sword then return end

        lp.Character.Humanoid:EquipTool(sword)
        task.wait(0.2)

        local skill = getSkill(sword.Name)
        if not skill then return end

        for _, enemy in ipairs(getPlayers()) do
            local enemyChar = waitForChar(enemy)
            chaseAndAttack(enemyChar, skill)
            task.wait(0.3)
        end
    end

    KillAll()

end)






-- ESP System
local espConns, espEnabled = {}, false
local requiredLevel = 400
local espPlr = players.LocalPlayer

local function cleanESP(char)
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Highlight") or v:IsA("BillboardGui") then
            if v.Name == "ESPHighlight" or v.Name == "PlayerESPThumb" or v.Name == "XrayHighlight" or v.Name == "XrayThumb" then
                v:Destroy()
            end
        end
    end
end

local function applyESP(char, name)
    cleanESP(char)

    local bb = Instance.new("BillboardGui", char)
    bb.Name = "PlayerESPThumb"
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 150, 0, 40)
    bb.MaxDistance = math.huge
    bb.Adornee = char:FindFirstChild("Head") or char.PrimaryPart or char

    local nameLbl = Instance.new("TextLabel", bb)
    nameLbl.Size = UDim2.new(1,0,0.33,0)
    nameLbl.Position = UDim2.new(0, 0, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextScaled = true
    nameLbl.TextStrokeTransparency = 0.5
    nameLbl.Text = name
    nameLbl.TextColor3 = Color3.new(1,1,1)
    nameLbl.TextStrokeColor3 = Color3.new(0,0,0)

    local hpLbl = Instance.new("TextLabel", bb)
    hpLbl.Name = "HP"
    hpLbl.Size = UDim2.new(1,0,0.33,0)
    hpLbl.Position = UDim2.new(0, 0, 0.33, 0)
    hpLbl.BackgroundTransparency = 1
    hpLbl.TextScaled = true
    hpLbl.TextStrokeTransparency = 0.5
    hpLbl.TextColor3 = Color3.fromRGB(0,255,0)
    hpLbl.TextStrokeColor3 = Color3.new(0,0,0)

    local lvlLbl = Instance.new("TextLabel", bb)
    lvlLbl.Name = "Level"
    lvlLbl.Size = UDim2.new(1,0,0.33,0)
    lvlLbl.Position = UDim2.new(0, 0, 0.66, 0)
    lvlLbl.BackgroundTransparency = 1
    lvlLbl.TextScaled = true
    lvlLbl.TextStrokeTransparency = 0.5
    lvlLbl.TextColor3 = Color3.fromRGB(0,170,255)
    lvlLbl.TextStrokeColor3 = Color3.new(0,0,0)

    local esp = Instance.new("Highlight", char)
    esp.Name = "ESPHighlight"
    esp.FillColor = Color3.fromRGB(226,0,0)
    esp.OutlineColor = Color3.fromRGB(255,0,0)
    esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    local hum = char:FindFirstChildWhichIsA("Humanoid")
    local player = players:GetPlayerFromCharacter(char)

    if hum then
        hpLbl.Text = "HP: "..math.floor(hum.Health)
        table.insert(espConns, hum.HealthChanged:Connect(function()
            if hpLbl.Parent then
                hpLbl.Text = "HP: "..math.floor(hum.Health)
            end
        end))
    end

    if player then
        local levelVal = player:FindFirstChild("values") and player.values:FindFirstChild("Level")
        if levelVal then
            lvlLbl.Text = "LVL: "..levelVal.Value
            table.insert(espConns, levelVal:GetPropertyChangedSignal("Value"):Connect(function()
                if lvlLbl.Parent then
                    lvlLbl.Text = "LVL: "..levelVal.Value
                end
            end))
        else
            lvlLbl.Text = "LVL: ???"
        end
    end
end

local function setupESP()
    for _, conn in ipairs(espConns) do conn:Disconnect() end
    espConns = {}

    if espEnabled then
        for _, p in ipairs(players:GetPlayers()) do
            if p.Character then applyESP(p.Character, p.Name) end
            table.insert(espConns, p.CharacterAdded:Connect(function(c)
                task.wait(1)
                if espEnabled then applyESP(c, p.Name) end
            end))
        end

        table.insert(espConns, players.PlayerAdded:Connect(function(p)
            table.insert(espConns, p.CharacterAdded:Connect(function(c)
                task.wait(1)
                if espEnabled then applyESP(c, p.Name) end
            end))
        end))

        table.insert(espConns, uis.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Enum.KeyCode.E and espEnabled then
                local levelVal = espPlr:FindFirstChild("Values") and espPlr.Values:FindFirstChild("Level")
                if levelVal and levelVal.Value >= requiredLevel then
                    for _, p in ipairs(players:GetPlayers()) do
                        if p.Character then applyESP(p.Character, p.Name) end
                    end
                else
                    print("🔒 Level too low to activate Observation Haki V2!")
                end
            end
        end))
    else
        for _, p in ipairs(players:GetPlayers()) do
            if p.Character then cleanESP(p.Character) end
        end
    end
end

SkillsTab:NewToggle("🔥 Haki OBS V2", false, function(state)
    espEnabled = state
    setupESP()
end)

------------------------------------
-- MISSIONS TAB
------------------------------------
local AutoFarmTab = Init:NewTab("Farm")

local plr = game.Players.LocalPlayer
local farming = false
local selectedType = nil
local selectedSkill = "Click"
local interval = 1

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

local AdminMisc = AdminTab:NewSection("Misc", "center")


AdminTab:NewButton("💻 - Dex Explorer", function()
    Notif:Notify("Carregando Dex Explorer...", 5, "sucess")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)


------------------------------------
-- INVENTORY TAB
------------------------------------
local InventoryTab = Init:NewTab("⚔️ Items")

local autoLoadProfile = [[
{}
]]

if plr:FindFirstChild("values") then
    local loaded = HttpService:JSONDecode(autoLoadProfile)
    for name, value in pairs(loaded) do
        local v = plr.values:FindFirstChild(name)
        if v then
            v.Value = value
        end
    end
    sendAnnounce("💾 Save: todos seus itens foram carregados!", Color3.fromRGB(0, 255, 0), 4)
end

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

local InventorySection6 = InventoryTab:NewSection("Gerenciamento Perfil 🗂️")
InventoryTab:NewButton("Salvar Perfil (Copy JSON)", function()
    local valuesFolder = plr:FindFirstChild("values")
    if valuesFolder then
        local data = {}
        for _,v in pairs(valuesFolder:GetChildren()) do
            data[v.Name] = v.Value
        end
        setclipboard(HttpService:JSONEncode(data))
        Notif:Notify("Perfil Copiado para clipboard!", 4, "success")
    end
end)

InventoryTab:NewButton("Carregar Perfil (Paste JSON)", function()
    local valuesFolder = plr:FindFirstChild("values")
    if valuesFolder then
        local input = library:Prompt("Colar JSON do Perfil", "Insira seu JSON aqui:")
        if input then
            local loaded = HttpService:JSONDecode(input)
            for name, value in pairs(loaded) do
                local v = valuesFolder:FindFirstChild(name)
                if v then
                    v.Value = value
                end
            end
            Notif:Notify("Perfil Carregado com sucesso!", 4, "success")
        end
    end
end)

InventoryTab:NewButton("Visualizar Todos Values", function()
    local valuesFolder = plr:FindFirstChild("values")
    if valuesFolder then
        print("====== VALORES ATUAIS ======")
        for _,v in pairs(valuesFolder:GetChildren()) do
            print(v.Name.." = "..v.Value)
        end
        Notif:Notify("Check console (F9) para lista completa!", 4, "information")
    end
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

NPCGuiTab:NewToggle("EatFruit 🍏", false, function(state)
    local gui = npcsFolder:FindFirstChild("EatFruit")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("UsePerm 🎁", false, function(state)
    local gui = npcsFolder:FindFirstChild("UsePerm")
    if gui then gui.Enabled = state end
end)

local NPCSection2 = NPCGuiTab:NewSection("🗡️ Espadas / Acessórios")
NPCGuiTab:NewToggle("SwordDealer 🗡️", false, function(state)
    local gui = npcsFolder:FindFirstChild("SwordDealer")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("Accessories 🎭", false, function(state)
    local gui = npcsFolder:FindFirstChild("Accessories")
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

NPCGuiTab:NewToggle("DrachHaki 🐉", false, function(state)
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

NPCGuiTab:NewToggle("ScientistCook 🍳", false, function(state)
    local gui = npcsFolder:FindFirstChild("ScientistCook")
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

NPCGuiTab:NewToggle("MirrorWorldDealer 🪞", false, function(state)
    local gui = npcsFolder:FindFirstChild("MirrorWorldDealer")
    if gui then gui.Enabled = state end
end)

NPCGuiTab:NewToggle("IceDoor1 ❄️", false, function(state)
    local gui = npcsFolder:FindFirstChild("IceDoor1")
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

local function giveKen()
    local ken = plr:FindFirstChild("values") and plr.values:FindFirstChild("Ken")
    if ken then
        ken.Value = 1
        Notif:Notify("Ken ativado com sucesso!", 4, "success")
    else
        Notif:Notify("Ken não encontrado!", 4, "error")
    end
end

local function noCooldown()
    local fruit = nil
    for _,v in pairs(plr.Backpack:GetChildren()) do
        for _,f in pairs(game.ReplicatedStorage.Fruits:GetChildren()) do
            if v.Name == f.Name then fruit = f.Name end
        end
    end
    if not fruit then
        for _,v in pairs(plr.Character:GetChildren()) do
            for _,f in pairs(game.ReplicatedStorage.Fruits:GetChildren()) do
                if v.Name == f.Name then fruit = f.Name end
            end
        end
    end
    local skillFolder = game.ReplicatedStorage.FruitSkills:FindFirstChild(fruit)
    local keys = {"Z", "X", "C", "V"}
    if skillFolder then
        for _,k in pairs(keys) do
            local s = skillFolder:FindFirstChild(k)
            if s and s:FindFirstChild("Cooldown") then
                s.Cooldown.Value = 0
            end
        end
    end

    for _,sword in pairs(plr.Backpack:GetChildren()) do
        local skill = game.ReplicatedStorage.SwordSkills:FindFirstChild(sword.Name)
        if skill then
            for _,k in pairs(keys) do
                local s = skill:FindFirstChild(k)
                if s and s:FindFirstChild("Cooldown") then
                    s.Cooldown.Value = 0
                end
            end
        end
    end
    Notif:Notify("No Cooldown aplicado!", 4, "success")
end

local function allSwords()
    for _,v in pairs(plr.values:GetChildren()) do
        if v.Name:match("^Sword%d+") then
            v.Value = 1
        end
    end
    Notif:Notify("Todas swords ativadas!", 4, "success")
end

local function allAccs()
    for _,v in pairs(plr.values:GetChildren()) do
        if v.Name:match("^Acc%d+") then
            v.Value = 1
        end
    end
    Notif:Notify("Todos acessórios ativados!", 4, "success")
end

local function FruitNotifier()
    local sharkBoss = workspace.Islands.Island5.Bandits:FindFirstChild("Pillager [Lvl 500]")
    if not sharkBoss then return end

    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant.Name == sharkBoss.Name then
            sendAnnounce("🚨 [Event Notifier]: Um evento está ocorrendo no servidor! Evento: " .. descendant.Name, Color3.fromRGB(0, 255, 0), 2)

            local highlight = Instance.new("Highlight")
            highlight.Name = "BossHighlight"
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.FillColor = Color3.fromRGB(226, 0, 0)
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = descendant

            local billboard = Instance.new("BillboardGui")
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 150, 0, 20)
            billboard.MaxDistance = math.huge
            billboard.Adornee = descendant:FindFirstChild("Head") or descendant.PrimaryPart or descendant
            billboard.Parent = descendant

            local billboard2 = Instance.new("BillboardGui")
            billboard2.AlwaysOnTop = true
            billboard2.Size = UDim2.new(0, 150, 0, 20)
            billboard2.MaxDistance = math.huge
            billboard2.Adornee = descendant:FindFirstChild("Head") or descendant.PrimaryPart or descendant
            billboard2.Parent = descendant

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.TextScaled = true
            label.TextSize = 14
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextStrokeTransparency = 0.5
            label.Text = descendant.Name
            label.Parent = billboard

            local label2 = Instance.new("TextLabel")
            label2.Size = UDim2.new(1, 0, 1, 0)
            label2.Position = UDim2.new(0, 0, 0.5, 0)
            label2.BackgroundTransparency = 1
            label2.TextScaled = true
            label2.TextSize = 14
            label2.TextColor3 = Color3.fromRGB(0, 255, 0)
            label2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label2.TextStrokeTransparency = 0.5
            label2.Text = descendant:FindFirstChild("Humanoid").Health.Value
            label2.Parent = billboard2

            break
        end
    end
end

local function startNotifier()
    if notifierStarted then
        sendAnnounce("🚨 [Notifier]: Já está ativo!", Color3.fromRGB(255, 255, 0), 2)
        return
    end
    notifierStarted = true
    sendAnnounce("🚨 [Notifier]: Agora monitorando eventos!", Color3.fromRGB(0, 255, 0), 2)

    workspace.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "Shark [Lvl 2500]" then
            FruitNotifier()
        end
    end)

    FruitNotifier()
end

local function vomit()
    local plr = game.Players.LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local backpack = plr:WaitForChild("Backpack")
    local fruitFolder = rs:WaitForChild("RandomFruits")
    local character = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local function notify(txt)
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Lua God Turbo 🤮",
                Text = txt,
                Duration = 2
            })
        end)
    end

    local function isFruit(tool)
        for _, fruit in pairs(fruitFolder:GetChildren()) do
            if tool.Name == fruit.Name then
                return true
            end
        end
        return false
    end

    local function vomitaToolFAST(tool)
        humanoid:EquipTool(tool)
        tool.Parent = workspace
    end

    local function vomitaFrutasRapido()
        local count = 0
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and isFruit(tool) then
                vomitaToolFAST(tool)
                count += 1
            end
        end

        if count == 0 then
            notify("Sem frutas pra vomitar 💩")
        else
            notify("Vomitadas: " .. count .. " frutas 🤢")
        end
    end

    vomitaFrutasRapido()
end

local commands = {
    ["Ten kara ji e,-shin no kajitsu no ame o!"] = vomit,
    ["/disconnect all"] = crash,
    ["!g Ken"] = giveKen,
    ["!g NoCooldown"] = noCooldown,
    ["!g AllSwords"] = allSwords,
    ["!g AllAccs"] = allAccs,
    ["!notifier"] = startNotifier,
}

local CmdSection1 = CmdTab:NewSection("Comandos do Sistema")
CmdTab:NewLabel("Use o chat novo ou caixa abaixo 👇", "center")

CmdTab:NewTextbox("Executar Comando", "Digite o comando aqui...", "all", "medium", true, false, function(cmd)
    if commands[cmd] then
        pcall(commands[cmd])
    else
        Notif:Notify("❌ Comando inválido ou não encontrado!", 4, "error")
    end
end)

local CmdSection2 = CmdTab:NewSection("Lista de Comandos")
CmdTab:NewLabel("!g Ken - Ativa Haki da Observação", "left")
CmdTab:NewLabel("!g NoCooldown - Remove cooldown das skills", "left")
CmdTab:NewLabel("!g AllSwords - Ativa todas as espadas", "left")
CmdTab:NewLabel("!g AllAccs - Ativa todos os acessórios", "left")
CmdTab:NewLabel("!notifier - Ativa notificador de eventos", "left")
CmdTab:NewLabel("/disconnect all - Crash server (use com cuidado)", "left")

TextChatService.OnIncomingMessage = function(msg)
    local content = msg.Text
    if commands[content] then
        pcall(commands[content])
    end
end

local FinishedLoading = Notif:Notify("Hypex Revamp V3 - Sun Piece Carregado!", 4, "success")
