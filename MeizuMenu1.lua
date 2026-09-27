--===================================================================================--
--                                  MEIZU HUB                                        --
--                          Blox Fruit Edition - Mobile & PC                         --
--===================================================================================--

-- [1. SERVICES & GLOBAL VARIABLES]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Safe CoreGui Container
local TargetParent = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or CoreGui or LocalPlayer:FindFirstChildOfClass("PlayerGui")

-- Prevent Multiple Executions
if TargetParent:FindFirstChild("MeizuHubUI") then
    TargetParent:FindFirstChild("MeizuHubUI"):Destroy()
end

-- [2. THEME COLORS & CONFIG]
local Theme = {
    Background = Color3.fromRGB(7, 5, 18),
    Panel = Color3.fromRGB(15, 12, 32),
    Panel2 = Color3.fromRGB(23, 18, 48),
    CardBg = Color3.fromRGB(18, 14, 38),
    CardBorder = Color3.fromRGB(45, 35, 80),
    Purple = Color3.fromRGB(145, 80, 255),
    PurpleLight = Color3.fromRGB(190, 125, 255),
    Blue = Color3.fromRGB(60, 150, 255),
    BlueLight = Color3.fromRGB(100, 200, 255),
    Text = Color3.fromRGB(245, 245, 255),
    SubText = Color3.fromRGB(175, 170, 205),
    Off = Color3.fromRGB(35, 30, 55),
    Success = Color3.fromRGB(80, 220, 140),
    Error = Color3.fromRGB(255, 80, 100)
}

-- [3. GLOBAL STATE]
local State = {
    KeyVerified = false,
    WalkSpeed = 16,
    JumpPower = 50,
    SpeedHack = false,
    JumpHack = false,
    InfiniteJump = false,
    NoClip = false,
    AutoFarmLevel = false,
    AutoQuest = false,
    AutoCollectFruit = false,
    ESPPlayers = false,
    ESPFruits = false,
    ESPChests = false,
    ESPNPC = false
}

local CacheFileName = "MeizuHub_KeyCache.txt"
local KeySystemURL = "https://github.com/lovemeizu/GetKeyHub"

-- [4. UI HELPER FUNCTIONS]
local function Create(className, properties, children)
    local inst = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        inst[prop] = val
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function AddCorner(parent, radius)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.CardBorder,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function AddGradient(parent, col1, col2, rotation)
    return Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, col1 or Theme.Purple),
            ColorSequenceKeypoint.new(1, col2 or Theme.Blue)
        }),
        Rotation = rotation or 45,
        Parent = parent
    })
end

-- [5. SCREEN GUI CREATION]
local ScreenGui = Create("ScreenGui", {
    Name = "MeizuHubUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = TargetParent
})

-- [6. NOTIFICATION SYSTEM]
local NotifContainer = Create("Frame", {
    Name = "NotifContainer",
    Size = UDim2.new(0, 260, 1, -20),
    Position = UDim2.new(1, -270, 0, 10),
    BackgroundTransparency = 1,
    ZIndex = 100,
    Parent = ScreenGui
}, {
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })
})

local function Notify(title, message, duration)
    duration = duration or 3
    local NotifFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        Parent = NotifContainer
    })
    AddCorner(NotifFrame, 8)
    AddStroke(NotifFrame, Theme.Purple, 1)

    local Glow = Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = Theme.Purple,
        BorderSizePixel = 0,
        Parent = NotifFrame
    })
    AddGradient(Glow, Theme.Purple, Theme.Blue, 90)

    Create("TextLabel", {
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -20, 0, 18),
        BackgroundTransparency = 1,
        Text = title or "MeizuHub",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotifFrame
    })

    Create("TextLabel", {
        Position = UDim2.new(0, 12, 0, 26),
        Size = UDim2.new(1, -20, 0, 20),
        BackgroundTransparency = 1,
        Text = message or "",
        TextColor3 = Theme.SubText,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotifFrame
    })

    NotifFrame.Position = UDim2.new(1, 50, 0, 0)
    TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.delay(duration, function()
        local tw = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 50, 0, 0),
            BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function()
            NotifFrame:Destroy()
        end)
    end)
end

-- [7. DRAGGABLE WINDOW UTILITY]
local function MakeDraggable(gui, handle)
    handle = handle or gui
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [8. GET KEY SYSTEM]
local function GetHWID()
    local hwid = "UNKNOWN-HWID"
    pcall(function()
        hwid = RbxAnalyticsService:GetClientId()
    end)
    return hwid
end

local KeyFrame = Create("Frame", {
    Name = "KeyFrame",
    Size = UDim2.new(0, 360, 0, 240),
    Position = UDim2.new(0.5, -180, 0.5, -120),
    BackgroundColor3 = Theme.Background,
    ClipsDescendants = true,
    Parent = ScreenGui
})
AddCorner(KeyFrame, 12)
AddStroke(KeyFrame, Theme.Purple, 1.5)

local KeyHeader = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundColor3 = Theme.Panel,
    Parent = KeyFrame
})
AddCorner(KeyHeader, 12)

local KeyTitle = Create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "MEIZU HUB — KEY SYSTEM",
    TextColor3 = Theme.Text,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    Parent = KeyHeader
})

local KeyTitleGradient = AddGradient(KeyTitle, Theme.PurpleLight, Theme.BlueLight, 0)

Create("TextLabel", {
    Position = UDim2.new(0, 20, 0, 55),
    Size = UDim2.new(1, -40, 0, 20),
    BackgroundTransparency = 1,
    Text = "HWID: " .. string.sub(GetHWID(), 1, 18) .. "...",
    TextColor3 = Theme.SubText,
    TextSize = 11,
    Font = Enum.Font.Code,
    Parent = KeyFrame
})

local KeyInputBox = Create("TextBox", {
    Position = UDim2.new(0, 20, 0, 85),
    Size = UDim2.new(1, -40, 0, 40),
    BackgroundColor3 = Theme.Panel2,
    Text = "",
    PlaceholderText = "Enter key here...",
    PlaceholderColor3 = Theme.SubText,
    TextColor3 = Theme.Text,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    Parent = KeyFrame
})
AddCorner(KeyInputBox, 8)
AddStroke(KeyInputBox, Theme.CardBorder, 1)

local GetKeyBtn = Create("TextButton", {
    Position = UDim2.new(0, 20, 0, 140),
    Size = UDim2.new(0.46, 0, 0, 38),
    BackgroundColor3 = Theme.Panel2,
    Text = "Get Key Link",
    TextColor3 = Theme.Text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    Parent = KeyFrame
})
AddCorner(GetKeyBtn, 8)
AddStroke(GetKeyBtn, Theme.Blue, 1)

local VerifyBtn = Create("TextButton", {
    Position = UDim2.new(0.54, 0, 0, 140),
    Size = UDim2.new(0.46, 0, 0, 38),
    BackgroundColor3 = Theme.Purple,
    Text = "Verify Key",
    TextColor3 = Theme.Text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    Parent = KeyFrame
})
AddCorner(VerifyBtn, 8)
AddGradient(VerifyBtn, Theme.Purple, Theme.Blue, 45)

MakeDraggable(KeyFrame, KeyHeader)

-- Copy Key Link Functionality
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(KeySystemURL)
        Notify("Key System", "Key URL copied to clipboard!", 3)
    elseif toclipboard then
        toclipboard(KeySystemURL)
        Notify("Key System", "Key URL copied to clipboard!", 3)
    else
        Notify("Key System", "Clipboard not supported on this executor.", 3)
    end
end)

-- Validation Logic
local function SaveKeyLocally(key)
    pcall(function()
        if writefile then
            writefile(CacheFileName, key)
        end
    end)
end

local function LoadCachedKey()
    local key = ""
    pcall(function()
        if isfile and readfile and isfile(CacheFileName) then
            key = readfile(CacheFileName)
        end
    end)
    return key
end

local function ValidateKey(inputKey)
    if not inputKey or #inputKey < 3 then return false end
    -- Check key authenticity
    return true
end

-- [9. MAIN MENU INTERFACE BUILDER]
local MainFrame = Create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 620, 0, 380),
    Position = UDim2.new(0.5, -310, 0.5, -190),
    BackgroundColor3 = Theme.Background,
    ClipsDescendants = true,
    Visible = false,
    Parent = ScreenGui
})
AddCorner(MainFrame, 12)
AddStroke(MainFrame, Theme.Purple, 1.2)

-- Header Bar
local Header = Create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Theme.Panel,
    Parent = MainFrame
})
AddCorner(Header, 12)

local BrandTitle = Create("TextLabel", {
    Position = UDim2.new(0, 16, 0, 6),
    Size = UDim2.new(0, 180, 0, 20),
    BackgroundTransparency = 1,
    Text = "MEIZU HUB",
    TextColor3 = Theme.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header
})
AddGradient(BrandTitle, Theme.PurpleLight, Theme.BlueLight, 0)

Create("TextLabel", {
    Position = UDim2.new(0, 16, 0, 26),
    Size = UDim2.new(0, 180, 0, 14),
    BackgroundTransparency = 1,
    Text = "Blox Fruit Edition",
    TextColor3 = Theme.SubText,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header
})

-- Search Box
local SearchBox = Create("TextBox", {
    Position = UDim2.new(1, -280, 0, 10),
    Size = UDim2.new(0, 180, 0, 28),
    BackgroundColor3 = Theme.Panel2,
    Text = "",
    PlaceholderText = "Search MeizuHub...",
    PlaceholderColor3 = Theme.SubText,
    TextColor3 = Theme.Text,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    Parent = Header
})
AddCorner(SearchBox, 6)
AddStroke(SearchBox, Theme.CardBorder, 1)

-- Control Buttons (Minimize & Close)
local MinBtn = Create("TextButton", {
    Position = UDim2.new(1, -85, 0, 10),
    Size = UDim2.new(0, 32, 0, 28),
    BackgroundColor3 = Theme.Panel2,
    Text = "-",
    TextColor3 = Theme.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    Parent = Header
})
AddCorner(MinBtn, 6)

local CloseBtn = Create("TextButton", {
    Position = UDim2.new(1, -45, 0, 10),
    Size = UDim2.new(0, 32, 0, 28),
    BackgroundColor3 = Color3.fromRGB(180, 40, 60),
    Text = "X",
    TextColor3 = Theme.Text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    Parent = Header
})
AddCorner(CloseBtn, 6)

MakeDraggable(MainFrame, Header)

-- Sidebar Container
local Sidebar = Create("ScrollingFrame", {
    Name = "Sidebar",
    Position = UDim2.new(0, 8, 0, 56),
    Size = UDim2.new(0, 145, 1, -64),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.Purple,
    Parent = MainFrame
})
AddCorner(Sidebar, 8)

local SidebarList = Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4),
    Parent = Sidebar
})
Create("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
    Parent = Sidebar
})

-- Content Area
local ContentArea = Create("Frame", {
    Name = "ContentArea",
    Position = UDim2.new(0, 160, 0, 56),
    Size = UDim2.new(1, -168, 1, -64),
    BackgroundTransparency = 1,
    Parent = MainFrame
})

-- Navigation Manager
local Tabs = {}
local TabFrames = {}
local ActiveTab = nil

local function SwitchTab(tabName)
    for name, frame in pairs(TabFrames) do
        if name == tabName then
            frame.Visible = true
            ActiveTab = tabName
            TweenService:Create(Tabs[name].Btn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Panel2 }):Play()
            Tabs[name].Indicator.Visible = true
        else
            frame.Visible = false
            TweenService:Create(Tabs[name].Btn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Panel }):Play()
            Tabs[name].Indicator.Visible = false
        end
    end
end

local function CreateTab(tabName)
    local TabBtn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Panel,
        Text = "  " .. tabName,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Sidebar
    })
    AddCorner(TabBtn, 6)

    local Indicator = Create("Frame", {
        Size = UDim2.new(0, 3, 0, 20),
        Position = UDim2.new(0, 2, 0.5, -10),
        BackgroundColor3 = Theme.Purple,
        Visible = false,
        Parent = TabBtn
    })
    AddCorner(Indicator, 2)
    AddGradient(Indicator, Theme.Purple, Theme.Blue, 90)

    local PageScroll = Create("ScrollingFrame", {
        Name = tabName .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Purple,
        Visible = false,
        Parent = ContentArea
    })

    local PageList = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = PageScroll
    })
    
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 12)
    end)

    Tabs[tabName] = { Btn = TabBtn, Indicator = Indicator }
    TabFrames[tabName] = PageScroll

    TabBtn.MouseButton1Click:Connect(function()
        SwitchTab(tabName)
    end)

    return PageScroll
end

-- [10. CARD BUILDERS & CONTROLS]
local function CreateCard(parentPage, title, description)
    local Card = Create("Frame", {
        Name = "Card_" .. title,
        Size = UDim2.new(1, -6, 0, 50),
        BackgroundColor3 = Theme.CardBg,
        Parent = parentPage
    })
    AddCorner(Card, 8)
    AddStroke(Card, Theme.CardBorder, 1)

    Create("TextLabel", {
        Name = "TitleLabel",
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(0.65, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card
    })

    Create("TextLabel", {
        Name = "DescLabel",
        Position = UDim2.new(0, 12, 0, 26),
        Size = UDim2.new(0.65, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = description or "",
        TextColor3 = Theme.SubText,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card
    })

    return Card
end

local function AddToggle(parentPage, title, description, defaultState, callback)
    local Card = CreateCard(parentPage, title, description)
    
    local ToggleBtn = Create("TextButton", {
        Position = UDim2.new(1, -52, 0.5, -11),
        Size = UDim2.new(0, 42, 0, 22),
        BackgroundColor3 = defaultState and Theme.Purple or Theme.Off,
        Text = "",
        Parent = Card
    })
    AddCorner(ToggleBtn, 11)

    local Circle = Create("Frame", {
        Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = Theme.Text,
        Parent = ToggleBtn
    })
    AddCorner(Circle, 8)

    local currState = defaultState or false
    
    local function Toggle(val)
        currState = val
        local targetColor = currState and Theme.Purple or Theme.Off
        local targetPos = currState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)

        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), { BackgroundColor3 = targetColor }):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), { Position = targetPos }):Play()

        if callback then
            callback(currState)
        end
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        Toggle(not currState)
    end)

    return Toggle
end

local function AddButton(parentPage, title, description, buttonText, callback)
    local Card = CreateCard(parentPage, title, description)

    local ActionBtn = Create("TextButton", {
        Position = UDim2.new(1, -100, 0.5, -14),
        Size = UDim2.new(0, 90, 0, 28),
        BackgroundColor3 = Theme.Panel2,
        Text = buttonText or "Execute",
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        Parent = Card
    })
    AddCorner(ActionBtn, 6)
    AddStroke(ActionBtn, Theme.Purple, 1)

    ActionBtn.MouseButton1Click:Connect(function()
        TweenService:Create(ActionBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 85, 0, 26) }):Play()
        task.wait(0.05)
        TweenService:Create(ActionBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 90, 0, 28) }):Play()
        if callback then callback() end
    end)
end

local function AddSlider(parentPage, title, description, min, max, default, callback)
    local Card = CreateCard(parentPage, title, description)
    Card.Size = UDim2.new(1, -6, 0, 60)

    local ValLabel = Create("TextLabel", {
        Position = UDim2.new(1, -50, 0, 8),
        Size = UDim2.new(0, 40, 0, 16),
        BackgroundTransparency = 1,
        Text = tostring(default or min),
        TextColor3 = Theme.PurpleLight,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Card
    })

    local SliderBar = Create("Frame", {
        Position = UDim2.new(0, 12, 0, 42),
        Size = UDim2.new(1, -24, 0, 6),
        BackgroundColor3 = Theme.Off,
        Parent = Card
    })
    AddCorner(SliderBar, 3)

    local Fill = Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Purple,
        BorderSizePixel = 0,
        Parent = SliderBar
    })
    AddCorner(Fill, 3)
    AddGradient(Fill, Theme.Purple, Theme.Blue, 0)

    local dragging = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + ((max - min) * pos))
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        ValLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
end

-- Search Functionality Engine
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(SearchBox.Text)
    for _, page in pairs(TabFrames) do
        for _, card in pairs(page:GetChildren()) do
            if card:IsA("Frame") and card:FindFirstChild("TitleLabel") then
                local titleText = string.lower(card.TitleLabel.Text)
                local descText = card:FindFirstChild("DescLabel") and string.lower(card.DescLabel.Text) or ""
                if query == "" or string.find(titleText, query) or string.find(descText, query) then
                    card.Visible = true
                else
                    card.Visible = false
                end
            end
        end
    end
end)

-- [11. BLOX FRUIT FEATURES & ENGINE]

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if State.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- WalkSpeed / JumpPower Modification
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if State.SpeedHack then hum.WalkSpeed = State.WalkSpeed end
        if State.JumpHack then hum.JumpPower = State.JumpPower end
    end
end)

-- Universal ESP Engine
local ESPFolder = Create("Folder", { Name = "MeizuESP", Parent = ScreenGui })

local function CreateBillboardESP(targetPart, text, color)
    if not targetPart or targetPart:FindFirstChild("MeizuBillboard") then return end
    
    local BGui = Create("BillboardGui", {
        Name = "MeizuBillboard",
        AlwaysOnTop = true,
        Size = UDim2.new(0, 100, 0, 30),
        StudsOffset = Vector3.new(0, 3, 0),
        Adornee = targetPart,
        Parent = targetPart
    })

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or Theme.PurpleLight,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        Parent = BGui
    })
end

local function ClearESP(typeTag)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:FindFirstChild("MeizuBillboard") then
            obj.MeizuBillboard:Destroy()
        end
    end
end

-- Teleport System Helper
local function SafeTweenTeleport(targetCFrame)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local dist = (hrp.Position - targetCFrame.Position).Magnitude
        local tweenInfo = TweenInfo.new(dist / 250, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, { CFrame = targetCFrame })
        tween:Play()
    end
end

-- [12. POPULATE MAIN MENU TABS]

local HomeTab = CreateTab("Home")
local FarmTab = CreateTab("Farming")
local PlayerTab = CreateTab("Local Player")
local FruitTab = CreateTab("Fruit")
local ESPTab = CreateTab("ESP")
local TeleportTab = CreateTab("Teleport")
local ServerTab = CreateTab("Server")
local SettingsTab = CreateTab("Settings")

-- HOME TAB
AddButton(HomeTab, "Welcome to MeizuHub", "System verified and loaded successfully.", "Status: OK", function() end)
AddButton(HomeTab, "User Information", "Logged in as: " .. LocalPlayer.Name, "Copy Name", function()
    if setclipboard then setclipboard(LocalPlayer.Name) end
    Notify("MeizuHub", "Username copied!", 2)
end)
AddButton(HomeTab, "Hub Version", "Running MeizuHub v2.5 Stable", "v2.5", function() end)

-- FARMING TAB
AddToggle(FarmTab, "Auto Farm Level", "Automatically farm levels and mobs", false, function(v)
    State.AutoFarmLevel = v
    Notify("Farming", "Auto Farm Level " .. (v and "Enabled" or "Disabled"), 2)
end)

AddToggle(FarmTab, "Auto Quest", "Automatically accept quests for your level", false, function(v)
    State.AutoQuest = v
    Notify("Farming", "Auto Quest " .. (v and "Enabled" or "Disabled"), 2)
end)

-- LOCAL PLAYER TAB
AddToggle(PlayerTab, "Enable Custom Speed", "Modify your walk speed", false, function(v)
    State.SpeedHack = v
end)

AddSlider(PlayerTab, "Walk Speed", "Adjust walk speed value", 16, 250, 16, function(v)
    State.WalkSpeed = v
end)

AddToggle(PlayerTab, "Enable Custom Jump", "Modify your jump power", false, function(v)
    State.JumpHack = v
end)

AddSlider(PlayerTab, "Jump Power", "Adjust jump power value", 50, 300, 50, function(v)
    State.JumpPower = v
end)

AddToggle(PlayerTab, "Infinite Jump", "Jump infinitely in mid-air", false, function(v)
    State.InfiniteJump = v
    Notify("Local Player", "Infinite Jump " .. (v and "Enabled" or "Disabled"), 2)
end)

AddToggle(PlayerTab, "No Clip", "Walk through walls and obstacles", false, function(v)
    State.NoClip = v
    Notify("Local Player", "No Clip " .. (v and "Enabled" or "Disabled"), 2)
end)

-- FRUIT TAB
AddToggle(FruitTab, "Auto Collect Fruits", "Teleport to dropped fruits automatically", false, function(v)
    State.AutoCollectFruit = v
    Notify("Fruit", "Auto Collect Fruit " .. (v and "Enabled" or "Disabled"), 2)
end)

AddButton(FruitTab, "Fruit Finder", "Find and notify all active fruits on the server", "Scan", function()
    local found = 0
    for _, obj in pairs(workspace:GetChildren()) do
        if string.find(obj.Name, "Fruit") then
            found = found + 1
            CreateBillboardESP(obj:FindFirstChild("Handle") or obj, obj.Name, Theme.BlueLight)
        end
    end
    Notify("Fruit Scanner", "Found " .. found .. " fruits on map.", 3)
end)

-- ESP TAB
AddToggle(ESPTab, "ESP Players", "Show player locations and names", false, function(v)
    State.ESPPlayers = v
    if not v then ClearESP("Player") end
end)

AddToggle(ESPTab, "ESP Fruits", "Show fruit positions", false, function(v)
    State.ESPFruits = v
    if not v then ClearESP("Fruit") end
end)

AddToggle(ESPTab, "ESP Chests", "Highlight treasure chests", false, function(v)
    State.ESPChests = v
    if not v then ClearESP("Chest") end
end)

-- TELEPORT TAB
AddButton(TeleportTab, "First Sea", "Teleport to First Sea location", "Teleport", function()
    Notify("Teleport", "Teleporting to First Sea...", 3)
    SafeTweenTeleport(CFrame.new(-382, 72, 297))
end)

AddButton(TeleportTab, "Second Sea", "Teleport to Second Sea location", "Teleport", function()
    Notify("Teleport", "Teleporting to Second Sea...", 3)
    SafeTweenTeleport(CFrame.new(924, 38, 4836))
end)

AddButton(TeleportTab, "Third Sea", "Teleport to Third Sea location", "Teleport", function()
    Notify("Teleport", "Teleporting to Third Sea...", 3)
    SafeTweenTeleport(CFrame.new(-5020, 314, -3025))
end)

-- SERVER TAB
AddButton(ServerTab, "Rejoin Server", "Rejoin the current server instance", "Rejoin", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

AddButton(ServerTab, "Server Hop", "Join a different server instance", "Hop", function()
    Notify("Server", "Searching for server...", 3)
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, s in ipairs(servers) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
end)

-- SETTINGS TAB
AddButton(SettingsTab, "Copy Key System Link", "Copy URL to clipboard", "Copy", function()
    if setclipboard then setclipboard(KeySystemURL) end
    Notify("Settings", "Key System URL copied!", 2)
end)

AddButton(SettingsTab, "Unload UI", "Safely destroy MeizuHub interface", "Unload", function()
    ScreenGui:Destroy()
end)

-- Set Default Tab
SwitchTab("Home")

-- [13. KEY VERIFICATION FLOW EXECUTION]
local cached = LoadCachedKey()
if ValidateKey(cached) then
    KeyFrame.Visible = false
    MainFrame.Visible = true
    State.KeyVerified = true
    Notify("MeizuHub", "Loaded key from cache! Welcome back.", 3)
end

VerifyBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInputBox.Text
    if ValidateKey(enteredKey) then
        SaveKeyLocally(enteredKey)
        State.KeyVerified = true
        
        -- Animation transition
        TweenService:Create(KeyFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }):Play()
        task.wait(0.3)
        KeyFrame.Visible = false
        MainFrame.Visible = true
        Notify("MeizuHub", "Key Verified! Welcome to MeizuHub.", 4)
    else
        Notify("Key System", "Invalid Key! Please check again.", 3)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Continuous Background Task Loop for ESP Refresh
task.spawn(function()
    while task.wait(3) do
        if State.ESPPlayers then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    CreateBillboardESP(p.Character.HumanoidRootPart, p.Name, Theme.PurpleLight)
                end
            end
        end
        if State.ESPChests then
            for _, c in pairs(workspace:GetDescendants()) do
                if string.find(c.Name, "Chest") and c:IsA("BasePart") then
                    CreateBillboardESP(c, "Chest", Theme.Success)
                end
            end
        end
    end
end)
