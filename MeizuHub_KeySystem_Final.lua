-- MeizuHub Key System patch
-- Replace the existing KeySys block and BtnGetKey.MouseButton1Click block.
-- HWID is kept out of the visible UI and is passed silently in the Get Key URL.

local KeySys = {}
do
    function KeySys.HWID()
        local id = tostring(LP.UserId)
        pcall(function()
            if type(gethwid) == "function" then
                local ok, r = pcall(gethwid)
                if ok and r ~= nil and #tostring(r) > 0 then
                    id = tostring(r)
                    return
                end
            end
            if type(hwid) == "string" and #hwid > 0 then
                id = hwid
                return
            end
            local service = game:GetService("RbxAnalyticsService")
            local cid = service:GetClientId()
            if cid and #tostring(cid) > 10 then
                id = tostring(cid)
            end
        end)
        return tostring(id)
    end

    function KeySys.Cached()
        if type(readfile) == "function" and type(isfile) == "function" and isfile(CONFIG.KeyCacheFile) then
            local ok, cached = pcall(readfile, CONFIG.KeyCacheFile)
            if ok and cached and #tostring(cached) > 10 then
                return tostring(cached)
            end
        end
        return nil
    end

    function KeySys.SaveCache(key)
        if type(writefile) == "function" then
            pcall(writefile, CONFIG.KeyCacheFile, tostring(key))
        end
    end

    function KeySys.Verify(key, cb)
        key = tostring(key or ""):gsub("%s+", "")
        if #key < 8 then
            cb(false, "Key không hợp lệ")
            return
        end

        local currentHWID = KeySys.HWID()
        local url = CONFIG.KeyVerifyUrl:format(
            HttpService:UrlEncode(key),
            HttpService:UrlEncode(currentHWID)
        )

        P("KeyVerify", function()
            local ok, response = pcall(function()
                return game:HttpGet(url)
            end)
            if not ok then
                cb(false, "Không thể kết nối máy chủ")
                return
            end

            local decoded, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            if not decoded or type(data) ~= "table" then
                cb(false, "Phản hồi máy chủ không hợp lệ")
                return
            end

            if data.success ~= false and data.valid ~= false then
                KeySys.SaveCache(key)
                cb(true, data.message or "Key hợp lệ")
            else
                cb(false, data.error or "Key không hợp lệ")
            end
        end)
    end
end

-- Replace the existing BtnGetKey.MouseButton1Click handler with this:
BtnGetKey.MouseButton1Click:Connect(function()
    local currentHWID = KeySys.HWID()
    if not currentHWID or #tostring(currentHWID) == 0 then
        SetStatus("❌ Không lấy được HWID", CONFIG.UI.Red)
        return
    end

    local url = CONFIG.KeyGetUrl .. "?hwid=" .. HttpService:UrlEncode(tostring(currentHWID))

    if type(setclipboard) == "function" then
        local ok = pcall(setclipboard, url)
        if ok then
            SetStatus("✅ Link lấy key đã copy!", CONFIG.UI.Green)
        else
            SetStatus("🔗 Link lấy key đã sẵn sàng", CONFIG.UI.Muted)
        end
    else
        SetStatus("🔗 Link lấy key đã sẵn sàng", CONFIG.UI.Muted)
    end
end)
