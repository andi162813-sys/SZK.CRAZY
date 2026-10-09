local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ONYXHUB-X-SZK/SZKWINDUI/refs/heads/main/szk/lua/libary/wind%20ui/szkhub-libary.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera
local cam = camera
local genv = getgenv and getgenv() or _G

local SCRIPT_NAME = "SZKHUB"
local SCRIPT_VERSION = "v1.7.2"


local BG_LIST = {
    { name = "SERIUS CAT",      id = "100129495197691" },
    { name = "MONTE EVEREST",   id = "124016448435305" },
    { name = "ART",             id = "90064912954009"  },
    { name = "FLOWER",          id = "106649541877806" },
    { name = "SILVER",          id = "91816825862557"  },
    { name = "BLACK LAKE WATER",id = "34494181460683"  },
    { name = "ANGEL STATUES",   id = "103516381279878" },
    { name = "SAMURAI CAT",     id = "75102853478391"  },
    { name = "FLOWER AGAIN",    id = "70967429484455"  },
    { name = "JAPAN FLOWER",    id = "77327983749206"  },
    { name = "WHITE FLOWER",    id = "129712892318094" },
    { name = "RED FULLNESS",    id = "81053303516002"  },
    { name = "SAMURAI HD",      id = "135414401061463" },
    { name = "REY",             id = "88751579241211"  },
}

local DEFAULT_BG = "100129495197691"


local Window = WindUI:CreateWindow({
    Title = "SZKHUB[Duels]",
    Author = "SZK",
    Folder = "SZKHUB",
    ConfigName = "SZK",
    Theme = "Graphite",
    Size = UDim2.fromOffset(520, 405),
    MinSize = Vector2.new(440, 335),
    MaxSize = Vector2.new(650, 500),
    Icon = "rbxassetid://85755059842228",
    IconThemed = true,
    Background = "rbxassetid://" .. DEFAULT_BG,
    BackgroundImageTransparency = 0.22,
    Transparent = false,
    Acrylic = false,
    SideBarWidth = 145,
    ElementsRadius = 12,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    Resizable = true,
    ModernLayout = true,
    ModernLayoutMergeElements = false,
    HidePanelBackground = false,
    BottomDragBarEnabled = true,
    Topbar = { Height = 42, ButtonsType = "Default" },
    OpenButton = {
        Enabled = true,
        Title = "SZKHUB[Duels]",
        Icon = "rbxassetid://85755059842228",
        OnlyMobile = false,
        Draggable = true,
        Scale = 0.82,
        StrokeThickness = 1,
        Color = ColorSequence.new(Color3.fromRGB(118,118,124), Color3.fromRGB(164,164,170))
    }
})

local WindUI_BgCache = nil

local function findWindUIBackground()
    if WindUI_BgCache and WindUI_BgCache.Parent then return WindUI_BgCache end
    WindUI_BgCache = nil
    local best, bestSize = nil, 0
    local roots = {}
    pcall(function() if gethui then table.insert(roots, gethui()) end end)
    pcall(function() table.insert(roots, game:GetService("CoreGui")) end)
    pcall(function() local pg = LP:FindFirstChild("PlayerGui"); if pg then table.insert(roots, pg) end end)

    local function scan(inst, depth)
        if depth > 12 then return end
        if inst:IsA("ImageLabel") then
            local sz = inst.AbsoluteSize.X * inst.AbsoluteSize.Y
            if sz > bestSize then bestSize = sz; best = inst end
        end
        for _, c in ipairs(inst:GetChildren()) do scan(c, depth + 1) end
    end
    for _, root in ipairs(roots) do
        if root then
            for _, c in ipairs(root:GetChildren()) do scan(c, 0) end
        end
    end
    WindUI_BgCache = best
    return best
end

local function setWindowBackground(id)
    local assetId = "rbxassetid://" .. id
    -- Intento API oficial
    pcall(function() if Window.SetBackground then Window:SetBackground(assetId) end end)
    pcall(function() if Window.SetBackgroundImage then Window:SetBackgroundImage(assetId) end end)
    pcall(function() if Window.Background then Window.Background = assetId end end)
    -- Fuerza el ImageLabel más grande
    local bg = findWindUIBackground()
    if bg then
        pcall(function()
            bg.Image = assetId
            if bg.ImageTransparency > 0.6 then bg.ImageTransparency = 0.22 end
        end)
    end
    -- Rescan por si acaso
    task.spawn(function()
        task.wait(0.15)
        local bg2 = findWindUIBackground()
        if bg2 and bg2 ~= bg then
            pcall(function() bg2.Image = assetId end)
        end
    end)
end


local SZK = {
    GlobalFov = 300,
    SilentAim  = {Enabled=false, Keybind=Enum.KeyCode.Q, Target="Cabeza", UseFovLimit=true, WallCheck=true, MaxDistance=5000, FovSize=300, _toggled=false},
    AutoShoot  = {Enabled=false, Keybind=Enum.KeyCode.E, Target="Cabeza", UseFovLimit=true, WallCheck=true, MaxDistance=5000, FovSize=300, ShootDelay=0.15, ActivateTime=0.05, _toggled=false, _lastShot=0},
    TriggerBot = {Enabled=false, Keybind=Enum.KeyCode.T, AutoEquip=true, AutoShoot=true, UnequipNoEnemy=true, PreferFirearm=true, DropMelee=true, Target="Cabeza", UseFovLimit=true, FovSize=300, WallCheck=true, MaxDistance=5000, ShootDelay=0.04, ActivateTime=0.02, _toggled=false, _lastShot=0, _weaponEquipped=nil, _shots=0},
    Settings   = {ShowFovCircle=true, ButtonsLocked=false},
    ESP = {
        Enabled=false, Highlight=false, Box=false, FillBox=false, Skeleton=false, HeadDot=false, Name=false,
        Distance=false, Health=false, Tracer=false, TracerOrigin="Bottom",
        ShowTeammates=false, TeamColor=Color3.fromRGB(0,255,100), EnemyColor=Color3.fromRGB(255,80,110),
        MaxDistance=1500
    },
    AutoFarm = {Enabled=false, _loopRunning=false},
    KnifeBot = {Enabled=false, TargetPart="Cabeza"},
    Macro    = {Enabled=false, Target="Cabeza", MaxDistance=5000, WallCheck=true, Cooldown=0.2, AutoEquip=true, _lastUse=0},
    Aimbot   = {Enabled=false, OnlyGun=true, ShowFOV=false, TargetPart="Cabeza", AimMode="FOV", Smoothness=0.9, Prediction=true, PredictionScale=0.7},
    Keybinds = {ESP=nil, TriggerBot=nil, SilentAim=nil, Aimbot=nil},
    Hitbox   = {Enabled=false, Size=15},
    Speed    = {Enabled=false, Multiplier=0.5, _loop=nil},
}
genv.SZK = SZK
genv.SZK_Target = nil
genv.SZK_ShotTarget = nil
genv.SZK_KnifeTarget = nil
genv.SZK_EquippedAccessories = genv.SZK_EquippedAccessories or {}
genv.SZK_HeadlessOn = false
genv.SZK_KorbloxOn = false

local ENEMY_COLOR = Color3.fromRGB(255, 80, 110)
local TEAM_COLOR  = Color3.fromRGB(0, 255, 100)
local STATE_COLORS = {
    Lobby = Color3.fromRGB(150, 150, 160),
    Clear = Color3.fromRGB(0, 230, 150),
    Enemy = Color3.fromRGB(255, 80, 110),
}
local currentStateColor = STATE_COLORS.Lobby


local function Notify(title, text, duration)
    pcall(function()
        WindUI:Notify({ Title = title, Content = text, Duration = duration or 3 })
    end)
end

local function getScoreboard()
    local pg = LP:FindFirstChild("PlayerGui"); if not pg then return nil end
    local main = pg:FindFirstChild("Main"); if not main then return nil end
    local frame = main:FindFirstChild("MainGameFrame"); if not frame then return nil end
    return frame:FindFirstChild("IngameScore")
end

local function refreshTeams()
    local snap = {}
    local score = getScoreboard()
    if score then
        for _, fName in ipairs({"TeamRed","TeamBlue"}) do
            local folder = score:FindFirstChild(fName)
            if folder then
                local team = (fName == "TeamRed") and "Red" or "Blue"
                for _, entry in ipairs(folder:GetChildren()) do
                    snap[string.lower(entry.Name)] = team
                end
            end
        end
    end
    return snap
end

local function getPlayerTeam(target)
    if not target then return nil end
    local snap = refreshTeams()
    local t = snap[string.lower(target.Name)]
    if not t and target.DisplayName then t = snap[string.lower(target.DisplayName)] end
    return t
end

local function IsSameTeam(plr)
    if not plr then return false end
    local a = getPlayerTeam(LP); local b = getPlayerTeam(plr)
    if not a or not b then return false end
    return a == b
end

local function InGame()
    if not LP then return false end
    local pg = LP:FindFirstChild("PlayerGui")
    local main = pg and (pg:FindFirstChild("Main") or pg)
    local frame = main and main:FindFirstChild("MainGameFrame")
    local score = frame and frame:FindFirstChild("IngameScore")
    local timer = score and score:FindFirstChild("Timer")
    if timer then
        local txt = tostring(timer.Text or ""):match("^%s*%d+:%d%d%s*$")
        if txt then return true end
    end
    local gA = LP:GetAttribute("Game"); local mA = LP:GetAttribute("Map")
    if typeof(gA) == "string" and gA ~= "" and typeof(mA) == "string" and mA ~= "" then return true end
    return false
end

local function GetHRP(plr)
    local c = plr and plr.Character; if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    return (h and h:IsA("BasePart")) and h or nil
end

local function IsAlive(plr)
    local c = plr and plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsEnemy(plr)
    if not plr or plr == LP then return false end
    if not plr.Character then return false end
    if IsSameTeam(plr) then return false end
    return IsAlive(plr)
end

local function GetParts(plr, mode)
    local char = plr and plr.Character; if not char then return {} end
    local names
    if mode == "Cabeza" then names = {"Head"}
    elseif mode == "Torso" then names = {"UpperTorso","LowerTorso","Torso"}
    else names = {"Head","UpperTorso","LowerTorso","Torso","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg"} end
    local out = {}
    for _, n in ipairs(names) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then out[#out+1] = p end
    end
    return out
end

local function FindBestTarget(cfg)
    local char = LP.Character
    local myHRP = GetHRP(LP)
    if not char or not myHRP then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local myPos = myHRP.Position
    local cx, cy = cam.ViewportSize.X/2, cam.ViewportSize.Y/2
    local fovLimit = cfg.FovSize or SZK.GlobalFov
    local best, bestScore, bestName = nil, math.huge, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if IsEnemy(plr) then
            params.FilterDescendantsInstances = {char, plr.Character}
            for _, part in ipairs(GetParts(plr, cfg.Target)) do
                local dist = (part.Position - myPos).Magnitude
                if dist <= cfg.MaxDistance then
                    local sp, on = cam:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local sd = (Vector2.new(sp.X, sp.Y) - Vector2.new(cx, cy)).Magnitude
                        if not cfg.UseFovLimit or sd <= fovLimit then
                            local score = sd + dist*0.05
                            if score < bestScore then
                                local visible = true
                                if cfg.WallCheck then
                                    local ray = workspace:Raycast(myPos, part.Position - myPos, params)
                                    visible = (ray == nil)
                                end
                                if visible then bestScore, best, bestName = score, part, plr.Name end
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestName
end

local function HasVisibleEnemy()
    if not InGame() then return false end
    local myHRP = GetHRP(LP); if not myHRP then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if IsEnemy(plr) then
            local eChar = plr.Character
            local part = eChar and (eChar:FindFirstChild("Head") or eChar:FindFirstChild("HumanoidRootPart"))
            if part then
                local sp, on = cam:WorldToViewportPoint(part.Position)
                if on and sp.Z > 0 then return true end
            end
        end
    end
    return false
end


local WeaponDB = genv.SZK_WeaponDB or { Guns = {}, Melees = {} }
genv.SZK_WeaponDB = WeaponDB

local function SaveWeaponDB()
    genv.SZK_WeaponDB = WeaponDB
    pcall(function()
        if writefile then
            writefile("SZK_WeaponDB.json", game:GetService("HttpService"):JSONEncode(WeaponDB))
        end
    end)
end

pcall(function()
    if readfile and isfile and isfile("SZK_WeaponDB.json") then
        local data = readfile("SZK_WeaponDB.json")
        local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(data) end)
        if ok and decoded and decoded.Guns then
            WeaponDB = decoded; genv.SZK_WeaponDB = WeaponDB
        end
    end
end)

local function IsFirearm(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    if WeaponDB.Guns[tool.Name] then return true end
    if WeaponDB.Melees[tool.Name] then return false end
    return nil
end

local function IsMelee(tool)
    if not tool then return false end
    local r = IsFirearm(tool)
    if r == false then return true end
    if r == true then return false end
    return true
end

function SZK_MarkAsGun(toolName)
    if not toolName or toolName == "" then return end
    WeaponDB.Guns[toolName] = true; WeaponDB.Melees[toolName] = nil
    SaveWeaponDB()
end
function SZK_MarkAsMelee(toolName)
    if not toolName or toolName == "" then return end
    WeaponDB.Melees[toolName] = true; WeaponDB.Guns[toolName] = nil
    SaveWeaponDB()
end
function SZK_ClearWeaponMemory(toolName)
    if toolName then
        WeaponDB.Guns[toolName] = nil; WeaponDB.Melees[toolName] = nil
    else
        WeaponDB.Guns = {}; WeaponDB.Melees = {}
    end
    SaveWeaponDB()
end
genv.SZK_MarkAsGun = SZK_MarkAsGun
genv.SZK_MarkAsMelee = SZK_MarkAsMelee
genv.SZK_ClearWeaponMemory = SZK_ClearWeaponMemory

local function FindWeaponInBackpack(prefer)
    local char = LP.Character; if not char then return nil end
    local equipped = char:FindFirstChildOfClass("Tool")
    local bp = LP:FindFirstChildOfClass("Backpack")
    local list = {}
    if equipped then list[#list+1] = {tool=equipped, eq=true} end
    if bp then
        for _, i in ipairs(bp:GetChildren()) do
            if i:IsA("Tool") then list[#list+1] = {tool=i, eq=false} end
        end
    end
    if #list == 0 then return nil end
    if prefer then
        for _, e in ipairs(list) do if e.eq and IsFirearm(e.tool) == true then return e.tool end end
        for _, e in ipairs(list) do if not e.eq and IsFirearm(e.tool) == true then return e.tool end end
    end
    for _, e in ipairs(list) do if e.eq then return e.tool end end
    for _, e in ipairs(list) do return e.tool end
    return nil
end

local function EquipTool(tool)
    local char = LP.Character; if not char or not tool then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    pcall(function() hum:EquipTool(tool) end)
    return true
end


local KillSoundEnabled      = false
local RecargaDisparoEnabled = false
local MuteOriginalShoot     = true   -- ✅ NUEVO: silenciar disparo original
local SelectedKillSound     = "Onichaaan"
local SelectedShootReload   = "chispas"
local KillSoundVolume       = 1

local KillSounds = {
    { Name = "Onichaaan",       Id = "114361503583259" },
    { Name = "Omagaaa",         Id = "4496966777" },
    { Name = "korummm",         Id = "119896940405402" },
    { Name = "FAAAH XD",        Id = "92076037937225" },
    { Name = "Campana meme",    Id = "107378927201728" },
    { Name = "Enrique",         Id = "100688006999379" },
    { Name = "Magia de anime",  Id = "109296938403067" },
    { Name = "Risa anime",      Id = "93739527256723" },
    { Name = "Gemido",          Id = "94981264286350" },
    { Name = "Magic 2",         Id = "100507897550384" },
    { Name = "OwO",             Id = "71942674274967" },
    { Name = "SEMPAI >.<",      Id = "115498703521334" },
    { Name = "Ahhh:3",          Id = "83559496188823" },
    { Name = "ñyaa >//~//<",    Id = "78798011197804" },
}

local ShootReloadOptions = {
    ["chispas"] = { Shoot = "109296938403067", Reload = "100507897550384" },
}

local KillSoundPlayer = Instance.new("Sound")
KillSoundPlayer.Name = "SZK_KillSound"
KillSoundPlayer.Volume = KillSoundVolume
KillSoundPlayer.Looped = false
KillSoundPlayer.Parent = SoundService

local ShootSoundPlayer = Instance.new("Sound")
ShootSoundPlayer.Name = "SZK_ShootSound"
ShootSoundPlayer.Volume = KillSoundVolume
ShootSoundPlayer.Looped = false
ShootSoundPlayer.Parent = SoundService

local ReloadSoundPlayer = Instance.new("Sound")
ReloadSoundPlayer.Name = "SZK_ReloadSound"
ReloadSoundPlayer.Volume = KillSoundVolume
ReloadSoundPlayer.Looped = false
ReloadSoundPlayer.Parent = SoundService

-- ✅ Sistema de mute de disparos originales
local MutedFireSounds = {}   -- [Sound] = volumenOriginal

local FIRE_SOUND_KEYWORDS = { "fire","shoot","shot","gun","burst","shotgun","gunshot","muzzle","rifle","pistol","shooting","firing" }
local function isFireSound(s)
    if not s:IsA("Sound") then return false end
    local n = string.lower(s.Name)
    for _, kw in ipairs(FIRE_SOUND_KEYWORDS) do
        if string.find(n, kw, 1, true) then return true end
    end
    return false
end

local function muteFireSound(s)
    if not s or not s:IsA("Sound") then return end
    if not isFireSound(s) then return end
    if MutedFireSounds[s] == nil then
        MutedFireSounds[s] = s.Volume
    end
    pcall(function() s.Volume = 0 end)
end

local function unmuteAllFireSounds()
    for s, v in pairs(MutedFireSounds) do
        if s and s.Parent then
            pcall(function() s.Volume = v end)
        end
    end
    MutedFireSounds = {}
end

local function scanAndMuteFireSounds()
    local function scan(root)
        if not root then return end
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("Sound") then muteFireSound(d) end
        end
    end
    scan(LP.Character)
    scan(LP:FindFirstChildOfClass("Backpack"))
end

local function ApplyMuteState()
    if RecargaDisparoEnabled and MuteOriginalShoot then
        scanAndMuteFireSounds()
    else
        unmuteAllFireSounds()
    end
end

local function GetKillSoundIdByName(soundName)
    for _, s in ipairs(KillSounds) do
        if s.Name == soundName then return s.Id end
    end
    return KillSounds[1].Id
end

local function PlayKillSound()
    if not KillSoundEnabled then return end
    KillSoundPlayer:Stop()
    KillSoundPlayer.SoundId = "rbxassetid://" .. GetKillSoundIdByName(SelectedKillSound)
    KillSoundPlayer.Volume = KillSoundVolume
    KillSoundPlayer:Play()
end

local lastKillSoundTime, KILL_SOUND_COOLDOWN = 0, 0.08
local function TryPlayKillSound()
    if not KillSoundEnabled then return end
    local now = tick()
    if now - lastKillSoundTime < KILL_SOUND_COOLDOWN then return end
    lastKillSoundTime = now
    PlayKillSound()
end

local KILL_STAT_NAMES = { kos=true, kills=true, kill=true, ko=true, killed=true, eliminations=true, kills_count=true }
local function HookStatValue(stat)
    if not stat then return end
    if not (stat:IsA("IntValue") or stat:IsA("NumberValue")) then return end
    if not KILL_STAT_NAMES[string.lower(stat.Name)] then return end
    if stat:GetAttribute("SZ_KOHooked") then return end
    stat:SetAttribute("SZ_KOHooked", true)
    local lastVal = stat.Value
    stat:GetPropertyChangedSignal("Value"):Connect(function()
        if stat.Value > lastVal then TryPlayKillSound() end
        lastVal = stat.Value
    end)
end

local function HookLeaderstatsContainer(container)
    if not container then return end
    for _, stat in ipairs(container:GetChildren()) do HookStatValue(stat) end
    container.ChildAdded:Connect(HookStatValue)
end

local KILL_ATTR_NAMES = {"KOs","Kills","kos","kills","KO","killed","Eliminations"}
for _, attrName in ipairs(KILL_ATTR_NAMES) do
    local lastVal = tonumber(LP:GetAttribute(attrName))
    LP:GetAttributeChangedSignal(attrName):Connect(function()
        local newVal = tonumber(LP:GetAttribute(attrName))
        if newVal ~= nil and lastVal ~= nil and newVal > lastVal then TryPlayKillSound() end
        lastVal = newVal
    end)
end

if LP:FindFirstChild("leaderstats") then HookLeaderstatsContainer(LP:FindFirstChild("leaderstats")) end
for _, containerName in ipairs({"Stats","stats","PlayerStats"}) do
    local cont = LP:FindFirstChild(containerName)
    if cont then HookLeaderstatsContainer(cont) end
end
LP.ChildAdded:Connect(function(child)
    if child.Name == "leaderstats" then HookLeaderstatsContainer(child) end
    for _, containerName in ipairs({"Stats","stats","PlayerStats"}) do
        if child.Name == containerName then HookLeaderstatsContainer(child) end
    end
end)

local function HookKillOnCharacter(targetPlayer, character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    humanoid.Died:Connect(function()
        if not KillSoundEnabled then return end
        if IsSameTeam(targetPlayer) then return end
        local tag = humanoid:FindFirstChild("creator")
        if tag and tag.Value == LP then TryPlayKillSound() end
    end)
end

local function HookKillPlayer(targetPlayer)
    if targetPlayer == LP then return end
    if targetPlayer.Character then task.spawn(HookKillOnCharacter, targetPlayer, targetPlayer.Character) end
    targetPlayer.CharacterAdded:Connect(function(c) HookKillOnCharacter(targetPlayer, c) end)
end

for _, p in ipairs(Players:GetPlayers()) do HookKillPlayer(p) end
Players.PlayerAdded:Connect(HookKillPlayer)

local SHOOT_SOUND_MAX_DURATION = 1.5
local shootSoundToken, lastShootSoundTime = 0, 0
local SHOOT_SOUND_MIN_INTERVAL = 0.05

local function PlayShootSound()
    if not RecargaDisparoEnabled then return end
    local cfg = ShootReloadOptions[SelectedShootReload]
    if not cfg or not cfg.Shoot then return end
    local now = tick()
    if now - lastShootSoundTime < SHOOT_SOUND_MIN_INTERVAL then return end
    lastShootSoundTime = now
    shootSoundToken = shootSoundToken + 1
    local myToken = shootSoundToken
    ShootSoundPlayer:Stop()
    ShootSoundPlayer.SoundId = "rbxassetid://" .. cfg.Shoot
    ShootSoundPlayer.Volume = KillSoundVolume
    ShootSoundPlayer:Play()
    task.delay(SHOOT_SOUND_MAX_DURATION, function()
        if shootSoundToken == myToken and ShootSoundPlayer.Playing then ShootSoundPlayer:Stop() end
    end)
end

local function PlayReloadSound()
    if not RecargaDisparoEnabled then return end
    local cfg = ShootReloadOptions[SelectedShootReload]
    if not cfg or not cfg.Reload then return end
    ReloadSoundPlayer:Stop()
    ReloadSoundPlayer.SoundId = "rbxassetid://" .. cfg.Reload
    ReloadSoundPlayer.Volume = KillSoundVolume
    ReloadSoundPlayer:Play()
end

local function HookFireSound(s)
    if not s:IsA("Sound") then return end
    if not isFireSound(s) then return end
    -- Mute inmediato si la feature está activa
    if RecargaDisparoEnabled and MuteOriginalShoot then
        muteFireSound(s)
    end
    if s:GetAttribute("SZ_FireHooked") then return end
    s:SetAttribute("SZ_FireHooked", true)

    s.Played:Connect(function()
        if not RecargaDisparoEnabled then return end
        local char = LP.Character
        if not char then return end
        local bp = LP:FindFirstChildOfClass("Backpack")
        if s:IsDescendantOf(char) or (bp and s:IsDescendantOf(bp)) then
            -- Silenciar el sonido original
            if MuteOriginalShoot then
                if MutedFireSounds[s] == nil then
                    MutedFireSounds[s] = (s.Volume > 0) and s.Volume or 1
                end
                s.Volume = 0
            end
            PlayShootSound()
        end
    end)
end

local function HookShootOnTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    for _, d in ipairs(tool:GetDescendants()) do HookFireSound(d) end
    if not tool:GetAttribute("SZ_ToolHooked") then
        tool:SetAttribute("SZ_ToolHooked", true)
        tool.DescendantAdded:Connect(function(d)
            if d:IsA("Sound") then HookFireSound(d) end
        end)
    end
end

local function HookShootOnRoot(root)
    if not root then return end
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("Tool") then HookShootOnTool(child) end
    end
    root.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then HookShootOnTool(child) end
    end)
end

if LP:FindFirstChildOfClass("Backpack") then HookShootOnRoot(LP:FindFirstChildOfClass("Backpack")) end
LP.ChildAdded:Connect(function(c)
    if c:IsA("Backpack") then HookShootOnRoot(c) end
end)
if LP.Character then HookShootOnRoot(LP.Character) end
LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    HookShootOnRoot(c)
    if RecargaDisparoEnabled and MuteOriginalShoot then
        task.wait(0.3)
        scanAndMuteFireSounds()
    end
end)

-- Loop de seguridad: mantiene los sonidos de disparo mutados
task.spawn(function()
    while task.wait(0.4) do
        if RecargaDisparoEnabled and MuteOriginalShoot then
            scanAndMuteFireSounds()
        end
    end
end)

local function estaRecargando(tool)
    if not tool then return false end
    for _, attr in ipairs({"Reloading","IsReloading","reloading","isReloading"}) do
        if tool:GetAttribute(attr) == true then return true end
    end
    for _, name in ipairs({"Reloading","IsReloading","Reload"}) do
        local v = tool:FindFirstChild(name)
        if v then
            if v:IsA("BoolValue") and v.Value then return true end
            if v:IsA("IntValue") and v.Value > 0 then return true end
        end
    end
    return false
end

task.spawn(function()
    local lastReloadState = false
    while task.wait(0.05) do
        if not RecargaDisparoEnabled then lastReloadState = false; continue end
        local char = LP.Character
        if not char then lastReloadState = false; continue end
        local arma = char:FindFirstChildOfClass("Tool")
        if not arma or IsMelee(arma) then lastReloadState = false; continue end
        local recargando = estaRecargando(arma)
        if recargando and not lastReloadState then PlayReloadSound() end
        lastReloadState = recargando
    end
end)


local FovGui = Instance.new("ScreenGui")
FovGui.Name = "SZK_fov"
FovGui.ResetOnSpawn = false
FovGui.IgnoreGuiInset = true
FovGui.DisplayOrder = 5
pcall(function() FovGui.Parent = gethui and gethui() or game:GetService("CoreGui") end)

local FovFrame = Instance.new("Frame", FovGui)
FovFrame.AnchorPoint = Vector2.new(0.5,0.5)
FovFrame.BackgroundTransparency = 1
FovFrame.BorderSizePixel = 0
FovFrame.Visible = false
Instance.new("UICorner", FovFrame).CornerRadius = UDim.new(1,0)
local FovStroke = Instance.new("UIStroke", FovFrame)
FovStroke.Color = STATE_COLORS.Lobby
FovStroke.Thickness = 2

RunService.RenderStepped:Connect(function()
    if not InGame() then currentStateColor = STATE_COLORS.Lobby
    elseif HasVisibleEnemy() then currentStateColor = STATE_COLORS.Enemy
    else currentStateColor = STATE_COLORS.Clear end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local radius = SZK.GlobalFov
    local anyActive = SZK.SilentAim._toggled or SZK.AutoShoot._toggled or SZK.TriggerBot._toggled or SZK.Aimbot.Enabled
    FovFrame.Position = UDim2.fromOffset(center.X, center.Y)
    FovFrame.Size = UDim2.fromOffset(radius*2, radius*2)
    FovStroke.Color = currentStateColor
    FovFrame.Visible = SZK.Settings.ShowFovCircle and anyActive
end)


local EspGui = Instance.new("ScreenGui")
EspGui.Name = "SZK_esp"
EspGui.ResetOnSpawn = false
EspGui.IgnoreGuiInset = true
EspGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() EspGui.Parent = gethui and gethui() or game:GetService("CoreGui") end)

local ESP_Data = {}
local vpSize = cam.ViewportSize
cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() vpSize = cam.ViewportSize end)

local function setLine(f, from, to, thick)
    local dx, dy = to.X - from.X, to.Y - from.Y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist < 0.5 then f.Visible = false; return end
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Size = UDim2.new(0, dist, 0, thick or 2)
    f.Position = UDim2.new(0, (from.X+to.X)/2, 0, (from.Y+to.Y)/2)
    f.Rotation = math.deg(math.atan2(dy, dx))
    f.Visible = true
end

local function destroyESP(plr)
    local d = ESP_Data[plr]; if not d then return end
    if d.hl then pcall(function() d.hl:Destroy() end) end
    if d.bb then pcall(function() d.bb:Destroy() end) end
    if d.box then pcall(function() d.box:Destroy() end) end
    if d.tracer then pcall(function() d.tracer:Destroy() end) end
    if d.headDot then pcall(function() d.headDot:Destroy() end) end
    if d.skel then for _, l in ipairs(d.skel) do pcall(function() l:Destroy() end) end end
    ESP_Data[plr] = nil
end

local SKELETON_R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local SKELETON_R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

local function createESP(plr)
    if plr == LP then return end
    local char = plr.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then return end
    destroyESP(plr)
    local d = {skel={}}
    ESP_Data[plr] = d

    d.hl = Instance.new("Highlight", EspGui)
    d.hl.FillColor = ENEMY_COLOR
    d.hl.OutlineColor = Color3.fromRGB(255,255,255)
    d.hl.FillTransparency = 0.8
    d.hl.OutlineTransparency = 0.4
    d.hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    d.hl.Adornee = char

    local bb = Instance.new("BillboardGui", EspGui)
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = head
    bb.ResetOnSpawn = false
    bb.LightInfluence = 0
    bb.MaxDistance = 500
    bb.Enabled = true
    d.bb = bb

    d.name = Instance.new("TextLabel", bb)
    d.name.Size = UDim2.new(1, 0, 0, 18)
    d.name.BackgroundTransparency = 1
    d.name.Text = plr.Name
    d.name.TextColor3 = Color3.fromRGB(255,255,255)
    d.name.Font = Enum.Font.GothamBold
    d.name.TextSize = 13
    d.name.TextStrokeTransparency = 0

    d.dist = Instance.new("TextLabel", bb)
    d.dist.Size = UDim2.new(1, 0, 0, 12)
    d.dist.Position = UDim2.new(0, 0, 0, 18)
    d.dist.BackgroundTransparency = 1
    d.dist.Text = "0m"
    d.dist.TextColor3 = ENEMY_COLOR
    d.dist.Font = Enum.Font.GothamMedium
    d.dist.TextSize = 10
    d.dist.TextStrokeTransparency = 0

    local hpBg = Instance.new("Frame", bb)
    hpBg.Name = "HpBg"
    hpBg.Size = UDim2.new(0, 70, 0, 5)
    hpBg.Position = UDim2.new(0.5, -35, 0, 34)
    hpBg.BackgroundColor3 = Color3.fromRGB(20,20,20)
    hpBg.BorderSizePixel = 0
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 3)
    d.hp = Instance.new("Frame", hpBg)
    d.hp.Size = UDim2.new(1, 0, 1, 0)
    d.hp.BackgroundColor3 = Color3.fromRGB(0,230,150)
    d.hp.BorderSizePixel = 0
    Instance.new("UICorner", d.hp).CornerRadius = UDim.new(0, 3)

    d.box = Instance.new("Frame", EspGui)
    d.box.BackgroundTransparency = 1
    d.box.BorderSizePixel = 0
    d.box.Visible = false
    d.box.ZIndex = 2
    Instance.new("UICorner", d.box).CornerRadius = UDim.new(0, 4)
    d.boxStroke = Instance.new("UIStroke", d.box)
    d.boxStroke.Color = ENEMY_COLOR
    d.boxStroke.Thickness = 2
    d.boxFill = Instance.new("Frame", d.box)
    d.boxFill.Size = UDim2.new(1, 0, 1, 0)
    d.boxFill.BackgroundColor3 = ENEMY_COLOR
    d.boxFill.BackgroundTransparency = 0.8
    d.boxFill.BorderSizePixel = 0
    d.boxFill.Visible = false
    d.boxFill.ZIndex = 1
    Instance.new("UICorner", d.boxFill).CornerRadius = UDim.new(0, 4)

    d.headDot = Instance.new("Frame", EspGui)
    d.headDot.Size = UDim2.new(0, 8, 0, 8)
    d.headDot.BackgroundColor3 = ENEMY_COLOR
    d.headDot.BorderSizePixel = 0
    d.headDot.Visible = false
    d.headDot.ZIndex = 4
    Instance.new("UICorner", d.headDot).CornerRadius = UDim.new(1, 0)
    local hdSt = Instance.new("UIStroke", d.headDot)
    hdSt.Color = Color3.fromRGB(255,255,255)
    hdSt.Thickness = 1

    d.tracer = Instance.new("Frame", EspGui)
    d.tracer.BackgroundColor3 = ENEMY_COLOR
    d.tracer.BorderSizePixel = 0
    d.tracer.Visible = false
    d.tracer.ZIndex = 1

    local bones = char:FindFirstChild("UpperTorso") and SKELETON_R15 or SKELETON_R6
    d.bones = bones
    for i = 1, #bones do
        local ln = Instance.new("Frame", EspGui)
        ln.BackgroundColor3 = ENEMY_COLOR
        ln.BorderSizePixel = 0
        ln.Visible = false
        ln.ZIndex = 3
        Instance.new("UICorner", ln).CornerRadius = UDim.new(1, 0)
        d.skel[i] = ln
    end
end

local function getScreenBounds(char)
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hrp or not hum then return nil end
    local topPos = head.Position + Vector3.new(0, 0.6, 0)
    local hipH = hum.HipHeight or 2
    local bottomPos = hrp.Position - Vector3.new(0, hipH - 0.2, 0)
    local spT, onT = cam:WorldToViewportPoint(topPos)
    local spB, onB = cam:WorldToViewportPoint(bottomPos)
    local spH, onH = cam:WorldToViewportPoint(hrp.Position)
    if spT.Z <= 0 or spB.Z <= 0 or spH.Z <= 0 then return nil end
    if not onT and not onB and not onH then return nil end
    local height = math.abs(spB.Y - spT.Y)
    if height < 5 then return nil end
    local width = height * 0.55
    return spH.X - width/2, spT.Y, spH.X + width/2, spT.Y + height
end

local function hideESP(d)
    if d.hl then d.hl.Enabled = false end
    if d.bb then d.bb.Enabled = false end
    if d.box then d.box.Visible = false end
    if d.tracer then d.tracer.Visible = false end
    if d.headDot then d.headDot.Visible = false end
    if d.skel then for _, l in ipairs(d.skel) do l.Visible = false end end
end

local function updateESP()
    local myHRP = GetHRP(LP); if not myHRP then return end
    local myPos = myHRP.Position
    for plr, d in pairs(ESP_Data) do
        local teammate = IsSameTeam(plr)
        local active = SZK.ESP.Enabled
        if teammate and not SZK.ESP.ShowTeammates then active = false end
        local targetColor = teammate and TEAM_COLOR or ENEMY_COLOR
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local distance = (hrp and myHRP) and (hrp.Position - myPos).Magnitude or 0
        local tooFar = distance > SZK.ESP.MaxDistance
        if not char or not hum or hum.Health <= 0 then destroyESP(plr)
        elseif not active or not hrp or not head or tooFar then hideESP(d)
        else
            if d.hl then d.hl.Enabled = SZK.ESP.Highlight; d.hl.FillColor = targetColor end
            if d.bb then
                d.bb.Enabled = (SZK.ESP.Name or SZK.ESP.Distance or SZK.ESP.Health)
                if d.name then d.name.Visible = SZK.ESP.Name; d.name.TextColor3 = targetColor end
                if d.dist then
                    d.dist.Visible = SZK.ESP.Distance
                    if SZK.ESP.Distance then
                        d.dist.Text = string.format("%dm", math.floor(distance))
                        d.dist.TextColor3 = targetColor
                    end
                end
                local hpBg = d.bb:FindFirstChild("HpBg")
                if hpBg then
                    hpBg.Visible = SZK.ESP.Health
                    if SZK.ESP.Health and d.hp then
                        local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        d.hp.Size = UDim2.new(pct, 0, 1, 0)
                        d.hp.BackgroundColor3 = Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 60)
                    end
                end
            end
            if d.box then
                if SZK.ESP.Box then
                    local x1,y1,x2,y2 = getScreenBounds(char)
                    if x1 then
                        d.box.Position = UDim2.new(0, x1, 0, y1)
                        d.box.Size = UDim2.new(0, math.max(x2-x1,1), 0, math.max(y2-y1,1))
                        d.box.Visible = true
                        if d.boxStroke then d.boxStroke.Color = targetColor end
                        if d.boxFill then d.boxFill.Visible = SZK.ESP.FillBox; d.boxFill.BackgroundColor3 = targetColor end
                    else d.box.Visible = false end
                else d.box.Visible = false end
            end
            if d.headDot then
                if SZK.ESP.HeadDot then
                    local sp, on = cam:WorldToViewportPoint(head.Position)
                    if on and sp.Z > 0 then
                        d.headDot.Position = UDim2.new(0, sp.X-4, 0, sp.Y-4)
                        d.headDot.BackgroundColor3 = targetColor
                        d.headDot.Visible = true
                    else d.headDot.Visible = false end
                else d.headDot.Visible = false end
            end
            if d.bones then
                for i, pair in ipairs(d.bones) do
                    local ln = d.skel[i]
                    if ln then
                        if SZK.ESP.Skeleton then
                            local a = char:FindFirstChild(pair[1])
                            local b = char:FindFirstChild(pair[2])
                            if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
                                local sa, onA = cam:WorldToViewportPoint(a.Position)
                                local sb, onB = cam:WorldToViewportPoint(b.Position)
                                if sa.Z > 0 and sb.Z > 0 and onA and onB then
                                    setLine(ln, Vector2.new(sa.X, sa.Y), Vector2.new(sb.X, sb.Y), 1.5)
                                    ln.BackgroundColor3 = targetColor
                                else ln.Visible = false end
                            else ln.Visible = false end
                        else ln.Visible = false end
                    end
                end
            end
            if d.tracer then
                if SZK.ESP.Tracer then
                    local sp, on = cam:WorldToViewportPoint(hrp.Position)
                    if on and sp.Z > 0 then
                        local origin = Vector2.new(vpSize.X/2, vpSize.Y)
                        if SZK.ESP.TracerOrigin == "Top" then origin = Vector2.new(vpSize.X/2, 0)
                        elseif SZK.ESP.TracerOrigin == "Center" then origin = Vector2.new(vpSize.X/2, vpSize.Y/2) end
                        setLine(d.tracer, origin, Vector2.new(sp.X, sp.Y), 1.5)
                        d.tracer.BackgroundColor3 = targetColor
                    else d.tracer.Visible = false end
                else d.tracer.Visible = false end
            end
        end
    end
end

local function setupPlayerESP(plr)
    if plr == LP then return end
    plr.CharacterAdded:Connect(function(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local head = char:WaitForChild("Head", 5)
        if hrp and head then createESP(plr) end
    end)
    plr.CharacterRemoving:Connect(function() destroyESP(plr) end)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
        createESP(plr)
    end
end
for _, p in ipairs(Players:GetPlayers()) do setupPlayerESP(p) end
Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(destroyESP)

local function rebuildAllESP()
    for plr in pairs(ESP_Data) do destroyESP(plr) end
    if SZK.ESP.Enabled then
        for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then createESP(plr) end end
    end
end
RunService.RenderStepped:Connect(updateESP)
task.spawn(function()
    while task.wait(1) do
        for plr, _ in pairs(ESP_Data) do
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum or hum.Health <= 0 then destroyESP(plr) end
        end
    end
end)



local AvatarBackup = {Headless=nil, Korblox=nil}
local LoadAccessoryToPlayer, RemoveAccessoryByID

local function ApplyHeadless()
    local char = LP.Character; if not char then return false end
    local head = char:FindFirstChild("Head"); if not head then return false end
    if not AvatarBackup.Headless then
        AvatarBackup.Headless = {trans=head.Transparency, kids={}}
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SpecialMesh") then
                AvatarBackup.Headless.kids[v] = v.Transparency
            end
        end
    end
    pcall(function()
        head.Transparency = 1
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SpecialMesh") then v.Transparency = 1 end
        end
    end)
    return true
end

local function RemoveHeadless()
    local char = LP.Character; if not char then return false end
    local head = char:FindFirstChild("Head"); if not head then return false end
    pcall(function()
        if AvatarBackup.Headless then
            head.Transparency = AvatarBackup.Headless.trans or 0
            for c, t in pairs(AvatarBackup.Headless.kids) do if c and c.Parent then c.Transparency = t end end
        else
            head.Transparency = 0
            for _, v in ipairs(head:GetChildren()) do
                if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SpecialMesh") then v.Transparency = 0 end
            end
        end
    end)
    return true
end

local function ApplyKorblox()
    local char = LP.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    if not AvatarBackup.Korblox then
        AvatarBackup.Korblox = {parts={}, meshes={}}
        if hum.RigType == Enum.HumanoidRigType.R15 then
            for _, n in ipairs({"RightFoot","RightLowerLeg","RightUpperLeg"}) do
                local p = char:FindFirstChild(n)
                if p then AvatarBackup.Korblox.parts[p] = {t=p.Transparency, c=p.Color} end
            end
            local rul = char:FindFirstChild("RightUpperLeg")
            if rul then AvatarBackup.Korblox.meshes[rul] = {MeshId=rul.MeshId or "", TextureID=rul.TextureID or "", Color=rul.Color} end
        else
            local rl = char:FindFirstChild("Right Leg")
            if rl then
                AvatarBackup.Korblox.parts[rl] = {t=rl.Transparency, c=rl.Color}
                local mesh = rl:FindFirstChildOfClass("SpecialMesh")
                if mesh then AvatarBackup.Korblox.meshes[rl] = {MeshType=mesh.MeshType, MeshId=mesh.MeshId, TextureId=mesh.TextureId, Scale=mesh.Scale} end
            end
        end
    end
    pcall(function()
        if hum.RigType == Enum.HumanoidRigType.R15 then
            local rf = char:FindFirstChild("RightFoot"); local rll = char:FindFirstChild("RightLowerLeg"); local rul = char:FindFirstChild("RightUpperLeg")
            if rf then rf.Transparency = 1 end
            if rll then rll.Transparency = 1 end
            if rul then rul.MeshId = "rbxassetid://902942096"; rul.TextureID = "rbxassetid://902843398"; rul.Color = Color3.new(1,1,1); rul.Transparency = 0 end
        else
            local rl = char:FindFirstChild("Right Leg")
            if rl then
                for _, v in ipairs(char:GetChildren()) do
                    if v:IsA("CharacterMesh") and v.BodyPart == Enum.BodyPart.RightLeg then v:Destroy() end
                end
                local mesh = rl:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", rl)
                rl.Color = Color3.fromRGB(64,64,64)
                mesh.MeshType = Enum.MeshType.FileMesh
                mesh.MeshId = "rbxassetid://101851696"
                mesh.TextureId = "rbxassetid://101851254"
                mesh.Scale = Vector3.new(1,1,1)
            end
        end
    end)
    return true
end

local function RemoveKorblox()
    local char = LP.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    pcall(function()
        if AvatarBackup.Korblox then
            for p, d in pairs(AvatarBackup.Korblox.parts) do if p and p.Parent then p.Transparency = d.t; p.Color = d.c end end
            for p, d in pairs(AvatarBackup.Korblox.meshes) do
                if p and p.Parent then
                    local mesh = p:FindFirstChildOfClass("SpecialMesh")
                    if mesh then
                        if d.MeshType then mesh.MeshType = d.MeshType end
                        if d.MeshId then mesh.MeshId = d.MeshId end
                        if d.TextureId then mesh.TextureId = d.TextureId end
                        if d.Scale then mesh.Scale = d.Scale end
                    end
                end
            end
        end
    end)
    return true
end

LoadAccessoryToPlayer = function(accId)
    local char = LP.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local ok = pcall(function()
        local s, content = pcall(function() return game:GetObjects("rbxassetid://"..accId) end)
        if not s or not content or not content[1] then return end
        local acc = content[1]
        if not acc:IsA("Accessory") then return end
        for _, o in ipairs(char:GetChildren()) do if o:IsA("Accessory") and o.Name == acc.Name then return end end
        local handle = acc:FindFirstChild("Handle")
        if not handle then acc.Parent = char; return end
        handle.Anchored = false; handle.CanCollide = false
        local att = handle:FindFirstChildOfClass("Attachment")
        local tAtt = nil
        if att then
            for _, bp in ipairs(char:GetChildren()) do
                if bp:IsA("BasePart") then
                    local f = bp:FindFirstChild(att.Name)
                    if f and f:IsA("Attachment") then tAtt = f; break end
                end
            end
        end
        if tAtt then
            handle.CFrame = tAtt.WorldCFrame * att.CFrame:Inverse()
            local w = Instance.new("Weld")
            w.Part0 = tAtt.Parent; w.Part1 = handle
            w.C0 = tAtt.CFrame; w.C1 = att.CFrame
            w.Parent = handle
        else
            local head = char:FindFirstChild("Head")
            if head then
                handle.CFrame = head.CFrame
                local w = Instance.new("Weld")
                w.Part0 = head; w.Part1 = handle
                w.C0 = CFrame.new(); w.C1 = att and att.CFrame or CFrame.new()
                w.Parent = handle
            end
        end
        acc.Parent = char
    end)
    if ok then genv.SZK_EquippedAccessories[accId] = true end
    return ok
end

RemoveAccessoryByID = function(accId)
    local char = LP.Character; if not char then return false end
    local s, content = pcall(function() return game:GetObjects("rbxassetid://"..accId) end)
    if s and content and content[1] then
        local tName = content[1].Name
        for _, o in ipairs(char:GetChildren()) do
            if o:IsA("Accessory") and o.Name == tName then o:Destroy() end
        end
    end
    genv.SZK_EquippedAccessories[accId] = nil
    return true
end

LP.CharacterAdded:Connect(function(char)
    AvatarBackup.Headless = nil
    AvatarBackup.Korblox = nil
    char:WaitForChild("Humanoid", 5)
    char:WaitForChild("HumanoidRootPart", 5)
    char:WaitForChild("Head", 5)
    task.wait(0.9)
    for accId, _ in pairs(genv.SZK_EquippedAccessories) do
        pcall(function() LoadAccessoryToPlayer(accId) end); task.wait(0.1)
    end
    if genv.SZK_HeadlessOn then pcall(ApplyHeadless) end
    if genv.SZK_KorbloxOn then pcall(ApplyKorblox) end
end)


local BOOMBOX_SONGS = {
    {name="Song 1",id="rbxassetid://131465489873214"},{name="Song 2",id="rbxassetid://135321902579514"},
    {name="Song 3",id="rbxassetid://128048502331483"},{name="Song 4",id="rbxassetid://115440201770223"},
    {name="Song 5",id="rbxassetid://138863509657081"},{name="Song 6",id="rbxassetid://110398343528156"},
    {name="Song 7",id="rbxassetid://93699644879957"},{name="Song 8",id="rbxassetid://135609653444873"},
    {name="Song 9",id="rbxassetid://75688616622595"},{name="Song 10",id="rbxassetid://71393805905055"},
    {name="Song 11",id="rbxassetid://82746224492420"},{name="Song 12",id="rbxassetid://87570666848900"},
    {name="Song 13",id="rbxassetid://86503267790406"},{name="Song 14",id="rbxassetid://90851490275942"},
    {name="Song 15",id="rbxassetid://86317637164248"},{name="Song 16",id="rbxassetid://110685134112291"},
    {name="Song 17",id="rbxassetid://117810918009991"},{name="Song 18",id="rbxassetid://75793040119604"},
    {name="Song 19",id="rbxassetid://78775217854077"},{name="Song 20",id="rbxassetid://100840031560163"},
    {name="Song 21",id="rbxassetid://104242464450684"},{name="Song 22",id="rbxassetid://81151325045733"},
    {name="Song 23",id="rbxassetid://80735192805425"},{name="Song 24",id="rbxassetid://93930555396098"},
    {name="Song 25",id="rbxassetid://118773510013062"},{name="Song 26",id="rbxassetid://113269872401718"},
    {name="Song 27",id="rbxassetid://117334682026487"},{name="Song 28",id="rbxassetid://99625326669788"},
    {name="Song 29",id="rbxassetid://90859442818485"},
}
local Boombox = Instance.new("Sound", SoundService)
Boombox.Name = "SZK_boombox"
Boombox.Volume = 0.5
Boombox.Looped = true
Boombox.SoundId = BOOMBOX_SONGS[1].id
local BoomboxState = {CurrentSong=BOOMBOX_SONGS[1].id, CurrentName=BOOMBOX_SONGS[1].name, Volume=0.5, Loop=true, Playing=false}



local TabHome   = Window:Tab({ Title = "HOME", Icon = "home" })
local TabAim    = Window:Tab({ Title = "AIM", Icon = "crosshair" })
local TabEsp    = Window:Tab({ Title = "ESP", Icon = "eye" })
local TabExtra  = Window:Tab({ Title = "EXTRA", Icon = "zap" })
local TabSound  = Window:Tab({ Title = "SONIDOS", Icon = "volume-2" })
local TabMusic  = Window:Tab({ Title = "MUSIC", Icon = "music" })
local TabBg     = Window:Tab({ Title = "BG", Icon = "image" })
local TabPc     = Window:Tab({ Title = "PC-MODE", Icon = "keyboard" })
local TabInf    = Window:Tab({ Title = "INFO", Icon = "info" })

-- HOME
TabHome:Section({ Title = "WELCOME" })
TabHome:Paragraph({ Title = "SZKHUB "..SCRIPT_VERSION, Desc = "Welcome, "..LP.DisplayName.."!\nGame: Murderers vs Sheriffs Duels" })
TabHome:Button({ Title = "📋 COPIAR DISCORD", Callback = function()
    pcall(function() if setclipboard then setclipboard("https://discord.gg/gRzA4bsTxv") end end)
    Notify("SZKHUB", "Discord link copiado", 2)
end })

-- AIM
TabAim:Section({ Title = "FOV GLOBAL" })
TabAim:Slider({ Title = "FOV Radius", Step = 1, Value = { Min = 50, Max = 800, Default = 300 }, Callback = function(v)
    SZK.GlobalFov = v
    SZK.SilentAim.FovSize = v; SZK.AutoShoot.FovSize = v; SZK.TriggerBot.FovSize = v
end })
TabAim:Toggle({ Title = "Show FOV Circle", Value = true, Callback = function(v) SZK.Settings.ShowFovCircle = v end })

TabAim:Section({ Title = "SILENT AIM" })
TabAim:Toggle({ Title = "Enable Silent Aim", Value = false, Callback = function(v) SZK.SilentAim.Enabled = v; SZK.SilentAim._toggled = v end })
TabAim:Toggle({ Title = "Usar FOV Global", Value = true, Callback = function(v) SZK.SilentAim.UseFovLimit = v end })
TabAim:Toggle({ Title = "Wall Check", Value = true, Callback = function(v) SZK.SilentAim.WallCheck = v end })

TabAim:Section({ Title = "AUTO SHOOT" })
TabAim:Toggle({ Title = "Enable Auto Shoot", Value = false, Callback = function(v) SZK.AutoShoot.Enabled = v; SZK.AutoShoot._toggled = v end })
TabAim:Toggle({ Title = "Usar FOV Global", Value = true, Callback = function(v) SZK.AutoShoot.UseFovLimit = v end })
TabAim:Slider({ Title = "Shoot Delay (ms)", Step = 1, Value = { Min = 50, Max = 1000, Default = 150 }, Callback = function(v) SZK.AutoShoot.ShootDelay = v/1000 end })
TabAim:Toggle({ Title = "Wall Check", Value = true, Callback = function(v) SZK.AutoShoot.WallCheck = v end })

TabAim:Section({ Title = "AIMBOT" })
TabAim:Toggle({ Title = "Enable Aimbot", Value = false, Callback = function(v) SZK.Aimbot.Enabled = v end })
TabAim:Toggle({ Title = "Only Gun", Value = true, Callback = function(v) SZK.Aimbot.OnlyGun = v end })
TabAim:Toggle({ Title = "Prediction", Value = true, Callback = function(v) SZK.Aimbot.Prediction = v end })
TabAim:Dropdown({ Title = "Target Part", Values = {"Cabeza","Torso","Completo"}, Value = "Cabeza", Callback = function(v) SZK.Aimbot.TargetPart = v end })
TabAim:Slider({ Title = "Smoothness", Step = 1, Value = { Min = 0, Max = 100, Default = 90 }, Callback = function(v) SZK.Aimbot.Smoothness = v/100 end })

TabAim:Section({ Title = "TRIGGER BOT v3" })
TabAim:Toggle({ Title = "Enable Trigger Bot", Value = false, Callback = function(v)
    SZK.TriggerBot.Enabled = v; SZK.TriggerBot._toggled = v
    Notify("TRIGGER BOT", v and "ON" or "OFF", 2)
end })
TabAim:Toggle({ Title = "Auto Equip", Value = true, Callback = function(v) SZK.TriggerBot.AutoEquip = v end })
TabAim:Toggle({ Title = "Auto Shoot", Value = true, Callback = function(v) SZK.TriggerBot.AutoShoot = v end })
TabAim:Toggle({ Title = "Preferir Arma (GUN)", Value = true, Callback = function(v) SZK.TriggerBot.PreferFirearm = v end })
TabAim:Toggle({ Title = "Tirar Melee", Value = true, Callback = function(v) SZK.TriggerBot.DropMelee = v end })
TabAim:Slider({ Title = "Shoot Delay (ms)", Step = 1, Value = { Min = 10, Max = 1000, Default = 40 }, Callback = function(v) SZK.TriggerBot.ShootDelay = v/1000 end })
TabAim:Toggle({ Title = "Wall Check", Value = true, Callback = function(v) SZK.TriggerBot.WallCheck = v end })
TabAim:Slider({ Title = "FOV Radius", Step = 1, Value = { Min = 50, Max = 800, Default = 300 }, Callback = function(v) SZK.TriggerBot.FovSize = v end })
TabAim:Button({ Title = "🎯 ABRIR SCANNER (Hotkey: B)", Callback = function()
    if ScannerPanel then
        ScannerPanel.Visible = true
        if scanRefresh_Click then scanRefresh_Click() end
    end
end })

TabAim:Section({ Title = "KNIFE BOT" })
TabAim:Toggle({ Title = "Enable Knife Bot", Value = false, Callback = function(v) SZK.KnifeBot.Enabled = v end })
TabAim:Dropdown({ Title = "Target Part", Values = {"Cabeza","Torso","Completo"}, Value = "Cabeza", Callback = function(v) SZK.KnifeBot.TargetPart = v end })

-- ESP
TabEsp:Section({ Title = "ESP MASTER" })
TabEsp:Toggle({ Title = "Enable ESP", Value = false, Callback = function(v) SZK.ESP.Enabled = v; rebuildAllESP() end })
TabEsp:Toggle({ Title = "Show Teammates (Verde)", Value = false, Callback = function(v) SZK.ESP.ShowTeammates = v end })
TabEsp:Slider({ Title = "Max Distance", Step = 50, Value = { Min = 50, Max = 3000, Default = 1500 }, Callback = function(v) SZK.ESP.MaxDistance = v end })

TabEsp:Section({ Title = "ELEMENTOS V2" })
TabEsp:Toggle({ Title = "Highlight", Value = false, Callback = function(v) SZK.ESP.Highlight = v end })
TabEsp:Toggle({ Title = "Box", Value = false, Callback = function(v) SZK.ESP.Box = v end })
TabEsp:Toggle({ Title = "Fill Box", Value = false, Callback = function(v) SZK.ESP.FillBox = v end })
TabEsp:Toggle({ Title = "Skeleton", Value = false, Callback = function(v) SZK.ESP.Skeleton = v end })
TabEsp:Toggle({ Title = "Head Dot", Value = false, Callback = function(v) SZK.ESP.HeadDot = v end })
TabEsp:Toggle({ Title = "Name", Value = false, Callback = function(v) SZK.ESP.Name = v end })
TabEsp:Toggle({ Title = "Distance", Value = false, Callback = function(v) SZK.ESP.Distance = v end })
TabEsp:Toggle({ Title = "Health", Value = false, Callback = function(v) SZK.ESP.Health = v end })
TabEsp:Toggle({ Title = "Tracer", Value = false, Callback = function(v) SZK.ESP.Tracer = v end })
TabEsp:Dropdown({ Title = "Tracer Origin", Values = {"Top","Center","Bottom"}, Value = "Bottom", Callback = function(v) SZK.ESP.TracerOrigin = v end })

-- EXTRA
TabExtra:Section({ Title = "AUTOFARM" })
TabExtra:Toggle({ Title = "Enable AutoFarm", Value = false, Callback = function(v)
    SZK.AutoFarm.Enabled = v
    if v and not SZK.AutoFarm._loopRunning then
        SZK.AutoFarm._loopRunning = true
        task.spawn(function()
            local s, container = pcall(function() return workspace:WaitForChild("SpawnablesClient", 10) end)
            if not s or not container then
                Notify("AutoFarm", "No container", 4)
                SZK.AutoFarm._loopRunning = false; SZK.AutoFarm.Enabled = false
                return
            end
            Notify("AutoFarm", "Started", 3)
            while SZK.AutoFarm.Enabled do
                for _, obj in ipairs(container:GetChildren()) do
                    if not SZK.AutoFarm.Enabled then break end
                    local tp = obj:FindFirstChild("Touch")
                    if tp and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            if firetouchinterest then
                                firetouchinterest(LP.Character.HumanoidRootPart, tp, 0)
                                firetouchinterest(LP.Character.HumanoidRootPart, tp, 1)
                            end
                        end)
                    end
                end
                task.wait(0.45)
            end
            SZK.AutoFarm._loopRunning = false
        end)
    end
end })
TabExtra:Button({ Title = "ONCE FARM", Callback = function()
    task.spawn(function()
        local s, c = pcall(function() return workspace:WaitForChild("SpawnablesClient", 5) end)
        if not s or not c then Notify("Once Farm", "No container", 3); return end
        local count = 0
        for _, obj in ipairs(c:GetChildren()) do
            local tp = obj:FindFirstChild("Touch")
            if tp and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    if firetouchinterest then
                        firetouchinterest(LP.Character.HumanoidRootPart, tp, 0)
                        firetouchinterest(LP.Character.HumanoidRootPart, tp, 1)
                    end
                end)
                count = count + 1; task.wait(0.05)
            end
        end
        Notify("Once Farm", "Tocados "..count, 3)
    end)
end })

TabExtra:Section({ Title = "MACRO (TAP)" })
TabExtra:Toggle({ Title = "Enable Macro", Value = false, Callback = function(v) SZK.Macro.Enabled = v; Notify("MACRO", v and "ON" or "OFF", 2) end })
TabExtra:Toggle({ Title = "Auto Equip", Value = true, Callback = function(v) SZK.Macro.AutoEquip = v end })
TabExtra:Toggle({ Title = "Wall Check", Value = true, Callback = function(v) SZK.Macro.WallCheck = v end })
TabExtra:Dropdown({ Title = "Target", Values = {"Cabeza","Torso","Completo"}, Value = "Cabeza", Callback = function(v) SZK.Macro.Target = v end })
TabExtra:Slider({ Title = "Cooldown (ms)", Step = 10, Value = { Min = 50, Max = 1000, Default = 200 }, Callback = function(v) SZK.Macro.Cooldown = v/1000 end })

TabExtra:Section({ Title = "HITBOX (BIG)" })
TabExtra:Toggle({ Title = "Enable Hitbox", Value = false, Callback = function(v)
    SZK.Hitbox.Enabled = v
    if not v then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local g = p.Character:FindFirstChild("GhostHitbox")
                if g then g:Destroy() end
            end
        end
    end
    Notify("HITBOX", v and "ON" or "OFF", 2)
end })
TabExtra:Slider({ Title = "Hitbox Size", Step = 1, Value = { Min = 5, Max = 35, Default = 15 }, Callback = function(v) SZK.Hitbox.Size = v end })

TabExtra:Section({ Title = "SPEED" })
TabExtra:Toggle({ Title = "Enable Speed", Value = false, Callback = function(v)
    SZK.Speed.Enabled = v
    if not v then
        if SZK.Speed._loop then SZK.Speed._loop:Disconnect(); SZK.Speed._loop = nil end
        Notify("SPEED", "OFF", 2); return
    end
    if SZK.Speed._loop then SZK.Speed._loop:Disconnect() end
    SZK.Speed._loop = RunService.Heartbeat:Connect(function()
        if not SZK.Speed.Enabled then return end
        local c = LP.Character; if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        local rp = c:FindFirstChild("HumanoidRootPart")
        if not rp or not hum then return end
        local md = hum.MoveDirection
        if md.Magnitude > 0 then rp.CFrame = rp.CFrame + (md * SZK.Speed.Multiplier) end
    end)
    Notify("SPEED", "ON", 2)
end })
TabExtra:Slider({ Title = "Multiplier x100", Step = 10, Value = { Min = 10, Max = 200, Default = 50 }, Callback = function(v) SZK.Speed.Multiplier = v/100 end })

TabExtra:Section({ Title = "HEADLESS + KORBLOX" })
TabExtra:Toggle({ Title = "Headless", Value = false, Callback = function(v)
    genv.SZK_HeadlessOn = v
    if v then ApplyHeadless() else RemoveHeadless() end
end })
TabExtra:Toggle({ Title = "Korblox", Value = false, Callback = function(v)
    genv.SZK_KorbloxOn = v
    if v then ApplyKorblox() else RemoveKorblox() end
end })

-- SONIDOS
TabSound:Section({ Title = "🔪 KILL SOUND (Magia Anime)" })
TabSound:Toggle({ Title = "Enable Kill Sound", Value = false, Callback = function(v)
    KillSoundEnabled = v
    if not v then KillSoundPlayer:Stop() end
    Notify("SONIDOS", "Kill Sound "..(v and "ON" or "OFF"), 2)
end })

local KillSoundDropdownValues = {}
for _, s in ipairs(KillSounds) do table.insert(KillSoundDropdownValues, s.Name) end
TabSound:Dropdown({ Title = "Sonido de muerte", Values = KillSoundDropdownValues, Value = "Onichaaan", Callback = function(selected)
    SelectedKillSound = selected
end })
TabSound:Button({ Title = "▶️ PROBAR KILL SOUND", Callback = function()
    local was = KillSoundEnabled
    KillSoundEnabled = true
    PlayKillSound()
    task.delay(1.2, function() KillSoundEnabled = was end)
end })

TabSound:Section({ Title = "🔫 DISPARO Y RECARGA (chispas)" })
TabSound:Toggle({ Title = "Recarga + Disparo", Value = false, Callback = function(v)
    RecargaDisparoEnabled = v
    if not v then
        ShootSoundPlayer:Stop(); ReloadSoundPlayer:Stop()
    end
    ApplyMuteState()  -- ✅ Silencia/restaura según estado
    Notify("SONIDOS", "Disparo/Recarga "..(v and "ON" or "OFF"), 2)
end })

-- ✅ NUEVO TOGGLE
TabSound:Toggle({ Title = "🔇 Silenciar disparo original", Value = true, Callback = function(v)
    MuteOriginalShoot = v
    ApplyMuteState()
    Notify("SONIDOS", "Mute original "..(v and "ON" or "OFF"), 2)
end })

TabSound:Dropdown({ Title = "Sonido de disparo", Values = { "chispas" }, Value = "chispas", Callback = function(selected) SelectedShootReload = selected end })
TabSound:Button({ Title = "▶️ PROBAR DISPARO", Callback = function()
    local was = RecargaDisparoEnabled
    RecargaDisparoEnabled = true
    PlayShootSound()
    task.delay(1.2, function() RecargaDisparoEnabled = was end)
end })
TabSound:Button({ Title = "▶️ PROBAR RECARGA", Callback = function()
    local was = RecargaDisparoEnabled
    RecargaDisparoEnabled = true
    PlayReloadSound()
    task.delay(1.2, function() RecargaDisparoEnabled = was end)
end })

TabSound:Section({ Title = "🔊 VOLUMEN GLOBAL" })
TabSound:Slider({ Title = "Volumen (x1 = 10, x3 = 30)", Step = 1, Value = { Min = 10, Max = 30, Default = 10 }, Callback = function(v)
    local real = v / 10
    KillSoundVolume = real
    KillSoundPlayer.Volume = real
    ShootSoundPlayer.Volume = real
    ReloadSoundPlayer.Volume = real
end })

-- MUSIC
TabMusic:Section({ Title = "🎵 BOOMBOX PLAYER" })
local songNames = {}
for _, s in ipairs(BOOMBOX_SONGS) do songNames[#songNames+1] = s.name end
TabMusic:Dropdown({ Title = "🎶 Song", Values = songNames, Value = BOOMBOX_SONGS[1].name, Callback = function(v)
    for _, s in ipairs(BOOMBOX_SONGS) do
        if s.name == v then
            BoomboxState.CurrentSong = s.id; BoomboxState.CurrentName = s.name
            if BoomboxState.Playing then Boombox.SoundId = s.id; Boombox:Play() end
            Notify("BOOMBOX", "Song: "..s.name, 2)
            break
        end
    end
end })
TabMusic:Slider({ Title = "🔊 Volume", Step = 1, Value = { Min = 0, Max = 100, Default = 50 }, Callback = function(v)
    BoomboxState.Volume = v/100; Boombox.Volume = BoomboxState.Volume
end })
TabMusic:Toggle({ Title = "🔁 Loop", Value = true, Callback = function(v) BoomboxState.Loop = v; Boombox.Looped = v end })
TabMusic:Button({ Title = "▶️ PLAY", Callback = function()
    Boombox.SoundId = BoomboxState.CurrentSong
    Boombox.Volume = BoomboxState.Volume
    Boombox.Looped = BoomboxState.Loop
    Boombox:Play(); BoomboxState.Playing = true
    Notify("BOOMBOX", "Playing: "..BoomboxState.CurrentName, 2)
end })
TabMusic:Button({ Title = "⏸️ PAUSE", Callback = function() Boombox:Pause(); Notify("BOOMBOX", "Paused", 2) end })
TabMusic:Button({ Title = "⏹️ STOP", Callback = function() Boombox:Stop(); BoomboxState.Playing = false; Notify("BOOMBOX", "Stopped", 2) end })

-- BG (FIX con rescan)
TabBg:Section({ Title = "🎨 BACKGROUND CHANGER" })
TabBg:Paragraph({ Title = "Cambia el fondo del menú", Desc = "Elige entre "..#BG_LIST.." fondos diferentes." })

for _, bg in ipairs(BG_LIST) do
    TabBg:Button({ Title = "🖼️  "..bg.name, Callback = function()
        setWindowBackground(bg.id)
        Notify("BACKGROUND", bg.name.." aplicado", 2)
    end })
end

TabBg:Button({ Title = "🔄  RESET (Fondo principal)", Callback = function()
    setWindowBackground(DEFAULT_BG)
    Notify("BACKGROUND", "Fondo principal restaurado", 2)
end })

-- 🐛 Botón de debug
TabBg:Button({ Title = "🐛 DEBUG: Detectar fondo", Callback = function()
    WindUI_BgCache = nil
    local bg = findWindUIBackground()
    if bg then
        print("[DEBUG] Fondo detectado: "..bg:GetFullName())
        print("[DEBUG] Tamaño: "..tostring(bg.AbsoluteSize))
        print("[DEBUG] Image actual: "..tostring(bg.Image))
        Notify("DEBUG", "OK: "..bg.Name.." ("..math.floor(bg.AbsoluteSize.X).."x"..math.floor(bg.AbsoluteSize.Y)..")", 5)
    else
        Notify("DEBUG", "❌ No detectado - revisa consola", 5)
    end
end })

-- PC-MODE
TabPc:Section({ Title = "CONTROLES" })
TabPc:Keybind({ Title = "ESP Toggle", Value = "None", Callback = function(k) SZK.Keybinds.ESP = k end })
TabPc:Keybind({ Title = "TriggerBot Toggle", Value = "None", Callback = function(k) SZK.Keybinds.TriggerBot = k end })
TabPc:Keybind({ Title = "Silent Aim Toggle", Value = "None", Callback = function(k) SZK.Keybinds.SilentAim = k end })
TabPc:Keybind({ Title = "Aimbot Toggle", Value = "None", Callback = function(k) SZK.Keybinds.Aimbot = k end })

-- INFO
TabInf:Section({ Title = "INFO DEL JUEGO" })
TabInf:Paragraph({ Title = "Game: Murderers vs Sheriffs Duels", Desc = "PlaceId: "..tostring(game.PlaceId).."\nLast Update: 29/09/2026" })
TabInf:Section({ Title = "CREDITOS" })
TabInf:Paragraph({ Title = "MADE BY SZK", Desc = SCRIPT_NAME.." "..SCRIPT_VERSION.."\nDiscord: https://discord.gg/gRzA4bsTxv" })
TabInf:Section({ Title = "CONTENT CREATORS" })
TabInf:Button({ Title = "★ JUAN • CC", Callback = function()
    pcall(function() if setclipboard then setclipboard("https://www.tiktok.com/@juancc302") end end)
    pcall(function() game:GetService("GuiService"):OpenBrowserWindow("https://www.tiktok.com/@juancc302") end)
    Notify("CC", "JUAN TikTok abierto", 3)
end })
TabInf:Button({ Title = "★ 66GHOST660 • CC", Callback = function()
    pcall(function() if setclipboard then setclipboard("https://www.tiktok.com/@666ghost667") end end)
    pcall(function() game:GetService("GuiService"):OpenBrowserWindow("https://www.tiktok.com/@666ghost667") end)
    Notify("CC", "66GHOST660 TikTok abierto", 3)
end })



RunService.RenderStepped:Connect(function(dt)
    local ab = SZK.Aimbot
    if not ab.Enabled then return end
    if ab.OnlyGun then
        local c = LP.Character
        local tool = c and c:FindFirstChildOfClass("Tool")
        if not tool or IsFirearm(tool) ~= true then return end
    end
    local cfg = {Target=ab.TargetPart, UseFovLimit=true, FovSize=SZK.GlobalFov, WallCheck=false, MaxDistance=5000}
    local best = FindBestTarget(cfg); if not best then return end
    local tPos = best.Position
    if ab.Prediction then
        local hrp = best.Parent and best.Parent:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            if vel.Magnitude > 1 then
                local dist = (tPos - cam.CFrame.Position).Magnitude
                tPos = tPos + vel * (dist/1500) * ab.PredictionScale
            end
        end
    end
    local curCF = cam.CFrame
    local tgtCF = CFrame.new(curCF.Position, tPos)
    local sm = math.clamp(ab.Smoothness, 0, 1)
    local lf = 1 - sm
    if lf <= 0 then return end
    local alpha = 1 - (1-lf)^(dt*60)
    cam.CFrame = curCF:Lerp(tgtCF, alpha)
end)

task.spawn(function()
    local knifeHead = {"Head","HumanoidRootPart","UpperTorso","Torso"}
    local knifeTorso = {"UpperTorso","Torso","HumanoidRootPart","LowerTorso"}
    local knifeFull = {"Head","HumanoidRootPart","UpperTorso","Torso","LowerTorso","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg","LeftArm","RightArm","LeftLeg","RightLeg"}
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
    local function getParts(m)
        if m == "Cabeza" then return knifeHead end
        if m == "Torso" then return knifeTorso end
        return knifeFull
    end
    while true do
        if SZK.KnifeBot.Enabled then
            local c = LP.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local arma = c:FindFirstChildOfClass("Tool")
                if arma and arma:FindFirstChild("Handle") and IsMelee(arma) then
                    local myPos = c.HumanoidRootPart.Position
                    local objs = {}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LP and IsEnemy(p) and p.Character then
                            local eh = p.Character:FindFirstChild("Humanoid")
                            if eh and eh.Health > 0 then
                                for _, pn in ipairs(getParts(SZK.KnifeBot.TargetPart)) do
                                    local pt = p.Character:FindFirstChild(pn)
                                    if pt and pt:IsA("BasePart") then
                                        table.insert(objs, {Part=pt, Dist=(pt.Position-myPos).Magnitude, Char=p.Character})
                                    end
                                end
                            end
                        end
                    end
                    table.sort(objs, function(a,b) return a.Dist < b.Dist end)
                    local tgtPart, tgtChar
                    for _, o in ipairs(objs) do
                        params.FilterDescendantsInstances = {c, o.Char}
                        local cf = o.Part.CFrame
                        local vis = not workspace:Raycast(myPos, cf.Position-myPos, params)
                        if vis then tgtPart = o.Part; tgtChar = o.Char; break end
                    end
                    if tgtPart and tgtChar then
                        local eHRP = tgtChar:FindFirstChild("HumanoidRootPart")
                        if eHRP then genv.SZK_KnifeTarget = eHRP end
                        pcall(function()
                            arma:Activate()
                            task.delay(0.002, function() if arma.Parent == c then arma:Deactivate() end end)
                        end)
                        task.wait(0.003)
                    else
                        genv.SZK_KnifeTarget = nil; task.wait(0.01)
                    end
                else genv.SZK_KnifeTarget = nil; task.wait(0.05) end
            else task.wait(0.1) end
        else genv.SZK_KnifeTarget = nil; task.wait(0.05) end
    end
end)

local lastWeaponWarn = 0
task.spawn(function()
    while task.wait(0.008) do
        local tb = SZK.TriggerBot
        if tb.Enabled and tb._toggled and InGame() then
            local c = LP.Character
            if c then
                local myHRP = GetHRP(LP)
                if myHRP then
                    local best = FindBestTarget(tb)
                    if best then
                        local hum = c:FindFirstChildOfClass("Humanoid")
                        local ct = c:FindFirstChildOfClass("Tool")
                        if ct and IsFirearm(ct) ~= true then
                            if hum then pcall(function() hum:UnequipTools() end) end
                            tb._weaponEquipped = nil
                            task.wait(0.015)
                            ct = c:FindFirstChildOfClass("Tool")
                        end
                        if not ct or IsFirearm(ct) ~= true then
                            local bp = LP:FindFirstChildOfClass("Backpack")
                            local gun = nil
                            if bp then
                                for _, item in ipairs(bp:GetChildren()) do
                                    if item:IsA("Tool") and IsFirearm(item) == true then gun = item; break end
                                end
                            end
                            if gun and hum then
                                pcall(function() hum:EquipTool(gun) end)
                                tb._weaponEquipped = gun
                                task.wait(0.03)
                                ct = c:FindFirstChildOfClass("Tool")
                            else
                                local now = tick()
                                if now - lastWeaponWarn > 5 then
                                    lastWeaponWarn = now
                                    Notify("TRIGGER BOT", "⚠️ Marca tu GUN en la lista de armas", 4)
                                end
                            end
                        end
                        if tb.AutoShoot and ct and IsFirearm(ct) == true and ct:FindFirstChild("Handle") then
                            local now = tick()
                            if (now - tb._lastShot) >= tb.ShootDelay then
                                tb._lastShot = now
                                genv.SZK_ShotTarget = best
                                pcall(function()
                                    if ct.Parent == c then
                                        ct:Activate()
                                        task.delay(tb.ActivateTime, function()
                                            pcall(function() if ct.Parent == c then ct:Deactivate() end end)
                                        end)
                                    end
                                end)
                                task.delay(0.2, function()
                                    if genv.SZK_ShotTarget == best then genv.SZK_ShotTarget = nil end
                                end)
                            end
                        end
                    else
                        if tb.UnequipNoEnemy and tb._weaponEquipped then
                            local tool = c:FindFirstChildOfClass("Tool")
                            local hum = c:FindFirstChildOfClass("Humanoid")
                            if tool and hum then
                                pcall(function() hum:UnequipTools() end)
                                tb._weaponEquipped = nil
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.03) do
        local s = SZK.SilentAim
        if s.Enabled and s._toggled and InGame() then
            genv.SZK_Target = FindBestTarget(s)
        else genv.SZK_Target = nil end
    end
end)

task.spawn(function()
    while task.wait(0.03) do
        local a = SZK.AutoShoot
        if a.Enabled and a._toggled and InGame() then
            local c = LP.Character
            local tool = c and c:FindFirstChildOfClass("Tool")
            if c and tool and tool:FindFirstChild("Handle") then
                local best = FindBestTarget(a)
                local now = tick()
                if best and (now - a._lastShot) >= a.ShootDelay then
                    genv.SZK_ShotTarget = best; a._lastShot = now
                    pcall(function()
                        if tool.Parent == c then tool:Activate() end
                        task.delay(a.ActivateTime, function()
                            pcall(function() if tool.Parent == c then tool:Deactivate() end end)
                        end)
                    end)
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not SZK.Hitbox.Enabled then return end
    local sz = Vector3.new(SZK.Hitbox.Size, SZK.Hitbox.Size, SZK.Hitbox.Size + 1)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and IsEnemy(p) then
            local c = p.Character
            local rp = c:FindFirstChild("HumanoidRootPart")
            local hum = c:FindFirstChild("Humanoid")
            if rp and hum and hum.Health > 0 then
                if not c:FindFirstChild("GhostHitbox") then
                    local pt = Instance.new("Part")
                    pt.Name = "GhostHitbox"
                    pt.Size = sz
                    pt.Transparency = 0.7
                    pt.CanCollide = false
                    pt.Massless = true
                    pt.CFrame = rp.CFrame
                    pt.Parent = c
                    local w = Instance.new("WeldConstraint")
                    w.Part0 = rp; w.Part1 = pt; w.Parent = pt
                else
                    local pt = c:FindFirstChild("GhostHitbox")
                    if pt then pt.Size = sz end
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not SZK.Macro.Enabled then return end
    if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not InGame() then return end
    local now = tick()
    if now - SZK.Macro._lastUse < SZK.Macro.Cooldown then return end
    SZK.Macro._lastUse = now
    task.spawn(function()
        local c = LP.Character; if not c then return end
        local myHRP = GetHRP(LP); if not myHRP then return end
        local tool = c:FindFirstChildOfClass("Tool")
        if SZK.Macro.AutoEquip then
            if not tool or IsFirearm(tool) ~= true then
                local w = FindWeaponInBackpack(true)
                if w then EquipTool(w); task.wait(0.12); tool = c:FindFirstChildOfClass("Tool") end
            end
        end
        if not tool or not tool:FindFirstChild("Handle") then return end
        for i = 1, 3 do
            if not LP.Character or tool.Parent ~= c then break end
            if not InGame() then break end
            local cfg = {Target=SZK.Macro.Target, UseFovLimit=false, WallCheck=SZK.Macro.WallCheck, MaxDistance=SZK.Macro.MaxDistance}
            local best = FindBestTarget(cfg); if not best then break end
            genv.SZK_ShotTarget = best; genv.SZK_Target = best
            pcall(function() tool:Activate(); task.wait(0.05); tool:Deactivate() end)
            task.wait(0.05)
        end
        task.delay(0.2, function() genv.SZK_ShotTarget = nil; genv.SZK_Target = nil end)
    end)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        if Boombox.Playing then
            Boombox:Pause(); Notify("BOOMBOX", "Paused", 2)
        else
            Boombox.SoundId = BoomboxState.CurrentSong
            Boombox.Volume = BoomboxState.Volume
            Boombox.Looped = BoomboxState.Loop
            Boombox:Play(); BoomboxState.Playing = true
            Notify("BOOMBOX", "Playing: "..BoomboxState.CurrentName, 2)
        end
    end
    if input.KeyCode == SZK.SilentAim.Keybind then SZK.SilentAim._toggled = not SZK.SilentAim._toggled end
    if input.KeyCode == SZK.AutoShoot.Keybind then SZK.AutoShoot._toggled = not SZK.AutoShoot._toggled end
    if input.KeyCode == SZK.TriggerBot.Keybind then
        SZK.TriggerBot._toggled = not SZK.TriggerBot._toggled
        Notify("TRIGGER BOT", SZK.TriggerBot._toggled and "ON" or "OFF", 2)
    end
    if SZK.Keybinds.ESP and input.KeyCode == SZK.Keybinds.ESP then
        SZK.ESP.Enabled = not SZK.ESP.Enabled; rebuildAllESP()
    end
    if SZK.Keybinds.TriggerBot and input.KeyCode == SZK.Keybinds.TriggerBot then
        SZK.TriggerBot.Enabled = not SZK.TriggerBot.Enabled
        SZK.TriggerBot._toggled = SZK.TriggerBot.Enabled
    end
    if SZK.Keybinds.SilentAim and input.KeyCode == SZK.Keybinds.SilentAim then
        SZK.SilentAim.Enabled = not SZK.SilentAim.Enabled
        SZK.SilentAim._toggled = SZK.SilentAim.Enabled
    end
    if SZK.Keybinds.Aimbot and input.KeyCode == SZK.Keybinds.Aimbot then
        SZK.Aimbot.Enabled = not SZK.Aimbot.Enabled
    end
end)

pcall(function()
    if hookmetamethod and checkcaller and getnamecallmethod then
        local oldH
        oldH = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local target = genv.SZK_ShotTarget or genv.SZK_Target or genv.SZK_KnifeTarget
            if not checkcaller() and target and target.Parent then
                if method == "Raycast" and self == workspace then
                    local origin, direction, params = ...
                    if typeof(direction) == "Vector3" and typeof(origin) == "Vector3" then
                        local newDir = (target.Position - origin).Unit * math.max(direction.Magnitude, 5000)
                        return oldH(self, origin, newDir, params)
                    end
                end
            end
            return oldH(self, ...)
        end)
    end
end)



local ScannerPanel
local scanRefresh_Click
pcall(function()
    local ScannerGui = Instance.new("ScreenGui")
    ScannerGui.Name = "SZK_scanner"
    ScannerGui.ResetOnSpawn = false
    ScannerGui.IgnoreGuiInset = true
    ScannerGui.DisplayOrder = 998
    pcall(function() ScannerGui.Parent = gethui and gethui() or game:GetService("CoreGui") end)

    ScannerPanel = Instance.new("Frame")
    ScannerPanel.Size = UDim2.new(0, 270, 0, 360)
    ScannerPanel.Position = UDim2.new(0, 16, 0, 80)
    ScannerPanel.BackgroundColor3 = Color3.fromRGB(20,20,28)
    ScannerPanel.BackgroundTransparency = 0.03
    ScannerPanel.BorderSizePixel = 0
    ScannerPanel.Active = true
    ScannerPanel.Visible = false
    ScannerPanel.Parent = ScannerGui
    Instance.new("UICorner", ScannerPanel).CornerRadius = UDim.new(0,10)

    local scanHeader = Instance.new("Frame", ScannerPanel)
    scanHeader.Size = UDim2.new(1, 0, 0, 32)
    scanHeader.BackgroundColor3 = Color3.fromRGB(12,12,18)
    scanHeader.BorderSizePixel = 0
    scanHeader.Active = true
    Instance.new("UICorner", scanHeader).CornerRadius = UDim.new(0,10)

    local title = Instance.new("TextLabel", scanHeader)
    title.Size = UDim2.new(1,-70,1,0)
    title.Position = UDim2.new(0,10,0,0)
    title.BackgroundTransparency = 1
    title.Text = "🔫 WEAPON SCANNER"
    title.TextColor3 = Color3.fromRGB(245,245,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 10
    title.TextXAlignment = Enum.TextXAlignment.Left

    local scanClose = Instance.new("TextButton", scanHeader)
    scanClose.Size = UDim2.new(0, 22, 0, 22)
    scanClose.Position = UDim2.new(1, -26, 0.5, -11)
    scanClose.BackgroundColor3 = Color3.fromRGB(255,80,110)
    scanClose.Text = "✕"
    scanClose.TextColor3 = Color3.new(1,1,1)
    scanClose.Font = Enum.Font.GothamBold
    scanClose.TextSize = 11
    scanClose.BorderSizePixel = 0
    scanClose.Parent = scanHeader
    Instance.new("UICorner", scanClose).CornerRadius = UDim.new(0,6)

    local scanBody = Instance.new("ScrollingFrame", ScannerPanel)
    scanBody.Size = UDim2.new(1, -12, 1, -84)
    scanBody.Position = UDim2.new(0, 6, 0, 36)
    scanBody.BackgroundTransparency = 1
    scanBody.BorderSizePixel = 0
    scanBody.ScrollBarThickness = 3
    scanBody.CanvasSize = UDim2.new(0,0,0,0)
    scanBody.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scanBody.ScrollingDirection = Enum.ScrollingDirection.Y
    local scanLayout = Instance.new("UIListLayout", scanBody)
    scanLayout.Padding = UDim.new(0, 4)
    scanLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local scanActions = Instance.new("Frame", ScannerPanel)
    scanActions.Size = UDim2.new(1, -12, 0, 34)
    scanActions.Position = UDim2.new(0, 6, 1, -38)
    scanActions.BackgroundTransparency = 1

    local scanRefresh = Instance.new("TextButton", scanActions)
    scanRefresh.Size = UDim2.new(0.5, -3, 1, 0)
    scanRefresh.BackgroundColor3 = Color3.fromRGB(130,110,255)
    scanRefresh.Text = "🔄 SCAN"
    scanRefresh.TextColor3 = Color3.new(1,1,1)
    scanRefresh.Font = Enum.Font.GothamBold
    scanRefresh.TextSize = 9
    scanRefresh.BorderSizePixel = 0
    Instance.new("UICorner", scanRefresh).CornerRadius = UDim.new(0,6)

    local scanAutoEquip = Instance.new("TextButton", scanActions)
    scanAutoEquip.Size = UDim2.new(0.5, -3, 1, 0)
    scanAutoEquip.Position = UDim2.new(0.5, 3, 0, 0)
    scanAutoEquip.BackgroundColor3 = Color3.fromRGB(0,230,150)
    scanAutoEquip.Text = "⚡ AUTO GUN"
    scanAutoEquip.TextColor3 = Color3.new(1,1,1)
    scanAutoEquip.Font = Enum.Font.GothamBold
    scanAutoEquip.TextSize = 9
    scanAutoEquip.BorderSizePixel = 0
    Instance.new("UICorner", scanAutoEquip).CornerRadius = UDim.new(0,6)

    local scanRows = {}

    local function getWeaponTag(tool)
        if WeaponDB.Guns[tool.Name] then return "GUN", Color3.fromRGB(0,230,150) end
        if WeaponDB.Melees[tool.Name] then return "MELEE", Color3.fromRGB(255,80,110) end
        return "? SIN MARCAR", Color3.fromRGB(250,200,45)
    end

    local function clearScanRows()
        for _, r in ipairs(scanRows) do pcall(function() r:Destroy() end) end
        scanRows = {}
    end

    local function createScanRow(tool, isEquipped)
        local row = Instance.new("Frame", scanBody)
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = Color3.fromRGB(28,28,40)
        row.BackgroundTransparency = 0.5
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
        table.insert(scanRows, row)
        local tag, tagColor = getWeaponTag(tool)
        local prefix = isEquipped and "⭐ " or "   "
        local nl = Instance.new("TextLabel", row)
        nl.Size = UDim2.new(1, -110, 0, 14); nl.Position = UDim2.new(0, 8, 0, 2)
        nl.BackgroundTransparency = 1
        nl.Text = prefix..tool.Name
        nl.TextColor3 = Color3.fromRGB(245,245,255)
        nl.Font = Enum.Font.GothamBold; nl.TextSize = 9
        nl.TextXAlignment = Enum.TextXAlignment.Left
        local tl = Instance.new("TextLabel", row)
        tl.Size = UDim2.new(1, -110, 0, 10); tl.Position = UDim2.new(0, 8, 0, 18)
        tl.BackgroundTransparency = 1; tl.Text = tag; tl.TextColor3 = tagColor
        tl.Font = Enum.Font.GothamBold; tl.TextSize = 8
        tl.TextXAlignment = Enum.TextXAlignment.Left
        local gunBtn = Instance.new("TextButton", row)
        gunBtn.Size = UDim2.new(0, 46, 0, 16); gunBtn.Position = UDim2.new(1, -100, 0.5, -8)
        gunBtn.BackgroundColor3 = WeaponDB.Guns[tool.Name] and Color3.fromRGB(0,230,150) or Color3.fromRGB(40,44,64)
        gunBtn.Text = "GUN"; gunBtn.TextColor3 = Color3.new(1,1,1)
        gunBtn.Font = Enum.Font.GothamBold; gunBtn.TextSize = 8; gunBtn.BorderSizePixel = 0
        Instance.new("UICorner", gunBtn).CornerRadius = UDim.new(0,5)
        local meleeBtn = Instance.new("TextButton", row)
        meleeBtn.Size = UDim2.new(0, 46, 0, 16); meleeBtn.Position = UDim2.new(1, -50, 0.5, -8)
        meleeBtn.BackgroundColor3 = WeaponDB.Melees[tool.Name] and Color3.fromRGB(255,80,110) or Color3.fromRGB(40,44,64)
        meleeBtn.Text = "MELEE"; meleeBtn.TextColor3 = Color3.new(1,1,1)
        meleeBtn.Font = Enum.Font.GothamBold; meleeBtn.TextSize = 8; meleeBtn.BorderSizePixel = 0
        Instance.new("UICorner", meleeBtn).CornerRadius = UDim.new(0,5)
        gunBtn.MouseButton1Click:Connect(function()
            SZK_MarkAsGun(tool.Name); Notify("SCANNER", "'"..tool.Name.."' = GUN ✅", 2)
            if scanRefresh_Click then scanRefresh_Click() end
        end)
        meleeBtn.MouseButton1Click:Connect(function()
            SZK_MarkAsMelee(tool.Name); Notify("SCANNER", "'"..tool.Name.."' = MELEE ❌", 2)
            if scanRefresh_Click then scanRefresh_Click() end
        end)
    end

    scanRefresh_Click = function()
        clearScanRows()
        local char = LP.Character; if not char then return end
        local equipped = char:FindFirstChildOfClass("Tool")
        local bp = LP:FindFirstChildOfClass("Backpack")
        local count = 0
        if equipped then createScanRow(equipped, true); count = count + 1 end
        if bp then
            for _, item in ipairs(bp:GetChildren()) do
                if item:IsA("Tool") and item ~= equipped then
                    createScanRow(item, false); count = count + 1
                end
            end
        end
        if count == 0 then
            local empty = Instance.new("Frame", scanBody)
            empty.Size = UDim2.new(1, 0, 0, 30); empty.BackgroundTransparency = 1
            local el = Instance.new("TextLabel", empty)
            el.Size = UDim2.new(1,0,1,0); el.BackgroundTransparency = 1
            el.Text = "Sin armas en backpack"
            el.TextColor3 = Color3.fromRGB(100,100,115)
            el.Font = Enum.Font.Gotham; el.TextSize = 9
            el.TextXAlignment = Enum.TextXAlignment.Center
            table.insert(scanRows, empty)
        end
    end

    scanRefresh.MouseButton1Click:Connect(function() if scanRefresh_Click then scanRefresh_Click() end end)
    scanClose.MouseButton1Click:Connect(function() ScannerPanel.Visible = false end)
    scanAutoEquip.MouseButton1Click:Connect(function()
        local char = LP.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local bp = LP:FindFirstChildOfClass("Backpack")
        local gun = nil
        if bp then
            for _, item in ipairs(bp:GetChildren()) do
                if item:IsA("Tool") and IsFirearm(item) == true then gun = item; break end
            end
        end
        if not gun then
            local eq = char:FindFirstChildOfClass("Tool")
            if eq and IsFirearm(eq) == true then gun = eq end
        end
        if gun then
            pcall(function() hum:EquipTool(gun) end)
            Notify("SCANNER", "Equipada: "..gun.Name, 2)
        else
            Notify("SCANNER", "⚠️ No hay GUN marcada", 2)
        end
    end)

    do
        local dragging, dragStart, startPos = false, nil, nil
        scanHeader.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if input.Target == scanClose or (input.Target and input.Target:IsDescendantOf(scanClose)) then return end
                dragging = true; dragStart = input.Position; startPos = ScannerPanel.Position
            end
        end)
        scanHeader.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                ScannerPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    task.spawn(function()
        while true do
            task.wait(1.5)
            if ScannerPanel.Visible and scanRefresh_Click then scanRefresh_Click() end
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.B then
            ScannerPanel.Visible = not ScannerPanel.Visible
            if ScannerPanel.Visible and scanRefresh_Click then scanRefresh_Click() end
        end
    end)

    LP.CharacterAdded:Connect(function()
        task.wait(1)
        if ScannerPanel.Visible and scanRefresh_Click then scanRefresh_Click() end
    end)
end)



genv.SZK = SZK
genv.SZK_InGame = InGame
Notify(SCRIPT_NAME, SCRIPT_VERSION.." — ✅", 4)
Notify("🔇 NUEVO", "Silenciar disparo original disponible", 5)
Notify("BACKGROUNDS", "14 fondos en pestaña BG (con DEBUG)", 5)
Notify("SONIDOS", "🔊 Kill + Disparo/Recarga (chispas)", 5)
