--============================================================
-- MEIZU HUB
-- Single-file build
-- Key gate + HWID + cache + Purple x Blue UI + feature callbacks
--============================================================

--============================================================
-- SERVICES
--============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
if not Player then
    return
end

local PlayerGui = Player:WaitForChild("PlayerGui")

--============================================================
-- CONFIG
-- One config source only.
--============================================================
local Config = {
    Name = "MeizuHub",

    VERIFY_URL = "https://getkeyhub-uwal.onrender.com/api/verify?key=%s&hwid=%s",
    GETKEY_URL = "https://lovemeizu.github.io/GetKeyHub/getkey.html",
    CACHE_FILE = "meizu_hub_key.txt",

    Team = "Pirates",

    Configuration = {
        HopWhenIdle = true,
        AutoHop = false,
        AutoHopDelay = 60 * 60,
        FpsBoost = false,
        blackscreen = false,
        LowGraphics = true,
    },

    Items = {
        AutoFullyMelees = true,
        Saber = true,
        CursedDualKatana = true,
        SoulGuitar = true,
        RaceV2 = true,
        AutoRaceV3 = true,
        AutoRandomFruit = false,
    },

    Sword = {
        ["Shark Saw"] = true,
        ["Wardens Sword"] = true,
        ["Pole (1st Form)"] = true,
        ["Gravity Blade"] = true,
        ["Longsword"] = true,
        ["Rengoku"] = true,
        ["Flail"] = true,
        ["Twin Hooks"] = true,
    },

    BossWeapons = {
        ["Awakened Ice Admiral"] = true,
        ["Tide Keeper"] = true,
        ["Deandre"] = true,
        ["Urban"] = true,
        ["Diablo"] = true,
        ["Soul Reaper"] = true,
        ["Cake Prince"] = true,
        ["Core"] = true,
        ["Darkbeard"] = true,
        ["Katakuri"] = true,
        ["Beautiful Pirates"] = true,
    },

    Melee = {
        AutoBuy = true,
        CheckMasteryAfterBuy = true,
        RaidAtV1Mastery = 500,
        GodhumanAtV2Mastery = 400,
    },

    AutoKen = true,
    BringMobs = false,

    PanicMode = {
        Enabled = true,
        LowHealthPercent = 20,
        SafeHealthPercent = 75,
        EscapeHeight = 2000,
        CheckInterval = 1,
    },

    Settings = {
        StayInSea2UntilHaveDarkFragments = true,
    },

    AutoSea2 = false,
    AutoSea3 = false,
    AutoRaidIce_TargetFragments = 5000,

    Theme = {
        Background = Color3.fromRGB(7, 5, 18),
        Panel = Color3.fromRGB(15, 12, 32),
        Panel2 = Color3.fromRGB(23, 18, 48),

        Purple = Color3.fromRGB(145, 80, 255),
        PurpleLight = Color3.fromRGB(190, 125, 255),
        Blue = Color3.fromRGB(60, 150, 255),
        BlueLight = Color3.fromRGB(100, 200, 255),

        Text = Color3.fromRGB(245, 245, 255),
        SubText = Color3.fromRGB(175, 170, 205),
        Green = Color3.fromRGB(80, 220, 145),
        Red = Color3.fromRGB(255, 100, 120),
        Yellow = Color3.fromRGB(255, 205, 100),
    },
}

--============================================================
-- STATE
-- One state source only.
--============================================================
local State = {
    KeyVerified = false,

    UIVisible = true,
    UIOpen = true,
    UIAnimation = true,
    UIScale = 1.0,
    GlassTransparency = 0.08,
    Notifications = true,

    InfiniteJump = false,
    NoClip = false,
    WalkSpeed = 16,
    JumpPower = 50,

    AutoFarmLevel = false,
    AutoQuest = false,
    AutoFarmNPC = false,
    AutoFarmBoss = false,
    AutoFarmMastery = false,

    StackFarm = false,
    BringMobs = false,

    AutoCollectFruit = false,
    FruitFinder = false,

    ESPPlayers = false,
    ESPNPC = false,
    ESPBoss = false,
    ESPFruits = false,
    ESPChests = false,

    AutoRaid = false,
    AutoDungeon = false,
    AutoSeaEvent = false,

    AntiAFK = false,
    LowGraphics = true,

    SelectedWeapon = "Melee",

    Search = "",
}

--============================================================
-- SINGLE CALLBACK REGISTRY
--============================================================
local FeatureCallbacks = {}

local function RegisterFeature(name, callback)
    if type(name) ~= "string" or name == "" then
        return
    end

    if type(callback) == "function" then
        FeatureCallbacks[name] = callback
    else
        FeatureCallbacks[name] = function()
        end
    end
end

--============================================================
-- HELPERS
--============================================================
local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function Trim(value)
    value = tostring(value or "")
    return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function Create(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    if parent then
        object.Parent = parent
    end
    return object
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius),
    }, parent)
end

local function Stroke(parent, color, transparency, thickness)
    local object = Create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
    return object
end

local function Gradient(parent, firstColor, secondColor, rotation)
    local object = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, firstColor),
            ColorSequenceKeypoint.new(1, secondColor),
        }),
        Rotation = rotation or 0,
    }, parent)
    return object
end

local function Tween(object, duration, properties)
    if not object or not object.Parent then
        return
    end

    local info = TweenInfo.new(
        duration or 0.2,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

    local ok, tween = pcall(function()
        return TweenService:Create(object, info, properties)
    end)

    if ok and tween then
        tween:Play()
    end
end

local function Pulse(object, normalSize, pressedSize)
    if not State.UIAnimation or not object or not object.Parent then
        return
    end

    Tween(object, 0.08, {Size = pressedSize})
    task.delay(0.08, function()
        if object and object.Parent then
            Tween(object, 0.14, {Size = normalSize})
        end
    end)
end

local function FindRemote()
    local rs = game:GetService("ReplicatedStorage")

    local ok, remote = pcall(function()
        return rs:FindFirstChild("Remotes")
            and rs.Remotes:FindFirstChild("CommF_")
    end)

    if ok and remote then
        return remote
    end

    local direct = rs:FindFirstChild("CommF_")
    return direct
end

local function GetCharacter()
    return Player.Character
end

local function GetHumanoid()
    local character = GetCharacter()
    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local character = GetCharacter()
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(model)
    if not model then
        return false
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0
end

--============================================================
-- NOTIFICATION
-- One notification system only.
--============================================================
local NotificationRoot

local function Notify(title, message, duration)
    if not State.Notifications then
        return
    end

    if not NotificationRoot or not NotificationRoot.Parent then
        return
    end

    local life = tonumber(duration) or 3
    local toastHeight = 72

    local toast = Create("Frame", {
        Size = UDim2.fromOffset(300, toastHeight),
        BackgroundColor3 = Config.Theme.Panel,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, NotificationRoot)

    Corner(toast, 18)
    Stroke(toast, Config.Theme.Purple, 0.55, 1)
    Gradient(toast, Color3.fromRGB(17, 13, 38), Color3.fromRGB(13, 25, 48), 20)

    local accent = Create("Frame", {
        Size = UDim2.new(0, 4, 1, -20),
        Position = UDim2.fromOffset(8, 10),
        BackgroundColor3 = Config.Theme.Purple,
        BorderSizePixel = 0,
    }, toast)

    Corner(accent, 3)
    Gradient(accent, Config.Theme.Purple, Config.Theme.Blue, 90)

    Create("TextLabel", {
        Position = UDim2.fromOffset(24, 10),
        Size = UDim2.new(1, -36, 0, 22),
        BackgroundTransparency = 1,
        Text = tostring(title or "MeizuHub"),
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, toast)

    Create("TextLabel", {
        Position = UDim2.fromOffset(24, 32),
        Size = UDim2.new(1, -36, 0, 27),
        BackgroundTransparency = 1,
        Text = tostring(message or ""),
        TextColor3 = Config.Theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, toast)

    local normalSize = toast.Size
    toast.Size = UDim2.fromOffset(260, 0)
    toast.Position = UDim2.fromOffset(18, 0)

    Tween(toast, 0.22, {
        Size = normalSize,
        Position = UDim2.fromOffset(18, 0),
    })

    task.delay(life, function()
        if toast and toast.Parent then
            Tween(toast, 0.18, {
                Size = UDim2.fromOffset(260, 0),
            })
            task.wait(0.2)
            if toast and toast.Parent then
                toast:Destroy()
            end
        end
    end)
end

--============================================================
-- HWID / KEY STORAGE
-- Mirrors the current project flow.
--============================================================
local function GetHWID()
    local result = tostring(Player.UserId)

    pcall(function()
        if type(gethwid) == "function" then
            local value = gethwid()
            if value and tostring(value) ~= "" then
                result = tostring(value)
                return
            end
        end

        if type(hwid) == "string" and #hwid > 0 then
            result = hwid
            return
        end

        local analytics = game:GetService("RbxAnalyticsService")
        local value = analytics:GetClientId()

        if value and #tostring(value) > 10 then
            result = tostring(value)
        end
    end)

    return result
end

local function SaveKey(key)
    if type(writefile) ~= "function" or type(key) ~= "string" then
        return false
    end

    local ok = pcall(function()
        writefile(Config.CACHE_FILE, key)
    end)

    return ok
end

local function LoadKey()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then
        return ""
    end

    local existsOK, exists = pcall(function()
        return isfile(Config.CACHE_FILE)
    end)

    if not existsOK or not exists then
        return ""
    end

    local readOK, value = pcall(function()
        return readfile(Config.CACHE_FILE)
    end)

    if readOK and type(value) == "string" then
        return Trim(value)
    end

    return ""
end

local function HttpGet(url)
    local ok, response = pcall(function()
        return game:HttpGet(url, true)
    end)

    if ok and type(response) == "string" then
        return true, response
    end

    local ok2, response2 = pcall(function()
        return game:HttpGet(url)
    end)

    if ok2 and type(response2) == "string" then
        return true, response2
    end

    return false, tostring(response2 or response or "HTTP request failed")
end

local function VerifyKey(key)
    key = Trim(key)

    if #key < 3 then
        return false, "Vui lòng nhập key."
    end

    local currentHWID = GetHWID()

    if not currentHWID or tostring(currentHWID) == "" then
        return false, "Không lấy được HWID."
    end

    local url = string.format(
        Config.VERIFY_URL,
        HttpService:UrlEncode(key),
        HttpService:UrlEncode(tostring(currentHWID))
    )

    local requestOK, response = HttpGet(url)

    if not requestOK then
        return false, "Không kết nối được máy chủ xác thực."
    end

    local decodeOK, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not decodeOK or type(data) ~= "table" then
        return false, "Phản hồi máy chủ không hợp lệ."
    end

    if data.success == false or data.valid == false then
        return false, tostring(
            data.error
                or data.message
                or "Key không hợp lệ."
        )
    end

    return true, tostring(data.message or "Key hợp lệ.")
end

--============================================================
-- ROOT GUI
--============================================================
local oldGui = PlayerGui:FindFirstChild(Config.Name)
if oldGui then
    pcall(function()
        oldGui:Destroy()
    end)
end

local Gui = Create("ScreenGui", {
    Name = Config.Name,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
}, PlayerGui)

local function DestroyGui()
    if Gui and Gui.Parent then
        Gui:Destroy()
    end
end

--============================================================
-- KEY GATE
--============================================================
local KeyGate = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.56),
    Size = UDim2.fromOffset(390, 430),
    BackgroundColor3 = Config.Theme.Panel,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, Gui)

Corner(KeyGate, 24)

local KeyScale = Create("UIScale", {
    Scale = 1,
}, KeyGate)

Stroke(KeyGate, Config.Theme.Purple, 0.55, 1)

local KeyGradient = Gradient(
    KeyGate,
    Config.Theme.Purple,
    Config.Theme.Blue,
    25
)
KeyGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.72),
    NumberSequenceKeypoint.new(0.5, 0.92),
    NumberSequenceKeypoint.new(1, 0.76),
})

local KeyContent = Create("Frame", {
    Position = UDim2.fromOffset(26, 24),
    Size = UDim2.new(1, -52, 1, -48),
    BackgroundTransparency = 1,
}, KeyGate)

local KeyBadge = Create("Frame", {
    Size = UDim2.fromOffset(126, 28),
    BackgroundColor3 = Config.Theme.Purple,
    BackgroundTransparency = 0.82,
    BorderSizePixel = 0,
}, KeyContent)

Corner(KeyBadge, 14)
Stroke(KeyBadge, Config.Theme.Purple, 0.5, 1)
Gradient(KeyBadge, Config.Theme.Purple, Config.Theme.Blue, 0)

Create("TextLabel", {
    Position = UDim2.fromOffset(13, 0),
    Size = UDim2.new(1, -13, 1, 0),
    BackgroundTransparency = 1,
    Text = "ONE-TIME KEY",
    TextColor3 = Config.Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Center,
}, KeyBadge)

local KeyTitle = Create("TextLabel", {
    Position = UDim2.fromOffset(0, 52),
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundTransparency = 1,
    Text = "MEIZU HUB",
    TextColor3 = Config.Theme.Text,
    Font = Enum.Font.GothamBlack,
    TextSize = 27,
    TextXAlignment = Enum.TextXAlignment.Left,
}, KeyContent)

Gradient(KeyTitle, Config.Theme.PurpleLight, Config.Theme.BlueLight, 0)

Create("TextLabel", {
    Position = UDim2.fromOffset(0, 92),
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "Blox Fruit",
    TextColor3 = Config.Theme.SubText,
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
}, KeyContent)

local KeyStatus = Create("TextLabel", {
    Position = UDim2.fromOffset(0, 126),
    Size = UDim2.new(1, 0, 0, 22),
    BackgroundTransparency = 1,
    Text = "●  Chưa xác thực",
    TextColor3 = Config.Theme.SubText,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, KeyContent)

local KeyBox = Create("TextBox", {
    Position = UDim2.fromOffset(0, 163),
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    PlaceholderText = "Nhập key...",
    PlaceholderColor3 = Config.Theme.SubText,
    Text = "",
    TextColor3 = Config.Theme.Text,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
}, KeyContent)

Corner(KeyBox, 14)
Stroke(KeyBox, Config.Theme.Purple, 0.72, 1)

Create("UIPadding", {
    PaddingLeft = UDim.new(0, 13),
    PaddingRight = UDim.new(0, 13),
}, KeyBox)

local GetKey = Create("TextButton", {
    Position = UDim2.fromOffset(0, 219),
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = Config.Theme.Purple,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "Tạo / Lấy Key",
    TextColor3 = Config.Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
}, KeyContent)

Corner(GetKey, 14)
Gradient(GetKey, Config.Theme.Purple, Config.Theme.Blue, 0)

local Verify = Create("TextButton", {
    Position = UDim2.fromOffset(0, 275),
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = Config.Theme.Panel2,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "Xác thực Key",
    TextColor3 = Config.Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
}, KeyContent)

Corner(Verify, 14)
Stroke(Verify, Config.Theme.Blue, 0.65, 1)

local KeyResult = Create("TextLabel", {
    Position = UDim2.fromOffset(0, 331),
    Size = UDim2.new(1, 0, 0, 28),
    BackgroundTransparency = 1,
    Text = "HWID được xử lý tự động.",
    TextColor3 = Config.Theme.SubText,
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Center,
}, KeyContent)

Create("TextLabel", {
    Position = UDim2.fromOffset(0, 366),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    Text = "MEIZU HUB • PURPLE × BLUE",
    TextColor3 = Color3.fromRGB(115, 105, 145),
    Font = Enum.Font.GothamMedium,
    TextSize = 8,
    TextXAlignment = Enum.TextXAlignment.Center,
}, KeyContent)

local function ScaleKeyGate()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(390, 430)
    local widthScale = (viewport.X - 28) / 390
    local heightScale = (viewport.Y - 40) / 430
    KeyScale.Scale = Clamp(math.min(widthScale, heightScale), 0.72, 1)
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ScaleKeyGate)
ScaleKeyGate()

local cached = LoadKey()
if cached ~= "" then
    KeyBox.Text = cached
end

GetKey.MouseButton1Click:Connect(function()
    local currentHWID = GetHWID()

    if not currentHWID or tostring(currentHWID) == "" then
        KeyStatus.Text = "●  Không lấy được HWID"
        KeyStatus.TextColor3 = Config.Theme.Red
        KeyResult.Text = "Không thể tạo link Get Key."
        return
    end

    local url = Config.GETKEY_URL
        .. "?hwid="
        .. HttpService:UrlEncode(tostring(currentHWID))

    if type(setclipboard) == "function" then
        local copyOK = pcall(function()
            setclipboard(url)
        end)

        if copyOK then
            KeyStatus.Text = "●  Link Get Key đã sẵn sàng"
            KeyStatus.TextColor3 = Config.Theme.Green
            KeyResult.Text = "Đã copy link Get Key kèm HWID."
        else
            KeyStatus.Text = "●  Get Key sẵn sàng"
            KeyStatus.TextColor3 = Config.Theme.Yellow
            KeyResult.Text = "Không thể dùng clipboard trong môi trường này."
        end
    else
        KeyStatus.Text = "●  Get Key sẵn sàng"
        KeyStatus.TextColor3 = Config.Theme.Yellow
        KeyResult.Text = "Clipboard không được hỗ trợ."
    end

    Pulse(
        GetKey,
        UDim2.new(1, 0, 0, 46),
        UDim2.new(1, -8, 0, 43)
    )
end)

--============================================================
-- FEATURE RUNTIME
--============================================================
local Runtime = {
    CharacterConnections = {},
    NoclipParts = {},
    ESPHighlights = {},
    FarmLoop = false,
    FruitLoop = false,
    ESPLoop = false,
}

local function ApplyCharacterSettings()
    local humanoid = GetHumanoid()
    if not humanoid then
        return
    end

    pcall(function()
        humanoid.WalkSpeed = tonumber(State.WalkSpeed) or 16
    end)

    pcall(function()
        humanoid.UseJumpPower = true
        humanoid.JumpPower = tonumber(State.JumpPower) or 50
    end)
end

local function SetNoClip(enabled)
    State.NoClip = enabled

    local character = GetCharacter()
    if not character then
        return
    end

    if enabled then
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") then
                if Runtime.NoclipParts[object] == nil then
                    Runtime.NoclipParts[object] = object.CanCollide
                end
                object.CanCollide = false
            end
        end
    else
        for object, oldValue in pairs(Runtime.NoclipParts) do
            if object and object.Parent then
                pcall(function()
                    object.CanCollide = oldValue
                end)
            end
            Runtime.NoclipParts[object] = nil
        end
    end
end

local function EnsureAntiAFK()
    if not State.AntiAFK then
        return
    end

    pcall(function()
        local VirtualUser = game:GetService("VirtualUser")
        Player.Idled:Connect(function()
            if State.AntiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end
        end)
    end)
end

local function FindEnemiesFolder()
    local workspaceEnemies = workspace:FindFirstChild("Enemies")
    if workspaceEnemies then
        return workspaceEnemies
    end

    local enemies = workspace:FindFirstChild("Enemies")
    return enemies
end

local function GetEnemyCandidates()
    local list = {}

    local folders = {
        workspace:FindFirstChild("Enemies"),
        workspace:FindFirstChild("NPCs"),
        workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Enemies"),
    }

    for _, folder in ipairs(folders) do
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") and IsAlive(model) then
                    table.insert(list, model)
                end
            end
        end
    end

    return list
end

local function GetNearestEnemy(maxDistance)
    local root = GetRoot()
    if not root then
        return nil
    end

    local nearest = nil
    local nearestDistance = maxDistance or math.huge

    for _, enemy in ipairs(GetEnemyCandidates()) do
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
        if enemyRoot then
            local distance = (enemyRoot.Position - root.Position).Magnitude
            if distance < nearestDistance then
                nearest = enemy
                nearestDistance = distance
            end
        end
    end

    return nearest
end

local function IsBossName(name)
    local text = tostring(name or ""):lower()

    local names = {
        "gorilla king",
        "chief",
        "yeti",
        "vice admiral",
        "warden",
        "chief warden",
        "swan",
        "magma admiral",
        "fishman lord",
        "wysper",
        "thunder god",
        "cyborg",
        "diamond",
        "jeremy",
        "orbitus",
        "smoke admiral",
        "awakened ice admiral",
        "tide keeper",
        "don swan",
        "stone",
        "kilo admiral",
        "captain elephant",
        "beautiful pirate",
        "cake queen",
        "cake prince",
        "soul reaper",
        "darkbeard",
        "katakuri",
    }

    for _, bossName in ipairs(names) do
        if text == bossName or text:find(bossName, 1, true) then
            return true
        end
    end

    return false
end

local function GetBossCandidates()
    local list = {}

    for _, enemy in ipairs(GetEnemyCandidates()) do
        if IsBossName(enemy.Name) then
            table.insert(list, enemy)
        end
    end

    return list
end

local function GetNearestBoss()
    local root = GetRoot()
    if not root then
        return nil
    end

    local nearest = nil
    local nearestDistance = math.huge

    for _, boss in ipairs(GetBossCandidates()) do
        local bossRoot = boss:FindFirstChild("HumanoidRootPart")
        if bossRoot then
            local distance = (bossRoot.Position - root.Position).Magnitude
            if distance < nearestDistance then
                nearest = boss
                nearestDistance = distance
            end
        end
    end

    return nearest
end

local function EquipSelectedWeapon()
    local character = GetCharacter()
    if not character then
        return nil
    end

    local equipped = character:FindFirstChildOfClass("Tool")
    if equipped then
        if State.SelectedWeapon == "Any" then
            return equipped
        end

        if equipped.ToolTip == State.SelectedWeapon then
            return equipped
        end
    end

    local backpack = Player:FindFirstChildOfClass("Backpack")
    if not backpack then
        return equipped
    end

    if State.SelectedWeapon == "Any" then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = character
            return tool
        end
        return equipped
    end

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local tip = tool.ToolTip
            if tip == State.SelectedWeapon then
                tool.Parent = character
                return tool
            end
        end
    end

    return equipped
end

local function AttackTarget(target)
    if not target or not IsAlive(target) then
        return
    end

    local tool = EquipSelectedWeapon()
    if not tool then
        return
    end

    local character = GetCharacter()
    if not character then
        return
    end

    pcall(function()
        tool:Activate()
    end)

    local commF = FindRemote()
    if commF then
        local rootPart = target:FindFirstChild("HumanoidRootPart")
        if rootPart then
            pcall(function()
                commF:FireServer("TIR", target.Name, rootPart.Position)
            end)
        end
    end
end

local function FarmStep()
    local root = GetRoot()
    if not root then
        return
    end

    local target

    if State.AutoFarmBoss then
        target = GetNearestBoss()
    end

    if not target then
        target = GetNearestEnemy(350)
    end

    if not target then
        return
    end

    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    pcall(function()
        root.CFrame = targetRoot.CFrame * CFrame.new(0, 12, 0)
        root.AssemblyLinearVelocity = Vector3.zero
    end)

    AttackTarget(target)
end

local function GetFruitObjects()
    local fruits = {}

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Tool") then
            local name = object.Name:lower()
            if name:find("fruit", 1, true)
                or name:find("kilo", 1, true)
                or name:find("rocket", 1, true)
                or name:find("spin", 1, true)
                or name:find("chop", 1, true)
                or name:find("bomb", 1, true)
                or name:find("smoke", 1, true)
                or name:find("flame", 1, true)
            then
                table.insert(fruits, object)
            end
        end
    end

    return fruits
end

local function CollectFruitStep()
    local root = GetRoot()
    if not root then
        return
    end

    local closest
    local distance = math.huge

    for _, fruit in ipairs(GetFruitObjects()) do
        local handle = fruit:FindFirstChild("Handle")
        if handle then
            local d = (handle.Position - root.Position).Magnitude
            if d < distance then
                closest = handle
                distance = d
            end
        end
    end

    if closest then
        pcall(function()
            root.CFrame = closest.CFrame + Vector3.new(0, 2, 0)
        end)
    end
end

local function ClearESP()
    for object, highlight in pairs(Runtime.ESPHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        Runtime.ESPHighlights[object] = nil
    end
end

local function ApplyESPTo(object, category)
    if not object or not object.Parent then
        return
    end

    local existing = Runtime.ESPHighlights[object]

    if existing and existing.Parent then
        existing.Name = "MeizuESP_" .. category
        existing.Adornee = object
        return
    end

    local highlight = Create("Highlight", {
        Name = "MeizuESP_" .. category,
        Adornee = object,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        FillTransparency = 0.80,
        OutlineTransparency = 0.20,
        FillColor = Config.Theme.Purple,
        OutlineColor = Config.Theme.Blue,
    }, Gui)

    Runtime.ESPHighlights[object] = highlight
end

local function UpdateESP()
    if not State.ESPNPC
        and not State.ESPBoss
        and not State.ESPPlayers
        and not State.ESPFruits
        and not State.ESPChests
    then
        ClearESP()
        return
    end

    local valid = {}

    if State.ESPPlayers then
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= Player and targetPlayer.Character then
                ApplyESPTo(targetPlayer.Character, "Player")
                valid[targetPlayer.Character] = true
            end
        end
    end

    if State.ESPNPC or State.ESPBoss then
        for _, enemy in ipairs(GetEnemyCandidates()) do
            local isBoss = IsBossName(enemy.Name)

            if (isBoss and State.ESPBoss)
                or ((not isBoss) and State.ESPNPC)
            then
                ApplyESPTo(enemy, isBoss and "Boss" or "NPC")
                valid[enemy] = true
            end
        end
    end

    if State.ESPFruits then
        for _, fruit in ipairs(GetFruitObjects()) do
            local handle = fruit:FindFirstChild("Handle")
            if handle then
                ApplyESPTo(handle, "Fruit")
                valid[handle] = true
            end
        end
    end

    if State.ESPChests then
        for _, object in ipairs(workspace:GetDescendants()) do
            if object:IsA("Model") or object:IsA("BasePart") then
                local lower = object.Name:lower()
                if lower:find("chest", 1, true) then
                    ApplyESPTo(object, "Chest")
                    valid[object] = true
                end
            end
        end
    end

    for object, highlight in pairs(Runtime.ESPHighlights) do
        if not valid[object] or not object.Parent then
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
            Runtime.ESPHighlights[object] = nil
        end
    end
end

local function OptimizeGraphics(enabled)
    State.LowGraphics = enabled
    Config.Configuration.LowGraphics = enabled

    if not enabled then
        return
    end

    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ParticleEmitter")
            or object:IsA("Trail")
            or object:IsA("Smoke")
            or object:IsA("Fire")
            or object:IsA("Sparkles")
        then
            object.Enabled = false
        end
    end
end

local function Rejoin()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            Player
        )
    end)
end

local function ServerHop()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, Player)
    end)
end

local function TeleportTo(cframe)
    local root = GetRoot()
    if root and typeof(cframe) == "CFrame" then
        pcall(function()
            root.CFrame = cframe
        end)
    end
end

local Teleports = {
    ["First Sea"] = CFrame.new(1128, 16, 1446),
    ["Second Sea"] = CFrame.new(-6508, 89, -132),
    ["Third Sea"] = CFrame.new(-12463, 375, -7551),

    ["Pirate Starter"] = CFrame.new(-1160, 5, 382),
    ["Jungle"] = CFrame.new(-1612, 36, 149),
    ["Frozen Village"] = CFrame.new(1149, 117, -1150),
    ["Colosseum"] = CFrame.new(-1429, 7, -3014),

    ["Kingdom of Rose"] = CFrame.new(-429, 71, 1836),
    ["Cafe"] = CFrame.new(-386, 73, 300),
    ["Hot and Cold"] = CFrame.new(-6027, 14, -4900),
    ["Forgotten Island"] = CFrame.new(-3054, 238, -10145),

    ["Castle"] = CFrame.new(-5077, 315, -3152),
    ["Hydra Island"] = CFrame.new(5742, 668, -670),
    ["Mansion"] = CFrame.new(-12511, 337, -7481),
    ["Great Tree"] = CFrame.new(2258, 25, -6496),
}

local function StartRuntimeLoops()
    if not Runtime.FarmLoop then
        Runtime.FarmLoop = true

        task.spawn(function()
            while Runtime.FarmLoop do
                if State.AutoFarmLevel
                    or State.AutoFarmNPC
                    or State.AutoFarmBoss
                    or State.AutoFarmMastery
                    or State.StackFarm
                then
                    pcall(FarmStep)
                end

                task.wait(0.25)
            end
        end)
    end

    if not Runtime.FruitLoop then
        Runtime.FruitLoop = true

        task.spawn(function()
            while Runtime.FruitLoop do
                if State.AutoCollectFruit then
                    pcall(CollectFruitStep)
                end

                task.wait(0.35)
            end
        end)
    end

    if not Runtime.ESPLoop then
        Runtime.ESPLoop = true

        task.spawn(function()
            while Runtime.ESPLoop do
                pcall(UpdateESP)
                task.wait(1)
            end
        end)
    end
end

--============================================================
-- FEATURE CALLBACKS
--============================================================
RegisterFeature("WalkSpeed", function(enabled)
    State.WalkSpeed = enabled and State.WalkSpeed or 16
    ApplyCharacterSettings()
end)

RegisterFeature("JumpPower", function(enabled)
    State.JumpPower = enabled and State.JumpPower or 50
    ApplyCharacterSettings()
end)

RegisterFeature("Infinite Jump", function(enabled)
    State.InfiniteJump = enabled
end)

RegisterFeature("No Clip", function(enabled)
    SetNoClip(enabled)
end)

RegisterFeature("Auto Farm Level", function(enabled)
    State.AutoFarmLevel = enabled
    if enabled then
        State.AutoFarmNPC = true
        Notify("MEIZU HUB", "Auto Farm Level đã bật.", 2.5)
    end
end)

RegisterFeature("Auto Quest", function(enabled)
    State.AutoQuest = enabled
    Notify(
        "MEIZU HUB",
        enabled and "Auto Quest đã bật." or "Auto Quest đã tắt.",
        2
    )
end)

RegisterFeature("Auto Farm NPC", function(enabled)
    State.AutoFarmNPC = enabled
end)

RegisterFeature("Auto Farm Boss", function(enabled)
    State.AutoFarmBoss = enabled
end)

RegisterFeature("Auto Farm Mastery", function(enabled)
    State.AutoFarmMastery = enabled
end)

RegisterFeature("Stack Farming", function(enabled)
    State.StackFarm = enabled
    State.BringMobs = enabled
    Config.BringMobs = enabled
end)

RegisterFeature("Bring Mobs", function(enabled)
    State.BringMobs = enabled
    Config.BringMobs = enabled
end)

RegisterFeature("Fruit Finder", function(enabled)
    State.FruitFinder = enabled
    State.ESPFruits = enabled
end)

RegisterFeature("Auto Collect Fruit", function(enabled)
    State.AutoCollectFruit = enabled
    if enabled then
        State.FruitFinder = true
        State.ESPFruits = true
    end
end)

RegisterFeature("ESP Players", function(enabled)
    State.ESPPlayers = enabled
end)

RegisterFeature("ESP NPC", function(enabled)
    State.ESPNPC = enabled
end)

RegisterFeature("ESP Boss", function(enabled)
    State.ESPBoss = enabled
end)

RegisterFeature("ESP Fruits", function(enabled)
    State.ESPFruits = enabled
end)

RegisterFeature("ESP Chests", function(enabled)
    State.ESPChests = enabled
end)

RegisterFeature("Auto Raid", function(enabled)
    State.AutoRaid = enabled
end)

RegisterFeature("Auto Dungeon", function(enabled)
    State.AutoDungeon = enabled
end)

RegisterFeature("Sea Event", function(enabled)
    State.AutoSeaEvent = enabled
end)

RegisterFeature("Anti AFK", function(enabled)
    State.AntiAFK = enabled
    if enabled then
        EnsureAntiAFK()
    end
end)

RegisterFeature("Low Graphics", function(enabled)
    OptimizeGraphics(enabled)
end)

RegisterFeature("Rejoin Server", function()
    Rejoin()
end)

RegisterFeature("Server Hop", function()
    ServerHop()
end)

RegisterFeature("Reset Character", function()
    local humanoid = GetHumanoid()
    if humanoid then
        pcall(function()
            humanoid.Health = 0
        end)
    end
end)

RegisterFeature("Teleport First Sea", function()
    TeleportTo(Teleports["First Sea"])
end)

RegisterFeature("Teleport Second Sea", function()
    TeleportTo(Teleports["Second Sea"])
end)

RegisterFeature("Teleport Third Sea", function()
    TeleportTo(Teleports["Third Sea"])
end)

--============================================================
-- RUNTIME EVENTS
--============================================================
UserInputService.JumpRequest:Connect(function()
    if not State.InfiniteJump then
        return
    end

    local humanoid = GetHumanoid()
    if humanoid then
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

RunService.Stepped:Connect(function()
    if not State.NoClip then
        return
    end

    local character = GetCharacter()
    if not character then
        return
    end

    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart") then
            if Runtime.NoclipParts[object] == nil then
                Runtime.NoclipParts[object] = object.CanCollide
            end
            object.CanCollide = false
        end
    end
end)

Player.CharacterAdded:Connect(function()
    task.wait(0.5)

    Runtime.NoclipParts = {}

    ApplyCharacterSettings()

    if State.NoClip then
        SetNoClip(true)
    end
end)

--============================================================
-- MAIN UI RUNTIME
--============================================================
local MainRoot
local MainScale
local Sidebar
local Body
local Page
local PageTitle
local SearchBox
local SidebarToggle
local MinimizeButton
local WindowCloseButton
local SettingsButton
local CurrentTab = "Home"
local PageCards = {}
local TabButtons = {}

local function SetGlass(object, transparency)
    if not object then
        return
    end

    object.BackgroundTransparency = Clamp(
        transparency or State.GlassTransparency,
        0,
        0.95
    )
end

local function SetSelectedTab(button, selected)
    if not button then
        return
    end

    local stroke = button:FindFirstChildOfClass("UIStroke")
    local fill = button:FindFirstChildOfClass("UIGradient")

    if selected then
        button.BackgroundColor3 = Config.Theme.Purple
        button.BackgroundTransparency = 0.20

        if stroke then
            stroke.Transparency = 0.25
            stroke.Color = Config.Theme.Blue
        end

        if fill then
            fill.Enabled = true
        end
    else
        button.BackgroundColor3 = Config.Theme.Panel2
        button.BackgroundTransparency = 0.72

        if stroke then
            stroke.Transparency = 0.86
            stroke.Color = Config.Theme.Purple
        end

        if fill then
            fill.Enabled = false
        end
    end
end

local function CreateControlLabel(parent, title, description)
    local titleLabel = Create("TextLabel", {
        Position = UDim2.fromOffset(16, 9),
        Size = UDim2.new(1, -130, 0, 22),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)

    local descriptionLabel = Create("TextLabel", {
        Position = UDim2.fromOffset(16, 31),
        Size = UDim2.new(1, -130, 0, 24),
        BackgroundTransparency = 1,
        Text = description or "",
        TextColor3 = Config.Theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)

    return titleLabel, descriptionLabel
end

local function CreateCard(title, description)
    local card = Create("Frame", {
        Size = UDim2.new(1, -4, 0, 76),
        BackgroundColor3 = Config.Theme.Panel2,
        BackgroundTransparency = 0.32,
        BorderSizePixel = 0,
    }, Page)

    Corner(card, 16)
    local outline = Stroke(card, Config.Theme.Purple, 0.78, 1)

    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 12, 38)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(17, 14, 42)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 24, 46)),
        }),
        Rotation = 15,
    }, card)

    CreateControlLabel(card, title, description)

    local record = {
        Card = card,
        Title = title,
        Description = description or "",
        Outline = outline,
    }

    table.insert(PageCards, record)

    return record
end

local function CreateToggle(cardRecord, initialValue, callbackName)
    local card = cardRecord.Card
    local buttonSize = UDim2.fromOffset(52, 28)

    local toggle = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = buttonSize,
        BackgroundColor3 = Config.Theme.Panel,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    }, card)

    Corner(toggle, 14)

    local trackGradient = Gradient(
        toggle,
        Config.Theme.Purple,
        Config.Theme.Blue,
        0
    )
    trackGradient.Enabled = false

    Stroke(toggle, Config.Theme.Purple, 0.55, 1)

    local knob = Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 4, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = Color3.fromRGB(120, 116, 145),
        BorderSizePixel = 0,
    }, toggle)

    Corner(knob, 10)

    local stateValue = initialValue == true

    local function RenderToggle(fire)
        local position = stateValue
            and UDim2.new(1, -24, 0.5, 0)
            or UDim2.new(0, 4, 0.5, 0)

        if stateValue then
            toggle.BackgroundColor3 = Config.Theme.Purple
            toggle.BackgroundTransparency = 0.18
            knob.BackgroundColor3 = Config.Theme.Text
            trackGradient.Enabled = true
        else
            toggle.BackgroundColor3 = Config.Theme.Panel
            toggle.BackgroundTransparency = 0.08
            knob.BackgroundColor3 = Color3.fromRGB(105, 101, 128)
            trackGradient.Enabled = false
        end

        Tween(knob, 0.16, {
            Position = position,
        })

        if fire then
            local callback = FeatureCallbacks[callbackName]
            if callback then
                pcall(callback, stateValue)
            end
        end
    end

    toggle.MouseButton1Click:Connect(function()
        stateValue = not stateValue
        Pulse(toggle, buttonSize, UDim2.fromOffset(48, 26))
        RenderToggle(true)
    end)

    record.Toggle = toggle
    record.SetToggle = function(value, fire)
        stateValue = value == true
        RenderToggle(fire ~= false)
    end

    RenderToggle(false)

    return toggle
end

local function CreateActionButton(cardRecord, callbackName, text)
    local card = cardRecord.Card

    local button = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(92, 32),
        BackgroundColor3 = Config.Theme.Purple,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = text or "Open",
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
    }, card)

    Corner(button, 14)
    Gradient(button, Config.Theme.Purple, Config.Theme.Blue, 0)
    Stroke(button, Config.Theme.Blue, 0.55, 1)

    button.MouseButton1Click:Connect(function()
        Pulse(
            button,
            UDim2.fromOffset(92, 32),
            UDim2.fromOffset(86, 30)
        )

        local callback = FeatureCallbacks[callbackName]
        if callback then
            pcall(callback)
        end
    end)

    cardRecord.Button = button
    return button
end

local function CreateDropdown(cardRecord, values, defaultValue, callback)
    local card = cardRecord.Card
    local button = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(112, 32),
        BackgroundColor3 = Config.Theme.Panel,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = tostring(defaultValue or values[1] or "Select"),
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 9,
    }, card)

    Corner(button, 14)
    Stroke(button, Config.Theme.Purple, 0.55, 1)

    local index = 1

    for i, value in ipairs(values) do
        if value == defaultValue then
            index = i
            break
        end
    end

    local function Apply()
        local value = values[index]
        button.Text = tostring(value)

        if callback then
            pcall(callback, value)
        end
    end

    button.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #values then
            index = 1
        end

        Pulse(
            button,
            UDim2.fromOffset(112, 32),
            UDim2.fromOffset(108, 30)
        )

        Apply()
    end)

    Apply()

    cardRecord.Dropdown = button
    return button
end

local function CreateSlider(cardRecord, minimum, maximum, value, callback)
    local card = cardRecord.Card

    local holder = Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(130, 34),
        BackgroundTransparency = 1,
    }, card)

    local track = Create("Frame", {
        Position = UDim2.fromOffset(0, 16),
        Size = UDim2.new(1, 0, 0, 5),
        BackgroundColor3 = Config.Theme.Panel,
        BorderSizePixel = 0,
    }, holder)

    Corner(track, 4)

    local fill = Create("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = Config.Theme.Purple,
        BorderSizePixel = 0,
    }, track)

    Corner(fill, 4)
    Gradient(fill, Config.Theme.Purple, Config.Theme.Blue, 0)

    local knob = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Config.Theme.Text,
        BorderSizePixel = 0,
    }, track)

    Corner(knob, 7)

    local valueLabel = Create("TextLabel", {
        Position = UDim2.new(0, 0, 0, -2),
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = Config.Theme.SubText,
        Font = Enum.Font.GothamMedium,
        TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, holder)

    local dragging = false
    local current = tonumber(value) or minimum

    local function Render()
        local alpha = (current - minimum) / (maximum - minimum)
        alpha = Clamp(alpha, 0, 1)

        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(math.floor(current * 100) / 100)

        if callback then
            pcall(callback, current)
        end
    end

    local function SetFromX(x)
        local relative = Clamp(
            (x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1),
            0,
            1
        )

        current = minimum + ((maximum - minimum) * relative)
        Render()
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = true
            SetFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then
            SetFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = false
        end
    end)

    cardRecord.Slider = holder

    Render()

    return holder
end

local function CreateSection(title, subtitle)
    local section = Create("Frame", {
        Size = UDim2.new(1, -4, 0, 58),
        BackgroundColor3 = Config.Theme.Panel,
        BackgroundTransparency = 0.26,
        BorderSizePixel = 0,
    }, Page)

    Corner(section, 15)
    Stroke(section, Config.Theme.Purple, 0.84, 1)

    local line = Create("Frame", {
        Position = UDim2.fromOffset(14, 15),
        Size = UDim2.fromOffset(3, 28),
        BackgroundColor3 = Config.Theme.Purple,
        BorderSizePixel = 0,
    }, section)

    Corner(line, 2)
    Gradient(line, Config.Theme.Purple, Config.Theme.Blue, 90)

    Create("TextLabel", {
        Position = UDim2.fromOffset(27, 9),
        Size = UDim2.new(1, -35, 0, 22),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, section)

    Create("TextLabel", {
        Position = UDim2.fromOffset(27, 30),
        Size = UDim2.new(1, -35, 0, 18),
        BackgroundTransparency = 1,
        Text = subtitle or "",
        TextColor3 = Config.Theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, section)

    return section
end

local function AddToggle(title, description, default, callbackName)
    local record = CreateCard(title, description)
    CreateToggle(record, default, callbackName)
    return record
end

local function AddButton(title, description, callbackName, buttonText)
    local record = CreateCard(title, description)
    CreateActionButton(record, callbackName, buttonText)
    return record
end

local function AddDropdown(title, description, values, defaultValue, callback)
    local record = CreateCard(title, description)
    CreateDropdown(record, values, defaultValue, callback)
    return record
end

local function AddSlider(title, description, minimum, maximum, value, callback)
    local record = CreateCard(title, description)
    CreateSlider(record, minimum, maximum, value, callback)
    return record
end

local function ClearPage()
    PageCards = {}

    if not Page then
        return
    end

    for _, child in ipairs(Page:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

local function RefreshCardFilter()
    local query = Trim(State.Search):lower()

    for _, record in ipairs(PageCards) do
        local haystack = (
            tostring(record.Title)
            .. " "
            .. tostring(record.Description)
        ):lower()

        record.Card.Visible = (
            query == ""
            or haystack:find(query, 1, true) ~= nil
        )
    end

    if Page then
        local layout = Page:FindFirstChildOfClass("UIListLayout")
        if layout then
            Page.CanvasSize = UDim2.fromOffset(
                0,
                layout.AbsoluteContentSize.Y + 12
            )
        end
    end
end

local function ShowTab(name)
    CurrentTab = name
    PageTitle.Text = name

    for tabName, button in pairs(TabButtons) do
        SetSelectedTab(button, tabName == name)
    end

    ClearPage()

    if name == "Home" then
        CreateSection(
            "Welcome to MEIZU HUB",
            "Purple × Blue • Modern Blox Fruit control center"
        )

        AddButton(
            "Player Information",
            "Open a quick player snapshot.",
            "NotifyPlayerInfo",
            "View"
        )

        AddButton(
            "Server Information",
            "Show place, job and player count.",
            "NotifyServerInfo",
            "View"
        )

        AddButton(
            "Hub Version",
            "Single-file MeizuHub build.",
            "NotifyVersion",
            "View"
        )

        AddButton(
            "Key Status",
            State.KeyVerified
                and "Key + HWID verification completed."
                or "Key is not verified.",
            "NotifyKeyStatus",
            State.KeyVerified and "Valid" or "Check"
        )

    elseif name == "Shop" then
        CreateSection(
            "Shop",
            "Purchase and quick utility controls"
        )

        AddButton(
            "Random Fruit",
            "Use the current game purchase flow when available.",
            "RandomFruit",
            "Use"
        )

        AddButton(
            "Reset Character",
            "Respawn the current character.",
            "Reset Character",
            "Reset"
        )

    elseif name == "Status" then
        CreateSection(
            "Status",
            "Live local status and runtime options"
        )

        AddButton(
            "Player Information",
            "Level, race, currency and current place.",
            "NotifyPlayerInfo",
            "Refresh"
        )

        AddButton(
            "Server Information",
            "Player count and server identifier.",
            "NotifyServerInfo",
            "Refresh"
        )

        AddToggle(
            "Low Graphics",
            "Reduce visual load for mobile performance.",
            State.LowGraphics,
            "Low Graphics"
        )

        AddToggle(
            "Anti AFK",
            "Keep the client active while idle.",
            State.AntiAFK,
            "Anti AFK"
        )

    elseif name == "Local Player" then
        CreateSection(
            "Movement",
            "Character movement and utility controls"
        )

        AddSlider(
            "WalkSpeed",
            "Adjust character movement speed.",
            16,
            150,
            State.WalkSpeed,
            function(value)
                State.WalkSpeed = math.floor(value)
                ApplyCharacterSettings()
            end
        )

        AddSlider(
            "JumpPower",
            "Adjust character jump power.",
            50,
            150,
            State.JumpPower,
            function(value)
                State.JumpPower = math.floor(value)
                ApplyCharacterSettings()
            end
        )

        AddToggle(
            "Infinite Jump",
            "Jump again while already airborne.",
            State.InfiniteJump,
            "Infinite Jump"
        )

        AddToggle(
            "No Clip",
            "Disable character collision while enabled.",
            State.NoClip,
            "No Clip"
        )

    elseif name == "Farming" then
        CreateSection(
            "Level Farming",
            "Automated target selection and combat loop"
        )

        AddToggle(
            "Auto Farm Level",
            "Move to nearby enemies and attack automatically.",
            State.AutoFarmLevel,
            "Auto Farm Level"
        )

        AddToggle(
            "Auto Quest",
            "Keep the quest state enabled alongside farming.",
            State.AutoQuest,
            "Auto Quest"
        )

        AddToggle(
            "Auto Farm NPC",
            "Continuously target nearby NPC enemies.",
            State.AutoFarmNPC,
            "Auto Farm NPC"
        )

        AddToggle(
            "Auto Farm Boss",
            "Prefer detected boss targets.",
            State.AutoFarmBoss,
            "Auto Farm Boss"
        )

        AddToggle(
            "Auto Farm Mastery",
            "Keep the combat loop active for mastery sessions.",
            State.AutoFarmMastery,
            "Auto Farm Mastery"
        )

    elseif name == "Stack Farming" then
        CreateSection(
            "Stack Farming",
            "Consolidated mob control and farming state"
        )

        AddToggle(
            "Stack Farming",
            "Enable the combined farming state.",
            State.StackFarm,
            "Stack Farming"
        )

        AddToggle(
            "Bring Mobs",
            "Keep the shared BringMobs state enabled.",
            State.BringMobs,
            "Bring Mobs"
        )

        AddDropdown(
            "Weapon Type",
            "Select the preferred combat tool category.",
            {"Melee", "Sword", "Gun", "Blox Fruit", "Any"},
            State.SelectedWeapon,
            function(value)
                State.SelectedWeapon = value
            end
        )

    elseif name == "Farming Other" then
        CreateSection(
            "Utility Farming",
            "Extra farming-related switches"
        )

        AddToggle(
            "Auto Random Fruit",
            "Keep the shared random-fruit setting enabled.",
            Config.Items.AutoRandomFruit,
            "RandomFruitToggle"
        )

        AddToggle(
            "Auto Ken",
            "Keep the shared AutoKen setting enabled.",
            Config.AutoKen,
            "AutoKenToggle"
        )

        AddToggle(
            "Auto Sea 2",
            "Keep the shared second-sea progression state.",
            Config.AutoSea2,
            "AutoSea2Toggle"
        )

        AddToggle(
            "Auto Sea 3",
            "Keep the shared third-sea progression state.",
            Config.AutoSea3,
            "AutoSea3Toggle"
        )

    elseif name == "Fruit" then
        CreateSection(
            "Fruit",
            "Finder, ESP and collection"
        )

        AddToggle(
            "Fruit Finder",
            "Highlight fruits detected in the workspace.",
            State.FruitFinder,
            "Fruit Finder"
        )

        AddToggle(
            "Auto Collect Fruit",
            "Move to the closest detected fruit.",
            State.AutoCollectFruit,
            "Auto Collect Fruit"
        )

        AddToggle(
            "Fruit ESP",
            "Highlight fruit objects through walls.",
            State.ESPFruits,
            "ESP Fruits"
        )

    elseif name == "Raid" then
        CreateSection(
            "Raid",
            "Raid-related shared states"
        )

        AddToggle(
            "Auto Raid",
            "Enable the unified raid state.",
            State.AutoRaid,
            "Auto Raid"
        )

        AddToggle(
            "Auto Raid Ice",
            "Keep the shared ice raid configuration active.",
            false,
            "AutoRaidIce"
        )

        AddSlider(
            "Ice Fragments",
            "Target amount for the shared ice raid setting.",
            500,
            10000,
            Config.AutoRaidIce_TargetFragments,
            function(value)
                Config.AutoRaidIce_TargetFragments = math.floor(value / 100) * 100
            end
        )

    elseif name == "Dungeon" then
        CreateSection(
            "Dungeon",
            "Dungeon session controls"
        )

        AddToggle(
            "Auto Dungeon",
            "Enable the dungeon state.",
            State.AutoDungeon,
            "Auto Dungeon"
        )

        AddButton(
            "Reset Character",
            "Use a reset when a fresh dungeon state is needed.",
            "Reset Character",
            "Reset"
        )

    elseif name == "Sea Event" then
        CreateSection(
            "Sea Events",
            "Sea event automation states"
        )

        AddToggle(
            "Sea Event",
            "Enable the combined sea-event state.",
            State.AutoSeaEvent,
            "Sea Event"
        )

        AddButton(
            "First Sea",
            "Teleport to First Sea.",
            "Teleport First Sea",
            "Go"
        )

        AddButton(
            "Second Sea",
            "Teleport to Second Sea.",
            "Teleport Second Sea",
            "Go"
        )

        AddButton(
            "Third Sea",
            "Teleport to Third Sea.",
            "Teleport Third Sea",
            "Go"
        )

    elseif name == "ESP" then
        CreateSection(
            "ESP",
            "One unified ESP runtime"
        )

        AddToggle(
            "ESP Players",
            "Highlight other players.",
            State.ESPPlayers,
            "ESP Players"
        )

        AddToggle(
            "ESP NPC",
            "Highlight detected NPC enemies.",
            State.ESPNPC,
            "ESP NPC"
        )

        AddToggle(
            "ESP Boss",
            "Highlight detected boss enemies.",
            State.ESPBoss,
            "ESP Boss"
        )

        AddToggle(
            "ESP Fruits",
            "Highlight fruits.",
            State.ESPFruits,
            "ESP Fruits"
        )

        AddToggle(
            "ESP Chests",
            "Highlight objects with chest names.",
            State.ESPChests,
            "ESP Chests"
        )

    elseif name == "Teleport" then
        CreateSection(
            "Teleport",
            "Fast travel points"
        )

        local teleportList = {
            {"First Sea", "Teleport to the main First Sea point."},
            {"Second Sea", "Teleport to the main Second Sea point."},
            {"Third Sea", "Teleport to the main Third Sea point."},

            {"Pirate Starter", "Starter island."},
            {"Jungle", "Jungle area."},
            {"Frozen Village", "Frozen Village."},
            {"Colosseum", "Colosseum."},

            {"Kingdom of Rose", "Second Sea main area."},
            {"Cafe", "Cafe area."},
            {"Hot and Cold", "Hot and Cold."},
            {"Forgotten Island", "Forgotten Island."},

            {"Castle", "Third Sea castle area."},
            {"Hydra Island", "Hydra Island."},
            {"Mansion", "Mansion area."},
            {"Great Tree", "Great Tree."},
        }

        for _, entry in ipairs(teleportList) do
            local placeName = entry[1]
            local desc = entry[2]
            local callbackName = "TP:" .. placeName

            RegisterFeature(callbackName, function()
                TeleportTo(Teleports[placeName])
            end)

            AddButton(
                placeName,
                desc,
                callbackName,
                "Go"
            )
        end

    elseif name == "Settings" then
        CreateSection(
            "Interface",
            "MeizuHub appearance and behavior"
        )

        AddSlider(
            "UI Scale",
            "Adjust the entire window size.",
            0.75,
            1.15,
            State.UIScale,
            function(value)
                State.UIScale = math.floor(value * 100) / 100
                if MainScale then
                    MainScale.Scale = State.UIScale
                end
            end
        )

        AddSlider(
            "Transparency",
            "Adjust panel glass transparency.",
            0.02,
            0.30,
            State.GlassTransparency,
            function(value)
                State.GlassTransparency = math.floor(value * 100) / 100
                if MainRoot then
                    MainRoot.BackgroundTransparency = State.GlassTransparency
                end
            end
        )

        AddToggle(
            "UI Animation",
            "Enable smooth button and tab tweens.",
            State.UIAnimation,
            "UIAnimation"
        )

        AddToggle(
            "Notifications",
            "Enable the unified notification system.",
            State.Notifications,
            "Notifications"
        )

        AddToggle(
            "Compact UI",
            "Collapse the sidebar for a wider content view.",
            false,
            "CompactUI"
        )

        AddButton(
            "Reset UI",
            "Restore the default visual state.",
            "Reset UI",
            "Reset"
        )

        AddDropdown(
            "Theme",
            "Default theme is Purple × Blue.",
            {"Purple × Blue"},
            "Purple × Blue",
            function()
                Notify("MEIZU HUB", "Purple × Blue is the active theme.", 2)
            end
        )

    elseif name == "Server" then
        CreateSection(
            "Server",
            "Session and server utility controls"
        )

        AddButton(
            "Rejoin Server",
            "Reconnect to the current server instance.",
            "Rejoin Server",
            "Rejoin"
        )

        AddButton(
            "Server Hop",
            "Teleport to another server session.",
            "Server Hop",
            "Hop"
        )

        AddButton(
            "Server Information",
            "Show current job and player count.",
            "NotifyServerInfo",
            "View"
        )
    end

    RefreshCardFilter()

    local layout = Page:FindFirstChildOfClass("UIListLayout")
    if layout then
        Page.CanvasSize = UDim2.fromOffset(
            0,
            layout.AbsoluteContentSize.Y + 12
        )
    end
end

--============================================================
-- EXTRA FEATURE CALLBACKS USED BY UI
--============================================================
RegisterFeature("NotifyPlayerInfo", function()
    local data = Player:FindFirstChild("Data")
    local level = data and data:FindFirstChild("Level")
    local race = data and data:FindFirstChild("Race")
    local beli = data and data:FindFirstChild("Beli")
    local fragments = data and data:FindFirstChild("Fragments")

    local message = string.format(
        "Level %s • Race %s • Beli %s • Frag %s",
        tostring(level and level.Value or 0),
        tostring(race and race.Value or "?"),
        tostring(beli and beli.Value or 0),
        tostring(fragments and fragments.Value or 0)
    )

    Notify("Player Information", message, 4)
end)

RegisterFeature("NotifyServerInfo", function()
    local playerCount = #Players:GetPlayers()

    Notify(
        "Server Information",
        string.format(
            "Place %s • Players %d • Job %s",
            tostring(game.PlaceId),
            playerCount,
            tostring(game.JobId)
        ),
        4
    )
end)

RegisterFeature("NotifyVersion", function()
    Notify(
        "Hub Version",
        "MEIZU HUB • Single-file Purple × Blue build.",
        3
    )
end)

RegisterFeature("NotifyKeyStatus", function()
    Notify(
        "Key Status",
        State.KeyVerified
            and "Key hợp lệ và HWID đã được xác thực."
            or "Key chưa được xác thực.",
        3
    )
end)

RegisterFeature("RandomFruit", function()
    local remote = FindRemote()
    if remote then
        pcall(function()
            remote:InvokeServer("Cousin", "Buy")
        end)
        Notify("MEIZU HUB", "Đã gửi yêu cầu mua trái ngẫu nhiên.", 2.5)
    else
        Notify("MEIZU HUB", "Không tìm thấy remote mua trái.", 2.5)
    end
end)

RegisterFeature("RandomFruitToggle", function(enabled)
    Config.Items.AutoRandomFruit = enabled
end)

RegisterFeature("AutoKenToggle", function(enabled)
    Config.AutoKen = enabled
    State.BringMobs = State.BringMobs
end)

RegisterFeature("AutoSea2Toggle", function(enabled)
    Config.AutoSea2 = enabled
end)

RegisterFeature("AutoSea3Toggle", function(enabled)
    Config.AutoSea3 = enabled
end)

RegisterFeature("AutoRaidIce", function(enabled)
    Config.AutoRaidIce_TargetFragments = enabled
        and math.max(Config.AutoRaidIce_TargetFragments, 500)
        or Config.AutoRaidIce_TargetFragments
end)

RegisterFeature("UIAnimation", function(enabled)
    State.UIAnimation = enabled
end)

RegisterFeature("Notifications", function(enabled)
    State.Notifications = enabled
end)

RegisterFeature("CompactUI", function(enabled)
    if not Sidebar or not Body then
        return
    end

    if enabled then
        Sidebar.Visible = false
        Body.Position = UDim2.fromOffset(0, 58)
        Body.Size = UDim2.new(1, 0, 1, -58)
    else
        Sidebar.Visible = true
        Body.Position = UDim2.fromOffset(174, 58)
        Body.Size = UDim2.new(1, -174, 1, -58)
    end
end)

RegisterFeature("Reset UI", function()
    State.UIAnimation = true
    State.UIScale = 1.0
    State.GlassTransparency = 0.08
    State.Notifications = true

    if MainScale then
        MainScale.Scale = 1.0
    end

    if MainRoot then
        MainRoot.BackgroundTransparency = 0.08
    end

    Notify("MEIZU HUB", "UI đã được đặt lại.", 2)
end)

--============================================================
-- BUILD MAIN HUB
-- Only called after valid key.
--============================================================
local function BuildMainHub()
    if not KeyGate or not KeyGate.Parent then
        return
    end

    KeyGate:Destroy()

    MainRoot = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.54),
        Size = UDim2.fromOffset(780, 500),
        BackgroundColor3 = Config.Theme.Background,
        BackgroundTransparency = State.GlassTransparency,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, Gui)

    Corner(MainRoot, 24)
    Stroke(MainRoot, Config.Theme.Purple, 0.62, 1)

    local outerGradient = Gradient(
        MainRoot,
        Config.Theme.Purple,
        Config.Theme.Blue,
        22
    )
    outerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.92),
        NumberSequenceKeypoint.new(0.48, 1),
        NumberSequenceKeypoint.new(1, 0.94),
    })

    MainScale = Create("UIScale", {
        Scale = State.UIScale,
    }, MainRoot)

    local Header = Create("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = Config.Theme.Panel,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
    }, MainRoot)

    Corner(Header, 24)

    local HeaderMask = Create("Frame", {
        Position = UDim2.fromOffset(0, 30),
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Config.Theme.Panel,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
    }, Header)

    local HeaderGradient = Gradient(
        Header,
        Config.Theme.Purple,
        Config.Theme.Blue,
        0
    )
    HeaderGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.92),
        NumberSequenceKeypoint.new(0.55, 1),
        NumberSequenceKeypoint.new(1, 0.90),
    })

    local LogoDot = Create("Frame", {
        Position = UDim2.fromOffset(18, 18),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = Config.Theme.Purple,
        BorderSizePixel = 0,
    }, Header)

    Corner(LogoDot, 10)
    Gradient(LogoDot, Config.Theme.Purple, Config.Theme.Blue, 0)

    local LogoInner = Create("Frame", {
        Position = UDim2.fromOffset(5, 5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = Config.Theme.Text,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
    }, LogoDot)

    Corner(LogoInner, 5)

    Create("TextLabel", {
        Position = UDim2.fromOffset(48, 8),
        Size = UDim2.fromOffset(220, 24),
        BackgroundTransparency = 1,
        Text = "MEIZU HUB",
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Header)

    Create("TextLabel", {
        Position = UDim2.fromOffset(49, 31),
        Size = UDim2.fromOffset(220, 16),
        BackgroundTransparency = 1,
        Text = "Blox Fruit",
        TextColor3 = Config.Theme.SubText,
        Font = Enum.Font.GothamMedium,
        TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Header)

    local ControlHolder = Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 11),
        Size = UDim2.fromOffset(156, 34),
        BackgroundTransparency = 1,
    }, Header)

    local function WindowButton(text, callback)
        local button = Create("TextButton", {
            Size = UDim2.fromOffset(46, 32),
            BackgroundColor3 = Config.Theme.Panel2,
            BackgroundTransparency = 0.20,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = text,
            TextColor3 = Config.Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 9,
        }, ControlHolder)

        Corner(button, 12)
        Stroke(button, Config.Theme.Purple, 0.82, 1)

        button.MouseButton1Click:Connect(function()
            Pulse(
                button,
                UDim2.fromOffset(46, 32),
                UDim2.fromOffset(42, 30)
            )

            if callback then
                pcall(callback)
            end
        end)

        return button
    end

    SidebarToggle = WindowButton("Menu", function()
        local visible = not Sidebar.Visible
        Sidebar.Visible = visible

        if visible then
            Body.Position = UDim2.fromOffset(174, 58)
            Body.Size = UDim2.new(1, -174, 1, -58)
        else
            Body.Position = UDim2.fromOffset(0, 58)
            Body.Size = UDim2.new(1, 0, 1, -58)
        end
    end)

    SettingsButton = WindowButton("⚙", function()
        if TabButtons.Settings then
            ShowTab("Settings")
        end
    end)

    MinimizeButton = WindowButton("—", function()
        State.UIOpen = not State.UIOpen
        Body.Visible = State.UIOpen

        if State.UIOpen then
            MainRoot.Size = UDim2.fromOffset(780, 500)
        else
            MainRoot.Size = UDim2.fromOffset(780, 58)
        end
    end)

    WindowCloseButton = WindowButton("×", function()
        State.UIVisible = false
        State.UIOpen = false
        DestroyGui()
    end)

    local controlLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, ControlHolder)

    Body = Create("Frame", {
        Position = UDim2.fromOffset(174, 58),
        Size = UDim2.new(1, -174, 1, -58),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, MainRoot)

    Sidebar = Create("Frame", {
        Position = UDim2.fromOffset(0, 58),
        Size = UDim2.fromOffset(174, 442),
        BackgroundColor3 = Config.Theme.Panel,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, MainRoot)

    Corner(Sidebar, 0)
    Stroke(Sidebar, Config.Theme.Purple, 0.88, 1)

    local SidebarTitle = Create("TextLabel", {
        Position = UDim2.fromOffset(14, 13),
        Size = UDim2.new(1, -28, 0, 22),
        BackgroundTransparency = 1,
        Text = "CATEGORIES",
        TextColor3 = Config.Theme.SubText,
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Sidebar)

    local Nav = Create("ScrollingFrame", {
        Position = UDim2.fromOffset(10, 42),
        Size = UDim2.new(1, -20, 1, -52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Theme.Blue,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, Sidebar)

    local NavLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, Nav)

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
    }, Nav)

    local ContentHeader = Create("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundTransparency = 1,
    }, Body)

    PageTitle = Create("TextLabel", {
        Position = UDim2.fromOffset(10, 9),
        Size = UDim2.new(0, 280, 0, 24),
        BackgroundTransparency = 1,
        Text = CurrentTab,
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamBlack,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, ContentHeader)

    local Subtitle = Create("TextLabel", {
        Position = UDim2.fromOffset(11, 31),
        Size = UDim2.fromOffset(250, 16),
        BackgroundTransparency = 1,
        Text = "MEIZU HUB • PURPLE × BLUE",
        TextColor3 = Config.Theme.SubText,
        Font = Enum.Font.GothamMedium,
        TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, ContentHeader)

    local SearchWrap = Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 9),
        Size = UDim2.fromOffset(210, 38),
        BackgroundColor3 = Config.Theme.Panel2,
        BackgroundTransparency = 0.22,
        BorderSizePixel = 0,
    }, ContentHeader)

    Corner(SearchWrap, 15)
    Stroke(SearchWrap, Config.Theme.Purple, 0.83, 1)

    SearchBox = Create("TextBox", {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -24, 1, 0),
        BackgroundTransparency = 1,
        PlaceholderText = "Search MeizuHub...",
        PlaceholderColor3 = Config.Theme.SubText,
        Text = "",
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, SearchWrap)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        State.Search = SearchBox.Text
        RefreshCardFilter()
    end)

    Page = Create("ScrollingFrame", {
        Position = UDim2.fromOffset(10, 62),
        Size = UDim2.new(1, -20, 1, -70),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Theme.Blue,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, Body)

    local PageLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, Page)

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 10),
    }, Page)

    NotificationRoot = Create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.fromOffset(320, 260),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, Gui)

    Create("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, NotificationRoot)

    local Tabs = {
        "Home",
        "Shop",
        "Status",
        "Local Player",
        "Farming",
        "Stack Farming",
        "Farming Other",
        "Fruit",
        "Raid",
        "Dungeon",
        "Sea Event",
        "ESP",
        "Teleport",
        "Settings",
        "Server",
    }

    for index, tabName in ipairs(Tabs) do
        local button = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Config.Theme.Panel2,
            BackgroundTransparency = 0.72,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = tabName,
            TextColor3 = Config.Theme.SubText,
            Font = Enum.Font.GothamMedium,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = index,
        }, Nav)

        Corner(button, 12)
        Stroke(button, Config.Theme.Purple, 0.86, 1)

        local icon = Create("Frame", {
            Position = UDim2.fromOffset(10, 9),
            Size = UDim2.fromOffset(15, 15),
            BackgroundColor3 = Config.Theme.Purple,
            BackgroundTransparency = 0.55,
            BorderSizePixel = 0,
        }, button)

        Corner(icon, 5)
        Gradient(icon, Config.Theme.Purple, Config.Theme.Blue, 0)

        Create("TextLabel", {
            Position = UDim2.fromOffset(31, 0),
            Size = UDim2.new(1, -38, 1, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = Config.Theme.SubText,
            Font = Enum.Font.GothamMedium,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, button)

        button.MouseButton1Click:Connect(function()
            Pulse(
                button,
                UDim2.new(1, 0, 0, 34),
                UDim2.new(1, -5, 0, 32)
            )

            ShowTab(tabName)
        end)

        TabButtons[tabName] = button
    end

    NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Nav.CanvasSize = UDim2.fromOffset(
            0,
            NavLayout.AbsoluteContentSize.Y + 10
        )
    end)

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(
            0,
            PageLayout.AbsoluteContentSize.Y + 12
        )
    end)

    local dragging = false
    local dragStart
    local startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = true
            dragStart = input.Position
            startPos = MainRoot.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch
        then
            return
        end

        local delta = input.Position - dragStart

        MainRoot.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = false
        end
    end)

    local function ResizeForViewport()
        if not MainRoot or not MainRoot.Parent then
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then
            return
        end

        local viewport = camera.ViewportSize
        local fitX = (viewport.X - 20) / 780
        local fitY = (viewport.Y - 20) / 500
        local fit = Clamp(math.min(fitX, fitY), 0.66, 1)

        if not State.UIScale or State.UIScale == 1 then
            MainScale.Scale = fit
        else
            MainScale.Scale = Clamp(fit * State.UIScale, 0.6, 1.15)
        end
    end

    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ResizeForViewport)

    RegisterFeature("ResizeForViewport", ResizeForViewport)

    ResizeForViewport()

    ShowTab("Home")

    MainRoot.Position = UDim2.fromScale(0.5, 0.58)
    MainRoot.BackgroundTransparency = 1

    Tween(MainRoot, 0.32, {
        Position = UDim2.fromScale(0.5, 0.50),
        BackgroundTransparency = State.GlassTransparency,
    })

    Notify(
        "MEIZU HUB",
        "Key hợp lệ • Main Menu đã sẵn sàng.",
        3
    )
end

RegisterFeature("BuildMainHub", BuildMainHub)

--============================================================
-- INIT ORDER
-- Services
--   ↓
-- Config
--   ↓
-- State
--   ↓
-- Get Key System
--   ↓
-- Verify Key
--   ↓
-- Key valid
--   ↓
-- Initialize Features
--   ↓
-- Register Callbacks
--   ↓
-- Build Main Menu
--   ↓
-- Connect UI
--   ↓
-- Render Home
--============================================================

-- Initialize feature runtime only after the key is accepted.
local function InitializeFeatures()
    StartRuntimeLoops()
    ApplyCharacterSettings()
    OptimizeGraphics(State.LowGraphics)
    EnsureAntiAFK()
end

-- Key verification button.
Verify.MouseButton1Click:Connect(function()
    local key = Trim(KeyBox.Text)

    if key == "" then
        key = LoadKey()
        KeyBox.Text = key
    end

    if key == "" then
        KeyStatus.Text = "●  Chưa nhập key"
        KeyStatus.TextColor3 = Config.Theme.Red
        KeyResult.Text = "Nhập key trước khi xác thực."
        return
    end

    Verify.Active = false
    Verify.AutoButtonColor = false

    KeyStatus.Text = "●  Đang xác thực..."
    KeyStatus.TextColor3 = Config.Theme.Blue
    KeyResult.Text = "Đang kiểm tra key + HWID..."

    task.spawn(function()
        local ok, message = VerifyKey(key)

        if ok then
            SaveKey(key)
            State.KeyVerified = true

            KeyStatus.Text = "●  Key hợp lệ"
            KeyStatus.TextColor3 = Config.Theme.Green
            KeyResult.Text = message

            InitializeFeatures()

            task.wait(0.25)

            if Gui and Gui.Parent then
                BuildMainHub()
            end
        else
            KeyStatus.Text = "●  Xác thực thất bại"
            KeyStatus.TextColor3 = Config.Theme.Red
            KeyResult.Text = message
            Verify.Active = true
            Verify.AutoButtonColor = false
        end
    end)

    Pulse(
        Verify,
        UDim2.new(1, 0, 0, 46),
        UDim2.new(1, -8, 0, 43)
    )
end)

--============================================================
-- KEY GATE ENTRANCE
--============================================================
KeyGate.Position = UDim2.fromScale(0.5, 0.56)
KeyGate.BackgroundTransparency = 1

Tween(KeyGate, 0.34, {
    Position = UDim2.fromScale(0.5, 0.50),
    BackgroundTransparency = 0.08,
})

--============================================================
-- END
--============================================================
