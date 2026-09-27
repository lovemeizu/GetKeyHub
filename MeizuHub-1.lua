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
    Size = UDim2.new(0.88, 0, 0.78, 0),
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
        FireFeature(title)
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

local uiVisible = true

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible

        if uiVisible then
            Main.Visible = true
            Animate(Main, {Size = normalSize}, 0.2)
        else
            Animate(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            task.wait(0.21)
            Main.Visible = false
        end
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



--==================================================
-- MEIZU HUB v3.0.0 INTEGRATION LAYER
-- Kept separate from the existing Blue Glass UI so the UI layout remains intact.
--==================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local LocalPlayer = player

------------------------------------------------------------------------------
-- 1. CONFIGURATION LAYER
------------------------------------------------------------------------------
local Config = {
    Version = "3.0.0",
    Theme = {
        Background = Color3.fromRGB(12, 20, 32),
        BackgroundTransparency = 0.25,
        GlassBorder = Color3.fromRGB(56, 189, 248),
        Accent = Color3.fromRGB(14, 165, 233),
        TextPrimary = Color3.fromRGB(241, 245, 249),
        TextSecondary = Color3.fromRGB(148, 163, 184)
    },
    Settings = {
        UIScale = 1.0,
        Notifications = true,
        FastAttackSpeed = 0.015,
        FarmDistance = 7
    },
    State = {
        AutoFarmLevel = false,
        AutoChest = false,
        AutoCollectFruit = false,
        MasteryFarm = false,
        InfiniteJump = false,
        NoClip = false,
        ESPPlayers = false,
        ESPFruits = false,
        ESPChests = false
    }
}

------------------------------------------------------------------------------
-- 2. TASK MANAGER ENGINE
------------------------------------------------------------------------------
type TaskState = "Running" | "Stopped" | "Error"

local TaskManager = {
    Threads = {} :: { [string]: thread },
    Connections = {} :: { [string]: RBXScriptConnection },
    Tweens = {} :: { [string]: Tween },
    States = {} :: { [string]: TaskState },
    Cleanups = {} :: { [string]: () -> () }
}

function TaskManager.RunLoop(id: string, interval: number, callback: () -> ())
    TaskManager.Stop(id)

    local isRunning = true
    TaskManager.States[id] = "Running"
    TaskManager.Cleanups[id] = function()
        isRunning = false
    end

    TaskManager.Threads[id] = task.spawn(function()
        while isRunning do
            local success, err = pcall(callback)
            if not success then
                TaskManager.States[id] = "Error"
                warn(string.format("[MeizuHub TaskManager Error - Task: %s]: %s", id, tostring(err)))
            end
            task.wait(interval)
        end
    end)
end

function TaskManager.AddConnection(id: string, connection: RBXScriptConnection)
    if TaskManager.Connections[id] then
        TaskManager.Connections[id]:Disconnect()
    end
    TaskManager.Connections[id] = connection
end

function TaskManager.RegisterTween(id: string, tween: Tween)
    if TaskManager.Tweens[id] then
        TaskManager.Tweens[id]:Cancel()
    end
    TaskManager.Tweens[id] = tween
end

function TaskManager.Stop(id: string)
    if TaskManager.Cleanups[id] then
        pcall(TaskManager.Cleanups[id])
        TaskManager.Cleanups[id] = nil
    end
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
    TaskManager.States[id] = "Stopped"
end

function TaskManager.StopAll()
    for id in pairs(TaskManager.States) do
        TaskManager.Stop(id)
    end
end

-- Chống AFK văng game sau 20 phút
TaskManager.AddConnection("AntiAFK", LocalPlayer.Idled:Connect(function()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
end))

------------------------------------------------------------------------------
-- 3. NETWORK & SAFE REMOTE LAYER
------------------------------------------------------------------------------
local Network = {
    CommF = nil :: RemoteFunction?,
    RegisterAttack = nil :: RemoteEvent?,
    RegisterHit = nil :: RemoteEvent?
}

function Network.Init()
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 3)
    if remotes then
        Network.CommF = remotes:FindFirstChild("CommF_") :: RemoteFunction
    end

    local success, _ = pcall(function()
        local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
        if net then
            Network.RegisterAttack = net:FindFirstChild("RegisterAttack") :: RemoteEvent
            Network.RegisterHit = net:FindFirstChild("RegisterHit") :: RemoteEvent
        end
    end)

    if not success then
        warn("[MeizuHub] Fast Attack Remotes: UNVERIFIED / CẦN KIỂM TRA")
    end
end

function Network.InvokeServer(...: any): (boolean, any)
    if not Network.CommF then
        return false, "CommF_ RemoteFunction not found"
    end
    return pcall(Network.CommF.InvokeServer, Network.CommF, ...)
end

function Network.FastAttack(targetPart: BasePart?)
    if Network.RegisterAttack and Network.RegisterHit then
        pcall(function()
            Network.RegisterAttack:FireServer(0)
            if targetPart then
                Network.RegisterHit:FireServer(targetPart, {targetPart})
            end
        end)
    end
end

Network.Init()

------------------------------------------------------------------------------
-- 4. LAYERED DATA
------------------------------------------------------------------------------
type QuestEntry = {
    Level: number,
    QuestName: string,
    QuestNumber: number,
    MobName: string,
    NPCCFrame: CFrame
}

local DataLayer = {
    Sea1Quests = {
        { Level = 1,   QuestName = "BanditQuest1", QuestNumber = 1, MobName = "Bandit",      NPCCFrame = CFrame.new(1059, 16, 1550) },
        { Level = 10,  QuestName = "JungleQuest",  QuestNumber = 1, MobName = "Monkey",      NPCCFrame = CFrame.new(-1598, 37, 153) },
        { Level = 15,  QuestName = "JungleQuest",  QuestNumber = 2, MobName = "Gorilla",     NPCCFrame = CFrame.new(-1598, 37, 153) },
        { Level = 30,  QuestName = "BuggyQuest1",  QuestNumber = 1, MobName = "Pirate",      NPCCFrame = CFrame.new(-1140, 4, 3828) },
        { Level = 60,  QuestName = "DesertQuest",  QuestNumber = 1, MobName = "Desert Cop",  NPCCFrame = CFrame.new(894, 6, 4388) }
    } :: {QuestEntry},

    Teleports = {
        Sea1 = {
            ["Starter Island"] = CFrame.new(1059, 16, 1550),
            ["Jungle"] = CFrame.new(-1598, 37, 153),
            ["Pirate Village"] = CFrame.new(-1140, 4, 3828),
            ["Desert"] = CFrame.new(894, 6, 4388)
        },
        Sea2 = {
            ["Cafe"] = CFrame.new(-380, 73, 297),
            ["Kingdom of Rose"] = CFrame.new(-429, 73, 1836)
        },
        Sea3 = {
            ["Mansion"] = CFrame.new(-12463, 375, -7562),
            ["Castle on the Sea"] = CFrame.new(-5015, 314, -3004)
        }
    }
}

------------------------------------------------------------------------------
-- 5. NOTIFICATION SYSTEM
------------------------------------------------------------------------------
local Notification = {}
local NotifyContainer: Frame? = nil

function Notification.Init(parentGui: ScreenGui)
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, 260, 1, -20)
    container.Position = UDim2.new(1, -270, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = parentGui

    local layout = Instance.new("UIListLayout")
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container

    NotifyContainer = container
end

function Notification.Show(title: string, message: string, duration: number?)
    if not Config.Settings.Notifications or not NotifyContainer then return end
    duration = duration or 3.5

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 55)
    toast.BackgroundColor3 = Config.Theme.Background
    toast.BackgroundTransparency = 0.15
    toast.Parent = NotifyContainer

    local stroke = Instance.new("UIStroke")
    stroke.Color = Config.Theme.GlassBorder
    stroke.Thickness = 1
    stroke.Parent = toast

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toast

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -16, 0, 20)
    titleLbl.Position = UDim2.new(0, 8, 0, 6)
    titleLbl.Text = title
    titleLbl.TextColor3 = Config.Theme.GlassBorder
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = toast

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -16, 0, 24)
    msgLbl.Position = UDim2.new(0, 8, 0, 24)
    msgLbl.Text = message
    msgLbl.TextColor3 = Config.Theme.TextPrimary
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 11
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextWrapped = true
    msgLbl.BackgroundTransparency = 1
    msgLbl.Parent = toast

    task.delay(duration, function()
        if toast and toast.Parent then
            toast:Destroy()
        end
    end)
end

Notification.Init(Gui)

------------------------------------------------------------------------------
-- 6. FEATURE MODULES
------------------------------------------------------------------------------

local Farming = {}

function Farming.TweenTo(targetCFrame: CFrame, speed: number?): Tween?
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart") :: BasePart
    if not root then return nil end

    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local dist = (root.Position - targetCFrame.Position).Magnitude
    local time = dist / (speed or 300)
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})

    TaskManager.RegisterTween("MovementTween", tween)
    tween:Play()
    return tween
end

function Farming.GetLevel(): number
    local data = LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return (data.Level :: NumberValue).Value
    end
    return 1
end

function Farming.GetCurrentQuest(): QuestEntry
    local level = Farming.GetLevel()
    local current = DataLayer.Sea1Quests[1]
    for _, q in ipairs(DataLayer.Sea1Quests) do
        if level >= q.Level then current = q end
    end
    return current
end

function Farming.SetAutoFarmLevel(state: boolean)
    Config.State.AutoFarmLevel = state
    if not state then
        TaskManager.Stop("AutoFarmLevel")
        return
    end

    TaskManager.RunLoop("AutoFarmLevel", 0.1, function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart :: BasePart

        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local hasQuest = mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible

        local quest = Farming.GetCurrentQuest()

        if not hasQuest then
            if (root.Position - quest.NPCCFrame.Position).Magnitude > 15 then
                Farming.TweenTo(quest.NPCCFrame)
            else
                root.CFrame = quest.NPCCFrame
                Network.InvokeServer("StartQuest", quest.QuestName, quest.QuestNumber)
            end
        else
            local targetMob: Model? = nil
            local enemies = Workspace:FindFirstChild("Enemies")
            if enemies then
                for _, mob in ipairs(enemies:GetChildren()) do
                    if mob.Name == quest.MobName and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                        if (mob.Humanoid :: Humanoid).Health > 0 then
                            targetMob = mob
                            break
                        end
                    end
                end
            end

            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobRoot = targetMob.HumanoidRootPart :: BasePart
                root.CFrame = mobRoot.CFrame * CFrame.new(0, Config.Settings.FarmDistance, 0)
                mobRoot.CanCollide = false
                Network.FastAttack(mobRoot)
            end
        end
    end)
end

local CombatMastery = {
    SelectedWeapon = "Melee"
}

function CombatMastery.EquipWeapon()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer.Backpack
    if not char then return end

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == CombatMastery.SelectedWeapon then
            char.Humanoid:EquipTool(tool)
            break
        end
    end
end

local Fruit = {}

function Fruit.SetAutoCollect(state: boolean)
    Config.State.AutoCollectFruit = state
    if not state then
        TaskManager.Stop("AutoCollectFruit")
        return
    end

    TaskManager.RunLoop("AutoCollectFruit", 1, function()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name:find("Fruit") and (obj:IsA("Tool") or obj:IsA("BasePart")) then
                local handle = obj:IsA("Tool") and obj:FindFirstChild("Handle") or obj
                local char = LocalPlayer.Character
                if handle and char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = (handle :: BasePart).CFrame
                    task.wait(0.5)
                    local ok, err = Network.InvokeServer("StoreFruit", obj.Name, obj)
                    if ok then
                        Notification.Show("[Fruit System]", "Đã cất " .. obj.Name .. " vào rương!")
                    end
                end
            end
        end
    end)
end

local SeaEvent = {
    CurrentEvent = "Không có"
}

function SeaEvent.InitTracker(updateCallback: (string) -> ())
    TaskManager.RunLoop("SeaEventTracker", 3, function()
        local status = "Bình thường"
        if Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("MysticIsland") then
            status = "🌕 Mirage Island (Đảo Khỉ Mới)!"
        elseif Workspace:FindFirstChild("SeaBeast") then
            status = "🌊 Sea Beast Xuất Hiện!"
        end
        SeaEvent.CurrentEvent = status
        updateCallback(status)
    end)
end

local ESP = {
    Highlights = {} :: { [Instance]: Highlight }
}

function ESP.SetCategory(category: string, state: boolean)
    local taskId = "ESP_" .. category
    if not state then
        TaskManager.Stop(taskId)
        for target, hl in pairs(ESP.Highlights) do
            if hl and hl.Parent then hl:Destroy() end
        end
        ESP.Highlights = {}
        return
    end

    TaskManager.RunLoop(taskId, 1.5, function()
        local targets = {}
        if category == "Player" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then table.insert(targets, p.Character) end
            end
        elseif category == "Fruit" then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name:find("Fruit") then table.insert(targets, obj) end
            end
        elseif category == "Chest" then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name:find("Chest") then table.insert(targets, obj) end
            end
        end

        for _, target in ipairs(targets) do
            if not ESP.Highlights[target] then
                local hl = Instance.new("Highlight")
                hl.FillColor = category == "Player" and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(34, 197, 94)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.4
                hl.Parent = target
                ESP.Highlights[target] = hl
            end
        end
    end)
end

local PlayerUtils = {
    DefaultSpeed = 16
}

function PlayerUtils.SetWalkSpeed(speed: number)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        (char.Humanoid :: Humanoid).WalkSpeed = speed
    end
end

function PlayerUtils.SetInfiniteJump(state: boolean)
    Config.State.InfiniteJump = state
    if not state then
        TaskManager.Stop("InfiniteJump")
        return
    end

    TaskManager.AddConnection("InfiniteJump", UserInputService.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            (char.Humanoid :: Humanoid):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end

function PlayerUtils.SetNoClip(state: boolean)
    Config.State.NoClip = state
    if not state then
        TaskManager.Stop("NoClip")
        return
    end

    TaskManager.AddConnection("NoClip", RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end))
end

local ServerUtils = {}

function ServerUtils.GetStats(): (string, string, number)
    local jobId = game.JobId
    local players = string.format("%d/%d", #Players:GetPlayers(), Players.MaxPlayers)
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    return jobId, players, ping
end

function ServerUtils.Rejoin()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

------------------------------------------------------------------------------
-- UI INTEGRATION: existing Blue Glass cards -> v3.0.0 modules
------------------------------------------------------------------------------

local FeatureState = {}

local function BindToggleFeature(name, getter, setter)
    FeatureState[name] = getter
    RegisterFeature(name, function()
        local nextState = not getter()
        setter(nextState)
        return nextState
    end)
end

local function RefreshFeatureCards(name)
    local getter = FeatureState[name]
    if not getter then return end
    local state = getter()
    for _, child in ipairs(ContentScroll:GetChildren()) do
        if child:IsA("Frame") and child.Name == "Card" then
            local titleLabel = child:FindFirstChildOfClass("TextLabel")
            if titleLabel and titleLabel.Text == name then
                local action = child:FindFirstChildOfClass("TextButton")
                if action then
                    action.Text = state and "ON" or "OFF"
                end
            end
        end
    end
end

BindToggleFeature("Auto Farm Level", function()
    return Config.State.AutoFarmLevel
end, Farming.SetAutoFarmLevel)

BindToggleFeature("Auto Collect Fruit", function()
    return Config.State.AutoCollectFruit
end, Fruit.SetAutoCollect)

BindToggleFeature("Infinite Jump", function()
    return Config.State.InfiniteJump
end, PlayerUtils.SetInfiniteJump)

BindToggleFeature("No Clip", function()
    return Config.State.NoClip
end, PlayerUtils.SetNoClip)

BindToggleFeature("Player ESP", function()
    return Config.State.ESPPlayers
end, function(state)
    Config.State.ESPPlayers = state
    ESP.SetCategory("Player", state)
end)

BindToggleFeature("Fruit ESP", function()
    return Config.State.ESPFruits
end, function(state)
    Config.State.ESPFruits = state
    ESP.SetCategory("Fruit", state)
end)

BindToggleFeature("Auto Chest", function()
    return Config.State.AutoChest
end, function(state)
    Config.State.AutoChest = state
    if not state then
        TaskManager.Stop("AutoChest")
    end
end)

RegisterFeature("Rejoin Server", function()
    ServerUtils.Rejoin()
end)

RegisterFeature("Server Information", function()
    local ok, jobId, playerCount, ping = pcall(ServerUtils.GetStats)
    if ok then
        Notification.Show("[Server]", string.format("Players: %s • Ping: %d ms", playerCount, ping))
    else
        Notification.Show("[Server]", "Không lấy được thông tin server")
    end
end)

RegisterFeature("Player Status", function()
    local level = Farming.GetLevel()
    Notification.Show("[Player]", "Level: " .. tostring(level))
end)

RegisterFeature("Melee Skill", function()
    CombatMastery.SelectedWeapon = "Melee"
    CombatMastery.EquipWeapon()
end)

RegisterFeature("Sword Skill", function()
    CombatMastery.SelectedWeapon = "Sword"
    CombatMastery.EquipWeapon()
end)

RegisterFeature("Fruit Skill", function()
    CombatMastery.SelectedWeapon = "Fruit"
    CombatMastery.EquipWeapon()
end)

-- Existing cards without a v3.0.0 implementation remain untouched.
-- They continue using the original Feature API and therefore do not gain
-- invented game logic.

-- Make the existing card renderer aware of v3 stateful features.
local OriginalCreateCard = CreateCard
CreateCard = function(title, description, actionText, index)
    OriginalCreateCard(title, description, actionText, index)
end

-- Rebind the actual card click handlers by wrapping FireFeature.
-- The UI's original FireFeature remains the single dispatch entry point.
local OriginalFireFeature = FireFeature
FireFeature = function(name, ...)
    local callback = FeatureCallbacks[name]
    if callback then
        local result = callback(...)
        RefreshFeatureCards(name)
        return result
    end
    return OriginalFireFeature(name, ...)
end

-- Tracker page is connected to the existing Sea Event page without creating
-- another window or replacing the Blue Glass UI.
local SeaEventStatusLabel = nil
SeaEvent.InitTracker(function(status)
    SeaEvent.CurrentEvent = status
    if SeaEventStatusLabel and SeaEventStatusLabel.Parent then
        SeaEventStatusLabel.Text = "Sea Event: " .. status
    end
end)

-- Update existing card descriptions for features that now have real v3 bindings.
-- The original UI structure and categories are retained.
for _, pageData in pairs(Pages) do
    for _, item in ipairs(pageData) do
        local featureName = item[1]
        if FeatureState[featureName] then
            item[3] = FeatureState[featureName]() and "ON" or "OFF"
        end
    end
end

-- Keep UI cleanup tied to the existing GUI lifetime.
Gui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        TaskManager.StopAll()
    end
end)

print("[MEIZU HUB] v3.0.0 modules integrated into Blue Glass UI")


return {
    Gui = Gui,
    Main = Main,
    RegisterFeature = RegisterFeature,
    FireFeature = FireFeature,
    RenderPage = RenderPage,
    Config = Config,
    TaskManager = TaskManager,
    Network = Network,
    DataLayer = DataLayer,
    Notification = Notification,
    Farming = Farming,
    CombatMastery = CombatMastery,
    Fruit = Fruit,
    SeaEvent = SeaEvent,
    ESP = ESP,
    PlayerUtils = PlayerUtils,
    ServerUtils = ServerUtils,
}
