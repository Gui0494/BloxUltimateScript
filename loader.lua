--[[
╔══════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                                      ║
║    ██████╗ ██╗      ██████╗ ██╗  ██╗    ███████╗██████╗ ██╗   ██╗██╗████████╗███████╗                ║
║    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝    ██╔════╝██╔══██╗██║   ██║██║╚══██╔══╝██╔════╝                ║
║    ██████╔╝██║     ██║   ██║ ╚███╔╝     █████╗  ██████╔╝██║   ██║██║   ██║   ███████╗                ║
║    ██╔══██╗██║     ██║   ██║ ██╔██╗     ██╔══╝  ██╔══██╗██║   ██║██║   ██║   ╚════██║                ║
║    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗    ██║     ██║  ██║╚██████╔╝██║   ██║   ███████║                ║
║    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝   ╚═╝   ╚══════╝                ║
║                                                                                                      ║
║                              ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗          ║
║                              ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝          ║
║                              ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗            ║
║                              ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝            ║
║                              ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗          ║
║                               ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝          ║
║                                                                                                      ║
║                                   『 v14.1 SUPREME EDITION 』                                        ║
║                                          LOADER                                                      ║
║                                                                                                      ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════╝

    Este é o LOADER. Ele mostra a animação de carregamento
    e depois baixa o script principal do GitHub.
    
    ► COMO USAR:
    1. Suba o Main.lua para seu repositório GitHub
    2. Substitua a URL abaixo pela RAW URL do seu Main.lua
    3. Execute ESTE arquivo no executor (Delta, etc.)
]]

-- ══════════════════════════════════════════════════════════════════════════════════════════
--              ⚠️  CONFIGURE SUA URL AQUI  ⚠️
-- ══════════════════════════════════════════════════════════════════════════════════════════

local SCRIPT_URL = "https://raw.githubusercontent.com/Gui0494/BloxUltimateScript/main/main.lua"
--                                              ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
--                                    TROQUE AQUI pela sua URL RAW do GitHub!
--
--  Exemplo real:
--  local SCRIPT_URL = "https://raw.githubusercontent.com/GuilhermeDev/BloxFruitsUltimate/main/Main.lua"

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                              LOADER CONFIGURATION
-- ══════════════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local LoaderConfig = {
    Title = "BLOX FRUITS",
    Subtitle = "ULTIMATE",
    Version = "v14.1 SUPREME",
    PrimaryColor = Color3.fromRGB(138, 43, 226),
    SecondaryColor = Color3.fromRGB(75, 0, 130),
    AccentColor = Color3.fromRGB(255, 215, 0),
    GlowColor = Color3.fromRGB(186, 85, 211),
    BackgroundColor = Color3.fromRGB(10, 10, 15),
    CardColor = Color3.fromRGB(20, 20, 30),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(150, 150, 170),
    SuccessColor = Color3.fromRGB(0, 255, 127),
    ErrorColor = Color3.fromRGB(255, 75, 75),
}

local LoadingSteps = {
    {text = "Initializing core...",            duration = 0.25},
    {text = "Verifying game environment...",   duration = 0.20},
    {text = "Connecting to server...",         duration = 0.30},
    {text = "Downloading script...",           duration = 0.40},
    {text = "Loading protection layer...",     duration = 0.25},
    {text = "Building quest database...",      duration = 0.35},
    {text = "Mapping teleport coordinates...", duration = 0.30},
    {text = "Initializing combat engine...",   duration = 0.25},
    {text = "Loading raid system...",          duration = 0.25},
    {text = "Setting up kill aura...",         duration = 0.20},
    {text = "Configuring sea navigation...",   duration = 0.20},
    {text = "Building bounty tracker...",      duration = 0.20},
    {text = "Creating interface...",           duration = 0.30},
    {text = "Finalizing...",                   duration = 0.15},
    {text = "Ready!",                          duration = 0.15},
}

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                   GUI LOADER CLASS
-- ══════════════════════════════════════════════════════════════════════════════════════════

local GUILoader = {}
GUILoader.__index = GUILoader

function GUILoader.new()
    local self = setmetatable({}, GUILoader)
    self.Gui = nil
    self.Blur = nil
    self.Progress = 0
    self.Particles = {}
    self._alive = true
    return self
end

function GUILoader:Tween(inst, props, dur, style, dir)
    return TweenService:Create(inst, TweenInfo.new(dur, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
end

function GUILoader:Corner(parent, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = parent; return c
end

function GUILoader:Stroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke"); s.Color = color or LoaderConfig.PrimaryColor
    s.Thickness = thick or 2; s.Transparency = trans or 0; s.Parent = parent; return s
end

function GUILoader:Gradient(parent, colors, rot)
    local g = Instance.new("UIGradient")
    g.Color = colors or ColorSequence.new({
        ColorSequenceKeypoint.new(0, LoaderConfig.PrimaryColor),
        ColorSequenceKeypoint.new(1, LoaderConfig.SecondaryColor)
    })
    g.Rotation = rot or 45; g.Parent = parent; return g
end

function GUILoader:Create()
    if PlayerGui:FindFirstChild("BFLoader") then PlayerGui.BFLoader:Destroy() end
    if Lighting:FindFirstChild("LBlur") then Lighting.LBlur:Destroy() end

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "BFLoader"
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Gui.IgnoreGuiInset = true
    self.Gui.ResetOnSpawn = false
    self.Gui.DisplayOrder = 999
    self.Gui.Parent = PlayerGui

    self.Blur = Instance.new("BlurEffect")
    self.Blur.Name = "LBlur"; self.Blur.Size = 0; self.Blur.Parent = Lighting

    -- Background
    local bg = Instance.new("Frame")
    bg.Name = "BG"; bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = LoaderConfig.BackgroundColor
    bg.BackgroundTransparency = 1; bg.BorderSizePixel = 0; bg.Parent = self.Gui
    self.BG = bg

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0); overlay.BackgroundTransparency = 0.85
    overlay.BorderSizePixel = 0; overlay.Parent = bg
    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, LoaderConfig.PrimaryColor),
        ColorSequenceKeypoint.new(0.5, LoaderConfig.BackgroundColor),
        ColorSequenceKeypoint.new(1, LoaderConfig.SecondaryColor)
    })
    bgGrad.Parent = overlay; self.BgGrad = bgGrad

    -- Particles
    local pContainer = Instance.new("Frame")
    pContainer.Size = UDim2.new(1,0,1,0); pContainer.BackgroundTransparency = 1; pContainer.Parent = bg
    for i = 1, 20 do
        local sz = math.random(3, 12)
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0,sz,0,sz)
        p.Position = UDim2.new(math.random()/1, 0, math.random()/1, 0)
        p.BackgroundColor3 = LoaderConfig.PrimaryColor
        p.BackgroundTransparency = math.random(70,95)/100
        p.BorderSizePixel = 0; p.Parent = pContainer
        self:Corner(p, sz/2)
        table.insert(self.Particles, {frame=p, sx=math.random(-100,100)/1000, sy=math.random(-100,100)/1000})
    end

    -- Main Card
    local card = Instance.new("Frame")
    card.Name = "Card"; card.Size = UDim2.new(0,460,0,360)
    card.Position = UDim2.new(0.5,0,0.5,0); card.AnchorPoint = Vector2.new(0.5,0.5)
    card.BackgroundColor3 = LoaderConfig.CardColor; card.BackgroundTransparency = 0.1
    card.BorderSizePixel = 0; card.Parent = bg
    self.Card = card; self:Corner(card, 16)

    -- Glow
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1,100,1,100); glow.Position = UDim2.new(0.5,0,0.5,0)
    glow.AnchorPoint = Vector2.new(0.5,0.5); glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"; glow.ImageColor3 = LoaderConfig.PrimaryColor
    glow.ImageTransparency = 0.7; glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24,24,276,276); glow.ZIndex = 0; glow.Parent = card
    self.Glow = glow

    -- Border
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1,4,1,4); border.Position = UDim2.new(0.5,0,0.5,0)
    border.AnchorPoint = Vector2.new(0.5,0.5); border.BackgroundTransparency = 1
    border.ZIndex = 0; border.Parent = card
    local bs = self:Stroke(border, LoaderConfig.PrimaryColor, 2, 0.5)
    self:Corner(border, 18); self:Gradient(bs)

    -- Logo Container
    local logoC = Instance.new("Frame")
    logoC.Size = UDim2.new(1,0,0,120); logoC.Position = UDim2.new(0,0,0,20)
    logoC.BackgroundTransparency = 1; logoC.Parent = card

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,50); title.Position = UDim2.new(0,0,0,10)
    title.BackgroundTransparency = 1; title.Text = LoaderConfig.Title
    title.TextColor3 = LoaderConfig.TextColor; title.TextSize = 42
    title.Font = Enum.Font.GothamBlack; title.TextTransparency = 1; title.Parent = logoC
    self.Title = title

    local tGrad = Instance.new("UIGradient")
    tGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, LoaderConfig.AccentColor),
        ColorSequenceKeypoint.new(0.5, LoaderConfig.TextColor),
        ColorSequenceKeypoint.new(1, LoaderConfig.AccentColor)
    })
    tGrad.Parent = title; self.TGrad = tGrad

    -- Subtitle
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1,0,0,35); sub.Position = UDim2.new(0,0,0,55)
    sub.BackgroundTransparency = 1; sub.Text = LoaderConfig.Subtitle
    sub.TextColor3 = LoaderConfig.PrimaryColor; sub.TextSize = 32
    sub.Font = Enum.Font.GothamBold; sub.TextTransparency = 1; sub.Parent = logoC
    self.Sub = sub

    -- Version
    local ver = Instance.new("TextLabel")
    ver.Size = UDim2.new(1,0,0,20); ver.Position = UDim2.new(0,0,0,92)
    ver.BackgroundTransparency = 1; ver.Text = LoaderConfig.Version
    ver.TextColor3 = LoaderConfig.SubTextColor; ver.TextSize = 14
    ver.Font = Enum.Font.Gotham; ver.TextTransparency = 1; ver.Parent = logoC
    self.Ver = ver

    -- Progress Bar
    local pbar = Instance.new("Frame")
    pbar.Size = UDim2.new(0.85,0,0,8); pbar.Position = UDim2.new(0.5,0,0,180)
    pbar.AnchorPoint = Vector2.new(0.5,0)
    pbar.BackgroundColor3 = Color3.fromRGB(40,40,55)
    pbar.BorderSizePixel = 0; pbar.Parent = card; self:Corner(pbar, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0); fill.BackgroundColor3 = LoaderConfig.PrimaryColor
    fill.BorderSizePixel = 0; fill.Parent = pbar; self:Corner(fill, 4)
    self.Fill = fill
    self:Gradient(fill, ColorSequence.new({
        ColorSequenceKeypoint.new(0, LoaderConfig.PrimaryColor),
        ColorSequenceKeypoint.new(0.5, LoaderConfig.GlowColor),
        ColorSequenceKeypoint.new(1, LoaderConfig.AccentColor)
    }), 0)

    local pglow = Instance.new("Frame")
    pglow.Size = UDim2.new(0,20,1,10); pglow.Position = UDim2.new(1,-10,0.5,0)
    pglow.AnchorPoint = Vector2.new(0.5,0.5); pglow.BackgroundColor3 = LoaderConfig.AccentColor
    pglow.BackgroundTransparency = 0.5; pglow.BorderSizePixel = 0; pglow.Parent = fill
    self:Corner(pglow, 10)

    -- Percent
    local pct = Instance.new("TextLabel")
    pct.Size = UDim2.new(1,0,0,25); pct.Position = UDim2.new(0,0,0,195)
    pct.BackgroundTransparency = 1; pct.Text = "0%"
    pct.TextColor3 = LoaderConfig.AccentColor; pct.TextSize = 22
    pct.Font = Enum.Font.GothamBold; pct.TextTransparency = 1; pct.Parent = card
    self.Pct = pct

    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,0,0,20); status.Position = UDim2.new(0,0,0,225)
    status.BackgroundTransparency = 1; status.Text = "Starting..."
    status.TextColor3 = LoaderConfig.SubTextColor; status.TextSize = 14
    status.Font = Enum.Font.Gotham; status.TextTransparency = 1; status.Parent = card
    self.Status = status

    -- Spinner
    local spinC = Instance.new("Frame")
    spinC.Size = UDim2.new(0,40,0,40); spinC.Position = UDim2.new(0.5,0,0,265)
    spinC.AnchorPoint = Vector2.new(0.5,0); spinC.BackgroundTransparency = 1; spinC.Parent = card
    self.SpinC = spinC

    local ring = Instance.new("ImageLabel")
    ring.Size = UDim2.new(1,0,1,0); ring.BackgroundTransparency = 1
    ring.Image = "rbxassetid://11963373994"; ring.ImageColor3 = LoaderConfig.PrimaryColor
    ring.ImageTransparency = 1; ring.Parent = spinC
    self.Ring = ring

    -- Footer
    local foot = Instance.new("TextLabel")
    foot.Size = UDim2.new(1,0,0,20); foot.Position = UDim2.new(0,0,1,-30)
    foot.BackgroundTransparency = 1; foot.Text = "🎮 Premium Script • v14.1 Supreme"
    foot.TextColor3 = LoaderConfig.SubTextColor; foot.TextSize = 12
    foot.Font = Enum.Font.Gotham; foot.TextTransparency = 1; foot.Parent = card
    self.Foot = foot

    return self
end

function GUILoader:AnimateIn()
    self:Tween(self.Blur, {Size=24}, 0.5):Play()
    self:Tween(self.BG, {BackgroundTransparency=0}, 0.5):Play()
    self.Card.Size = UDim2.new(0,0,0,0)
    self:Tween(self.Card, {Size=UDim2.new(0,460,0,360)}, 0.6, Enum.EasingStyle.Back):Play()
    task.wait(0.3)
    for _, el in ipairs({self.Title, self.Sub, self.Ver}) do
        self:Tween(el, {TextTransparency=0}, 0.35):Play(); task.wait(0.08)
    end
    task.wait(0.15)
    self:Tween(self.Pct, {TextTransparency=0}, 0.3):Play()
    self:Tween(self.Status, {TextTransparency=0}, 0.3):Play()
    self:Tween(self.Ring, {ImageTransparency=0}, 0.3):Play()
    self:Tween(self.Foot, {TextTransparency=0}, 0.3):Play()
end

function GUILoader:AnimateOut(cb)
    for _, el in ipairs({self.Title,self.Sub,self.Ver,self.Pct,self.Status,self.Foot}) do
        self:Tween(el, {TextTransparency=1}, 0.25):Play()
    end
    self:Tween(self.Ring, {ImageTransparency=1}, 0.25):Play()
    task.wait(0.25)
    self:Tween(self.Card, {Size=UDim2.new(0,0,0,0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
    task.wait(0.25)
    self:Tween(self.BG, {BackgroundTransparency=1}, 0.35):Play()
    self:Tween(self.Blur, {Size=0}, 0.35):Play()
    task.wait(0.4)
    self._alive = false
    if self.Gui then self.Gui:Destroy() end
    if self.Blur then self.Blur:Destroy() end
    if cb then cb() end
end

function GUILoader:UpdateProgress(pct, txt)
    self.Progress = math.clamp(pct, 0, 100)
    self:Tween(self.Fill, {Size=UDim2.new(self.Progress/100,0,1,0)}, 0.25):Play()
    self.Pct.Text = math.floor(self.Progress) .. "%"
    if txt then self.Status.Text = txt end
    self:Tween(self.Glow, {ImageTransparency=0.5}, 0.08):Play()
    task.delay(0.1, function()
        if self._alive and self.Glow then
            self:Tween(self.Glow, {ImageTransparency=0.7}, 0.15):Play()
        end
    end)
end

function GUILoader:StartAnims()
    task.spawn(function()
        while self._alive do self.SpinC.Rotation = self.SpinC.Rotation + 5; task.wait(0.02) end
    end)
    task.spawn(function()
        while self._alive do
            for _, p in ipairs(self.Particles) do
                local nx = p.frame.Position.X.Scale + p.sx
                local ny = p.frame.Position.Y.Scale + p.sy
                if nx > 1 then nx = 0 elseif nx < 0 then nx = 1 end
                if ny > 1 then ny = 0 elseif ny < 0 then ny = 1 end
                p.frame.Position = UDim2.new(nx,0,ny,0)
            end; task.wait(0.03)
        end
    end)
    task.spawn(function()
        while self._alive do self.BgGrad.Rotation = (self.BgGrad.Rotation + 0.5) % 360; task.wait(0.05) end
    end)
    task.spawn(function()
        local o = 0
        while self._alive do o = (o + 0.01) % 1; self.TGrad.Offset = Vector2.new(o,0); task.wait(0.05) end
    end)
end

function GUILoader:RunLoading()
    local total = #LoadingSteps
    for i, step in ipairs(LoadingSteps) do
        self:UpdateProgress((i/total)*100, step.text)
        task.wait(step.duration)
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                                   EXECUTE LOADER
-- ══════════════════════════════════════════════════════════════════════════════════════════

-- Anti-Duplicate
if getgenv().BFUltimateV14_1Loaded then
    warn("[BF Ultimate v14.1] Script already running!")
    return
end

-- Run animated loader
local Loader = GUILoader.new()
Loader:Create()
Loader:AnimateIn()
Loader:StartAnims()
task.wait(0.4)
Loader:RunLoading()
task.wait(0.2)

-- Mark as loaded
getgenv().BFUltimateV14_1Loaded = true

-- Animate out
Loader:AnimateOut(function()
    print("[BF Ultimate v14.1] Loader complete!")
end)

-- ══════════════════════════════════════════════════════════════════════════════════════════
--                           DOWNLOAD & EXECUTE MAIN SCRIPT
-- ══════════════════════════════════════════════════════════════════════════════════════════

print("[BF Ultimate v14.1] Downloading main script...")

local success, err = pcall(function()
    loadstring(game:HttpGet(SCRIPT_URL))()
end)

if not success then
    warn("[BF Ultimate v14.1] FAILED to load main script!")
    warn("[BF Ultimate v14.1] Error: " .. tostring(err))
    warn("[BF Ultimate v14.1] URL: " .. SCRIPT_URL)
    
    -- Show error notification
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ Load Error!",
            Text = "Failed to download script. Check URL!",
            Duration = 10,
        })
    end)
else
    print("[BF Ultimate v14.1] Main script loaded successfully!")
end
