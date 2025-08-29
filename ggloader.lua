-- Load Mercury Library
local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

-- Create GUI
local GUI = Mercury:Create{
    Name = "GGZERA MENU | Injetor",
    Size = UDim2.fromOffset(800, 600),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/GomesDev/ggzeraloader"
}

-- Tabs
local LoaderTab = GUI:Tab{
    Name = "Loader",
    Icon = "rbxassetid://131223257011550"
}

local MiscTab = GUI:Tab{
    Name = "Misc",
    Icon = "rbxassetid://12120687742"
}

-- ========== LOADER TAB COMPONENTS ==========

local MENU = nil
LoaderTab:Dropdown{
    Name = "Selecionar Menu",
    StartingText = "Selecione um menu pra carregar...",
    Items = {"GGZERA Menu RP", "GGZERA Admin", "GGZERA FPS"},
    Callback = function(item)
        print("Menu Selecionado:", item)
        MENU = item
    end
}



-- Load Button integrado com Prompt
LoaderTab:Button{
    Name = "Load",
    Description = "Carrega o menu selecionado na Lista.",
    Callback = function()
        GUI:Prompt{
            Followup = false,
            Title = "GGZERA Injetor",
            Text = "Deseja carregar este menu?",
            Buttons = {
                Yes = function()
                    if MENU == "GGZERA Menu RP" then
                        print("🛡️ Carregando: GGZERA RP")
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox/refs/heads/main/ggzeramenu.lua"))()
                    elseif MENU == "GGZERA Admin" then
                        print("🛡️ Carregando: GGZERA Admin")
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox/refs/heads/main/ggzeraadmin.lua"))()
                    elseif MENU == "GGZERA FPS" then
                        print("🛡️ Carregando: GGZERA FPS")
                        warn("Não tem GGZERA FPS ainda.")
                    end

                    return true
                end,
                No = function()
                    print("Cancelado - Injeção.")
                    return false
                end
            }
        }
    end
}



LoaderTab:Button{
    Name = "Verify Link",
    Description = "Verifica se o script está funcionando.",
    Callback = function()
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/KALIangg/Roblox/refs/heads/main/ggzeramenu.lua")
        end)

        if success then
            GUI:Notification{
                Title = "Success",
                Text = "Menu funcionando corretamente!",
                Duration = 3
            }
        else
            GUI:Notification{
                Title = "Error",
                Text = "Falha ao acessar menu: " .. tostring(result),
                Duration = 5
            }
        end
    end
}


------- INJETOR --------

local scriptload = nil

-- Textbox para inserir o código Lua
LoaderTab:Textbox{
    Name = "Injetor",
    Callback = function(text)
        scriptload = text
        print("Script definido!")
    end
}

-- Botão para executar o script
LoaderTab:Button{
    Name = "Execute",
    Description = "Executa o script inserido no jogo.",
    Callback = function()
        if scriptload and scriptload ~= "" then
            local success, result = pcall(function()
                loadstring(scriptload)()
            end)

            if success then
                GUI:Notification{
                    Title = "Sucesso",
                    Text = "Script executado!",
                    Duration = 3
                }
            else
                GUI:Notification{
                    Title = "Erro",
                    Text = "Falha ao executar script: " .. tostring(result),
                    Duration = 5
                }
            end
        else
            GUI:Notification{
                Title = "Erro",
                Text = "Nenhum script inserido!",
                Duration = 3
            }
        end
    end
}

--------------- MISC TAB ------------

local TeleportService = game:GetService("TeleportService")
local LocalPlayer = game.Players.LocalPlayer

-- Rejoin
MiscTab:Button{
    Name = "Rejoin",
    Description = "Reentra no mesmo servidor.",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        GUI:Notification{
            Title = "Rejoin",
            Text = "Entrando no mesmo servidor...",
            Duration = 3
        }
    end
}

-- Reset Stats
MiscTab:Button{
    Name = "Reset Stats",
    Description = "Reseta WalkSpeed, JumpPower e HipHeight.",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                hum.HipHeight = 2
                GUI:Notification{
                    Title = "Reset Stats",
                    Text = "WalkSpeed, JumpPower e HipHeight resetados.",
                    Duration = 3
                }
            end
        end
    end
}

-- Toggle GUI
MiscTab:Button{
    Name = "Toggle GUI",
    Description = "Ativa ou desativa a interface do jogo.",
    Callback = function()
        for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                gui.Enabled = not gui.Enabled
            end
        end
        GUI:Notification{
            Title = "Toggle GUI",
            Text = "Todas as GUIs foram alternadas.",
            Duration = 3
        }
    end
}

-- Change Character Color
MiscTab:Button{
    Name = "Char Color",
    Description = "Muda a cor de todas as partes do personagem.",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.Random()
                end
            end
            GUI:Notification{
                Title = "Char Color",
                Text = "Cor do personagem alterada.",
                Duration = 3
            }
        end
    end
}

-- Teleport to Spawn
MiscTab:Button{
    Name = "Spawn",
    Description = "Teleporta o personagem para o spawn.",
    Callback = function()
        local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation")
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if spawn and hrp then
            hrp.CFrame = spawn.CFrame + Vector3.new(0,5,0)
            GUI:Notification{
                Title = "Spawn",
                Text = "Personagem teleportado para spawn.",
                Duration = 3
            }
        end
    end
}

-- Notify Example
MiscTab:Button{
    Name = "Notify",
    Description = "Mostra uma notificação personalizada.",
    Callback = function()
        GUI:Notification{
            Title = "Alerta",
            Text = "Esta é uma notificação de teste.",
            Duration = 3
        }
    end
}

-- Prompt Example
MiscTab:Button{
    Name = "Prompt",
    Description = "Mostra um prompt de confirmação.",
    Callback = function()
        GUI:Prompt{
            Followup = false,
            Title = "Prompt Test",
            Text = "Deseja continuar?",
            Buttons = {
                Yes = function() print("Confirmado!") end,
                No = function() print("Cancelado!") end
            }
        }
    end
}

-- Toggle Fly Tool
MiscTab:Button{
    Name = "Fly Tool",
    Description = "Adiciona uma ferramenta de voo temporária.",
    Callback = function()
        local tool = Instance.new("Tool")
        tool.Name = "FlyTool"
        tool.RequiresHandle = false
        tool.Parent = LocalPlayer.Backpack
        GUI:Notification{
            Title = "Fly Tool",
            Text = "Ferramenta de voo adicionada ao backpack.",
            Duration = 3
        }
    end
}

-- Quick Heal
MiscTab:Button{
    Name = "Heal",
    Description = "Restaura a vida do personagem.",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                GUI:Notification{
                    Title = "Heal",
                    Text = "Vida restaurada.",
                    Duration = 2
                }
            end
        end
    end
}

-- Max Jump
MiscTab:Button{
    Name = "Max Jump",
    Description = "Aumenta o poder de pulo temporariamente.",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = 150
                GUI:Notification{
                    Title = "Max Jump",
                    Text = "JumpPower aumentado para 150.",
                    Duration = 2
                }
            end
        end
    end
}

-- Max Speed
MiscTab:Button{
    Name = "Max Speed",
    Description = "Aumenta a velocidade temporariamente.",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 100
                GUI:Notification{
                    Title = "Max Speed",
                    Text = "WalkSpeed aumentado para 100.",
                    Duration = 2
                }
            end
        end
    end
}


local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local flashActive = false
local flashConn
local flashFolder
local inputBeganConn
local inputEndedConn
local phaseTool

local targetSpeed = 600
local currentSpeed = 50
local defaultFOV = Camera.FieldOfView
local maxFOV = 110
local strikecolor = Color3.fromRGB(255,0,0)

local boostActive = false
local boostDuration = 6.5
local boostSpeedExtra = 500
local boostAnimId = "rbxassetid://73220746306116"
local breakSoundId = "rbxassetid://18950094486"

local keysHeld = {Q=false, E=false}
local inputMovement = {W=false, A=false, S=false, D=false}
local keysDown = {W=false, A=false, S=false, D=false}

local newAnimations = {
    Idle = 106169111259587,
    Run = 91648079587853
}
local idleTrack, runTrack

local noclipConnection
local noclipEnabled = false
local phaseAnim
local phaseActive = false

local savedAnimateClone

-- UI
MiscTab:ColorPicker{
    Name = "Flash Color",
    Style = Mercury.ColorPickerStyles.Legacy,
    Callback = function(color)
        strikecolor = color
    end
}
MiscTab:Slider{
    Name = "Flash Speed",
    Default = targetSpeed,
    Min = 50,
    Max = 10000,
    Callback = function(value)
        targetSpeed = value
        currentSpeed = math.min(currentSpeed, targetSpeed)
    end
}

-- Funções
local function smoothFOV(target)
    TweenService:Create(Camera, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {FieldOfView = target}):Play()
end

local function createDynamicLightning(basePos, totalLength, segments)
    local prevPos = basePos
    for i = 1, segments do
        local segmentLength = totalLength/segments
        local offset = Vector3.new(
            math.random(-segmentLength, segmentLength),
            math.random(-segmentLength/2, segmentLength/2),
            math.random(-segmentLength, segmentLength)
        )
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local endPos = prevPos - char.HumanoidRootPart.CFrame.LookVector * segmentLength + offset
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Color = strikecolor
        part.Size = Vector3.new(0.09 + math.random()*0.1, 0.09 + math.random()*0.1, (prevPos - endPos).Magnitude)
        part.CFrame = CFrame.new((prevPos+endPos)/2, endPos)
        part.Parent = flashFolder
        local tween = TweenService:Create(part, TweenInfo.new(0.1 + math.random()*0.05, Enum.EasingStyle.Linear), {Transparency = 1})
        tween:Play()
        tween.Completed:Connect(function() part:Destroy() end)
        prevPos = endPos
    end
end

local function loadAnimation(humanoid, animId, priority)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animId
    local track = humanoid:LoadAnimation(anim)
    track.Priority = priority
    return track
end

local function updateMovement()
    if not idleTrack or not runTrack then return end
    local anyKey = keysDown.W or keysDown.A or keysDown.S or keysDown.D
    if anyKey and not runTrack.IsPlaying then
        idleTrack:Stop()
        runTrack:Play()
    elseif not anyKey and not idleTrack.IsPlaying then
        runTrack:Stop()
        idleTrack:Play()
    end
end

local function noclip()
    if noclipEnabled then return end
    noclipEnabled = true
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    noclipConnection = RunService.Stepped:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function clip()
    if not noclipEnabled then return end
    noclipEnabled = false
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function startPhase(hum)
    if phaseAnim and phaseAnim.IsPlaying then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://82363856064263"
    phaseAnim = hum:LoadAnimation(anim)
    phaseAnim.Priority = Enum.AnimationPriority.Action
    phaseAnim:Play()
    phaseActive = true
    noclip()
end

local function stopPhase()
    if phaseAnim and phaseAnim.IsPlaying then
        phaseAnim:Stop()
    end
    phaseActive = false
    clip()
end

local function bindInputs(hum, hrp)
    if inputBeganConn then inputBeganConn:Disconnect() end
    if inputEndedConn then inputEndedConn:Disconnect() end

    inputBeganConn = UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        if keysDown[input.KeyCode.Name] ~= nil then
            keysDown[input.KeyCode.Name] = true
            updateMovement()
        end
        if inputMovement[input.KeyCode.Name] ~= nil then
            inputMovement[input.KeyCode.Name] = true
        end
        if input.KeyCode == Enum.KeyCode.Q then keysHeld.Q = true end
        if input.KeyCode == Enum.KeyCode.E then keysHeld.E = true end

        if input.KeyCode == Enum.KeyCode.LeftShift and not boostActive and flashActive then
            boostActive = true
            local prevInput = {}
            for k,v in pairs(inputMovement) do prevInput[k] = v; inputMovement[k] = false end
            if runTrack and runTrack.IsPlaying then runTrack:Stop() end
            if idleTrack and idleTrack.IsPlaying then idleTrack:Stop() end
            hum.WalkSpeed = 0
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)

            local boostAnim = Instance.new("Animation")
            boostAnim.AnimationId = boostAnimId
            local boostTrack = hum:LoadAnimation(boostAnim)
            boostTrack.Priority = Enum.AnimationPriority.Action
            boostTrack:Play()

            task.delay(boostDuration, function()
                if boostTrack.IsPlaying then boostTrack:Stop() end
                currentSpeed = targetSpeed + boostSpeedExtra
                hum.WalkSpeed = currentSpeed
                local sound = Instance.new("Sound")
                sound.SoundId = breakSoundId
                sound.Volume = 1
                sound.Parent = hrp
                sound:Play()
                Debris:AddItem(sound, 5)
                for k,v in pairs(prevInput) do inputMovement[k] = v end
                boostActive = false
                updateMovement()
            end)
        end

        if input.KeyCode == Enum.KeyCode.T then
            if phaseActive then stopPhase() else startPhase(hum) end
        end
    end)

    inputEndedConn = UIS.InputEnded:Connect(function(input, gpe)
        if keysDown[input.KeyCode.Name] ~= nil then
            keysDown[input.KeyCode.Name] = false
            updateMovement()
        end
        if inputMovement[input.KeyCode.Name] ~= nil then
            inputMovement[input.KeyCode.Name] = false
        end
        if input.KeyCode == Enum.KeyCode.Q then keysHeld.Q = false end
        if input.KeyCode == Enum.KeyCode.E then keysHeld.E = false end
    end)
end

MiscTab:Toggle{
    Name = "Deus Da Velocidade.",
    StartingState = false,
    Description = "Ativa os poderes do Flash.",
    Callback = function(state)
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if state then
            flashActive = true
            flashFolder = Instance.new("Folder")
            flashFolder.Name = "FlashEffects"
            flashFolder.Parent = workspace

            local oldAnimate = char:FindFirstChild("Animate")
            if oldAnimate then
                savedAnimateClone = oldAnimate:Clone()
                oldAnimate:Destroy()
            else
                savedAnimateClone = nil
            end

            for _, t in pairs(hum:GetPlayingAnimationTracks()) do
                t:Stop()
            end

            idleTrack = loadAnimation(hum, newAnimations.Idle, Enum.AnimationPriority.Movement)
            runTrack  = loadAnimation(hum, newAnimations.Run,  Enum.AnimationPriority.Movement)
            idleTrack:Play()

            currentSpeed = math.max(16, currentSpeed)
            bindInputs(hum, hrp)

            if phaseTool then phaseTool:Destroy() end
            phaseTool = Instance.new("Tool")
            phaseTool.Name = "Phase"
            phaseTool.RequiresHandle = false
            phaseTool.Parent = LocalPlayer.Backpack
            phaseTool.Equipped:Connect(function() startPhase(hum) end)
            phaseTool.Unequipped:Connect(stopPhase)

            local lastPos = hrp.Position
            local distanceTraveled = 0

            flashConn = RunService.RenderStepped:Connect(function(dt)
                if keysHeld.Q then currentSpeed = math.max(16, currentSpeed - 400*dt) end
                if keysHeld.E then currentSpeed = math.min(targetSpeed, currentSpeed + 400*dt) end

                if boostActive then
                    hum.WalkSpeed = 0
                    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    smoothFOV(defaultFOV)
                    return
                end

                if inputMovement.W or inputMovement.A or inputMovement.S or inputMovement.D then
                    hum.WalkSpeed = currentSpeed
                    smoothFOV(maxFOV)
                    local delta = (hrp.Position - lastPos).Magnitude
                    distanceTraveled = distanceTraveled + delta
                    if delta > 0.2 then
                        local numRays = math.clamp(math.floor(currentSpeed/100), 1, 4)
                        local lightningLength = math.clamp(distanceTraveled, 5, 20)
                        for _ = 1, numRays do
                            createDynamicLightning(hrp.Position + hrp.CFrame.LookVector*2, lightningLength, math.random(4,8))
                        end
                    end
                    lastPos = hrp.Position
                else
                    hum.WalkSpeed = 16
                    local vel = hrp.AssemblyLinearVelocity
                    hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
                    smoothFOV(defaultFOV)
                end
            end)
        else
            flashActive = false
            if flashConn then flashConn:Disconnect() flashConn = nil end
            if inputBeganConn then inputBeganConn:Disconnect() inputBeganConn = nil end
            if inputEndedConn then inputEndedConn:Disconnect() inputEndedConn = nil end
            if flashFolder then flashFolder:Destroy() flashFolder = nil end
            if idleTrack and idleTrack.IsPlaying then idleTrack:Stop() end
            if runTrack and runTrack.IsPlaying then runTrack:Stop() end
            stopPhase()
            if phaseTool then phaseTool:Destroy() phaseTool = nil end

            local hum2 = char:FindFirstChildOfClass("Humanoid")
            if hum2 then
                hum2.WalkSpeed = 16
                smoothFOV(defaultFOV)
            end

            if savedAnimateClone and not char:FindFirstChild("Animate") then
                savedAnimateClone:Clone().Parent = char
            end
        end
    end
}



























-- ========== MISC TAB COMPONENTS ==========

GUI:Notification{
    Title = "GGZERA Injetor Loaded!",
    Text = "Zaralho total!",
    Duration = 3,
    Callback = function() print("Notification closed") end
}

-- Credit Example
GUI:Credit{
    Name = "Bernardo Gomes",
    Description = "Criador do GGZERA MENU e GGZERA Injetor.",
    V3rm = "...",
    Discord = "No discord bruh"
}
