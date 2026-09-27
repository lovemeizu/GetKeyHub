--[[
    LOVE MEIZU KEY SYSTEM
    Roblox Loader
]]

--==================================================
-- CONFIG
--==================================================

local SERVER_URL = "https://getkeyhub-uwal.onrender.com"
local KEY_PAGE = "https://lovemeizu.github.io/GetKeyHub/getkey.html"

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

--==================================================
-- HTTP
--==================================================

local function httpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if ok then
        return true, result
    end

    return false, result
end

--==================================================
-- HWID
--==================================================

local function getHWID()

    local ok, result = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)

    if ok and result and result ~= "" then
        return tostring(result)
    end

    if Player then
        return tostring(Player.UserId)
    end

    return "UNKNOWN"
end

local HWID = getHWID()

--==================================================
-- VERIFY
--==================================================

local function verifyKey(key)

    key = tostring(key or ""):gsub("^%s+", ""):gsub("%s+$", "")

    if key == "" then
        return false, "Vui lòng nhập key."
    end

    local url =
        SERVER_URL ..
        "/api/verify?key=" ..
        HttpService:UrlEncode(key) ..
        "&hwid=" ..
        HttpService:UrlEncode(HWID)

    local ok, body = httpGet(url)

    if not ok then
        return false, "Không kết nối được máy chủ."
    end

    local decodedOK, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)

    if not decodedOK or type(data) ~= "table" then
        return false, "Máy chủ trả về dữ liệu không hợp lệ."
    end

    if data.valid == true then
        return true, data
    end

    local errorCode = tostring(data.error or "")

    local messages = {
        KEY_NOT_FOUND = "Key không tồn tại.",
        HWID_MISMATCH = "Key này không thuộc thiết bị hiện tại.",
        KEY_EXPIRED = "Key đã hết hạn.",
        MISSING_KEY_OR_HWID = "Thiếu key hoặc HWID."
    }

    return false, messages[errorCode] or "Key không hợp lệ."
end

--==================================================
-- GET KEY URL
--==================================================

local function getKeyURL()

    return KEY_PAGE ..
        "?hwid=" ..
        HttpService:UrlEncode(HWID)
end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "LoveMeizuKeySystem"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

if not gui.Parent then
    gui.Parent = Player:WaitForChild("PlayerGui")
end

--==================================================
-- BACKGROUND
--==================================================

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 390, 0, 285)
main.Position = UDim2.new(0.5, -195, 0.5, -142)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 78)
stroke.Transparency = 0.25
stroke.Thickness = 1
stroke.Parent = main

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 38)
title.Position = UDim2.new(0, 20, 0, 18)
title.BackgroundTransparency = 1
title.Text = "✦ LOVE MEIZU"
title.TextColor3 = Color3.fromRGB(245, 245, 250)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

--==================================================
-- SUBTITLE
--==================================================

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 25)
subtitle.Position = UDim2.new(0, 20, 0, 55)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Key System • 48 Hours"
subtitle.TextColor3 = Color3.fromRGB(155, 155, 165)
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

--==================================================
-- KEY BOX
--==================================================

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -40, 0, 48)
keyBox.Position = UDim2.new(0, 20, 0, 92)
keyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
keyBox.BorderSizePixel = 0
keyBox.ClearTextOnFocus = false
keyBox.PlaceholderText = "Nhập MEIZU-XXXX-XXXX-XXXX"
keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
keyBox.Text = ""
keyBox.TextColor3 = Color3.fromRGB(240, 240, 245)
keyBox.TextSize = 14
keyBox.Font = Enum.Font.Gotham
keyBox.Parent = main

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 12)
keyCorner.Parent = keyBox

local keyStroke = Instance.new("UIStroke")
keyStroke.Color = Color3.fromRGB(65, 65, 75)
keyStroke.Transparency = 0.35
keyStroke.Parent = keyBox

--==================================================
-- VERIFY BUTTON
--==================================================

local verifyButton = Instance.new("TextButton")
verifyButton.Size = UDim2.new(0.5, -25, 0, 45)
verifyButton.Position = UDim2.new(0, 20, 0, 150)
verifyButton.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
verifyButton.BorderSizePixel = 0
verifyButton.Text = "✓  VERIFY"
verifyButton.TextColor3 = Color3.fromRGB(15, 15, 18)
verifyButton.TextSize = 14
verifyButton.Font = Enum.Font.GothamBold
verifyButton.Parent = main

local verifyCorner = Instance.new("UICorner")
verifyCorner.CornerRadius = UDim.new(0, 12)
verifyCorner.Parent = verifyButton

--==================================================
-- GET KEY BUTTON
--==================================================

local getButton = Instance.new("TextButton")
getButton.Size = UDim2.new(0.5, -25, 0, 45)
getButton.Position = UDim2.new(0.5, 5, 0, 150)
getButton.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
getButton.BorderSizePixel = 0
getButton.Text = "🔑  GET KEY"
getButton.TextColor3 = Color3.fromRGB(235, 235, 240)
getButton.TextSize = 14
getButton.Font = Enum.Font.GothamBold
getButton.Parent = main

local getCorner = Instance.new("UICorner")
getCorner.CornerRadius = UDim.new(0, 12)
getCorner.Parent = getButton

local getStroke = Instance.new("UIStroke")
getStroke.Color = Color3.fromRGB(75, 75, 85)
getStroke.Transparency = 0.25
getStroke.Parent = getButton

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 30)
status.Position = UDim2.new(0, 20, 0, 205)
status.BackgroundTransparency = 1
status.Text = "●  Waiting for key..."
status.TextColor3 = Color3.fromRGB(160, 160, 170)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

--==================================================
-- HWID
--==================================================

local hwidLabel = Instance.new("TextLabel")
hwidLabel.Size = UDim2.new(1, -40, 0, 25)
hwidLabel.Position = UDim2.new(0, 20, 0, 238)
hwidLabel.BackgroundTransparency = 1
hwidLabel.Text = "HWID: " .. string.sub(HWID, 1, 18) .. "..."
hwidLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
hwidLabel.TextSize = 11
hwidLabel.Font = Enum.Font.Gotham
hwidLabel.TextXAlignment = Enum.TextXAlignment.Left
hwidLabel.Parent = main

--==================================================
-- DRAG
--==================================================

local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragStart
local startPosition

main.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

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

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

    end

end)

--==================================================
-- OPEN GET KEY
--==================================================

getButton.MouseButton1Click:Connect(function()

    local url = getKeyURL()

    status.Text = "●  Opening Get Key..."
    status.TextColor3 = Color3.fromRGB(220, 220, 225)

    local opened = false

    if syn and syn.request then
        opened = pcall(function()
            syn.request({
                Url = url,
                Method = "GET"
            })
        end)
    end

    if not opened and request then
        opened = pcall(function()
            request({
                Url = url,
                Method = "GET"
            })
        end)
    end

    -- Most executors expose setclipboard.
    pcall(function()
        if setclipboard then
            setclipboard(url)
        end
    end)

    status.Text = "●  Get Key link copied!"
    status.TextColor3 = Color3.fromRGB(190, 220, 255)

    print("LoveMeizu Get Key:")
    print(url)

end)

--==================================================
-- VERIFY
--==================================================

local verifying = false

verifyButton.MouseButton1Click:Connect(function()

    if verifying then
        return
    end

    local key = keyBox.Text

    if key == "" then

        status.Text = "●  Hãy nhập key trước."
        status.TextColor3 = Color3.fromRGB(255, 170, 170)

        return
    end

    verifying = true

    verifyButton.Text = "Checking..."
    status.Text = "●  Đang kiểm tra key..."
    status.TextColor3 = Color3.fromRGB(220, 220, 225)

    task.spawn(function()

        local valid, result = verifyKey(key)

        if valid then

            status.Text = "●  Key hợp lệ!"
            status.TextColor3 = Color3.fromRGB(170, 255, 190)

            verifyButton.Text = "✓  VERIFIED"

            task.wait(0.7)

            -- Hide key UI.
            main.Visible = false

            --==========================================
            -- PUT YOUR AUTHORIZED SCRIPT HERE
            --==========================================
            --
            -- Ví dụ:
            --
            -- local success, err = pcall(function()
            --     loadstring(game:HttpGet(
            --         "YOUR_SCRIPT_URL"
            --     ))()
            -- end)
            --
            --==========================================

            print("LoveMeizu: Key verified successfully.")
            print("HWID:", HWID)

        else

            status.Text = "●  " .. tostring(result)
            status.TextColor3 = Color3.fromRGB(255, 150, 150)

            verifyButton.Text = "✓  VERIFY"

        end

        verifying = false

    end)

end)

--==================================================
-- START
--==================================================

print("====================================")
print("        LOVE MEIZU KEY SYSTEM")
print("====================================")
print("HWID:", HWID)
print("Get Key:", getKeyURL())
print("====================================")
