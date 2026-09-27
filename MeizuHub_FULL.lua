--[=[
    MEIZU HUB - Blue Glass UI
    UI-only foundation based on the supplied reference layout.

    This version intentionally contains UI/state plumbing only.
    Game-specific features can be connected later through the Feature API
    at the bottom of this file.

    Controls:
      - RightShift: show/hide UI
      - Drag the top bar to move the window
]=]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("MeizuHub")
if oldGui then
    oldGui:Destroy()
end

local Theme = {
    Background = Color3.fromRGB(3, 8, 16),
    Glass = Color3.fromRGB(7, 18, 31),
    Glass2 = Color3.fromRGB(11, 28, 46),
    Glass3 = Color3.fromRGB(16, 38, 61),
    Accent = Color3.fromRGB(45, 155, 255),
    AccentLight = Color3.fromRGB(105, 210, 255),
    Text = Color3.fromRGB(245, 250, 255),
    SubText = Color3.fromRGB(160, 184, 208),
    Muted = Color3.fromRGB(105, 130, 155),
    Success = Color3.fromRGB(75, 220, 150),
}

local function New(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    return object
end

local function Round(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
    return corner
end

local function AddStroke(object, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Accent
    stroke.Transparency = transparency or 0.6
    stroke.Thickness = thickness or 1
    stroke.Parent = object
    return stroke
end

local function Animate(object, properties, duration)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local Gui = New("ScreenGui", {
    Name = "MeizuHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = playerGui,
})

New("Frame", {
    Name = "SceneTint",
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.72,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 0,
    Parent = Gui,
})

local Main = New("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0, 520, 0, 360),
    BackgroundColor3 = Theme.Glass,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 5,
    Parent = Gui,
})
Round(Main, 18)
AddStroke(Main, 0.25, 1.2)

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 23, 40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(4, 13, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 31, 51)),
})
MainGradient.Rotation = 35
MainGradient.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = New("Frame", {
    Name = "Header",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 64),
    ZIndex = 10,
    Parent = Main,
})

local function HeaderButton(text, position, size)
    local button = New("TextButton", {
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 21,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Glass2,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Position = position,
        Size = size,
        ZIndex = 12,
        Parent = Header,
    })
    Round(button, 12)
    AddStroke(button, 0.72, 1)

    button.MouseEnter:Connect(function()
        Animate(button, {
            BackgroundTransparency = 0.02,
            TextColor3 = Theme.AccentLight,
        }, 0.12)
    end)

    button.MouseLeave:Connect(function()
        Animate(button, {
            BackgroundTransparency = 0.25,
            TextColor3 = Theme.Text,
        }, 0.12)
    end)

    return button
end

local MenuButton = HeaderButton("☰", UDim2.new(0, 14, 0, 12), UDim2.new(0, 42, 0, 40))
HeaderButton("◌", UDim2.new(0, 62, 0, 12), UDim2.new(0, 42, 0, 40))
local SettingsButton = HeaderButton("⚙", UDim2.new(1, -142, 0, 12), UDim2.new(0, 42, 0, 40))
local MinimizeButton = HeaderButton("—", UDim2.new(1, -94, 0, 12), UDim2.new(0, 42, 0, 40))
local CloseButton = HeaderButton("×", UDim2.new(1, -46, 0, 12), UDim2.new(0, 32, 0, 40))

New("TextLabel", {
    Text = "◆",
    Font = Enum.Font.GothamBlack,
    TextSize = 27,
    TextColor3 = Theme.AccentLight,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, -115, 0, 7),
    Size = UDim2.new(0, 40, 0, 44),
    ZIndex = 12,
    Parent = Header,
})

New("TextLabel", {
    Text = "MEIZU HUB",
    Font = Enum.Font.GothamBlack,
    TextSize = 21,
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.new(0.5, -72, 0, 8),
    Size = UDim2.new(0, 160, 0, 28),
    ZIndex = 12,
    Parent = Header,
})

New("TextLabel", {
    Text = "Blox Fruit",
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextColor3 = Theme.AccentLight,
    BackgroundTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.new(0.5, -71, 0, 34),
    Size = UDim2.new(0, 150, 0, 18),
    ZIndex = 12,
    Parent = Header,
})

New("Frame", {
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.72,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 18, 1, -1),
    Size = UDim2.new(1, -36, 0, 1),
    ZIndex = 12,
    Parent = Header,
})

--==================================================
-- BODY
--==================================================

local Body = New("Frame", {
    Name = "Body",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 14, 0, 76),
    Size = UDim2.new(1, -28, 1, -90),
    ZIndex = 8,
    Parent = Main,
})

local Sidebar = New("Frame", {
    Name = "Sidebar",
    BackgroundColor3 = Theme.Glass2,
    BackgroundTransparency = 0.16,
    BorderSizePixel = 0,
    Size = UDim2.new(0.29, 0, 1, 0),
    ClipsDescendants = true,
    ZIndex = 9,
    Parent = Body,
})
Round(Sidebar, 14)
AddStroke(Sidebar, 0.62, 1)

local Content = New("Frame", {
    Name = "Content",
    BackgroundColor3 = Theme.Glass2,
    BackgroundTransparency = 0.14,
    BorderSizePixel = 0,
    Position = UDim2.new(0.31, 0, 0, 0),
    Size = UDim2.new(0.69, 0, 1, 0),
    ClipsDescendants = true,
    ZIndex = 9,
    Parent = Body,
})
Round(Content, 14)
AddStroke(Content, 0.62, 1)

--==================================================
-- SIDEBAR
--==================================================

local SearchBox = New("TextBox", {
    Name = "SearchBox",
    PlaceholderText = "Search section or function",
    PlaceholderColor3 = Theme.Muted,
    Text = "",
    ClearTextOnFocus = false,
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = Theme.Text,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 10, 0, 10),
    Size = UDim2.new(1, -20, 0, 40),
    ZIndex = 12,
    Parent = Sidebar,
})
Round(SearchBox, 9)
AddStroke(SearchBox, 0.72, 1)

local searchPadding = Instance.new("UIPadding")
searchPadding.PaddingLeft = UDim.new(0, 12)
searchPadding.Parent = SearchBox

New("TextLabel", {
    Text = "⌕",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Theme.AccentLight,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -34, 0, 7),
    Size = UDim2.new(0, 26, 0, 26),
    ZIndex = 13,
    Parent = Sidebar,
})

local SideScroll = New("ScrollingFrame", {
    Name = "SideScroll",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 5, 0, 60),
    Size = UDim2.new(1, -10, 1, -65),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Accent,
    ScrollBarImageTransparency = 0.3,
    ZIndex = 11,
    Parent = Sidebar,
})

local sideLayout = New("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
sideLayout.Parent = SideScroll

local categories = {
    "Shop",
    "Status And Server",
    "LocalPlayer",
    "Setting Farm",
    "Hold and Select Skill",
    "Farming",
    "Stack Farming",
    "Farming Other",
    "Fruit and Raid",
    "Dungeon",
    "Sea Event",
    "ESP",
    "Teleport",
    "Settings",
}

local categoryRefs = {}

for index, name in ipairs(categories) do
    local holder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 38),
        LayoutOrder = index,
        Parent = SideScroll,
    })

    local indicator = New("Frame", {
        BackgroundColor3 = Theme.AccentLight,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 4, 0.5, -12),
        Size = UDim2.new(0, 3, 0, 24),
        Parent = holder,
    })
    Round(indicator, 3)

    local button = New("TextButton", {
        Text = name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Glass,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 1),
        Size = UDim2.new(1, -12, 0, 36),
        ZIndex = 13,
        Parent = holder,
    })
    Round(button, 9)
    AddStroke(button, 1, 1)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 14)
    pad.Parent = button

    categoryRefs[name] = {
        Button = button,
        Indicator = indicator,
        Holder = holder,
    }
end

--==================================================
-- CONTENT HEADER
--==================================================

local ContentHeader = New("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 10),
    Size = UDim2.new(1, -36, 0, 52),
    ZIndex = 12,
    Parent = Content,
})

local ContentTitle = New("TextLabel", {
    Text = "Shop",
    Font = Enum.Font.GothamBold,
    TextSize = 21,
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.new(0, 0, 0, 2),
    Size = UDim2.new(0.7, 0, 0, 30),
    ZIndex = 13,
    Parent = ContentHeader,
})

New("TextLabel", {
    Text = "MEIZU HUB • Blue Glass Interface",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = Theme.Muted,
    BackgroundTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.new(0, 0, 0, 30),
    Size = UDim2.new(0.8, 0, 0, 18),
    ZIndex = 13,
    Parent = ContentHeader,
})

local ContentSearch = New("TextBox", {
    Name = "ContentSearch",
    PlaceholderText = "⌕",
    PlaceholderColor3 = Theme.SubText,
    Text = "",
    ClearTextOnFocus = false,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Theme.Text,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.24,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -44, 0, 3),
    Size = UDim2.new(0, 38, 0, 36),
    ZIndex = 14,
    Parent = ContentHeader,
})
Round(ContentSearch, 10)
AddStroke(ContentSearch, 0.7, 1)

local ContentScroll = New("ScrollingFrame", {
    Name = "ContentScroll",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 12, 0, 66),
    Size = UDim2.new(1, -24, 1, -78),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Theme.Accent,
    ScrollBarImageTransparency = 0.28,
    ZIndex = 12,
    Parent = Content,
})

local contentLayout = New("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
contentLayout.Parent = ContentScroll

--==================================================
-- PAGE DATA
--==================================================

local Pages = {
    Shop = {
        {"Redeem Code", "Open the code redemption interface.", "Click"},
        {"Teleport Old World", "Teleport control placeholder.", "Click"},
        {"Teleport New World", "Teleport control placeholder.", "Click"},
        {"Teleport Third Sea", "Teleport control placeholder.", "Click"},
        {"Buy Dual Flintlock", "Shop action placeholder.", "Click"},
        {"Reroll Race", "Race reroll control placeholder.", "Click"},
    },
    ["Status And Server"] = {
        {"Player Status", "Level / Beli / Fragments / Race.", "View"},
        {"Server Information", "Server ID / players / ping.", "View"},
        {"Rejoin Server", "Reconnect control placeholder.", "Click"},
        {"Server Hop", "Server navigation placeholder.", "Click"},
    },
    LocalPlayer = {
        {"WalkSpeed", "Player movement setting.", "Edit"},
        {"JumpPower", "Player jump setting.", "Edit"},
        {"Infinite Jump", "Player movement toggle.", "OFF"},
        {"No Clip", "Character collision toggle.", "OFF"},
    },
    ["Setting Farm"] = {
        {"Farm Method", "Choose the preferred farming mode.", "Select"},
        {"Auto Quest", "Quest automation placeholder.", "OFF"},
        {"Auto Farm Level", "Level farming placeholder.", "OFF"},
        {"Auto Farm Boss", "Boss farming placeholder.", "OFF"},
    },
    ["Hold and Select Skill"] = {
        {"Melee Skill", "Select a fighting skill.", "Select"},
        {"Sword Skill", "Select a sword skill.", "Select"},
        {"Fruit Skill", "Select a fruit skill.", "Select"},
    },
    Farming = {
        {"Auto Farm Level", "Level farming placeholder.", "OFF"},
        {"Auto Quest", "Quest selection placeholder.", "OFF"},
        {"Auto Farm NPC", "NPC farming placeholder.", "OFF"},
        {"Auto Farm Mastery", "Mastery farming placeholder.", "OFF"},
    },
    ["Stack Farming"] = {
        {"Stack Quest", "Quest stack placeholder.", "OFF"},
        {"Stack NPC", "NPC stack placeholder.", "OFF"},
        {"Stack Boss", "Boss stack placeholder.", "OFF"},
    },
    ["Farming Other"] = {
        {"Auto Chest", "Chest collection placeholder.", "OFF"},
        {"Auto Material", "Material collection placeholder.", "OFF"},
        {"Auto Elite", "Elite hunter placeholder.", "OFF"},
    },
    ["Fruit and Raid"] = {
        {"Fruit Finder", "Fruit detection placeholder.", "OFF"},
        {"Auto Collect Fruit", "Fruit collection placeholder.", "OFF"},
        {"Auto Raid", "Raid control placeholder.", "OFF"},
        {"Auto Awaken", "Awakening control placeholder.", "OFF"},
    },
    Dungeon = {
        {"Dungeon Finder", "Dungeon interface placeholder.", "Open"},
        {"Dungeon Status", "Current dungeon information.", "View"},
    },
    ["Sea Event"] = {
        {"Sea Event Finder", "Event detection placeholder.", "OFF"},
        {"Auto Sea Event", "Sea event control placeholder.", "OFF"},
    },
    ESP = {
        {"Player ESP", "Player visual overlay placeholder.", "OFF"},
        {"NPC ESP", "NPC visual overlay placeholder.", "OFF"},
        {"Boss ESP", "Boss visual overlay placeholder.", "OFF"},
        {"Fruit ESP", "Fruit visual overlay placeholder.", "OFF"},
    },
    Teleport = {
        {"First Sea", "Location selector placeholder.", "Open"},
        {"Second Sea", "Location selector placeholder.", "Open"},
        {"Third Sea", "Location selector placeholder.", "Open"},
        {"Boss Locations", "Boss location selector.", "Open"},
    },
    Settings = {
        {"Blue Glass Theme", "Current visual theme.", "ON"},
        {"UI Animation", "Smooth UI transitions.", "ON"},
        {"Transparency", "Glass transparency setting.", "Edit"},
        {"UI Scale", "Mobile interface scale.", "Edit"},
        {"Reset UI", "Reset visual preferences.", "Reset"},
    },
}

--==================================================
-- FEATURE API
--==================================================

local FeatureCallbacks = {}

local function RegisterFeature(name, callback)
    FeatureCallbacks[name] = callback
end

local function FireFeature(name, ...)
    local callback = FeatureCallbacks[name]
    if callback then
        return callback(...)
    end
    warn("[MEIZU HUB] Feature not connected: " .. tostring(name))
end

--==================================================
-- CARD RENDERER
--==================================================

local function ClearCards()
    for _, child in ipairs(ContentScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function CreateCard(title, description, actionText, index)
    local card = New("Frame", {
        Name = "Card",
        BackgroundColor3 = Theme.Glass3,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -4, 0, 62),
        LayoutOrder = index,
        ZIndex = 13,
        Parent = ContentScroll,
    })
    Round(card, 12)
    AddStroke(card, 0.74, 1)

    local accent = New("Frame", {
        BackgroundColor3 = Theme.AccentLight,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(0, 3, 0, 42),
        ZIndex = 14,
        Parent = card,
    })
    Round(accent, 3)

    New("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 17, 0, 8),
        Size = UDim2.new(1, -160, 0, 23),
        ZIndex = 15,
        Parent = card,
    })

    New("TextLabel", {
        Text = description,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextColor3 = Theme.Muted,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.new(0, 17, 0, 32),
        Size = UDim2.new(1, -160, 0, 18),
        ZIndex = 15,
        Parent = card,
    })

    local action = New("TextButton", {
        Text = actionText,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 122, 0, 38),
        ZIndex = 15,
        Parent = card,
    })
    Round(action, 10)
    AddStroke(action, 0.5, 1)

    action.MouseEnter:Connect(function()
        Animate(action, {
            BackgroundColor3 = Theme.AccentLight,
            BackgroundTransparency = 0.02,
        }, 0.12)
    end)

    action.MouseLeave:Connect(function()
        Animate(action, {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.18,
        }, 0.12)
    end)

    action.MouseButton1Click:Connect(function()
        local result = FireFeature(title)
        local stateKey = ({
            ["Auto Quest"] = "AutoQuest",
            ["Auto Farm Level"] = "AutoFarmLevel",
            ["Auto Farm Boss"] = "AutoFarmBoss",
            ["Auto Raid"] = "AutoRaid",
            ["Auto Collect Fruit"] = "AutoCollectFruit",
            ["Infinite Jump"] = "InfiniteJump",
            ["No Clip"] = "NoClip",
            ["Player ESP"] = "PlayerESP",
            ["NPC ESP"] = "NPCESP",
            ["Boss ESP"] = "BossESP",
            ["Fruit ESP"] = "FruitESP",
        })[title]
        if stateKey and GameState and GameState[stateKey] ~= nil then
            action.Text = GameState[stateKey] and "ON" or "OFF"
        elseif result ~= nil then
            action.Text = "OK"
        end
        print("[MEIZU HUB] " .. title)
    end)
end

local function RenderPage(name)
    ContentTitle.Text = name

    for category, refs in pairs(categoryRefs) do
        local selected = category == name
        Animate(refs.Button, {
            BackgroundTransparency = selected and 0.05 or 0.7,
            TextColor3 = selected and Theme.Text or Theme.SubText,
        }, 0.12)
        Animate(refs.Indicator, {
            BackgroundTransparency = selected and 0 or 1,
        }, 0.12)
    end

    ClearCards()

    for index, data in ipairs(Pages[name] or {}) do
        CreateCard(data[1], data[2], data[3], index)
    end
end

for name, refs in pairs(categoryRefs) do
    refs.Button.MouseEnter:Connect(function()
        if name ~= ContentTitle.Text then
            Animate(refs.Button, {
                BackgroundTransparency = 0.42,
                TextColor3 = Theme.Text,
            }, 0.12)
        end
    end)

    refs.Button.MouseLeave:Connect(function()
        if name ~= ContentTitle.Text then
            Animate(refs.Button, {
                BackgroundTransparency = 0.7,
                TextColor3 = Theme.SubText,
            }, 0.12)
        end
    end)

    refs.Button.MouseButton1Click:Connect(function()
        RenderPage(name)
    end)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(SearchBox.Text)
    for name, refs in pairs(categoryRefs) do
        refs.Holder.Visible = query == ""
            or string.find(string.lower(name), query, 1, true) ~= nil
    end
end)

ContentSearch:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(ContentSearch.Text)
    for _, child in ipairs(ContentScroll:GetChildren()) do
        if child:IsA("Frame") then
            local title = child:FindFirstChildOfClass("TextLabel")
            child.Visible = query == ""
                or (title and string.find(string.lower(title.Text), query, 1, true) ~= nil)
        end
    end
end)

--==================================================
-- GAME CONTROLLER / FEATURE INTEGRATION
--==================================================
-- Cấu hình gameplay nằm ở đây để không phải sửa UI.
-- Experience của bạn có thể đổi tên quest/raid/target theo server riêng.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local CommF = RemotesFolder:WaitForChild("CommF_")
local NetFolder = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = NetFolder:WaitForChild("RegisterAttack")

local GameConfig = {
    -- Có thể đổi trực tiếp theo quest/raid trong experience của bạn.
    QuestName = "BanditQuest1",
    QuestLevel = 1,
    RaidName = "Flame",

    AttackDelay = 0.12,
    QuestRefresh = 2.0,
    RaidRefresh = 3.0,
    FruitRefresh = 1.0,
    TargetRadius = 350,
    FarmHeight = 8,

    WalkSpeed = 16,
    JumpPower = 50,
}

local GameState = {
    AutoQuest = false,
    AutoFarmLevel = false,
    AutoFarmBoss = false,
    AutoRaid = false,
    AutoCollectFruit = false,
    AutoMastery = false,
    AutoMaterial = false,
    AutoChest = false,
    InfiniteJump = false,
    NoClip = false,
    PlayerESP = false,
    NPCESP = false,
    BossESP = false,
    FruitESP = false,
}

local TaskTokens = {}
local ESPObjects = {}

local function SafeInvoke(...)
    local args = table.pack(...)
    local ok, result = pcall(function()
        return CommF:InvokeServer(table.unpack(args, 1, args.n))
    end)
    if not ok then
        warn("[MEIZU HUB] CommF error:", result)
        return nil
    end
    return result
end

local function SafeFire(remote, ...)
    local args = table.pack(...)
    local ok, err = pcall(function()
        remote:FireServer(table.unpack(args, 1, args.n))
    end)
    if not ok then
        warn("[MEIZU HUB] RemoteEvent error:", err)
        return false
    end
    return true
end

local function StartQuest(questName, questLevel)
    return SafeInvoke("StartQuest", questName or GameConfig.QuestName, questLevel or GameConfig.QuestLevel)
end

local function Attack(hitDelay)
    return SafeFire(RegisterAttack, hitDelay or GameConfig.AttackDelay)
end

local function StoreFruit(fruitToolName, fruitInstance)
    return SafeInvoke("StoreFruit", fruitToolName, fruitInstance)
end

local function SelectRaid(raidName)
    return SafeInvoke("RaidsNpc", "Select", raidName or GameConfig.RaidName)
end

local function Character()
    return player.Character
end

local function RootOf(model)
    if not model or not model:IsA("Model") then return nil end
    return model:FindFirstChild("HumanoidRootPart")
end

local function HumanoidOf(model)
    if not model or not model:IsA("Model") then return nil end
    return model:FindFirstChildOfClass("Humanoid")
end

local function Alive(model)
    local hum = HumanoidOf(model)
    return hum and hum.Health > 0 and RootOf(model) ~= nil
end

local function FindNearestEnemy(maxDistance, bossOnly)
    local char = Character()
    local root = char and RootOf(char)
    if not root then return nil end

    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end

    local nearest, nearestDistance
    for _, obj in ipairs(enemies:GetChildren()) do
        if obj:IsA("Model") and Alive(obj) then
            local hum = HumanoidOf(obj)
            local hrp = RootOf(obj)
            local isBoss = string.find(string.lower(obj.Name), "boss", 1, true) ~= nil
                or (hum and hum.MaxHealth >= 10000)

            if (not bossOnly or isBoss) and hrp then
                local distance = (hrp.Position - root.Position).Magnitude
                if distance <= (maxDistance or GameConfig.TargetRadius)
                    and (not nearestDistance or distance < nearestDistance) then
                    nearest = obj
                    nearestDistance = distance
                end
            end
        end
    end
    return nearest, nearestDistance
end

local function MoveNear(target)
    local char = Character()
    local root = char and RootOf(char)
    local targetRoot = RootOf(target)
    if not root or not targetRoot then return false end

    local targetCFrame = targetRoot.CFrame * CFrame.new(0, GameConfig.FarmHeight, 0)
    pcall(function()
        root.CFrame = targetCFrame
    end)
    return true
end

local function StopTask(name)
    TaskTokens[name] = nil
end

local function StartTask(name, interval, callback)
    StopTask(name)
    local token = {}
    TaskTokens[name] = token

    task.spawn(function()
        while TaskTokens[name] == token and Gui.Parent do
            local ok, err = pcall(callback)
            if not ok then
                warn("[MEIZU HUB] " .. name .. " error:", err)
            end
            task.wait(interval or 0.1)
        end
    end)
end

local function SetFeatureState(name, enabled)
    GameState[name] = enabled
    if not enabled then
        StopTask(name)
    end
end

local function StartAutoQuest()
    SetFeatureState("AutoQuest", true)
    StartTask("AutoQuest", GameConfig.QuestRefresh, function()
        StartQuest(GameConfig.QuestName, GameConfig.QuestLevel)
    end)
end

local function StartAutoFarm(bossOnly, stateName)
    SetFeatureState(stateName, true)
    local lastQuest = 0
    StartTask(stateName, GameConfig.AttackDelay, function()
        if not bossOnly and os.clock() - lastQuest >= GameConfig.QuestRefresh then
            StartQuest(GameConfig.QuestName, GameConfig.QuestLevel)
            lastQuest = os.clock()
        end
        local target = FindNearestEnemy(GameConfig.TargetRadius, bossOnly)
        if not target then return end
        MoveNear(target)
        Attack(GameConfig.AttackDelay)
    end)
end

local function StartAutoRaid()
    SetFeatureState("AutoRaid", true)
    StartTask("AutoRaid", GameConfig.RaidRefresh, function()
        SelectRaid(GameConfig.RaidName)
    end)
end

local function IsFruitTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local name = string.lower(tool.Name)
    return string.find(name, "fruit", 1, true) ~= nil
        or string.find(name, "spin", 1, true) ~= nil
        or string.find(name, "bomb", 1, true) ~= nil
        or string.find(name, "flame", 1, true) ~= nil
end

local function FindFruitTools()
    local found = {}
    for _, container in ipairs({Workspace, player.Backpack, Character()}) do
        if container then
            for _, obj in ipairs(container:GetChildren()) do
                if IsFruitTool(obj) then
                    table.insert(found, obj)
                end
            end
        end
    end
    return found
end

local function StartAutoCollectFruit()
    SetFeatureState("AutoCollectFruit", true)
    StartTask("AutoCollectFruit", GameConfig.FruitRefresh, function()
        for _, fruit in ipairs(FindFruitTools()) do
            StoreFruit(fruit.Name, fruit)
        end
    end)
end

local function SetWalkSpeed(value)
    local hum = Character() and HumanoidOf(Character())
    if hum then hum.WalkSpeed = tonumber(value) or GameConfig.WalkSpeed end
end

local function SetJumpPower(value)
    local hum = Character() and HumanoidOf(Character())
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = tonumber(value) or GameConfig.JumpPower
    end
end

local infiniteJumpConnection
local function SetInfiniteJump(enabled)
    GameState.InfiniteJump = enabled
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
    if enabled then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            local hum = Character() and HumanoidOf(Character())
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end

local noclipConnection
local function SetNoClip(enabled)
    GameState.NoClip = enabled
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if enabled then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = Character()
            if not char then return end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.CanCollide = false
                end
            end
        end)
    else
        local char = Character()
        if char then
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                    obj.CanCollide = true
                end
            end
        end
    end
end

local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    table.clear(ESPObjects)
end

local function ESPColor(kind)
    if kind == "Boss" then return Color3.fromRGB(255, 90, 130) end
    if kind == "Fruit" then return Color3.fromRGB(130, 255, 180) end
    if kind == "NPC" then return Color3.fromRGB(255, 210, 90) end
    return Theme.AccentLight
end

local function AddESP(model, kind)
    if not model or not model:IsA("Model") or ESPObjects[model] then return end
    local root = RootOf(model)
    if not root then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "MeizuESP"
    highlight.FillColor = ESPColor(kind)
    highlight.OutlineColor = Theme.Text
    highlight.FillTransparency = 0.78
    highlight.OutlineTransparency = 0.15
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = model
    highlight.Parent = Gui
    ESPObjects[model] = highlight
end

local function UpdateESP(kind, predicate)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and predicate(obj) then
            AddESP(obj, kind)
        end
    end
end

local function RefreshESP()
    ClearESP()
    if GameState.PlayerESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then AddESP(p.Character, "Player") end
        end
    end
    if GameState.NPCESP then
        UpdateESP("NPC", function(m)
            return m.Parent and m.Parent.Name == "Enemies" and not string.find(string.lower(m.Name), "boss", 1, true)
        end)
    end
    if GameState.BossESP then
        UpdateESP("Boss", function(m)
            local h = HumanoidOf(m)
            return m.Parent and m.Parent.Name == "Enemies" and (string.find(string.lower(m.Name), "boss", 1, true) ~= nil or (h and h.MaxHealth >= 10000))
        end)
    end
    if GameState.FruitESP then
        UpdateESP("Fruit", function(m)
            return string.find(string.lower(m.Name), "fruit", 1, true) ~= nil
        end)
    end
end

RegisterFeature("Auto Quest", function()
    if GameState.AutoQuest then
        SetFeatureState("AutoQuest", false)
    else
        StartAutoQuest()
    end
end)

RegisterFeature("Auto Farm Level", function()
    if GameState.AutoFarmLevel then
        SetFeatureState("AutoFarmLevel", false)
    else
        StartAutoFarm(false, "AutoFarmLevel")
    end
end)

RegisterFeature("Auto Farm Boss", function()
    if GameState.AutoFarmBoss then
        SetFeatureState("AutoFarmBoss", false)
    else
        StartAutoFarm(true, "AutoFarmBoss")
    end
end)

RegisterFeature("Auto Raid", function()
    if GameState.AutoRaid then
        SetFeatureState("AutoRaid", false)
    else
        StartAutoRaid()
    end
end)

RegisterFeature("Auto Collect Fruit", function()
    if GameState.AutoCollectFruit then
        SetFeatureState("AutoCollectFruit", false)
    else
        StartAutoCollectFruit()
    end
end)

RegisterFeature("Infinite Jump", function()
    SetInfiniteJump(not GameState.InfiniteJump)
end)

RegisterFeature("No Clip", function()
    SetNoClip(not GameState.NoClip)
end)

RegisterFeature("WalkSpeed", function()
    SetWalkSpeed(GameConfig.WalkSpeed)
end)

RegisterFeature("JumpPower", function()
    SetJumpPower(GameConfig.JumpPower)
end)

for _, espName in ipairs({"Player ESP", "NPC ESP", "Boss ESP", "Fruit ESP"}) do
    RegisterFeature(espName, function()
        local key = espName:gsub(" ", "")
        if key == "PlayerESP" then GameState.PlayerESP = not GameState.PlayerESP end
        if key == "NPCESP" then GameState.NPCESP = not GameState.NPCESP end
        if key == "BossESP" then GameState.BossESP = not GameState.BossESP end
        if key == "FruitESP" then GameState.FruitESP = not GameState.FruitESP end
        RefreshESP()
    end)
end

Players.PlayerAdded:Connect(function(p)
    if GameState.PlayerESP then
        p.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if GameState.PlayerESP then AddESP(char, "Player") end
        end)
    end
end)

player.CharacterAdded:Connect(function(char)
    task.wait(0.35)
    if GameState.InfiniteJump then SetInfiniteJump(true) end
    if GameState.NoClip then SetNoClip(true) end
    SetWalkSpeed(GameConfig.WalkSpeed)
end)

--==================================================
-- COMPACT TOGGLE BUTTON
--==================================================

local uiVisible = true

local MiniToggle = New("TextButton", {
    Name = "MiniToggle",
    Text = "M",
    Font = Enum.Font.GothamBlack,
    TextSize = 14,
    TextColor3 = Theme.Text,
    AutoButtonColor = false,
    BackgroundColor3 = Theme.Glass2,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -58, 0.5, -20),
    Size = UDim2.new(0, 40, 0, 40),
    ZIndex = 100,
    Parent = Gui,
})
Round(MiniToggle, 20)
AddStroke(MiniToggle, 0.3, 1.2)

local function SetMainVisible(value)
    uiVisible = value
    if value then
        Main.Visible = true
        MiniToggle.Visible = false
        Main.Size = UDim2.new(0, 20, 0, 20)
        Animate(Main, {Size = normalSize}, 0.2)
    else
        Animate(Main, {Size = UDim2.new(0, 20, 0, 20)}, 0.16)
        task.delay(0.17, function()
            if not uiVisible then
                Main.Visible = false
                MiniToggle.Visible = true
            end
        end)
    end
end

MiniToggle.MouseButton1Click:Connect(function()
    SetMainVisible(true)
end)

MiniToggle.MouseEnter:Connect(function()
    Animate(MiniToggle, {BackgroundTransparency = 0, TextColor3 = Theme.AccentLight}, 0.12)
end)
MiniToggle.MouseLeave:Connect(function()
    Animate(MiniToggle, {BackgroundTransparency = 0.12, TextColor3 = Theme.Text}, 0.12)
end)

--==================================================
-- WINDOW DRAG
--==================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- HEADER CONTROLS
--==================================================

local sidebarVisible = true
MenuButton.MouseButton1Click:Connect(function()
    sidebarVisible = not sidebarVisible
    Sidebar.Visible = sidebarVisible

    if sidebarVisible then
        Content.Position = UDim2.new(0.31, 0, 0, 0)
        Content.Size = UDim2.new(0.69, 0, 1, 0)
    else
        Content.Position = UDim2.new(0, 0, 0, 0)
        Content.Size = UDim2.new(1, 0, 1, 0)
    end
end)

local minimized = false
local normalSize = Main.Size

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    Body.Visible = not minimized

    if minimized then
        Animate(Main, {Size = UDim2.new(0.48, 0, 0, 64)}, 0.22)
    else
        Animate(Main, {Size = normalSize}, 0.22)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MiniToggle.Visible = false
    Animate(Main, {
        Size = UDim2.new(0.7, 0, 0.6, 0),
        BackgroundTransparency = 1,
    }, 0.2)
    task.wait(0.21)
    Gui:Destroy()
end)

SettingsButton.MouseButton1Click:Connect(function()
    RenderPage("Settings")
end)

--==================================================
-- SHOW / HIDE
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        SetMainVisible(not uiVisible)
    end
end)

--==================================================
-- INITIAL PAGE
--==================================================

RenderPage("Shop")

print("[MEIZU HUB] Blue Glass UI loaded")

-- Example for the next development stage:
-- RegisterFeature("Redeem Code", function()
--     -- connect the real feature here later
-- end)

return {
    Gui = Gui,
    Main = Main,
    RegisterFeature = RegisterFeature,
    FireFeature = FireFeature,
    RenderPage = RenderPage,
    Game = {
        StartQuest = StartQuest,
        Attack = Attack,
        StoreFruit = StoreFruit,
        SelectRaid = SelectRaid,
        Config = GameConfig,
        State = GameState,
        StopTask = StopTask,
        SetWalkSpeed = SetWalkSpeed,
        SetJumpPower = SetJumpPower,
        SetInfiniteJump = SetInfiniteJump,
        SetNoClip = SetNoClip,
        RefreshESP = RefreshESP,
    },
}
