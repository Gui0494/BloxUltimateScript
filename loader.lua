--[[
    BLOX FRUITS ULTIMATE v10.0 - LOADER
    Professional | Stable | Anti-Error
    Compatible: Delta, Fluxus, Hydrogen
    
    INSTRUÇÕES:
    1. Certifique-se que o main.lua está no seu GitHub
    2. O link abaixo já está configurado (substitua se mudar o user/repo)
]]

-- 1. Anti-Double Load
if getgenv().BloxUltLoaded then 
    warn("[Loader] Script is already running!")
    return 
end
getgenv().BloxUltLoaded = true

-- 2. Wait for Game
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1) -- Pequeno delay extra para garantir que a UI carregou

-- 3. Verify Blox Fruits
local placeId = game.PlaceId
local isBlox = (placeId == 2753915549 or placeId == 4442272183 or placeId == 7449423635)

if not isBlox then
    -- Fallback check (Nome do jogo)
    pcall(function()
        local n = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name or ""
        isBlox = n:lower():find("blox") and n:lower():find("fruit")
    end)
end

if not isBlox then
    warn("[Loader] Error: This script only works on Blox Fruits!")
    getgenv().BloxUltLoaded = nil
    return
end

-- 4. Notification (Safe)
task.spawn(function()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "💎 Starting...",
            Text = "Blox Fruits Ultimate v10.0",
            Duration = 3,
            Icon = "rbxassetid://4483345998"
        })
    end)
end)

-- 5. Load Script (Anti-Cache & Error Handling)
-- Adicionei '?t=' para evitar que o executor use uma versão antiga salva em cache
local url = "https://raw.githubusercontent.com/Gui0494/BloxUltimateScript/main/main.lua"

local success, err = pcall(function()
    -- Download
    local scriptContent = game:HttpGet(url .. "?t=" .. tostring(tick()), true)
    
    if not scriptContent or #scriptContent < 10 then
        error("Empty response from GitHub. Check URL/Privacy settings.")
    end

    -- Compile
    local func, syntaxErr = loadstring(scriptContent)
    if not func then
        error("Syntax Error in main.lua: " .. tostring(syntaxErr))
    end

    -- Execute
    func()
end)

-- 6. Error Report
if not success then
    getgenv().BloxUltLoaded = nil -- Reseta para permitir tentar de novo
    warn("[Loader] Critical Error: " .. tostring(err))
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ Script Error",
            Text = "Check F9 Console for details",
            Duration = 5
        })
    end)
end
