--[[
    MeizuHub.lua
    Kaitun wrapper + Get Key System

    SOURCE KAITUN: dùng đúng source người dùng cung cấp.
    GET KEY: logic Verify/HWID/Cache theo GetKeyHub/MeizuHub.lua.
    Không thêm gameplay logic vào Kaitun.
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local CONFIG = {
    Name = "MeizuHub",
    VERIFY_URL = "https://getkeyhub-uwal.onrender.com/api/verify?key=%s&hwid=%s",
    GETKEY_URL = "https://lovemeizu.github.io/GetKeyHub/getkey.html",
    CACHE_FILE = "meizu_hub_key.txt",

    KAITUN_SOURCE = "https://doitenroi.win/paste/273mm6/raw",

    Bg = Color3.fromRGB(7, 8, 16),
    Panel = Color3.fromRGB(15, 18, 31),
    Panel2 = Color3.fromRGB(22, 27, 45),
    Blue = Color3.fromRGB(75, 105, 255),
    Blue2 = Color3.fromRGB(48, 72, 210),
    Purple = Color3.fromRGB(145, 92, 255),
    Cyan = Color3.fromRGB(64, 210, 255),
    Text = Color3.fromRGB(240, 244, 255),
    Muted = Color3.fromRGB(145, 155, 180),
    Green = Color3.fromRGB(75, 225, 145),
    Red = Color3.fromRGB(255, 85, 105),
    Yellow = Color3.fromRGB(255, 205, 90),
}

-- ============================================================
-- CLEAN OLD MEIZUHUB INSTANCE
-- ============================================================

pcall(function()
    local old = CoreGui:FindFirstChild(CONFIG.Name)
    if old then old:Destroy() end
end)

-- ============================================================
-- BASIC UI HELPERS
-- ============================================================

local function Create(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 14)
    }, parent)
end

local function Stroke(parent, color, transparency, thickness)
    return Create("UIStroke", {
        Color = color,
        Transparency = transparency or 0.75,
        Thickness = thickness or 1
    }, parent)
end

local function Gradient(parent, a, b, rotation)
    return Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, a),
            ColorSequenceKeypoint.new(1, b)
        }),
        Rotation = rotation or 0
    }, parent)
end

local function Tween(obj, duration, props)
    local ok, tw = pcall(function()
        local t = TweenService:Create(
            obj,
            TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            props
        )
        t:Play()
        return t
    end)
    return ok and tw or nil
end

-- ============================================================
-- GET KEY SYSTEM
-- Logic follows GetKeyHub/MeizuHub.lua:
-- HWID -> cache -> GETKEY_URL?hwid= -> VERIFY_URL?key=&hwid=
-- ============================================================

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
        writefile(CONFIG.CACHE_FILE, key)
    end)

    return ok
end

local function LoadKey()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then
        return ""
    end

    local existsOK, exists = pcall(function()
        return isfile(CONFIG.CACHE_FILE)
    end)

    if not existsOK or not exists then
        return ""
    end

    local readOK, value = pcall(function()
        return readfile(CONFIG.CACHE_FILE)
    end)

    if readOK and type(value) == "string" then
        return value:gsub("^%s+", ""):gsub("%s+$", "")
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
    key = tostring(key or "")
    key = key:gsub("^%s+", ""):gsub("%s+$", "")

    if #key < 3 then
        return false, "Vui lòng nhập key."
    end

    local currentHWID = GetHWID()

    if not currentHWID or tostring(currentHWID) == "" then
        return false, "Không lấy được HWID."
    end

    local url = string.format(
        CONFIG.VERIFY_URL,
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
        return false, tostring(data.error or data.message or "Key không hợp lệ.")
    end

    return true, tostring(data.message or "Key hợp lệ.")
end

-- ============================================================
-- GUI ROOT
-- ============================================================

local Gui = Create("ScreenGui", {
    Name = CONFIG.Name,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 9999
}, CoreGui)

-- ============================================================
-- NOTIFICATION
-- ============================================================

local function Notify(text, kind)
    local color = CONFIG.Blue
    if kind == "success" then color = CONFIG.Green end
    if kind == "error" then color = CONFIG.Red end
    if kind == "warn" then color = CONFIG.Yellow end

    local holder = Gui:FindFirstChild("Notifications")
    if not holder then
        holder = Create("Frame", {
            Name = "Notifications",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -14, 0, 14),
            Size = UDim2.fromOffset(290, 400),
            BackgroundTransparency = 1
        }, Gui)

        Create("UIListLayout", {
            Padding = UDim.new(0, 7),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Top
        }, holder)
    end

    local card = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = CONFIG.Panel,
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0
    }, holder)

    Corner(card, 13)
    Stroke(card, color, 0.55, 1)

    Create("Frame", {
        Size = UDim2.fromOffset(3, 32),
        Position = UDim2.fromOffset(7, 9),
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, card)

    Create("TextLabel", {
        Position = UDim2.fromOffset(18, 5),
        Size = UDim2.new(1, -25, 1, -10),
        BackgroundTransparency = 1,
        Text = tostring(text),
        TextColor3 = CONFIG.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, card)

    task.delay(3, function()
        if card and card.Parent then
            Tween(card, 0.25, {
                BackgroundTransparency = 1
            })
            task.wait(0.3)
            pcall(function() card:Destroy() end)
        end
    end)
end

-- ============================================================
-- KEY GATE
-- ============================================================

local Gate = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.56),
    Size = UDim2.fromOffset(330, 365),
    BackgroundColor3 = CONFIG.Panel,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0
}, Gui)

Corner(Gate, 22)
Stroke(Gate, CONFIG.Purple, 0.55, 1)
Gradient(Gate, CONFIG.Panel2, CONFIG.Bg, 90)

local Content = Create("Frame", {
    Position = UDim2.fromOffset(22, 20),
    Size = UDim2.new(1, -44, 1, -40),
    BackgroundTransparency = 1
}, Gate)

local Badge = Create("Frame", {
    Size = UDim2.fromOffset(118, 27),
    BackgroundColor3 = CONFIG.Purple,
    BackgroundTransparency = 0.82,
    BorderSizePixel = 0
}, Content)

Corner(Badge, 14)
Stroke(Badge, CONFIG.Purple, 0.55, 1)

Create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "●  MEIZU HUB",
    TextColor3 = CONFIG.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 9
}, Badge)

Create("TextLabel", {
    Position = UDim2.fromOffset(0, 43),
    Size = UDim2.new(1, 0, 0, 31),
    BackgroundTransparency = 1,
    Text = "Kaitun Access",
    TextColor3 = CONFIG.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 21,
    TextXAlignment = Enum.TextXAlignment.Left
}, Content)

Create("TextLabel", {
    Position = UDim2.fromOffset(0, 76),
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundTransparency = 1,
    Text = "Xác thực Key + HWID để khởi động Kaitun.",
    TextColor3 = CONFIG.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
}, Content)

local KeyBox = Create("TextBox", {
    Position = UDim2.fromOffset(0, 124),
    Size = UDim2.new(1, 0, 0, 43),
    BackgroundColor3 = CONFIG.Bg,
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    PlaceholderText = "Nhập / dán Key...",
    PlaceholderColor3 = CONFIG.Muted,
    Text = "",
    TextColor3 = CONFIG.Text,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left
}, Content)

Corner(KeyBox, 12)
Stroke(KeyBox, CONFIG.Blue, 0.72, 1)

Create("UIPadding", {
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12)
}, KeyBox)

local GetKey = Create("TextButton", {
    Position = UDim2.fromOffset(0, 178),
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = CONFIG.Blue,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "Tạo / Lấy Key Free",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 11
}, Content)

Corner(GetKey, 12)
Gradient(GetKey, CONFIG.Blue, CONFIG.Purple, 0)

local Verify = Create("TextButton", {
    Position = UDim2.fromOffset(0, 228),
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = CONFIG.Panel2,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "Xác thực Key",
    TextColor3 = CONFIG.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11
}, Content)

Corner(Verify, 12)
Stroke(Verify, CONFIG.Blue, 0.68, 1)

local Status = Create("TextLabel", {
    Position = UDim2.fromOffset(0, 280),
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "● Chờ xác thực",
    TextColor3 = CONFIG.Muted,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left
}, Content)

local Result = Create("TextLabel", {
    Position = UDim2.fromOffset(0, 303),
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundTransparency = 1,
    Text = "Get Key sẽ tự gắn HWID hiện tại.",
    TextColor3 = CONFIG.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
}, Content)

GetKey.MouseButton1Click:Connect(function()
    local currentHWID = GetHWID()

    if not currentHWID or tostring(currentHWID) == "" then
        Status.Text = "● Không lấy được HWID"
        Status.TextColor3 = CONFIG.Red
        Result.Text = "Không thể tạo link Get Key."
        return
    end

    local url = CONFIG.GETKEY_URL .. "?hwid=" .. HttpService:UrlEncode(tostring(currentHWID))

    if type(setclipboard) == "function" then
        local copyOK = pcall(function()
            setclipboard(url)
        end)

        if copyOK then
            Status.Text = "● Link Get Key đã sẵn sàng"
            Status.TextColor3 = CONFIG.Green
            Result.Text = "Đã copy link Get Key kèm HWID."
            Notify("Đã copy link Get Key + HWID", "success")
        else
            Status.Text = "● Get Key sẵn sàng"
            Status.TextColor3 = CONFIG.Yellow
            Result.Text = "Không thể dùng clipboard trong môi trường này."
        end
    else
        Status.Text = "● Get Key sẵn sàng"
        Status.TextColor3 = CONFIG.Yellow
        Result.Text = "Clipboard không được hỗ trợ."
    end
end)

-- ============================================================
-- STATUS HUB
-- ============================================================

local Main
local StatusRows = {}

local function SetRow(name, value)
    local row = StatusRows[name]
    if row then
        row.Value.Text = tostring(value or "—")
    end
end

local function MakeRow(parent, name)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CONFIG.Panel2,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0
    }, parent)

    Corner(row, 11)

    Create("TextLabel", {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.fromOffset(82, 42),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = CONFIG.Muted,
        Font = Enum.Font.GothamMedium,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, row)

    local value = Create("TextLabel", {
        Position = UDim2.fromOffset(94, 0),
        Size = UDim2.new(1, -106, 42, 0),
        BackgroundTransparency = 1,
        Text = "—",
        TextColor3 = CONFIG.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 9,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center
    }, row)

    StatusRows[name] = {
        Row = row,
        Value = value
    }
end

local function BuildMain()
    if Main and Main.Parent then return end
    if Gate and Gate.Parent then
        Gate:Destroy()
    end

    Main = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.56),
        Size = UDim2.fromOffset(420, 420),
        BackgroundColor3 = CONFIG.Bg,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0
    }, Gui)

    Corner(Main, 20)
    Stroke(Main, CONFIG.Purple, 0.52, 1)
    Gradient(Main, CONFIG.Panel2, CONFIG.Bg, 90)

    local Header = Create("Frame", {
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.new(1, -24, 0, 66),
        BackgroundColor3 = CONFIG.Panel,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0
    }, Main)

    Corner(Header, 15)
    Stroke(Header, CONFIG.Blue, 0.78, 1)

    Create("TextLabel", {
        Position = UDim2.fromOffset(14, 9),
        Size = UDim2.new(1, -28, 0, 27),
        BackgroundTransparency = 1,
        Text = "MEIZU HUB",
        TextColor3 = CONFIG.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Header)

    Create("TextLabel", {
        Position = UDim2.fromOffset(15, 36),
        Size = UDim2.new(1, -30, 0, 18),
        BackgroundTransparency = 1,
        Text = "Blox Fruits • Kaitun Status",
        TextColor3 = CONFIG.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Header)

    local Body = Create("Frame", {
        Position = UDim2.fromOffset(12, 88),
        Size = UDim2.new(1, -24, 1, -100),
        BackgroundTransparency = 1
    }, Main)

    local Card = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = CONFIG.Panel,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0
    }, Body)

    Corner(Card, 15)
    Stroke(Card, CONFIG.Blue, 0.82, 1)

    local Padding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12)
    }, Card)

    local List = Create("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, Card)

    local title = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = "Kaitun đang hoạt động",
        TextColor3 = CONFIG.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Card)

    MakeRow(Card, "Đang làm")
    MakeRow(Card, "Task")
    MakeRow(Card, "Quest")
    MakeRow(Card, "Target")
    MakeRow(Card, "Level")
    MakeRow(Card, "Sea")
    MakeRow(Card, "Status")
    MakeRow(Card, "Progress")

    local dragging = false
    local dragStart
    local startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)

    Tween(Main, 0.45, {
        Position = UDim2.fromScale(0.5, 0.52)
    })
end

-- ============================================================
-- STATUS READER
-- Reads source state only; does not alter Kaitun logic.
-- ============================================================

local function SafeGlobal(name)
    local ok, value = pcall(function()
        return getgenv()[name]
    end)

    if ok then return value end
    return nil
end

local function ReadState()
    local storage = SafeGlobal("ScriptStorage")
    local questController = SafeGlobal("QuestController")
    local seaIndex = SafeGlobal("SeaIndex")
    local monResult = SafeGlobal("MonResult")

    if type(storage) ~= "table" then
        return {
            loaded = false
        }
    end

    local tasks = type(storage.Task) == "table" and storage.Task or {}
    local playerData = type(storage.PlayerData) == "table" and storage.PlayerData or {}

    local mainTask = tasks.MainTask
    local subTask = tasks.SubTask

    local doing = subTask or mainTask or "Đang khởi tạo..."
    local taskText = mainTask or "—"

    local quest = "—"
    if type(questController) == "table" then
        quest = questController.CurrentQuestName
            or questController.CurrentQuest
            or "—"
    end

    local target = "—"
    if monResult then
        pcall(function()
            if typeof(monResult) == "Instance" then
                target = monResult.Name
            else
                target = tostring(monResult)
            end
        end)
    end

    local level = playerData.Level or "—"

    local sea = "—"
    if tonumber(seaIndex) == 1 then
        sea = "Sea 1"
    elseif tonumber(seaIndex) == 2 then
        sea = "Sea 2"
    elseif tonumber(seaIndex) == 3 then
        sea = "Sea 3"
    elseif seaIndex then
        sea = tostring(seaIndex)
    end

    -- Progress is display-only. It extracts an existing x/y or x% value
    -- already present in the Kaitun task text.
    local combined = tostring(subTask or "") .. " | " .. tostring(mainTask or "")
    local progress = combined:match("(%d+%s*/%s*%d+)")
        or combined:match("(%d+%%)")
        or "—"

    local status = "Running"
    if tostring(doing):lower():find("wait")
    or tostring(doing):lower():find("waiting")
    or tostring(doing):lower():find("chờ") then
        status = "Waiting"
    end

    return {
        loaded = true,
        doing = doing,
        task = taskText,
        quest = quest,
        target = target,
        level = level,
        sea = sea,
        status = status,
        progress = progress
    }
end

local function HideOriginalKaitunUI()
    pcall(function()
        local old = CoreGui:FindFirstChild("KaitunUI")
        if old then
            old:Destroy()
        end
    end)
end

local function StartStatusMonitor()
    task.spawn(function()
        local sourceSeen = false

        while task.wait(0.25) do
            local state = ReadState()

            if not state.loaded then
                SetRow("Đang làm", "Đang khởi tạo Kaitun...")
                SetRow("Task", "Đang tải source...")
                SetRow("Status", "Loading")
            else
                sourceSeen = true

                SetRow("Đang làm", state.doing)
                SetRow("Task", state.task)
                SetRow("Quest", state.quest)
                SetRow("Target", state.target)
                SetRow("Level", state.level)
                SetRow("Sea", state.sea)
                SetRow("Status", state.status)
                SetRow("Progress", state.progress)

                HideOriginalKaitunUI()
            end

            if sourceSeen then
                HideOriginalKaitunUI()
            end
        end
    end)
end

-- ============================================================
-- START EXACT KAITUN SOURCE
-- ============================================================

local function StartKaitun()
    Status.Text = "● Đang khởi động Kaitun..."
    Status.TextColor3 = CONFIG.Blue
    Result.Text = "Đang tải source Kaitun đã cấu hình."

    BuildMain()
    StartStatusMonitor()

    task.spawn(function()
        local ok, source = HttpGet(CONFIG.KAITUN_SOURCE)

        if not ok or type(source) ~= "string" or #source < 100 then
            Notify("Không tải được source Kaitun.", "error")
            SetRow("Status", "Source Error")
            SetRow("Đang làm", "Không thể tải Kaitun")
            return
        end

        local fn, compileError = loadstring(source)

        if not fn then
            Notify("Kaitun compile error: " .. tostring(compileError), "error")
            SetRow("Status", "Compile Error")
            SetRow("Đang làm", "Source không thể chạy")
            return
        end

        local runOK, runError = pcall(fn)

        if not runOK then
            Notify("Kaitun runtime error: " .. tostring(runError), "error")
            SetRow("Status", "Runtime Error")
            SetRow("Đang làm", tostring(runError))
        end
    end)
end

-- ============================================================
-- VERIFY
-- ============================================================

Verify.MouseButton1Click:Connect(function()
    local key = tostring(KeyBox.Text or "")
    key = key:gsub("^%s+", ""):gsub("%s+$", "")

    if key == "" then
        key = LoadKey()
        KeyBox.Text = key
    end

    if key == "" then
        Status.Text = "● Chưa nhập key"
        Status.TextColor3 = CONFIG.Red
        Result.Text = "Nhập key trước khi xác thực."
        return
    end

    Verify.Active = false
    Verify.AutoButtonColor = false
    Status.Text = "● Đang xác thực..."
    Status.TextColor3 = CONFIG.Blue
    Result.Text = "Đang kiểm tra key + HWID..."

    task.spawn(function()
        local ok, message = VerifyKey(key)

        if ok then
            SaveKey(key)

            Status.Text = "● Key hợp lệ"
            Status.TextColor3 = CONFIG.Green
            Result.Text = message

            task.wait(0.25)

            Notify("Xác thực thành công • Khởi động Kaitun", "success")
            StartKaitun()
        else
            Status.Text = "● Xác thực thất bại"
            Status.TextColor3 = CONFIG.Red
            Result.Text = message
            Verify.Active = true
            Verify.AutoButtonColor = false
        end
    end)
end)

-- ============================================================
-- LOAD CACHED KEY
-- ============================================================

local cached = LoadKey()

if cached ~= "" then
    KeyBox.Text = cached
end

Tween(Gate, 0.4, {
    Position = UDim2.fromScale(0.5, 0.5)
})
