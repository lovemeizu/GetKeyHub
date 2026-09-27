--[[==========================================================================
  MEIZU HUB :: Blox Fruits — Blue Liquid Glass Compact
  File hợp nhất duy nhất | Vanilla Luau, không thư viện ngoài
  ---------------------------------------------------------------------------
  NGUỒN DỮ LIỆU (công khai, kiểm tra 27/09/2026):
    - Blox Fruits Wiki (Fandom), bloxfruits.gg, bloxodes, rblxguide, u7buy
    - Đảo / Boss / Trái: tên & cấp độ lấy từ wiki; tọa độ trong game KHÔNG
      có trong nguồn công khai => module Teleport quét Workspace tìm model
      đảo theo tên thay vì hardcode tọa độ (không bịa số).
  GIỚI HẠN THỰC TẾ (đánh dấu TODO-RUNTIME):
    - Remote nhận quest / kích hoạt skill riêng của Blox Fruits KHÔNG công khai
      và đổi theo update => không bịa tên. AutoFarm hoạt động ở dạng "tự di
      chuyển + tự đánh quái theo tên" (không cần remote). Nhận quest tự động
      cần bạn map Remote thật lúc runtime (đã để hook Adapter).
  ==========================================================================]]

--========================= CONFIG ==========================================
local CONFIG = {
  HubName      = "MEIZU HUB",
  Version      = "2.0.0-blueglass",
  KeyVerifyUrl = "https://getkeyhub-uwal.onrender.com/api/verify?key=%s&hwid=%s",
  KeyGetUrl    = "https://lovemeizu.github.io/GetKeyHub/getkey.html",
  KeyCacheFile = "meizu_hub_key.txt",
  ConfigFile   = "meizu_hub_config.json",
  DefaultTab   = "Player",
  UI = {
    Width  = 300, Height = 440, Corner = 14,
    Accent = Color3.fromRGB(80,160,255),
    Bg     = Color3.fromRGB(10,16,32),
    Text   = Color3.fromRGB(225,235,255),
    Dim    = Color3.fromRGB(140,160,195),
  },
  Farm = {
    ScanInterval   = 0.5,   -- giây giữa các lần quét quái
    AttackRange    = 12,    -- khoảng cách đánh (stud)
    StuckThreshold = 4,     -- giây đứng yên coi là kẹt
    LootRadius     = 40,
  },
}

--========================= SERVICES ========================================
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService= game:GetService("TweenService")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local TeleportSvc = game:GetService("TeleportService")
local LP          = Players.LocalPlayer
local Mouse       = LP:GetMouse()

if getgenv and getgenv().MEIZU_CLEANUP then pcall(getgenv().MEIZU_CLEANUP) end

local function P(label, fn, ...)
  local ok, r = pcall(fn, ...)
  if not ok then warn(("[MEIZU][%s] %s"):format(label, tostring(r))) end
  return ok, r
end

--========================= DATA (nguồn wiki công khai) =====================
-- Cấp độ là khoảng tham khảo từ wiki; có thể chênh lệch theo update.
local IslandData = { -- {Name, MinLevel, Sea}
  Sea1 = {
    {Name="Starter Island",  Lv=1},   {Name="Jungle",          Lv=15},
    {Name="Pirate Village",  Lv=30},  {Name="Desert",          Lv=35},
    {Name="Frozen Village",  Lv=50},  {Name="Marine Fortress", Lv=120},
    {Name="Skylands",        Lv=150}, {Name="Prison",          Lv=190},
    {Name="Colosseum",       Lv=225}, {Name="Magma Village",   Lv=300},
    {Name="Underwater City", Lv=375}, {Name="Fountain City",   Lv=450},
  },
  Sea2 = { -- 700-1500
    {Name="Kingdom of Rose", Lv=700}, {Name="Usoap's Island",  Lv=700},
    {Name="Green Zone",      Lv=875}, {Name="Graveyard",       Lv=925},
    {Name="Snow Mountain",   Lv=1000},{Name="Hot and Cold",    Lv=1100},
    {Name="Cursed Ship",     Lv=1250},{Name="Ice Castle",      Lv=1350},
    {Name="Forgotten Island",Lv=1425},
  },
  Sea3 = { -- 1500+
    {Name="Port Town",       Lv=1500},{Name="Hydra Island",    Lv=1575},
    {Name="Great Tree",      Lv=1625},{Name="Floating Turtle", Lv=1700},
    {Name="Cake Land",       Lv=1750},{Name="Ice Cream Land",  Lv=1875},
    {Name="Dough King's Quest",Lv=2000},{Name="Castle on the Sea",Lv=2175},
    {Name="Sea of Treats",   Lv=2400},
  },
}

local FruitData = { -- {Name, Rarity, Type} — nguồn: wiki (41-57 trái theo update)
  Common   = {"Rocket","Spin","Chop","Spring","Bomb","Smoke","Spike"},
  Uncommon = {"Flame","Ice","Sand","Dark","Light","Rubber","Barrier","Diamond"},
  Rare     = {"Quake","String","Spider","Love","Ghost","Buddha"},
  Legendary= {"Sound","Phoenix","Portal","Lightning","Pain","Blizzard","Gravity","Magma","Venom","Dough","Dragon","Mammoth","T-Rex"},
  Mythical = {"Leopard","Kitsune","Control","Spirit","Shadow","Gas","Rocket","Mochi","Creation"},
}

local BossData = { -- {Name, Level, Island} — nguồn: bloxfruits.gg / wiki
  {Name="Gorilla King", Lv=20,   Island="Jungle"},
  {Name="Bobby",        Lv=55,   Island="Pirate Village"},
  {Name="The Saw",      Lv=100,  Island="Desert"},
  {Name="Yeti",         Lv=110,  Island="Frozen Village"},
  {Name="Vice Admiral", Lv=130,  Island="Marine Fortress"},
  {Name="Warden",       Lv=220,  Island="Prison"},
  {Name="Chief Warden", Lv=230,  Island="Prison"},
  {Name="Swan",         Lv=240,  Island="Prison"},
  {Name="Thunder God",  Lv=575,  Island="Skylands"},
  {Name="Cyborg",       Lv=675,  Island="Fountain City"},
  {Name="Don Swan",     Lv=1000, Island="Kingdom of Rose"},
  {Name="Darkbeard",    Lv=1000, Island="Dark Arena"},
  {Name="Awakened Ice Admiral", Lv=1400, Island="Ice Castle"},
  {Name="rip_indra",    Lv=1500, Island="Second Sea"},
}

-- Tên quái thường gặp (dùng để quét Workspace). Thêm/bớt tùy đảo.
local EnemyNames = {
  "Bandit","Monkey","Pirate","Desert Bandit","Marine","Sky Pirate",
  "Prisoner","Colosseum Fighter","Magma Villager","Underwater Fighter",
  "Rose Militia","Green Zone Soldier","Snow Warrior","Hot and Cold Fighter",
  "Cursed Pirate","Ice Castle Guard","Port Town Bandit",
}

--========================= CORE > NOTIFICATION =============================
local Notify = {}
do
  local holder
  local function ensure()
    if holder and holder.Parent then return holder end
    local pg = LP:WaitForChild("PlayerGui")
    holder = Instance.new("ScreenGui"); holder.Name="MeizuNotify"; holder.ResetOnSpawn=false
    holder.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,6)
    l.HorizontalAlignment=Enum.HorizontalAlignment.Right; l.VerticalAlignment=Enum.VerticalAlignment.Top; l.Parent=holder
    local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,10); p.PaddingRight=UDim.new(0,10); p.Parent=holder
    holder.Parent=pg; return holder
  end
  function Notify.Show(text, dur)
    dur=dur or 3; P("Notify",function()
      local h=ensure(); local f=Instance.new("Frame")
      f.Size=UDim2.fromOffset(240,36); f.BackgroundColor3=CONFIG.UI.Bg; f.BackgroundTransparency=.25; f.BorderSizePixel=0
      local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,10); c.Parent=f
      local s=Instance.new("UIStroke"); s.Color=CONFIG.UI.Accent; s.Thickness=1; s.Transparency=.4; s.Parent=f
      local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Size=UDim2.fromScale(1,1)
      t.Text=text; t.TextColor3=CONFIG.UI.Text; t.Font=Enum.Font.GothamMedium; t.TextSize=13; t.TextWrapped=true; t.Parent=f
      f.Parent=h
      TweenService:Create(f,TweenInfo.new(.25),{BackgroundTransparency=.25}):Play()
      task.delay(dur,function()
        local tw=TweenService:Create(f,TweenInfo.new(.3),{BackgroundTransparency=1})
        tw:Play(); tw.Completed:Wait(); f:Destroy()
      end)
    end)
  end
end

--========================= CORE > CONFIG STORE =============================
local Store = {Data={Toggles={}}}
do
  function Store.Save() P("SaveCfg",function()
    if type(writefile)=="function" then writefile(CONFIG.ConfigFile, HttpService:JSONEncode(Store.Data)) end end) end
  function Store.Load() P("LoadCfg",function()
    if type(readfile)=="function" and isfile and isfile(CONFIG.ConfigFile) then
      local d=HttpService:JSONDecode(readfile(CONFIG.ConfigFile))
      if type(d)=="table" and type(d.Toggles)=="table" then Store.Data=d end
    end end) end
  function Store.Set(n,v) Store.Data.Toggles[n]=v; Store.Save() end
  function Store.Get(n) return Store.Data.Toggles[n]==true end
end

--========================= CORE > TASK MANAGER =============================
local Tasks = {_b={}}
do
  function Tasks.Bucket(n) local b=Tasks._b[n]; if not b then b={c={},alive=true}; Tasks._b[n]=b end; return b end
  function Tasks.Stop(n) local b=Tasks._b[n]; if not b then return end; b.alive=false
    for _,c in ipairs(b.c) do pcall(function() c:Disconnect() end) end; Tasks._b[n]=nil end
  function Tasks.Ctx(n)
    local b=Tasks.Bucket(n)
    return {
      Loop=function(_,fn,iv) iv=iv or .1; local th=task.spawn(function()
        while b.alive do local ok,e=pcall(fn); if not ok then warn(("[MEIZU][Loop:%s] %s"):format(n,tostring(e))) end; task.wait(iv) end end)
        table.insert(b.c,{Disconnect=function() pcall(function() task.cancel(th) end) end}); return th end,
      Connect=function(_,sig,fn) local c=sig:Connect(function(...) pcall(fn,...) end); table.insert(b.c,c); return c end,
      OnCleanup=function(_,fn) table.insert(b.c,{Disconnect=fn}) end,
      Alive=function() return b.alive end,
    }
  end
end

--========================= CORE > FEATURE REGISTRY =========================
local Feature = {_r={}}
do
  function Feature.Register(name, group, fn) Feature._r[name]={fn=fn,group=group,active=false} end
  function Feature.Fire(name, on)
    local e=Feature._r[name]; if not e then Notify.Show("Không có feature: "..name,3); return false end
    if e.active==on then return true end
    Tasks.Stop(name); e.active=on
    if on then
      local ctx=Tasks.Ctx(name)
      local ok,err=pcall(e.fn,true,ctx)
      if not ok then e.active=false; Tasks.Stop(name); Notify.Show(("Lỗi '%s': %s"):format(name,tostring(err)),4); return false end
      Notify.Show("Bật: "..name,2)
    else Notify.Show("Tắt: "..name,2) end
    Store.Set(name,e.active); return true
  end
  function Feature.Restore()
    for n,e in pairs(Feature._r) do if Store.Get(n) then task.spawn(function() Feature.Fire(n,true) end) end end
  end
end

--========================= CORE > UTIL / CHARACTER GUARD ===================
local function Char()
  local c=LP.Character; if c and c.Parent and c:FindFirstChildOfClass("Humanoid") then return c end; return nil
end
local function Hum() local c=Char(); return c and c:FindFirstChildOfClass("Humanoid") or nil end
local function Root() local c=Char(); return c and c:FindFirstChild("HumanoidRootPart") or nil end
local function OnRespawn(fn) return LP.CharacterAdded:Connect(function(ch) ch:WaitForChild("Humanoid",5); task.wait(.2); pcall(fn,ch) end) end

-- Tìm model trong Workspace theo tên (khớp một phần, không phân biệt hoa thường)
local function FindModelByName(nameList, container)
  container = container or Workspace
  for _,obj in ipairs(container:GetDescendants()) do
    if obj:IsA("Model") or obj:IsA("BasePart") then
      for _,nm in ipairs(nameList) do
        if obj.Name:lower():find(nm:lower(),1,true) then return obj end
      end
    end
  end
  return nil
end
local function FindAllEnemies()
  local out={}; local c=Char(); if not c then return out end
  for _,m in ipairs(Workspace:GetDescendants()) do
    if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and m~=c then
      local h=m:FindFirstChildOfClass("Humanoid")
      if h and h.Health>0 and h.MaxHealth>0 and m:FindFirstChild("HumanoidRootPart") then
        for _,en in ipairs(EnemyNames) do
          if m.Name:lower():find(en:lower(),1,true) then table.insert(out,m); break end
        end
      end
    end
  end
  return out
end
local function NearestEnemy()
  local r=Root(); if not r then return nil end
  local best,bd=nil,math.huge
  for _,m in ipairs(FindAllEnemies()) do
    local p=m:FindFirstChild("HumanoidRootPart"); if p then
      local d=(p.Position-r.Position).Magnitude; if d<bd then bd=d; best=m end
    end
  end
  return best,bd
end

--========================= KEY SYSTEM ======================================
local KeySys = {}
do
  -- Ưu tiên HWID của executor (gethwid/hwid), fallback RbxAnalytics, cuối cùng UserId
  function KeySys.HWID()
    local id = tostring(LP.UserId)
    P("HWID-exec", function()
      if type(gethwid)=="function" then local r=gethwid(); if r and tostring(r):len()>0 then id=tostring(r); return end end
      if type(hwid)=="string" and #hwid>0 then id=hwid; return end
      if type(hwid)=="function" then local r=hwid(); if r then id=tostring(r); return end end
    end)
    if id ~= tostring(LP.UserId) then return id end
    P("HWID-roblox", function()
      local r=game:GetService("RbxAnalyticsService"):GetClientId()
      if r and #r>0 then id=tostring(r) end
    end)
    return id
  end
  local function cacheRead() local k=nil; P("ReadKey",function()
    if type(readfile)=="function" and isfile and isfile(CONFIG.KeyCacheFile) then k=readfile(CONFIG.KeyCacheFile) end end)
    return k and #k>0 and k or nil end
  local function cacheWrite(k) P("WriteKey",function()
    if type(writefile)=="function" then writefile(CONFIG.KeyCacheFile,k) end end) end
  function KeySys.Verify(key)
    local url=CONFIG.KeyVerifyUrl:format(HttpService:UrlEncode(key), HttpService:UrlEncode(KeySys.HWID()))
    local ok,res=P("KeyHttp",function() return HttpService:RequestAsync({Url=url,Method="GET"}) end)
    if not ok or not res then return false,"Không kết nối được key server" end
    if res.StatusCode~=200 then return false,("HTTP %s"):format(tostring(res.StatusCode)) end
    local parsed=nil; P("KeyParse",function() parsed=HttpService:JSONDecode(res.Body) end)
    if type(parsed)=="table" then
      local valid = parsed.valid==true or parsed.success==true or parsed.status=="ok" or parsed.message=="valid"
      if valid then cacheWrite(key); return true,"OK" end
      return false, parsed.message or "Key không hợp lệ"
    end
    -- fallback: một số backend trả text thuần "valid"/"invalid"
    if type(res.Body)=="string" and res.Body:lower():find("valid") and not res.Body:lower():find("invalid") then
      cacheWrite(key); return true,"OK" end
    return false,"Response không xác định"
  end
  function KeySys.HasCache() return cacheRead()~=nil end
  function KeySys.VerifyCache() local k=cacheRead(); if not k then return false,"Chưa có key" end; return KeySys.Verify(k) end
end

--[[==========================================================================
  FEATURES — cài đặt bằng API Roblox chuẩn (không cần remote bí mật)
  TODO-RUNTIME: nhận quest tự động & kích hoạt skill cần map Remote thật.
  ==========================================================================]]

-- ---------- Player ----------
Feature.Register("Player / WalkSpeed", "Player", function(on,ctx)
  local base=16; P("WS",function() local h=Hum(); if h then base=h.WalkSpeed end end)
  ctx:Loop(function() local h=Hum(); if h then h.WalkSpeed=on and 35 or base end end,.3)
  ctx:OnCleanup(function() local h=Hum(); if h then h.WalkSpeed=base end end)
end)
Feature.Register("Player / JumpPower", "Player", function(on,ctx)
  local base=50; P("JP",function() local h=Hum(); if h then base=h.UseJumpPower and h.JumpPower or 50 end end)
  ctx:Loop(function() local h=Hum(); if h then h.JumpPower=on and 100 or base end end,.3)
  ctx:OnCleanup(function() local h=Hum(); if h then h.JumpPower=base end end)
end)
Feature.Register("Player / No Clip", "Player", function(on,ctx)
  ctx:Connect(RunService.Stepped, function()
    local r=Root(); if not r then return end
    for _,p in ipairs(Char():GetDescendants()) do
      if p:IsA("BasePart") then p.CanCollide=not on end
    end
  end)
  ctx:OnCleanup(function() local c=Char(); if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end)
end)
Feature.Register("Player / Anti AFK", "Player", function(on,ctx)
  local vu=game:GetService("VirtualUser")
  ctx:Loop(function() if on then P("AntiAFK",function() vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame) task.wait(1) vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame) end) end end,60)
end)
Feature.Register("Player / Reset Character", "Player", function(on,ctx)
  P("Reset",function() local h=Hum(); if h then h.Health=0 end end)
  task.delay(.5,function() Feature.Fire("Player / Reset Character",false) end)
end)

-- ---------- Server ----------
Feature.Register("Server / Rejoin", "Server", function(on,ctx)
  P("Rejoin",function() TeleportSvc:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
  task.delay(1,function() Feature.Fire("Server / Rejoin",false) end)
end)
Feature.Register("Server / Copy JobId", "Server", function(on,ctx)
  P("CopyJob",function() if setclipboard then setclipboard(tostring(game.JobId)) end; Notify.Show("JobId đã copy",3) end)
  task.delay(.5,function() Feature.Fire("Server / Copy JobId",false) end)
end)
Feature.Register("Server / Server Hop", "Server", function(on,ctx)
  -- Dùng TeleportService đến place hiện tại (server khác). Cần danh sách server public;
  -- ở đây thực hiện rejoin đơn giản; hook list server thật tại TODO-RUNTIME.
  Notify.Show("Server Hop: thử vào server khác...",3)
  P("Hop",function() TeleportSvc:Teleport(game.PlaceId, LP) end)
  task.delay(1,function() Feature.Fire("Server / Server Hop",false) end)
end)

-- ---------- ESP ---------- (client-side, Highlight + BillboardGui)
local ESP = {conns={}}
Feature.Register("ESP / Player ESP", "ESP", function(on,ctx)
  local function addEsp(plr)
    if plr==LP then return end
    P("ESPAdd",function()
      local ch=plr.Character or plr.CharacterAdded:Wait(); local hrp=ch:WaitForChild("HumanoidRootPart",5)
      if not hrp then return end
      local hl=Instance.new("Highlight"); hl.FillColor=Color3.fromRGB(255,80,80)
      hl.FillTransparency=.6; hl.OutlineColor=Color3.fromRGB(255,255,255); hl.OutlineTransparency=.3
      hl.Adornee=ch; hl.Parent=hrp
      local bg=Instance.new("BillboardGui"); bg.Size=UDim2.fromOffset(120,30); bg.AlwaysOnTop=true
      bg.StudsOffset=Vector3.new(0,3,0); bg.Adornee=hrp; bg.Parent=hrp
      local tl=Instance.new("TextLabel"); bg.BackgroundTransparency=1; tl.BackgroundTransparency=1
      tl.Size=UDim2.fromScale(1,1); tl.Font=Enum.Font.GothamBold; tl.TextSize=13
      tl.TextColor3=Color3.fromRGB(255,120,120); tl.TextStrokeTransparency=.5; tl.Parent=bg
      ctx:Loop(function()
        if not ch.Parent then hl:Destroy(); bg:Destroy(); return end
        local h=ch:FindFirstChildOfClass("Humanoid"); local dist=Root() and (hrp.Position-Root().Position).Magnitude or 0
        tl.Text=("%s  %.0fm%s"):format(plr.Name, dist, h and ("  %.0f/%.0f"):format(h.Health,h.MaxHealth) or "")
      end,.3)
    end)
  end
  for _,plr in ipairs(Players:GetPlayers()) do task.spawn(addEsp,plr) end
  ctx:Connect(Players.PlayerAdded, function(plr) plr.CharacterAdded:Connect(function() task.spawn(addEsp,plr) end) end)
end)
Feature.Register("ESP / Fruit ESP", "ESP", function(on,ctx)
  ctx:Loop(function()
    for _,m in ipairs(Workspace:GetDescendants()) do
      if m:IsA("BasePart") or m:IsA("Model") then
        for rarity,list in pairs(FruitData) do
          for _,fn in ipairs(list) do
            if m.Name:lower():find(fn:lower(),1,true) and not m:FindFirstChild("MeizuFruitEsp") then
              P("FruitEsp",function()
                local hl=Instance.new("Highlight"); hl.Name="MeizuFruitEsp"
                hl.FillColor=Color3.fromRGB(255,215,0); hl.FillTransparency=.4
                hl.Adornee=m:IsA("Model") and m or m.Parent; hl.Parent=m
                Notify.Show(("Phát hiện trái: %s (%s)"):format(fn,rarity),5)
              end)
            end
          end
        end
      end
    end
  end,2)
end)

-- ---------- Teleport ---------- (tìm model đảo trong Workspace, dịch CFrame tới)
Feature.Register("Teleport / Auto đến đảo kế tiếp", "Teleport", function(on,ctx)
  ctx:Loop(function()
    local r=Root(); if not r then return end
    -- chọn đảo phù hợp cấp độ (đọc level từ leaderstats nếu có)
    local lv=1; P("Lv",function()
      local ls=LP:FindFirstChild("leaderstats"); if ls then
        local s=ls:FindFirstChild("Level"); if s then lv=tonumber(s.Value) or 1 end end end)
    local target=nil
    for sea,list in pairs(IslandData) do
      for _,isl in ipairs(list) do
        if isl.Lv<=lv and (not target or isl.Lv>target.Lv) then target=isl end
      end
    end
    if target then
      local m=FindModelByName({target.Name})
      if m then
        local pos = m:IsA("Model") and (m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")) or m
        if pos then r.CFrame=CFrame.new(pos.Position+Vector3.new(0,15,0)); Notify.Show("Đến: "..target.Name,3) end
      end
    end
    task.wait(5)
  end,1)
end)

-- ---------- Fruit ---------- (quét + thông báo + tự nhặt nếu gần)
Feature.Register("Fruit / Tìm & Thu thập", "Fruit", function(on,ctx)
  ctx:Loop(function()
    local r=Root(); if not r then return end
    for _,m in ipairs(Workspace:GetDescendants()) do
      if m:IsA("BasePart") then
        for _,list in pairs(FruitData) do
          for _,fn in ipairs(list) do
            if m.Name:lower():find(fn:lower(),1,true) then
              local d=(m.Position-r.Position).Magnitude
              if d<CONFIG.Farm.LootRadius then
                P("Pickup",function() firetouchinterest(r,m,0); firetouchinterest(r,m,1) end)
                Notify.Show("Đã chạm trái: "..fn,3)
              elseif d<500 then
                Notify.Show(("Trái %s ở cách %.0fm"):format(fn,d),4)
              end
            end
          end
        end
      end
    end
  end,1.5)
end)

-- ---------- Combat / AutoFarm ---------- (state machine: quét quái → di chuyển → đánh)
Feature.Register("Combat / Auto Farm", "Farming", function(on,ctx)
  local state="SCAN"; local lastMove=0; local lastPos=nil; local stuckTime=0
  local function equipMelee()
    P("Equip",function()
      local bp=LP:FindFirstChildOfClass("Backpack"); local char=Char()
      if not char then return end
      -- ưu tiên combat style / kiếm đang trang bị; nếu không, lấy tool đầu tiên
      local tool=char:FindFirstChildOfClass("Tool")
      if not tool and bp then
        for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then tool=t; break end end
        if tool then tool.Parent=char end
      end
    end)
  end
  ctx:Loop(function()
    local r=Root(); local h=Hum(); if not r or not h then state="SCAN"; return end
    if state=="SCAN" then
      local enemy,dist=NearestEnemy()
      if enemy then
        equipMelee(); state="MOVE"; lastMove=tick(); lastPos=r.Position; stuckTime=0
        Notify.Show("Mục tiêu: "..enemy.Name,2)
      end
    elseif state=="MOVE" then
      local enemy=NearestEnemy(); if not enemy then state="SCAN"; return end
      local hrp=enemy:FindFirstChild("HumanoidRootPart"); if not hrp then state="SCAN"; return end
      local dist=(hrp.Position-r.Position).Magnitude
      if dist>CONFIG.Farm.AttackRange then
        h:MoveTo(hrp.Position)
        -- phát hiện kẹt
        if (r.Position-lastPos).Magnitude<3 then stuckTime=stuckTime+CONFIG.Farm.ScanInterval
        else stuckTime=0; lastPos=r.Position end
        if stuckTime>CONFIG.Farm.StuckThreshold then
          r.CFrame=hrp.CFrame*CFrame.new(0,0,6); stuckTime=0; Notify.Show("Bỏ kẹt: dịch gần mục tiêu",2)
        end
      else
        h:MoveTo(r.Position); state="ATTACK"
      end
    elseif state=="ATTACK" then
      local enemy=NearestEnemy(); if not enemy then state="SCAN"; return end
      local hrp=enemy:FindFirstChild("HumanoidRootPart"); local eh=enemy:FindFirstChildOfClass("Humanoid")
      if not hrp or not eh or eh.Health<=0 then state="SCAN"; return end
      local dist=(hrp.Position-r.Position).Magnitude
      if dist>CONFIG.Farm.AttackRange*1.5 then state="MOVE"; return end
      -- xoay mặt về mục tiêu + kích hoạt tool (M1)
      P("Attack",function()
        r.CFrame=CFrame.lookAt(r.Position, Vector3.new(hrp.Position.X, r.Position.Y, hrp.Position.Z))
        local tool=Char():FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
        mouse1click = mouse1click or function() end -- placeholder; executor có mouse1click
      end)
    end
  end, CONFIG.Farm.ScanInterval)
end)

-- ---------- Quest ---------- (TODO-RUNTIME: remote nhận quest; hiện tại chỉ tìm NPC gần)
Feature.Register("Quest / Tìm NPC nhiệm vụ", "Quest", function(on,ctx)
  ctx:Loop(function()
    local m=FindModelByName({"Quest Giver","Quest Master","Teacher","Mayor","Soldier"})
    if m then
      local pos=m:IsA("Model") and (m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")) or m
      if pos then Notify.Show("NPC quest gần: "..m.Name.." tại "..tostring(pos.Position),5) end
    end
    task.wait(10)
  end,1)
end)

-- ---------- Boss ---------- (thông báo khi boss spawn trong Workspace)
Feature.Register("Boss / Cảnh báo spawn", "Boss", function(on,ctx)
  local seen={}
  ctx:Loop(function()
    for _,b in ipairs(BossData) do
      local m=FindModelByName({b.Name})
      if m and not seen[b.Name] then
        seen[b.Name]=true
        Notify.Show(("BOSS SPAWN: %s (Lv%d)"):format(b.Name,b.Level),6)
      elseif not m and seen[b.Name] then
        seen[b.Name]=false
      end
    end
  end,3)
end)

--========================= UI > BLUE LIQUID GLASS COMPACT ==================
local UI={}
do
  local TABS={"Player","Farming","Combat","Quest","Teleport","Fruit","ESP","Boss","Server","Settings"}
  local toggles={}
  local function glass(parent,size,pos,corner)
    local f=Instance.new("Frame"); f.Size=size; f.Position=pos or UDim2.new(); f.BorderSizePixel=0
    f.BackgroundColor3=CONFIG.UI.Bg; f.BackgroundTransparency=.32
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,corner or CONFIG.UI.Corner); c.Parent=f
    local g=Instance.new("UIGradient"); g.Color=ColorSequence.new{
      ColorSequenceKeypoint.new(0,Color3.fromRGB(22,36,66)), ColorSequenceKeypoint.new(1,Color3.fromRGB(8,12,26))}
    g.Rotation=90; g.Parent=f
    local s=Instance.new("UIStroke"); s.Color=CONFIG.UI.Accent; s.Thickness=1; s.Transparency=.55; s.Parent=f
    f.Parent=parent; return f
  end
  local function makeToggle(row,name)
    local t=Instance.new("TextButton"); t.Size=UDim2.fromOffset(40,20); t.Position=UDim2.new(1,-50,0.5,-10)
    t.BackgroundColor3=Color3.fromRGB(40,50,70); t.Text=""; t.BorderSizePixel=0; t.AutoButtonColor=false; t.Parent=row
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=t
    local k=Instance.new("Frame"); k.Size=UDim2.fromOffset(16,16); k.Position=UDim2.new(0,2,0.5,-8)
    k.BackgroundColor3=Color3.fromRGB(200,210,230); k.BorderSizePixel=0; k.Parent=t
    local kc=Instance.new("UICorner"); kc.CornerRadius=UDim.new(1,0); kc.Parent=k
    local st={on=false}; toggles[name]={btn=t,knob=k,state=st}
    t.MouseButton1Click:Connect(function()
      local nx=not st.on; local ok=Feature.Fire(name,nx)
      if not ok then nx=false end
      st.on=nx
      TweenService:Create(t,TweenInfo.new(.18),{BackgroundColor3=nx and CONFIG.UI.Accent or Color3.fromRGB(40,50,70)}):Play()
      TweenService:Create(k,TweenInfo.new(.18),{Position=nx and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
    end)
  end
  local function addRow(parent,name)
    local row=glass(parent,UDim2.new(1,-8,0,34),nil,10); row.BackgroundTransparency=.75
    local lb=Instance.new("TextLabel"); lb.BackgroundTransparency=1; lb.Size=UDim2.new(1,-60,1,0)
    lb.Position=UDim2.fromOffset(10,0); lb.Text=name:gsub("^.+ / ",""); lb.TextColor3=CONFIG.UI.Text
    lb.Font=Enum.Font.Gotham; lb.TextSize=13; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=row
    makeToggle(row,name)
  end
  function UI.Build()
    local pg=LP:WaitForChild("PlayerGui")
    local sg=Instance.new("ScreenGui"); sg.Name="MeizuHub"; sg.ResetOnSpawn=false
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; P("Inset",function() sg.IgnoreGuiInset=true end); sg.Parent=pg
    local vp=Workspace.CurrentCamera.ViewportSize
    local w=math.min(CONFIG.UI.Width,vp.X-24); local h=math.min(CONFIG.UI.Height,vp.Y-80)
    local win=glass(sg,UDim2.fromOffset(w,h),UDim2.new(0.5,-w/2,0.5,-h/2),CONFIG.UI.Corner)
    win.Active=true; win.Draggable=true
    local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,0,0,36); title.BackgroundTransparency=1
    title.Text=("  %s   v%s"):format(CONFIG.HubName,CONFIG.Version); title.TextColor3=CONFIG.UI.Text
    title.Font=Enum.Font.GothamBold; title.TextSize=14; title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=win
    local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,-16,0,1); bar.Position=UDim2.fromOffset(8,36)
    bar.BackgroundColor3=CONFIG.UI.Accent; bar.BackgroundTransparency=.6; bar.BorderSizePixel=0; bar.Parent=win
    local side=Instance.new("Frame"); side.Size=UDim2.new(0,64,1,-44); side.Position=UDim2.fromOffset(0,44)
    side.BackgroundTransparency=1; side.Parent=win
    local sl=Instance.new("UIListLayout"); sl.Padding=UDim.new(0,4); sl.HorizontalAlignment=Enum.HorizontalAlignment.Center; sl.Parent=side
    local sp=Instance.new("UIPadding"); sp.PaddingTop=UDim.new(0,6); sp.Parent=side
    local scroll=Instance.new("ScrollingFrame"); scroll.Size=UDim2.new(1,-72,1,-50); scroll.Position=UDim2.fromOffset(68,46)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=3
    scroll.ScrollBarImageColor3=CONFIG.UI.Accent; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.CanvasSize=UDim2.new(); scroll.Parent=win
    local holders={}; local btns={}
    local function switch(tab) for n,hd in pairs(holders) do hd.Visible=(n==tab) end
      for n,b in pairs(btns) do b.BackgroundColor3=(n==tab) and CONFIG.UI.Accent or Color3.fromRGB(18,26,46) end end
    for _,tab in ipairs(TABS) do
      local b=Instance.new("TextButton"); b.Size=UDim2.new(0,56,0,28); b.Text=tab:sub(1,5)
      b.BackgroundColor3=Color3.fromRGB(18,26,46); b.TextColor3=CONFIG.UI.Text; b.Font=Enum.Font.GothamMedium
      b.TextSize=10; b.BorderSizePixel=0; local bc=Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,8); bc.Parent=b
      b.Parent=side; btns[tab]=b; b.MouseButton1Click:Connect(function() switch(tab) end)
      local hd=Instance.new("Frame"); hd.Size=UDim2.new(1,0,1,0); hd.BackgroundTransparency=1; hd.Visible=false; hd.Parent=scroll
      local hl=Instance.new("UIListLayout"); hl.Padding=UDim.new(0,6); hl.Parent=hd; holders[tab]=hd
      for name,e in pairs(Feature._r) do if e.group==tab then addRow(hd,name) end end
    end
    switch(CONFIG.DefaultTab)
    -- sync toggle states từ config
    for name,t in pairs(toggles) do if Store.Get(name) then
      t.state.on=true; t.btn.BackgroundColor3=CONFIG.UI.Accent; t.knob.Position=UDim2.new(1,-18,0.5,-8) end end
    Notify.Show(CONFIG.HubName.." đã tải",2)
  end
end

--========================= KEY GATE UI =====================================
local function KeyGate(onOk)
  local pg=LP:WaitForChild("PlayerGui")
  local sg=Instance.new("ScreenGui"); sg.Name="MeizuKeyGate"; sg.ResetOnSpawn=false
  P("Inset",function() sg.IgnoreGuiInset=true end); sg.Parent=pg
  local vp=Workspace.CurrentCamera.ViewportSize; local w=math.min(280,vp.X-32)
  local f=Instance.new("Frame"); f.Size=UDim2.fromOffset(w,220); f.Position=UDim2.new(0.5,-w/2,0.5,-110)
  f.BackgroundColor3=CONFIG.UI.Bg; f.BackgroundTransparency=.25; f.BorderSizePixel=0; f.Parent=sg
  local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,14); c.Parent=f
  local s=Instance.new("UIStroke"); s.Color=CONFIG.UI.Accent; s.Thickness=1; s.Transparency=.5; s.Parent=f
  local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,0,0,34); t.BackgroundTransparency=1
  t.Text="MEIZU HUB — Nhập Key"; t.TextColor3=CONFIG.UI.Text; t.Font=Enum.Font.GothamBold; t.TextSize=14; t.Parent=f
  local box=Instance.new("TextBox"); box.Size=UDim2.new(1,-32,0,34); box.Position=UDim2.fromOffset(16,44)
  box.PlaceholderText="Dán key vào đây"; box.Text=""; box.BackgroundColor3=Color3.fromRGB(18,26,46)
  box.TextColor3=CONFIG.UI.Text; box.Font=Enum.Font.Gotham; box.TextSize=13; box.ClearTextOnFocus=false; box.BorderSizePixel=0; box.Parent=f
  local bc=Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,8); bc.Parent=box
  local get=Instance.new("TextButton"); get.Size=UDim2.new(1,-32,0,22); get.Position=UDim2.fromOffset(16,82)
  get.BackgroundTransparency=1; get.Text="Lấy key (mở link)"; get.TextColor3=CONFIG.UI.Accent; get.Font=Enum.Font.Gotham; get.TextSize=11; get.Parent=f
  get.MouseButton1Click:Connect(function() P("OpenKey",function()
    local url = CONFIG.KeyGetUrl .. "?hwid=" .. HttpService:UrlEncode(KeySys.HWID())
    if setclipboard then setclipboard(url) end
    Notify.Show("Link lấy key (kèm HWID) đã copy",4)
  end) end)
  local hwidLbl=Instance.new("TextButton"); hwidLbl.Size=UDim2.new(1,-32,0,20); hwidLbl.Position=UDim2.fromOffset(16,106)
  hwidLbl.BackgroundTransparency=1; hwidLbl.Font=Enum.Font.Gotham; hwidLbl.TextSize=10
  hwidLbl.TextColor3=CONFIG.UI.Dim; hwidLbl.AutoButtonColor=false; hwidLbl.Parent=f
  hwidLbl.Text = "HWID: " .. KeySys.HWID():sub(1,26) .. (KeySys.HWID():len()>26 and "…" or "") .. "  (bấm để copy)"
  hwidLbl.MouseButton1Click:Connect(function() P("CopyHWID",function()
    if setclipboard then setclipboard(KeySys.HWID()) end; Notify.Show("HWID đã copy",3)
  end) end)
  local status=Instance.new("TextLabel"); status.Size=UDim2.new(1,-32,0,20); status.Position=UDim2.fromOffset(16,128)
  status.BackgroundTransparency=1; status.Text=""; status.TextColor3=Color3.fromRGB(255,130,130)
  status.Font=Enum.Font.Gotham; status.TextSize=11; status.TextWrapped=true; status.Parent=f
  local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,-32,0,34); btn.Position=UDim2.fromOffset(16,154)
  btn.Text="Xác nhận Key"; btn.BackgroundColor3=CONFIG.UI.Accent; btn.TextColor3=Color3.fromRGB(10,16,32)
  btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.BorderSizePixel=0; btn.Parent=f
  local btc=Instance.new("UICorner"); btc.CornerRadius=UDim.new(0,8); btc.Parent=btn
  local busy=false
  btn.MouseButton1Click:Connect(function()
    if busy then return end; local key=box.Text:gsub("%s","")
    if #key==0 then status.Text="Chưa nhập key"; return end
    busy=true; btn.Text="Đang kiểm tra..."; status.Text=""
    task.spawn(function()
      local ok,msg=KeySys.Verify(key); busy=false; btn.Text="Xác nhận Key"
      if ok then sg:Destroy(); onOk() else status.Text="Lỗi: "..tostring(msg) end
    end)
  end)
end

--========================= BOOTSTRAP =======================================
Store.Load()
local function Open() UI.Build(); Feature.Restore() end
task.spawn(function()
  if KeySys.HasCache() then
    local ok=KeySys.VerifyCache(); if ok then Open(); return end
    Notify.Show("Key cache hết hạn, nhập lại",3)
  end
  KeyGate(Open)
end)

-- dọn dẹp cho lần chạy sau
getgenv().MEIZU_CLEANUP = function()
  P("Cleanup",function()
    for n in pairs(Feature._r) do Tasks.Stop(n) end
    local pg=LP:FindFirstChild("PlayerGui"); if pg then
      for _,nm in ipairs({"MeizuHub","MeizuKeyGate","MeizuNotify"}) do
        local x=pg:FindFirstChild(nm); if x then x:Destroy() end
      end
    end
  end)
end
