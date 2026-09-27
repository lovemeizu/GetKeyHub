--============================================================
-- MEIZUHUB - BLUE HUB EDITION
-- Compact Key Gate + Main Hub UI
-- Footer: make by LoveMeizu
-- No full-screen background / no moving shine
--============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local CONFIG = {
    Name = "MeizuHub",
    SERVER_URL = "https://getkeyhub-uwal.onrender.com",
    VERIFY_URL = "https://getkeyhub-uwal.onrender.com/api/verify?key=%s&hwid=%s",
    GETKEY_URL = "https://lovemeizu.github.io/GetKeyHub/getkey.html",
    CACHE_FILE = "meizu_hub_key.txt",

    Blue = Color3.fromRGB(59,130,246),
    BlueDark = Color3.fromRGB(37,99,235),
    Cyan = Color3.fromRGB(34,211,238),
    Purple = Color3.fromRGB(124,92,255),
    Bg = Color3.fromRGB(8,10,18),
    Panel = Color3.fromRGB(15,19,31),
    Panel2 = Color3.fromRGB(20,25,40),
    Text = Color3.fromRGB(239,246,255),
    Muted = Color3.fromRGB(145,160,185),
    Green = Color3.fromRGB(74,222,128),
    Red = Color3.fromRGB(248,113,113),
}

local old = PlayerGui:FindFirstChild(CONFIG.Name)
if old then old:Destroy() end

local function Create(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function Stroke(parent, color, transparency, thickness)
    return Create("UIStroke", {
        Color = color,
        Transparency = transparency or .8,
        Thickness = thickness or 1,
    }, parent)
end

local function Gradient(parent, a, b, rotation)
    return Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, a),
            ColorSequenceKeypoint.new(1, b),
        }),
        Rotation = rotation or 0,
    }, parent)
end

local function PlayTween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local Gui = Create("ScreenGui", {
    Name = CONFIG.Name,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

--============================================================
-- HWID
--============================================================
local function GetHWID()
    local result = tostring(Player.UserId)
    pcall(function()
        if type(gethwid) == "function" then
            local v = gethwid()
            if v and tostring(v) ~= "" then
                result = tostring(v)
                return
            end
        end
        if type(hwid) == "string" and #hwid > 0 then
            result = hwid
            return
        end
        local analytics = game:GetService("RbxAnalyticsService")
        local v = analytics:GetClientId()
        if v and #tostring(v) > 10 then result = tostring(v) end
    end)
    return result
end

local function SaveKey(key)
    if type(writefile) == "function" then
        pcall(function() writefile(CONFIG.CACHE_FILE, key) end)
    end
end

local function LoadKey()
    if type(readfile) == "function" and type(isfile) == "function" then
        local ok, exists = pcall(isfile, CONFIG.CACHE_FILE)
        if ok and exists then
            local ok2, value = pcall(readfile, CONFIG.CACHE_FILE)
            if ok2 and value and #value > 0 then return value end
        end
    end
    return ""
end

local function VerifyKey(key)
    if not key or #key < 3 then return false, "Vui lòng nhập key." end
    local hwid = GetHWID()
    local url = string.format(CONFIG.VERIFY_URL, HttpService:UrlEncode(key), HttpService:UrlEncode(hwid))
    local ok, response = pcall(function() return game:HttpGet(url) end)
    if not ok then return false, "Không kết nối được máy chủ xác thực." end

    local okJson, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not okJson or type(data) ~= "table" then
        return false, "Phản hồi máy chủ không hợp lệ."
    end

    if data.success == false or data.valid == false then
        return false, tostring(data.error or data.message or "Key không hợp lệ.")
    end
    return true, tostring(data.message or "Key hợp lệ.")
end

--============================================================
-- COMPACT KEY POPUP
-- No background, no moving shine
--============================================================
local Gate = Create("Frame", {
    AnchorPoint = Vector2.new(.5,.5),
    Position = UDim2.fromScale(.5,.5),
    Size = UDim2.fromOffset(320,370),
    BackgroundColor3 = CONFIG.Panel,
    BackgroundTransparency = .08,
    BorderSizePixel = 0,
}, Gui)
Corner(Gate, 22)
Stroke(Gate, Color3.fromRGB(150,190,255), .72, 1)

local Content = Create("Frame", {
    Position = UDim2.fromOffset(22,21),
    Size = UDim2.new(1,-44,1,-42),
    BackgroundTransparency = 1,
}, Gate)

local Badge = Create("Frame", {
    Size = UDim2.fromOffset(116,27),
    BackgroundColor3 = CONFIG.Blue,
    BackgroundTransparency = .87,
    BorderSizePixel = 0,
}, Content)
Corner(Badge,14)
Stroke(Badge, CONFIG.Blue, .65, 1)
local BadgeDot = Create("Frame", {
    Position = UDim2.fromOffset(9,10),
    Size = UDim2.fromOffset(7,7),
    BackgroundColor3 = CONFIG.Cyan,
    BorderSizePixel = 0,
}, Badge)
Corner(BadgeDot,7)
Create("TextLabel", {
    Position = UDim2.fromOffset(23,0),
    Size = UDim2.new(1,-26,1,0),
    BackgroundTransparency = 1,
    Text = "ONE-TIME KEY",
    TextColor3 = CONFIG.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Badge)

Create("TextLabel", {
    Position = UDim2.fromOffset(0,43),
    Size = UDim2.new(1,0,0,38),
    BackgroundTransparency = 1,
    Text = "MeizuHub",
    TextColor3 = CONFIG.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 27,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Content)

Create("TextLabel", {
    Position = UDim2.fromOffset(0,82),
    Size = UDim2.new(1,0,0,35),
    BackgroundTransparency = 1,
    Text = "Nhập key để mở MeizuHub.",
    TextColor3 = CONFIG.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Content)

local Status = Create("TextLabel", {
    Position = UDim2.fromOffset(0,118),
    Size = UDim2.new(1,0,0,22),
    BackgroundTransparency = 1,
    Text = "●  Chưa xác thực",
    TextColor3 = CONFIG.Muted,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Content)

local KeyBox = Create("TextBox", {
    Position = UDim2.fromOffset(0,149),
    Size = UDim2.new(1,0,0,42),
    BackgroundColor3 = Color3.new(1,1,1),
    BackgroundTransparency = .94,
    BorderSizePixel = 0,
    PlaceholderText = "Nhập key...",
    PlaceholderColor3 = CONFIG.Muted,
    Text = "",
    TextColor3 = CONFIG.Text,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    ClearTextOnFocus = false,
}, Content)
Corner(KeyBox,12)
Stroke(KeyBox, Color3.fromRGB(130,170,255), .82, 1)
Create("UIPadding", {PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)}, KeyBox)

local GetKey = Create("TextButton", {
    Position = UDim2.fromOffset(0,201),
    Size = UDim2.new(1,0,0,42),
    BackgroundColor3 = CONFIG.Blue,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "Tạo / Lấy Key Free",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 11,
}, Content)
Corner(GetKey,12)
Gradient(GetKey, CONFIG.Blue, CONFIG.BlueDark, 0)

local Verify = Create("TextButton", {
    Position = UDim2.fromOffset(0,249),
    Size = UDim2.new(1,0,0,42),
    BackgroundColor3 = Color3.new(1,1,1),
    BackgroundTransparency = .94,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "Xác thực Key",
    TextColor3 = CONFIG.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
}, Content)
Corner(Verify,12)
Stroke(Verify, Color3.new(1,1,1), .86, 1)

local Result = Create("TextLabel", {
    Position = UDim2.fromOffset(0,300),
    Size = UDim2.new(1,0,0,27),
    BackgroundTransparency = 1,
    Text = "HWID sẽ được gửi kèm khi xác thực.",
    TextColor3 = CONFIG.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 8,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Center,
}, Content)

Create("TextLabel", {
    Position = UDim2.fromOffset(0,333),
    Size = UDim2.new(1,0,0,18),
    BackgroundTransparency = 1,
    Text = "make by LoveMeizu",
    TextColor3 = Color3.fromRGB(100,115,140),
    Font = Enum.Font.Gotham,
    TextSize = 8,
}, Content)

GetKey.MouseButton1Click:Connect(function()
    if setclipboard then pcall(setclipboard, CONFIG.GETKEY_URL) end
    Status.Text = "●  Link Get Key đã sẵn sàng"
    Status.TextColor3 = Color3.fromRGB(250,190,80)
    Result.Text = "Đã copy link Get Key."
end)

local function BuildMainHub()
    Gate:Destroy()

    local Main = Create("Frame", {
        AnchorPoint = Vector2.new(.5,.5),
        Position = UDim2.fromScale(.5,.56),
        Size = UDim2.fromOffset(680,445),
        BackgroundColor3 = CONFIG.Bg,
        BackgroundTransparency = .04,
        BorderSizePixel = 0,
    }, Gui)
    Corner(Main,18)
    Stroke(Main, Color3.fromRGB(100,150,255), .78, 1)

    local Header = Create("Frame", {
        Size = UDim2.new(1,0,0,54),
        BackgroundColor3 = CONFIG.Panel,
        BackgroundTransparency = .05,
        BorderSizePixel = 0,
    }, Main)
    Corner(Header,18)
    Create("TextLabel", {
        Position = UDim2.fromOffset(17,8),Size = UDim2.fromOffset(250,25),
        BackgroundTransparency=1,Text="MeizuHub",TextColor3=CONFIG.Text,
        Font=Enum.Font.GothamBold,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,
    }, Header)
    Create("TextLabel", {
        Position = UDim2.fromOffset(18,30),Size=UDim2.fromOffset(300,16),
        BackgroundTransparency=1,Text="Blue Edition",TextColor3=CONFIG.Muted,
        Font=Enum.Font.Gotham,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,
    }, Header)

    local Body = Create("Frame", {Position=UDim2.fromOffset(0,54),Size=UDim2.new(1,0,1,-54),BackgroundTransparency=1}, Main)
    local Sidebar = Create("Frame", {
        Size=UDim2.new(0,145,1,0),BackgroundColor3=CONFIG.Panel,BackgroundTransparency=.04,BorderSizePixel=0,
    }, Body)
    Corner(Sidebar,18)

    local Nav = Create("ScrollingFrame", {
        Position=UDim2.fromOffset(9,10),Size=UDim2.new(1,-18,1,-20),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,
        ScrollBarImageColor3=CONFIG.Blue,CanvasSize=UDim2.new(),
    }, Sidebar)
    local NavList = Create("UIListLayout", {Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder}, Nav)

    local ContentArea = Create("Frame", {
        Position=UDim2.fromOffset(157,0),Size=UDim2.new(1,-169,1,0),BackgroundTransparency=1,
    }, Body)
    local PageTitle = Create("TextLabel", {
        Position=UDim2.fromOffset(2,12),Size=UDim2.new(1,-4,0,28),BackgroundTransparency=1,
        Text="Thông Tin",TextColor3=CONFIG.Text,Font=Enum.Font.GothamBold,TextSize=19,TextXAlignment=Enum.TextXAlignment.Left,
    }, ContentArea)
    local Page = Create("ScrollingFrame", {
        Position=UDim2.fromOffset(0,56),Size=UDim2.new(1,0,1,-56),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=CONFIG.Blue,CanvasSize=UDim2.new(),
    }, ContentArea)
    local PageList = Create("UIListLayout", {Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder}, Page)

    local Tabs = {"Thông Tin","Cày","Sự Kiện","Vật Phẩm","Cài Đặt","Máy Chủ","Chỉ Số","Người Chơi","Dịch Chuyển","Giả","Trái","Tập Kích","Tộc","Cửa Hàng","Khác"}

    local function ClearPage()
        for _,v in ipairs(Page:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end
    end

    local function Card(title, desc)
        local f=Create("Frame",{Size=UDim2.new(1,-4,0,61),BackgroundColor3=CONFIG.Panel2,BackgroundTransparency=.12,BorderSizePixel=0},Page)
        Corner(f,11);Stroke(f,Color3.fromRGB(90,130,220),.86,1)
        Create("TextLabel",{Position=UDim2.fromOffset(11,8),Size=UDim2.new(1,-22,0,19),BackgroundTransparency=1,Text=title,TextColor3=CONFIG.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},f)
        Create("TextLabel",{Position=UDim2.fromOffset(11,29),Size=UDim2.new(1,-22,0,23),BackgroundTransparency=1,Text=desc,TextColor3=CONFIG.Muted,Font=Enum.Font.Gotham,TextSize=8,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},f)
    end

    local function Toggle(title, desc)
        local f=Create("TextButton",{Size=UDim2.new(1,-4,0,54),BackgroundColor3=CONFIG.Panel2,BackgroundTransparency=.12,BorderSizePixel=0,AutoButtonColor=false,Text=""},Page)
        Corner(f,11);Stroke(f,Color3.fromRGB(90,130,220),.88,1)
        Create("TextLabel",{Position=UDim2.fromOffset(11,6),Size=UDim2.new(1,-65,0,19),BackgroundTransparency=1,Text=title,TextColor3=CONFIG.Text,Font=Enum.Font.GothamMedium,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},f)
        Create("TextLabel",{Position=UDim2.fromOffset(11,27),Size=UDim2.new(1,-65,0,17),BackgroundTransparency=1,Text=desc,TextColor3=CONFIG.Muted,Font=Enum.Font.Gotham,TextSize=7,TextXAlignment=Enum.TextXAlignment.Left},f)
        local sw=Create("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.fromOffset(29,16),BackgroundColor3=Color3.fromRGB(45,52,70),BorderSizePixel=0},f);Corner(sw,9)
        local knob=Create("Frame",{Position=UDim2.fromOffset(2,2),Size=UDim2.fromOffset(12,12),BackgroundColor3=Color3.fromRGB(180,190,205),BorderSizePixel=0},sw);Corner(knob,6)
        local on=false
        f.MouseButton1Click:Connect(function()
            on=not on
            PlayTween(sw,TweenInfo.new(.15),{BackgroundColor3=on and CONFIG.Blue or Color3.fromRGB(45,52,70)})
            PlayTween(knob,TweenInfo.new(.15),{Position=on and UDim2.fromOffset(15,2) or UDim2.fromOffset(2,2)})
        end)
    end

    local function ShowTab(name)
        PageTitle.Text=name
        ClearPage()
        if name=="Thông Tin" then
            Card("MeizuHub","Blue / Blue-Purple interface.")
            Card("Key Status","Key + HWID verification đã hoàn tất.")
            Card("Version","MeizuHub Blue Hub Edition")
        elseif name=="Cày" then
            Toggle("Auto Farm","Bảng điều khiển farm.")
            Toggle("Auto Quest","Bảng quest.")
            Toggle("Auto Collect","Bảng thu thập.")
        elseif name=="Sự Kiện" then
            Toggle("Sea Events","Bảng sự kiện.")
            Toggle("Boss Events","Theo dõi boss.")
            Toggle("Special Events","Khu vực sự kiện.")
        elseif name=="Vật Phẩm" then
            Toggle("Item ESP","Hiển thị vật phẩm.")
            Toggle("Chest ESP","Hiển thị chest.")
            Toggle("Fruit ESP","Hiển thị fruit.")
        elseif name=="Cài Đặt" then
            Toggle("Save Config","Lưu cấu hình UI.")
            Toggle("Notifications","Bật thông báo.")
            Toggle("Compact UI","Thu nhỏ giao diện.")
        elseif name=="Máy Chủ" then
            Card("Server","Thông tin server hiện tại.")
            Toggle("Server Hop","Bảng chuyển server.")
        elseif name=="Chỉ Số" then
            Card("Stats","Thông tin chỉ số nhân vật.")
            Toggle("Stats ESP","Hiển thị chỉ số.")
        elseif name=="Người Chơi" then
            Toggle("Player ESP","Hiển thị người chơi.")
            Toggle("Anti AFK","Bảng Anti AFK.")
            Toggle("WalkSpeed","Điều chỉnh tốc độ.")
        elseif name=="Dịch Chuyển" then
            Card("Locations","Danh sách địa điểm.")
            Toggle("Teleport Panel","Mở bảng dịch chuyển.")
        elseif name=="Giả" then
            Toggle("Visual Effects","Tuỳ chọn hiển thị.")
            Toggle("ESP","Tuỳ chọn ESP.")
        elseif name=="Trái" then
            Toggle("Fruit Finder","Tìm fruit.")
            Toggle("Fruit ESP","Hiển thị fruit.")
        elseif name=="Tập Kích" then
            Toggle("Raid Panel","Bảng raid.")
            Toggle("Auto Start","Điều khiển bắt đầu raid.")
        elseif name=="Tộc" then
            Toggle("Race Panel","Bảng tộc.")
            Toggle("Race Info","Thông tin race.")
        elseif name=="Cửa Hàng" then
            Toggle("Shop Panel","Bảng cửa hàng.")
            Toggle("Item Tracker","Theo dõi vật phẩm.")
        else
            Toggle("Misc Panel","Các tuỳ chọn khác.")
            Toggle("Notifications","Thông báo MeizuHub.")
        end
        task.defer(function() Page.CanvasSize=UDim2.fromOffset(0,PageList.AbsoluteContentSize.Y+8) end)
    end

    for _,name in ipairs(Tabs) do
        local b=Create("TextButton",{Size=UDim2.new(1,0,0,30),BackgroundColor3=CONFIG.Panel2,BackgroundTransparency=.95,BorderSizePixel=0,AutoButtonColor=false,Text=name,TextColor3=CONFIG.Muted,Font=Enum.Font.GothamMedium,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left},Nav)
        Corner(b,8);Create("UIPadding",{PaddingLeft=UDim.new(0,9)},b)
        b.MouseButton1Click:Connect(function()
            for _,x in ipairs(Nav:GetChildren()) do if x:IsA("TextButton") then x.BackgroundTransparency=.95;x.TextColor3=CONFIG.Muted end end
            b.BackgroundTransparency=.82;b.BackgroundColor3=CONFIG.Blue;b.TextColor3=CONFIG.Text
            ShowTab(name)
        end)
    end
    NavList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Nav.CanvasSize=UDim2.fromOffset(0,NavList.AbsoluteContentSize.Y+8) end)
    local first=Nav:FindFirstChildWhichIsA("TextButton")
    if first then first.BackgroundTransparency=.82;first.BackgroundColor3=CONFIG.Blue;first.TextColor3=CONFIG.Text end
    ShowTab("Thông Tin")

    -- Drag PC + mobile
    local dragging=false;local dragStart;local startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true;dragStart=input.Position;startPos=Main.Position
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
        local d=input.Position-dragStart
        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end)

    Main.Position=UDim2.fromScale(.5,.59)
    Main.BackgroundTransparency=1
    PlayTween(Main,TweenInfo.new(.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.fromScale(.5,.54),BackgroundTransparency=.04})
end

Verify.MouseButton1Click:Connect(function()
    local key=KeyBox.Text
    if key=="" then key=LoadKey() end
    if key=="" then
        Status.Text="●  Chưa nhập key"
        Status.TextColor3=CONFIG.Red
        Result.Text="Nhập key trước khi xác thực."
        return
    end
    Status.Text="●  Đang xác thực..."
    Status.TextColor3=CONFIG.Blue
    Result.Text="Đang kiểm tra key + HWID..."
    task.spawn(function()
        local ok,msg=VerifyKey(key)
        if ok then
            SaveKey(key)
            Status.Text="●  Key hợp lệ"
            Status.TextColor3=CONFIG.Green
            Result.Text=msg
            task.wait(.3)
            BuildMainHub()
        else
            Status.Text="●  Xác thực thất bại"
            Status.TextColor3=CONFIG.Red
            Result.Text=msg
        end
    end)
end)

local cached=LoadKey()
if cached~="" then KeyBox.Text=cached end

-- Popup entrance only; no shine loop.
Gate.Position=UDim2.fromScale(.5,.56)
Gate.BackgroundTransparency=1
PlayTween(Gate,TweenInfo.new(.4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.fromScale(.5,.5),BackgroundTransparency=.08})

return {Name=CONFIG.Name,Theme="Blue Hub",GUI=Gui}
