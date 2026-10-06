local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ONYXHUB-X-SZK/SZKWINDUI/refs/heads/main/szk/lua/libary/wind%20ui/szkhub-libary.lua"))()

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")

local isPC = (function()
    local ok, platform = pcall(function() return UserInputService:GetPlatform() end)
    if ok and (platform == Enum.Platform.Android or platform == Enum.Platform.IOS) then return false end
    return UserInputService.KeyboardEnabled
end)()

-- ============ GLOBAL CONFIG (SZK) ============
local SZK = {
    GlobalFov = 300,
    ESP = {
        Enabled = false, ShowTeammates = false, MaxDistance = 2000,
        Highlight = true, Name = true, Distance = true, Health = true,
        Box = true, FillBox = false, HeadDot = true, Skeleton = false,
        Tracer = false, TracerOrigin = "Bottom" -- "Bottom" | "Top" | "Center"
    }
}
_G.SZK = SZK

-- genv para targets compartidos con el hook
local genv = { SZK_Target = nil, SZK_ShotTarget = nil, SZK_KnifeTarget = nil }
_G.genvSZK = genv

-- ============ THEMES ============
local function createTheme(name, colors)
    local theme = {}
    for key, value in pairs(WindUI:GetThemes().Dark) do theme[key] = value end
    theme.Name = name
    for key, value in pairs(colors) do theme[key] = value end
    WindUI:AddTheme(theme)
end

createTheme("Graphite", {
    Accent = Color3.fromRGB(58, 58, 62), Dialog = Color3.fromRGB(22, 22, 24),
    Outline = Color3.fromRGB(145, 145, 150), Text = Color3.fromRGB(232, 232, 235),
    Placeholder = Color3.fromRGB(118, 118, 124), Background = Color3.fromRGB(15, 15, 17),
    Button = Color3.fromRGB(82, 82, 88), Icon = Color3.fromRGB(174, 174, 180),
    Toggle = Color3.fromRGB(150, 150, 156), Slider = Color3.fromRGB(132, 132, 140),
    Checkbox = Color3.fromRGB(150, 150, 156), PanelBackground = Color3.fromRGB(22, 22, 25),
    PanelBackgroundTransparency = 0.56, TabBackground = Color3.fromRGB(38, 38, 42),
    TabBackgroundHover = Color3.fromRGB(72, 72, 78), TabBackgroundHoverTransparency = 0.72,
    TabBackgroundActive = Color3.fromRGB(92, 92, 100), TabBackgroundActiveTransparency = 0.52,
    TabTextTransparency = 0.05, TabTextTransparencyActive = 0,
    TabIconTransparency = 0.12, TabIconTransparencyActive = 0,
    TabBorderTransparency = 0.72, TabBorderTransparencyActive = 0.35,
    Primary = Color3.fromRGB(145, 145, 152)
})
createTheme("Deep Blue", {
    Accent = Color3.fromRGB(25, 42, 68), Dialog = Color3.fromRGB(10, 18, 31),
    Outline = Color3.fromRGB(75, 105, 145), Text = Color3.fromRGB(220, 231, 245),
    Placeholder = Color3.fromRGB(99, 119, 146), Background = Color3.fromRGB(6, 12, 22),
    Button = Color3.fromRGB(45, 69, 101), Icon = Color3.fromRGB(132, 158, 193),
    Toggle = Color3.fromRGB(69, 112, 168), Slider = Color3.fromRGB(62, 101, 154),
    Checkbox = Color3.fromRGB(69, 112, 168), PanelBackground = Color3.fromRGB(8, 16, 28),
    PanelBackgroundTransparency = 0.54, TabBackground = Color3.fromRGB(18, 34, 56),
    TabBackgroundHover = Color3.fromRGB(43, 72, 108), TabBackgroundHoverTransparency = 0.7,
    TabBackgroundActive = Color3.fromRGB(55, 91, 136), TabBackgroundActiveTransparency = 0.48,
    TabTextTransparency = 0.04, TabTextTransparencyActive = 0,
    TabIconTransparency = 0.1, TabIconTransparencyActive = 0,
    TabBorderTransparency = 0.68, TabBorderTransparencyActive = 0.3,
    Primary = Color3.fromRGB(69, 112, 168)
})
createTheme("Rose Gray", {
    Accent = Color3.fromRGB(111, 72, 88), Dialog = Color3.fromRGB(35, 24, 30),
    Outline = Color3.fromRGB(178, 137, 154), Text = Color3.fromRGB(242, 228, 234),
    Placeholder = Color3.fromRGB(151, 119, 132), Background = Color3.fromRGB(24, 16, 21),
    Button = Color3.fromRGB(126, 91, 106), Icon = Color3.fromRGB(202, 168, 182),
    Toggle = Color3.fromRGB(174, 119, 143), Slider = Color3.fromRGB(158, 108, 130),
    Checkbox = Color3.fromRGB(174, 119, 143), PanelBackground = Color3.fromRGB(32, 20, 27),
    PanelBackgroundTransparency = 0.52, TabBackground = Color3.fromRGB(58, 37, 47),
    TabBackgroundHover = Color3.fromRGB(105, 70, 84), TabBackgroundHoverTransparency = 0.68,
    TabBackgroundActive = Color3.fromRGB(132, 87, 106), TabBackgroundActiveTransparency = 0.46,
    TabTextTransparency = 0.03, TabTextTransparencyActive = 0,
    TabIconTransparency = 0.08, TabIconTransparencyActive = 0,
    TabBorderTransparency = 0.65, TabBorderTransparencyActive = 0.28,
    Primary = Color3.fromRGB(174, 119, 143)
})
WindUI:SetTheme("Graphite")

-- ============ EXECUTOR INFO & WEBHOOK ============
local function detectExecutorName()
    if type(getexecutorname) == "function" then
        local s, n = pcall(getexecutorname)
        if s and n and tostring(n) ~= "" then return tostring(n) end
    end
    if type(identifyexecutor) == "function" then
        local s, n = pcall(identifyexecutor)
        if s and n and tostring(n) ~= "" then return tostring(n) end
    end
    return "Unknown"
end
local executorName = detectExecutorName()

local notificationIcons = { done = "circle-check", warning = "triangle-alert", error = "circle-x", info = "info" }
local function notify(config)
    config = config or {}
    return WindUI:Notify({
        Title = config.Title or "SZK - DMVS",
        Content = config.Message or config.Content or "",
        Icon = notificationIcons[config.Type] or config.Icon or "bell",
        Duration = config.Duration or 4
    })
end

task.spawn(function()
    pcall(function()
        local logApiUrl = "https://synergy-team-official.vercel.app/api/log/dmvs"
        local gameName = "Unknown"
        pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
        local payload = {
            script = "dmvs", game = gameName, placeId = tostring(game.PlaceId), jobId = game.JobId,
            username = player.Name, displayName = player.DisplayName, executor = executorName
        }
        local body = HttpService:JSONEncode(payload)
        local sent = false
        if request then sent = pcall(function() request({Url=logApiUrl,Method="POST",Headers={["Content-Type"]="application/json"},Body=body}) end) end
        if not sent and syn and syn.request then pcall(function() syn.request({Url=logApiUrl,Method="POST",Headers={["Content-Type"]="application/json"},Body=body}) end) end
        if not sent and http_request then pcall(function() http_request({Url=logApiUrl,Method="POST",Headers={["Content-Type"]="application/json"},Body=body}) end) end
        if not sent then pcall(function() HttpService:RequestAsync({Url=logApiUrl,Method="POST",Headers={["Content-Type"]="application/json"},Body=body}) end) end
    end)
end)

-- ============ STATE ============
local dmvsDestroyed = false
local hitboxEnabled = false
local hitboxTransparency = 0.7
local hitboxSizeValue = 10
local CustomHitboxSize = Vector3.new(hitboxSizeValue, hitboxSizeValue, hitboxSizeValue)
local customParts = {}
local teamCheckEnabled = true
local enemyCache = {}

-- ============ SAFE ZONE / LOBBY ============
local SAFE_ZONES = {
    {Center = Vector3.new(-320.50, 280.82, 16.00), Radius = 500},
    {Center = Vector3.new(1564.14, -155.45, 40.04), Radius = 300}
}
local function isInLobby()
    local char = player.Character
    if not char then return true end
    if char:FindFirstChildOfClass("ForceField") then return true end
    if player.Team then
        local tName = string.lower(player.Team.Name)
        if string.find(tName, "lobby") or string.find(tName, "spectat") or string.find(tName, "menu") or string.find(tName, "dead") then return true end
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, zone in ipairs(SAFE_ZONES) do
            if (hrp.Position - zone.Center).Magnitude <= zone.Radius then return true end
        end
    end
    return false
end

-- ============ TEAM RESOLUTION ============
dmvsTeamResolverState = {Snapshot = {}, LastRefresh = 0, RefreshInterval = 0.12}
function dmvsRefreshScoreboardTeams(force)
    local state = dmvsTeamResolverState
    local now = os.clock()
    if not force and now - state.LastRefresh < state.RefreshInterval then return state.Snapshot end
    state.LastRefresh = now
    local snapshot = {}
    local pg = player:FindFirstChild("PlayerGui")
    local score = pg and pg:FindFirstChild("IngameScore", true)
    if score then
        local red = score:FindFirstChild("TeamRed")
        local blue = score:FindFirstChild("TeamBlue")
        if red then for _, e in ipairs(red:GetChildren()) do snapshot[string.lower(e.Name)] = "Red" end end
        if blue then for _, e in ipairs(blue:GetChildren()) do snapshot[string.lower(e.Name)] = "Blue" end end
    end
    state.Snapshot = snapshot
    return snapshot
end
function dmvsResolvePlayerTeam(tp)
    if not tp then return nil end
    local snap = dmvsRefreshScoreboardTeams(false)
    local t = snap[string.lower(tp.Name)]
    if not t and tp.DisplayName then t = snap[string.lower(tp.DisplayName)] end
    if t then return t end
    local attr = tp:GetAttribute("Team") or tp:GetAttribute("team")
    if attr ~= nil and tostring(attr) ~= "" then return tostring(attr) end
    if tp.Team then return tp.Team.Name end
    return nil
end
function dmvsPlayersAreEnemies(a, b)
    if not a or not b or a == b then return false end
    local ta, tb = dmvsResolvePlayerTeam(a), dmvsResolvePlayerTeam(b)
    if ta and tb then return ta ~= tb end
    return true
end
local function isEnemy(tp)
    if not tp or tp == player then return false end
    if not teamCheckEnabled then return true end
    return dmvsPlayersAreEnemies(player, tp)
end
local function updateMyTeam() enemyCache = {} dmvsRefreshScoreboardTeams(true) end
player:GetPropertyChangedSignal("Team"):Connect(updateMyTeam)
player:GetPropertyChangedSignal("TeamColor"):Connect(updateMyTeam)
player:GetAttributeChangedSignal("Team"):Connect(updateMyTeam)

-- ============ TOOLS ============
local function getInventoryTools()
    local tools = {}
    local bp = player:FindFirstChild("Backpack")
    if bp then for _, i in ipairs(bp:GetChildren()) do if i:IsA("Tool") then table.insert(tools, i) end end end
    local c = player.Character
    if c then for _, i in ipairs(c:GetChildren()) do if i:IsA("Tool") then table.insert(tools, i) end end end
    return tools
end
local function isKnife(t) return t and type(t.SetKnifeGoneTime) == "function" end
local function isGun(t)
    if not t then return false end
    local b = t:FindFirstChild("showBeam")
    return b and b:IsA("RemoteEvent")
end
local function getKnife() for _, t in ipairs(getInventoryTools()) do if isKnife(t) then return t end end return getInventoryTools()[1] end
local function getGun() for _, t in ipairs(getInventoryTools()) do if isGun(t) then return t end end return getInventoryTools()[2] end
local function getEquippedTool() return player.Character and player.Character:FindFirstChildOfClass("Tool") end
local function hasGunEquipped() return isGun(getEquippedTool()) end

-- ============ HELPERS COMBAT ============
local function GetHRP(p)
    local c = p.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetParts(plr, target)
    local parts = {}
    local c = plr.Character
    if not c then return parts end
    local t = target or "Head"
    if t == "Head" or t == "Cabeza" then
        local h = c:FindFirstChild("Head")
        if h then table.insert(parts, h) end
    elseif t == "Torso" then
        local ut = c:FindFirstChild("UpperTorso")
        local tt = c:FindFirstChild("Torso")
        local lr = c:FindFirstChild("HumanoidRootPart")
        if ut then table.insert(parts, ut) end
        if tt then table.insert(parts, tt) end
        if lr then table.insert(parts, lr) end
    else
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") and d.Name ~= "GhostHitbox" then
                table.insert(parts, d)
            end
        end
    end
    return parts
end

-- ============ HITBOX ============
local function clearAllHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local e = plr.Character:FindFirstChild("GhostHitbox")
            if e then e:Destroy() end
        end
    end
    customParts = {}
end
local hitboxConnection = RunService.Heartbeat:Connect(function()
    if not hitboxEnabled then return end
    for _, tp in ipairs(Players:GetPlayers()) do
        if tp ~= player and tp.Character then
            local c = tp.Character
            local rp = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if rp and h and h.Health > 0 then
                if not c:FindFirstChild("GhostHitbox") then
                    local p = Instance.new("Part")
                    p.Name = "GhostHitbox"; p.Size = CustomHitboxSize
                    p.Transparency = hitboxTransparency; p.CanCollide = false
                    p.Massless = true; p.CFrame = rp.CFrame; p.Parent = c
                    local w = Instance.new("WeldConstraint"); w.Part0 = rp; w.Part1 = p; w.Parent = p
                    customParts[tp] = p
                else
                    local p = c:FindFirstChild("GhostHitbox")
                    if p then p.Size = CustomHitboxSize; p.Transparency = hitboxTransparency end
                end
            end
        end
    end
end)

-- ============ AUX UI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DMVS_AuxiliaryUI"; screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local function makeDraggable(obj, toMove)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = toMove.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            toMove.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ============================================================
-- ==================== NUEVO ESP SYSTEM =======================
-- ============================================================
local ENEMY_COLOR = Color3.fromRGB(255, 80, 80)
local TEAM_COLOR  = Color3.fromRGB(80, 180, 255)
local ThemeSuccess = Color3.fromRGB(80, 220, 100)

-- Parents
local EspGui = Instance.new("ScreenGui")
EspGui.Name = "DMVS_ESP_New"
EspGui.ResetOnSpawn = false
EspGui.IgnoreGuiInset = true
EspGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
EspGui.Parent = playerGui

local CORE = playerGui
pcall(function()
    if gethui then CORE = gethui()
    elseif game:GetService("CoreGui") then CORE = game:GetService("CoreGui") end
end)

local ESP_Data = {}
local vpSize = camera.ViewportSize
camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() vpSize = camera.ViewportSize end)

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
    local d = ESP_Data[plr]
    if not d then return end
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

local FontB = Enum.Font.GothamBold
local FontM = Enum.Font.GothamMedium

local function createESP(plr)
    if plr == player then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then return end
    destroyESP(plr)
    local d = {skel={}}
    ESP_Data[plr] = d

    d.hl = Instance.new("Highlight", CORE)
    d.hl.FillColor = ENEMY_COLOR
    d.hl.OutlineColor = Color3.fromRGB(255,255,255)
    d.hl.FillTransparency = 0.8
    d.hl.OutlineTransparency = 0.4
    d.hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    d.hl.Adornee = char

    local bb = Instance.new("BillboardGui", CORE)
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
    d.name.TextColor3 = Color3.fromRGB(255, 255, 255)
    d.name.Font = FontB
    d.name.TextSize = 13
    d.name.TextStrokeTransparency = 0

    d.dist = Instance.new("TextLabel", bb)
    d.dist.Size = UDim2.new(1, 0, 0, 12)
    d.dist.Position = UDim2.new(0, 0, 0, 18)
    d.dist.BackgroundTransparency = 1
    d.dist.Text = "0m"
    d.dist.TextColor3 = ENEMY_COLOR
    d.dist.Font = FontM
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
    d.hp.BackgroundColor3 = ThemeSuccess
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
    local spT, onT = camera:WorldToViewportPoint(topPos)
    local spB, onB = camera:WorldToViewportPoint(bottomPos)
    local spH, onH = camera:WorldToViewportPoint(hrp.Position)
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
    local myHRP = GetHRP(player)
    if not myHRP then return end
    local myPos = myHRP.Position
    for plr, d in pairs(ESP_Data) do
        local teammate = not isEnemy(plr)
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
                    local sp, on = camera:WorldToViewportPoint(head.Position)
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
                                local sa, onA = camera:WorldToViewportPoint(a.Position)
                                local sb, onB = camera:WorldToViewportPoint(b.Position)
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
                    local sp, on = camera:WorldToViewportPoint(hrp.Position)
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
    if plr == player then return end
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
        for _, plr in ipairs(Players:GetPlayers()) do if plr ~= player and plr.Character then createESP(plr) end end
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

-- ============================================================
-- ==================== NUEVO COMBAT SYSTEM ====================
-- ============================================================
local Combat = {
    SilentAim  = {Enabled=false, Keybind=Enum.KeyCode.Q, Target="Head", UseFovLimit=true, WallCheck=true, MaxDistance=5000, FovSize=300, _toggled=false},
    AutoShoot  = {Enabled=false, Keybind=Enum.KeyCode.E, Target="Head", UseFovLimit=true, WallCheck=true, MaxDistance=5000, FovSize=300, ShootDelay=0.15, ActivateTime=0.05, _toggled=false, _lastShot=0},
    TriggerBot = {Enabled=false, Keybind=Enum.KeyCode.T, AutoEquip=true, AutoShoot=true, UnequipNoEnemy=true, PreferFirearm=true, DropMelee=true, Target="Head", UseFovLimit=true, FovSize=300, WallCheck=true, MaxDistance=5000, ShootDelay=0.04, ActivateTime=0.02, _toggled=false, _lastShot=0, _weaponEquipped=nil, _shots=0},
}
_G.CombatSZK = Combat

-- ==================== FIND BEST TARGET (COMPARTIDO) ====================
local function FindBestTarget(cfg)
    local char = player.Character
    local myHRP = GetHRP(player)
    if not char or not myHRP then return nil end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local myPos = myHRP.Position
    local cx, cy = camera.ViewportSize.X/2, camera.ViewportSize.Y/2
    local fovLimit = cfg.FovSize or SZK.GlobalFov
    local best, bestScore, bestName = nil, math.huge, nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            params.FilterDescendantsInstances = {char, plr.Character}
            for _, part in ipairs(GetParts(plr, cfg.Target)) do
                local dist = (part.Position - myPos).Magnitude
                if dist <= cfg.MaxDistance then
                    local sp, on = camera:WorldToViewportPoint(part.Position)
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
                                if visible then
                                    bestScore, best, bestName = score, part, plr.Name
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestName
end

-- ==================== SILENT AIM ====================
task.spawn(function()
    while task.wait(0.03) do
        local s = Combat.SilentAim
        if s.Enabled and s._toggled and not isInLobby() then
            genv.SZK_Target = FindBestTarget(s)
        else
            genv.SZK_Target = nil
        end
    end
end)

-- ==================== AUTO SHOOT ====================
task.spawn(function()
    while task.wait(0.03) do
        local a = Combat.AutoShoot
        if a.Enabled and a._toggled and not isInLobby() then
            local c = player.Character
            local tool = c and c:FindFirstChildOfClass("Tool")
            if c and tool and tool:FindFirstChild("Handle") then
                local best = FindBestTarget(a)
                local now = tick()
                if best and (now - a._lastShot) >= a.ShootDelay then
                    genv.SZK_ShotTarget = best; a._lastShot = now
                    pcall(function()
                        if tool.Parent == c then
                            tool:Activate()
                        end
                        task.delay(a.ActivateTime, function()
                            pcall(function() if tool.Parent == c then tool:Deactivate() end end)
                        end)
                    end)
                end
            end
        end
    end
end)

-- ==================== TRIGGER BOT ====================
local lastWeaponWarn = 0

task.spawn(function()
    while task.wait(0.008) do
        local tb = Combat.TriggerBot

        if tb.Enabled and tb._toggled and not isInLobby() then
            local c = player.Character
            if not c then continue end

            local myHRP = GetHRP(player)
            if not myHRP then continue end

            local best = FindBestTarget(tb)
            if not best then continue end

            local hum = c:FindFirstChildOfClass("Humanoid")
            local ct = c:FindFirstChildOfClass("Tool")

            -- Auto Equip
            if ct and isGun(ct) ~= true then
                if hum then pcall(function() hum:UnequipTools() end) end
                tb._weaponEquipped = nil
                task.wait(0.015)
                ct = c:FindFirstChildOfClass("Tool")
            end

            if not ct or isGun(ct) ~= true then
                local bp = player:FindFirstChildOfClass("Backpack")
                local gun = nil
                if bp then
                    for _, item in ipairs(bp:GetChildren()) do
                        if item:IsA("Tool") and isGun(item) == true then
                            gun = item
                            break
                        end
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
                        notify({Title="TRIGGER BOT", Message="⚠️ Marca tu GUN en la lista de armas", Type="warning", Duration=4})
                    end
                    continue
                end
            end

            -- Auto Shoot
            if tb.AutoShoot and ct and isGun(ct) == true and ct:FindFirstChild("Handle") then
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
            -- Unequip cuando no hay enemigo
            if tb.UnequipNoEnemy and tb._weaponEquipped then
                local c = player.Character
                local tool = c and c:FindFirstChildOfClass("Tool")
                local hum = c and c:FindFirstChildOfClass("Humanoid")
                if tool and hum then
                    pcall(function() hum:UnequipTools() end)
                    tb._weaponEquipped = nil
                end
            end
        end
    end
end)

-- ==================== HOOKMETAMETHOD (SILENT AIM) ====================
local namecallHook
pcall(function()
    if hookmetamethod and checkcaller and getnamecallmethod then
        local oldH
        oldH = hookmetamethod(game, "__namecall", function(self, ...)
            if checkcaller() then return oldH(self, ...) end
            local method = getnamecallmethod()
            local target = genv.SZK_ShotTarget or genv.SZK_Target or genv.SZK_KnifeTarget
            if target and target.Parent then
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
        namecallHook = oldH
    end
end)

-- ==================== KEYBINDS ====================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Combat.SilentAim.Keybind then
        Combat.SilentAim._toggled = not Combat.SilentAim._toggled
        notify({Title="SILENT AIM", Message=Combat.SilentAim._toggled and "ON" or "OFF", Type="info", Duration=2})
    end
    if input.KeyCode == Combat.AutoShoot.Keybind then
        Combat.AutoShoot._toggled = not Combat.AutoShoot._toggled
        notify({Title="AUTO SHOOT", Message=Combat.AutoShoot._toggled and "ON" or "OFF", Type="info", Duration=2})
    end
    if input.KeyCode == Combat.TriggerBot.Keybind then
        Combat.TriggerBot._toggled = not Combat.TriggerBot._toggled
        notify({Title="TRIGGER BOT", Message=Combat.TriggerBot._toggled and "ON" or "OFF", Type="info", Duration=2})
    end
end)

-- ============ DEAD ZONE ============
local deadZoneFrame = Instance.new("Frame")
deadZoneFrame.Size = UDim2.new(0, 150, 0, 150)
deadZoneFrame.Position = UDim2.new(0.8, -75, 0.8, -75)
deadZoneFrame.BackgroundColor3 = Color3.fromRGB(255,50,50)
deadZoneFrame.BackgroundTransparency = 0.5; deadZoneFrame.Visible = false
deadZoneFrame.ZIndex = 100; deadZoneFrame.Parent = screenGui
Instance.new("UICorner", deadZoneFrame).CornerRadius = UDim.new(0,16)
local dzStroke = Instance.new("UIStroke", deadZoneFrame)
dzStroke.Color = Color3.fromRGB(255,255,255); dzStroke.Thickness = 2
local dzLabel = Instance.new("TextLabel", deadZoneFrame)
dzLabel.Size = UDim2.new(1,0,1,0); dzLabel.BackgroundTransparency = 1
dzLabel.Text = "DEAD ZONE\n(Drag)"; dzLabel.TextColor3 = Color3.fromRGB(255,255,255)
dzLabel.Font = Enum.Font.GothamBold; dzLabel.TextSize = 14; dzLabel.TextWrapped = true
makeDraggable(deadZoneFrame, deadZoneFrame)

-- ============ MACRO (GUN) ============
local macroActive = false
local macroEquipDelay = 0.04
local macroShootDelay = 0.10
local screenTouches = {}
local function executeMacroAction()
    if isInLobby() then return end
    local hasEnemies = false
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if dmvsPlayersAreEnemies(player, p) then hasEnemies = true break end
        end
    end
    if not hasEnemies then return end
    local char = player.Character; if not char then return end
    local hum = char:FindFirstChild("Humanoid"); if not hum then return end
    local toolInHand = char:FindFirstChildOfClass("Tool")
    if toolInHand and not isGun(toolInHand) then return end
    local gun = getGun(); if not gun then return end
    task.spawn(function()
        hum:UnequipTools(); task.wait()
        hum:EquipTool(gun); task.wait(macroEquipDelay)
        if gun.Parent == char then
            gun:Activate(); task.wait(macroShootDelay)
            gun:Deactivate(); hum:UnequipTools()
        end
    end)
end
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not macroActive then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then executeMacroAction()
    elseif input.KeyCode == Enum.KeyCode.ButtonR2 then executeMacroAction()
    elseif input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        local dzPos = deadZoneFrame.AbsolutePosition
        local dzSz = deadZoneFrame.AbsoluteSize
        local inDZ = (pos.X >= dzPos.X) and (pos.X <= dzPos.X + dzSz.X) and (pos.Y >= dzPos.Y) and (pos.Y <= dzPos.Y + dzSz.Y)
        if not inDZ then screenTouches[input] = {position = input.Position, time = tick()} end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if not macroActive then return end
    if input.UserInputType == Enum.UserInputType.Touch and screenTouches[input] then
        local d = screenTouches[input]
        local moved = (d.position - input.Position).Magnitude
        local pressed = tick() - d.time
        screenTouches[input] = nil
        if moved < 10 and pressed < 0.35 and pressed > 0.03 then executeMacroAction() end
    end
end)

-- ============ KILL SOUND ============
dmvsKillSoundState = {
    Enabled = false, Selected = "Among Us", Options = {"Good","Among Us","Arsenal OG"},
    Assets = {Good = "131977397046203", ["Among Us"] = "130456049552264", ["Arsenal OG"] = "88261753232248"},
    PlayerConnections = {}
}
function dmvsIsDeathSound(s)
    if not s or not s:IsA("Sound") or s.Name == "DMVS_KillSound" then return false end
    local n = string.lower(s.Name)
    return n == "died" or n == "death" or n == "dead" or n == "deathsound"
        or string.find(n, "death", 1, true) or string.find(n, "died", 1, true)
end
function dmvsStopDeathSound(s)
    if not dmvsIsDeathSound(s) then return end
    pcall(function() s:Stop() end); pcall(function() s.Volume = 0 end)
end
function dmvsSuppressCharacterDeathSounds(c)
    if not c then return end
    for _, o in ipairs(c:GetDescendants()) do dmvsStopDeathSound(o) end
    local conn = c.DescendantAdded:Connect(function(o) if dmvsKillSoundState.Enabled then dmvsStopDeathSound(o) end end)
    task.delay(2, function() if conn and conn.Connected then conn:Disconnect() end end)
end
function dmvsPlayKillSound()
    if not dmvsKillSoundState.Enabled or dmvsDestroyed then return end
    local id = dmvsKillSoundState.Assets[dmvsKillSoundState.Selected]; if not id then return end
    local s = Instance.new("Sound"); s.Name = "DMVS_KillSound"; s.SoundId = "rbxassetid://"..id
    s.Volume = 1; s.Parent = game:GetService("SoundService"); s:Play()
    s.Ended:Connect(function() if s.Parent then s:Destroy() end end)
    game:GetService("Debris"):AddItem(s, 12)
end
function dmvsBindKillSoundCharacter(tp, c)
    if tp == player or not c then return end
    local d = dmvsKillSoundState.PlayerConnections[tp]
    if not d then d = {} dmvsKillSoundState.PlayerConnections[tp] = d end
    if d.HumanoidConnection then d.HumanoidConnection:Disconnect(); d.HumanoidConnection = nil end
    local h = c:FindFirstChildOfClass("Humanoid") or c:WaitForChild("Humanoid", 5); if not h then return end
    d.HumanoidConnection = h.Died:Connect(function()
        if not dmvsKillSoundState.Enabled or dmvsDestroyed then return end
        dmvsSuppressCharacterDeathSounds(c); dmvsPlayKillSound()
    end)
end
function dmvsRegisterKillSoundPlayer(tp)
    if tp == player then return end
    local d = dmvsKillSoundState.PlayerConnections[tp]
    if not d then d = {} dmvsKillSoundState.PlayerConnections[tp] = d end
    if not d.CharacterConnection then
        d.CharacterConnection = tp.CharacterAdded:Connect(function(c) dmvsBindKillSoundCharacter(tp, c) end)
    end
    if tp.Character then task.defer(dmvsBindKillSoundCharacter, tp, tp.Character) end
end
function dmvsUnregisterKillSoundPlayer(tp)
    local d = dmvsKillSoundState.PlayerConnections[tp]; if not d then return end
    for _, c in pairs(d) do if typeof(c) == "RBXScriptConnection" then pcall(function() c:Disconnect() end) end end
    dmvsKillSoundState.PlayerConnections[tp] = nil
end
for _, tp in ipairs(Players:GetPlayers()) do dmvsRegisterKillSoundPlayer(tp) end
dmvsKillSoundState.PlayerAddedConnection = Players.PlayerAdded:Connect(dmvsRegisterKillSoundPlayer)
dmvsKillSoundState.PlayerRemovingConnection = Players.PlayerRemoving:Connect(dmvsUnregisterKillSoundPlayer)

-- ============ LOOP TP ============
dmvsLoopTPState = {Enabled = false, Selected = nil, Options = {}}
dmvsLoopTPDropdown = nil
function dmvsBuildLoopTPPlayerList()
    local o = {}
    for _, tp in ipairs(Players:GetPlayers()) do if tp ~= player then o[#o+1] = tp.Name end end
    table.sort(o, function(a,b) return string.lower(a) < string.lower(b) end)
    dmvsLoopTPState.Options = o
    if dmvsLoopTPState.Selected and not Players:FindFirstChild(dmvsLoopTPState.Selected) then dmvsLoopTPState.Selected = nil end
    if not dmvsLoopTPState.Selected and #o > 0 then dmvsLoopTPState.Selected = o[1] end
    return o
end
function dmvsRefreshLoopTPPlayers()
    local o = dmvsBuildLoopTPPlayerList()
    if dmvsLoopTPDropdown and type(dmvsLoopTPDropdown.Refresh) == "function" then
        pcall(function()
            dmvsLoopTPDropdown:Refresh(o, true)
            if dmvsLoopTPState.Selected and type(dmvsLoopTPDropdown.Select) == "function" then
                dmvsLoopTPDropdown:Select(dmvsLoopTPState.Selected, true)
            end
        end)
    end
end
function dmvsTeleportToLoopTPTarget()
    if not dmvsLoopTPState.Enabled or not dmvsLoopTPState.Selected or dmvsDestroyed then return false end
    local tp = Players:FindFirstChild(dmvsLoopTPState.Selected); if not tp or tp == player then return false end
    local tc = tp.Character; local tr = tc and tc:FindFirstChild("HumanoidRootPart"); if not tr then return false end
    local mc = player.Character; local mh = mc and mc:FindFirstChildOfClass("Humanoid"); local mr = mc and mc:FindFirstChild("HumanoidRootPart")
    if not mh or mh.Health <= 0 or not mr then return false end
    mr.CFrame = tr.CFrame; return true
end
task.spawn(function()
    while not dmvsDestroyed do
        if dmvsLoopTPState.Enabled then pcall(dmvsTeleportToLoopTPTarget) end
        task.wait(0.001)
    end
end)

-- ============ AUTO MACRO 360 ============
dmvsAutoMacroState = {
    Enabled = false, Range = 250, EquipDelay = 0.04, ShootDelay = 0.10, ScanDelay = 0.03,
    TeamCheck = true, WallCheck = true, TargetPart = "Head", Busy = false,
    CurrentTarget = nil, ManagedGun = nil
}
function dmvsAutoMacroIsEnemy(tp)
    if not tp or tp == player then return false end
    local tc = tp.Character; local th = tc and tc:FindFirstChildOfClass("Humanoid")
    if not th or th.Health <= 0 then return false end
    local myMatch = player:GetAttribute("MatchId"); local tMatch = tp:GetAttribute("MatchId")
    if myMatch and tMatch and myMatch ~= "" and tMatch ~= "" and myMatch ~= tMatch then return false end
    if not dmvsAutoMacroState.TeamCheck then return true end
    return dmvsPlayersAreEnemies(player, tp)
end
function dmvsAutoMacroResolvePart(c)
    if not c then return nil end
    if dmvsAutoMacroState.TargetPart == "Head" then return c:FindFirstChild("Head") end
    if dmvsAutoMacroState.TargetPart == "Torso" then
        return c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("HumanoidRootPart")
    end
    for _, n in ipairs({"Head","UpperTorso","LowerTorso","Torso","HumanoidRootPart","LeftArm","RightArm","LeftLeg","RightLeg"}) do
        local p = c:FindFirstChild(n); if p and p:IsA("BasePart") then return p end
    end
    return nil
end
function dmvsAutoMacroHasLineOfSight(tp)
    if not dmvsAutoMacroState.WallCheck then return true end
    local mc = player.Character; local tc = tp and tp.Parent; if not mc or not tc then return false end
    local op = mc:FindFirstChild("Head") or mc:FindFirstChild("HumanoidRootPart"); if not op then return false end
    local p = RaycastParams.new(); p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = {mc, tc}; p.IgnoreWater = true
    return workspace:Raycast(op.Position, tp.Position - op.Position, p) == nil
end
function dmvsAutoMacroTargetValid(tp)
    if not tp or not tp.Parent then return false end
    local tc = tp.Parent; local th = tc:FindFirstChildOfClass("Humanoid")
    if not th or th.Health <= 0 then return false end
    local mc = player.Character; local mr = mc and mc:FindFirstChild("HumanoidRootPart"); if not mr then return false end
    if (tp.Position - mr.Position).Magnitude > dmvsAutoMacroState.Range then return false end
    return dmvsAutoMacroHasLineOfSight(tp)
end
function dmvsAutoMacroGetTarget()
    if not dmvsAutoMacroState.Enabled or dmvsDestroyed or isInLobby() then return nil end
    local mc = player.Character; local mh = mc and mc:FindFirstChildOfClass("Humanoid")
    local mr = mc and mc:FindFirstChild("HumanoidRootPart")
    if not mh or mh.Health <= 0 or not mr then return nil end
    local bt, bd = nil, dmvsAutoMacroState.Range
    for _, tp in ipairs(Players:GetPlayers()) do
        if dmvsAutoMacroIsEnemy(tp) then
            local p = dmvsAutoMacroResolvePart(tp.Character)
            if p then
                local d = (p.Position - mr.Position).Magnitude
                if d <= bd and dmvsAutoMacroHasLineOfSight(p) then bd = d; bt = p end
            end
        end
    end
    return bt
end
function dmvsAutoMacroCleanupGun(g, c, h)
    if g then pcall(function() g:Deactivate() end) end
    if h and h.Parent then pcall(function() h:UnequipTools() end) end
    task.delay(0.035, function()
        if g then pcall(function() g:Deactivate() end) end
        if h and h.Parent then pcall(function() h:UnequipTools() end) end
    end)
    task.delay(0.09, function()
        if not g or not c or g.Parent ~= c then return end
        if h and h.Parent then pcall(function() h:UnequipTools() end) end
        task.wait()
        if g.Parent == c then
            local bp = player:FindFirstChild("Backpack")
            if bp then pcall(function() g.Parent = bp end) end
        end
    end)
end
function dmvsAutoMacroRunCycle(tp)
    if dmvsAutoMacroState.Busy or not dmvsAutoMacroState.Enabled or not dmvsAutoMacroTargetValid(tp) then return end
    dmvsAutoMacroState.Busy = true
    task.spawn(function()
        local c = player.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local gun = nil
        pcall(function()
            if not c or not h or h.Health <= 0 then return end
            local eq = c:FindFirstChildOfClass("Tool")
            if eq and not isGun(eq) then return end
            gun = eq and isGun(eq) and eq or getGun()
            if not gun or not isGun(gun) then return end
            dmvsAutoMacroState.ManagedGun = gun
            dmvsAutoMacroState.CurrentTarget = tp
            if gun.Parent ~= c then
                h:UnequipTools(); task.wait()
                if not dmvsAutoMacroState.Enabled or not dmvsAutoMacroTargetValid(tp) then return end
                h:EquipTool(gun); task.wait(dmvsAutoMacroState.EquipDelay)
            end
            if not dmvsAutoMacroState.Enabled or gun.Parent ~= c or not dmvsAutoMacroTargetValid(tp) then return end
            dmvsAutoMacroState.CurrentTarget = tp
            gun:Activate(); task.wait(dmvsAutoMacroState.ShootDelay)
        end)
        dmvsAutoMacroCleanupGun(gun, c, h)
        dmvsAutoMacroState.CurrentTarget = nil
        dmvsAutoMacroState.ManagedGun = nil
        dmvsAutoMacroState.Busy = false
    end)
end
task.spawn(function()
    while not dmvsDestroyed do
        if dmvsAutoMacroState.Enabled and not dmvsAutoMacroState.Busy then
            local t = dmvsAutoMacroGetTarget()
            if t then dmvsAutoMacroRunCycle(t) end
        end
        task.wait(dmvsAutoMacroState.ScanDelay)
    end
end)

-- ============ ANIMATIONS ============
local animationData = {
    ["Old School"] = { Walk = 10921244891, Run = 10921240218, Jump = 10921242013, Fall = 10921241244, SwimIdle = 10921244018, Swim = 10921243048, Idle = 10921230744, Idle2 = 10921232093, Climb = 10921229866 },
    ["Adidas Sports"] = { Walk = 18537392113, Run = 18537384940, Jump = 18537380791, Fall = 18537367238, SwimIdle = 18537387180, Swim = 18537389531, Idle = 18537376492, Idle2 = 18537371272, Climb = 18537363391 },
    ["Adidas Community"] = { Walk = 122150855457006, Run = 82598234841035, Jump = 75290611992385, Fall = 98600215928904, SwimIdle = 109346520324160, Swim = 133308483266208, Idle = 122257458498464, Idle2 = 102357151005774, Climb = 88763136693023 },
    ["Adidas Aura"] = { Walk = 83842218823011, Run = 118320322718866, Jump = 109996626521204, Fall = 95603166884636, SwimIdle = 94922130551805, Swim = 134530128383903, Idle = 110211186840347, Idle2 = 114191137265065, Climb = 97824616490448 },
    ["Wicked Popular"] = { Walk = 92072849924640, Run = 72301599441680, Jump = 104325245285198, Fall = 121152442762481, Idle = 118832222982049, Idle2 = 76049494037641, SwimIdle = 113199415118199, Swim = 99384245425157, Climb = 131326830509784 },
    ["Elder"] = { Walk = 10921111375, Run = 10921104374, Jump = 10921107367, Fall = 10921105765, SwimIdle = 10921110146, Swim = 10921108971, Idle = 10921101664, Idle2 = 10921102574, Climb = 10921100400 },
    ["Zombie"] = { Walk = 10921355261, Run = 616163682, Jump = 10921351278, Fall = 10921350320, SwimIdle = 10921353442, Swim = 10921352344, Idle = 10921344533, Idle2 = 10921345304, Climb = 10921343576 },
    ["Mage"] = { Walk = 10921152678, Run = 10921148209, Jump = 10921149743, Fall = 10921148939, SwimIdle = 10921151661, Swim = 10921150788, Idle = 10921144709, Idle2 = 10921145797, Climb = 10921143404 },
    ["Catwalk Glam"] = { Walk = 109168724482748, Run = 81024476153754, Jump = 116936326516985, Fall = 92294537340807, SwimIdle = 98854111361360, Swim = 134591743181628, Idle = 133806214992291, Idle2 = 94970088341563, Climb = 119377220967554 },
    ["Astronaut"] = { Walk = 10921046031, Run = 10921039308, Jump = 10921042494, Fall = 10921040576, SwimIdle = 10921045006, Swim = 10921044000, Idle = 10921034824, Idle2 = 10921036806, Climb = 10921032124 },
    ["Werewolf"] = { Walk = 10921342074, Run = 10921336997, Jump = 10921339274, Fall = 10921337907, SwimIdle = 10921341319, Swim = 10921340419, Idle = 10921330408, Idle2 = 10921333667, Climb = 10921329322 },
    ["Superhero"] = { Walk = 10921298616, Run = 10921291831, Jump = 10921294559, Fall = 10921293273, SwimIdle = 10921297391, Swim = 10921295495, Idle = 10921288909, Idle2 = 10921290167, Climb = 10921286911 },
    ["Toy"] = { Walk = 10921312010, Run = 10921306285, Jump = 10921308158, Fall = 10921307241, SwimIdle = 10921310341, Swim = 10921309319, Idle = 10921301576, Climb = 10921300839 },
    ["No Boundaries"] = { Walk = 18747074203, Run = 18747070484, Jump = 18747069148, Fall = 18747062535, SwimIdle = 18747071682, Swim = 18747073181, Idle = 18747067405, Idle2 = 18747063918, Climb = 18747060903 },
    ["NFL"] = { Walk = 110358958299415, Run = 117333533048078, Jump = 119846112151352, Fall = 129773241321032, SwimIdle = 79090109939093, Swim = 132697394189921, Idle = 92080889861410, Idle2 = 74451233229259, Climb = 134630013742019 },
    ["Amazon Unboxed"] = { Walk = 90478085024465, Run = 134824450619865, Jump = 121454505477205, Fall = 94788218468396, SwimIdle = 129126268464847, Swim = 105962919001086, Idle = 98281136301627, Climb = 121145883950231 },
    ["Vampire"] = { Walk = 10921326949, Run = 10921320299, Jump = 10921322186, Fall = 10921321317, SwimIdle = 10921325443, Swim = 10921324408, Idle = 10921315373, Climb = 10921314188 },
    ["Ninja"] = { Walk = 656121766, Run = 656118852, Jump = 656117878, Fall = 656115606, SwimIdle = 656121397, Swim = 656119721, Idle = 656117400, Idle2 = 656118341, Climb = 656114359 },
    ["Robot"] = { Walk = 616095330, Run = 616091570, Jump = 616090535, Fall = 616087089, SwimIdle = 616094091, Swim = 616092998, Idle = 616088211, Idle2 = 616089559, Climb = 616086039 },
    ["Levitation"] = { Walk = 616013216, Run = 616010382, Jump = 616008936, Fall = 616005863, SwimIdle = 616012453, Swim = 616011509, Idle = 616006778, Idle2 = 616008087, Climb = 616003713 },
    ["Stylish"] = { Walk = 616146177, Run = 616140816, Jump = 616139451, Fall = 616134815, SwimIdle = 616144772, Swim = 616143378, Idle = 616136790, Idle2 = 616138447, Climb = 616133594 },
    ["Bubbly"] = { Walk = 910034870, Run = 910025107, Jump = 910016857, Fall = 910001910, SwimIdle = 910030921, Swim = 910028158, Idle = 910004836, Idle2 = 910009958, Climb = 909997997 },
    ["Cartoon"] = { Walk = 742640026, Run = 742638842, Jump = 742637942, Fall = 742637151, SwimIdle = 742639812, Swim = 742639220, Idle = 742637544, Idle2 = 742638445, Climb = 742636889 }
}
local currentActiveAnim = nil
local myOriginalAnims = nil
local animationCharacter = nil
local animationApplyInProgress = false
local animationBindings = {
    {Key="Idle",Folder="idle",Name="Animation1"},{Key="Idle2",Folder="idle",Name="Animation2"},
    {Key="Walk",Folder="walk",Name="WalkAnim"},{Key="Run",Folder="run",Name="RunAnim"},
    {Key="Jump",Folder="jump",Name="JumpAnim"},{Key="Climb",Folder="climb",Name="ClimbAnim"},
    {Key="Fall",Folder="fall",Name="FallAnim"},{Key="Swim",Folder="swim",Name="Swim"},
    {Key="SwimIdle",Folder="swimidle",Name="SwimIdle"}
}
local function clearAllAnimations(h)
    if not h then return end
    for _, t in ipairs(h:GetPlayingAnimationTracks()) do
        pcall(function() t:Stop(0) end); pcall(function() t:Destroy() end)
    end
    task.wait(0.05)
end
local function getAnimationId(a) if not a or not a:IsA("Animation") then return nil end return a.AnimationId:match("%d+") end
local function getAnimationObject(an, b)
    local f = an and an:FindFirstChild(b.Folder); return f and f:FindFirstChild(b.Name)
end
local function animationStateMatches(cd, an)
    if not cd or not an then return false end
    for _, b in ipairs(animationBindings) do
        local d = cd[b.Key]
        if b.Key == "Idle2" and not d then d = cd.Idle
        elseif b.Key == "SwimIdle" and not d then d = cd.Swim end
        if d then
            local c = getAnimationId(getAnimationObject(an, b))
            if c ~= tostring(d) then return false end
        end
    end
    return true
end
local function hasPlayingAnimation(h)
    for _, t in ipairs(h:GetPlayingAnimationTracks()) do if t.IsPlaying then return true end end
    return false
end
local function applyCustomAnims(cd)
    if not cd or animationApplyInProgress then return end
    local c = player.Character; if not c then return end
    local an = c:FindFirstChild("Animate"); local h = c:FindFirstChildOfClass("Humanoid")
    if not an or not h then return end
    animationApplyInProgress = true
    pcall(function()
        if animationCharacter ~= c then animationCharacter = c; myOriginalAnims = nil end
        if not myOriginalAnims then
            local function g(fn, an2)
                local f = an:FindFirstChild(fn); local a = f and f:FindFirstChild(an2)
                local id = getAnimationId(a); return id and tonumber(id) or nil
            end
            myOriginalAnims = {
                Idle = g("idle","Animation1") or 507766666,
                Idle2 = g("idle","Animation2") or 507766951,
                Walk = g("walk","WalkAnim") or 507777826,
                Run = g("run","RunAnim") or 507767714,
                Jump = g("jump","JumpAnim") or 507765000,
                Climb = g("climb","ClimbAnim") or 507765644,
                Fall = g("fall","FallAnim") or 507767968,
                Swim = g("swim","Swim") or 507784897,
                SwimIdle = g("swimidle","SwimIdle") or 507785072
            }
        end
        an.Disabled = true
        clearAllAnimations(h)
        local function u(fn, an2, id)
            if not id then return end
            local f = an:FindFirstChild(fn); local a = f and f:FindFirstChild(an2)
            if a and a:IsA("Animation") then a.AnimationId = "rbxassetid://" .. tostring(id) end
        end
        u("idle","Animation1", cd.Idle); u("idle","Animation2", cd.Idle2 or cd.Idle)
        u("walk","WalkAnim", cd.Walk); u("run","RunAnim", cd.Run)
        u("jump","JumpAnim", cd.Jump); u("climb","ClimbAnim", cd.Climb)
        u("fall","FallAnim", cd.Fall); u("swim","Swim", cd.Swim)
        u("swimidle","SwimIdle", cd.SwimIdle or cd.Swim)
        task.wait(0.05)
        an.Disabled = false
        h:ChangeState(Enum.HumanoidStateType.Landed); task.wait(0.05)
        h:ChangeState(Enum.HumanoidStateType.Running)
    end)
    if not pcall(function() return an.Parent end) then an.Disabled = false end
    animationApplyInProgress = false
end
task.spawn(function()
    while not dmvsDestroyed and task.wait(0.35) do
        local cd = currentActiveAnim
        local c = player.Character; local h = c and c:FindFirstChildOfClass("Humanoid")
        local an = c and c:FindFirstChild("Animate")
        if cd and h and h.Health > 0 and an and not animationApplyInProgress then
            if not animationStateMatches(cd, an) or not hasPlayingAnimation(h) then applyCustomAnims(cd) end
        end
    end
end)
local animList = {"None"}
for name in pairs(animationData) do table.insert(animList, name) end
table.sort(animList)
local mixParts = {Idle="None", Walk="None", Run="None", Jump="None", Fall="None", Climb="None"}
local autoMixApplyEnabled = false
local function applySelectedMix()
    local cd = {}
    if mixParts.Idle ~= "None" then cd.Idle = animationData[mixParts.Idle].Idle; cd.Idle2 = animationData[mixParts.Idle].Idle2 end
    if mixParts.Walk ~= "None" then cd.Walk = animationData[mixParts.Walk].Walk end
    if mixParts.Run ~= "None" then cd.Run = animationData[mixParts.Run].Run end
    if mixParts.Jump ~= "None" then cd.Jump = animationData[mixParts.Jump].Jump end
    if mixParts.Fall ~= "None" then cd.Fall = animationData[mixParts.Fall].Fall end
    if mixParts.Climb ~= "None" then cd.Climb = animationData[mixParts.Climb].Climb end
    local hv = false
    for _, v in pairs(cd) do if v then hv = true break end end
    if hv then currentActiveAnim = cd; task.spawn(function() applyCustomAnims(cd) end) end
end

-- ============ SKYBOX / RTX ============
local originalSky = Lighting:FindFirstChildOfClass("Sky") and Lighting:FindFirstChildOfClass("Sky"):Clone() or nil
local originalAtmospheres = {}
for _, o in ipairs(Lighting:GetChildren()) do if o:IsA("Atmosphere") then table.insert(originalAtmospheres, o:Clone()) end end
local terrain = workspace:FindFirstChildOfClass("Terrain")
local originalClouds = terrain and terrain:FindFirstChildOfClass("Clouds") and terrain:FindFirstChildOfClass("Clouds"):Clone() or nil
originalLightingState = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    ExposureCompensation = Lighting.ExposureCompensation, FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd, FogColor = Lighting.FogColor, Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient, ColorShift_Top = Lighting.ColorShift_Top,
    ColorShift_Bottom = Lighting.ColorShift_Bottom, EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale, ShadowSoftness = Lighting.ShadowSoftness,
    GlobalShadows = Lighting.GlobalShadows
}
originalPostEffects = {}
for _, o in ipairs(Lighting:GetChildren()) do
    if o:IsA("BloomEffect") or o:IsA("ColorCorrectionEffect") or o:IsA("SunRaysEffect") or o:IsA("DepthOfFieldEffect") then
        table.insert(originalPostEffects, o:Clone())
    end
end

skyboxData = {
    Twilight = {"264908339","264907909","264909420","264909758","264908886","264907379"},
    Nebula = {"159454299","159454296","159454293","159454286","159454300","159454288"},
    Vaporwave = {"1417494030","1417494146","1417494253","1417494402","1417494499","1417494643"},
    Redshift = {"401664839","401664862","401664960","401664881","401664901","401664936"},
    ["Blue Stars"] = {"149397684","149397686","149397688","149397692","149397697","149397702"},
    ["Sakura Pink Sky"] = {"271042516","271077243","271042556","271042310","271042467","271077958"},
    Default = {"591058823","591059876","591058104","591057861","591057625","591059642"},
    Desert = {"1013852","1013853","1013850","1013851","1013849","1013854"},
    DaBaby = {"7245418472","7245418472","7245418472","7245418472","7245418472","7245418472"},
    Minecraft = {"1876545003","1876544331","1876542941","1876543392","1876543764","1876544642"},
    SpongeBob = {"7633178166","7633178166","7633178166","7633178166","7633178166","7633178166"},
    Skibidi = {"14952256113","14952256113","14952256113","14952256113","14952256113","14952256113"},
    Blaze = {"150939022","150939038","150939047","150939056","150939063","150939082"},
    ["Pussy Cat"] = {"11154422902","11154422902","11154422902","11154422902","11154422902","11154422902"},
    ["Among Us"] = {"5752463190","5752463190","5752463190","5752463190","5752463190","5752463190"},
    ["Space Wave"] = {"16262356578","16262358026","16262360469","16262362003","16262363873","16262366016"},
    ["Space Wave 2"] = {"1233158420","1233158838","1233157105","1233157640","1233157995","1233159158"},
    ["Turquoise Wave"] = {"47974894","47974690","47974821","47974776","47974859","47974909"},
    ["Dark Night"] = {"6285719338","6285721078","6285722964","6285724682","6285726335","6285730635"},
    ["White Galaxy"] = {"5540798456","5540799894","5540801779","5540801192","5540799108","5540800635"}
}
skyboxOrder = {"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}
skyboxNames = {"Original"}
for name in pairs(skyboxData) do table.insert(skyboxNames, name) end
table.sort(skyboxNames, function(a, b)
    if a == "Original" then return true end
    if b == "Original" then return false end
    return a < b
end)
ContentProvider = game:GetService("ContentProvider")
skyboxRequestId = 0

function clearSkyboxes()
    for _, o in ipairs(Lighting:GetChildren()) do
        if o:IsA("Sky") then
            for _, p in ipairs(skyboxOrder) do pcall(function() o[p] = "" end) end
            o.Parent = nil; pcall(function() o:Destroy() end)
        elseif o:IsA("Atmosphere") then pcall(function() o:Destroy() end) end
    end
    if terrain then
        for _, o in ipairs(terrain:GetChildren()) do
            if o:IsA("Clouds") then pcall(function() o:Destroy() end) end
        end
    end
end
function restoreSkybox()
    skyboxRequestId = skyboxRequestId + 1
    clearSkyboxes()
    if originalSky then originalSky:Clone().Parent = Lighting end
    for _, a in ipairs(originalAtmospheres) do a:Clone().Parent = Lighting end
    if originalClouds and terrain then originalClouds:Clone().Parent = terrain end
end
function applySkybox(name)
    if name == "Original" then restoreSkybox(); return true end
    local data = skyboxData[name]
    if not data then return false end
    local sky = Instance.new("Sky"); sky.Name = "DMVS_Skybox"
    sky.CelestialBodiesShown = false; sky.StarCount = 0
    for i, p in ipairs(skyboxOrder) do sky[p] = "rbxassetid://" .. data[i] end
    pcall(function() ContentProvider:PreloadAsync({sky}) end)
    clearSkyboxes()
    sky.Parent = Lighting
    return true
end
function requestSkybox(name)
    skyboxRequestId = skyboxRequestId + 1
    task.spawn(function()
        local ok = applySkybox(name)
        if ok then notify({Message = "Skybox: "..name, Type = "done"}) end
    end)
end

rtxPresets = {
    Cinematic = {
        Brightness = 2, Exposure = -0.05, ClockTime = 17.4,
        Ambient = Color3.fromRGB(72,72,82), OutdoorAmbient = Color3.fromRGB(100,93,112),
        Bloom = {Intensity=0.55, Size=40, Threshold=1},
        Color = {Brightness=-0.01, Contrast=0.28, Saturation=-0.08, TintColor=Color3.fromRGB(255,225,205)},
        Rays = {Intensity=0.12, Spread=0.8},
        Depth = {FarIntensity=0.08, FocusDistance=45, InFocusRadius=32, NearIntensity=0.15}
    },
    Performance = {
        Brightness = 2, Exposure = 0, ClockTime = 14,
        Ambient = Color3.fromRGB(100,100,100), OutdoorAmbient = Color3.fromRGB(128,128,128),
        Color = {Brightness=0, Contrast=0.08, Saturation=0.05, TintColor=Color3.fromRGB(255,255,255)}
    }
}
function clearPostEffects()
    for _, o in ipairs(Lighting:GetChildren()) do
        if o:IsA("BloomEffect") or o:IsA("ColorCorrectionEffect") or o:IsA("SunRaysEffect") or o:IsA("DepthOfFieldEffect") then
            o:Destroy()
        end
    end
end
function applyProperties(o, p) for k, v in pairs(p) do o[k] = v end end
function restoreRTX()
    clearPostEffects()
    for k, v in pairs(originalLightingState) do Lighting[k] = v end
    for _, e in ipairs(originalPostEffects) do e:Clone().Parent = Lighting end
end
function applyRTX(name)
    if name == "Original" then restoreRTX(); return end
    local p = rtxPresets[name]; if not p then return end
    clearPostEffects()
    Lighting.Brightness = p.Brightness; Lighting.ExposureCompensation = p.Exposure
    Lighting.ClockTime = p.ClockTime; Lighting.Ambient = p.Ambient
    Lighting.OutdoorAmbient = p.OutdoorAmbient
    Lighting.EnvironmentDiffuseScale = 1; Lighting.EnvironmentSpecularScale = 1
    Lighting.ShadowSoftness = 0.18; Lighting.GlobalShadows = true
    if p.Bloom then local e = Instance.new("BloomEffect"); applyProperties(e, p.Bloom); e.Name = "DMVS_RTX_Bloom"; e.Parent = Lighting end
    if p.Color then local e = Instance.new("ColorCorrectionEffect"); applyProperties(e, p.Color); e.Name = "DMVS_RTX_Color"; e.Parent = Lighting end
    if p.Rays then local e = Instance.new("SunRaysEffect"); applyProperties(e, p.Rays); e.Name = "DMVS_RTX_Rays"; e.Parent = Lighting end
    if p.Depth then local e = Instance.new("DepthOfFieldEffect"); applyProperties(e, p.Depth); e.Name = "DMVS_RTX_Depth"; e.Parent = Lighting end
end

-- ============ NAME CHANGER ============
nameState = {
    myUsernameEnabled = false, otherNamesEnabled = false, replacementName = "SZK",
    playerNameMap = {}, fakeNames = {}, playerConnections = {}, nextFakeNameId = 1,
    trackedElements = setmetatable({}, {__mode="k"}),
    originalTextByElement = setmetatable({}, {__mode="k"}),
    renderedTextByElement = setmetatable({}, {__mode="k"}),
    elementConnections = setmetatable({}, {__mode="k"}),
    elementUpdating = setmetatable({}, {__mode="k"}),
    containerConnections = {}, cachedReplacementPairs = nil
}
function invalidateNameReplacementCache() nameState.cachedReplacementPairs = nil end
function escapeNamePattern(t) return string.gsub(t, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") end
function isNameTextElement(e) return e:IsA("TextLabel") or e:IsA("TextButton") or e:IsA("TextBox") end
function rebuildOtherPlayerNameMap()
    nameState.playerNameMap = {}
    for _, tp in ipairs(Players:GetPlayers()) do
        if tp ~= player then
            local fn = nameState.fakeNames[tp]
            if not fn then fn = "SZK #"..tostring(nameState.nextFakeNameId); nameState.nextFakeNameId = nameState.nextFakeNameId + 1; nameState.fakeNames[tp] = fn end
            if tp.Name and tp.Name ~= "" then nameState.playerNameMap[tp.Name] = fn end
            if tp.DisplayName and tp.DisplayName ~= "" then nameState.playerNameMap[tp.DisplayName] = fn end
        end
    end
    invalidateNameReplacementCache()
end
function getNameReplacementPairs()
    if nameState.cachedReplacementPairs then return nameState.cachedReplacementPairs end
    local r = {}; local seen = {}
    local function add(o, f)
        if o and o ~= "" and not seen[o] then seen[o] = true; table.insert(r, {Original=o, Replacement=f}) end
    end
    if nameState.myUsernameEnabled then add(player.Name, nameState.replacementName); add(player.DisplayName, nameState.replacementName) end
    if nameState.otherNamesEnabled then for o, f in pairs(nameState.playerNameMap) do add(o, f) end end
    table.sort(r, function(a, b) return #a.Original > #b.Original end)
    nameState.cachedReplacementPairs = r
    return r
end
function transformNameText(t)
    local x = t
    for _, r in ipairs(getNameReplacementPairs()) do x = string.gsub(x, escapeNamePattern(r.Original), r.Replacement) end
    return x
end
function refreshNameElement(e)
    if not e or not e.Parent or not isNameTextElement(e) or nameState.elementUpdating[e] then return end
    local cur = e.Text; local orig = nameState.originalTextByElement[e]; local rend = nameState.renderedTextByElement[e]
    if orig == nil then orig = cur elseif rend ~= nil and cur ~= rend then orig = cur end
    nameState.originalTextByElement[e] = orig
    local tt = transformNameText(orig); nameState.renderedTextByElement[e] = tt
    if e.Text ~= tt then
        nameState.elementUpdating[e] = true
        pcall(function() e.Text = tt end)
        nameState.elementUpdating[e] = nil
    end
end
function refreshAllNameElements() for e in pairs(nameState.trackedElements) do refreshNameElement(e) end end
function trackNameElement(e)
    if not e or not e.Parent or not isNameTextElement(e) then return end
    nameState.trackedElements[e] = true
    if not nameState.elementConnections[e] then
        nameState.elementConnections[e] = e:GetPropertyChangedSignal("Text"):Connect(function() refreshNameElement(e) end)
    end
    refreshNameElement(e)
end
function scanNameContainer(c)
    if not c or nameState.containerConnections[c] then return end
    for _, e in ipairs(c:GetDescendants()) do trackNameElement(e) end
    nameState.containerConnections[c] = c.DescendantAdded:Connect(trackNameElement)
end
function registerOtherPlayer(tp)
    if tp == player then return end
    if not nameState.fakeNames[tp] then
        nameState.fakeNames[tp] = "SZK #"..tostring(nameState.nextFakeNameId)
        nameState.nextFakeNameId = nameState.nextFakeNameId + 1
    end
    if not nameState.playerConnections[tp] then
        nameState.playerConnections[tp] = tp:GetPropertyChangedSignal("DisplayName"):Connect(function()
            rebuildOtherPlayerNameMap(); refreshAllNameElements()
        end)
    end
end
for _, tp in ipairs(Players:GetPlayers()) do registerOtherPlayer(tp) end
rebuildOtherPlayerNameMap()
Players.PlayerAdded:Connect(function(tp) registerOtherPlayer(tp); rebuildOtherPlayerNameMap(); refreshAllNameElements() end)
Players.PlayerRemoving:Connect(function(tp)
    nameState.fakeNames[tp] = nil
    nameState.playerNameMap[tp.Name] = nil
    nameState.playerNameMap[tp.DisplayName] = nil
    invalidateNameReplacementCache()
    local c = nameState.playerConnections[tp]
    if c then c:Disconnect(); nameState.playerConnections[tp] = nil end
    refreshAllNameElements()
end)
for _, c in ipairs({playerGui, game:GetService("CoreGui"), workspace}) do
    task.spawn(function() pcall(function() scanNameContainer(c) end) end)
end

-- ============ WINDOW ============
local Window = WindUI:CreateWindow({
    Title = "SZK - DMVS",
    Author = "Made by SZK",
    Folder = "SZKWINDUI",
    ConfigName = "SZKWIND UI",
    Theme = "Graphite",
    Size = UDim2.fromOffset(520, 405),
    MinSize = Vector2.new(440, 335),
    MaxSize = Vector2.new(650, 500),
    Icon = "rbxassetid://132065937809574",
    IconThemed = true,
    Background = "rbxassetid://85148301875362",
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
        Enabled = true, Title = "SZK - DMVS", Icon = "rbxassetid://132065937809574",
        OnlyMobile = false, Draggable = true, Scale = 0.82, StrokeThickness = 1,
        Color = ColorSequence.new(Color3.fromRGB(118,118,124), Color3.fromRGB(164,164,170))
    }
})

local targetPartOptions = {"Head","Torso","Full Body"}
local lightingOptions = {"Original","Cinematic","Performance"}

-- ============ TAB: HOME ============
;(function()
    local homeTab = Window:Tab({Title = "Home", Icon = "house", ShowTabTitle = true, Border = true})
    local gameName = "Unknown Game"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info and info.Name then gameName = info.Name end
    end)
    homeTab:Divider({Title = "Welcome to SZKHUB"})
    local avatarUrl = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    local avatarShown = false
    pcall(function()
        if type(homeTab.Image) == "function" then
            homeTab:Image({ Image = avatarUrl, Height = 100, Callback = function() end })
            avatarShown = true
        end
    end)
    if not avatarShown then homeTab:Paragraph({Title = "Avatar: " .. avatarUrl}) end
    homeTab:Paragraph({Title = "Welcome, " .. player.DisplayName .. "!"})
    homeTab:Paragraph({Title = "SZKHUB"})
    homeTab:Divider({Title = "Session Info"})
    local gameIconUrl = "rbxthumb://type=GameIcon&id=" .. game.PlaceId .. "&w=150&h=150"
    local gameIconShown = false
    pcall(function()
        if type(homeTab.Image) == "function" then
            homeTab:Image({ Image = gameIconUrl, Height = 100, Callback = function() end })
            gameIconShown = true
        end
    end)
    if not gameIconShown then homeTab:Paragraph({Title = "Game Icon: " .. gameIconUrl}) end
    homeTab:Paragraph({Title = "Game: " .. gameName})
    homeTab:Paragraph({Title = "Executor: " .. executorName})
    homeTab:Divider({Title = "Discord"})
    homeTab:Paragraph({Title = "We welcome you to come to our Discord server. Be active and read the rules!"})
    homeTab:Button({Title = "Join Discord Server", Callback = function()
        setclipboard("https://discord.gg/gxcA58cbWE")
        notify({Message = "Discord invite copied to clipboard!", Type = "done"})
    end})
    homeTab:Divider({Title = "Credits"})
    homeTab:Paragraph({Title = "Script: SZK - DMVS"})
    homeTab:Paragraph({Title = "Made by SZK"})
    homeTab:Paragraph({Title = "WIND UI Made by SZK"})
end)()

-- ============ TAB: INFORMATION ============
;(function()
    local WINDUI_URL = "https://raw.githubusercontent.com/ONYXHUB-X-SZK/SZKWINDUI/refs/heads/main/szk/lua/libary/wind%20ui/szkhub-libary.lua"
    local infoTab = Window:Tab({Title = "Information", Icon = "badge-info", ShowTabTitle = true, Border = true})
    infoTab:Divider({Title = "About"})
    infoTab:Paragraph({Title = "SZK - SZKHUB"})
    infoTab:Paragraph({Title = "Version: v1.0.0 | Game: Murderers vs Sheriffs Duels"})
    infoTab:Paragraph({Title = "Made by SZK"})
    infoTab:Divider({Title = "Communities"})
    infoTab:Button({Title = "Discord Server", Callback = function()
        setclipboard("https://discord.gg/gxcA58cbWE")
        notify({Message = "Discord link copied", Type = "done"})
    end})
    infoTab:Divider({Title = "Features"})
    infoTab:Paragraph({Title = "COMBAT"})
    infoTab:Paragraph({Title = "• Silent Aim (Q): Redirects your bullets to enemy."})
    infoTab:Paragraph({Title = "• Auto Shoot (E): Automatically shoots enemies."})
    infoTab:Paragraph({Title = "• Trigger Bot (T): Auto shoots when crosshair is on enemy."})
    infoTab:Paragraph({Title = "VISUAL"})
    infoTab:Paragraph({Title = "• ESP: Boxes + names + health + skeleton + tracer."})
    infoTab:Paragraph({Title = "• Change Names, Skybox, RTX, Environment."})
    infoTab:Divider({Title = "What is WindUI?"})
    infoTab:Paragraph({Title = "WindUI is a modern GUI library for Roblox, made by Synergy Team."})
    infoTab:Input({
        Title = "WindUI Raw URL", Flag = "WindUIUrl", Value = WINDUI_URL,
        Placeholder = WINDUI_URL, Callback = function() end
    })
    infoTab:Button({Title = "Copy WindUI URL", Callback = function()
        setclipboard(WINDUI_URL)
        notify({Message = "WindUI URL copied to clipboard!", Type = "done"})
    end})
end)()

-- ============ TAB: KEYBINDS ============
;(function()
    local tab = Window:Tab({Title = "Keybinds", Icon = "keyboard", ShowTabTitle = true, Border = true})
    tab:Divider({Title = "Interface"})
    local uiToggleKey = Enum.KeyCode.RightShift
    tab:Keybind({Title = "Toggle UI", Flag = "ToggleUIKB", Value = "RightShift", Callback = function(v)
        if v == "None" then uiToggleKey = nil
        else local k = typeof(v) == "EnumItem" and v or Enum.KeyCode[v]; if k then uiToggleKey = k end end
    end})
    tab:Divider({Title = "Feature Keybinds"})
    tab:Paragraph({Title = "Silent Aim = Q | Auto Shoot = E | Trigger Bot = T"})
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if uiToggleKey and input.KeyCode == uiToggleKey then
            if Window.Closed then Window:Open() else Window:Close(true) end
        end
    end)
end)()

-- ============ TAB: COMBAT (NUEVO) ============
;(function()
    local tab = Window:Tab({Title = "Combat", Icon = "crosshair", ShowTabTitle = true, Border = true})

    -- SILENT AIM
    tab:Divider({Title = "Silent Aim"})
    tab:Toggle({Title = "Enable Silent Aim", Flag = "SilentAimEnable", Value = false, Callback = function(v)
        Combat.SilentAim.Enabled = v; Combat.SilentAim._toggled = v
        if not v then genv.SZK_Target = nil end
    end})
    tab:Keybind({Title = "Keybind", Flag = "SilentAimKey", Value = "Q", Callback = function(v)
        if v == "None" then Combat.SilentAim.Keybind = nil
        else local k = typeof(v) == "EnumItem" and v or Enum.KeyCode[v]; if k then Combat.SilentAim.Keybind = k end end
    end})
    tab:Dropdown({Title = "Target Part", Flag = "SilentAimTarget", Values = targetPartOptions, Value = "Head",
        Callback = function(v) Combat.SilentAim.Target = (type(v) == "table" and v.Value or v) end})
    tab:Toggle({Title = "Use FOV Limit", Flag = "SilentAimFov", Value = true, Callback = function(v) Combat.SilentAim.UseFovLimit = v end})
    tab:Slider({Title = "FOV Size", Flag = "SilentAimFovSize", Value = {Min=10,Max=800,Default=300}, Step=1,
        Callback = function(v) Combat.SilentAim.FovSize = v end})
    tab:Toggle({Title = "Wall Check", Flag = "SilentAimWall", Value = true, Callback = function(v) Combat.SilentAim.WallCheck = v end})
    tab:Slider({Title = "Max Distance", Flag = "SilentAimDist", Value = {Min=100,Max=10000,Default=5000}, Step=50,
        Callback = function(v) Combat.SilentAim.MaxDistance = v end})

    -- AUTO SHOOT
    tab:Divider({Title = "Auto Shoot"})
    tab:Toggle({Title = "Enable Auto Shoot", Flag = "AutoShootEnable", Value = false, Callback = function(v)
        Combat.AutoShoot.Enabled = v; Combat.AutoShoot._toggled = v
    end})
    tab:Keybind({Title = "Keybind", Flag = "AutoShootKey", Value = "E", Callback = function(v)
        if v == "None" then Combat.AutoShoot.Keybind = nil
        else local k = typeof(v) == "EnumItem" and v or Enum.KeyCode[v]; if k then Combat.AutoShoot.Keybind = k end end
    end})
    tab:Dropdown({Title = "Target Part", Flag = "AutoShootTarget", Values = targetPartOptions, Value = "Head",
        Callback = function(v) Combat.AutoShoot.Target = (type(v) == "table" and v.Value or v) end})
    tab:Toggle({Title = "Use FOV Limit", Flag = "AutoShootFov", Value = true, Callback = function(v) Combat.AutoShoot.UseFovLimit = v end})
    tab:Slider({Title = "FOV Size", Flag = "AutoShootFovSize", Value = {Min=10,Max=800,Default=300}, Step=1,
        Callback = function(v) Combat.AutoShoot.FovSize = v end})
    tab:Toggle({Title = "Wall Check", Flag = "AutoShootWall", Value = true, Callback = function(v) Combat.AutoShoot.WallCheck = v end})
    tab:Slider({Title = "Max Distance", Flag = "AutoShootDist", Value = {Min=100,Max=10000,Default=5000}, Step=50,
        Callback = function(v) Combat.AutoShoot.MaxDistance = v end})
    tab:Slider({Title = "Shoot Delay", Flag = "AutoShootDelay", Value = {Min=0.05,Max=1.0,Default=0.15}, Step=0.01,
        Callback = function(v) Combat.AutoShoot.ShootDelay = v end})
    tab:Slider({Title = "Activate Time", Flag = "AutoShootAct", Value = {Min=0.01,Max=0.5,Default=0.05}, Step=0.01,
        Callback = function(v) Combat.AutoShoot.ActivateTime = v end})

    -- TRIGGER BOT
    tab:Divider({Title = "Trigger Bot"})
    tab:Toggle({Title = "Enable Trigger Bot", Flag = "TriggerBotEnable", Value = false, Callback = function(v)
        Combat.TriggerBot.Enabled = v; Combat.TriggerBot._toggled = v
    end})
    tab:Keybind({Title = "Keybind", Flag = "TriggerBotKey", Value = "T", Callback = function(v)
        if v == "None" then Combat.TriggerBot.Keybind = nil
        else local k = typeof(v) == "EnumItem" and v or Enum.KeyCode[v]; if k then Combat.TriggerBot.Keybind = k end end
    end})
    tab:Dropdown({Title = "Target Part", Flag = "TriggerBotTarget", Values = targetPartOptions, Value = "Head",
        Callback = function(v) Combat.TriggerBot.Target = (type(v) == "table" and v.Value or v) end})
    tab:Toggle({Title = "Auto Equip Gun", Flag = "TriggerBotAutoEquip", Value = true, Callback = function(v) Combat.TriggerBot.AutoEquip = v end})
    tab:Toggle({Title = "Auto Shoot", Flag = "TriggerBotAutoShoot", Value = true, Callback = function(v) Combat.TriggerBot.AutoShoot = v end})
    tab:Toggle({Title = "Unequip No Enemy", Flag = "TriggerBotUnequip", Value = true, Callback = function(v) Combat.TriggerBot.UnequipNoEnemy = v end})
    tab:Toggle({Title = "Use FOV Limit", Flag = "TriggerBotFov", Value = true, Callback = function(v) Combat.TriggerBot.UseFovLimit = v end})
    tab:Slider({Title = "FOV Size", Flag = "TriggerBotFovSize", Value = {Min=10,Max=800,Default=300}, Step=1,
        Callback = function(v) Combat.TriggerBot.FovSize = v end})
    tab:Toggle({Title = "Wall Check", Flag = "TriggerBotWall", Value = true, Callback = function(v) Combat.TriggerBot.WallCheck = v end})
    tab:Slider({Title = "Max Distance", Flag = "TriggerBotDist", Value = {Min=100,Max=10000,Default=5000}, Step=50,
        Callback = function(v) Combat.TriggerBot.MaxDistance = v end})
    tab:Slider({Title = "Shoot Delay", Flag = "TriggerBotDelay", Value = {Min=0.01,Max=0.5,Default=0.04}, Step=0.01,
        Callback = function(v) Combat.TriggerBot.ShootDelay = v end})
    tab:Slider({Title = "Activate Time", Flag = "TriggerBotAct", Value = {Min=0.01,Max=0.2,Default=0.02}, Step=0.01,
        Callback = function(v) Combat.TriggerBot.ActivateTime = v end})

    -- GLOBAL
    tab:Divider({Title = "Global"})
    tab:Toggle({Title = "Team Check (Global)", Flag = "GlobalTeamCheck", Value = true, Callback = function(v)
        teamCheckEnabled = v; enemyCache = {}; dmvsRefreshScoreboardTeams(true)
    end})
end)()

-- ============ TAB: HITBOX ============
;(function()
    local tab = Window:Tab({Title = "Hitbox", Icon = "box", ShowTabTitle = true, Border = true})
    tab:Divider({Title = "Hitbox"})
    tab:Toggle({Title = "Enable Hitbox", Flag = "HitboxEnable", Value = false, Callback = function(s)
        hitboxEnabled = s; if not s then clearAllHitboxes() end
    end})
    tab:Slider({Title = "Transparency", Flag = "HitboxTransparency", Value = {Min=0,Max=1,Default=0.7}, Step = 0.05,
        Callback = function(v)
            hitboxTransparency = v
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then
                    local h = plr.Character:FindFirstChild("GhostHitbox"); if h then h.Transparency = v end
                end
            end
        end})
    tab:Slider({Title = "Size", Flag = "HitboxSize", Value = {Min=3,Max=15,Default=10}, Step = 1,
        Callback = function(v)
            hitboxSizeValue = v; CustomHitboxSize = Vector3.new(v,v,v)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then
                    local h = plr.Character:FindFirstChild("GhostHitbox"); if h then h.Size = CustomHitboxSize end
                end
            end
        end})
end)()

-- ============ TAB: VISUAL (ESP NUEVO) ============
;(function()
    local tab = Window:Tab({Title = "Visual", Icon = "palette", ShowTabTitle = true, Border = true})

    tab:Divider({Title = "ESP - Player Visuals"})
    tab:Toggle({Title = "Enable ESP", Flag = "EspEnable", Value = false, Callback = function(s)
        SZK.ESP.Enabled = s; rebuildAllESP()
    end})
    tab:Toggle({Title = "Show Teammates", Flag = "EspShowTeammates", Value = false, Callback = function(s) SZK.ESP.ShowTeammates = s end})
    tab:Slider({Title = "Max Distance", Flag = "EspMaxDistance", Value = {Min=50,Max=5000,Default=2000}, Step = 50,
        Callback = function(v) SZK.ESP.MaxDistance = v end})
    tab:Toggle({Title = "Highlight", Flag = "EspHighlight", Value = true, Callback = function(s) SZK.ESP.Highlight = s end})
    tab:Toggle({Title = "Show Names", Flag = "EspShowNames", Value = true, Callback = function(s) SZK.ESP.Name = s end})
    tab:Toggle({Title = "Show Distance", Flag = "EspShowDistance", Value = true, Callback = function(s) SZK.ESP.Distance = s end})
    tab:Toggle({Title = "Show Health", Flag = "EspShowHealth", Value = true, Callback = function(s) SZK.ESP.Health = s end})
    tab:Toggle({Title = "Box", Flag = "EspBox", Value = true, Callback = function(s) SZK.ESP.Box = s end})
    tab:Toggle({Title = "Fill Box", Flag = "EspFillBox", Value = false, Callback = function(s) SZK.ESP.FillBox = s end})
    tab:Toggle({Title = "Head Dot", Flag = "EspHeadDot", Value = true, Callback = function(s) SZK.ESP.HeadDot = s end})
    tab:Toggle({Title = "Skeleton", Flag = "EspSkeleton", Value = false, Callback = function(s) SZK.ESP.Skeleton = s end})
    tab:Toggle({Title = "Tracer", Flag = "EspTracer", Value = false, Callback = function(s) SZK.ESP.Tracer = s end})
    tab:Dropdown({Title = "Tracer Origin", Flag = "EspTracerOrigin", Values = {"Bottom","Top","Center"}, Value = "Bottom",
        Callback = function(v) SZK.ESP.TracerOrigin = (type(v) == "table" and v.Value or v) end})

    tab:Divider({Title = "Change Names"})
    tab:Toggle({Title = "Change My Username", Flag = "ChangeMyUsername", Value = false,
        Callback = function(v) nameState.myUsernameEnabled = v; invalidateNameReplacementCache(); refreshAllNameElements() end})
    tab:Toggle({Title = "Change Other Player Names", Flag = "ChangeOtherPlayerNames", Value = false,
        Callback = function(v) nameState.otherNamesEnabled = v; invalidateNameReplacementCache(); refreshAllNameElements() end})

    tab:Divider({Title = "Skybox"})
    tab:Dropdown({Title = "Choose Skybox", Flag = "SkyboxDropdown", Values = skyboxNames, SearchBarEnabled = true, Value = "Original",
        Callback = function(name) requestSkybox(name) end})
    tab:Button({Title = "Restore Original Sky", Callback = function()
        restoreSkybox(); notify({Message = "Original sky restored.", Type = "done"})
    end})

    tab:Divider({Title = "RTX"})
    tab:Dropdown({Title = "Lighting Preset", Flag = "RTXPreset", Values = lightingOptions, Value = "Original",
        Callback = function(name)
            name = (type(name) == "table" and name.Value or name)
            applyRTX(name); notify({Message = "RTX: "..name, Type = "done"})
        end})
    tab:Button({Title = "Restore Original Visuals", Callback = function()
        restoreSkybox(); restoreRTX(); notify({Message = "Original visuals restored.", Type = "done"})
    end})

    tab:Divider({Title = "Environment"})
    tab:Slider({Title = "Time of Day", Flag = "VisualClockTime",
        Value = {Min=0,Max=24,Default=originalLightingState.ClockTime}, Step = 0.25,
        Callback = function(v) Lighting.ClockTime = v end})
    tab:Slider({Title = "Brightness", Flag = "VisualBrightness",
        Value = {Min=0,Max=6,Default=originalLightingState.Brightness}, Step = 0.1,
        Callback = function(v) Lighting.Brightness = v end})
    tab:Slider({Title = "Exposure", Flag = "VisualExposure",
        Value = {Min=-2,Max=2,Default=originalLightingState.ExposureCompensation}, Step = 0.05,
        Callback = function(v) Lighting.ExposureCompensation = v end})
    tab:Slider({Title = "Fog Distance", Flag = "VisualFogEnd",
        Value = {Min=100,Max=100000,Default=math.clamp(originalLightingState.FogEnd, 100, 100000)}, Step = 100,
        Callback = function(v) Lighting.FogEnd = v end})
    tab:Colorpicker({Title = "Ambient Color", Flag = "VisualAmbient", Color = originalLightingState.Ambient,
        Callback = function(c) Lighting.Ambient = c end})
end)()

-- ============ TAB: EXTRA ============
;(function()
    local tab = Window:Tab({Title = "Extra", Icon = "wand", ShowTabTitle = true, Border = true})

    -- BOOMBOX
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
    local Boombox = SoundService:FindFirstChild("SZK_boombox") or Instance.new("Sound", SoundService)
    Boombox.Name = "SZK_boombox"
    Boombox.Volume = 0.5
    Boombox.Looped = true
    Boombox.SoundId = BOOMBOX_SONGS[1].id
    local BoomboxState = {CurrentSong = BOOMBOX_SONGS[1].id, CurrentName = BOOMBOX_SONGS[1].name, Volume = 0.5, Loop = true, Playing = false}
    local songNames = {}
    for _, s in ipairs(BOOMBOX_SONGS) do songNames[#songNames+1] = s.name end

    tab:Divider({Title = "Boombox Player"})
    tab:Dropdown({Title = "Song", Flag = "BoomboxSong", Values = songNames, SearchBarEnabled = true, Value = BOOMBOX_SONGS[1].name,
        Callback = function(v)
            if type(v) == "table" then v = v.Value or v.Title end
            for _, s in ipairs(BOOMBOX_SONGS) do
                if s.name == v then
                    BoomboxState.CurrentSong = s.id; BoomboxState.CurrentName = s.name
                    if BoomboxState.Playing then Boombox.SoundId = s.id; Boombox:Play() end
                    notify({Message = "Song: "..s.name, Type = "info"})
                    break
                end
            end
        end})
    tab:Slider({Title = "Volume", Flag = "BoomboxVolume", Value = {Min=0,Max=100,Default=50}, Step = 1,
        Callback = function(v) BoomboxState.Volume = v/100; Boombox.Volume = BoomboxState.Volume end})
    tab:Toggle({Title = "Loop", Flag = "BoomboxLoop", Value = true, Callback = function(v) BoomboxState.Loop = v; Boombox.Looped = v end})
    tab:Button({Title = "Play", Callback = function()
        Boombox.SoundId = BoomboxState.CurrentSong; Boombox.Volume = BoomboxState.Volume
        Boombox.Looped = BoomboxState.Loop; Boombox:Play(); BoomboxState.Playing = true
        notify({Message = "Playing: "..BoomboxState.CurrentName, Type = "done"})
    end})
    tab:Button({Title = "Pause", Callback = function() Boombox:Pause(); notify({Message = "Paused", Type = "info"}) end})
    tab:Button({Title = "Stop", Callback = function() Boombox:Stop(); BoomboxState.Playing = false; notify({Message = "Stopped", Type = "info"}) end})

    -- BACKGROUND CHANGER
    local BG_LIST = {
        {name="Background 1",id="rbxassetid://127475690425531"},{name="Background 2",id="rbxassetid://138242673369180"},
        {name="Background 3",id="rbxassetid://70609842395967"},{name="Background 4",id="rbxassetid://81053303516002"},
        {name="Background 5",id="rbxassetid://130691930643174"},{name="Background 6",id="rbxassetid://135414401061463"},
        {name="Background 7",id="rbxassetid://88751579241211"},{name="Background 8",id="rbxassetid://104239381391061"},
        {name="Background 9",id="rbxassetid://99224315720440"},{name="Background 10",id="rbxassetid://75102853478391"},
        {name="Background 11",id="rbxassetid://102574649815324"},{name="Background 12",id="rbxassetid://97823921818913"},
        {name="Background 13",id="rbxassetid://129712892318094"},{name="Background 14",id="rbxassetid://77327983749206"},
        {name="Background 15",id="rbxassetid://70967429484455"},
    }
    local DEFAULT_BG = "rbxassetid://85148301875362"
    local bgNames = {}
    for _, b in ipairs(BG_LIST) do bgNames[#bgNames+1] = b.name end

    tab:Divider({Title = "Background Changer"})
    tab:Dropdown({Title = "Menu Background", Flag = "MenuBgSelect", Values = bgNames, SearchBarEnabled = true, Value = "Background 5",
        Callback = function(v)
            if type(v) == "table" then v = v.Value or v.Title end
            for _, b in ipairs(BG_LIST) do
                if b.name == v then
                    Window:SetBackgroundImage(b.id); Window:SetBackgroundImageTransparency(0)
                    notify({Message = v.." applied", Type = "done"})
                    break
                end
            end
        end})
    tab:Button({Title = "Reset Background", Callback = function()
        Window:SetBackgroundImage(DEFAULT_BG); Window:SetBackgroundImageTransparency(0.22)
        notify({Message = "Default background restored", Type = "done"})
    end})

    -- MACRO
    tab:Divider({Title = "Macro (Gun)"})
    tab:Toggle({Title = "Enable Macro", Flag = "MacroEnable", Value = false, Callback = function(s) macroActive = s end})
    tab:Slider({Title = "Equip Delay", Flag = "MacroEquipDelay", Value = {Min=0.01,Max=0.50,Default=0.04}, Step = 0.01,
        Callback = function(v) macroEquipDelay = v end})
    tab:Slider({Title = "Shoot Delay", Flag = "MacroShootDelay", Value = {Min=0.05,Max=0.80,Default=0.10}, Step = 0.01,
        Callback = function(v) macroShootDelay = v end})

    -- AUTO MACRO 360
    tab:Divider({Title = "Auto Macro 360"})
    tab:Toggle({Title = "Auto Macro 360", Flag = "AutoMacro360Enabled", Value = false, Callback = function(v)
        dmvsAutoMacroState.Enabled = v
        if not v then
            dmvsAutoMacroState.CurrentTarget = nil
            if dmvsAutoMacroState.ManagedGun then
                local c = player.Character; local h = c and c:FindFirstChildOfClass("Humanoid")
                dmvsAutoMacroCleanupGun(dmvsAutoMacroState.ManagedGun, c, h)
            end
        end
    end})
    tab:Dropdown({Title = "Target Part", Flag = "AutoMacro360TargetPart", Values = targetPartOptions, Value = "Head",
        Callback = function(v) dmvsAutoMacroState.TargetPart = (type(v) == "table" and v.Value or v) end})
    tab:Slider({Title = "360 Range", Flag = "AutoMacro360Range", Value = {Min=25,Max=500,Default=250}, Step = 5,
        Callback = function(v) dmvsAutoMacroState.Range = v end})
    tab:Toggle({Title = "Team Check", Flag = "AutoMacro360TeamCheck", Value = true, Callback = function(v) dmvsAutoMacroState.TeamCheck = v end})
    tab:Toggle({Title = "Wall Check", Flag = "AutoMacro360WallCheck", Value = true, Callback = function(v) dmvsAutoMacroState.WallCheck = v end})
    tab:Slider({Title = "Scan Delay", Flag = "AutoMacro360ScanDelay", Value = {Min=0.01,Max=0.25,Default=0.03}, Step = 0.01,
        Callback = function(v) dmvsAutoMacroState.ScanDelay = v end})

    -- KILL SOUND
    tab:Divider({Title = "Kill Sound"})
    tab:Toggle({Title = "Kill Sound", Flag = "KillSoundEnabled", Value = false, Callback = function(v) dmvsKillSoundState.Enabled = v end})
    tab:Dropdown({Title = "Sound", Flag = "KillSoundSelection", Values = dmvsKillSoundState.Options, Value = "Among Us",
        Callback = function(v)
            if type(v) == "table" then v = v.Value or v.Title end
            if dmvsKillSoundState.Assets[v] then dmvsKillSoundState.Selected = v end
        end})

    -- LOOP TP
    tab:Divider({Title = "LoopTP"})
    dmvsBuildLoopTPPlayerList()
    dmvsLoopTPDropdown = tab:Dropdown({
        Title = "Player", Flag = "LoopTPPlayer", Values = dmvsLoopTPState.Options,
        SearchBarEnabled = true, Value = dmvsLoopTPState.Selected,
        Callback = function(v)
            if type(v) == "table" then v = v.Value or v.Title end
            if type(v) == "string" and Players:FindFirstChild(v) and v ~= player.Name then dmvsLoopTPState.Selected = v end
        end})
    tab:Button({Title = "Refresh Players", Callback = function() dmvsRefreshLoopTPPlayers() end})
    tab:Toggle({Title = "LoopTP", Flag = "LoopTPEnabled", Value = false, Callback = function(v) dmvsLoopTPState.Enabled = v end})

    -- DEAD ZONE
    tab:Divider({Title = "Dead Zone"})
    tab:Toggle({Title = "Show/Adjust Dead Zone", Flag = "DeadZoneVisible", Value = false, Callback = function(s) deadZoneFrame.Visible = s end})
    tab:Slider({Title = "Dead Zone Size", Flag = "DeadZoneSize", Value = {Min=80,Max=400,Default=150}, Step = 1,
        Callback = function(v) deadZoneFrame.Size = UDim2.new(0, v, 0, v) end})
end)()

-- ============ TAB: ANIMATIONS ============
;(function()
    local tab = Window:Tab({Title = "Animations", Icon = "person-standing", ShowTabTitle = true, Border = true})
    tab:Divider({Title = "Full Animation Packs"})
    local selectedFullBundle = "None"
    tab:Dropdown({Title = "Choose Pack", Flag = "AnimPack", Values = animList, SearchBarEnabled = true, Value = "None",
        Callback = function(v) selectedFullBundle = v end})
    tab:Button({Title = "Apply Full Pack", Callback = function()
        if selectedFullBundle == "None" then return end
        task.spawn(function() currentActiveAnim = animationData[selectedFullBundle]; applyCustomAnims(currentActiveAnim) end)
    end})
    tab:Button({Title = "Restore Default", Callback = function()
        task.spawn(function()
            local def = myOriginalAnims or {
                Idle = 507766666, Idle2 = 507766951, Walk = 507777826, Run = 507767714,
                Jump = 507765000, Climb = 507765644, Fall = 507767968, Swim = 507784897, SwimIdle = 507785072
            }
            currentActiveAnim = nil; applyCustomAnims(def)
        end)
    end})
    tab:Divider({Title = "Animation Mixer"})
    tab:Dropdown({Title = "Idle", Flag = "MixIdle", Values = animList, SearchBarEnabled = true, Value = "None",
        Callback = function(v) mixParts.Idle = v; if autoMixApplyEnabled then applySelectedMix() end end})
    tab:Dropdown({Title = "Walk", Flag = "MixWalk", Values = animList, SearchBarEnabled = true, Value = "None",
        Callback = function(v) mixParts.Walk = v; if autoMixApplyEnabled then applySelectedMix() end end})
    tab:Dropdown({Title = "Run", Flag = "MixRun", Values = animList, SearchBarEnabled = true, Value = "None",
        Callback = function(v) mixParts.Run = v; if autoMixApplyEnabled then applySelectedMix() end end})
    tab:Dropdown({Title = "Jump", Flag = "MixJump", Values = animList, SearchBarEnabled = true, Value = "None",
        Callback = function(v) mixParts.Jump = v; if autoMixApplyEnabled then applySelectedMix() end end})
    tab:Dropdown({Title = "Fall", Flag = "MixFall", Values = animList, SearchBarEnabled = true, Value = "None",
        Callback = function(v) mixParts.Fall = v; if autoMixApplyEnabled then applySelectedMix() end end})
    tab:Dropdown({Title = "Climb", Flag = "MixClimb", Values = animList, SearchBarEnabled = true, Value = "None",
        Callback = function(v) mixParts.Climb = v; if autoMixApplyEnabled then applySelectedMix() end end})
    tab:Button({Title = "Mix and Apply", Callback = function() applySelectedMix() end})
    tab:Toggle({Title = "Auto Mix Apply", Flag = "AutoMixApply", Value = false, Callback = function(v)
        autoMixApplyEnabled = v; if v then applySelectedMix() end
    end})
end)()

-- ============ DESTROY ============
Window:OnDestroy(function()
    dmvsDestroyed = true
    -- Reset combat
    Combat.SilentAim.Enabled = false; Combat.SilentAim._toggled = false
    Combat.AutoShoot.Enabled = false; Combat.AutoShoot._toggled = false
    Combat.TriggerBot.Enabled = false; Combat.TriggerBot._toggled = false
    genv.SZK_Target = nil; genv.SZK_ShotTarget = nil; genv.SZK_KnifeTarget = nil
    -- Unhook namecall
    pcall(function()
        if namecallHook and hookmetamethod and getnamecallmethod then
            hookmetamethod(game, "__namecall", namecallHook)
        end
    end)
    -- ESP cleanup
    for plr in pairs(ESP_Data) do destroyESP(plr) end
    pcall(function() if EspGui then EspGui:Destroy() end end)
    -- Auto macro
    dmvsAutoMacroState.Enabled = false
    dmvsAutoMacroState.CurrentTarget = nil
    if dmvsAutoMacroState.ManagedGun then
        local c = player.Character; local h = c and c:FindFirstChildOfClass("Humanoid")
        dmvsAutoMacroCleanupGun(dmvsAutoMacroState.ManagedGun, c, h)
    end
    dmvsLoopTPState.Enabled = false
    dmvsKillSoundState.Enabled = false
    pcall(function() if dmvsKillSoundState.PlayerAddedConnection then dmvsKillSoundState.PlayerAddedConnection:Disconnect() end end)
    pcall(function() if dmvsKillSoundState.PlayerRemovingConnection then dmvsKillSoundState.PlayerRemovingConnection:Disconnect() end end)
    for tp in pairs(dmvsKillSoundState.PlayerConnections) do dmvsUnregisterKillSoundPlayer(tp) end
    nameState.myUsernameEnabled = false; nameState.otherNamesEnabled = false
    refreshAllNameElements()
    restoreSkybox(); restoreRTX()
    pcall(function()
        local bb = SoundService:FindFirstChild("SZK_boombox")
        if bb then bb:Stop() end
    end)
    pcall(function() heartbeatConnection:Disconnect() end)
    pcall(function() hitboxConnection:Disconnect() end)
    pcall(function() clearAllHitboxes() end)
    for _, c in pairs(nameState.elementConnections) do pcall(function() c:Disconnect() end) end
    for _, c in pairs(nameState.containerConnections) do pcall(function() c:Disconnect() end) end
    for _, c in pairs(nameState.playerConnections) do pcall(function() c:Disconnect() end) end
    local pg = player:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("ESP_UI") then pg.ESP_UI:Destroy() end
    if screenGui then screenGui:Destroy() end
end)

notify({Message = "SZK - DMVS loaded successfully!", Type = "done", Duration = 5})
notify({Message = "Silent Aim + Auto Shoot + Trigger Bot v3.6.2", Type = "info", Duration = 5})
notify({Message = "Hotkeys: Q = Silent | E = Auto Shoot | T = Trigger Bot", Type = "info", Duration = 5})
