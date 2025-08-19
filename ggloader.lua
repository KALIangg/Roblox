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


local strikecolor = nil
MiscTab:ColorPicker{
    Name = "Flash Color",
    Style = Mercury.ColorPickerStyles.Legacy, -- Ou Gradient
    Callback = function(color)
        strikecolor = color
    end
}





local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

local flashActive = false
local flashConn = nil
local flashFolder = nil
local tool = nil
local playAnim = nil
local targetSpeed = 600
local currentSpeed = 16
local acceleration = 300
local defaultFOV = Camera.FieldOfView
local maxFOV = 110



MiscTab:Slider{
    Name = "Flash Speed",
    Default = targetSpeed,
    Min = 50,
    Max = 10000,
    Callback = function(value)
        targetSpeed = value
    end
}

-- Slider para controlar Flash Acceleration
MiscTab:Slider{
    Name = "Flash Acceleration",
    Default = acceleration,
    Min = 1,
    Max = 10000,
    Callback = function(value)
        acceleration = value
    end
}




MiscTab:Toggle{
    Name = "Deus Da Velocidade.",
    StartingState = false,
    Description = "A criatura mais rápida do mundo.",
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

            -- Animação Adidas
            local runAnim = Instance.new("Animation")
            runAnim.AnimationId = "rbxassetid://82598234841035"
            playAnim = hum:LoadAnimation(runAnim)
            playAnim.Priority = Enum.AnimationPriority.Action
            local animPlaying = false

            local lastPos = hrp.Position
            local distanceTraveled = 0
            local input = {W=false, A=false, S=false, D=false}
            local maxLightningLength = 20
            local maxRays = 6

            -- Captura inputs
            UIS.InputBegan:Connect(function(key, processed)
                if processed then return end
                if key.KeyCode == Enum.KeyCode.W then input.W = true end
                if key.KeyCode == Enum.KeyCode.A then input.A = true end
                if key.KeyCode == Enum.KeyCode.S then input.S = true end
                if key.KeyCode == Enum.KeyCode.D then input.D = true end
            end)
            UIS.InputEnded:Connect(function(key)
                if key.KeyCode == Enum.KeyCode.W then input.W = false end
                if key.KeyCode == Enum.KeyCode.A then input.A = false end
                if key.KeyCode == Enum.KeyCode.S then input.S = false end
                if key.KeyCode == Enum.KeyCode.D then input.D = false end
            end)

            local function createDynamicLightning(basePos, totalLength, segments)
                local prevPos = basePos
                for i = 1, segments do
                    local segmentLength = totalLength/segments
                    local offset = Vector3.new(
                        math.random(-segmentLength, segmentLength),
                        math.random(-segmentLength/2, segmentLength/2),
                        math.random(-segmentLength, segmentLength)
                    )
                    local endPos = prevPos - hrp.CFrame.LookVector * segmentLength + offset

                    local part = Instance.new("Part")
                    part.Anchored = true
                    part.CanCollide = false
                    part.Material = Enum.Material.Neon
                    part.BrickColor = BrickColor.new(strikecolor)
                    part.Size = Vector3.new(
                        0.09 + math.random()*0.1,
                        0.09 + math.random()*0.1,
                        (prevPos - endPos).Magnitude
                    )
                    part.CFrame = CFrame.new((prevPos+endPos)/2, endPos)
                    part.Parent = flashFolder

                    local tween = TweenService:Create(part, TweenInfo.new(0.1 + math.random()*0.05, Enum.EasingStyle.Linear), {Transparency = 1})
                    tween:Play()
                    tween.Completed:Connect(function() part:Destroy() end)

                    prevPos = endPos
                end
            end

            -- RenderStepped: movimento, raios, animação, FOV
            flashConn = RunService.RenderStepped:Connect(function(dt)
                -- Aceleração gradual independente da tecla W
                if input.W or input.A or input.S or input.D then
                    currentSpeed = math.min(currentSpeed + acceleration*dt, targetSpeed)
                else
                    currentSpeed = math.max(currentSpeed - acceleration*dt*2, 0)
                end
                hum.WalkSpeed = currentSpeed
                Camera.FieldOfView = defaultFOV + (currentSpeed/targetSpeed)*(maxFOV - defaultFOV)

                -- Só animação e raios se estiver pressionando W
                if input.W or input.A or input.S or input.D then
                    -- Animação
                    if currentSpeed > 0.1 then
                        if not animPlaying then
                            playAnim:Play()
                            animPlaying = true
                        end
                    else
                        if animPlaying then
                            playAnim:Stop()
                            animPlaying = false
                        end
                    end

                    -- Raios
                    local delta = (hrp.Position - lastPos).Magnitude
                    distanceTraveled = distanceTraveled + delta
                    if delta > 0.2 then
                        local numRays = math.clamp(math.floor(currentSpeed/100), 1, maxRays)
                        local lightningLength = math.clamp(distanceTraveled, 5, maxLightningLength)
                        for r = 1, numRays do
                            createDynamicLightning(hrp.Position + hrp.CFrame.LookVector*2, lightningLength, math.random(4,8))
                        end
                    end
                    lastPos = hrp.Position
                    if currentSpeed < 1 then distanceTraveled = 0 end
                else
                    -- Se W não estiver pressionado, para animação
                    if animPlaying then
                        playAnim:Stop()
                        animPlaying = false
                    end
                end
            end)

            -- TP Tool
            tool = Instance.new("Tool")
            tool.Name = "Força De Aceleração"
            tool.RequiresHandle = false
            tool.CanBeDropped = false
            tool.Parent = LocalPlayer.Backpack

            tool.Activated:Connect(function()
                local mouse = LocalPlayer:GetMouse()
                local target = mouse.Hit.Position
                local tween = TweenService:Create(hrp, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(target + Vector3.new(0,5,0))})
                tween:Play()

                local part = Instance.new("Part")
                part.Size = Vector3.new(2,2,2)
                part.Anchored = true
                part.CanCollide = false
                part.Material = Enum.Material.Neon
                part.BrickColor = BrickColor.new(strikecolor)
                part.CFrame = hrp.CFrame
                part.Parent = workspace
                game.Debris:AddItem(part,0.2)
            end)

            GUI:Notification{
                Title = "Flash",
                Text = "Você agora corre como o Flash! TP Tool adicionada.",
                Duration = 4
            }
        else
            flashActive = false
            hum.WalkSpeed = 16
            Camera.FieldOfView = defaultFOV
            if flashConn then flashConn:Disconnect() end
            if flashFolder then flashFolder:Destroy() end
            if tool and tool.Parent then tool:Destroy() end
            if playAnim and playAnim.IsPlaying then playAnim:Stop() end
        end
    end
}





local phaseActive = false
local phaseConn = nil

MiscTab:Toggle{
    Name = "Phase Flash",
    StartingState = false,
    Description = "Tremor lateral rápido com sombra, sem travar movimento.",
    Callback = function(state)
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if state then
            phaseActive = true
            local t = 0

            phaseConn = RunService.RenderStepped:Connect(function(dt)
                t = t + dt * 300 -- frequência bem alta para efeito de sombra
                local offsetX = math.sin(t) * 0.3
                local offsetZ = math.cos(t*1.5) * 0.3

                -- Aplica offsets relativos ao CFrame atual, não bloqueando movimentos
                hrp.CFrame = hrp.CFrame * CFrame.new(offsetX, 0, offsetZ)
            end)
        else
            phaseActive = false
            if phaseConn then
                phaseConn:Disconnect()
                phaseConn = nil
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
