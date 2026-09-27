-- MeizuHub_BlueHub_Complete.lua
-- BlueHub-style UI + Key/HWID gate
-- Gameplay automation/exploit modules intentionally not included.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local LocalPlayer = Players.LocalPlayer

local SERVER_URL = "https://getkeyhub-uwal.onrender.com"
local GETKEY_URL = "https://lovemeizu.github.io/GetKeyHub/getkey.html"
local KEY_FILE = "meizu_hub_key.txt"

local C = {
    bg = Color3.fromRGB(7, 10, 17),
    panel = Color3.fromRGB(15, 22, 36),
    panel2 = Color3.fromRGB(20, 29, 47),
    accent = Color3.fromRGB(58, 134, 255),
    accent2 = Color3.fromRGB(116, 92, 255),
    text = Color3.fromRGB(235, 244, 255),
    dim = Color3.fromRGB(150, 169, 198),
    good = Color3.fromRGB(90, 220, 150),
    bad = Color3.fromRGB(240, 90, 105),
    warn = Color3.fromRGB(245, 185, 75),
}

local function GetHWID()
    local ok, result
    if typeof(gethwid) == "function" then
        ok, result = pcall(gethwid)
        if ok and result and tostring(result) ~= "" then return tostring(result) end
    end
    if typeof(hwid) == "function" then
        ok, result = pcall(hwid)
        if ok and result and tostring(result) ~= "" then return tostring(result) end
    end
    local success, clientId = pcall(function()
        return RbxAnalyticsService:GetClientId()
    end)
    if success and clientId and tostring(clientId) ~= "" then return tostring(clientId) end
    return tostring(LocalPlayer.UserId)
end

local HWID = GetHWID()

local function req(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok then return true, body end
    if request then
        local rOk, r = pcall(function() return request({Url=url, Method="GET"}) end)
        if rOk and r then return true, r.Body end
    end
    if http_request then
        local rOk, r = pcall(function() return http_request({Url=url, Method="GET"}) end)
        if rOk and r then return true, r.Body end
    end
    return false, body
end

local function verifyKey(key)
    key = tostring(key or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if key == "" then return false, "Vui lòng nhập Key." end
    local url = SERVER_URL .. "/api/verify?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(HWID)
    local ok, body = req(url)
    if not ok then return false, "Không kết nối được máy chủ." end
    local decodedOk, data = pcall(function() return HttpService:JSONDecode(body) end)
    if decodedOk and type(data) == "table" then
        if data.success == true or data.valid == true or data.ok == true then
            return true, data.message or "Key hợp lệ."
        end
        return false, data.message or data.error or "Key không hợp lệ hoặc HWID không khớp."
    end
    return false, "Phản hồi máy chủ không hợp lệ."
end

local function saveKey(key)
    if writefile then pcall(function() writefile(KEY_FILE, key) end) end
end

local function loadKey()
    if isfile and readfile then
        local ok, value = pcall(function()
            if isfile(KEY_FILE) then return readfile(KEY_FILE) end
        end)
        if ok and value and value ~= "" then return value end
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "MeizuHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function corner(obj, radius)
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, radius)
    x.Parent = obj
end
local function stroke(obj, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0
    s.Thickness = 1
    s.Parent = obj
end
local function label(parent, text, size, pos, fontSize, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.Size = size
    l.Position = pos
    l.Font = Enum.Font.Gotham
    l.TextSize = fontSize or 14
    l.TextColor3 = color or C.text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end
local function button(parent, text, size, pos)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = text
    b.Size = size
    b.Position = pos
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.TextColor3 = C.text
    b.BackgroundColor3 = C.panel2
    b.Parent = parent
    corner(b, 10)
    stroke(b, Color3.fromRGB(80, 110, 155), .72)
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(.15), {BackgroundColor3=C.accent}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(.15), {BackgroundColor3=C.panel2}):Play() end)
    return b
end

-- Key Gate
local gate = Instance.new("Frame")
gate.AnchorPoint = Vector2.new(.5,.5)
gate.Position = UDim2.fromScale(.5,.5)
gate.Size = UDim2.fromOffset(330, 375)
gate.BackgroundColor3 = C.bg
gate.BackgroundTransparency = .08
gate.Parent = gui
corner(gate, 18)
stroke(gate, Color3.fromRGB(85,125,190), .58)

local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,5)
top.BackgroundColor3 = C.accent
top.BorderSizePixel = 0
top.Parent = gate
corner(top, 5)

local badge = label(gate, "●  ONE-TIME KEY", UDim2.fromOffset(280,22), UDim2.fromOffset(25,24), 11, C.accent)
badge.Font = Enum.Font.GothamBold
label(gate, "MeizuHub", UDim2.new(1,-50,0,42), UDim2.fromOffset(25,55), 28, C.text).Font = Enum.Font.GothamBold
label(gate, "Nhập key để mở MeizuHub.", UDim2.new(1,-50,0,25), UDim2.fromOffset(25,95), 13, C.dim)
label(gate, "HWID", UDim2.fromOffset(60,20), UDim2.fromOffset(25,132), 11, C.dim)
local hw = label(gate, string.sub(HWID,1,24) .. (#HWID>24 and "…" or ""), UDim2.new(1,-50,0,20), UDim2.fromOffset(75,132), 11, C.text)
hw.TextXAlignment = Enum.TextXAlignment.Right

local box = Instance.new("TextBox")
box.PlaceholderText = "Nhập Key của bạn..."
box.Text = ""
box.ClearTextOnFocus = false
box.Size = UDim2.new(1,-50,0,45)
box.Position = UDim2.fromOffset(25,165)
box.Font = Enum.Font.Gotham
box.TextSize = 13
box.TextColor3 = C.text
box.PlaceholderColor3 = C.dim
box.BackgroundColor3 = C.panel2
box.Parent = gate
corner(box, 11)
stroke(box, Color3.fromRGB(80,110,155), .65)

local status = label(gate, "Chưa xác thực", UDim2.new(1,-50,0,22), UDim2.fromOffset(25,218), 12, C.warn)

local getBtn = button(gate, "Tạo / Lấy Key Free", UDim2.new(1,-50,0,42), UDim2.fromOffset(25,250))
getBtn.BackgroundColor3 = C.accent
local verifyBtn = button(gate, "Xác thực Key", UDim2.new(1,-50,0,42), UDim2.fromOffset(25,298))
label(gate, "make by LoveMeizu", UDim2.new(1,-50,0,18), UDim2.fromOffset(25,349), 10, C.dim).TextXAlignment = Enum.TextXAlignment.Center

getBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(setclipboard, GETKEY_URL) end
    status.Text = "Đã sao chép link lấy Key."
    status.TextColor3 = C.good
    pcall(function() game:GetService("GuiService"):OpenBrowserWindow(GETKEY_URL) end)
end)

local function finish()
    gate:Destroy()
end

verifyBtn.MouseButton1Click:Connect(function()
    verifyBtn.Active = false
    status.Text = "Đang xác thực..."
    status.TextColor3 = C.warn
    local ok, msg = verifyKey(box.Text)
    if ok then
        saveKey(box.Text)
        status.Text = tostring(msg)
        status.TextColor3 = C.good
        task.wait(.35)
        finish()
        buildMain()
    else
        status.Text = tostring(msg)
        status.TextColor3 = C.bad
        verifyBtn.Active = true
    end
end)

local cached = loadKey()
if cached then
    box.Text = cached
    task.spawn(function()
        task.wait(.2)
        local ok, msg = verifyKey(cached)
        if ok then
            status.Text = tostring(msg)
            status.TextColor3 = C.good
            task.wait(.25)
            finish()
            buildMain()
        end
    end)
end

function buildMain()
    local main = Instance.new("Frame")
    main.AnchorPoint = Vector2.new(.5,.5)
    main.Position = UDim2.fromScale(.5,.5)
    main.Size = UDim2.fromOffset(700,450)
    main.BackgroundColor3 = C.bg
    main.Parent = gui
    corner(main, 17)
    stroke(main, Color3.fromRGB(80,120,180), .58)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1,0,0,52)
    header.BackgroundColor3 = C.panel
    header.Parent = main
    corner(header,17)
    label(header,"MeizuHub",UDim2.fromOffset(230,30),UDim2.fromOffset(18,11),20,C.text).Font=Enum.Font.GothamBold
    label(header,"BlueHub",UDim2.fromOffset(100,20),UDim2.fromOffset(120,17),11,C.accent)

    local close = button(header,"×",UDim2.fromOffset(35,32),UDim2.new(1,-45,0,10))
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    local side = Instance.new("ScrollingFrame")
    side.Size = UDim2.new(0,155,1,-62)
    side.Position = UDim2.fromOffset(8,57)
    side.BackgroundColor3 = C.panel
    side.ScrollBarThickness = 2
    side.CanvasSize = UDim2.new()
    side.Parent = main
    corner(side,13)
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0,5)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Parent = side
    local pad = Instance.new("UIPadding")
    pad.PaddingTop=UDim.new(0,9); pad.PaddingBottom=UDim.new(0,9)
    pad.Parent=side

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-174,1,-62)
    content.Position = UDim2.fromOffset(166,57)
    content.BackgroundColor3 = C.panel
    content.Parent = main
    corner(content,13)

    local tabs = {"Thông Tin","Cày","Sự Kiện","Vật Phẩm","Cài Đặt","Máy Chủ","Chỉ Số","Người Chơi","Dịch Chuyển","Giả","Trái","Tập Kích","Tộc","Cửa Hàng","Khác"}
    local current
    local function showTab(name)
        for _,v in ipairs(content:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end
        label(content,name,UDim2.new(1,-30,0,35),UDim2.fromOffset(15,15),20,C.text).Font=Enum.Font.GothamBold
        label(content,"MeizuHub module • "..name,UDim2.new(1,-30,0,25),UDim2.fromOffset(15,50),11,C.dim)
        local info = Instance.new("Frame")
        info.Size=UDim2.new(1,-30,0,95); info.Position=UDim2.fromOffset(15,85); info.BackgroundColor3=C.panel2; info.Parent=content; corner(info,11)
        label(info,"Module sẵn sàng",UDim2.new(1,-20,0,24),UDim2.fromOffset(10,10),13,C.good)
        label(info,"Đây là khung giao diện/module. Chức năng gameplay phải được triển khai trong game do bạn sở hữu.",UDim2.new(1,-20,0,48),UDim2.fromOffset(10,38),11,C.dim).TextWrapped=true
    end
    for _,name in ipairs(tabs) do
        local b=button(side,name,UDim2.new(1,-14,0,34),UDim2.new())
        b.MouseButton1Click:Connect(function() showTab(name) end)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() side.CanvasSize=UDim2.fromOffset(0,list.AbsoluteContentSize.Y+18) end)
    showTab("Thông Tin")

    -- Drag window
    local dragging=false; local dragStart; local startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPos=main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local d=input.Position-dragStart
            main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end
