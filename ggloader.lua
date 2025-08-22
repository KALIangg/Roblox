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
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

-- Variáveis principais
local flashActive = false
local flashConn
local flashFolder
local playAnim
local attachParts = {}
local targetSpeed = 600 -- velocidade máxima, controlada pelo slider
local currentSpeed = 50 -- velocidade atual, controlada por Q/E e boost
local defaultFOV = Camera.FieldOfView
local maxFOV = 110
local strikecolor = Color3.fromRGB(255,0,0)

-- Boost
local boostActive = false
local boostDuration = 6.5
local boostSpeedExtra = 500
local boostAnimId = "rbxassetid://73220746306116"
local breakSoundId = "rbxassetid://224339201"

-- Teclas Q/E seguráveis
local keysHeld = {Q=false, E=false}
local inputMovement = {W=false, A=false, S=false, D=false}

--== UI ==
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

--== Funções ==
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
        local endPos = prevPos - LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * segmentLength + offset

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

--== TOGGLE FLASH ==
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
            flashFolder = Instance.new("Folder", workspace)
            flashFolder.Name = "FlashEffects"

            -- Animação de corrida
            local runAnim = Instance.new("Animation")
            runAnim.AnimationId = "rbxassetid://91648079587853"
            playAnim = hum:LoadAnimation(runAnim)

            attachParts = {}
            for _,p in ipairs({"UpperTorso","Left Arm","Right Arm","Left Leg","Right Leg"}) do
                local part = char:FindFirstChild(p)
                if part then table.insert(attachParts, part) end
            end

            local lastPos = hrp.Position
            local distanceTraveled = 0
            currentSpeed = math.max(16, currentSpeed)

            --== Input de movimento ==
            UIS.InputBegan:Connect(function(key, processed)
                if processed then return end
                if inputMovement[key.KeyCode.Name] ~= nil then inputMovement[key.KeyCode.Name] = true end
                if key.KeyCode == Enum.KeyCode.Q then keysHeld.Q = true end
                if key.KeyCode == Enum.KeyCode.E then keysHeld.E = true end

                --== Boost ==
                if key.KeyCode == Enum.KeyCode.LeftShift and not boostActive and flashActive then
                    boostActive = true

                    -- Congelar player
                    hum.WalkSpeed = 0
                    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)

                    -- Bloquear input temporariamente
                    local prevInput = {}
                    for k,v in pairs(inputMovement) do prevInput[k] = v; inputMovement[k] = false end

                    -- Animação de preparação
                    local boostAnim = Instance.new("Animation")
                    boostAnim.AnimationId = boostAnimId
                    local boostTrack = hum:LoadAnimation(boostAnim)
                    boostTrack:Play()

                    spawn(function()
                        wait(boostDuration)
                        boostTrack:Stop()

                        -- Velocidade atual recebe target + extra
                        currentSpeed = targetSpeed + boostSpeedExtra
                        hum.WalkSpeed = currentSpeed

                        -- Som da barreira do som
                        local sound = Instance.new("Sound", hrp)
                        sound.SoundId = breakSoundId
                        sound.Volume = 1
                        sound:Play()
                        Debris:AddItem(sound, 5)

                        -- Reativar input
                        for k,v in pairs(prevInput) do inputMovement[k] = v end
                        boostActive = false
                    end)
                end
            end)

            UIS.InputEnded:Connect(function(key, processed)
                if inputMovement[key.KeyCode.Name] ~= nil then inputMovement[key.KeyCode.Name] = false end
                if key.KeyCode == Enum.KeyCode.Q then keysHeld.Q = false end
                if key.KeyCode == Enum.KeyCode.E then keysHeld.E = false end
            end)

            --== Tool Phase ==
            local toolPhase = Instance.new("Tool", LocalPlayer.Backpack)
            toolPhase.Name = "Phase"
            toolPhase.RequiresHandle = false
            local phaseAnim
            local phaseActive = false

            local function startPhase()
                if phaseAnim and phaseAnim.IsPlaying then return end
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://82363856064263"
                phaseAnim = hum:LoadAnimation(anim)
                phaseAnim:Play()
                phaseActive = true
            end

            local function stopPhase()
                if phaseAnim and phaseAnim.IsPlaying then phaseAnim:Stop() end
                phaseActive = false
            end

            toolPhase.Equipped:Connect(startPhase)
            toolPhase.Unequipped:Connect(stopPhase)

            UIS.InputBegan:Connect(function(key, processed)
                if key.KeyCode == Enum.KeyCode.T then
                    if phaseActive then stopPhase() else startPhase() end
                end
            end)

            --== Loop principal ==
            flashConn = RunService.RenderStepped:Connect(function(dt)
                -- Ajuste de currentSpeed via Q/E com limite mínimo de 16
                if keysHeld.Q then currentSpeed = math.max(16, currentSpeed - 400*dt) end
                if keysHeld.E then currentSpeed = math.min(targetSpeed, currentSpeed + 400*dt) end

                if boostActive then
                    hum.WalkSpeed = 0
                    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    smoothFOV(defaultFOV)
                    if playAnim.IsPlaying then playAnim:Stop() end
                    return
                end

                -- Movimento
                if inputMovement.W or inputMovement.A or inputMovement.S or inputMovement.D then
                    hum.WalkSpeed = currentSpeed
                    smoothFOV(maxFOV)
                    if not playAnim.IsPlaying then playAnim:Play() end

                    local delta = (hrp.Position - lastPos).Magnitude
                    distanceTraveled = distanceTraveled + delta
                    if delta > 0.2 then
                        local numRays = math.clamp(math.floor(currentSpeed/100), 1, 4)
                        local lightningLength = math.clamp(distanceTraveled, 5, 20)
                        for r = 1, numRays do
                            createDynamicLightning(hrp.Position + hrp.CFrame.LookVector*2, lightningLength, math.random(4,8))
                        end
                    end
                    lastPos = hrp.Position
                else
                    hum.WalkSpeed = 16
                    local vel = hrp.AssemblyLinearVelocity
                    hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
                    smoothFOV(defaultFOV)
                    if playAnim.IsPlaying then playAnim:Stop() end
                end
            end)

        else
            -- Desativar Flash
            flashActive = false
            hum.WalkSpeed = 16
            smoothFOV(defaultFOV)
            if flashConn then flashConn:Disconnect() end
            if flashFolder then flashFolder:Destroy() end
            if playAnim and playAnim.IsPlaying then playAnim:Stop() end
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
