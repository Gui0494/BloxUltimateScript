--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                    BLOX FRUITS ULTIMATE - LOADER v3.0                        ║
    ║                     Professional Grade | No Key Required                      ║
    ║                              FIXED & STABLE                                  ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════════════════════════
-- ANTI-DOUBLE LOAD
-- ════════════════════════════════════════════════════════════════════════════════
if getgenv().BloxUltimateLoaded then
    warn("[Loader] Script already loaded!")
    return
end

-- ════════════════════════════════════════════════════════════════════════════════
-- WAIT FOR GAME
-- ════════════════════════════════════════════════════════════════════════════════
if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(1)

-- ════════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")

local CoreGui = nil
pcall(function()
    CoreGui = game:GetService("CoreGui")
end)

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ════════════════════════════════════════════════════════════════════════════════
local CONFIG = {
    -- URLs para carregar o script (sua URL do GitHub)
    SCRIPT_URLS = {
        "https://raw.githubusercontent.com/Gui0494/BloxUltimateScript/main/main.lua",
        "https://raw.githubusercontent.com/Gui0494/BloxUltimateScript/refs/heads/main/main.lua",
    },
    
    -- Place IDs válidos do Blox Fruits
    VALID_PLACE_IDS = {
        2753915549,  -- Blox Fruits Main
        4442272183,  -- Blox Fruits Private Server
        7449423635,  -- Blox Fruits Test
    },
}

-- ════════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Blox Ultimate",
            Text = text or "",
            Duration = duration or 5
        })
    end)
end

local function IsBloxFruits()
    local placeId = game.PlaceId
    
    -- Verifica por Place ID
    for _, validId in ipairs(CONFIG.VALID_PLACE_IDS) do
        if placeId == validId then
            return true
        end
    end
    
    -- Verifica pelo nome do jogo
    local success, result = pcall(function()
        local info = MarketplaceService:GetProductInfo(placeId)
        if info and info.Name then
            local name = info.Name:lower()
            return name:find("blox") and name:find("fruit")
        end
        return false
    end)
    
    return success and result
end

-- ════════════════════════════════════════════════════════════════════════════════
-- LOADING UI
-- ════════════════════════════════════════════════════════════════════════════════
local function CreateLoadingUI()
    pcall(function()
        if CoreGui and CoreGui:FindFirstChild("BloxUltimateLoader") then
            CoreGui.BloxUltimateLoader:Destroy()
        end
    end)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxUltimateLoader"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    
    local parentSuccess = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    
    if not parentSuccess then
        pcall(function()
            ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
        end)
    end
    
    if not ScreenGui.Parent then
        return nil
    end
    
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0.3
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui
    
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, 350, 0, 160)
    Container.Position = UDim2.new(0.5, -175, 0.5, -80)
    Container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Container.BorderSizePixel = 0
    Container.Parent = Background
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Container
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 100, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Container
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "💎 BLOX FRUITS ULTIMATE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Container
    
    local Version = Instance.new("TextLabel")
    Version.Size = UDim2.new(1, 0, 0, 18)
    Version.Position = UDim2.new(0, 0, 0, 48)
    Version.BackgroundTransparency = 1
    Version.Text = "v10.0 - Ultimate Edition"
    Version.TextColor3 = Color3.fromRGB(150, 150, 255)
    Version.TextSize = 12
    Version.Font = Enum.Font.Gotham
    Version.Parent = Container
    
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -30, 0, 22)
    Status.Position = UDim2.new(0, 15, 0, 75)
    Status.BackgroundTransparency = 1
    Status.Text = "Initializing..."
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 13
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Container
    
    local ProgressBG = Instance.new("Frame")
    ProgressBG.Size = UDim2.new(1, -30, 0, 6)
    ProgressBG.Position = UDim2.new(0, 15, 0, 102)
    ProgressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    ProgressBG.BorderSizePixel = 0
    ProgressBG.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 3)
    ProgressCorner.Parent = ProgressBG
    
    local ProgressFill = Instance.new("Frame")
    ProgressFill.Name = "Fill"
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBG
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = ProgressFill
    
    local Percentage = Instance.new("TextLabel")
    Percentage.Name = "Percentage"
    Percentage.Size = UDim2.new(1, -30, 0, 18)
    Percentage.Position = UDim2.new(0, 15, 0, 112)
    Percentage.BackgroundTransparency = 1
    Percentage.Text = "0%"
    Percentage.TextColor3 = Color3.fromRGB(150, 150, 150)
    Percentage.TextSize = 11
    Percentage.Font = Enum.Font.Gotham
    Percentage.TextXAlignment = Enum.TextXAlignment.Right
    Percentage.Parent = Container
    
    local Credits = Instance.new("TextLabel")
    Credits.Size = UDim2.new(1, 0, 0, 18)
    Credits.Position = UDim2.new(0, 0, 1, -20)
    Credits.BackgroundTransparency = 1
    Credits.Text = "Free Script • No Key Required"
    Credits.TextColor3 = Color3.fromRGB(80, 80, 80)
    Credits.TextSize = 10
    Credits.Font = Enum.Font.Gotham
    Credits.Parent = Container
    
    return {
        ScreenGui = ScreenGui,
        Container = Container,
        Status = Status,
        ProgressFill = ProgressFill,
        Percentage = Percentage,
        Background = Background
    }
end

local function UpdateProgress(ui, progress, status)
    if not ui then return end
    
    pcall(function()
        local targetSize = UDim2.new(math.clamp(progress / 100, 0, 1), 0, 1, 0)
        local tween = TweenService:Create(
            ui.ProgressFill, 
            TweenInfo.new(0.25, Enum.EasingStyle.Quad), 
            {Size = targetSize}
        )
        tween:Play()
        ui.Percentage.Text = math.floor(progress) .. "%"
        if status then 
            ui.Status.Text = status 
        end
    end)
end

local function DestroyUI(ui, delay)
    if not ui then return end
    
    task.spawn(function()
        task.wait(delay or 0.5)
        pcall(function()
            local fade = TweenService:Create(
                ui.Container,
                TweenInfo.new(0.4, Enum.EasingStyle.Quad),
                {BackgroundTransparency = 1}
            )
            fade:Play()
            fade.Completed:Wait()
            ui.ScreenGui:Destroy()
        end)
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- MAIN LOADER FUNCTION
-- ════════════════════════════════════════════════════════════════════════════════
local function Main()
    local ui = CreateLoadingUI()
    
    -- Step 1: Verificar jogo
    if ui then UpdateProgress(ui, 10, "🔍 Checking game...") end
    task.wait(0.3)
    
    if not IsBloxFruits() then
        if ui then UpdateProgress(ui, 100, "❌ This script only works on Blox Fruits!") end
        warn("[Loader] This script only works on Blox Fruits!")
        task.wait(3)
        DestroyUI(ui, 0)
        return
    end
    
    if ui then UpdateProgress(ui, 25, "✅ Blox Fruits detected!") end
    task.wait(0.3)
    
    -- Step 2: Baixar script
    if ui then UpdateProgress(ui, 40, "📦 Downloading script...") end
    task.wait(0.2)
    
    local scriptContent = nil
    local lastError = nil
    
    for i, url in ipairs(CONFIG.SCRIPT_URLS) do
        if ui then UpdateProgress(ui, 40 + (i * 10), "📦 Trying source #" .. i .. "...") end
        
        local success, result = pcall(function()
            return game:HttpGet(url, true)
        end)
        
        if success and result and type(result) == "string" and #result > 1000 then
            scriptContent = result
            print("[Loader] ✅ Downloaded from source #" .. i)
            break
        else
            lastError = tostring(result)
            print("[Loader] ❌ Source #" .. i .. " failed: " .. lastError)
        end
        
        task.wait(0.5)
    end
    
    if not scriptContent then
        if ui then UpdateProgress(ui, 100, "❌ Failed to download script!") end
        warn("[Loader] All download attempts failed!")
        warn("[Loader] Last error: " .. tostring(lastError))
        Notify("❌ Error", "Failed to download. Check internet!", 5)
        task.wait(3)
        DestroyUI(ui, 0)
        return
    end
    
    -- Step 3: Executar script
    if ui then UpdateProgress(ui, 80, "🚀 Executing script...") end
    task.wait(0.3)
    
    getgenv().BloxUltimateLoaded = true
    
    local loadSuccess, loadFunc = pcall(loadstring, scriptContent)
    
    if not loadSuccess or not loadFunc then
        if ui then UpdateProgress(ui, 100, "❌ Failed to compile script!") end
        warn("[Loader] Loadstring failed: " .. tostring(loadFunc))
        Notify("❌ Error", "Script compilation failed!", 5)
        getgenv().BloxUltimateLoaded = nil
        task.wait(3)
        DestroyUI(ui, 0)
        return
    end
    
    local execSuccess, execError = pcall(loadFunc)
    
    if not execSuccess then
        if ui then UpdateProgress(ui, 100, "❌ Execution error!") end
        warn("[Loader] Execution failed: " .. tostring(execError))
        Notify("❌ Error", "Script error: " .. string.sub(tostring(execError), 1, 40), 5)
        getgenv().BloxUltimateLoaded = nil
        task.wait(3)
        DestroyUI(ui, 0)
        return
    end
    
    -- Sucesso!
    if ui then UpdateProgress(ui, 100, "✅ Script loaded successfully!") end
    task.wait(0.5)
    DestroyUI(ui, 0.5)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- EXECUTION
-- ════════════════════════════════════════════════════════════════════════════════
local success, err = pcall(Main)

if not success then
    warn("[Loader] Critical Error: " .. tostring(err))
    Notify("❌ Critical Error", "Check console for details", 5)
    getgenv().BloxUltimateLoaded = nil
end
