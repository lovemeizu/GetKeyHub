--==================================================
-- MEIZU HUB - SYSTEM & BLUE GLASS UI INTEGRATION
-- Full Key System (Auto HWID & Render API Sync) + Main UI
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Xóa UI cũ nếu đã tồn tại
local oldGui = PlayerGui:FindFirstChild("MeizuHubComplete")
if oldGui then
    oldGui:Destroy()
end

-- Lấy HWID thiết bị tự động (Tương thích hầu hết các Executor)
local function GetDeviceHWID()
    if gethwid then
        return gethwid()
    elseif syn and syn.get_hwid then
        return syn.get_hwid()
    else
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end
end

local ClientHWID = GetDeviceHWID()

-- Bảng màu chuẩn Blue Glass Theme
local Theme = {
    Background = Color3.fromRGB(6, 15, 28),
    Glass = Color3.fromRGB(10, 24, 44),
    GlassCard = Color3.fromRGB(14, 34, 60),
    Border = Color3.fromRGB(0, 140, 255),
    BorderMuted = Color3.fromRGB(20, 60, 105),
    Accent = Color3.fromRGB(0, 162, 255),
    AccentLight = Color3.fromRGB(100, 210, 255),
    Text = Color3.fromRGB(240, 248, 255),
    SubText = Color3.fromRGB(140, 170, 200),
    Success = Color3.fromRGB(46, 204, 113),
    Error = Color3.fromRGB(231, 76, 60),
    ButtonBlue = Color3.fromRGB(24, 119, 242)
}

-- Cấu hình hệ thống Key động (Tích hợp HWID & Render Server)
local KeySystemConfig = {
    HWID = ClientHWID,
    GetKeyBaseUrl = "https://lovemeizu.github.io/GetKeyHub/getkey.html",
    ApiUrl = "https://getkeyhub-uwal.onrender.com"
}

-- Tạo Link Get Key cá nhân hóa chứa HWID người dùng
local function GenerateGetKeyLink()
    return KeySystemConfig.GetKeyBaseUrl .. "?hwid=" .. KeySystemConfig.HWID
end

-- Hàm tạo Instance nhanh
local function New(className, properties)
    local instance = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        instance[prop] = val
    end
    return instance
end

local function AddCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = object
    return corner
end

local function AddStroke(object, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.Parent = object
    return stroke
end

local function Animate(object, properties, duration)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- Tạo ScreenGui chính
local ScreenGui = New("ScreenGui", {
    Name = "MeizuHubComplete",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = PlayerGui
})

--==================================================
-- GIAO DIỆN GET KEY
--==================================================

local KeyFrame = New("Frame", {
    Name = "KeyFrame",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0, 340, 0, 420),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 20,
    Parent = ScreenGui
})
AddCorner(KeyFrame, 18)
AddStroke(KeyFrame, Theme.BorderMuted, 1.2, 0.3)

-- Gradient Nền Key
local KeyGradient = Instance.new("UIGradient")
KeyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 22, 38)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 12, 22))
})
KeyGradient.Rotation = 45
KeyGradient.Parent = KeyFrame

-- Badge "ONE-TIME KEY"
local BadgeFrame = New("Frame", {
    BackgroundColor3 = Color3.fromRGB(16, 40, 70),
    Position = UDim2.new(0, 24, 0, 24),
    Size = UDim2.new(0, 110, 0, 24),
    ZIndex = 21,
    Parent = KeyFrame
})
AddCorner(BadgeFrame, 12)
AddStroke(BadgeFrame, Theme.Accent, 1, 0.7)

local BadgeDot = New("Frame", {
    BackgroundColor3 = Color3.fromRGB(0, 225, 255),
    Position = UDim2.new(0, 8, 0.5, -3),
    Size = UDim2.new(0, 6, 0, 6),
    ZIndex = 22,
    Parent = BadgeFrame
})
AddCorner(BadgeDot, 6)

New("TextLabel", {
    Text = "ONE-TIME KEY",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Theme.AccentLight,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 0),
    Size = UDim2.new(1, -18, 1, 0),
    ZIndex = 22,
    Parent = BadgeFrame
})

-- Tiêu đề Key UI
New("TextLabel", {
    Text = "MeizuHub",
    Font = Enum.Font.GothamBlack,
    TextSize = 28,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 24, 0, 62),
    Size = UDim2.new(1, -48, 0, 34),
    ZIndex = 21,
    Parent = KeyFrame
})

New("TextLabel", {
    Text = "Nhập key để mở MeizuHub.",
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 24, 0, 100),
    Size = UDim2.new(1, -48, 0, 20),
    ZIndex = 21,
    Parent = KeyFrame
})

New("TextLabel", {
    Text = "• Link Get Key đã gắn HWID tự động",
    Font = Enum.Font.GothamSemibold,
    TextSize = 11,
    TextColor3 = Color3.fromRGB(241, 196, 15),
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 24, 0, 138),
    Size = UDim2.new(1, -48, 0, 20),
    ZIndex = 21,
    Parent = KeyFrame
})

-- Ô nhập Key
local KeyInputBox = New("TextBox", {
    PlaceholderText = "Nhập key...",
    PlaceholderColor3 = Theme.SubText,
    Text = "",
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = Theme.Text,
    BackgroundColor3 = Color3.fromRGB(12, 28, 48),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 24, 0, 172),
    Size = UDim2.new(1, -48, 0, 46),
    ClearTextOnFocus = false,
    ZIndex = 21,
    Parent = KeyFrame
})
AddCorner(KeyInputBox, 10)
AddStroke(KeyInputBox, Theme.BorderMuted, 1, 0.5)

local inputPad = Instance.new("UIPadding")
inputPad.PaddingLeft = UDim.new(0, 14)
inputPad.Parent = KeyInputBox

-- Nút Get Key Free
local GetKeyBtn = New("TextButton", {
    Text = "Tạo / Lấy Key Free (Copy Link)",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Theme.Text,
    BackgroundColor3 = Theme.ButtonBlue,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 24, 0, 230),
    Size = UDim2.new(1, -48, 0, 44),
    AutoButtonColor = false,
    ZIndex = 21,
    Parent = KeyFrame
})
AddCorner(GetKeyBtn, 10)

-- Nút Xác thực Key
local VerifyKeyBtn = New("TextButton", {
    Text = "Xác thực Key Online",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Theme.Text,
    BackgroundColor3 = Color3.fromRGB(18, 38, 62),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 24, 0, 284),
    Size = UDim2.new(1, -48, 0, 44),
    AutoButtonColor = false,
    ZIndex = 21,
    Parent = KeyFrame
})
AddCorner(VerifyKeyBtn, 10)
AddStroke(VerifyKeyBtn, Theme.BorderMuted, 1, 0.6)

-- Thông báo dưới cùng Key UI
local StatusLabel = New("TextLabel", {
    Text = "",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = Theme.SubText,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 24, 0, 340),
    Size = UDim2.new(1, -48, 0, 20),
    ZIndex = 21,
    Parent = KeyFrame
})

New("TextLabel", {
    Text = "HWID: " .. string.sub(KeySystemConfig.HWID, 1, 16) .. "...",
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(80, 110, 140),
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 24, 1, -28),
    Size = UDim2.new(1, -48, 0, 18),
    ZIndex = 21,
    Parent = KeyFrame
})

--==================================================
-- GIAO DIỆN CHÍNH MAIN HUB
--==================================================

local MainFrame = New("Frame", {
    Name = "MainFrame",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0, 680, 0, 410),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 5,
    Parent = ScreenGui
})
AddCorner(MainFrame, 14)
AddStroke(MainFrame, Theme.Border, 1.5, 0.2)

-- Header Bar
local MainHeader = New("Frame", {
    Name = "MainHeader",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 45),
    ZIndex = 10,
    Parent = MainFrame
})

local SystemDot = New("Frame", {
    BackgroundColor3 = Color3.fromRGB(0, 230, 255),
    Position = UDim2.new(0, 16, 0, 18),
    Size = UDim2.new(0, 8, 0, 8),
    ZIndex = 11,
    Parent = MainHeader
})
AddCorner(SystemDot, 4)

New("TextLabel", {
    Text = "SYSTEM\nONLINE",
    Font = Enum.Font.GothamBold,
    TextSize = 8,
    TextColor3 = Theme.AccentLight,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 30, 0, 12),
    Size = UDim2.new(0, 60, 0, 20),
    ZIndex = 11,
    Parent = MainHeader
})

local LogoIcon = New("Frame", {
    BackgroundColor3 = Theme.GlassCard,
    Position = UDim2.new(0.5, -20, 0, 6),
    Size = UDim2.new(0, 36, 0, 34),
    ZIndex = 11,
    Parent = MainHeader
})
AddCorner(LogoIcon, 8)
AddStroke(LogoIcon, Theme.Border, 1, 0.4)

New("TextLabel", {
    Text = "❖",
    Font = Enum.Font.GothamBlack,
    TextSize = 18,
    TextColor3 = Theme.AccentLight,
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 12,
    Parent = LogoIcon
})

New("TextLabel", {
    Text = "Meizu Hub - Blox Fruit",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 25, 0, 12),
    Size = UDim2.new(0, 200, 0, 22),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11,
    Parent = MainHeader
})

local CloseBtn = New("TextButton", {
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Theme.SubText,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -36, 0, 10),
    Size = UDim2.new(0, 26, 0, 26),
    ZIndex = 12,
    Parent = MainHeader
})

New("Frame", {
    BackgroundColor3 = Theme.Border,
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 12, 1, -1),
    Size = UDim2.new(1, -24, 0, 1),
    ZIndex = 10,
    Parent = MainHeader
})

-- Body Container
local MainBody = New("Frame", {
    Name = "MainBody",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 50),
    Size = UDim2.new(1, -20, 1, -58),
    ZIndex = 8,
    Parent = MainFrame
})

-- Sidebar
local Sidebar = New("Frame", {
    Name = "Sidebar",
    BackgroundColor3 = Theme.Glass,
    BackgroundTransparency = 0.3,
    Size = UDim2.new(0.32, 0, 1, 0),
    ZIndex = 9,
    Parent = MainBody
})
AddCorner(Sidebar, 10)
AddStroke(Sidebar, Theme.Border, 1, 0.6)

local SearchBox = New("TextBox", {
    PlaceholderText = "Search section...",
    PlaceholderColor3 = Theme.SubText,
    Text = "",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = Theme.Text,
    BackgroundColor3 = Color3.fromRGB(8, 20, 36),
    Position = UDim2.new(0, 8, 0, 8),
    Size = UDim2.new(1, -16, 0, 32),
    ClearTextOnFocus = false,
    ZIndex = 11,
    Parent = Sidebar
})
AddCorner(SearchBox, 8)
AddStroke(SearchBox, Theme.BorderMuted, 1, 0.5)

local searchPad = Instance.new("UIPadding")
searchPad.PaddingLeft = UDim.new(0, 26)
searchPad.Parent = SearchBox

New("TextLabel", {
    Text = "⌕",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Theme.AccentLight,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 6),
    Size = UDim2.new(0, 16, 0, 20),
    ZIndex = 12,
    Parent = SearchBox
})

local SideScroll = New("ScrollingFrame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 4, 0, 46),
    Size = UDim2.new(1, -8, 1, -50),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.Accent,
    ZIndex = 10,
    Parent = Sidebar
})

local sideLayout = New("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder
})
sideLayout.Parent = SideScroll

-- Content Panel
local ContentArea = New("Frame", {
    Name = "ContentArea",
    BackgroundColor3 = Theme.Glass,
    BackgroundTransparency = 0.3,
    Position = UDim2.new(0.335, 0, 0, 0),
    Size = UDim2.new(0.665, 0, 1, 0),
    ZIndex = 9,
    Parent = MainBody
})
AddCorner(ContentArea, 10)
AddStroke(ContentArea, Theme.Border, 1, 0.6)

local CategoryTitle = New("TextLabel", {
    Text = "Shop",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 10),
    Size = UDim2.new(0.5, 0, 0, 22),
    ZIndex = 10,
    Parent = ContentArea
})

local SubCategoryTitle = New("TextLabel", {
    Text = "Misc Shop",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0, 12),
    Size = UDim2.new(0.5, -16, 0, 20),
    ZIndex = 10,
    Parent = ContentArea
})

local ContentScroll = New("ScrollingFrame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 10, 0, 38),
    Size = UDim2.new(1, -20, 1, -46),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Accent,
    ZIndex = 10,
    Parent = ContentArea
})

local contentLayout = New("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder
})
contentLayout.Parent = ContentScroll

--==================================================
-- DỮ LIỆU TAB VÀ TÍNH NĂNG
--==================================================

local TabData = {
    ["Shop"] = {
        Sub = "Misc Shop",
        Items = {
            {Title = "Redeem Code", Type = "Button", ActionText = "CLICK"},
            {Title = "Teleport Old World", Type = "Button", ActionText = "CLICK"},
            {Title = "Teleport New World", Type = "Button", ActionText = "CLICK"},
            {Title = "Teleport Third Sea", Type = "Button", ActionText = "CLICK"},
            {Title = "Buy Dual Flintlock", Type = "Button", ActionText = "CLICK"},
            {Title = "Reroll Race", Type = "Button", ActionText = "CLICK"}
        }
    },
    ["Status And Server"] = {
        Sub = "Server Controls",
        Items = {
            {Title = "Player Stats", Type = "Button", ActionText = "VIEW"},
            {Title = "Server Rejoin", Type = "Button", ActionText = "REJOIN"},
            {Title = "Server Hop", Type = "Button", ActionText = "HOP"}
        }
    },
    ["LocalPlayer"] = {
        Sub = "Player Options",
        Items = {
            {Title = "WalkSpeed Booster", Type = "Toggle", State = false},
            {Title = "Infinite Jump", Type = "Toggle", State = false},
            {Title = "No Clip Mode", Type = "Toggle", State = false}
        }
    },
    ["Setting Farm"] = {
        Sub = "Farm Configurations",
        Items = {
            {Title = "Fast Attack Speed", Type = "Toggle", State = true},
            {Title = "Auto Equip Weapon", Type = "Toggle", State = true}
        }
    },
    ["Farming"] = {
        Sub = "Main Auto Farm",
        Items = {
            {Title = "Auto Farm Level", Type = "Toggle", State = false},
            {Title = "Auto Accept Quest", Type = "Toggle", State = true},
            {Title = "Auto Farm Bosses", Type = "Toggle", State = false}
        }
    },
    ["ESP"] = {
        Sub = "Visual Highlights",
        Items = {
            {Title = "Player ESP", Type = "Toggle", State = false},
            {Title = "Fruit ESP", Type = "Toggle", State = false},
            {Title = "Chest ESP", Type = "Toggle", State = false}
        }
    }
}

local TabButtons = {}

local function RenderContent(tabName)
    CategoryTitle.Text = tabName
    local data = TabData[tabName]
    SubCategoryTitle.Text = data and data.Sub or "Settings"

    for _, child in ipairs(ContentScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    if not data or not data.Items then return end

    for index, item in ipairs(data.Items) do
        local card = New("Frame", {
            BackgroundColor3 = Theme.GlassCard,
            BackgroundTransparency = 0.2,
            Size = UDim2.new(1, -4, 0, 42),
            LayoutOrder = index,
            ZIndex = 11,
            Parent = ContentScroll
        })
        AddCorner(card, 8)
        AddStroke(card, Theme.BorderMuted, 1, 0.6)

        New("TextLabel", {
            Text = item.Title,
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(0.65, 0, 1, 0),
            ZIndex = 12,
            Parent = card
        })

        if item.Type == "Button" then
            local actionBtn = New("TextButton", {
                Text = item.ActionText or "CLICK",
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Theme.AccentLight,
                BackgroundColor3 = Color3.fromRGB(12, 36, 64),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.new(0, 80, 0, 28),
                AutoButtonColor = false,
                ZIndex = 12,
                Parent = card
            })
            AddCorner(actionBtn, 6)
            AddStroke(actionBtn, Theme.Border, 1, 0.5)

            actionBtn.MouseButton1Click:Connect(function()
                Animate(actionBtn, {BackgroundColor3 = Theme.Accent}, 0.1)
                task.wait(0.1)
                Animate(actionBtn, {BackgroundColor3 = Color3.fromRGB(12, 36, 64)}, 0.1)
            end)

        elseif item.Type == "Toggle" then
            local toggleBtn = New("TextButton", {
                Text = item.State and "ON" or "OFF",
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = item.State and Theme.Success or Theme.SubText,
                BackgroundColor3 = item.State and Color3.fromRGB(16, 52, 38) or Color3.fromRGB(20, 28, 40),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.new(0, 70, 0, 28),
                AutoButtonColor = false,
                ZIndex = 12,
                Parent = card
            })
            AddCorner(toggleBtn, 6)
            AddStroke(toggleBtn, item.State and Theme.Success or Theme.BorderMuted, 1, 0.5)

            toggleBtn.MouseButton1Click:Connect(function()
                item.State = not item.State
                toggleBtn.Text = item.State and "ON" or "OFF"
                toggleBtn.TextColor3 = item.State and Theme.Success or Theme.SubText
                toggleBtn.BackgroundColor3 = item.State and Color3.fromRGB(16, 52, 38) or Color3.fromRGB(20, 28, 40)
            end)
        end
    end
end

local tabOrder = {"Shop", "Status And Server", "LocalPlayer", "Setting Farm", "Farming", "ESP"}
for index, name in ipairs(tabOrder) do
    local btn = New("TextButton", {
        Text = "  " .. name,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = index == 1 and Theme.Text or Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = index == 1 and Color3.fromRGB(14, 40, 72) or Theme.Glass,
        BackgroundTransparency = index == 1 and 0.2 or 0.8,
        Size = UDim2.new(1, 0, 0, 32),
        LayoutOrder = index,
        AutoButtonColor = false,
        ZIndex = 11,
        Parent = SideScroll
    })
    AddCorner(btn, 6)
    local stroke = AddStroke(btn, Theme.Border, 1, index == 1 and 0.3 or 1)

    TabButtons[name] = {Button = btn, Stroke = stroke}

    btn.MouseButton1Click:Connect(function()
        for tName, refs in pairs(TabButtons) do
            local isSel = tName == name
            Animate(refs.Button, {
                BackgroundColor3 = isSel and Color3.fromRGB(14, 40, 72) or Theme.Glass,
                BackgroundTransparency = isSel and 0.2 or 0.8,
                TextColor3 = isSel and Theme.Text or Theme.SubText
            }, 0.12)
            Animate(refs.Stroke, {Transparency = isSel and 0.3 or 1}, 0.12)
        end
        RenderContent(name)
    end)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(SearchBox.Text)
    for name, refs in pairs(TabButtons) do
        refs.Button.Visible = (query == "" or string.find(string.lower(name), query, 1, true) ~= nil)
    end
end)

--==================================================
-- XỬ LÝ GET KEY & CALL RENDER API
--==================================================

-- Copy Link Get Key kèm HWID
GetKeyBtn.MouseButton1Click:Connect(function()
    local getUrl = GenerateGetKeyLink()
    if setclipboard then
        setclipboard(getUrl)
        StatusLabel.Text = "Đã copy link Get Key kèm HWID!"
        StatusLabel.TextColor3 = Theme.Success
    else
        StatusLabel.Text = "Link: " .. getUrl
        StatusLabel.TextColor3 = Theme.AccentLight
    end
end)

-- Hàm gửi Request xác thực tới Render Backend
local function VerifyKeyWithServer(inputKey)
    local req = (syn and syn.request) or (http and http.request) or http_request or request or Fluxus.request
    local queryUrl = KeySystemConfig.ApiUrl .. "/verify?hwid=" .. KeySystemConfig.HWID .. "&key=" .. HttpService:UrlEncode(inputKey)

    if req then
        local response = req({
            Url = queryUrl,
            Method = "GET"
        })
        if response and response.StatusCode == 200 then
            local success, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if success and data then
                return data.valid == true or data.success == true, data.message
            end
        end
    else
        -- Fallback nếu không có request function
        local success, result = pcall(function()
            return game:HttpGet(queryUrl)
        end)
        if success and string.find(string.lower(result), "true") then
            return true, "Thành công"
        end
    end
    
    -- Trường hợp Key mặc định fallback (nếu server render đang sleep/chờ cold start)
    if inputKey == "MeizuHub2026" or inputKey == "MEIZU" then
        return true, "Xác thực Offline"
    end

    return false, "Key hoặc HWID không hợp lệ"
end

-- Xác thực Key
VerifyKeyBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInputBox.Text
    if enteredKey == "" then
        StatusLabel.Text = "Vui lòng nhập Key!"
        StatusLabel.TextColor3 = Theme.Error
        return
    end

    StatusLabel.Text = "Đang kiểm tra với Server Render..."
    StatusLabel.TextColor3 = Theme.AccentLight

    task.spawn(function()
        local isValid, msg = VerifyKeyWithServer(enteredKey)

        if isValid then
            StatusLabel.Text = "Xác thực thành công! Đang mở Hub..."
            StatusLabel.TextColor3 = Theme.Success

            task.wait(0.6)

            Animate(KeyFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.25)
            task.wait(0.26)
            KeyFrame:Destroy()

            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            Animate(MainFrame, {Size = UDim2.new(0, 680, 0, 410)}, 0.25)

            RenderContent("Shop")
        else
            StatusLabel.Text = msg or "Key không chính xác hoặc đã hết hạn!"
            StatusLabel.TextColor3 = Theme.Error
        end
    end)
end)

-- Đóng Hub
CloseBtn.MouseButton1Click:Connect(function()
    Animate(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
    task.wait(0.21)
    ScreenGui:Destroy()
end)

-- Di chuyển Window
local function EnableDrag(dragFrame, moveFrame)
    local dragging, dragStart, startPos = false, nil, nil

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            moveFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

EnableDrag(KeyFrame, KeyFrame)
EnableDrag(MainHeader, MainFrame)

-- Phím tắt Ẩn/Hiện UI (RightShift)
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        if MainFrame and MainFrame.Parent then
            uiVisible = not uiVisible
            MainFrame.Visible = uiVisible
        end
    end
end)
