--[[
    BLOX FRUITS ULTIMATE v10.0 - LOADER
    Professional | Stable | Anti-Error
    Compatible: Delta, Fluxus, Hydrogen
    
    INSTRUÇÕES:
    1. Coloque main.lua no GitHub
    2. Substitua URL abaixo pela sua URL RAW
    3. Execute este loader
]]

-- Anti-Double Load
if getgenv().BloxUltLoaded then return end
getgenv().BloxUltLoaded = true

-- Wait for game
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

-- Verify Blox Fruits
local placeId = game.PlaceId
local isBlox = (placeId == 2753915549 or placeId == 4442272183 or placeId == 7449423635)
if not isBlox then
    pcall(function()
        local n = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name or ""
        isBlox = n:lower():find("blox") and n:lower():find("fruit")
    end)
end
if not isBlox then
    warn("[Loader] Only works on Blox Fruits!")
    getgenv().BloxUltLoaded = nil
    return
end

-- Notify
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "💎 Loading...",
        Text = "Blox Fruits Ultimate v10.0",
        Duration = 3
    })
end)

-- Load Script
local url = "https://raw.githubusercontent.com/Gui0494/BloxUltimateScript/main/main.lua"

local success, err = pcall(function()
    local script = game:HttpGet(url, true)
    if script and #script > 100 then
        loadstring(script)()
    else
        error("Invalid response")
    end
end)

if not success then
    warn("[Loader] Failed: " .. tostring(err))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ Error",
            Text = "Failed to load. Check URL!",
            Duration = 5
        })
    end)
    getgenv().BloxUltLoaded = nil
end
