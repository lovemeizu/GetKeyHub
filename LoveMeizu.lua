--[[
    LoveMeizu Key System
    Client-only key gate. Set SERVER_URL to your Render service.
    This file intentionally contains only key verification/UI plumbing;
    put your own game/script functionality after the verified callback.
]]

local SERVER_URL = "https://getkeyhub-uwal.onrender.com/"
local KEY_PAGE = "https://lovemeizu.github.io/GetKeyHub/getkey.html"

local function httpGet(url)
    if game and game.HttpGet then
        return game:HttpGet(url)
    end
    error("HttpGet is not available in this environment")
end

local function jsonDecode(s)
    local HttpService = game:GetService("HttpService")
    return HttpService:JSONDecode(s)
end

local function getHWID()
    -- Replace this with your environment's stable installation identifier
    -- if it exposes one. Do not use a Roblox username as a security secret.
    local ok, id = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if ok and id then return id end
    return tostring(game:GetService("Players").LocalPlayer.UserId)
end

local HWID = getHWID()

local function verify(key)
    local url = SERVER_URL .. "/api/verify?key=" ..
        game:GetService("HttpService"):UrlEncode(key) ..
        "&hwid=" .. game:GetService("HttpService"):UrlEncode(HWID)

    local ok, body = pcall(httpGet, url)
    if not ok then return false, "Không kết nối được máy chủ." end

    local ok2, data = pcall(jsonDecode, body)
    if not ok2 then return false, "Phản hồi máy chủ không hợp lệ." end

    if data.valid then
        return true, data
    end

    return false, data.error or "Key không hợp lệ."
end

local function getKeyPage()
    return KEY_PAGE .. "?hwid=" ..
        game:GetService("HttpService"):UrlEncode(HWID)
end

-- Minimal console flow. Replace this section with your preferred UI.
print("╔══════════════════════════════╗")
print("║        LOVE MEIZU HUB        ║")
print("╚══════════════════════════════╝")
print("Get Key: " .. getKeyPage())
print("HWID: " .. HWID)

-- Example:
-- local valid, result = verify("MEIZU-XXXX-XXXX-XXXX")
-- if not valid then return end
-- Your own authorized functionality starts here.
