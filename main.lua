--[[
╔═══════════════════════════════════════════════════════════════════════════════════════╗
║                    BLOX FRUITS ULTIMATE v10.0 - ULTRA COMPLETE                        ║
║                         Professional Grade Script                                      ║
║                    200+ Features | Anti-Detection | Mobile Ready                       ║
╚═══════════════════════════════════════════════════════════════════════════════════════╝

FEATURES:
✓ Smart Auto Farm (Level, Mastery, Boss, Materials)
✓ Auto Quest Inteligente
✓ Fruit System (Sniper, ESP, Store, Buy)
✓ Race V4 Complete
✓ Mirage Island System
✓ Raids (Law, Dough, Auto)
✓ Sea Events (Leviathan, Terror Shark, Sea Beast)
✓ PvP System
✓ Anti-Detection AI
✓ FPS Booster
✓ Modern UI
✓ Save/Load Config
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 1: INITIALIZATION & ANTI-DETECTION
-- ═══════════════════════════════════════════════════════════════════════════════

-- Anti Double Load
if getgenv().BloxUltimateV10Loaded then
    warn("[Blox Ultimate] Already loaded!")
    return
end
getgenv().BloxUltimateV10Loaded = true

-- Wait for game
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5 + math.random() * 0.5)

-- Verify Blox Fruits
local placeId = game.PlaceId
local validPlaces = {2753915549, 4442272183, 7449423635}
local isBloxFruits = table.find(validPlaces, placeId) ~= nil

if not isBloxFruits then
    pcall(function()
        local name = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name or ""
        isBloxFruits = name:lower():find("blox") and name:lower():find("fruit")
    end)
end

if not isBloxFruits then
    warn("[Blox Ultimate] This script only works on Blox Fruits!")
    getgenv().BloxUltimateV10Loaded = nil
    return
end

-- Clean previous instances
if getgenv().BloxUltimateManager then
    pcall(function() getgenv().BloxUltimateManager:Destroy() end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 2: SERVICES CACHE
-- ═══════════════════════════════════════════════════════════════════════════════

local Services = {}
setmetatable(Services, {
    __index = function(self, service)
        local s = game:GetService(service)
        rawset(self, service, s)
        return s
    end
})

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local UserInputService = Services.UserInputService
local TeleportService = Services.TeleportService
local VirtualInputManager = Services.VirtualInputManager
local Lighting = Services.Lighting
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 3: UTILITY MODULE
-- ═══════════════════════════════════════════════════════════════════════════════

local Utils = {}

function Utils.GetCharacter()
    return LocalPlayer.Character
end

function Utils.GetHumanoid()
    local char = Utils.GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utils.GetHRP()
    local char = Utils.GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utils.IsAlive()
    local hum = Utils.GetHumanoid()
    return hum and hum.Health > 0
end

function Utils.GetPlayerData()
    return LocalPlayer:FindFirstChild("Data")
end

function Utils.GetLevel()
    local data = Utils.GetPlayerData()
    return data and data:FindFirstChild("Level") and data.Level.Value or 1
end

function Utils.GetBeli()
    local data = Utils.GetPlayerData()
    return data and data:FindFirstChild("Beli") and data.Beli.Value or 0
end

function Utils.GetFragments()
    local data = Utils.GetPlayerData()
    return data and data:FindFirstChild("Fragments") and data.Fragments.Value or 0
end

function Utils.GetBounty()
    local data = Utils.GetPlayerData()
    return data and data:FindFirstChild("Bounty") and data.Bounty.Value or 0
end

function Utils.GetRace()
    local data = Utils.GetPlayerData()
    return data and data:FindFirstChild("Race") and data.Race.Value or "Human"
end

function Utils.GetSea()
    local level = Utils.GetLevel()
    if level < 700 then return 1
    elseif level < 1500 then return 2
    else return 3 end
end

function Utils.Distance(pos1, pos2)
    if typeof(pos1) == "CFrame" then pos1 = pos1.Position end
    if typeof(pos2) == "CFrame" then pos2 = pos2.Position end
    if typeof(pos1) == "Instance" then pos1 = pos1.Position end
    if typeof(pos2) == "Instance" then pos2 = pos2.Position end
    return (pos1 - pos2).Magnitude
end

function Utils.RandomDelay(min, max)
    min = min or 0.05
    max = max or 0.15
    return min + math.random() * (max - min)
end

function Utils.Notify(title, text, duration)
    pcall(function()
        if getgenv().Config and getgenv().Config.Notifications == false then return end
        StarterGui:SetCore("SendNotification", {
            Title = title or "Blox Ultimate",
            Text = text or "",
            Duration = duration or 3
        })
    end)
end

function Utils.Log(message, logType)
    logType = logType or "INFO"
    if getgenv().Config and getgenv().Config.EnableLogs then
        print(string.format("[Blox Ultimate][%s] %s", logType, message))
    end
end

function Utils.GetClosestEntity(folder, filter, maxDist)
    local hrp = Utils.GetHRP()
    if not hrp then return nil end
    
    maxDist = maxDist or math.huge
    local closest, closestDist = nil, maxDist
    
    local entities = typeof(folder) == "Instance" and folder:GetChildren() or folder
    
    for _, entity in ipairs(entities) do
        local entityHRP = entity:FindFirstChild("HumanoidRootPart")
        local entityHum = entity:FindFirstChild("Humanoid")
        
        if entityHRP and entityHum and entityHum.Health > 0 then
            if not filter or entity.Name == filter or (typeof(filter) == "function" and filter(entity)) then
                local dist = Utils.Distance(hrp.Position, entityHRP.Position)
                if dist < closestDist then
                    closest = entity
                    closestDist = dist
                end
            end
        end
    end
    
    return closest, closestDist
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 4: CONNECTION MANAGER
-- ═══════════════════════════════════════════════════════════════════════════════

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    local self = setmetatable({}, ConnectionManager)
    self.Connections = {}
    self.Instances = {}
    self.Tweens = {}
    self.Loops = {}
    return self
end

function ConnectionManager:Connect(name, connection)
    if self.Connections[name] then
        pcall(function() self.Connections[name]:Disconnect() end)
    end
    self.Connections[name] = connection
    return connection
end

function ConnectionManager:Disconnect(name)
    if self.Connections[name] then
        pcall(function() self.Connections[name]:Disconnect() end)
        self.Connections[name] = nil
    end
end

function ConnectionManager:DisconnectAll()
    for name, _ in pairs(self.Connections) do
        self:Disconnect(name)
    end
end

function ConnectionManager:AddInstance(name, instance)
    if self.Instances[name] then
        pcall(function() self.Instances[name]:Destroy() end)
    end
    self.Instances[name] = instance
    return instance
end

function ConnectionManager:RemoveInstance(name)
    if self.Instances[name] then
        pcall(function() self.Instances[name]:Destroy() end)
        self.Instances[name] = nil
    end
end

function ConnectionManager:AddTween(name, tween)
    if self.Tweens[name] then
        pcall(function() self.Tweens[name]:Cancel() end)
    end
    self.Tweens[name] = tween
    return tween
end

function ConnectionManager:CancelTween(name)
    if self.Tweens[name] then
        pcall(function() self.Tweens[name]:Cancel() end)
        self.Tweens[name] = nil
    end
end

function ConnectionManager:SetLoop(name, enabled)
    self.Loops[name] = enabled
end

function ConnectionManager:IsLoopEnabled(name)
    return self.Loops[name] == true
end

function ConnectionManager:Destroy()
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, inst in pairs(self.Instances) do
        pcall(function() inst:Destroy() end)
    end
    for _, tween in pairs(self.Tweens) do
        pcall(function() tween:Cancel() end)
    end
    self.Connections = {}
    self.Instances = {}
    self.Tweens = {}
    self.Loops = {}
end

getgenv().BloxUltimateManager = ConnectionManager.new()
local Manager = getgenv().BloxUltimateManager

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 5: REMOTE HANDLER (Anti-Detection)
-- ═══════════════════════════════════════════════════════════════════════════════

local RemoteHandler = {}
local RemoteCache = {}
local LastRemoteCall = {}
local RemoteCallCount = {}

function RemoteHandler.GetRemote(name)
    if RemoteCache[name] then return RemoteCache[name] end
    
    local remote = ReplicatedStorage:FindFirstChild(name)
    if not remote then
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            remote = remotes:FindFirstChild(name)
        end
    end
    
    if remote then
        RemoteCache[name] = remote
    end
    
    return remote
end

function RemoteHandler.Fire(remoteName, ...)
    local remote = RemoteHandler.GetRemote(remoteName)
    if not remote then return nil end
    
    -- Anti-Detection: Rate limiting with random delays
    local now = tick()
    local lastCall = LastRemoteCall[remoteName] or 0
    local minDelay = 0.03 + math.random() * 0.05
    
    if now - lastCall < minDelay then
        task.wait(minDelay - (now - lastCall) + math.random() * 0.02)
    end
    
    LastRemoteCall[remoteName] = tick()
    
    -- Track call count for anti-detection
    RemoteCallCount[remoteName] = (RemoteCallCount[remoteName] or 0) + 1
    
    local success, result = pcall(function()
        if remote:IsA("RemoteFunction") then
            return remote:InvokeServer(...)
        elseif remote:IsA("RemoteEvent") then
            remote:FireServer(...)
            return true
        end
    end)
    
    return success and result or nil
end

function RemoteHandler.Invoke(...)
    return RemoteHandler.Fire("CommF_", ...)
end

function RemoteHandler.InvokeSafe(...)
    task.wait(Utils.RandomDelay(0.05, 0.1))
    return RemoteHandler.Invoke(...)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 6: CONFIGURATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

getgenv().Config = getgenv().Config or {
    -- ══════════════════════════════════════
    -- AUTO FARM SETTINGS
    -- ══════════════════════════════════════
    AutoFarm = false,
    AutoQuest = true,
    SmartFarm = true,
    AutoFarmMastery = false,
    AutoFarmBoss = false,
    AutoFarmMaterials = false,
    ServerHopNoMobs = false,
    PathfindingMode = false,
    
    -- Farm Weapon Type
    FarmWeaponType = "Main", -- Main, Sword, Melee, Fruit, Gun
    AutoSwitchWeapon = false,
    MasteryWeapon = "Melee",
    MasteryHealthSwitch = 30,
    
    -- Boss Settings
    SelectedBoss = "Auto",
    BossPriority = {"Cake Queen", "Dough King", "Awakened Ice Admiral"},
    AutoCollectDrops = true,
    
    -- ══════════════════════════════════════
    -- WEAPON SETTINGS
    -- ══════════════════════════════════════
    SelectedWeapon = "Combat",
    SelectedSword = "",
    SelectedGun = "",
    SelectedFruit = "",
    
    -- ══════════════════════════════════════
    -- COMBAT SETTINGS
    -- ══════════════════════════════════════
    AutoSkill = true,
    FastAttack = true,
    AutoBusoHaki = true,
    AutoKenHaki = false,
    KillAura = false,
    Aimbot = false,
    AutoDodge = false,
    SkillCooldown = 0.5,
    
    -- ══════════════════════════════════════
    -- FRUIT SYSTEM
    -- ══════════════════════════════════════
    FruitSniper = false,
    FruitESP = false,
    AutoStoreFruit = false,
    AutoBuyFruit = false,
    AutoDropFruit = false,
    FruitNotification = true,
    TargetFruit = "Any", -- Any, Legendary, Mythical, specific fruit
    
    -- ══════════════════════════════════════
    -- MIRAGE ISLAND
    -- ══════════════════════════════════════
    AutoMirage = false,
    ESPMirage = true,
    ESPMirageDealer = true,
    MirageNotification = true,
    
    -- ══════════════════════════════════════
    -- RACE V4 SYSTEM
    -- ══════════════════════════════════════
    AutoRaceV4 = false,
    AutoTrialV4 = false,
    AutoMinotaur = false,
    AutoAwakening = false,
    
    -- ══════════════════════════════════════
    -- RAIDS SYSTEM
    -- ══════════════════════════════════════
    AutoRaid = false,
    AutoLawRaid = false,
    AutoDoughRaid = false,
    AutoBuyChip = false,
    SelectedRaid = "Auto",
    
    -- ══════════════════════════════════════
    -- SEA EVENTS
    -- ══════════════════════════════════════
    AutoSeaEvents = false,
    AutoSeaBeast = false,
    AutoTerrorShark = false,
    AutoLeviathan = false,
    AutoShipFarm = false,
    
    -- ══════════════════════════════════════
    -- PVP SETTINGS
    -- ══════════════════════════════════════
    AutoPvP = false,
    PvPESP = false,
    AutoBountyHunt = false,
    TargetPlayer = "",
    
    -- ══════════════════════════════════════
    -- ESP SETTINGS
    -- ══════════════════════════════════════
    ESPBoss = true,
    ESPQuestMobs = true,
    ESPPlayer = false,
    ESPChest = false,
    ESPFlower = false,
    ESPNPC = false,
    ESPFruit = false,
    ESPDistance = true,
    ESPHealth = true,
    
    -- ══════════════════════════════════════
    -- MOVEMENT & UTILITY
    -- ══════════════════════════════════════
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    FlySpeed = 150,
    NoClip = false,
    InfiniteEnergy = false,
    
    -- ══════════════════════════════════════
    -- SAFETY & ANTI-DETECTION
    -- ══════════════════════════════════════
    SafeMode = true,
    SafeHealthPercent = 30,
    AntiAFK = true,
    AntiDetection = true,
    AutoDisableOnAdmin = true,
    AutoRejoin = false,
    FPSBooster = false,
    
    -- ══════════════════════════════════════
    -- AUTO BUY
    -- ══════════════════════════════════════
    AutoBuyBuso = false,
    AutoBuyKen = false,
    AutoBuyGeppo = false,
    AutoBuySoru = false,
    
    -- ══════════════════════════════════════
    -- MISC SETTINGS
    -- ══════════════════════════════════════
    AutoChestFarm = false,
    AutoObservationV2 = false,
    BringMobs = true,
    ExpandHitbox = true,
    HitboxSize = 50,
    BringDistance = 100,
    FarmDistance = 50,
    
    -- ══════════════════════════════════════
    -- UI SETTINGS
    -- ══════════════════════════════════════
    Notifications = true,
    EnableLogs = false,
    Theme = "Dark",
    UIScale = 1,
    
    -- ══════════════════════════════════════
    -- TELEPORT
    -- ══════════════════════════════════════
    SelectedIsland = "Auto",
}

-- Config Save/Load System
local ConfigFileName = "BloxUltimate_v10_Config.json"

local function SaveConfig()
    if writefile then
        local success = pcall(function()
            writefile(ConfigFileName, HttpService:JSONEncode(getgenv().Config))
        end)
        if success then
            Utils.Notify("Config", "Configuration saved!", 2)
            Utils.Log("Config saved successfully", "INFO")
        end
    end
end

local function LoadConfig()
    if readfile and isfile then
        local success = pcall(function()
            if isfile(ConfigFileName) then
                local data = HttpService:JSONDecode(readfile(ConfigFileName))
                for k, v in pairs(data) do
                    if getgenv().Config[k] ~= nil then
                        getgenv().Config[k] = v
                    end
                end
            end
        end)
        if success then
            Utils.Log("Config loaded successfully", "INFO")
        end
    end
end

pcall(LoadConfig)

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 7: DATABASE - QUESTS
-- ═══════════════════════════════════════════════════════════════════════════════

local QuestDatabase = {
    -- FIRST SEA (1-700)
    {Min=1, Max=9, QuestId="BanditQuest1", MobName="Bandit", QuestLevel=1, QuestPos=CFrame.new(1060,17,1550), MobPos=CFrame.new(1044,16,1525), Island="Starter"},
    {Min=10, Max=14, QuestId="JungleQuest", MobName="Monkey", QuestLevel=1, QuestPos=CFrame.new(-1604,37,152), MobPos=CFrame.new(-1538,37,203), Island="Jungle"},
    {Min=15, Max=29, QuestId="JungleQuest", MobName="Gorilla", QuestLevel=2, QuestPos=CFrame.new(-1604,37,152), MobPos=CFrame.new(-1230,6,-485), Island="Jungle"},
    {Min=30, Max=39, QuestId="BuggyQuest1", MobName="Pirate", QuestLevel=1, QuestPos=CFrame.new(-1140,5,3828), MobPos=CFrame.new(-1190,5,3762), Island="Buggy"},
    {Min=40, Max=59, QuestId="BuggyQuest1", MobName="Brute", QuestLevel=2, QuestPos=CFrame.new(-1140,5,3828), MobPos=CFrame.new(-1414,12,4162), Island="Buggy"},
    {Min=60, Max=74, QuestId="DesertQuest", MobName="Desert Bandit", QuestLevel=1, QuestPos=CFrame.new(897,7,4388), MobPos=CFrame.new(960,7,4348), Island="Desert"},
    {Min=75, Max=89, QuestId="DesertQuest", MobName="Desert Officer", QuestLevel=2, QuestPos=CFrame.new(897,7,4388), MobPos=CFrame.new(1537,7,4596), Island="Desert"},
    {Min=90, Max=99, QuestId="SnowQuest", MobName="Snow Bandit", QuestLevel=1, QuestPos=CFrame.new(1386,87,-1297), MobPos=CFrame.new(1366,87,-1347), Island="Frozen"},
    {Min=100, Max=119, QuestId="SnowQuest", MobName="Snowman", QuestLevel=2, QuestPos=CFrame.new(1386,87,-1297), MobPos=CFrame.new(1120,115,-1411), Island="Frozen"},
    {Min=120, Max=149, QuestId="MarineQuest2", MobName="Chief Petty Officer", QuestLevel=1, QuestPos=CFrame.new(-4880,21,4273), MobPos=CFrame.new(-4953,21,4232), Island="Marine Ford"},
    {Min=150, Max=174, QuestId="SkyQuest", MobName="Sky Bandit", QuestLevel=1, QuestPos=CFrame.new(-4892,312,4211), MobPos=CFrame.new(-4946,312,4175), Island="Sky Island"},
    {Min=175, Max=189, QuestId="PrisonerQuest", MobName="Prisoner", QuestLevel=1, QuestPos=CFrame.new(5308,2,474), MobPos=CFrame.new(5379,2,413), Island="Prison"},
    {Min=190, Max=209, QuestId="PrisonerQuest", MobName="Dangerous Prisoner", QuestLevel=2, QuestPos=CFrame.new(5308,2,474), MobPos=CFrame.new(5098,2,466), Island="Prison"},
    {Min=210, Max=249, QuestId="ColosseumQuest", MobName="Toga Warrior", QuestLevel=1, QuestPos=CFrame.new(-1576,8,-2985), MobPos=CFrame.new(-1475,8,-2918), Island="Colosseum"},
    {Min=250, Max=274, QuestId="ColosseumQuest", MobName="Gladiator", QuestLevel=2, QuestPos=CFrame.new(-1576,8,-2985), MobPos=CFrame.new(-1415,8,-3150), Island="Colosseum"},
    {Min=275, Max=299, QuestId="MagmaQuest", MobName="Military Soldier", QuestLevel=1, QuestPos=CFrame.new(-5313,12,8515), MobPos=CFrame.new(-5451,12,8466), Island="Magma"},
    {Min=300, Max=324, QuestId="MagmaQuest", MobName="Military Spy", QuestLevel=2, QuestPos=CFrame.new(-5313,12,8515), MobPos=CFrame.new(-5138,12,8519), Island="Magma"},
    {Min=325, Max=374, QuestId="FishmanQuest", MobName="Fishman Warrior", QuestLevel=1, QuestPos=CFrame.new(61123,19,1569), MobPos=CFrame.new(61072,19,1519), Island="Fishman"},
    {Min=375, Max=399, QuestId="FishmanQuest", MobName="Fishman Commando", QuestLevel=2, QuestPos=CFrame.new(61123,19,1569), MobPos=CFrame.new(61497,19,1526), Island="Fishman"},
    {Min=400, Max=449, QuestId="SkyExp1Quest", MobName="God's Guard", QuestLevel=1, QuestPos=CFrame.new(-4721,845,-1912), MobPos=CFrame.new(-4766,845,-1978), Island="Upper Sky"},
    {Min=450, Max=474, QuestId="SkyExp1Quest", MobName="Shanda", QuestLevel=2, QuestPos=CFrame.new(-4721,845,-1912), MobPos=CFrame.new(-7863,5545,-380), Island="Upper Sky"},
    {Min=475, Max=524, QuestId="SkyExp2Quest", MobName="Royal Squad", QuestLevel=1, QuestPos=CFrame.new(-7906,5634,-1411), MobPos=CFrame.new(-7903,5634,-1467), Island="Upper Sky 2"},
    {Min=525, Max=549, QuestId="SkyExp2Quest", MobName="Royal Soldier", QuestLevel=2, QuestPos=CFrame.new(-7906,5634,-1411), MobPos=CFrame.new(-7679,5584,-1406), Island="Upper Sky 2"},
    {Min=550, Max=624, QuestId="FountainQuest", MobName="Galley Pirate", QuestLevel=1, QuestPos=CFrame.new(5255,39,4050), MobPos=CFrame.new(5267,42,3996), Island="Fountain"},
    {Min=625, Max=699, QuestId="FountainQuest", MobName="Galley Captain", QuestLevel=2, QuestPos=CFrame.new(5255,39,4050), MobPos=CFrame.new(5573,39,4107), Island="Fountain"},
    
    -- SECOND SEA (700-1500)
    {Min=700, Max=724, QuestId="Area1Quest", MobName="Raider", QuestLevel=1, QuestPos=CFrame.new(-428,73,1836), MobPos=CFrame.new(-472,73,1824), Island="Rose"},
    {Min=725, Max=774, QuestId="Area1Quest", MobName="Mercenary", QuestLevel=2, QuestPos=CFrame.new(-428,73,1836), MobPos=CFrame.new(-413,73,1563), Island="Rose"},
    {Min=775, Max=799, QuestId="Area2Quest", MobName="Swan Pirate", QuestLevel=1, QuestPos=CFrame.new(638,73,1478), MobPos=CFrame.new(638,73,1527), Island="Rose"},
    {Min=800, Max=874, QuestId="Area2Quest", MobName="Factory Staff", QuestLevel=2, QuestPos=CFrame.new(638,73,1478), MobPos=CFrame.new(281,73,410), Island="Rose"},
    {Min=875, Max=899, QuestId="MarineQuest3", MobName="Marine Lieutenant", QuestLevel=1, QuestPos=CFrame.new(-2440,73,-3217), MobPos=CFrame.new(-2496,73,-3280), Island="Green Zone"},
    {Min=900, Max=949, QuestId="MarineQuest3", MobName="Marine Captain", QuestLevel=2, QuestPos=CFrame.new(-2440,73,-3217), MobPos=CFrame.new(-2273,73,-3125), Island="Green Zone"},
    {Min=950, Max=974, QuestId="ZombieQuest", MobName="Zombie", QuestLevel=1, QuestPos=CFrame.new(-5497,49,-795), MobPos=CFrame.new(-5454,49,-729), Island="Graveyard"},
    {Min=975, Max=999, QuestId="ZombieQuest", MobName="Vampire", QuestLevel=2, QuestPos=CFrame.new(-5497,49,-795), MobPos=CFrame.new(-5635,112,-780), Island="Graveyard"},
    {Min=1000, Max=1049, QuestId="SnowMountainQuest", MobName="Snow Trooper", QuestLevel=1, QuestPos=CFrame.new(607,401,-5371), MobPos=CFrame.new(600,401,-5304), Island="Snow Mountain"},
    {Min=1050, Max=1099, QuestId="SnowMountainQuest", MobName="Winter Warrior", QuestLevel=2, QuestPos=CFrame.new(607,401,-5371), MobPos=CFrame.new(596,440,-5806), Island="Snow Mountain"},
    {Min=1100, Max=1124, QuestId="IceSideQuest", MobName="Lab Subordinate", QuestLevel=1, QuestPos=CFrame.new(-6061,16,-4905), MobPos=CFrame.new(-6095,16,-4832), Island="Hot Cold"},
    {Min=1125, Max=1174, QuestId="IceSideQuest", MobName="Horned Warrior", QuestLevel=2, QuestPos=CFrame.new(-6061,16,-4905), MobPos=CFrame.new(-5988,16,-5280), Island="Hot Cold"},
    {Min=1175, Max=1199, QuestId="FireSideQuest", MobName="Magma Ninja", QuestLevel=1, QuestPos=CFrame.new(-5431,16,-5296), MobPos=CFrame.new(-5376,16,-5247), Island="Hot Cold"},
    {Min=1200, Max=1249, QuestId="FireSideQuest", MobName="Lava Pirate", QuestLevel=2, QuestPos=CFrame.new(-5431,16,-5296), MobPos=CFrame.new(-5102,16,-5427), Island="Hot Cold"},
    {Min=1250, Max=1274, QuestId="ShipQuest1", MobName="Ship Deckhand", QuestLevel=1, QuestPos=CFrame.new(1037,125,32911), MobPos=CFrame.new(958,125,32849), Island="Cursed Ship"},
    {Min=1275, Max=1299, QuestId="ShipQuest1", MobName="Ship Engineer", QuestLevel=2, QuestPos=CFrame.new(1037,125,32911), MobPos=CFrame.new(1235,125,32895), Island="Cursed Ship"},
    {Min=1300, Max=1324, QuestId="ShipQuest2", MobName="Ship Steward", QuestLevel=1, QuestPos=CFrame.new(971,125,33245), MobPos=CFrame.new(924,141,33184), Island="Cursed Ship"},
    {Min=1325, Max=1349, QuestId="ShipQuest2", MobName="Ship Officer", QuestLevel=2, QuestPos=CFrame.new(971,125,33245), MobPos=CFrame.new(920,177,33385), Island="Cursed Ship"},
    {Min=1350, Max=1374, QuestId="FrostQuest", MobName="Arctic Warrior", QuestLevel=1, QuestPos=CFrame.new(5669,29,-6482), MobPos=CFrame.new(5596,29,-6420), Island="Ice Castle"},
    {Min=1375, Max=1424, QuestId="FrostQuest", MobName="Snow Lurker", QuestLevel=2, QuestPos=CFrame.new(5669,29,-6482), MobPos=CFrame.new(5874,29,-6585), Island="Ice Castle"},
    {Min=1425, Max=1449, QuestId="ForgottenQuest", MobName="Sea Soldier", QuestLevel=1, QuestPos=CFrame.new(-3054,236,-10145), MobPos=CFrame.new(-3004,236,-10089), Island="Forgotten"},
    {Min=1450, Max=1499, QuestId="ForgottenQuest", MobName="Water Fighter", QuestLevel=2, QuestPos=CFrame.new(-3054,236,-10145), MobPos=CFrame.new(-2864,236,-10186), Island="Forgotten"},
    
    -- THIRD SEA (1500+)
    {Min=1500, Max=1524, QuestId="PiratePortQuest", MobName="Pirate Millionaire", QuestLevel=1, QuestPos=CFrame.new(-290,44,5580), MobPos=CFrame.new(-241,44,5632), Island="Port Town"},
    {Min=1525, Max=1574, QuestId="PiratePortQuest", MobName="Pistol Billionaire", QuestLevel=2, QuestPos=CFrame.new(-290,44,5580), MobPos=CFrame.new(-444,44,5595), Island="Port Town"},
    {Min=1575, Max=1599, QuestId="AmazonQuest", MobName="Dragon Crew Warrior", QuestLevel=1, QuestPos=CFrame.new(5832,52,-1100), MobPos=CFrame.new(5766,52,-1159), Island="Hydra"},
    {Min=1600, Max=1624, QuestId="AmazonQuest", MobName="Dragon Crew Archer", QuestLevel=2, QuestPos=CFrame.new(5832,52,-1100), MobPos=CFrame.new(6076,52,-1035), Island="Hydra"},
    {Min=1625, Max=1649, QuestId="AmazonQuest2", MobName="Female Islander", QuestLevel=1, QuestPos=CFrame.new(5448,602,751), MobPos=CFrame.new(5401,602,706), Island="Amazon"},
    {Min=1650, Max=1699, QuestId="AmazonQuest2", MobName="Giant Islander", QuestLevel=2, QuestPos=CFrame.new(5448,602,751), MobPos=CFrame.new(5691,602,785), Island="Amazon"},
    {Min=1700, Max=1724, QuestId="MarineTreeIsland", MobName="Marine Commodore", QuestLevel=1, QuestPos=CFrame.new(2180,29,-6737), MobPos=CFrame.new(2119,29,-6784), Island="Marine Tree"},
    {Min=1725, Max=1774, QuestId="MarineTreeIsland", MobName="Marine Rear Admiral", QuestLevel=2, QuestPos=CFrame.new(2180,29,-6737), MobPos=CFrame.new(2365,29,-6663), Island="Marine Tree"},
    {Min=1775, Max=1799, QuestId="DeepForestIsland", MobName="Mythological Pirate", QuestLevel=1, QuestPos=CFrame.new(-13234,332,-7625), MobPos=CFrame.new(-13303,332,-7570), Island="Turtle"},
    {Min=1800, Max=1824, QuestId="DeepForestIsland2", MobName="Jungle Pirate", QuestLevel=1, QuestPos=CFrame.new(-12680,390,-9902), MobPos=CFrame.new(-12620,390,-9840), Island="Turtle"},
    {Min=1825, Max=1849, QuestId="DeepForestIsland3", MobName="Musketeer Pirate", QuestLevel=1, QuestPos=CFrame.new(-13234,332,-7625), MobPos=CFrame.new(-13450,332,-7580), Island="Turtle"},
    {Min=1850, Max=1899, QuestId="HauntedQuest1", MobName="Reborn Skeleton", QuestLevel=1, QuestPos=CFrame.new(-9479,142,5566), MobPos=CFrame.new(-9426,142,5510), Island="Haunted"},
    {Min=1900, Max=1924, QuestId="HauntedQuest1", MobName="Living Zombie", QuestLevel=2, QuestPos=CFrame.new(-9479,142,5566), MobPos=CFrame.new(-9606,142,5584), Island="Haunted"},
    {Min=1925, Max=1974, QuestId="HauntedQuest2", MobName="Demonic Soul", QuestLevel=1, QuestPos=CFrame.new(-9513,172,6078), MobPos=CFrame.new(-9457,172,6020), Island="Haunted"},
    {Min=1975, Max=1999, QuestId="HauntedQuest2", MobName="Posessed Mummy", QuestLevel=2, QuestPos=CFrame.new(-9513,172,6078), MobPos=CFrame.new(-9613,172,6136), Island="Haunted"},
    {Min=2000, Max=2024, QuestId="IceCreamLandQuest", MobName="Peanut Scout", QuestLevel=1, QuestPos=CFrame.new(-716,38,-12469), MobPos=CFrame.new(-659,38,-12412), Island="Ice Cream"},
    {Min=2025, Max=2049, QuestId="IceCreamLandQuest", MobName="Peanut President", QuestLevel=2, QuestPos=CFrame.new(-716,38,-12469), MobPos=CFrame.new(-865,38,-12532), Island="Ice Cream"},
    {Min=2050, Max=2074, QuestId="IceCreamLandQuest2", MobName="Ice Cream Chef", QuestLevel=1, QuestPos=CFrame.new(-821,66,-10965), MobPos=CFrame.new(-762,66,-10906), Island="Ice Cream 2"},
    {Min=2075, Max=2099, QuestId="IceCreamLandQuest2", MobName="Ice Cream Commander", QuestLevel=2, QuestPos=CFrame.new(-821,66,-10965), MobPos=CFrame.new(-978,66,-11028), Island="Ice Cream 2"},
    {Min=2100, Max=2124, QuestId="CakeQuest1", MobName="Cookie Crafter", QuestLevel=1, QuestPos=CFrame.new(-2021,38,-12028), MobPos=CFrame.new(-1968,38,-11975), Island="Cake"},
    {Min=2125, Max=2149, QuestId="CakeQuest1", MobName="Cake Guard", QuestLevel=2, QuestPos=CFrame.new(-2021,38,-12028), MobPos=CFrame.new(-2132,38,-12089), Island="Cake"},
    {Min=2150, Max=2199, QuestId="CakeQuest2", MobName="Baking Staff", QuestLevel=1, QuestPos=CFrame.new(-1927,38,-12842), MobPos=CFrame.new(-1871,38,-12785), Island="Cake 2"},
    {Min=2200, Max=2224, QuestId="CakeQuest2", MobName="Head Baker", QuestLevel=2, QuestPos=CFrame.new(-1927,38,-12842), MobPos=CFrame.new(-2038,38,-12905), Island="Cake 2"},
    {Min=2225, Max=2249, QuestId="ChocQuest1", MobName="Cocoa Warrior", QuestLevel=1, QuestPos=CFrame.new(231,23,-12197), MobPos=CFrame.new(286,23,-12141), Island="Chocolate"},
    {Min=2250, Max=2274, QuestId="ChocQuest1", MobName="Chocolate Bar Battler", QuestLevel=2, QuestPos=CFrame.new(231,23,-12197), MobPos=CFrame.new(120,23,-12258), Island="Chocolate"},
    {Min=2275, Max=2299, QuestId="ChocQuest2", MobName="Sweet Thief", QuestLevel=1, QuestPos=CFrame.new(151,23,-12774), MobPos=CFrame.new(205,23,-12718), Island="Chocolate 2"},
    {Min=2300, Max=2324, QuestId="ChocQuest2", MobName="Candy Rebel", QuestLevel=2, QuestPos=CFrame.new(151,23,-12774), MobPos=CFrame.new(40,23,-12837), Island="Chocolate 2"},
    {Min=2325, Max=2349, QuestId="CandyQuest1", MobName="Candy Pirate", QuestLevel=1, QuestPos=CFrame.new(-1149,14,-14445), MobPos=CFrame.new(-1093,14,-14389), Island="Candy"},
    {Min=2350, Max=2374, QuestId="CandyQuest1", MobName="Snow Demon", QuestLevel=2, QuestPos=CFrame.new(-1149,14,-14445), MobPos=CFrame.new(-1260,14,-14508), Island="Candy"},
    {Min=2375, Max=2399, QuestId="TikiQuest1", MobName="Isle Outlaw", QuestLevel=1, QuestPos=CFrame.new(-16545,56,1051), MobPos=CFrame.new(-16490,56,995), Island="Tiki"},
    {Min=2400, Max=2424, QuestId="TikiQuest1", MobName="Island Boy", QuestLevel=2, QuestPos=CFrame.new(-16545,56,1051), MobPos=CFrame.new(-16655,56,1114), Island="Tiki"},
    {Min=2425, Max=2449, QuestId="TikiQuest2", MobName="Sun-kissed Warrior", QuestLevel=1, QuestPos=CFrame.new(-16539,56,-173), MobPos=CFrame.new(-16483,56,-117), Island="Tiki 2"},
    {Min=2450, Max=9999, QuestId="TikiQuest2", MobName="Isle Champion", QuestLevel=2, QuestPos=CFrame.new(-16539,56,-173), MobPos=CFrame.new(-16650,56,-236), Island="Tiki 2"},
}

function QuestDatabase.GetQuestForLevel(level)
    level = level or Utils.GetLevel()
    for _, quest in ipairs(QuestDatabase) do
        if level >= quest.Min and level <= quest.Max then
            return quest
        end
    end
    return QuestDatabase[#QuestDatabase]
end

function QuestDatabase.GetQuestByMob(mobName)
    for _, quest in ipairs(QuestDatabase) do
        if quest.MobName == mobName then
            return quest
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 8: DATABASE - BOSSES
-- ═══════════════════════════════════════════════════════════════════════════════

local BossDatabase = {
    -- FIRST SEA
    {Name = "Gorilla King", Level = 25, Pos = CFrame.new(-1221,6,-427), Sea = 1, Drops = {"Gorilla King Crown"}},
    {Name = "Bobby", Level = 55, Pos = CFrame.new(-1259,5,4282), Sea = 1, Drops = {}},
    {Name = "Yeti", Level = 110, Pos = CFrame.new(1187,138,-1483), Sea = 1, Drops = {}},
    {Name = "Mob Leader", Level = 120, Pos = CFrame.new(-3037,21,3071), Sea = 1, Drops = {}},
    {Name = "Vice Admiral", Level = 130, Pos = CFrame.new(-5072,22,4280), Sea = 1, Drops = {}},
    {Name = "Warden", Level = 200, Pos = CFrame.new(5231,2,443), Sea = 1, Drops = {}},
    {Name = "Chief Warden", Level = 220, Pos = CFrame.new(4926,-72,608), Sea = 1, Drops = {}},
    {Name = "Saber Expert", Level = 200, Pos = CFrame.new(-1458,29,-48), Sea = 1, Drops = {"Saber"}},
    {Name = "Magma Admiral", Level = 350, Pos = CFrame.new(-5364,40,8442), Sea = 1, Drops = {}},
    {Name = "Fishman Lord", Level = 425, Pos = CFrame.new(61366,18,1476), Sea = 1, Drops = {"Fishman Trident"}},
    {Name = "Wysper", Level = 500, Pos = CFrame.new(-7862,5544,-371), Sea = 1, Drops = {}},
    {Name = "Thunder God", Level = 575, Pos = CFrame.new(-7648,5586,-1414), Sea = 1, Drops = {"Pole V1"}},
    {Name = "Cyborg", Level = 675, Pos = CFrame.new(5331,54,4038), Sea = 1, Drops = {"Cool Shades", "Cyborg Race"}},
    {Name = "Greybeard", Level = 750, Pos = CFrame.new(-5076,25,4270), Sea = 1, Drops = {"Bisento"}},
    
    -- SECOND SEA
    {Name = "Diamond", Level = 750, Pos = CFrame.new(-429,73,1218), Sea = 2, Drops = {}},
    {Name = "Jeremy", Level = 850, Pos = CFrame.new(-797,73,1064), Sea = 2, Drops = {}},
    {Name = "Fajita", Level = 925, Pos = CFrame.new(-2148,73,-3106), Sea = 2, Drops = {}},
    {Name = "Don Swan", Level = 1000, Pos = CFrame.new(-375,124,428), Sea = 2, Drops = {"Swan Glasses", "Pink Coat"}},
    {Name = "Smoke Admiral", Level = 1150, Pos = CFrame.new(-5099,16,-5335), Sea = 2, Drops = {}},
    {Name = "Awakened Ice Admiral", Level = 1400, Pos = CFrame.new(5669,29,-6482), Sea = 2, Drops = {"Library Key"}},
    {Name = "Tide Keeper", Level = 1475, Pos = CFrame.new(-2871,236,-10179), Sea = 2, Drops = {"Tushita", "Yama"}},
    
    -- THIRD SEA
    {Name = "Stone", Level = 1550, Pos = CFrame.new(-293,44,5472), Sea = 3, Drops = {}},
    {Name = "Island Empress", Level = 1675, Pos = CFrame.new(5698,602,779), Sea = 3, Drops = {"Serpent Bow"}},
    {Name = "Kilo Admiral", Level = 1750, Pos = CFrame.new(2366,28,-6708), Sea = 3, Drops = {}},
    {Name = "Captain Elephant", Level = 1875, Pos = CFrame.new(-12757,332,-7734), Sea = 3, Drops = {"Elephant Mask"}},
    {Name = "Beautiful Pirate", Level = 1950, Pos = CFrame.new(-9565,142,5570), Sea = 3, Drops = {"Pretty Helm"}},
    {Name = "Cake Queen", Level = 2175, Pos = CFrame.new(-2021,38,-12028), Sea = 3, Drops = {"Buddy Sword"}},
    {Name = "rip_indra", Level = 5000, Pos = CFrame.new(-5352,424,-2893), Sea = 3, Drops = {"Dark Dagger", "Valkyrie Helm"}},
    {Name = "Dough King", Level = 2200, Pos = CFrame.new(231,23,-12197), Sea = 3, Drops = {}},
    {Name = "Cake Prince", Level = 2300, Pos = CFrame.new(-1927,38,-12842), Sea = 3, Drops = {}},
    {Name = "Longma", Level = 2000, Pos = CFrame.new(-13234,332,-7625), Sea = 3, Drops = {}},
}

function BossDatabase.GetBossForLevel(level)
    level = level or Utils.GetLevel()
    local suitable = {}
    for _, boss in ipairs(BossDatabase) do
        if level >= boss.Level then
            table.insert(suitable, boss)
        end
    end
    if #suitable > 0 then
        return suitable[#suitable]
    end
    return BossDatabase[1]
end

function BossDatabase.FindBoss(name)
    for _, boss in ipairs(BossDatabase) do
        if boss.Name:lower():find(name:lower()) then
            return boss
        end
    end
    return nil
end

function BossDatabase.GetBossesBySea(sea)
    local bosses = {}
    for _, boss in ipairs(BossDatabase) do
        if boss.Sea == sea then
            table.insert(bosses, boss)
        end
    end
    return bosses
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 9: DATABASE - ISLANDS
-- ═══════════════════════════════════════════════════════════════════════════════

local IslandDatabase = {
    -- FIRST SEA
    ["Starter Island"] = {Pos = CFrame.new(1044,16,1525), Sea = 1},
    ["Jungle"] = {Pos = CFrame.new(-1604,37,152), Sea = 1},
    ["Buggy Island"] = {Pos = CFrame.new(-1140,5,3828), Sea = 1},
    ["Desert"] = {Pos = CFrame.new(897,7,4388), Sea = 1},
    ["Frozen Village"] = {Pos = CFrame.new(1386,87,-1297), Sea = 1},
    ["Marine Ford"] = {Pos = CFrame.new(-4880,21,4273), Sea = 1},
    ["Sky Island"] = {Pos = CFrame.new(-4892,312,4211), Sea = 1},
    ["Prison"] = {Pos = CFrame.new(5308,2,474), Sea = 1},
    ["Colosseum"] = {Pos = CFrame.new(-1576,8,-2985), Sea = 1},
    ["Magma Village"] = {Pos = CFrame.new(-5313,12,8515), Sea = 1},
    ["Fishman Island"] = {Pos = CFrame.new(61123,19,1569), Sea = 1},
    ["Upper Skylands"] = {Pos = CFrame.new(-4721,845,-1912), Sea = 1},
    ["Upper Skylands 2"] = {Pos = CFrame.new(-7906,5634,-1411), Sea = 1},
    ["Fountain City"] = {Pos = CFrame.new(5255,39,4050), Sea = 1},
    
    -- SECOND SEA
    ["Kingdom of Rose"] = {Pos = CFrame.new(-428,73,1836), Sea = 2},
    ["Green Zone"] = {Pos = CFrame.new(-2440,73,-3217), Sea = 2},
    ["Graveyard Island"] = {Pos = CFrame.new(-5497,49,-795), Sea = 2},
    ["Snow Mountain"] = {Pos = CFrame.new(607,401,-5371), Sea = 2},
    ["Hot and Cold"] = {Pos = CFrame.new(-6061,16,-4905), Sea = 2},
    ["Cursed Ship"] = {Pos = CFrame.new(1037,125,32911), Sea = 2},
    ["Ice Castle"] = {Pos = CFrame.new(5669,29,-6482), Sea = 2},
    ["Forgotten Island"] = {Pos = CFrame.new(-3054,236,-10145), Sea = 2},
    ["Dark Arena"] = {Pos = CFrame.new(-375,124,428), Sea = 2},
    ["Cafe"] = {Pos = CFrame.new(-385,73,298), Sea = 2},
    
    -- THIRD SEA
    ["Port Town"] = {Pos = CFrame.new(-290,44,5580), Sea = 3},
    ["Hydra Island"] = {Pos = CFrame.new(5832,52,-1100), Sea = 3},
    ["Amazon Lily"] = {Pos = CFrame.new(5448,602,751), Sea = 3},
    ["Marine Tree"] = {Pos = CFrame.new(2180,29,-6737), Sea = 3},
    ["Floating Turtle"] = {Pos = CFrame.new(-13234,332,-7625), Sea = 3},
    ["Haunted Castle"] = {Pos = CFrame.new(-9479,142,5566), Sea = 3},
    ["Ice Cream Land"] = {Pos = CFrame.new(-716,38,-12469), Sea = 3},
    ["Cake Land"] = {Pos = CFrame.new(-2021,38,-12028), Sea = 3},
    ["Chocolate Land"] = {Pos = CFrame.new(231,23,-12197), Sea = 3},
    ["Candy Land"] = {Pos = CFrame.new(-1149,14,-14445), Sea = 3},
    ["Tiki Outpost"] = {Pos = CFrame.new(-16545,56,1051), Sea = 3},
    ["Mansion"] = {Pos = CFrame.new(-12896,331,-7574), Sea = 3},
    ["Castle on the Sea"] = {Pos = CFrame.new(-5039,313,-2991), Sea = 3},
    ["Mirage Island"] = {Pos = CFrame.new(925,81,34226), Sea = 3},
    ["Sea of Treats"] = {Pos = CFrame.new(-716,38,-12469), Sea = 3},
}

function IslandDatabase.GetIsland(name)
    for island, data in pairs(IslandDatabase) do
        if island:lower():find(name:lower()) then
            return data.Pos, data.Sea
        end
    end
    return nil, nil
end

function IslandDatabase.GetIslandsBySea(sea)
    local islands = {}
    for name, data in pairs(IslandDatabase) do
        if data.Sea == sea then
            islands[name] = data.Pos
        end
    end
    return islands
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 10: DATABASE - FRUITS
-- ═══════════════════════════════════════════════════════════════════════════════

local FruitDatabase = {
    Legendary = {"Dragon", "Leopard", "Spirit", "Control", "Venom", "Shadow", "Dough", "Soul", "Mammoth", "T-Rex"},
    Mythical = {"Buddha", "Phoenix", "Rumble", "Magma", "Quake", "Ice", "Light", "Love", "Gravity", "Dark"},
    Rare = {"Flame", "Paw", "String", "Bird", "Barrier", "Sand", "Rubber", "Diamond"},
    Uncommon = {"Smoke", "Falcon", "Revive", "Spin", "Spring", "Bomb", "Chop", "Spike"},
    Common = {"Kilo", "Spin", "Chop", "Spike", "Bomb"}
}

function FruitDatabase.GetRarity(fruitName)
    for rarity, fruits in pairs(FruitDatabase) do
        if table.find(fruits, fruitName) then
            return rarity
        end
    end
    return "Unknown"
end

function FruitDatabase.IsLegendary(fruitName)
    return table.find(FruitDatabase.Legendary, fruitName) ~= nil
end

function FruitDatabase.IsMythical(fruitName)
    return table.find(FruitDatabase.Mythical, fruitName) ~= nil
end

-- Continue in next section...
                        -- Combat
                        Combat.EquipWeapon(getgenv().Config.SelectedWeapon)
                        Combat.Attack(boss)
                        Combat.SpamSkills()
                    end
                end
            else
                BossFarm.CurrentBoss = nil
                
                -- Collect drops after boss dies
                BossFarm.CollectDrops()
                
                -- Go to boss spawn location
                if bossName ~= "Auto" then
                    local bossInfo = BossDatabase.FindBoss(bossName)
                    if bossInfo and bossInfo.Pos then
                        Movement.TweenTo(bossInfo.Pos)
                    end
                else
                    local bossInfo = BossDatabase.GetBossForLevel()
                    if bossInfo and bossInfo.Pos then
                        Movement.TweenTo(bossInfo.Pos)
                    end
                end
            end
        end)
        
        if not success then
            Utils.Log("BossFarm Error: " .. tostring(err), "ERROR")
        end
    end)
    
    Manager:Connect("BossFarmLoop", bossLoop)
end

function BossFarm.Stop()
    BossFarm.Running = false
    BossFarm.CurrentBoss = nil
    Movement.StopTween()
    Manager:Disconnect("BossFarmLoop")
    Utils.Notify("Boss Farm", "Stopped", 2)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 15: FRUIT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local FruitSystem = {}
FruitSystem.FoundFruits = {}
FruitSystem.LastCheck = 0

function FruitSystem.GetAllFruits()
    local fruits = {}
    
    -- Check workspace for fruits
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.ToolTip == "Blox Fruit" then
            table.insert(fruits, obj)
        end
    end
    
    -- Check ground items
    local groundItems = Workspace:FindFirstChild("GroundItems")
    if groundItems then
        for _, item in pairs(groundItems:GetChildren()) do
            local tool = item:FindFirstChildOfClass("Tool")
            if tool and tool.ToolTip == "Blox Fruit" then
                table.insert(fruits, item)
            end
        end
    end
    
    return fruits
end

function FruitSystem.GetClosestFruit()
    local hrp = Utils.GetHRP()
    if not hrp then return nil end
    
    local closest, closestDist = nil, math.huge
    
    for _, fruit in pairs(FruitSystem.GetAllFruits()) do
        local pos = fruit:FindFirstChild("Handle") and fruit.Handle.Position or 
                    (fruit:IsA("BasePart") and fruit.Position) or
                    (fruit.PrimaryPart and fruit.PrimaryPart.Position)
        
        if pos then
            local dist = Utils.Distance(hrp.Position, pos)
            if dist < closestDist then
                -- Check target fruit preference
                local fruitName = fruit:IsA("Tool") and fruit.Name or (fruit:FindFirstChildOfClass("Tool") and fruit:FindFirstChildOfClass("Tool").Name)
                local targetFruit = getgenv().Config.TargetFruit or "Any"
                
                if targetFruit == "Any" then
                    closest = fruit
                    closestDist = dist
                elseif targetFruit == "Legendary" and FruitDatabase.IsLegendary(fruitName) then
                    closest = fruit
                    closestDist = dist
                elseif targetFruit == "Mythical" and FruitDatabase.IsMythical(fruitName) then
                    closest = fruit
                    closestDist = dist
                elseif fruitName and fruitName:find(targetFruit) then
                    closest = fruit
                    closestDist = dist
                end
            end
        end
    end
    
    return closest, closestDist
end

function FruitSystem.CollectFruit(fruit)
    if not fruit then return false end
    
    pcall(function()
        local handle = fruit:FindFirstChild("Handle")
        local pos = handle and handle.Position or 
                    (fruit:IsA("BasePart") and fruit.Position) or
                    (fruit.PrimaryPart and fruit.PrimaryPart.Position)
        
        if pos then
            local hrp = Utils.GetHRP()
            if hrp then
                hrp.CFrame = CFrame.new(pos) * CFrame.new(0, 3, 0)
                task.wait(0.3)
                
                if handle and firetouchinterest then
                    firetouchinterest(hrp, handle, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, handle, 1)
                end
            end
        end
    end)
    
    return true
end

function FruitSystem.StoreFruit()
    if not getgenv().Config.AutoStoreFruit then return end
    
    pcall(function()
        RemoteHandler.InvokeSafe("StoreFruit")
    end)
end

function FruitSystem.StartSniper()
    Utils.Log("Fruit Sniper started", "INFO")
    
    local sniperLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not getgenv().Config.FruitSniper then return end
            
            local fruit, dist = FruitSystem.GetClosestFruit()
            if fruit then
                local fruitName = fruit:IsA("Tool") and fruit.Name or "Unknown Fruit"
                
                if getgenv().Config.FruitNotification then
                    Utils.Notify("🍎 Fruit Found!", fruitName .. " - " .. math.floor(dist) .. "m", 5)
                end
                
                -- Teleport to fruit instantly
                FruitSystem.CollectFruit(fruit)
                
                -- Store if enabled
                task.wait(0.5)
                FruitSystem.StoreFruit()
            end
        end)
    end)
    
    Manager:Connect("FruitSniperLoop", sniperLoop)
end

function FruitSystem.StopSniper()
    Manager:Disconnect("FruitSniperLoop")
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 16: MIRAGE ISLAND SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local MirageSystem = {}
MirageSystem.Found = false
MirageSystem.LastCheck = 0

function MirageSystem.FindMirageIsland()
    -- Method 1: Direct search
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "MirageIsland" or obj.Name == "Mirage Island" or 
           (obj.Name:find("Mirage") and (obj:IsA("Model") or obj:IsA("BasePart"))) then
            return obj
        end
    end
    
    -- Method 2: Check Map folder
    local map = Workspace:FindFirstChild("Map")
    if map then
        for _, island in pairs(map:GetChildren()) do
            if island.Name:find("Mirage") then
                return island
            end
        end
    end
    
    -- Method 3: Check for Mirage-specific NPCs
    local npcs = Workspace:FindFirstChild("NPCs")
    if npcs then
        for _, npc in pairs(npcs:GetDescendants()) do
            if npc.Name == "Fruit Dealer" or npc.Name:find("Advanced Fruit") then
                -- Check if near mirage coordinates
                local pos = npc:FindFirstChild("HumanoidRootPart")
                if pos and pos.Position.Y > 70 and pos.Position.Z > 30000 then
                    return npc.Parent
                end
            end
        end
    end
    
    return nil
end

function MirageSystem.FindFruitDealer()
    for _, npc in pairs(Workspace:GetDescendants()) do
        if npc.Name == "Fruit Dealer" or npc.Name == "Advanced Fruit Dealer" or 
           npc.Name:find("Fruit") and npc.Name:find("Dealer") then
            if npc:FindFirstChild("HumanoidRootPart") then
                return npc
            end
        end
    end
    return nil
end

function MirageSystem.TeleportToMirage()
    local mirage = MirageSystem.FindMirageIsland()
    if mirage then
        local pos = mirage:FindFirstChild("HumanoidRootPart") or 
                    mirage:FindFirstChildWhichIsA("BasePart") or 
                    mirage.PrimaryPart
        
        if pos then
            Movement.TeleportSafe(pos.CFrame * CFrame.new(0, 50, 0))
            Utils.Notify("🏝️ Mirage Island", "Teleported!", 3)
            return true
        end
    end
    
    -- Fallback to known coordinates
    Movement.TeleportSafe(CFrame.new(925, 81, 34226))
    return false
end

function MirageSystem.StartAutoMirage()
    Utils.Log("Auto Mirage started", "INFO")
    
    local mirageLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not getgenv().Config.AutoMirage then return end
            
            -- Rate limit checks
            local now = tick()
            if now - MirageSystem.LastCheck < 1 then return end
            MirageSystem.LastCheck = now
            
            local mirage = MirageSystem.FindMirageIsland()
            if mirage and not MirageSystem.Found then
                MirageSystem.Found = true
                
                if getgenv().Config.MirageNotification then
                    Utils.Notify("🏝️ MIRAGE ISLAND!", "Found! Teleporting...", 5)
                end
                
                MirageSystem.TeleportToMirage()
                
                -- Find and go to fruit dealer
                task.wait(2)
                local dealer = MirageSystem.FindFruitDealer()
                if dealer then
                    local dealerHRP = dealer:FindFirstChild("HumanoidRootPart")
                    if dealerHRP then
                        Movement.TeleportSafe(dealerHRP.CFrame * CFrame.new(0, 0, 3))
                        Utils.Notify("🍎 Fruit Dealer", "Found on Mirage!", 3)
                    end
                end
            elseif not mirage then
                MirageSystem.Found = false
            end
        end)
    end)
    
    Manager:Connect("MirageLoop", mirageLoop)
end

function MirageSystem.StopAutoMirage()
    Manager:Disconnect("MirageLoop")
    MirageSystem.Found = false
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 17: RACE V4 SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local RaceV4System = {}

RaceV4System.TrialLocations = {
    Human = CFrame.new(-7894, 5548, -380),
    Mink = CFrame.new(-12489, 332, -7558),
    Fishman = CFrame.new(61366, 18, 1476),
    Skypiea = CFrame.new(-7648, 5586, -1414),
    Cyborg = CFrame.new(5331, 54, 4038),
    Ghoul = CFrame.new(-9479, 142, 5566),
}

RaceV4System.KeyLocations = {
    Minotaur = CFrame.new(-12489, 332, -7558),
    AncientAltar = CFrame.new(-5039, 313, -2991),
    TempleOfTime = CFrame.new(-7894, 5548, -380),
    CastleOnSea = CFrame.new(-5039, 313, -2991),
}

function RaceV4System.GetPlayerRace()
    return Utils.GetRace()
end

function RaceV4System.HasRaceV4()
    local data = Utils.GetPlayerData()
    if data then
        local raceV = data:FindFirstChild("RaceV") or data:FindFirstChild("RaceVersion") or data:FindFirstChild("RaceLevel")
        if raceV then
            return raceV.Value >= 4
        end
    end
    return false
end

function RaceV4System.FindMinotaur()
    local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, enemy in pairs(enemies:GetChildren()) do
            if enemy.Name == "Minotaur" or enemy.Name:find("Minotaur") then
                local hum = enemy:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    return enemy
                end
            end
        end
    end
    return nil
end

function RaceV4System.TeleportToTrial()
    local race = RaceV4System.GetPlayerRace()
    local pos = RaceV4System.TrialLocations[race] or RaceV4System.KeyLocations.TempleOfTime
    Movement.TeleportSafe(pos)
    Utils.Notify("Race V4", "Teleported to " .. race .. " trial!", 3)
end

function RaceV4System.TeleportToMinotaur()
    Movement.TeleportSafe(RaceV4System.KeyLocations.Minotaur)
    Utils.Notify("Race V4", "Teleported to Minotaur!", 3)
end

function RaceV4System.TeleportToAltar()
    Movement.TeleportSafe(RaceV4System.KeyLocations.AncientAltar)
    Utils.Notify("Race V4", "Teleported to Ancient Altar!", 3)
end

function RaceV4System.StartAutoRaceV4()
    if RaceV4System.HasRaceV4() then
        Utils.Notify("Race V4", "You already have Race V4!", 3)
        return
    end
    
    Utils.Log("Auto Race V4 started", "INFO")
    
    local raceV4Loop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not getgenv().Config.AutoRaceV4 then return end
            if RaceV4System.HasRaceV4() then
                getgenv().Config.AutoRaceV4 = false
                Utils.Notify("Race V4", "You got Race V4!", 5)
                return
            end
            
            if not Utils.IsAlive() then return end
            
            local hrp = Utils.GetHRP()
            if not hrp then return end
            
            -- Find and farm Minotaur
            local minotaur = RaceV4System.FindMinotaur()
            if minotaur then
                local minoHRP = minotaur:FindFirstChild("HumanoidRootPart")
                if minoHRP then
                    local dist = Utils.Distance(hrp.Position, minoHRP.Position)
                    if dist > 100 then
                        Movement.TweenTo(minoHRP.CFrame * CFrame.new(0, 20, 0))
                    else
                        Movement.StopTween()
                        hrp.CFrame = minoHRP.CFrame * CFrame.new(0, 15, 0)
                        Combat.EquipWeapon(getgenv().Config.SelectedWeapon)
                        Combat.Attack(minotaur)
                        Combat.SpamSkills()
                    end
                    return
                end
            end
            
            -- No Minotaur, go to spawn
            if getgenv().Config.AutoTrialV4 then
                Movement.TweenTo(RaceV4System.KeyLocations.Minotaur)
            end
        end)
    end)
    
    Manager:Connect("RaceV4Loop", raceV4Loop)
end

function RaceV4System.StopAutoRaceV4()
    Manager:Disconnect("RaceV4Loop")
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 18: RAID SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local RaidSystem = {}
RaidSystem.InRaid = false

function RaidSystem.IsInRaid()
    return Workspace:FindFirstChild("_raid") ~= nil
end

function RaidSystem.GetRaidMobs()
    local raid = Workspace:FindFirstChild("_raid")
    if not raid then return {} end
    
    local mobs = {}
    for _, mob in pairs(raid:GetDescendants()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            if mob:FindFirstChild("HumanoidRootPart") then
                table.insert(mobs, mob)
            end
        end
    end
    return mobs
end

function RaidSystem.GetClosestRaidMob()
    local hrp = Utils.GetHRP()
    if not hrp then return nil end
    
    local mobs = RaidSystem.GetRaidMobs()
    local closest, closestDist = nil, math.huge
    
    for _, mob in pairs(mobs) do
        local mobHRP = mob:FindFirstChild("HumanoidRootPart")
        if mobHRP then
            local dist = Utils.Distance(hrp.Position, mobHRP.Position)
            if dist < closestDist then
                closest = mob
                closestDist = dist
            end
        end
    end
    
    return closest, closestDist
end

function RaidSystem.BuyChip()
    if not getgenv().Config.AutoBuyChip then return end
    pcall(function()
        RemoteHandler.InvokeSafe("BuyRaidChip")
    end)
end

function RaidSystem.StartRaid(raidName)
    pcall(function()
        RemoteHandler.InvokeSafe("StartRaid", raidName)
    end)
end

function RaidSystem.StartAutoRaid()
    Utils.Log("Auto Raid started", "INFO")
    
    local raidLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not getgenv().Config.AutoRaid then return end
            if not Utils.IsAlive() then return end
            
            if RaidSystem.IsInRaid() then
                RaidSystem.InRaid = true
                
                local mob, dist = RaidSystem.GetClosestRaidMob()
                if mob then
                    local hrp = Utils.GetHRP()
                    local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                    
                    if hrp and mobHRP then
                        if dist > 100 then
                            Movement.TweenTo(mobHRP.CFrame * CFrame.new(0, 15, 0))
                        else
                            Movement.StopTween()
                            hrp.CFrame = mobHRP.CFrame * CFrame.new(0, 12, 0)
                            Combat.EquipWeapon(getgenv().Config.SelectedWeapon)
                            Combat.Attack(mob)
                            Combat.SpamSkills()
                        end
                    end
                else
                    -- No mobs, maybe next island
                    RemoteHandler.InvokeSafe("RaidIsland")
                end
            else
                RaidSystem.InRaid = false
            end
        end)
    end)
    
    Manager:Connect("RaidLoop", raidLoop)
end

function RaidSystem.StopAutoRaid()
    Manager:Disconnect("RaidLoop")
    RaidSystem.InRaid = false
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 19: SEA EVENTS SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local SeaEvents = {}

function SeaEvents.FindSeaBeast()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "SeaBeast" or obj.Name:find("Sea Beast") or obj.Name == "SeaBeast1" then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                return obj
            end
        end
    end
    return nil
end

function SeaEvents.FindTerrorShark()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Terror Shark" or obj.Name:find("TerrorShark") then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                return obj
            end
        end
    end
    return nil
end

function SeaEvents.FindLeviathan()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Leviathan" or obj.Name:find("Leviathan") then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                return obj
            end
        end
    end
    return nil
end

function SeaEvents.StartAutoSeaEvents()
    Utils.Log("Auto Sea Events started", "INFO")
    
    local seaLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not getgenv().Config.AutoSeaEvents then return end
            if not Utils.IsAlive() then return end
            
            local hrp = Utils.GetHRP()
            if not hrp then return end
            
            local target = nil
            
            -- Priority: Leviathan > Terror Shark > Sea Beast
            if getgenv().Config.AutoLeviathan then
                target = SeaEvents.FindLeviathan()
            end
            
            if not target and getgenv().Config.AutoTerrorShark then
                target = SeaEvents.FindTerrorShark()
            end
            
            if not target and getgenv().Config.AutoSeaBeast then
                target = SeaEvents.FindSeaBeast()
            end
            
            if target then
                local targetHRP = target:FindFirstChild("HumanoidRootPart") or 
                                  target:FindFirstChildWhichIsA("BasePart")
                
                if targetHRP then
                    local dist = Utils.Distance(hrp.Position, targetHRP.Position)
                    
                    if dist > 100 then
                        Movement.TweenTo(targetHRP.CFrame * CFrame.new(0, 50, 0))
                    else
                        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 40, 0)
                        Combat.EquipWeapon(getgenv().Config.SelectedWeapon)
                        Combat.Attack(target)
                        Combat.SpamSkills()
                    end
                end
            end
        end)
    end)
    
    Manager:Connect("SeaEventsLoop", seaLoop)
end

function SeaEvents.StopAutoSeaEvents()
    Manager:Disconnect("SeaEventsLoop")
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 20: ESP SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local ESP = {}
ESP.Objects = {}
ESP.Colors = {
    Fruit = Color3.fromRGB(255, 165, 0),
    LegendaryFruit = Color3.fromRGB(255, 215, 0),
    Boss = Color3.fromRGB(255, 0, 0),
    Player = Color3.fromRGB(0, 255, 0),
    Enemy = Color3.fromRGB(255, 0, 0),
    Chest = Color3.fromRGB(255, 255, 0),
    Flower = Color3.fromRGB(0, 255, 255),
    NPC = Color3.fromRGB(255, 255, 255),
    QuestMob = Color3.fromRGB(255, 100, 255),
    Mirage = Color3.fromRGB(0, 255, 255),
    Dealer = Color3.fromRGB(255, 215, 0),
}

function ESP.CreateESP(object, color, text, showHealth)
    if ESP.Objects[object] then return ESP.Objects[object] end
    
    local success = pcall(function()
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_" .. tostring(object)
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Text = text
        label.Parent = billboard
        
        local adornee = object:IsA("BasePart") and object or 
                        (object:FindFirstChild("HumanoidRootPart") or 
                         object:FindFirstChild("Handle") or
                         object:FindFirstChildWhichIsA("BasePart"))
        
        if adornee then
            billboard.Adornee = adornee
            billboard.Parent = CoreGui
            
            local updateConn = RunService.RenderStepped:Connect(function()
                if not object or not object.Parent then
                    billboard:Destroy()
                    ESP.Objects[object] = nil
                    return
                end
                
                local hrp = Utils.GetHRP()
                if hrp and adornee and adornee.Parent then
                    local dist = math.floor(Utils.Distance(hrp.Position, adornee.Position))
                    local displayText = text
                    
                    if getgenv().Config.ESPDistance then
                        displayText = displayText .. " [" .. dist .. "m]"
                    end
                    
                    if showHealth and getgenv().Config.ESPHealth then
                        local hum = object:FindFirstChild("Humanoid")
                        if hum then
                            local hp = math.floor(hum.Health)
                            local maxHp = math.floor(hum.MaxHealth)
                            displayText = displayText .. "\n❤️ " .. hp .. "/" .. maxHp
                        end
                    end
                    
                    label.Text = displayText
                end
            end)
            
            ESP.Objects[object] = {Billboard = billboard, Connection = updateConn}
        end
    end)
    
    return ESP.Objects[object]
end

function ESP.RemoveESP(object)
    if ESP.Objects[object] then
        pcall(function()
            ESP.Objects[object].Billboard:Destroy()
            ESP.Objects[object].Connection:Disconnect()
        end)
        ESP.Objects[object] = nil
    end
end

function ESP.ClearAll()
    for object, _ in pairs(ESP.Objects) do
        ESP.RemoveESP(object)
    end
    ESP.Objects = {}
end

function ESP.UpdateAll()
    pcall(function()
        if not getgenv().Config then return end
        
        -- Boss ESP
        if getgenv().Config.ESPBoss then
            local enemies = Workspace:FindFirstChild("Enemies")
            if enemies then
                for _, enemy in pairs(enemies:GetChildren()) do
                    for _, boss in ipairs(BossDatabase) do
                        if enemy.Name == boss.Name and not ESP.Objects[enemy] then
                            ESP.CreateESP(enemy, ESP.Colors.Boss, "👹 " .. boss.Name, true)
                        end
                    end
                end
            end
        end
        
        -- Quest Mob ESP
        if getgenv().Config.ESPQuestMobs then
            local questData = QuestDatabase.GetQuestForLevel()
            if questData then
                local enemies = Workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, enemy in pairs(enemies:GetChildren()) do
                        if enemy.Name == questData.MobName and not ESP.Objects[enemy] then
                            ESP.CreateESP(enemy, ESP.Colors.QuestMob, "⚔️ " .. enemy.Name, true)
                        end
                    end
                end
            end
        end
        
        -- Mirage Island ESP
        if getgenv().Config.ESPMirage then
            local mirage = MirageSystem.FindMirageIsland()
            if mirage and not ESP.Objects[mirage] then
                ESP.CreateESP(mirage, ESP.Colors.Mirage, "🏝️ MIRAGE ISLAND", false)
                if getgenv().Config.MirageNotification then
                    Utils.Notify("🏝️ Mirage!", "Mirage Island detected!", 5)
                end
            end
        end
        
        -- Mirage Fruit Dealer ESP
        if getgenv().Config.ESPMirageDealer then
            local dealer = MirageSystem.FindFruitDealer()
            if dealer and not ESP.Objects[dealer] then
                ESP.CreateESP(dealer, ESP.Colors.Dealer, "🍎 FRUIT DEALER", false)
            end
        end
        
        -- Fruit ESP
        if getgenv().Config.ESPFruit or getgenv().Config.FruitESP then
            for _, fruit in pairs(FruitSystem.GetAllFruits()) do
                if not ESP.Objects[fruit] then
                    local fruitName = fruit:IsA("Tool") and fruit.Name or "Fruit"
                    local rarity = FruitDatabase.GetRarity(fruitName)
                    local color = (rarity == "Legendary" or rarity == "Mythical") and ESP.Colors.LegendaryFruit or ESP.Colors.Fruit
                    ESP.CreateESP(fruit, color, "🍎 " .. fruitName .. " (" .. rarity .. ")", false)
                end
            end
        end
        
        -- Player ESP
        if getgenv().Config.ESPPlayer then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not ESP.Objects[player.Character] then
                        local bounty = ""
                        pcall(function()
                            local data = player:FindFirstChild("Data")
                            if data and data:FindFirstChild("Bounty") then
                                bounty = " 💰" .. data.Bounty.Value
                            end
                        end)
                        ESP.CreateESP(player.Character, ESP.Colors.Player, "👤 " .. player.Name .. bounty, true)
                    end
                end
            end
        end
        
        -- Chest ESP
        if getgenv().Config.ESPChest then
            for _, chest in pairs(Workspace:GetDescendants()) do
                if (chest.Name == "Chest" or chest.Name:find("Chest")) and not ESP.Objects[chest] then
                    if chest:IsA("Model") or chest:IsA("BasePart") then
                        ESP.CreateESP(chest, ESP.Colors.Chest, "📦 Chest", false)
                    end
                end
            end
        end
        
        -- Flower ESP
        if getgenv().Config.ESPFlower then
            for _, flower in pairs(Workspace:GetDescendants()) do
                if flower.Name:find("Flower") and not ESP.Objects[flower] then
                    local color = flower.Name:find("Blue") and Color3.fromRGB(0, 100, 255) or ESP.Colors.Flower
                    ESP.CreateESP(flower, color, "🌸 " .. flower.Name, false)
                end
            end
        end
    end)
end

function ESP.StartLoop()
    local espLoop = RunService.RenderStepped:Connect(function()
        pcall(ESP.UpdateAll)
    end)
    Manager:Connect("ESPLoop", espLoop)
end

function ESP.StopLoop()
    Manager:Disconnect("ESPLoop")
    ESP.ClearAll()
end
-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 21: ANTI-DETECTION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local AntiDetection = {}
AntiDetection.AdminInServer = false
AntiDetection.LastCheck = 0

local AdminList = {
    "Rip_indra",
    "rip_indra",
    "mygame43",
    "Dumped",
    "Xpolsion",
    -- Add more known admins/staff
}

function AntiDetection.IsAdmin(player)
    -- Check by name
    if table.find(AdminList, player.Name) then
        return true
    end
    
    -- Check by group rank (Blox Fruits group)
    pcall(function()
        local groupId = 3268906 -- Blox Fruits group ID
        local rank = player:GetRankInGroup(groupId)
        if rank >= 200 then -- High rank = likely staff
            return true
        end
    end)
    
    return false
end

function AntiDetection.CheckForAdmins()
    if not getgenv().Config.AutoDisableOnAdmin then return false end
    
    for _, player in pairs(Players:GetPlayers()) do
        if AntiDetection.IsAdmin(player) then
            return true
        end
    end
    
    return false
end

function AntiDetection.DisableAllFeatures()
    getgenv().Config.AutoFarm = false
    getgenv().Config.AutoFarmBoss = false
    getgenv().Config.AutoRaid = false
    getgenv().Config.AutoMirage = false
    getgenv().Config.AutoRaceV4 = false
    getgenv().Config.FruitSniper = false
    getgenv().Config.Fly = false
    getgenv().Config.NoClip = false
    
    AutoFarm.Stop()
    BossFarm.Stop()
    RaidSystem.StopAutoRaid()
    MirageSystem.StopAutoMirage()
    RaceV4System.StopAutoRaceV4()
    FruitSystem.StopSniper()
    SeaEvents.StopAutoSeaEvents()
    Movement.StopTween()
    ESP.ClearAll()
    
    Utils.Notify("⚠️ ADMIN DETECTED", "All features disabled!", 10)
    Utils.Log("Admin detected! All features disabled!", "WARNING")
end

function AntiDetection.StartMonitoring()
    -- Monitor player joins
    Players.PlayerAdded:Connect(function(player)
        if AntiDetection.IsAdmin(player) then
            AntiDetection.AdminInServer = true
            AntiDetection.DisableAllFeatures()
        end
    end)
    
    -- Periodic check
    local monitorLoop = RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - AntiDetection.LastCheck < 5 then return end
        AntiDetection.LastCheck = now
        
        if getgenv().Config.AutoDisableOnAdmin then
            if AntiDetection.CheckForAdmins() then
                if not AntiDetection.AdminInServer then
                    AntiDetection.AdminInServer = true
                    AntiDetection.DisableAllFeatures()
                end
            else
                AntiDetection.AdminInServer = false
            end
        end
    end)
    
    Manager:Connect("AdminMonitor", monitorLoop)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 22: UTILITY FEATURES
-- ═══════════════════════════════════════════════════════════════════════════════

local UtilityFeatures = {}

function UtilityFeatures.AntiAFK()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        local conn = LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            Utils.Log("Anti-AFK triggered", "INFO")
        end)
        Manager:Connect("AntiAFK", conn)
    end)
end

function UtilityFeatures.FPSBooster(enable)
    pcall(function()
        if enable then
            -- Reduce quality
            settings().Rendering.QualityLevel = 1
            
            -- Disable effects
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
                if v:IsA("Decal") then
                    v.Transparency = 1
                end
                if v:IsA("Part") or v:IsA("MeshPart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                end
            end
            
            -- Lighting
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9999999
            
            Utils.Log("FPS Booster enabled", "INFO")
        else
            settings().Rendering.QualityLevel = 10
            Lighting.GlobalShadows = true
        end
    end)
end

function UtilityFeatures.RemoveFog()
    pcall(function()
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        
        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
                v.Enabled = false
            end
        end
    end)
end

function UtilityFeatures.InfiniteEnergy()
    local energyLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not getgenv().Config.InfiniteEnergy then return end
            
            local char = Utils.GetCharacter()
            if char then
                local energy = char:FindFirstChild("Energy")
                if energy then
                    energy.Value = energy.MaxValue or 1000
                end
            end
        end)
    end)
    Manager:Connect("InfiniteEnergy", energyLoop)
end

function UtilityFeatures.ServerHop()
    SaveConfig()
    Utils.Notify("Server Hop", "Finding new server...", 3)
    
    task.wait(1)
    
    pcall(function()
        local servers = HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        )
        
        if servers and servers.data then
            for _, server in ipairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
        
        -- Fallback: just rejoin
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

function UtilityFeatures.AutoRejoin()
    if not getgenv().Config.AutoRejoin then return end
    
    local teleportConn
    teleportConn = LocalPlayer.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Failed then
            task.wait(5)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
    Manager:Connect("AutoRejoin", teleportConn)
end

function UtilityFeatures.PanicButton()
    -- Instantly disable everything
    getgenv().Config.AutoFarm = false
    getgenv().Config.AutoFarmBoss = false
    getgenv().Config.AutoRaid = false
    getgenv().Config.AutoMirage = false
    getgenv().Config.AutoRaceV4 = false
    getgenv().Config.FruitSniper = false
    getgenv().Config.AutoSeaEvents = false
    getgenv().Config.Fly = false
    getgenv().Config.NoClip = false
    getgenv().Config.KillAura = false
    
    AutoFarm.Stop()
    BossFarm.Stop()
    RaidSystem.StopAutoRaid()
    MirageSystem.StopAutoMirage()
    RaceV4System.StopAutoRaceV4()
    FruitSystem.StopSniper()
    SeaEvents.StopAutoSeaEvents()
    Movement.StopTween()
    Movement.Fly(false)
    Movement.NoClip(false)
    ESP.ClearAll()
    
    -- Reset speed
    Movement.SetSpeed(16)
    Movement.SetJumpPower(50)
    
    Utils.Notify("🛑 PANIC!", "All features disabled!", 5)
    Utils.Log("Panic button pressed - all features disabled", "WARNING")
end

function UtilityFeatures.StartAll()
    -- Anti-AFK
    if getgenv().Config.AntiAFK then
        UtilityFeatures.AntiAFK()
    end
    
    -- FPS Booster
    if getgenv().Config.FPSBooster then
        UtilityFeatures.FPSBooster(true)
    end
    
    -- Remove fog
    UtilityFeatures.RemoveFog()
    
    -- Infinite Energy
    UtilityFeatures.InfiniteEnergy()
    
    -- Auto Rejoin
    UtilityFeatures.AutoRejoin()
    
    -- Movement speed/jump loop
    local movementLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if getgenv().Config.WalkSpeed > 16 then
                Movement.SetSpeed(getgenv().Config.WalkSpeed)
            end
            if getgenv().Config.JumpPower > 50 then
                Movement.SetJumpPower(getgenv().Config.JumpPower)
            end
        end)
    end)
    Manager:Connect("MovementLoop", movementLoop)
    
    -- Fly
    if getgenv().Config.Fly then
        Movement.Fly(true)
    end
    
    -- NoClip
    if getgenv().Config.NoClip then
        Movement.NoClip(true)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 23: TELEPORT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local TeleportSystem = {}

function TeleportSystem.ToIsland(islandName)
    local pos, sea = IslandDatabase.GetIsland(islandName)
    if pos then
        Movement.TeleportSafe(pos)
        Utils.Notify("Teleport", "Teleported to " .. islandName, 2)
        return true
    end
    Utils.Notify("Teleport", "Island not found!", 2)
    return false
end

function TeleportSystem.ToBoss(bossName)
    local boss = BossDatabase.FindBoss(bossName)
    if boss then
        Movement.TeleportSafe(boss.Pos)
        Utils.Notify("Teleport", "Teleported to " .. boss.Name, 2)
        return true
    end
    Utils.Notify("Teleport", "Boss not found!", 2)
    return false
end

function TeleportSystem.ToPlayer(playerName)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(playerName:lower()) then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                Movement.TeleportSafe(player.Character.HumanoidRootPart.CFrame)
                Utils.Notify("Teleport", "Teleported to " .. player.Name, 2)
                return true
            end
        end
    end
    Utils.Notify("Teleport", "Player not found!", 2)
    return false
end

function TeleportSystem.ToQuestGiver()
    local questData = QuestDatabase.GetQuestForLevel()
    if questData and questData.QuestPos then
        Movement.TeleportSafe(questData.QuestPos)
        Utils.Notify("Teleport", "Teleported to Quest Giver", 2)
        return true
    end
    return false
end

function TeleportSystem.ToMobs()
    local questData = QuestDatabase.GetQuestForLevel()
    if questData and questData.MobPos then
        Movement.TeleportSafe(questData.MobPos)
        Utils.Notify("Teleport", "Teleported to Mobs", 2)
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 24: UI SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local function CreateUI()
    local OrionLib = nil
    
    -- Try multiple sources
    local sources = {
        'https://raw.githubusercontent.com/shlexware/Orion/main/source',
        'https://raw.githubusercontent.com/jensonhirst/Orion/main/source'
    }
    
    for _, source in ipairs(sources) do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(source))()
        end)
        if success and result then
            OrionLib = result
            break
        end
    end
    
    if not OrionLib then
        warn("[Blox Ultimate] Failed to load UI library")
        Utils.Notify("UI Error", "Could not load UI library", 5)
        return nil
    end
    
    local Window = OrionLib:MakeWindow({
        Name = "💎 Blox Fruits Ultimate v10.0",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "BloxUltimateV10",
        IntroEnabled = false
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: AUTO FARM
    -- ═══════════════════════════════════════════
    local FarmTab = Window:MakeTab({Name = "⚔️ Auto Farm", Icon = "rbxassetid://4483345998"})
    
    FarmTab:AddSection({Name = "🔥 Main Farm"})
    
    FarmTab:AddToggle({
        Name = "Auto Farm Level",
        Default = false,
        Callback = function(v)
            getgenv().Config.AutoFarm = v
            getgenv().Config.AutoQuest = v
            if v then AutoFarm.Start() else AutoFarm.Stop() end
        end
    })
    
    FarmTab:AddToggle({
        Name = "Smart Farm Mode",
        Default = true,
        Callback = function(v) getgenv().Config.SmartFarm = v end
    })
    
    FarmTab:AddToggle({
        Name = "Auto Farm Boss",
        Default = false,
        Callback = function(v)
            getgenv().Config.AutoFarmBoss = v
            if v then BossFarm.Start() else BossFarm.Stop() end
        end
    })
    
    FarmTab:AddToggle({
        Name = "Auto Collect Drops",
        Default = true,
        Callback = function(v) getgenv().Config.AutoCollectDrops = v end
    })
    
    FarmTab:AddToggle({
        Name = "Server Hop (No Mobs)",
        Default = false,
        Callback = function(v) getgenv().Config.ServerHopNoMobs = v end
    })
    
    FarmTab:AddSection({Name = "⚔️ Weapon Settings"})
    
    FarmTab:AddDropdown({
        Name = "Main Weapon",
        Default = "Combat",
        Options = {"Combat", "Melee", "Sword", "Blox Fruit", "Gun"},
        Callback = function(v) getgenv().Config.SelectedWeapon = v end
    })
    
    FarmTab:AddToggle({
        Name = "Auto Switch Weapon",
        Default = false,
        Callback = function(v) getgenv().Config.AutoSwitchWeapon = v end
    })
    
    FarmTab:AddSlider({
        Name = "Mastery Switch HP %",
        Min = 10,
        Max = 60,
        Default = 30,
        Increment = 5,
        Callback = function(v) getgenv().Config.MasteryHealthSwitch = v end
    })
    
    FarmTab:AddSection({Name = "🛡️ Safety"})
    
    FarmTab:AddToggle({
        Name = "Safe Mode",
        Default = true,
        Callback = function(v) getgenv().Config.SafeMode = v end
    })
    
    FarmTab:AddSlider({
        Name = "Safe Health %",
        Min = 10,
        Max = 50,
        Default = 30,
        Increment = 5,
        Callback = function(v) getgenv().Config.SafeHealthPercent = v end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: MIRAGE ISLAND
    -- ═══════════════════════════════════════════
    local MirageTab = Window:MakeTab({Name = "🏝️ Mirage Island", Icon = "rbxassetid://4483345998"})
    
    MirageTab:AddToggle({
        Name = "Auto Mirage Island",
        Default = false,
        Callback = function(v)
            getgenv().Config.AutoMirage = v
            if v then MirageSystem.StartAutoMirage() else MirageSystem.StopAutoMirage() end
        end
    })
    
    MirageTab:AddToggle({
        Name = "ESP Mirage Island",
        Default = true,
        Callback = function(v) getgenv().Config.ESPMirage = v end
    })
    
    MirageTab:AddToggle({
        Name = "ESP Fruit Dealer",
        Default = true,
        Callback = function(v) getgenv().Config.ESPMirageDealer = v end
    })
    
    MirageTab:AddToggle({
        Name = "Mirage Notification",
        Default = true,
        Callback = function(v) getgenv().Config.MirageNotification = v end
    })
    
    MirageTab:AddButton({
        Name = "📍 TP to Mirage Island",
        Callback = function() MirageSystem.TeleportToMirage() end
    })
    
    MirageTab:AddLabel("Mirage Island spawns randomly in Third Sea!")
    
    -- ═══════════════════════════════════════════
    -- TAB: RACE V4
    -- ═══════════════════════════════════════════
    local RaceTab = Window:MakeTab({Name = "🧬 Race V4", Icon = "rbxassetid://4483345998"})
    
    RaceTab:AddToggle({
        Name = "Auto Race V4 (Farm Minotaur)",
        Default = false,
        Callback = function(v)
            getgenv().Config.AutoRaceV4 = v
            if v then RaceV4System.StartAutoRaceV4() else RaceV4System.StopAutoRaceV4() end
        end
    })
    
    RaceTab:AddToggle({
        Name = "Auto Go to Trial",
        Default = false,
        Callback = function(v) getgenv().Config.AutoTrialV4 = v end
    })
    
    RaceTab:AddButton({
        Name = "📍 TP to Minotaur",
        Callback = function() RaceV4System.TeleportToMinotaur() end
    })
    
    RaceTab:AddButton({
        Name = "📍 TP to Ancient Altar",
        Callback = function() RaceV4System.TeleportToAltar() end
    })
    
    RaceTab:AddButton({
        Name = "📍 TP to Race Trial",
        Callback = function() RaceV4System.TeleportToTrial() end
    })
    
    RaceTab:AddLabel("Your Race: " .. Utils.GetRace())
    
    -- ═══════════════════════════════════════════
    -- TAB: FRUITS
    -- ═══════════════════════════════════════════
    local FruitTab = Window:MakeTab({Name = "🍎 Fruits", Icon = "rbxassetid://4483345998"})
    
    FruitTab:AddToggle({
        Name = "Fruit Sniper",
        Default = false,
        Callback = function(v)
            getgenv().Config.FruitSniper = v
            if v then FruitSystem.StartSniper() else FruitSystem.StopSniper() end
        end
    })
    
    FruitTab:AddToggle({
        Name = "Fruit ESP",
        Default = false,
        Callback = function(v) getgenv().Config.FruitESP = v end
    })
    
    FruitTab:AddToggle({
        Name = "Auto Store Fruit",
        Default = false,
        Callback = function(v) getgenv().Config.AutoStoreFruit = v end
    })
    
    FruitTab:AddToggle({
        Name = "Fruit Notification",
        Default = true,
        Callback = function(v) getgenv().Config.FruitNotification = v end
    })
    
    FruitTab:AddDropdown({
        Name = "Target Fruit",
        Default = "Any",
        Options = {"Any", "Legendary", "Mythical", "Dragon", "Leopard", "Spirit", "Dough", "Buddha"},
        Callback = function(v) getgenv().Config.TargetFruit = v end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: RAIDS & SEA
    -- ═══════════════════════════════════════════
    local RaidTab = Window:MakeTab({Name = "🏴‍☠️ Raids & Sea", Icon = "rbxassetid://4483345998"})
    
    RaidTab:AddSection({Name = "⚔️ Raids"})
    
    RaidTab:AddToggle({
        Name = "Auto Raid",
        Default = false,
        Callback = function(v)
            getgenv().Config.AutoRaid = v
            if v then RaidSystem.StartAutoRaid() else RaidSystem.StopAutoRaid() end
        end
    })
    
    RaidTab:AddToggle({
        Name = "Auto Buy Chip",
        Default = false,
        Callback = function(v) getgenv().Config.AutoBuyChip = v end
    })
    
    RaidTab:AddSection({Name = "🌊 Sea Events"})
    
    RaidTab:AddToggle({
        Name = "Auto Sea Events",
        Default = false,
        Callback = function(v)
            getgenv().Config.AutoSeaEvents = v
            if v then SeaEvents.StartAutoSeaEvents() else SeaEvents.StopAutoSeaEvents() end
        end
    })
    
    RaidTab:AddToggle({
        Name = "Auto Sea Beast",
        Default = false,
        Callback = function(v) getgenv().Config.AutoSeaBeast = v end
    })
    
    RaidTab:AddToggle({
        Name = "Auto Terror Shark",
        Default = false,
        Callback = function(v) getgenv().Config.AutoTerrorShark = v end
    })
    
    RaidTab:AddToggle({
        Name = "Auto Leviathan",
        Default = false,
        Callback = function(v) getgenv().Config.AutoLeviathan = v end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: COMBAT
    -- ═══════════════════════════════════════════
    local CombatTab = Window:MakeTab({Name = "⚡ Combat", Icon = "rbxassetid://4483345998"})
    
    CombatTab:AddToggle({
        Name = "Auto Skill",
        Default = true,
        Callback = function(v) getgenv().Config.AutoSkill = v end
    })
    
    CombatTab:AddToggle({
        Name = "Fast Attack",
        Default = true,
        Callback = function(v) getgenv().Config.FastAttack = v end
    })
    
    CombatTab:AddToggle({
        Name = "Auto Buso Haki",
        Default = true,
        Callback = function(v) getgenv().Config.AutoBusoHaki = v end
    })
    
    CombatTab:AddToggle({
        Name = "Auto Ken Haki",
        Default = false,
        Callback = function(v) getgenv().Config.AutoKenHaki = v end
    })
    
    CombatTab:AddToggle({
        Name = "Kill Aura",
        Default = false,
        Callback = function(v) getgenv().Config.KillAura = v end
    })
    
    CombatTab:AddToggle({
        Name = "Bring Mobs",
        Default = true,
        Callback = function(v) getgenv().Config.BringMobs = v end
    })
    
    CombatTab:AddToggle({
        Name = "Expand Hitbox",
        Default = true,
        Callback = function(v) getgenv().Config.ExpandHitbox = v end
    })
    
    CombatTab:AddSlider({
        Name = "Hitbox Size",
        Min = 10,
        Max = 100,
        Default = 50,
        Increment = 5,
        Callback = function(v) getgenv().Config.HitboxSize = v end
    })
    
    CombatTab:AddSlider({
        Name = "Bring Distance",
        Min = 20,
        Max = 200,
        Default = 100,
        Increment = 10,
        Callback = function(v) getgenv().Config.BringDistance = v end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: ESP
    -- ═══════════════════════════════════════════
    local ESPTab = Window:MakeTab({Name = "👁️ ESP", Icon = "rbxassetid://4483345998"})
    
    ESPTab:AddToggle({
        Name = "Boss ESP",
        Default = true,
        Callback = function(v) getgenv().Config.ESPBoss = v end
    })
    
    ESPTab:AddToggle({
        Name = "Quest Mob ESP",
        Default = true,
        Callback = function(v) getgenv().Config.ESPQuestMobs = v end
    })
    
    ESPTab:AddToggle({
        Name = "Mirage Island ESP",
        Default = true,
        Callback = function(v) getgenv().Config.ESPMirage = v end
    })
    
    ESPTab:AddToggle({
        Name = "Fruit Dealer ESP",
        Default = true,
        Callback = function(v) getgenv().Config.ESPMirageDealer = v end
    })
    
    ESPTab:AddToggle({
        Name = "Fruit ESP",
        Default = false,
        Callback = function(v) getgenv().Config.ESPFruit = v end
    })
    
    ESPTab:AddToggle({
        Name = "Player ESP",
        Default = false,
        Callback = function(v) getgenv().Config.ESPPlayer = v end
    })
    
    ESPTab:AddToggle({
        Name = "Chest ESP",
        Default = false,
        Callback = function(v) getgenv().Config.ESPChest = v end
    })
    
    ESPTab:AddToggle({
        Name = "Flower ESP",
        Default = false,
        Callback = function(v) getgenv().Config.ESPFlower = v end
    })
    
    ESPTab:AddToggle({
        Name = "Show Distance",
        Default = true,
        Callback = function(v) getgenv().Config.ESPDistance = v end
    })
    
    ESPTab:AddToggle({
        Name = "Show Health",
        Default = true,
        Callback = function(v) getgenv().Config.ESPHealth = v end
    })
    
    ESPTab:AddButton({
        Name = "🗑️ Clear All ESP",
        Callback = function() ESP.ClearAll() end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: TELEPORT
    -- ═══════════════════════════════════════════
    local TPTab = Window:MakeTab({Name = "🗺️ Teleport", Icon = "rbxassetid://4483345998"})
    
    local islandList = {}
    for name, _ in pairs(IslandDatabase) do
        table.insert(islandList, name)
    end
    table.sort(islandList)
    
    TPTab:AddDropdown({
        Name = "Select Island",
        Default = "Starter Island",
        Options = islandList,
        Callback = function(v) getgenv().Config.SelectedIsland = v end
    })
    
    TPTab:AddButton({
        Name = "📍 Teleport to Island",
        Callback = function() TeleportSystem.ToIsland(getgenv().Config.SelectedIsland) end
    })
    
    local bossList = {"Auto"}
    for _, boss in ipairs(BossDatabase) do
        table.insert(bossList, boss.Name)
    end
    
    TPTab:AddDropdown({
        Name = "Select Boss",
        Default = "Auto",
        Options = bossList,
        Callback = function(v) getgenv().Config.SelectedBoss = v end
    })
    
    TPTab:AddButton({
        Name = "📍 Teleport to Boss",
        Callback = function() TeleportSystem.ToBoss(getgenv().Config.SelectedBoss) end
    })
    
    TPTab:AddButton({
        Name = "📍 TP to Quest Giver",
        Callback = function() TeleportSystem.ToQuestGiver() end
    })
    
    TPTab:AddButton({
        Name = "📍 TP to Mobs",
        Callback = function() TeleportSystem.ToMobs() end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: UTILITY
    -- ═══════════════════════════════════════════
    local UtilTab = Window:MakeTab({Name = "⚙️ Utility", Icon = "rbxassetid://4483345998"})
    
    UtilTab:AddSection({Name = "🏃 Movement"})
    
    UtilTab:AddSlider({
        Name = "Walk Speed",
        Min = 16,
        Max = 500,
        Default = 16,
        Increment = 10,
        Callback = function(v) getgenv().Config.WalkSpeed = v end
    })
    
    UtilTab:AddSlider({
        Name = "Jump Power",
        Min = 50,
        Max = 500,
        Default = 50,
        Increment = 10,
        Callback = function(v) getgenv().Config.JumpPower = v end
    })
    
    UtilTab:AddToggle({
        Name = "Fly",
        Default = false,
        Callback = function(v)
            getgenv().Config.Fly = v
            Movement.Fly(v)
        end
    })
    
    UtilTab:AddSlider({
        Name = "Fly Speed",
        Min = 50,
        Max = 500,
        Default = 150,
        Increment = 25,
        Callback = function(v) getgenv().Config.FlySpeed = v end
    })
    
    UtilTab:AddToggle({
        Name = "NoClip",
        Default = false,
        Callback = function(v)
            getgenv().Config.NoClip = v
            Movement.NoClip(v)
        end
    })
    
    UtilTab:AddToggle({
        Name = "Infinite Energy",
        Default = false,
        Callback = function(v) getgenv().Config.InfiniteEnergy = v end
    })
    
    UtilTab:AddSection({Name = "🛡️ Safety & Performance"})
    
    UtilTab:AddToggle({
        Name = "Anti AFK",
        Default = true,
        Callback = function(v)
            getgenv().Config.AntiAFK = v
            if v then UtilityFeatures.AntiAFK() end
        end
    })
    
    UtilTab:AddToggle({
        Name = "Auto Disable on Admin",
        Default = true,
        Callback = function(v) getgenv().Config.AutoDisableOnAdmin = v end
    })
    
    UtilTab:AddToggle({
        Name = "FPS Booster",
        Default = false,
        Callback = function(v)
            getgenv().Config.FPSBooster = v
            UtilityFeatures.FPSBooster(v)
        end
    })
    
    UtilTab:AddToggle({
        Name = "Auto Rejoin",
        Default = false,
        Callback = function(v) getgenv().Config.AutoRejoin = v end
    })
    
    UtilTab:AddButton({
        Name = "🔄 Server Hop",
        Callback = function() UtilityFeatures.ServerHop() end
    })
    
    UtilTab:AddButton({
        Name = "🛑 PANIC BUTTON (Stop All)",
        Callback = function() UtilityFeatures.PanicButton() end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: SETTINGS
    -- ═══════════════════════════════════════════
    local SetTab = Window:MakeTab({Name = "💾 Settings", Icon = "rbxassetid://4483345998"})
    
    SetTab:AddButton({
        Name = "💾 Save Config",
        Callback = function() SaveConfig() end
    })
    
    SetTab:AddButton({
        Name = "📂 Load Config",
        Callback = function()
            LoadConfig()
            OrionLib:MakeNotification({Name = "Config", Content = "Loaded!", Time = 3})
        end
    })
    
    SetTab:AddToggle({
        Name = "Notifications",
        Default = true,
        Callback = function(v) getgenv().Config.Notifications = v end
    })
    
    SetTab:AddToggle({
        Name = "Enable Logs",
        Default = false,
        Callback = function(v) getgenv().Config.EnableLogs = v end
    })
    
    SetTab:AddSection({Name = "📊 Info"})
    SetTab:AddLabel("Blox Fruits Ultimate v10.0")
    SetTab:AddLabel("Level: " .. Utils.GetLevel())
    SetTab:AddLabel("Sea: " .. Utils.GetSea())
    SetTab:AddLabel("Race: " .. Utils.GetRace())
    SetTab:AddLabel("Beli: $" .. Utils.GetBeli())
    
    OrionLib:Init()
    
    return OrionLib
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 25: INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

local function Initialize()
    print("╔═══════════════════════════════════════════════════════════════════╗")
    print("║       BLOX FRUITS ULTIMATE v10.0 - ULTRA COMPLETE                 ║")
    print("║                Loading all systems...                              ║")
    print("╚═══════════════════════════════════════════════════════════════════╝")
    
    -- Start ESP
    pcall(ESP.StartLoop)
    Utils.Log("ESP System loaded", "INFO")
    
    -- Start Anti-Detection
    pcall(AntiDetection.StartMonitoring)
    Utils.Log("Anti-Detection loaded", "INFO")
    
    -- Start Utilities
    pcall(UtilityFeatures.StartAll)
    Utils.Log("Utilities loaded", "INFO")
    
    -- Create UI
    local success, err = pcall(CreateUI)
    if success then
        Utils.Log("UI loaded successfully", "INFO")
    else
        warn("[Blox Ultimate] UI Error: " .. tostring(err))
        Utils.Log("UI failed to load: " .. tostring(err), "ERROR")
    end
    
    -- Final notification
    Utils.Notify("💎 Blox Ultimate v10.0", "Script loaded successfully!", 5)
    
    print("[Blox Ultimate] ✅ All systems initialized!")
    print("[Blox Ultimate] 📊 Level: " .. Utils.GetLevel() .. " | Sea: " .. Utils.GetSea())
    print("[Blox Ultimate] 🎮 Enjoy!")
end

-- Run initialization
local initSuccess, initErr = pcall(Initialize)
if not initSuccess then
    warn("[Blox Ultimate] Critical Error: " .. tostring(initErr))
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- END OF SCRIPT
-- ═══════════════════════════════════════════════════════════════════════════════
