--[[
    Blox Fruits Ultimate v14.2 SUPREME - Main Script
    Carregado pelo Loader.lua | NÃO execute diretamente!
    
    v14.2 CHANGELOG:
    ✓ Server Hop system (menos lag, menos players)
    ✓ Auto Fruit Store / Eat / Sniper melhorado
    ✓ Mirage Island Detector
    ✓ Combo System (sequências customizáveis)
    ✓ Config Save/Load persistente
    ✓ Dodge System (teleporta quando HP baixo)
    ✓ Auto Race upgrade
    ✓ Server Info no HUD
    ✓ Anti-Detection v2 melhorado
    ✓ Auto Heal (come comida automaticamente)
    ✓ Mob Aura (traz mobs + ataca em AoE)
]]

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                              WAIT FOR GAME
-- ══════════════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until LocalPlayer and LocalPlayer.Character
repeat task.wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                    SERVICES
-- ══════════════════════════════════════════════════════════════════════════════════════════

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local Services = setmetatable({}, {__index = function(s, k) local v = game:GetService(k); s[k] = v; return v end})
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage
local UserInputService = Services.UserInputService
local VirtualInputManager = Services.VirtualInputManager
local StarterGui = Services.StarterGui
local TeleportService = Services.TeleportService
local VirtualUser = Services.VirtualUser
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                              CONFIG SAVE/LOAD SYSTEM (v14.2 NEW)
-- ══════════════════════════════════════════════════════════════════════════════════════════

local ConfigManager = {}
ConfigManager.FileName = "BFUltimate_v14_Config.json"

function ConfigManager.Save(config)
    pcall(function()
        if writefile then
            local data = HttpService:JSONEncode(config)
            writefile(ConfigManager.FileName, data)
        end
    end)
end

function ConfigManager.Load()
    local ok, data = pcall(function()
        if isfile and isfile(ConfigManager.FileName) then
            return HttpService:JSONDecode(readfile(ConfigManager.FileName))
        end
        return nil
    end)
    return ok and data or nil
end

function ConfigManager.Delete()
    pcall(function()
        if isfile and isfile(ConfigManager.FileName) and delfile then
            delfile(ConfigManager.FileName)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                  CONFIGURATION
-- ══════════════════════════════════════════════════════════════════════════════════════════

local DefaultConfig = {
    AutoFarm = {
        Enabled = false,
        Mode = "Level",
        BringMobs = true,
        FarmHeight = 25, -- studs above mobs
        DipHeight = 8,   -- studs to dip down for click range
        PullRange = 120,  -- studs to pull mobs from
    },
    AutoQuest = { Enabled = true },
    Combat = {
        Weapon = "Melee",
        TargetPriority = "Nearest",
    },
    KillAura = {
        Enabled = false,
        Radius = 60,
        MaxTargets = 5,
    },
    MobAura = {
        Enabled = false,
        PullRadius = 80,
    },
    BountyHunt = {
        Enabled = false,
        MinBounty = 50000,
        MaxDistance = 500,
    },
    Raid = {
        AutoRaid = false,
        AutoCollect = true,
        SelectedRaid = "Auto",
    },
    SeaChange = { AutoChange = false },
    Dodge = {
        Enabled = false,
        HPThreshold = 30, -- percentage
        Distance = 50,
    },
    Combo = {
        Enabled = false,
        Sequence = {"Z","X","C","V"},
        Delay = 0.15,
    },
    Movement = {
        Fly = false,
        FlySpeed = 150,
        Noclip = false,
        InfiniteJump = false,
        TweenSpeed = 300,
        WalkSpeed = 16,
        JumpPower = 50,
    },
    Player = {
        AutoStats = false,
        StatsMode = "Melee",
        AutoRace = false,
    },
    Fruit = {
        Sniper = false,
        Notifier = true,
        AutoEat = false,
        AutoStore = false,
        StoreFruits = {}, -- list of fruit names to store
    },
    Extras = {
        AntiAFK = true,
        ESP = false,
        PlayerESP = false,
        FullBright = false,
        FPSBoost = false,
        AutoHaki = false,
        ObservationHaki = false,
        AutoRejoin = false,
        AutoCollect = false,
        AutoHeal = false,
        MirageDetector = false,
    },
    ServerHop = {
        MaxPlayers = 20,
        MinPlayers = 1,
    },
    System = {
        SafeMode = true,
        DebugMode = false,
        Notifications = true,
        SaveConfig = true,
    },
    Keybinds = {
        ToggleFarm = Enum.KeyCode.F1,
        ToggleFly = Enum.KeyCode.F2,
        ToggleAura = Enum.KeyCode.F3,
        StopAll = Enum.KeyCode.F4,
        ToggleMobAura = Enum.KeyCode.F5,
    },
}

-- Load saved config or use defaults
local savedConfig = ConfigManager.Load()
if savedConfig then
    -- Merge saved into defaults (so new keys are always present)
    local function deepMerge(base, override)
        local out = {}
        for k, v in pairs(base) do
            if type(v) == "table" and type(override[k]) == "table" then
                out[k] = deepMerge(v, override[k])
            elseif override[k] ~= nil then
                out[k] = override[k]
            else
                out[k] = v
            end
        end
        return out
    end
    getgenv().Settings = deepMerge(DefaultConfig, savedConfig)
else
    getgenv().Settings = getgenv().Settings or DefaultConfig
end
local Config = getgenv().Settings

-- Auto-save config periodically
task.spawn(function()
    while task.wait(30) do
        if Config.System.SaveConfig then
            -- Strip non-serializable values (Enum keybinds)
            local saveable = HttpService:JSONDecode(HttpService:JSONEncode(Config))
            saveable.Keybinds = nil -- Enums can't serialize
            ConfigManager.Save(saveable)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                  UTILITY HELPERS
-- ══════════════════════════════════════════════════════════════════════════════════════════

local function createThrottle(sec)
    local last = 0
    return function()
        local now = tick()
        if now - last < sec then return false end
        last = now; return true
    end
end

local function humanDelay(mn, mx)
    task.wait((mn or 0.05) + math.random() * ((mx or 0.15) - (mn or 0.05)))
end

-- v14.2: Random offset for positions (anti-detection)
local function randomOffset(cf, range)
    range = range or 3
    return cf * CFrame.new(math.random(-range, range), 0, math.random(-range, range))
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                   CORE UTILITIES
-- ══════════════════════════════════════════════════════════════════════════════════════════

local Core = {}

function Core.Notify(title, text, duration)
    if not Config.System.Notifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title), Text = tostring(text),
            Duration = duration or 3, Icon = "rbxassetid://6023426923"
        })
    end)
end

function Core.GetCharacter() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
function Core.GetHumanoid() local c = Core.GetCharacter(); return c and c:FindFirstChildOfClass("Humanoid") end
function Core.GetHRP() local c = Core.GetCharacter(); return c and c:FindFirstChild("HumanoidRootPart") end
function Core.IsAlive() local h = Core.GetHumanoid(); return h and h.Health > 0 end

function Core.GetHealthPercent()
    local h = Core.GetHumanoid()
    if not h or h.MaxHealth == 0 then return 100 end
    return (h.Health / h.MaxHealth) * 100
end

function Core.GetDistance(a, b)
    local function toV3(v)
        if typeof(v) == "Vector3" then return v end
        if typeof(v) == "CFrame" then return v.Position end
        if typeof(v) == "Instance" then
            local h = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
            if h then return h.Position end
            if v:IsA("BasePart") then return v.Position end
        end
        return nil
    end
    local v1, v2 = toV3(a), toV3(b)
    if not v1 or not v2 then return math.huge end
    return (v1 - v2).Magnitude
end

function Core.GetLevel()
    local d = LocalPlayer:FindFirstChild("Data")
    return d and d:FindFirstChild("Level") and d.Level.Value or 1
end

function Core.GetWorld()
    local lv = Core.GetLevel()
    if lv < 700 then return 1 elseif lv < 1500 then return 2 else return 3 end
end

function Core.GetWorldName()
    local w = Core.GetWorld()
    return w == 1 and "First Sea" or w == 2 and "Second Sea" or "Third Sea"
end

function Core.HasQuest()
    local g = LocalPlayer:FindFirstChild("PlayerGui")
    if g then
        local m = g:FindFirstChild("Main")
        if m then local q = m:FindFirstChild("Quest"); return q and q.Visible end
    end
    return false
end

function Core.GetRemote()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    return r and r:FindFirstChild("CommF_")
end

function Core.SafeCall(f, ...)
    local ok, res = pcall(f, ...)
    if not ok and Config.System.DebugMode then warn("[BF14.1 ERR] " .. tostring(res)) end
    return ok, res
end

-- v14.2: Improved SafeRemote with retry
function Core.SafeRemote(...)
    local remote = Core.GetRemote()
    if not remote then return false end
    humanDelay(0.02, 0.08)
    local args = {...}
    for attempt = 1, 2 do
        local ok, res = pcall(function() return remote:InvokeServer(unpack(args)) end)
        if ok then return true, res end
        if attempt < 2 then humanDelay(0.1, 0.3) end
        if Config.System.DebugMode then warn("[BF14.1 REMOTE] Attempt " .. attempt .. ": " .. tostring(res)) end
    end
    return false
end

function Core.GetBounty(player)
    if typeof(player) ~= "Instance" then return 0 end
    local data = player:FindFirstChild("Data")
    if data then
        local bounty = data:FindFirstChild("Bounty") or data:FindFirstChild("BountyEarned")
        if bounty then return bounty.Value end
    end
    return 0
end

function Core.GetPlayerCount()
    return #Players:GetPlayers()
end

function Core.GetMaxPlayers()
    return Players.MaxPlayers
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                CONNECTION MANAGER
-- ══════════════════════════════════════════════════════════════════════════════════════════

local Connections = {}
Connections._c = {}
Connections._t = {}

function Connections:Add(n, c) self:Remove(n); self._c[n] = c end
function Connections:Remove(n) if self._c[n] then pcall(function() self._c[n]:Disconnect() end); self._c[n] = nil end end
function Connections:AddTween(n, t) self:RemoveTween(n); self._t[n] = t end
function Connections:RemoveTween(n) if self._t[n] then pcall(function() self._t[n]:Cancel() end); self._t[n] = nil end end
function Connections:ClearAll()
    for n in pairs(self._c) do self:Remove(n) end
    for n in pairs(self._t) do self:RemoveTween(n) end
end
function Connections:Count() local c=0; for _ in pairs(self._c) do c=c+1 end; return c end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                   QUEST DATABASE
-- ══════════════════════════════════════════════════════════════════════════════════════════

local QuestDB = {}
QuestDB.Quests = {
    -- ═══ FIRST SEA ═══
    {MinLvl=1,    MaxLvl=10,   QuestId="BanditQuest1",        MobName="Bandit",           BossName=nil,              QuestNPC=CFrame.new(1060,16,1547),    MobArea=CFrame.new(1095,16,1570),    World=1},
    {MinLvl=11,   MaxLvl=15,   QuestId="MonkeyQuest1",        MobName="Monkey",           BossName="Gorilla King",   QuestNPC=CFrame.new(-1601,36,154),    MobArea=CFrame.new(-1550,37,120),    World=1},
    {MinLvl=16,   MaxLvl=29,   QuestId="GorilliaQuest",       MobName="Gorilla",          BossName="Gorilla King",   QuestNPC=CFrame.new(-1139,14,4109),   MobArea=CFrame.new(-1100,15,4150),   World=1},
    {MinLvl=30,   MaxLvl=59,   QuestId="PirateQuest",         MobName="Pirate",           BossName="Bobby",          QuestNPC=CFrame.new(-1139,4,3825),    MobArea=CFrame.new(-1100,5,3870),    World=1},
    {MinLvl=60,   MaxLvl=89,   QuestId="JunglePirateQuest",   MobName="Jungle Pirate",    BossName="Yeti",           QuestNPC=CFrame.new(-1601,36,154),    MobArea=CFrame.new(-1580,37,180),    World=1},
    {MinLvl=90,   MaxLvl=119,  QuestId="DesertBanditQuest",   MobName="Desert Bandit",    BossName="Saber Expert",   QuestNPC=CFrame.new(892,6,4392),      MobArea=CFrame.new(920,7,4430),      World=1},
    {MinLvl=120,  MaxLvl=174,  QuestId="SnowBanditQuest",     MobName="Snow Bandit",      BossName="Yeti",           QuestNPC=CFrame.new(1386,87,-1298),   MobArea=CFrame.new(1420,87,-1260),   World=1},
    {MinLvl=175,  MaxLvl=224,  QuestId="MarineQuest1",        MobName="Marine Soldier",   BossName="Vice Admiral",   QuestNPC=CFrame.new(-5033,28,4324),   MobArea=CFrame.new(-5000,29,4370),   World=1},
    {MinLvl=225,  MaxLvl=299,  QuestId="SkyBanditQuest",      MobName="Sky Bandit",       BossName="Wysper",         QuestNPC=CFrame.new(-4843,717,-2623), MobArea=CFrame.new(-4810,718,-2580), World=1},
    {MinLvl=300,  MaxLvl=374,  QuestId="PrisonerQuest",       MobName="Prisoner",         BossName="Warden",         QuestNPC=CFrame.new(4875,5,742),      MobArea=CFrame.new(4910,6,780),      World=1},
    {MinLvl=375,  MaxLvl=449,  QuestId="GladiatorQuest",      MobName="Toga Warrior",     BossName="Saber Expert",   QuestNPC=CFrame.new(-1569,7,-2920),   MobArea=CFrame.new(-1530,7,-2880),   World=1},
    {MinLvl=450,  MaxLvl=524,  QuestId="MagmaNinjaQuest",     MobName="Magma Ninja",      BossName="Magma Admiral",  QuestNPC=CFrame.new(-5312,12,8515),   MobArea=CFrame.new(-5280,12,8560),   World=1},
    {MinLvl=525,  MaxLvl=624,  QuestId="FishmanWarriorQuest", MobName="Fishman Warrior",  BossName="Fishman Lord",   QuestNPC=CFrame.new(61123,18,1569),   MobArea=CFrame.new(61160,18,1610),   World=1},
    {MinLvl=625,  MaxLvl=699,  QuestId="GodGuardQuest",       MobName="God's Guard",      BossName="Thunder God",    QuestNPC=CFrame.new(-4721,842,-1954), MobArea=CFrame.new(-4680,843,-1910), World=1},
    -- ═══ SECOND SEA ═══
    {MinLvl=700,  MaxLvl=774,  QuestId="RaiderQuest",         MobName="Raider",           BossName="Diamond",        QuestNPC=CFrame.new(-429,73,1836),    MobArea=CFrame.new(-390,73,1880),    World=2},
    {MinLvl=775,  MaxLvl=874,  QuestId="MercenaryQuest",      MobName="Mercenary",        BossName="Jeremy",         QuestNPC=CFrame.new(-429,73,1836),    MobArea=CFrame.new(-470,73,1790),    World=2},
    {MinLvl=875,  MaxLvl=949,  QuestId="ZombieQuest",         MobName="Zombie",           BossName="Zombie Lord",    QuestNPC=CFrame.new(-5765,52,-824),   MobArea=CFrame.new(-5720,52,-780),   World=2},
    {MinLvl=950,  MaxLvl=1049, QuestId="VampireQuest",        MobName="Vampire",          BossName="Vampire Lord",   QuestNPC=CFrame.new(-5765,52,-824),   MobArea=CFrame.new(-5810,52,-870),   World=2},
    {MinLvl=1050, MaxLvl=1174, QuestId="SnowTrooperQuest",    MobName="Snow Trooper",     BossName="Ice Admiral",    QuestNPC=CFrame.new(602,400,-5371),   MobArea=CFrame.new(640,401,-5330),   World=2},
    {MinLvl=1175, MaxLvl=1299, QuestId="ArcticWarriorQuest",  MobName="Arctic Warrior",   BossName="Tide Keeper",    QuestNPC=CFrame.new(6059,130,-6553),  MobArea=CFrame.new(6100,130,-6510),  World=2},
    {MinLvl=1300, MaxLvl=1424, QuestId="ButlerQuest",         MobName="Butler",           BossName="Order",          QuestNPC=CFrame.new(-12107,422,-7471),MobArea=CFrame.new(-12070,423,-7430),World=2},
    {MinLvl=1425, MaxLvl=1499, QuestId="CakeGuardQuest",      MobName="Cake Guard",       BossName="Dough King",     QuestNPC=CFrame.new(-2045,103,5405),  MobArea=CFrame.new(-2000,104,5450),  World=2},
    -- ═══ THIRD SEA ═══
    {MinLvl=1500, MaxLvl=1574, QuestId="PortTown",            MobName="Pirate Millionaire",BossName="Beautiful Pirate",QuestNPC=CFrame.new(-289,44,5579),   MobArea=CFrame.new(-250,44,5620),    World=3},
    {MinLvl=1575, MaxLvl=1649, QuestId="HydraIsland",         MobName="Hydra",            BossName="Island Empress", QuestNPC=CFrame.new(5229,16,303),     MobArea=CFrame.new(5270,17,340),     World=3},
    {MinLvl=1650, MaxLvl=1774, QuestId="FountainCity",        MobName="Galley Pirate",    BossName="Cyborg",         QuestNPC=CFrame.new(5441,287,4479),   MobArea=CFrame.new(5480,288,4520),   World=3},
    {MinLvl=1775, MaxLvl=1924, QuestId="HauntedCastle",       MobName="Ghost",            BossName="Soul Reaper",    QuestNPC=CFrame.new(-9500,146,5765),  MobArea=CFrame.new(-9460,147,5800),  World=3},
    {MinLvl=1925, MaxLvl=2099, QuestId="KitsuneShrine",       MobName="Kitsune Devotee",  BossName="Kitsune",        QuestNPC=CFrame.new(-9285,310,6258),  MobArea=CFrame.new(-9240,310,6300),  World=3},
    {MinLvl=2100, MaxLvl=2274, QuestId="LeviathanHunter",     MobName="Leviathan",        BossName="Leviathan",      QuestNPC=CFrame.new(-9285,310,6258),  MobArea=CFrame.new(-9240,310,6300),  World=3},
    {MinLvl=2275, MaxLvl=2449, QuestId="PirateRaiders",       MobName="Pirate Raider",    BossName="Captain Elephant",QuestNPC=CFrame.new(-289,44,5579),   MobArea=CFrame.new(-250,44,5620),    World=3},
    {MinLvl=2450, MaxLvl=9999, QuestId="SoulReaper",          MobName="Soul Reaper",      BossName="Soul Reaper",    QuestNPC=CFrame.new(-9285,310,6258),  MobArea=CFrame.new(-9240,310,6300),  World=3},
}

function QuestDB.GetQuest(level)
    level = level or Core.GetLevel()
    local world = Core.GetWorld()
    for _, q in ipairs(QuestDB.Quests) do
        if level >= q.MinLvl and level <= q.MaxLvl and q.World == world then return q end
    end
    for _, q in ipairs(QuestDB.Quests) do
        if level >= q.MinLvl and level <= q.MaxLvl then return q end
    end
    return QuestDB.Quests[1]
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                          EXPANDED TELEPORT DATABASE (44 LOCATIONS)
-- ══════════════════════════════════════════════════════════════════════════════════════════

local Teleports = {
    ["First Sea"] = {
        ["Starter Island"]     = CFrame.new(1060, 17, 1547),
        ["Jungle"]             = CFrame.new(-1601, 36, 154),
        ["Pirate Village"]     = CFrame.new(-1139, 4, 3825),
        ["Desert"]             = CFrame.new(912, 6, 4417),
        ["Frozen Village"]     = CFrame.new(1389, 87, -1298),
        ["Marine Fortress"]    = CFrame.new(-5033, 28, 4324),
        ["Skylands"]           = CFrame.new(-4843, 718, -2623),
        ["Prison"]             = CFrame.new(4875, 5, 742),
        ["Colosseum"]          = CFrame.new(-1569, 7, -2920),
        ["Magma Village"]      = CFrame.new(-5312, 12, 8516),
        ["Underwater City"]    = CFrame.new(61123, 18, 1569),
        ["Fountain City"]      = CFrame.new(5441, 287, 4479),
        ["Upper Skylands"]     = CFrame.new(-4721, 842, -1954),
        ["Shanks Room"]        = CFrame.new(-1442, 30, -28),
        ["Blox Fruit Dealer"]  = CFrame.new(-72, 15, 1547),
        ["Middle Town"]        = CFrame.new(-690, 15, 1582),
    },
    ["Second Sea"] = {
        ["Kingdom of Rose"]    = CFrame.new(-429, 73, 1836),
        ["Udon"]               = CFrame.new(-2045, 103, 5405),
        ["Graveyard"]          = CFrame.new(-5765, 52, -824),
        ["Snow Mountain"]      = CFrame.new(602, 400, -5371),
        ["Hot and Cold"]       = CFrame.new(-6050, 16, -4901),
        ["Cursed Ship"]        = CFrame.new(916, 125, 33171),
        ["Ice Castle"]         = CFrame.new(6059, 130, -6553),
        ["Forgotten Island"]   = CFrame.new(-3053, 234, -10201),
        ["Dark Arena"]         = CFrame.new(-4456, 20, -4475),
        ["Floating Turtle"]    = CFrame.new(-13232, 332, -7625),
        ["Mansion"]            = CFrame.new(-12107, 422, -7471),
        ["Cafe"]               = CFrame.new(-379, 73, 1838),
        ["Colosseum"]          = CFrame.new(-1800, 7, -2923),
        ["Magma Ore"]          = CFrame.new(-335, 117, 5623),
    },
    ["Third Sea"] = {
        ["Port Town"]          = CFrame.new(-289, 44, 5579),
        ["Hydra Island"]       = CFrame.new(5229, 16, 303),
        ["Great Tree"]         = CFrame.new(2361, 18, -7076),
        ["Floating Turtle"]    = CFrame.new(-13232, 332, -7625),
        ["Castle on the Sea"]  = CFrame.new(-5041, 313, -4832),
        ["Haunted Castle"]     = CFrame.new(-9500, 146, 5765),
        ["Sea of Treats"]      = CFrame.new(-2045, 103, 5405),
        ["Tiki Outpost"]       = CFrame.new(-11757, 332, -8306),
        ["Kitsune Shrine"]     = CFrame.new(-9285, 310, 6258),
        ["Mansion"]            = CFrame.new(-12107, 422, -7471),
        ["Mirage Island"]      = CFrame.new(-7886, 5607, -379),
        ["Fountain City"]      = CFrame.new(5441, 287, 4479),
        ["Beautiful Pirate"]   = CFrame.new(-451, 73, 1108),
        ["Leviathan"]          = CFrame.new(1867, 5, -5587),
    },
}

local TeleportOptions = {}
for sea, locs in pairs(Teleports) do
    TeleportOptions[sea] = {}
    for name in pairs(locs) do table.insert(TeleportOptions[sea], name) end
    table.sort(TeleportOptions[sea])
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                   MOVEMENT SYSTEM
-- ══════════════════════════════════════════════════════════════════════════════════════════

local Movement = {}
Movement.IsTweening = false
Movement.IsFlying = false

function Movement.StopTween()
    Connections:RemoveTween("MainTween"); Connections:Remove("TweenNoclip")
    Movement.IsTweening = false
    local hrp = Core.GetHRP()
    if hrp then pcall(function() hrp.Anchored = false; hrp.Velocity = Vector3.zero end) end
end

function Movement.TweenTo(target, speed, cb)
    if not Core.IsAlive() then return end
    local hrp = Core.GetHRP(); if not hrp then return end
    Movement.StopTween(); Movement.IsTweening = true
    local hum = Core.GetHumanoid()
    if hum and hum.Sit then hum.Sit = false; task.wait(0.1) end
    local dist = Core.GetDistance(hrp.Position, target.Position)
    speed = speed or Config.Movement.TweenSpeed or 300
    local t = math.max(dist / speed, 0.1)
    if dist < 50 then hrp.CFrame = target; Movement.IsTweening = false; if cb then cb() end; return end
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = target})
    Connections:AddTween("MainTween", tw)
    Connections:Add("TweenNoclip", RunService.Stepped:Connect(function()
        if not Movement.IsTweening then return end
        local ch = Core.GetCharacter()
        if ch then for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    end))
    tw.Completed:Connect(function(s) Movement.StopTween(); if s == Enum.PlaybackState.Completed and cb then cb() end end)
    tw:Play()
end

function Movement.TweenAwait(target, speed)
    local done = false
    Movement.TweenTo(target, speed, function() done = true end)
    local timeout = tick() + 30
    while not done and tick() < timeout do task.wait(0.1) end
    return done
end

function Movement.TeleportTo(cf)
    Movement.StopTween()
    local h = Core.GetHRP(); if h then h.CFrame = cf end
end

function Movement.EnableFly(enabled)
    local hrp = Core.GetHRP(); if not hrp then return end
    Movement.IsFlying = enabled; Config.Movement.Fly = enabled
    if enabled then
        pcall(function()
            if hrp:FindFirstChild("FV") then hrp.FV:Destroy() end
            if hrp:FindFirstChild("FG") then hrp.FG:Destroy() end
        end)
        local bv = Instance.new("BodyVelocity"); bv.Name = "FV"
        bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = Vector3.zero; bv.Parent = hrp
        local bg = Instance.new("BodyGyro"); bg.Name = "FG"
        bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.P = 9e4; bg.D = 1000; bg.Parent = hrp
        Connections:Add("FlyLoop", RunService.RenderStepped:Connect(function()
            if not Movement.IsFlying or not Core.IsAlive() then return end
            local hrp2 = Core.GetHRP(); local hum = Core.GetHumanoid()
            if not hrp2 or not hum then return end
            local bv2 = hrp2:FindFirstChild("FV"); local bg2 = hrp2:FindFirstChild("FG")
            if not bv2 or not bg2 then Movement.EnableFly(false); return end
            local spd = Config.Movement.FlySpeed; local cam = Camera.CFrame; local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
            if dir.Magnitude > 0 then dir = dir.Unit * spd end
            bv2.Velocity = dir; bg2.CFrame = cam; hum:ChangeState(Enum.HumanoidStateType.Flying)
        end))
        Core.Notify("✈️ Fly", "ON | Speed: " .. Config.Movement.FlySpeed, 2)
    else
        Connections:Remove("FlyLoop")
        pcall(function()
            if hrp:FindFirstChild("FV") then hrp.FV:Destroy() end
            if hrp:FindFirstChild("FG") then hrp.FG:Destroy() end
        end)
        Core.Notify("✈️ Fly", "OFF", 2)
    end
end

function Movement.EnableNoclip(on)
    Config.Movement.Noclip = on
    if on then
        Connections:Add("Noclip", RunService.Stepped:Connect(function()
            if not Config.Movement.Noclip or not Core.IsAlive() then return end
            local ch = Core.GetCharacter()
            if ch then for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end))
    else Connections:Remove("Noclip") end
end

function Movement.EnableInfJump(on)
    Config.Movement.InfiniteJump = on
    if on then
        Connections:Add("InfJump", UserInputService.JumpRequest:Connect(function()
            if not Config.Movement.InfiniteJump then return end
            local h = Core.GetHumanoid(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end))
    else Connections:Remove("InfJump") end
end

function Movement.SetSpeed(walk, jump)
    local h = Core.GetHumanoid(); if not h then return end
    if walk then h.WalkSpeed = walk; Config.Movement.WalkSpeed = walk end
    if jump then h.JumpPower = jump; h.UseJumpPower = true; Config.Movement.JumpPower = jump end
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                          COMBAT + TARGETING + FARM SYSTEMS
-- ══════════════════════════════════════════════════════════════════════════════════════════

local Combat = {}

function Combat.GetTool(typ)
    local ch = Core.GetCharacter(); local bp = LocalPlayer.Backpack
    local function find(cont, t)
        if not cont then return nil end
        for _, tool in pairs(cont:GetChildren()) do
            if tool:IsA("Tool") then
                local tip = tool.ToolTip or ""
                if t == "Melee" and tip:find("Melee") then return tool
                elseif t == "Sword" and tip:find("Sword") then return tool
                elseif t == "Blox Fruit" and tip:find("Blox Fruit") then return tool
                elseif t == "Gun" and tip:find("Gun") then return tool end
            end
        end; return nil
    end
    return find(ch, typ) or find(bp, typ)
end

function Combat.EquipWeapon(wType)
    wType = wType or Config.Combat.Weapon
    local hum = Core.GetHumanoid(); if not hum then return nil end
    local w = Combat.GetTool(wType)
    if w and w.Parent == LocalPlayer.Backpack then hum:EquipTool(w); task.wait(0.1) end
    return w
end

-- ═══ CLICK ATTACK (normal punch/click — NOT skills) ═══
-- Simula click do mouse na tela — hitbox grande com melee equipado
function Combat.ClickAttack()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.08)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- ═══ BRING ALL MOBS — puxa TODOS os mobs na range pro player ═══
-- Funciona setando CFrame dos mobs todo frame pra perto do player
function Combat.BringAllMobs(mobName, range)
    local hrp = Core.GetHRP(); if not hrp then return 0 end
    range = range or Config.AutoFarm.PullRange or 120
    local count = 0
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return 0 end
    
    for _, mob in pairs(enemies:GetChildren()) do
        local mHum = mob:FindFirstChild("Humanoid")
        local mHRP = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
        if mHum and mHRP and mHum.Health > 0 then
            -- Filter by mob name if specified
            local nameMatch = (not mobName or mobName == "Auto" or mob.Name:lower():find(mobName:lower()))
            if nameMatch then
                local dist = (hrp.Position - mHRP.Position).Magnitude
                if dist <= range then
                    -- Puxa o mob pra EMBAIXO do player (5 studs abaixo)
                    pcall(function()
                        mHRP.CFrame = hrp.CFrame * CFrame.new(
                            math.random(-6, 6), -- random X offset
                            -Config.AutoFarm.FarmHeight + 5, -- below player
                            math.random(-6, 6) -- random Z offset
                        )
                        mHRP.Velocity = Vector3.zero
                        mHRP.CanCollide = false
                    end)
                    count = count + 1
                end
            end
        end
    end
    return count
end

-- Skill spamming (para uso FORA do farm, ex: bounty hunt, combo)
function Combat.UseSkill(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game); humanDelay(0.05,0.1)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

function Combat.ExecuteCombo(target)
    if not Config.Combo.Enabled or not target then return end
    for _, key in ipairs(Config.Combo.Sequence) do
        if not Core.IsAlive() then break end
        local tH = target:FindFirstChild("Humanoid")
        if not tH or tH.Health <= 0 then break end
        Combat.UseSkill(key)
        task.wait(Config.Combo.Delay)
    end
end

-- ═══ TARGETING ═══

local Targeting = {}

function Targeting.GetEnemies()
    local out = {}
    local folder = Workspace:FindFirstChild("Enemies"); if not folder then return out end
    for _, e in pairs(folder:GetChildren()) do
        local h = e:FindFirstChild("Humanoid"); local hr = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Torso")
        if h and hr and h.Health > 0 then table.insert(out, e) end
    end; return out
end

function Targeting.GetBosses()
    local out = {}
    for _, e in ipairs(Targeting.GetEnemies()) do
        local h = e:FindFirstChild("Humanoid")
        if h and h.MaxHealth >= 10000 then table.insert(out, e) end
    end; return out
end

function Targeting.GetPlayers(excludeSelf)
    local out = {}
    for _, p in pairs(Players:GetPlayers()) do
        if (not excludeSelf or p ~= LocalPlayer) and p.Character then
            local h = p.Character:FindFirstChild("Humanoid"); local hr = p.Character:FindFirstChild("HumanoidRootPart")
            if h and hr and h.Health > 0 then table.insert(out, {Player=p, Character=p.Character}) end
        end
    end; return out
end

function Targeting.FilterName(list, name)
    if not name or name == "Auto" then return list end
    local out = {}
    for _, e in ipairs(list) do
        local n = (typeof(e) == "Instance" and e.Name) or (e.Character and e.Character.Name) or ""
        if n:lower():find(name:lower()) then table.insert(out, e) end
    end; return out
end

function Targeting.SelectBest(enemies, priority)
    if #enemies == 0 then return nil end
    priority = priority or Config.Combat.TargetPriority
    local hrp = Core.GetHRP(); if not hrp then return enemies[1] end
    if priority == "Nearest" then
        local best, bd = nil, math.huge
        for _, e in ipairs(enemies) do local d = Core.GetDistance(hrp, e); if d < bd then best, bd = e, d end end; return best
    elseif priority == "Lowest HP" then
        local best, bh = nil, math.huge
        for _, e in ipairs(enemies) do local h = e:FindFirstChild("Humanoid"); if h and h.Health < bh then best, bh = e, h.Health end end; return best
    elseif priority == "Highest HP" then
        local best, bh = nil, 0
        for _, e in ipairs(enemies) do local h = e:FindFirstChild("Humanoid"); if h and h.Health > bh then best, bh = e, h.Health end end; return best
    end; return enemies[1]
end

function Targeting.GetTarget(mobName) return Targeting.SelectBest(Targeting.FilterName(Targeting.GetEnemies(), mobName)) end
function Targeting.GetBoss(bossName) return Targeting.SelectBest(Targeting.FilterName(Targeting.GetBosses(), bossName)) end

-- Count alive mobs matching name in area
function Targeting.CountAlive(mobName, range)
    local hrp = Core.GetHRP(); if not hrp then return 0 end
    range = range or 200; local c = 0
    for _, e in ipairs(Targeting.FilterName(Targeting.GetEnemies(), mobName)) do
        if Core.GetDistance(hrp, e) <= range then c = c + 1 end
    end; return c
end

-- ═══ AUTO FARM — REWRITTEN v14.2 ═══
-- Mecânica: Sobe → Puxa mobs → Desce (dip) → Click attack → Sobe
-- SEM skills (Z,X,C,V) — só soco normal com click
-- BringMobs funcional — puxa TODOS os mobs da quest toda frame

local Farm = {}
Farm.Status = "Idle"
Farm.Phase = "idle" -- idle, traveling, pulling, dipping, attacking, rising
Farm._anchorPos = nil -- posição base acima dos mobs

function Farm.AcceptQuest(qd)
    if not qd or not Core.IsAlive() then return false end
    local hrp = Core.GetHRP(); if not hrp then return false end
    local dist = Core.GetDistance(hrp.Position, qd.QuestNPC.Position)
    if dist > 40 then
        Farm.Status = "→ Quest NPC"
        Movement.TweenTo(randomOffset(qd.QuestNPC, 2))
        return false
    else
        Movement.StopTween()
        Farm.Status = "Accepting Quest"
        Core.SafeRemote("StartQuest", qd.QuestId, 1)
        humanDelay(0.3, 0.5)
        return true
    end
end

-- MAIN FARM FUNCTION — Yo-yo attack loop
function Farm.FarmMobs(qd)
    if not Core.IsAlive() then return end
    local hrp = Core.GetHRP(); if not hrp then return end
    local mobName = qd.MobName
    
    -- Encontra um mob pra saber onde ficar
    local target = Targeting.GetTarget(mobName)
    if not target then
        -- Sem mobs — vai pra área e espera respawn
        Farm.Status = "Waiting respawn..."
        if qd.MobArea then
            local dist = Core.GetDistance(hrp.Position, qd.MobArea.Position)
            if dist > 80 then
                Farm.Status = "→ Mob Area"
                Movement.TweenTo(qd.MobArea * CFrame.new(0, Config.AutoFarm.FarmHeight, 0))
            end
        end
        return
    end
    
    local tHRP = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso")
    if not tHRP then return end
    
    -- Posição base: acima do mob
    local highPos = tHRP.CFrame * CFrame.new(0, Config.AutoFarm.FarmHeight, 0)
    local dist = Core.GetDistance(hrp.Position, highPos.Position)
    
    -- Se tá longe, tween até lá
    if dist > 60 then
        Farm.Status = "→ " .. target.Name
        Farm.Phase = "traveling"
        Movement.TweenTo(highPos)
        return
    end
    
    -- Parar tween se tiver ativo
    Movement.StopTween()
    
    -- Equipar arma
    Combat.EquipWeapon()
    
    -- ═══ FASE 1: POSICIONAR EM CIMA + PUXAR MOBS ═══
    Farm.Phase = "pulling"
    Farm.Status = "🧲 Pulling mobs (" .. Targeting.CountAlive(mobName, Config.AutoFarm.PullRange) .. ")"
    
    -- Ficar em cima (safe)
    hrp.CFrame = highPos
    
    -- Puxar TODOS os mobs da area pro player
    local pulled = Combat.BringAllMobs(mobName, Config.AutoFarm.PullRange)
    
    -- Desabilitar colisão do player (segurança)
    local ch = Core.GetCharacter()
    if ch then
        for _, part in pairs(ch:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    -- ═══ FASE 2: DIP DOWN + CLICK ATTACK ═══
    if pulled > 0 then
        Farm.Phase = "dipping"
        -- Descer um pouco pra ficar na range do click
        local dipPos = tHRP.CFrame * CFrame.new(0, Config.AutoFarm.DipHeight, 0)
        hrp.CFrame = dipPos
        
        Farm.Phase = "attacking"
        Farm.Status = "⚔ Clicking " .. pulled .. " mobs"
        
        -- Click attack múltiplas vezes (hitbox grande com melee)
        for _ = 1, math.random(3, 5) do
            if not Core.IsAlive() then break end
            Combat.ClickAttack()
            -- Re-puxar mobs enquanto ataca (mantém eles perto)
            Combat.BringAllMobs(mobName, Config.AutoFarm.PullRange)
            task.wait(0.08)
        end
        
        -- ═══ FASE 3: SUBIR DE VOLTA (safe) ═══
        Farm.Phase = "rising"
        hrp.CFrame = highPos
    end
end

-- Main loop que roda no Heartbeat
function Farm.MainLoop()
    if not Config.AutoFarm.Enabled then Farm.Status = "Disabled"; return end
    if not Core.IsAlive() then Farm.Status = "Dead..."; return end
    
    local mode = Config.AutoFarm.Mode
    local qd = QuestDB.GetQuest()
    
    if mode == "Level" then
        -- Pegar quest se não tiver
        if Config.AutoQuest.Enabled and not Core.HasQuest() then
            Farm.AcceptQuest(qd)
            return
        end
        Farm.FarmMobs(qd)
        
    elseif mode == "Mastery" then
        -- Mastery não precisa de quest, só farm
        Farm.FarmMobs(qd)
        
    elseif mode == "Boss" then
        -- Tenta boss primeiro, senão farm normal
        local bossTarget = Targeting.GetBoss(qd.BossName)
        if bossTarget then
            -- Boss farming — mesma mecânica mas foca no boss
            local bossHRP = bossTarget:FindFirstChild("HumanoidRootPart")
            if bossHRP then
                local hrp = Core.GetHRP()
                if hrp then
                    local dist = Core.GetDistance(hrp, bossTarget)
                    if dist > 60 then
                        Farm.Status = "→ Boss: " .. bossTarget.Name
                        Movement.TweenTo(bossHRP.CFrame * CFrame.new(0, Config.AutoFarm.FarmHeight, 0))
                    else
                        Movement.StopTween()
                        Combat.EquipWeapon()
                        hrp.CFrame = bossHRP.CFrame * CFrame.new(0, Config.AutoFarm.DipHeight, 0)
                        Farm.Status = "⚔ Boss: " .. bossTarget.Name
                        Combat.ClickAttack()
                        task.wait(0.05)
                        hrp.CFrame = bossHRP.CFrame * CFrame.new(0, Config.AutoFarm.FarmHeight, 0)
                    end
                end
            end
        else
            -- Sem boss, farm normal
            if Config.AutoQuest.Enabled and not Core.HasQuest() then
                Farm.AcceptQuest(qd); return
            end
            Farm.FarmMobs(qd)
        end
    end
end

function Farm.Start()
    Core.Notify("🌾 Farm", "ON - " .. Config.AutoFarm.Mode, 3)
    -- Farm loop roda ~30fps (Heartbeat) com throttle
    local th = createThrottle(0.05) -- ~20 ticks/sec
    Connections:Add("FarmLoop", RunService.Heartbeat:Connect(function()
        if not th() then return end
        Core.SafeCall(Farm.MainLoop)
    end))
end

function Farm.Stop()
    Connections:Remove("FarmLoop")
    Movement.StopTween()
    Farm.Status = "Stopped"
    Farm.Phase = "idle"
    Core.Notify("🌾 Farm", "OFF", 2)
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                              KILL AURA + MOB AURA
-- ══════════════════════════════════════════════════════════════════════════════════════════

local KillAura = {}
function KillAura.Enable(on)
    Config.KillAura.Enabled = on
    if on then
        local th = createThrottle(0.15)
        Connections:Add("KillAura", RunService.Heartbeat:Connect(function()
            if not Config.KillAura.Enabled or not Core.IsAlive() or not th() then return end
            local hrp = Core.GetHRP(); if not hrp then return end
            Combat.EquipWeapon()
            local hit = 0
            for _, enemy in ipairs(Targeting.GetEnemies()) do
                if hit >= Config.KillAura.MaxTargets then break end
                if Core.GetDistance(hrp, enemy) <= Config.KillAura.Radius then
                    local eHRP = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
                    if eHRP then
                        -- Puxa mob pra perto + click attack
                        pcall(function() eHRP.CFrame = hrp.CFrame * CFrame.new(math.random(-5,5), -3, math.random(-5,5)) end)
                        hit = hit + 1
                    end
                end
            end
            -- Click attack pra pegar todos que foram puxados
            if hit > 0 then Combat.ClickAttack() end
        end))
        Core.Notify("💀 Kill Aura", "ON | R:" .. Config.KillAura.Radius, 3)
    else Connections:Remove("KillAura"); Core.Notify("💀 Kill Aura", "OFF", 2) end
end

-- v14.2: Mob Aura - puxa mobs pra perto + ataca em AoE
local MobAura = {}
function MobAura.Enable(on)
    Config.MobAura.Enabled = on
    if on then
        local th = createThrottle(0.2)
        Connections:Add("MobAura", RunService.Heartbeat:Connect(function()
            if not Config.MobAura.Enabled or not Core.IsAlive() or not th() then return end
            local hrp = Core.GetHRP(); if not hrp then return end
            local pulled = 0
            for _, enemy in ipairs(Targeting.GetEnemies()) do
                if pulled >= 10 then break end
                local dist = Core.GetDistance(hrp, enemy)
                if dist <= Config.MobAura.PullRadius then
                    local eHRP = enemy:FindFirstChild("HumanoidRootPart")
                    if eHRP then
                        pcall(function() eHRP.CFrame = hrp.CFrame * CFrame.new(math.random(-8,8), 0, math.random(-8,8)) end)
                        pulled = pulled + 1
                    end
                end
            end
            -- Click attack depois de puxar todos
            if pulled > 0 then Combat.EquipWeapon(); Combat.ClickAttack() end
        end))
        Core.Notify("🧲 Mob Aura", "ON | R:" .. Config.MobAura.PullRadius, 3)
    else Connections:Remove("MobAura"); Core.Notify("🧲 Mob Aura", "OFF", 2) end
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                          DODGE SYSTEM (v14.2 NEW)
-- ══════════════════════════════════════════════════════════════════════════════════════════

local DodgeSystem = {}
function DodgeSystem.Enable(on)
    Config.Dodge.Enabled = on
    if on then
        local th = createThrottle(0.3)
        Connections:Add("Dodge", RunService.Heartbeat:Connect(function()
            if not Config.Dodge.Enabled or not Core.IsAlive() or not th() then return end
            local hpPct = Core.GetHealthPercent()
            if hpPct <= Config.Dodge.HPThreshold then
                local hrp = Core.GetHRP(); if not hrp then return end
                -- Teleporta para trás e para cima
                local dodgeCF = hrp.CFrame * CFrame.new(0, Config.Dodge.Distance * 0.5, Config.Dodge.Distance)
                hrp.CFrame = dodgeCF
                humanDelay(0.3, 0.5)
            end
        end))
        Core.Notify("🛡️ Dodge", "ON | Threshold: " .. Config.Dodge.HPThreshold .. "%", 3)
    else Connections:Remove("Dodge"); Core.Notify("🛡️ Dodge", "OFF", 2) end
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                    BOUNTY HUNT + RAID + SEA CHANGE (same as v14)
-- ══════════════════════════════════════════════════════════════════════════════════════════

local BountyHunt = {}
BountyHunt.CurrentTarget = nil; BountyHunt.Status = "Idle"

function BountyHunt.FindTarget()
    local hrp = Core.GetHRP(); if not hrp then return nil end
    local best, bestB = nil, 0
    for _, pd in ipairs(Targeting.GetPlayers(true)) do
        local b = Core.GetBounty(pd.Player)
        if b >= Config.BountyHunt.MinBounty then
            local d = Core.GetDistance(hrp, pd.Character)
            if d <= Config.BountyHunt.MaxDistance and b > bestB then best = pd; bestB = b end
        end
    end; return best, bestB
end

function BountyHunt.Enable(on)
    Config.BountyHunt.Enabled = on
    if on then
        local th = createThrottle(0.2)
        Connections:Add("BountyHunt", RunService.Heartbeat:Connect(function()
            if not Config.BountyHunt.Enabled or not Core.IsAlive() or not th() then return end
            local hrp = Core.GetHRP(); if not hrp then return end
            local target, bounty = BountyHunt.FindTarget()
            if not target then BountyHunt.Status = "Scanning..."; BountyHunt.CurrentTarget = nil; return end
            BountyHunt.CurrentTarget = target.Player.Name
            local tC = target.Character; local tHRP = tC:FindFirstChild("HumanoidRootPart"); local tHum = tC:FindFirstChild("Humanoid")
            if not tHRP or not tHum or tHum.Health <= 0 then BountyHunt.Status = "Target dead"; return end
            BountyHunt.Status = "⚔ " .. target.Player.Name .. " ($" .. bounty .. ")"
            local dist = Core.GetDistance(hrp, tC)
            if dist > 30 then Movement.TweenTo(tHRP.CFrame * CFrame.new(0,5,-5))
            else Movement.StopTween(); hrp.CFrame = tHRP.CFrame * CFrame.new(0,5,-5)
                Combat.EquipWeapon()
                Combat.ClickAttack()
                if Config.Combo.Enabled then Combat.ExecuteCombo(tC) end
            end
        end))
        Core.Notify("🏴‍☠️ Bounty Hunt", "ON | Min: $" .. Config.BountyHunt.MinBounty, 3)
    else Connections:Remove("BountyHunt"); BountyHunt.Status = "Idle"; Movement.StopTween(); Core.Notify("🏴‍☠️ Bounty Hunt", "OFF", 2) end
end

-- ═══ RAID ═══

local Raid = {}
Raid.Status = "Idle"; Raid.InRaid = false

local RaidData = {
    {Name="Flame",Level=300},{Name="Ice",Level=600},{Name="Sand",Level=500},{Name="Dark",Level=400},
    {Name="Light",Level=750},{Name="Quake",Level=750},{Name="Rubber",Level=750},{Name="Buddha",Level=1000},
    {Name="Magma",Level=850},{Name="Phoenix",Level=1100},{Name="Rumble",Level=750},{Name="Dough",Level=1200},
    {Name="Leopard",Level=1500},
}

function Raid.IsInRaid()
    local pG = LocalPlayer:FindFirstChild("PlayerGui")
    if pG then for _, g in pairs(pG:GetDescendants()) do if g.Name:find("Raid") and g:IsA("GuiObject") and g.Visible then return true end end end
    return Workspace:FindFirstChild("RaidIsland") ~= nil or Workspace:FindFirstChild("_Raid") ~= nil
end

function Raid.Enable(on)
    Config.Raid.AutoRaid = on
    if on then
        local th = createThrottle(0.3)
        Connections:Add("AutoRaid", RunService.Heartbeat:Connect(function()
            if not Config.Raid.AutoRaid or not Core.IsAlive() or not th() then return end
            if Raid.IsInRaid() then
                Raid.InRaid = true; local enemies = Targeting.GetEnemies()
                if #enemies > 0 then local t = Targeting.SelectBest(enemies, "Nearest"); if t then Farm.FarmMob(t); Raid.Status = "⚔ " .. t.Name end
                else Raid.Status = "Waiting wave..." end
                if Config.Raid.AutoCollect then
                    local hrp = Core.GetHRP(); if hrp then
                        for _, obj in pairs(Workspace:GetChildren()) do
                            if obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChild("Handle")) then
                                local h = obj:FindFirstChild("Handle") or (obj:IsA("BasePart") and obj)
                                if h and Core.GetDistance(hrp, h) < 50 then pcall(function() local pr = h:FindFirstChildOfClass("ProximityPrompt"); if pr then fireproximityprompt(pr) end end) end
                            end
                        end
                    end
                end
            else Raid.InRaid = false; Raid.Status = "Starting..."; Core.SafeRemote("RaidStart", Config.Raid.SelectedRaid ~= "Auto" and Config.Raid.SelectedRaid or nil); humanDelay(1,2) end
        end))
        Core.Notify("⚔️ Auto Raid", "ON", 3)
    else Connections:Remove("AutoRaid"); Raid.Status = "Idle"; Core.Notify("⚔️ Auto Raid", "OFF", 2) end
end

-- ═══ SEA CHANGE ═══

local SeaChange = {}
SeaChange.Status = "Idle"
local SeaPortals = {
    {FromWorld=1, ToWorld=2, MinLevel=700, Remote="TravelMain", Args={"TravelDressrosa"}, NPC=CFrame.new(1060,17,1547)},
    {FromWorld=2, ToWorld=3, MinLevel=1500, Remote="TravelMain", Args={"TravelZou"}, NPC=CFrame.new(-429,73,1836)},
}

function SeaChange.Enable(on)
    Config.SeaChange.AutoChange = on
    if on then
        local th = createThrottle(5)
        Connections:Add("SeaChange", RunService.Heartbeat:Connect(function()
            if not Config.SeaChange.AutoChange or not th() then return end
            local lv, w = Core.GetLevel(), Core.GetWorld()
            for _, p in ipairs(SeaPortals) do
                if w == p.FromWorld and lv >= p.MinLevel then
                    SeaChange.Status = "→ Sea " .. p.ToWorld
                    Core.SafeRemote(p.Remote, unpack(p.Args)); humanDelay(2,3)
                    if Core.GetWorld() == p.FromWorld then Movement.TweenTo(p.NPC); task.wait(3); Core.SafeRemote(p.Remote, unpack(p.Args)) end
                    return
                end
            end; SeaChange.Status = "Correct sea"
        end))
        Core.Notify("🌊 Sea Change", "ON", 3)
    else Connections:Remove("SeaChange"); SeaChange.Status = "Idle" end
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                       SERVER HOP SYSTEM (v14.2 NEW)
-- ══════════════════════════════════════════════════════════════════════════════════════════

local ServerHop = {}

function ServerHop.GetServers()
    local servers = {}
    local ok, data = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if ok and data and data.data then
        for _, s in ipairs(data.data) do
            if s.playing and s.maxPlayers and s.id ~= game.JobId then
                table.insert(servers, {id = s.id, players = s.playing, max = s.maxPlayers})
            end
        end
    end
    return servers
end

function ServerHop.HopToLowest()
    Core.Notify("🔄 Server Hop", "Finding best server...", 3)
    local servers = ServerHop.GetServers()
    if #servers == 0 then Core.Notify("❌ Hop", "No servers found", 3); return end
    
    -- Filter by player count preferences
    local candidates = {}
    for _, s in ipairs(servers) do
        if s.players >= Config.ServerHop.MinPlayers and s.players <= Config.ServerHop.MaxPlayers then
            table.insert(candidates, s)
        end
    end
    
    if #candidates == 0 then
        -- Fallback: pick server with fewest players
        table.sort(servers, function(a, b) return a.players < b.players end)
        candidates = {servers[1]}
    end
    
    -- Pick random from candidates (avoid predictability)
    local target = candidates[math.random(1, #candidates)]
    Core.Notify("🔄 Hopping!", "To server with " .. target.players .. " players", 3)
    task.wait(1)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer) end)
end

function ServerHop.HopRandom()
    Core.Notify("🔄 Server Hop", "Random hop...", 3)
    local servers = ServerHop.GetServers()
    if #servers == 0 then Core.Notify("❌ Hop", "No servers found", 3); return end
    local target = servers[math.random(1, #servers)]
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer) end)
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                    MIRAGE ISLAND DETECTOR (v14.2 NEW)
-- ══════════════════════════════════════════════════════════════════════════════════════════

local MirageDetector = {}
MirageDetector.Found = false

function MirageDetector.Enable(on)
    Config.Extras.MirageDetector = on
    if on then
        local th = createThrottle(5)
        Connections:Add("MirageDetect", RunService.Heartbeat:Connect(function()
            if not Config.Extras.MirageDetector or not th() then return end
            -- Check for Mirage Island in workspace
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj.Name:find("Mirage") or obj.Name:find("mirage") then
                    if not MirageDetector.Found then
                        MirageDetector.Found = true
                        Core.Notify("🏝️ MIRAGE ISLAND!", "Detected! Teleporting...", 10)
                        task.wait(0.5)
                        local target = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                        if target then Movement.TeleportTo(target.CFrame * CFrame.new(0, 10, 0))
                        else Movement.TeleportTo(CFrame.new(-7886, 5607, -379)) end
                    end
                    return
                end
            end
            MirageDetector.Found = false
        end))
        Core.Notify("🏝️ Mirage Detector", "Scanning...", 3)
    else Connections:Remove("MirageDetect") end
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                      EXTRAS
-- ══════════════════════════════════════════════════════════════════════════════════════════

local Extras = {}

function Extras.EnableAntiAFK(on)
    Config.Extras.AntiAFK = on
    if on then Connections:Add("AntiAFK", LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)) else Connections:Remove("AntiAFK") end
end

function Extras.EnableAutoHaki(on)
    Config.Extras.AutoHaki = on
    if on then local th = createThrottle(0.5)
        Connections:Add("AutoHaki", RunService.Heartbeat:Connect(function()
            if not Config.Extras.AutoHaki or not th() then return end
            local ch = Core.GetCharacter(); if not ch then return end
            local a = ch:FindFirstChild("HasBuso"); if not a or not a.Value then Core.SafeRemote("Buso") end
        end))
        Core.Notify("✊ Armament Haki", "ON", 2)
    else Connections:Remove("AutoHaki"); Core.Notify("✊ Armament Haki", "OFF", 2) end
end

-- ═══ OBSERVATION HAKI (Ken Haki) — v14.2 NEW ═══
-- Ativa Observation Haki (Ken/Kenbunshoku)
-- Usa tecla "J" do jogo ou remote "Ken" / "Observation"
-- Mostra inimigos através de paredes + dodge automático
function Extras.EnableObservationHaki(on)
    Config.Extras.ObservationHaki = on
    if on then
        local th = createThrottle(1)
        Connections:Add("ObsHaki", RunService.Heartbeat:Connect(function()
            if not Config.Extras.ObservationHaki or not th() then return end
            local ch = Core.GetCharacter(); if not ch then return end
            
            -- Método 1: Checar se Ken Haki já tá ativo
            local hasKen = ch:FindFirstChild("HasKen") or ch:FindFirstChild("HasObservation") or ch:FindFirstChild("Ken")
            if hasKen and hasKen:IsA("BoolValue") and hasKen.Value then return end -- já tá ativo
            
            -- Método 2: Tentar via Remote (CommF_)
            local activated = false
            pcall(function()
                local _, res = Core.SafeRemote("Ken")
                if res then activated = true end
            end)
            
            -- Método 3: Fallback - simular tecla J (keybind padrão do Ken Haki)
            if not activated then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.J, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.J, false, game)
                end)
            end
        end))
        Core.Notify("👁️ Observation Haki", "ON - Auto-activating Ken", 3)
    else
        Connections:Remove("ObsHaki")
        -- Desativar Ken Haki
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.J, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.J, false, game)
        end)
        Core.Notify("👁️ Observation Haki", "OFF", 2)
    end
end

-- v14.2: Auto Heal - uses food items when HP is low
function Extras.EnableAutoHeal(on)
    Config.Extras.AutoHeal = on
    if on then
        local th = createThrottle(1)
        Connections:Add("AutoHeal", RunService.Heartbeat:Connect(function()
            if not Config.Extras.AutoHeal or not th() then return end
            if Core.GetHealthPercent() < 50 then
                -- Try to eat food from backpack
                local bp = LocalPlayer.Backpack; local ch = Core.GetCharacter()
                if not bp or not ch then return end
                for _, tool in pairs(bp:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:find("Meat") or tool.Name:find("Food") or tool.Name:find("Apple") or tool.Name:find("Fish")) then
                        local hum = Core.GetHumanoid()
                        if hum then hum:EquipTool(tool); task.wait(0.3)
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1); task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
                        end; break
                    end
                end
            end
        end))
        Core.Notify("❤️ Auto Heal", "ON", 2)
    else Connections:Remove("AutoHeal") end
end

function Extras.EnableFruitSniper(on)
    Config.Fruit.Sniper = on
    if on then
        local th = createThrottle(2)
        Connections:Add("FruitWatch", Workspace.DescendantAdded:Connect(function(obj)
            if not Config.Fruit.Sniper then return end
            if obj:IsA("Tool") and obj.Name:find("Fruit") then task.defer(function()
                local hrp = Core.GetHRP(); local h = obj:FindFirstChild("Handle")
                if hrp and h and Core.GetDistance(hrp, h) < 600 then
                    Core.Notify("🍎 FRUIT!", obj.Name, 5)
                    Movement.TeleportTo(h.CFrame * CFrame.new(0,2,0)); task.wait(0.3)
                    local pr = h:FindFirstChildOfClass("ProximityPrompt"); if pr then pcall(function() fireproximityprompt(pr) end) end
                    -- v14.2: Auto eat or store
                    task.wait(0.5)
                    if Config.Fruit.AutoEat then Core.SafeRemote("EatFruit", obj.Name)
                    elseif Config.Fruit.AutoStore then Core.SafeRemote("StoreFruit", obj.Name) end
                end end) end
        end))
        Connections:Add("FruitScan", RunService.Heartbeat:Connect(function()
            if not Config.Fruit.Sniper or not th() then return end
            local hrp = Core.GetHRP(); if not hrp then return end
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Tool") and obj.Name:find("Fruit") then local h = obj:FindFirstChild("Handle")
                    if h and Core.GetDistance(hrp, h) < 600 then Movement.TeleportTo(h.CFrame * CFrame.new(0,2,0)); task.wait(0.3)
                        local pr = h:FindFirstChildOfClass("ProximityPrompt"); if pr then pcall(function() fireproximityprompt(pr) end) end end end
            end
        end))
        Core.Notify("🍎 Fruit Sniper", "ON", 3)
    else Connections:Remove("FruitWatch"); Connections:Remove("FruitScan") end
end

function Extras.EnableESP(on)
    Config.Extras.ESP = on
    if on then
        local th = createThrottle(3)
        local function mk(e, c)
            if e:FindFirstChild("_ESP") then return end
            local ad = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Head"); if not ad then return end
            local bb = Instance.new("BillboardGui"); bb.Name = "_ESP"; bb.Adornee = ad; bb.Size = UDim2.new(0,100,0,40)
            bb.StudsOffset = Vector3.new(0,4,0); bb.AlwaysOnTop = true; bb.Parent = e
            local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.new(1,0,1,0)
            t.Text = e.Name; t.TextColor3 = c or Color3.new(1,0,0); t.TextScaled = true; t.Font = Enum.Font.GothamBold; t.Parent = bb
        end
        local function upd() local ef = Workspace:FindFirstChild("Enemies"); if ef then for _, e in pairs(ef:GetChildren()) do if e:FindFirstChild("Humanoid") then mk(e, Color3.new(1,0.3,0.3)) end end end end
        upd(); Connections:Add("ESPUpdate", RunService.Heartbeat:Connect(function() if th() then upd() end end))
    else Connections:Remove("ESPUpdate"); pcall(function() for _, o in pairs(Workspace:GetDescendants()) do if o.Name == "_ESP" then o:Destroy() end end end) end
end

function Extras.EnablePlayerESP(on)
    Config.Extras.PlayerESP = on
    if on then
        local th = createThrottle(2)
        local function mk(ch)
            if ch:FindFirstChild("_PESP") then return end
            local ad = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Head"); if not ad then return end
            local bb = Instance.new("BillboardGui"); bb.Name = "_PESP"; bb.Adornee = ad; bb.Size = UDim2.new(0,120,0,50)
            bb.StudsOffset = Vector3.new(0,5,0); bb.AlwaysOnTop = true; bb.Parent = ch
            local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.new(1,0,0.6,0)
            t.Text = ch.Name; t.TextColor3 = Color3.new(0.3,0.8,1); t.TextScaled = true; t.Font = Enum.Font.GothamBold; t.Parent = bb
            local hp = Instance.new("TextLabel"); hp.BackgroundTransparency = 1; hp.Size = UDim2.new(1,0,0.4,0); hp.Position = UDim2.new(0,0,0.6,0)
            hp.TextColor3 = Color3.new(1,1,0.5); hp.TextScaled = true; hp.Font = Enum.Font.Gotham; hp.Parent = bb
            task.spawn(function() while ch and ch.Parent and bb and bb.Parent do local hum = ch:FindFirstChild("Humanoid")
                if hum then local b = Core.GetBounty(Players:GetPlayerFromCharacter(ch) or {}); hp.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. (b > 0 and " $"..b or "") end; task.wait(0.5) end end)
        end
        local function upd() for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then mk(p.Character) end end end
        upd(); Connections:Add("PESPUpdate", RunService.Heartbeat:Connect(function() if th() then upd() end end))
    else Connections:Remove("PESPUpdate"); pcall(function() for _, p in pairs(Players:GetPlayers()) do if p.Character then local e = p.Character:FindFirstChild("_PESP"); if e then e:Destroy() end end end end) end
end

function Extras.EnableFullBright(on) Config.Extras.FullBright = on; if on then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; for _, ef in pairs(Lighting:GetDescendants()) do if ef:IsA("Atmosphere") or ef:IsA("BlurEffect") or ef:IsA("ColorCorrectionEffect") then ef.Enabled = false end end else Lighting.Brightness = 1; Lighting.GlobalShadows = true end end

function Extras.EnableFPSBoost(on) Config.Extras.FPSBoost = on; if on then pcall(function() local t = Workspace.Terrain; t.WaterWaveSize=0; t.WaterWaveSpeed=0; t.WaterReflectance=0; t.WaterTransparency=0 end); pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end); for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled = false end end else pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end) end end

function Extras.EnableAutoStats(on) Config.Player.AutoStats = on; if on then local th = createThrottle(1); Connections:Add("AutoStats", RunService.Heartbeat:Connect(function() if not Config.Player.AutoStats or not th() then return end; local d = LocalPlayer:FindFirstChild("Data"); if not d then return end; local pts = d:FindFirstChild("Points"); if not pts or pts.Value <= 0 then return end; local m = {Melee="Melee",Defense="Defense",Sword="Sword",Gun="Gun",["Blox Fruit"]="Demon Fruit"}; Core.SafeRemote("AddPoint", m[Config.Player.StatsMode] or "Melee", 1) end)) else Connections:Remove("AutoStats") end end

function Extras.EnableAutoCollect(on) Config.Extras.AutoCollect = on; if on then local th = createThrottle(1); Connections:Add("AutoCollect", RunService.Heartbeat:Connect(function() if not Config.Extras.AutoCollect or not th() then return end; local hrp = Core.GetHRP(); if not hrp then return end; for _, obj in pairs(Workspace:GetDescendants()) do if obj:IsA("ProximityPrompt") and obj.Enabled then local part = obj.Parent; if part and part:IsA("BasePart") and Core.GetDistance(hrp, part) < 15 then pcall(function() fireproximityprompt(obj) end) end end end end)) else Connections:Remove("AutoCollect") end end

-- v14.2: Auto Race upgrade
function Extras.EnableAutoRace(on)
    Config.Player.AutoRace = on
    if on then
        local th = createThrottle(10)
        Connections:Add("AutoRace", RunService.Heartbeat:Connect(function()
            if not Config.Player.AutoRace or not th() then return end
            Core.SafeRemote("BuyRace")
        end))
        Core.Notify("🏃 Auto Race", "ON", 3)
    else Connections:Remove("AutoRace") end
end

function Extras.EnableAutoRejoin(on) Config.Extras.AutoRejoin = on end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                              STATUS HUD v2
-- ══════════════════════════════════════════════════════════════════════════════════════════

local StatusHUD = {}
function StatusHUD.Create()
    if PlayerGui:FindFirstChild("BFHUD") then PlayerGui.BFHUD:Destroy() end
    local gui = Instance.new("ScreenGui"); gui.Name = "BFHUD"; gui.ResetOnSpawn = false; gui.DisplayOrder = 100; gui.Parent = PlayerGui
    local frame = Instance.new("Frame"); frame.Name = "HUD"; frame.Size = UDim2.new(0,260,0,155); frame.Position = UDim2.new(0,10,0.5,-75)
    frame.BackgroundColor3 = Color3.fromRGB(12,12,20); frame.BackgroundTransparency = 0.15; frame.BorderSizePixel = 0
    frame.Active = true; frame.Draggable = true; frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(138,43,226); s.Thickness = 1.5; s.Transparency = 0.3; s.Parent = frame
    local function lbl(name, y, c, sz)
        local l = Instance.new("TextLabel"); l.Name = name; l.Size = UDim2.new(1,-14,0,14); l.Position = UDim2.new(0,7,0,y)
        l.BackgroundTransparency = 1; l.TextColor3 = c or Color3.fromRGB(200,200,220); l.TextSize = sz or 11
        l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = frame; return l
    end
    local tL = lbl("T",5,Color3.fromRGB(255,215,0),13); tL.Text = "🎮 BF Ultimate v14.2 Supreme"; tL.Font = Enum.Font.GothamBold
    local mL = lbl("M",23); local sL = lbl("S",39,Color3.fromRGB(150,150,170)); local lvL = lbl("L",55,Color3.fromRGB(150,150,170))
    local aL = lbl("A",71,Color3.fromRGB(150,150,170)); local rL = lbl("R",87,Color3.fromRGB(150,150,170))
    local bL = lbl("B",103,Color3.fromRGB(150,150,170)); local svL = lbl("SV",119,Color3.fromRGB(150,150,170))
    local hpL = lbl("HP",135,Color3.fromRGB(150,150,170))
    local th = createThrottle(0.5)
    Connections:Add("HUDUpdate", RunService.Heartbeat:Connect(function()
        if not th() then return end
        pcall(function()
            mL.Text = Config.AutoFarm.Enabled and ("Farm: " .. Config.AutoFarm.Mode .. " [" .. Farm.Phase .. "]") or "Farm: OFF"
            mL.TextColor3 = Config.AutoFarm.Enabled and Color3.fromRGB(0,255,127) or Color3.fromRGB(200,200,220)
            sL.Text = Farm.Status; lvL.Text = "Lvl: " .. Core.GetLevel() .. " | " .. Core.GetWorldName()
            aL.Text = (Config.KillAura.Enabled and "Aura: ON" or "Aura: OFF") .. (Config.MobAura.Enabled and " | Mob: ON" or "")
            aL.TextColor3 = (Config.KillAura.Enabled or Config.MobAura.Enabled) and Color3.fromRGB(255,100,100) or Color3.fromRGB(150,150,170)
            rL.Text = Config.Raid.AutoRaid and ("Raid: " .. Raid.Status) or "Raid: OFF"
            bL.Text = Config.BountyHunt.Enabled and ("Hunt: " .. BountyHunt.Status) or "Hunt: OFF"
            svL.Text = "Server: " .. Core.GetPlayerCount() .. "/" .. Core.GetMaxPlayers()
            hpL.Text = "HP: " .. math.floor(Core.GetHealthPercent()) .. "%" .. (Config.Dodge.Enabled and " | Dodge: ON" or "")
        end)
    end))
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                   KEYBINDS
-- ══════════════════════════════════════════════════════════════════════════════════════════

local function SetupKeybinds()
    Connections:Add("Keybinds", UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Config.Keybinds.ToggleFarm then Config.AutoFarm.Enabled = not Config.AutoFarm.Enabled; if Config.AutoFarm.Enabled then Farm.Start() else Farm.Stop() end
        elseif input.KeyCode == Config.Keybinds.ToggleFly then Movement.EnableFly(not Movement.IsFlying)
        elseif input.KeyCode == Config.Keybinds.ToggleAura then KillAura.Enable(not Config.KillAura.Enabled)
        elseif input.KeyCode == Config.Keybinds.ToggleMobAura then MobAura.Enable(not Config.MobAura.Enabled)
        elseif input.KeyCode == Config.Keybinds.StopAll then
            Config.AutoFarm.Enabled = false; Config.Movement.Fly = false; Config.KillAura.Enabled = false
            Config.MobAura.Enabled = false; Config.BountyHunt.Enabled = false; Config.Raid.AutoRaid = false
            Config.SeaChange.AutoChange = false; Config.Dodge.Enabled = false
            Connections:ClearAll(); Movement.StopTween(); Core.Notify("🛑 STOP ALL", "Halted!", 3)
            task.wait(0.1); SetupKeybinds(); StatusHUD.Create()
        end
    end))
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                        UI
-- ══════════════════════════════════════════════════════════════════════════════════════════

local function LoadUI()
    local ok, OrionLib = pcall(function() return loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))() end)
    if not ok then Core.Notify("❌ Error", "UI failed!", 5); return end

    local W = OrionLib:MakeWindow({Name = "🎮 Blox Fruits Ultimate v14.2 SUPREME", HidePremium = false, SaveConfig = true, ConfigFolder = "BFUltimateV14", IntroEnabled = false})

    -- ═══ MAIN TAB ═══
    local T1 = W:MakeTab({Name = "🏠 Main", Icon = "rbxassetid://7734053495"})
    T1:AddParagraph("Info", "Level: " .. Core.GetLevel() .. " | " .. Core.GetWorldName() .. " | Server: " .. Core.GetPlayerCount() .. "/" .. Core.GetMaxPlayers())
    T1:AddToggle({Name = "🌾 Auto Farm", Default = false, Callback = function(v) Config.AutoFarm.Enabled = v; if v then Farm.Start() else Farm.Stop() end end})
    T1:AddDropdown({Name = "Farm Mode", Default = "Level", Options = {"Level","Mastery","Boss"}, Callback = function(v) Config.AutoFarm.Mode = v end})
    T1:AddToggle({Name = "📋 Auto Quest", Default = true, Callback = function(v) Config.AutoQuest.Enabled = v end})
    T1:AddDropdown({Name = "Weapon", Default = "Melee", Options = {"Melee","Sword","Blox Fruit","Gun"}, Callback = function(v) Config.Combat.Weapon = v end})
    T1:AddDropdown({Name = "Target Priority", Default = "Nearest", Options = {"Nearest","Lowest HP","Highest HP"}, Callback = function(v) Config.Combat.TargetPriority = v end})
    T1:AddToggle({Name = "🧲 Bring Mobs (Pull All)", Default = true, Callback = function(v) Config.AutoFarm.BringMobs = v end})
    T1:AddSlider({Name = "Farm Height (studs)", Min = 10, Max = 50, Default = 25, Callback = function(v) Config.AutoFarm.FarmHeight = v end})
    T1:AddSlider({Name = "Dip Height (attack)", Min = 3, Max = 20, Default = 8, Callback = function(v) Config.AutoFarm.DipHeight = v end})
    T1:AddSlider({Name = "Pull Range", Min = 50, Max = 300, Default = 120, Callback = function(v) Config.AutoFarm.PullRange = v end})
    T1:AddParagraph("How it works", "Sobe → Puxa mobs → Desce → Click attack → Sobe (loop seguro, sem skills)")

    -- ═══ COMBAT TAB ═══
    local T2 = W:MakeTab({Name = "⚔️ Combat", Icon = "rbxassetid://7734053495"})
    T2:AddToggle({Name = "💀 Kill Aura", Default = false, Callback = function(v) KillAura.Enable(v) end})
    T2:AddSlider({Name = "Aura Radius", Min = 20, Max = 150, Default = 60, Callback = function(v) Config.KillAura.Radius = v end})
    T2:AddSlider({Name = "Max Targets", Min = 1, Max = 15, Default = 5, Callback = function(v) Config.KillAura.MaxTargets = v end})
    T2:AddToggle({Name = "🧲 Mob Aura (Pull+Attack)", Default = false, Callback = function(v) MobAura.Enable(v) end})
    T2:AddSlider({Name = "Pull Radius", Min = 30, Max = 200, Default = 80, Callback = function(v) Config.MobAura.PullRadius = v end})
    T2:AddToggle({Name = "🛡️ Auto Dodge", Default = false, Callback = function(v) DodgeSystem.Enable(v) end})
    T2:AddSlider({Name = "Dodge HP%", Min = 10, Max = 50, Default = 30, Callback = function(v) Config.Dodge.HPThreshold = v end})
    T2:AddToggle({Name = "🔗 Combo System", Default = false, Callback = function(v) Config.Combo.Enabled = v end})
    T2:AddSlider({Name = "Combo Delay", Min = 5, Max = 50, Default = 15, Callback = function(v) Config.Combo.Delay = v/100 end})

    -- ═══ PVP TAB ═══
    local T2b = W:MakeTab({Name = "🏴‍☠️ PVP", Icon = "rbxassetid://7734053495"})
    T2b:AddToggle({Name = "🏴‍☠️ Bounty Hunt", Default = false, Callback = function(v) BountyHunt.Enable(v) end})
    T2b:AddSlider({Name = "Min Bounty ($)", Min = 10000, Max = 500000, Default = 50000, Callback = function(v) Config.BountyHunt.MinBounty = v end})
    T2b:AddSlider({Name = "Hunt Range", Min = 100, Max = 2000, Default = 500, Callback = function(v) Config.BountyHunt.MaxDistance = v end})
    T2b:AddToggle({Name = "👥 Player ESP", Default = false, Callback = function(v) Extras.EnablePlayerESP(v) end})

    -- ═══ RAID TAB ═══
    local T3 = W:MakeTab({Name = "⚔️ Raid", Icon = "rbxassetid://7734053495"})
    T3:AddToggle({Name = "⚔️ Auto Raid", Default = false, Callback = function(v) Raid.Enable(v) end})
    T3:AddToggle({Name = "🎁 Raid Auto Collect", Default = true, Callback = function(v) Config.Raid.AutoCollect = v end})
    local rn = {"Auto"}; for _, r in ipairs(RaidData) do table.insert(rn, r.Name) end
    T3:AddDropdown({Name = "Select Raid", Default = "Auto", Options = rn, Callback = function(v) Config.Raid.SelectedRaid = v end})

    -- ═══ SEA & TRAVEL TAB ═══
    local T4 = W:MakeTab({Name = "🌊 Sea & Travel", Icon = "rbxassetid://7733960981"})
    T4:AddToggle({Name = "🌊 Auto Sea Change", Default = false, Callback = function(v) SeaChange.Enable(v) end})
    T4:AddParagraph("Sea Info", "Sea 1→2: Lvl 700 | Sea 2→3: Lvl 1500")
    T4:AddDropdown({Name = "📍 First Sea", Default = TeleportOptions["First Sea"][1], Options = TeleportOptions["First Sea"], Callback = function(v) Movement.TweenTo(Teleports["First Sea"][v]) end})
    T4:AddDropdown({Name = "📍 Second Sea", Default = TeleportOptions["Second Sea"][1], Options = TeleportOptions["Second Sea"], Callback = function(v) Movement.TweenTo(Teleports["Second Sea"][v]) end})
    T4:AddDropdown({Name = "📍 Third Sea", Default = TeleportOptions["Third Sea"][1], Options = TeleportOptions["Third Sea"], Callback = function(v) Movement.TweenTo(Teleports["Third Sea"][v]) end})
    T4:AddButton({Name = "🔄 Server Hop (Low Pop)", Callback = function() ServerHop.HopToLowest() end})
    T4:AddButton({Name = "🎲 Server Hop (Random)", Callback = function() ServerHop.HopRandom() end})
    T4:AddSlider({Name = "Max Players (Hop)", Min = 1, Max = 30, Default = 20, Callback = function(v) Config.ServerHop.MaxPlayers = v end})

    -- ═══ MOVEMENT TAB ═══
    local T5 = W:MakeTab({Name = "🚀 Movement", Icon = "rbxassetid://7733960981"})
    T5:AddToggle({Name = "✈️ Fly", Default = false, Callback = function(v) Movement.EnableFly(v) end})
    T5:AddSlider({Name = "Fly Speed", Min = 50, Max = 500, Default = 150, Callback = function(v) Config.Movement.FlySpeed = v end})
    T5:AddToggle({Name = "👻 Noclip", Default = false, Callback = function(v) Movement.EnableNoclip(v) end})
    T5:AddToggle({Name = "🦘 Infinite Jump", Default = false, Callback = function(v) Movement.EnableInfJump(v) end})
    T5:AddSlider({Name = "Tween Speed", Min = 100, Max = 1000, Default = 300, Callback = function(v) Config.Movement.TweenSpeed = v end})
    T5:AddSlider({Name = "Walk Speed", Min = 16, Max = 200, Default = 16, Callback = function(v) Movement.SetSpeed(v, nil) end})
    T5:AddSlider({Name = "Jump Power", Min = 50, Max = 300, Default = 50, Callback = function(v) Movement.SetSpeed(nil, v) end})

    -- ═══ PLAYER TAB ═══
    local T6 = W:MakeTab({Name = "👤 Player", Icon = "rbxassetid://7734053495"})
    T6:AddToggle({Name = "📊 Auto Stats", Default = false, Callback = function(v) Extras.EnableAutoStats(v) end})
    T6:AddDropdown({Name = "Stats Target", Default = "Melee", Options = {"Melee","Defense","Sword","Gun","Blox Fruit"}, Callback = function(v) Config.Player.StatsMode = v end})
    T6:AddToggle({Name = "🏃 Auto Race", Default = false, Callback = function(v) Extras.EnableAutoRace(v) end})
    T6:AddToggle({Name = "🎁 Auto Collect", Default = false, Callback = function(v) Extras.EnableAutoCollect(v) end})
    T6:AddToggle({Name = "❤️ Auto Heal", Default = false, Callback = function(v) Extras.EnableAutoHeal(v) end})

    -- ═══ EXTRAS TAB ═══
    local T7 = W:MakeTab({Name = "⚡ Extras", Icon = "rbxassetid://7733674035"})
    T7:AddToggle({Name = "💤 Anti-AFK", Default = true, Callback = function(v) Extras.EnableAntiAFK(v) end})
    T7:AddToggle({Name = "✊ Armament Haki (Buso)", Default = false, Callback = function(v) Extras.EnableAutoHaki(v) end})
    T7:AddToggle({Name = "👁️ Observation Haki (Ken)", Default = false, Callback = function(v) Extras.EnableObservationHaki(v) end})
    T7:AddToggle({Name = "🍎 Fruit Sniper", Default = false, Callback = function(v) Extras.EnableFruitSniper(v) end})
    T7:AddToggle({Name = "🍎 Auto Eat Fruit", Default = false, Callback = function(v) Config.Fruit.AutoEat = v end})
    T7:AddToggle({Name = "📦 Auto Store Fruit", Default = false, Callback = function(v) Config.Fruit.AutoStore = v end})
    T7:AddToggle({Name = "🏝️ Mirage Detector", Default = false, Callback = function(v) MirageDetector.Enable(v) end})
    T7:AddToggle({Name = "👁️ Enemy ESP", Default = false, Callback = function(v) Extras.EnableESP(v) end})
    T7:AddToggle({Name = "☀️ Full Bright", Default = false, Callback = function(v) Extras.EnableFullBright(v) end})
    T7:AddToggle({Name = "⚡ FPS Boost", Default = false, Callback = function(v) Extras.EnableFPSBoost(v) end})
    T7:AddToggle({Name = "🔄 Auto Rejoin", Default = false, Callback = function(v) Extras.EnableAutoRejoin(v) end})

    -- ═══ SETTINGS TAB ═══
    local T8 = W:MakeTab({Name = "⚙️ Settings", Icon = "rbxassetid://7734053495"})
    T8:AddToggle({Name = "🔔 Notifications", Default = true, Callback = function(v) Config.System.Notifications = v end})
    T8:AddToggle({Name = "💾 Auto Save Config", Default = true, Callback = function(v) Config.System.SaveConfig = v end})
    T8:AddToggle({Name = "🐛 Debug Mode", Default = false, Callback = function(v) Config.System.DebugMode = v end})
    T8:AddButton({Name = "💾 Save Config Now", Callback = function()
        local saveable = HttpService:JSONDecode(HttpService:JSONEncode(Config)); saveable.Keybinds = nil
        ConfigManager.Save(saveable); Core.Notify("💾 Saved!", "Config saved to file", 3)
    end})
    T8:AddButton({Name = "🗑️ Reset Config", Callback = function() ConfigManager.Delete(); Core.Notify("🗑️ Reset!", "Config deleted. Rejoin for defaults.", 5) end})
    T8:AddButton({Name = "🛑 STOP ALL (F4)", Callback = function()
        Config.AutoFarm.Enabled = false; Config.Movement.Fly = false; Config.KillAura.Enabled = false
        Config.MobAura.Enabled = false; Config.BountyHunt.Enabled = false; Config.Raid.AutoRaid = false
        Config.SeaChange.AutoChange = false; Config.Dodge.Enabled = false
        Connections:ClearAll(); Movement.StopTween(); Core.Notify("🛑 STOP", "Halted!", 3)
        task.wait(0.1); SetupKeybinds(); StatusHUD.Create()
    end})
    T8:AddButton({Name = "🔄 Rejoin Server", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end})
    T8:AddParagraph("Keybinds", "F1: Farm | F2: Fly | F3: Kill Aura | F4: Stop All | F5: Mob Aura")
    T8:AddParagraph("Connections", "Active: " .. Connections:Count())
    T8:AddLabel("🎮 v14.2 SUPREME | Premium Script")

    OrionLib:Init(); Extras.EnableAntiAFK(true)
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                   INITIALIZATION
-- ══════════════════════════════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Config.Movement.WalkSpeed ~= 16 then Movement.SetSpeed(Config.Movement.WalkSpeed, nil) end
    if Config.Movement.JumpPower ~= 50 then Movement.SetSpeed(nil, Config.Movement.JumpPower) end
    if Config.Movement.Fly then task.wait(0.5); Movement.EnableFly(true) end
end)

Players.PlayerRemoving:Connect(function(p)
    if p == LocalPlayer then
        if Config.System.SaveConfig then
            local saveable = HttpService:JSONDecode(HttpService:JSONEncode(Config)); saveable.Keybinds = nil
            ConfigManager.Save(saveable)
        end
        if Config.Extras.AutoRejoin then pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end
    end
end)

SetupKeybinds(); StatusHUD.Create(); LoadUI()

Core.Notify("✅ Loaded!", "v14.2 SUPREME | Lvl: " .. Core.GetLevel() .. " | " .. Core.GetWorldName(), 5)

print([[
╔══════════════════════════════════════════════════════════════════════════════════════════╗
║                    BLOX FRUITS ULTIMATE v14.2 SUPREME - LOADED                           ║
║  F1=Farm | F2=Fly | F3=Aura | F4=Stop | F5=MobAura                                    ║
║  New: ServerHop • MobAura • Dodge • Combo • Mirage • AutoHeal • ConfigSave             ║
╚══════════════════════════════════════════════════════════════════════════════════════════╝
]])

return {Core=Core, Config=Config, Farm=Farm, Movement=Movement, Combat=Combat, KillAura=KillAura,
    MobAura=MobAura, BountyHunt=BountyHunt, Raid=Raid, SeaChange=SeaChange, ServerHop=ServerHop,
    MirageDetector=MirageDetector, DodgeSystem=DodgeSystem, Extras=Extras, ConfigManager=ConfigManager}
