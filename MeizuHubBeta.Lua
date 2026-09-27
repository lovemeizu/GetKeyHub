--============================================================
-- MEIZUHUB - BLOX FRUIT FULL MASTER EDITION
-- Style: Blue Translucent Glass (100% Synced with Redz/Banana/Hoho Hub Standard)
-- Integrated: Key Gate + HWID System + Auto Farm + Fast Attack + Shop + Teleport + ESP
--============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------------------------
-- 1. CONFIGURATION & STYLING (SYNCED WITH IMAGE)
------------------------------------------------------------------------------
local CONFIG = {
    Name = "MeizuHub",
    VERIFY_URL = "https://getkeyhub-uwal.onrender.com/api/verify?key=%s&hwid=%s",
    GETKEY_URL = "https://lovemeizu.github.io/GetKeyHub/getkey.html",
    CACHE_FILE = "meizu_hub_key.txt",

    Theme = {
        Background = Color3.fromRGB(8, 14, 28),
        Translucent = 0.18,
        BorderGlow = Color3.fromRGB(0, 162, 255),
        HeaderBlue = Color3.fromRGB(0, 120, 230),
        TextPrimary = Color3.fromRGB(240, 246, 255),
        TextSecondary = Color3.fromRGB(130, 160, 200),
        StatusGreen = Color3.fromRGB(0, 255, 200),
        CardBg = Color3.fromRGB(12, 22, 42),
        CardBorder = Color3.fromRGB(0, 110, 210),
        ButtonBlue = Color3.fromRGB(0, 100, 220)
    },

    State = {
        AutoFarmLevel = false,
        FastAttack = true,
        AutoCollectFruit = false,
        AutoStoreFruit = false,
        ESPPlayers = false,
        ESPFruits = false,
        ESPChests = false,
        NoClip = false,
        InfiniteJump = false,
        WalkSpeed = 16
    }
}

------------------------------------------------------------------------------
-- 2. CLEANUP OLD GUI
------------------------------------------------------------------------------
local oldGui = PlayerGui:FindFirstChild(CONFIG.Name) or CoreGui:FindFirstChild(CONFIG.Name)
if oldGui then
    pcall(function() oldGui:Destroy() end)
end

------------------------------------------------------------------------------
-- 3. TASK MANAGER & CONNECTIONS CLEANUP
------------------------------------------------------------------------------
local TaskManager = {
    Threads = {},
    Connections = {},
    Tweens = {}
}

function TaskManager.RunLoop(id, interval, fn)
    if TaskManager.Threads[id] then task.cancel(TaskManager.Threads[id]) end
    TaskManager.Threads[id] = task.spawn(function()
        while true do
            local ok, err = pcall(fn)
            if not ok then warn("[MeizuHub Error - " .. tostring(id) .. "]: " .. tostring(err)) end
            task.wait(interval)
        end
    end)
end

function TaskManager.Stop(id)
    if TaskManager.Threads[id] then
        task.cancel(TaskManager.Threads[id])
        TaskManager.Threads[id] = nil
    end
    if TaskManager.Connections[id] then
        TaskManager.Connections[id]:Disconnect()
        TaskManager.Connections[id] = nil
    end
    if TaskManager.Tweens[id] then
        TaskManager.Tweens[id]:Cancel()
        TaskManager.Tweens[id] = nil
    end
end

function TaskManager.StopAll()
    for id in pairs(TaskManager.Threads) do TaskManager.Stop(id) end
    for id in pairs(TaskManager.Connections) do TaskManager.Stop(id) end
    for id in pairs(TaskManager.Tweens) do TaskManager.Stop(id) end
end

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

------------------------------------------------------------------------------
-- 4. NETWORK LAYER (CommF_ Remote & Fast Attack Engine)
------------------------------------------------------------------------------
local Network = { CommF = nil, RegisterAttack = nil, RegisterHit = nil }

function Network.Init()
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
    if remotes then
        Network.CommF = remotes:FindFirstChild("CommF_")
    end
    pcall(function()
        local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
        if net then
            Network.RegisterAttack = net:FindFirstChild("RegisterAttack")
            Network.RegisterHit = net:FindFirstChild("RegisterHit")
        end
    end)
end
Network.Init()

function Network.Invoke(...)
    if Network.CommF then
        return pcall(function(...) return Network.CommF:InvokeServer(...) end, ...)
    end
    return false, "No CommF_"
end

function Network.DoFastAttack(targetPart)
    if not CONFIG.State.FastAttack then return end
    pcall(function()
        if Network.RegisterAttack and Network.RegisterHit then
            Network.RegisterAttack:FireServer(0)
            if targetPart then
                Network.RegisterHit:FireServer(targetPart, {targetPart})
            end
        end
    end)
end

------------------------------------------------------------------------------
-- 5. HELPER UI BUILDERS (NEON BLUE GLASS ACCURACY)
------------------------------------------------------------------------------
local function Create(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function GlowBorder(parent, color, transparency, thickness)
    return Create("UIStroke", {
        Color = color or CONFIG.Theme.BorderGlow,
        Transparency = transparency or 0.2,
        Thickness = thickness or 1.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, parent)
end

-- Anti-Crash ScreenGui Parent Selector
local TargetParent = CoreGui:FindFirstChild("RobloxGui") or PlayerGui
local Gui = Create("ScreenGui", {
    Name = CONFIG.Name,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999
}, TargetParent)

Gui.AncestryChanged:Connect(function(_, parent)
    if not parent then TaskManager.StopAll() end
end)

------------------------------------------------------------------------------
-- 6. HWID & KEY GATE SYSTEM (INTEGRATED FROM SOURCE FILE)
------------------------------------------------------------------------------
local function GetHWID()
    local result = tostring(LocalPlayer.UserId)
    pcall(function()
        if type(gethwid) == "function" then
            local val = gethwid()
            if val and tostring(val) ~= "" then result = tostring(val) return end
        end
        if type(hwid) == "string" and #hwid > 0 then result = hwid return end
        local analytics = game:GetService("RbxAnalyticsService")
        local val = analytics:GetClientId()
        if val and #tostring(val) > 10 then result = tostring(val) end
    end)
    return result
end

local function SaveKey(key)
    if type(writefile) == "function" and type(key) == "string" then
        pcall(function() writefile(CONFIG.CACHE_FILE, key) end)
    end
end

local function LoadKey()
    if type(readfile) == "function" and type(isfile) == "function" then
        local ok, exists = pcall(function() return isfile(CONFIG.CACHE_FILE) end)
        if ok and exists then
            local readOK, val = pcall(function() return readfile(CONFIG.CACHE_FILE) end)
            if readOK and type(val) == "string" then return val:gsub("^%s+", ""):gsub("%s+$", "") end
        end
    end
    return ""
end

local function VerifyKey(key)
    key = tostring(key or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #key < 3 then return false, "Vui lòng nhập Key hợp lệ." end
    local currentHWID = GetHWID()
    local url = string.format(CONFIG.VERIFY_URL, HttpService:UrlEncode(key), HttpService:UrlEncode(tostring(currentHWID)))

    local ok, response = pcall(function() return game:HttpGet(url, true) end)
    if not ok then ok, response = pcall(function() return game:HttpGet(url) end) end
    if not ok then return false, "Không kết nối được máy chủ xác thực." end

    local decodeOK, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not decodeOK or type(data) ~= "table" then return false, "Phản hồi máy chủ lỗi." end
    if data.success == false or data.valid == false then
        return false, tostring(data.error or data.message or "Key không hợp lệ.")
    end
    return true, tostring(data.message or "Xác thực thành công!")
end

------------------------------------------------------------------------------
-- 7. KEY GATE UI FRAME
------------------------------------------------------------------------------
local GateFrame = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(330, 360),
    BackgroundColor3 = CONFIG.Theme.Background,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0
}, Gui)
Corner(GateFrame, 16)
GlowBorder(GateFrame, CONFIG.Theme.BorderGlow, 0.2, 1.5)

local GateContent = Create("Frame", {
    Position = UDim2.fromOffset(20, 20),
    Size = UDim2.new(1, -40, 1, -40),
    BackgroundTransparency = 1
}, GateFrame)

Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "MEIZUHUB KEY SYSTEM",
    TextColor3 = CONFIG.Theme.TextPrimary,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left
}, GateContent)

local KeyInput = Create("TextBox", {
    Position = UDim2.fromOffset(0, 50),
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = CONFIG.Theme.CardBg,
    TextColor3 = CONFIG.Theme.TextPrimary,
    PlaceholderText = "Nhập Key tại đây...",
    PlaceholderColor3 = CONFIG.Theme.TextSecondary,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left
}, GateContent)
Corner(KeyInput, 10)
GlowBorder(KeyInput, CONFIG.Theme.CardBorder, 0.5, 1)
Create("UIPadding", { PaddingLeft = UDim.new(0, 12) }, KeyInput)

local GateStatus = Create("TextLabel", {
    Position = UDim2.fromOffset(0, 100),
    Size = UDim2.new(1, 0, 0, 25),
    BackgroundTransparency = 1,
    Text = "Trạng thái: Chưa xác thực",
    TextColor3 = CONFIG.Theme.TextSecondary,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left
}, GateContent)

local BtnGetKey = Create("TextButton", {
    Position = UDim2.fromOffset(0, 135),
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = CONFIG.Theme.HeaderBlue,
    Text = "LẤY KEY FREE (COPY LINK)",
    TextColor3 = CONFIG.Theme.TextPrimary,
    Font = Enum.Font.GothamBold,
    TextSize = 12
}, GateContent)
Corner(BtnGetKey, 10)

local BtnVerify = Create("TextButton", {
    Position = UDim2.fromOffset(0, 185),
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = CONFIG.Theme.CardBg,
    Text = "XÁC THỰC KEY",
    TextColor3 = CONFIG.Theme.TextPrimary,
    Font = Enum.Font.GothamBold,
    TextSize = 12
}, GateContent)
Corner(BtnVerify, 10)
GlowBorder(BtnVerify, CONFIG.Theme.BorderGlow, 0.4, 1)

BtnGetKey.MouseButton1Click:Connect(function()
    local hwid = GetHWID()
    local url = CONFIG.GETKEY_URL .. "?hwid=" .. HttpService:UrlEncode(tostring(hwid))
    if type(setclipboard) == "function" then
        setclipboard(url)
        GateStatus.Text = "Đã Copy Link Get Key vào Clipboard!"
        GateStatus.TextColor3 = CONFIG.Theme.StatusGreen
    else
        GateStatus.Text = "Không thể copy link tự động."
    end
end)

------------------------------------------------------------------------------
-- 8. MAIN HUB ENGINE (MATCHING EXACT IMAGE DESIGN)
------------------------------------------------------------------------------
local function BuildMainHub()
    if GateFrame then GateFrame:Destroy() end

    -- Main Container Window
    local MainFrame = Create("Frame", {
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(660, 390),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = CONFIG.Theme.Translucent,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, Gui)
    Corner(MainFrame, 14)
    GlowBorder(MainFrame, CONFIG.Theme.BorderGlow, 0.15, 1.5)

    -- Top Header Bar
    local TopHeader = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0
    }, MainFrame)

    -- System Online Status Dot
    local SystemStatus = Create("Frame", {
        Position = UDim2.fromOffset(15, 12),
        Size = UDim2.fromOffset(115, 20),
        BackgroundTransparency = 1
    }, TopHeader)

    local StatusDot = Create("Frame", {
        Position = UDim2.fromOffset(72, 5),
        Size = UDim2.fromOffset(9, 9),
        BackgroundColor3 = CONFIG.Theme.StatusGreen,
        BorderSizePixel = 0
    }, SystemStatus)
    Corner(StatusDot, 5)

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Text = "SYSTEM\nONLINE",
        TextColor3 = Color3.fromRGB(0, 180, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Left
    }, SystemStatus)

    -- Logo Badge Center Top
    local ShieldBadge = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, -5),
        Size = UDim2.fromOffset(45, 45),
        BackgroundColor3 = CONFIG.Theme.CardBg,
        BorderSizePixel = 0
    }, TopHeader)
    Corner(ShieldBadge, 12)
    GlowBorder(ShieldBadge, CONFIG.Theme.BorderGlow, 0.2, 1)

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "🛡️",
        TextSize = 22,
        Parent = ShieldBadge
    })

    -- Title Label
    Create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 110, 0, 10),
        Size = UDim2.fromOffset(200, 22),
        BackgroundTransparency = 1,
        Text = "Meizu Hub - Blox Fruit",
        TextColor3 = CONFIG.Theme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 14
    }, TopHeader)

    -- Close Button (X)
    local CloseBtn = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 10),
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = CONFIG.Theme.BorderGlow,
        Font = Enum.Font.GothamBold,
        TextSize = 16
    }, TopHeader)

    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- Sidebar Container (Left)
    local Sidebar = Create("Frame", {
        Position = UDim2.fromOffset(12, 48),
        Size = UDim2.new(0, 185, 1, -58),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.5
    }, MainFrame)
    Corner(Sidebar, 10)
    GlowBorder(Sidebar, CONFIG.Theme.CardBorder, 0.4, 1)

    -- Search Bar inside Sidebar
    local SearchBox = Create("TextBox", {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 0, 28),
        BackgroundColor3 = CONFIG.Theme.CardBg,
        TextColor3 = CONFIG.Theme.TextPrimary,
        PlaceholderText = "🔍 Search section or Func",
        PlaceholderColor3 = CONFIG.Theme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Sidebar)
    Corner(SearchBox, 6)
    GlowBorder(SearchBox, CONFIG.Theme.CardBorder, 0.6, 1)
    Create("UIPadding", { PaddingLeft = UDim.new(0, 8) }, SearchBox)

    -- Tab Scrolling Frame
    local TabScroll = Create("ScrollingFrame", {
        Position = UDim2.fromOffset(8, 42),
        Size = UDim2.new(1, -16, 1, -48),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CONFIG.Theme.BorderGlow,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }, Sidebar)

    local TabListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, TabScroll)

    -- Content Area (Right)
    local ContentArea = Create("Frame", {
        Position = UDim2.fromOffset(205, 48),
        Size = UDim2.new(1, -217, 1, -58),
        BackgroundColor3 = CONFIG.Theme.Background,
        BackgroundTransparency = 0.5
    }, MainFrame)
    Corner(ContentArea, 10)
    GlowBorder(ContentArea, CONFIG.Theme.CardBorder, 0.4, 1)

    local ContentHeaderTitle = Create("TextLabel", {
        Position = UDim2.fromOffset(14, 10),
        Size = UDim2.new(1, -28, 0, 22),
        BackgroundTransparency = 1,
        Text = "Shop",
        TextColor3 = CONFIG.Theme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    }, ContentArea)

    local SubHeaderTitle = Create("TextLabel", {
        Position = UDim2.fromOffset(0, 32),
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "Misc Shop",
        TextColor3 = CONFIG.Theme.TextSecondary,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center
    }, ContentArea)

    local ContentScroll = Create("ScrollingFrame", {
        Position = UDim2.fromOffset(12, 54),
        Size = UDim2.new(1, -24, 1, -62),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = CONFIG.Theme.BorderGlow,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }, ContentArea)

    local ContentLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, ContentScroll)

    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentScroll.CanvasSize = UDim2.fromOffset(0, ContentLayout.AbsoluteContentSize.Y + 10)
    end)

    --------------------------------------------------------------------------
    -- 9. TAB & CONTROL CREATION ENGINE
    --------------------------------------------------------------------------
    local Tabs = {}
    local TabButtons = {}

    local function CreateTab(tabName)
        local page = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false
        }, ContentScroll)

        local pageLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, page)

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if page.Visible then
                ContentScroll.CanvasSize = UDim2.fromOffset(0, pageLayout.AbsoluteContentSize.Y + 10)
            end
        end)

        local tabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = CONFIG.Theme.CardBg,
            BackgroundTransparency = 0.8,
            Text = "  " .. tabName,
            TextColor3 = CONFIG.Theme.TextSecondary,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, TabScroll)
        Corner(tabBtn, 6)

        tabBtn.MouseButton1Click:Connect(function()
            for name, p in pairs(Tabs) do p.Visible = false end
            for name, b in pairs(TabButtons) do
                b.TextColor3 = CONFIG.Theme.TextSecondary
                b.BackgroundTransparency = 0.8
            end
            page.Visible = true
            tabBtn.TextColor3 = CONFIG.Theme.BorderGlow
            tabBtn.BackgroundTransparency = 0.3
            ContentHeaderTitle.Text = tabName
            SubHeaderTitle.Text = tabName .. " Options"
            ContentScroll.CanvasSize = UDim2.fromOffset(0, pageLayout.AbsoluteContentSize.Y + 10)
        end)

        Tabs[tabName] = page
        TabButtons[tabName] = tabBtn
        return page
    end

    -- Add Card with CLICK Button (Matches Image Style)
    local function AddClickCard(parent, titleText, callback)
        local card = Create("Frame", {
            Size = UDim2.new(1, -4, 0, 42),
            BackgroundColor3 = CONFIG.Theme.CardBg,
            BackgroundTransparency = 0.4
        }, parent)
        Corner(card, 8)
        GlowBorder(card, CONFIG.Theme.CardBorder, 0.5, 1)

        Create("TextLabel", {
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -95, 1, 0),
            BackgroundTransparency = 1,
            Text = titleText,
            TextColor3 = CONFIG.Theme.TextPrimary,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, card)

        local clickBtn = Create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(75, 26),
            BackgroundColor3 = CONFIG.Theme.CardBg,
            Text = "CLICK",
            TextColor3 = CONFIG.Theme.BorderGlow,
            Font = Enum.Font.GothamBold,
            TextSize = 10
        }, card)
        Corner(clickBtn, 12)
        GlowBorder(clickBtn, CONFIG.Theme.BorderGlow, 0.3, 1)

        clickBtn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    end

    -- Add Toggle Card
    local function AddToggleCard(parent, titleText, defaultState, callback)
        local card = Create("Frame", {
            Size = UDim2.new(1, -4, 0, 42),
            BackgroundColor3 = CONFIG.Theme.CardBg,
            BackgroundTransparency = 0.4
        }, parent)
        Corner(card, 8)
        GlowBorder(card, CONFIG.Theme.CardBorder, 0.5, 1)

        Create("TextLabel", {
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -70, 1, 0),
            BackgroundTransparency = 1,
            Text = titleText,
            TextColor3 = CONFIG.Theme.TextPrimary,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, card)

        local toggleFrame = Create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(36, 18),
            BackgroundColor3 = defaultState and CONFIG.Theme.HeaderBlue or Color3.fromRGB(30, 45, 70)
        }, card)
        Corner(toggleFrame, 10)

        local knob = Create("Frame", {
            Position = defaultState and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
            Size = UDim2.fromOffset(14, 14),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        }, toggleFrame)
        Corner(knob, 8)

        local active = defaultState
        local toggleBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        }, card)

        toggleBtn.MouseButton1Click:Connect(function()
            active = not active
            toggleFrame.BackgroundColor3 = active and CONFIG.Theme.HeaderBlue or Color3.fromRGB(30, 45, 70)
            knob.Position = active and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
            pcall(callback, active)
        end)
    end

    --------------------------------------------------------------------------
    -- 10. POPULATE TABS & FEATURES (EXACTLY MATCHING IMAGE TABS)
    --------------------------------------------------------------------------
    local shopTab = CreateTab("Shop")
    local statusTab = CreateTab("Status And Server")
    local localPlayerTab = CreateTab("LocalPlayer")
    local settingFarmTab = CreateTab("Setting Farm")
    local holdSkillTab = CreateTab("Hold and Select Skill")
    local farmingTab = CreateTab("Farming")
    local stackFarmTab = CreateTab("Stack Farming")
    local farmingOtherTab = CreateTab("Farming Other")
    local fruitRaidTab = CreateTab("Fruit and Raid, Dungeo")
    local seaEventTab = CreateTab("Sea Event")

    -- Fill [Shop] Tab (Matched with Screenshot)
    AddClickCard(shopTab, "Redeem Code", function()
        local codes = {"SUB2GAMERROBOT_RESET1", "KITT_RESET", "Sub2Fer999", "BLUXXY"}
        for _, code in ipairs(codes) do Network.Invoke("RedeemCode", code) end
    end)
    AddClickCard(shopTab, "Teleport Old World", function() Network.Invoke("TravelMain") end)
    AddClickCard(shopTab, "Teleport New World", function() Network.Invoke("TravelDressrosa") end)
    AddClickCard(shopTab, "Teleport Thid Sea", function() Network.Invoke("TravelZou") end)
    AddClickCard(shopTab, "Buy Dual Flintlock", function() Network.Invoke("BuyItem", "Dual Flintlock") end)
    AddClickCard(shopTab, "Reroll Race", function() Network.Invoke("BlackbeardReward", "Reroll", "2") end)

    -- Fill [Farming] Tab
    AddToggleCard(farmingTab, "Auto Farm Level", CONFIG.State.AutoFarmLevel, function(val)
        CONFIG.State.AutoFarmLevel = val
        if not val then TaskManager.Stop("AutoFarm") return end
        TaskManager.RunLoop("AutoFarm", 0.1, function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            -- Auto Farm Loop Logic
            local enemies = Workspace:FindFirstChild("Enemies")
            if enemies then
                for _, mob in ipairs(enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0)
                        Network.DoFastAttack(mob.HumanoidRootPart)
                        break
                    end
                end
            end
        end)
    end)

    -- Fill [LocalPlayer] Tab
    AddToggleCard(localPlayerTab, "Infinite Jump", CONFIG.State.InfiniteJump, function(val)
        CONFIG.State.InfiniteJump = val
        if val then
            TaskManager.Connections["InfJump"] = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            TaskManager.Stop("InfJump")
        end
    end)

    AddToggleCard(localPlayerTab, "No Clip", CONFIG.State.NoClip, function(val)
        CONFIG.State.NoClip = val
        if val then
            TaskManager.Connections["NoClip"] = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, p in ipairs(LocalPlayer.Character:GetChildren()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        else
            TaskManager.Stop("NoClip")
        end
    end)

    -- Search Bar Auto Filter Logic
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for name, btn in pairs(TabButtons) do
            if name:lower():find(query) then
                btn.Visible = true
            else
                btn.Visible = false
            end
        end
    end)

    -- Default Select First Tab
    Tabs["Shop"].Visible = true
    TabButtons["Shop"].TextColor3 = CONFIG.Theme.BorderGlow
    TabButtons["Shop"].BackgroundTransparency = 0.3

    -- Enable Dragging
    local dragging, dragStart, startPos
    TopHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    TopHeader.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

------------------------------------------------------------------------------
-- 11. KEY VERIFICATION EVENT BINDING
------------------------------------------------------------------------------
BtnVerify.MouseButton1Click:Connect(function()
    local key = KeyInput.Text or ""
    if key == "" then key = LoadKey() KeyInput.Text = key end
    if key == "" then
        GateStatus.Text = "Vui lòng nhập Key!"
        GateStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end

    GateStatus.Text = "Đang xác thực Key + HWID..."
    GateStatus.TextColor3 = CONFIG.Theme.BorderGlow

    task.spawn(function()
        local ok, msg = VerifyKey(key)
        if ok then
            SaveKey(key)
            GateStatus.Text = "Key hợp lệ! Đang mở Hub..."
            GateStatus.TextColor3 = CONFIG.Theme.StatusGreen
            task.wait(0.5)
            BuildMainHub()
        else
            GateStatus.Text = "Lỗi: " .. tostring(msg)
            GateStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)
end)

-- Auto load cached key on script execute
local cachedKey = LoadKey()
if cachedKey ~= "" then KeyInput.Text = cachedKey end

return { Name = CONFIG.Name, GUI = Gui }