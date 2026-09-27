--[[==========================================================================
 MEIZU HUB v3.0 — Blox Fruits | Banana Hub Style · Gold → Blue
 Auto Quest + Smart Auto Farm | Theme: Pale Gold → Deep Blue Glass
 ==========================================================================]]

--========================= CONFIG ==========================================
local CONFIG = {
 HubName = "MEIZU HUB",
 Version = "3.0.0-banana-blue",
 KeyVerifyUrl = "https://getkeyhub-uwal.onrender.com/api/verify?key=%s&hwid=%s",
 KeyGetUrl = "https://lovemeizu.github.io/GetKeyHub/getkey.html",
 KeyCacheFile = "meizu_hub_key.txt",
 ConfigFile = "meizu_hub_config.json",
 DefaultTab = "Player",
 LoaderUrl = "https://raw.githubusercontent.com/lovemeizu/GetKeyHub/main/MeizuHub.lua",
 UI = {
   Width = 340, Height = 520, Corner = 24,
   -- Theme: Pale Gold → Deep Blue
   Gold = Color3.fromRGB(250, 204, 21),      -- #facc15
   Blue = Color3.fromRGB(59, 130, 246),       -- #3b82f6
   Blue2 = Color3.fromRGB(37, 99, 235),       -- #2563eb
   DarkBlue = Color3.fromRGB(12, 26, 47),     -- #0c1a2f
   CardBg = Color3.fromRGB(255, 255, 255, 0.06),
   Stroke = Color3.fromRGB(147, 197, 253, 0.18),
   Text = Color3.fromRGB(240, 249, 255),
   Muted = Color3.fromRGB(147, 197, 253),
   Green = Color3.fromRGB(34, 197, 94),
   Red = Color3.fromRGB(239, 68, 68),
   SidebarWidth = 82,
 },
 Farm = {
   ScanInterval = 0.4,
   AttackRange = 14,
   StuckThreshold = 3.5,
   LootRadius = 45,
   AutoPickup = true,
   EquipDelay = 0.8,
   MaxTargetLevelDiff = 60,
 },
}

--========================= ANTI-RERUN ======================================
do
 local lastRun = _G.MEIZU_LAST_EXEC
 if lastRun and (tick() - lastRun) <= 5 then
   return warn("[MEIZU] Đã chạy trong 5 giây qua — bỏ qua")
 end
 _G.MEIZU_LAST_EXEC = tick()
end

--========================= QUEUE ON TELEPORT ==============================
do
 local executor = syn or fluxus or KRNL
 local queueFn = queue_on_teleport or (executor and executor.queue_on_teleport)
 if not _G.MEIZU_TP_QUEUE and type(queueFn) == "function" then
   _G.MEIZU_TP_QUEUE = true
   local reloadScript = ("loadstring(game:HttpGet('%s', true))()"):format(CONFIG.LoaderUrl)
   pcall(queueFn, reloadScript)
 end
end

--========================= SERVICES ========================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TeleportSvc = game:GetService("TeleportService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

if getgenv and getgenv().MEIZU_CLEANUP then pcall(getgenv().MEIZU_CLEANUP) end

local function P(label, fn, ...)
 local ok, r = pcall(fn, ...)
 if not ok then warn(("[MEIZU][%s] %s"):format(label, tostring(r))) end
 return ok, r
end

--========================= DATA ============================================
local IslandData = {
 Sea1 = {
   {Name="Starter Island", Lv=1}, {Name="Jungle", Lv=15},
   {Name="Pirate Village", Lv=30}, {Name="Desert", Lv=35},
   {Name="Frozen Village", Lv=50}, {Name="Marine Fortress", Lv=120},
   {Name="Skylands", Lv=150}, {Name="Prison", Lv=190},
   {Name="Colosseum", Lv=225}, {Name="Magma Village", Lv=300},
   {Name="Underwater City", Lv=375}, {Name="Fountain City", Lv=450},
 },
 Sea2 = {
   {Name="Kingdom of Rose", Lv=700}, {Name="Usoap's Island", Lv=700},
   {Name="Green Zone", Lv=875}, {Name="Graveyard", Lv=925},
   {Name="Snow Mountain", Lv=1000}, {Name="Hot and Cold", Lv=1100},
   {Name="Cursed Ship", Lv=1250}, {Name="Ice Castle", Lv=1350},
   {Name="Forgotten Island",Lv=1425},
 },
 Sea3 = {
   {Name="Port Town", Lv=1500}, {Name="Hydra Island", Lv=1575},
   {Name="Great Tree", Lv=1625}, {Name="Floating Turtle", Lv=1700},
   {Name="Cake Land", Lv=1750}, {Name="Ice Cream Land", Lv=1875},
   {Name="Castle on the Sea",Lv=2175}, {Name="Sea of Treats", Lv=2400},
 },
}

local QuestNPCData = {
 {Name="Quest Giver (Starter)", Island="Starter Island", MinLv=1, QuestType="Kill", TargetCount=5, TargetNames={"Bandit"}},
 {Name="Quest Giver (Jungle)", Island="Jungle", MinLv=10, QuestType="Kill", TargetCount=6, TargetNames={"Monkey", "Gorilla"}},
 {Name="Quest Giver (Pirate)", Island="Pirate Village", MinLv=20, QuestType="Kill", TargetCount=8, TargetNames={"Pirate"}},
 {Name="Quest Giver (Desert)", Island="Desert", MinLv=35, QuestType="Kill", TargetCount=8, TargetNames={"Desert Bandit"}},
 {Name="Quest Giver (Skylands)", Island="Skylands", MinLv=150, QuestType="Kill", TargetCount=10, TargetNames={"Sky Pirate"}},
 {Name="Quest Giver (Rose)", Island="Kingdom of Rose", MinLv=700, QuestType="Kill", TargetCount=12, TargetNames={"Rose Militia"}},
 {Name="Quest Giver (GreenZone)", Island="Green Zone", MinLv=875, QuestType="Kill", TargetCount=12, TargetNames={"Green Zone Soldier"}},
 {Name="Quest Giver (SnowMtn)", Island="Snow Mountain", MinLv=1000, QuestType="Kill", TargetCount=14, TargetNames={"Snow Warrior"}},
}

local FruitData = {
 Common = {"Rocket","Spin","Chop","Spring","Bomb","Smoke","Spike"},
 Uncommon = {"Flame","Ice","Sand","Dark","Light","Rubber","Barrier","Diamond"},
 Rare = {"Quake","String","Spider","Love","Ghost","Buddha"},
 Legendary= {"Sound","Phoenix","Portal","Lightning","Pain","Blizzard","Gravity","Magma","Venom","Dough","Dragon","Mammoth","T-Rex"},
 Mythical = {"Leopard","Kitsune","Control","Spirit","Shadow","Gas","Mochi"},
}

local BossData = {
 {Name="Gorilla King", Lv=20, Island="Jungle"},
 {Name="Bobby", Lv=55, Island="Pirate Village"},
 {Name="The Saw", Lv=100, Island="Desert"},
 {Name="Yeti", Lv=110, Island="Frozen Village"},
 {Name="Vice Admiral", Lv=130, Island="Marine Fortress"},
 {Name="Warden", Lv=220, Island="Prison"},
 {Name="Chief Warden", Lv=230, Island="Prison"},
 {Name="Swan", Lv=240, Island="Prison"},
 {Name="Thunder God", Lv=575, Island="Skylands"},
 {Name="Cyborg", Lv=675, Island="Fountain City"},
 {Name="Don Swan", Lv=1000, Island="Kingdom of Rose"},
 {Name="Darkbeard", Lv=1000, Island="Dark Arena"},
 {Name="Awakened Ice Admiral", Lv=1400, Island="Ice Castle"},
 {Name="rip_indra", Lv=1500, Island="Second Sea"},
}

local EnemyNames = {
 "Bandit","Monkey","Pirate","Desert Bandit","Marine","Sky Pirate",
 "Prisoner","Colosseum Fighter","Magma Villager","Underwater Fighter",
 "Rose Militia","Green Zone Soldier","Snow Warrior","Hot and Cold Fighter",
 "Cursed Pirate","Ice Castle Guard","Port Town Bandit","Gorilla",
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
   local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,8)
   l.HorizontalAlignment=Enum.HorizontalAlignment.Right; l.VerticalAlignment=Enum.VerticalAlignment.Top; l.Parent=holder
   local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,12); p.PaddingRight=UDim.new(0,12); p.Parent=holder
   holder.Parent=pg; return holder
 end
 function Notify.Show(text, dur)
   dur=dur or 3; P("Notify",function()
     local h=ensure(); local f=Instance.new("Frame")
     f.Size=UDim2.fromOffset(280,44); f.BackgroundColor3=CONFIG.UI.CardBg
     f.BackgroundTransparency=.1; f.BorderSizePixel=0
     f.BorderColor3=CONFIG.UI.Stroke
     local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,16); c.Parent=f
     local s=Instance.new("UIStroke"); s.Color=CONFIG.UI.Gold; s.Thickness=1.5; s.Transparency=.5; s.Parent=f
     local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Size=UDim2.fromScale(1,1)
     t.Text=text; t.TextColor3=CONFIG.UI.Text; t.Font=Enum.Font.GothamBold; t.TextSize=14; t.TextWrapped=true; t.Parent=f
     f.Parent=h
     TweenService:Create(f,TweenInfo.new(.25),{BackgroundTransparency=.1}):Play()
     task.delay(dur,function()
       local tw=TweenService:Create(f,TweenInfo.new(.35),{BackgroundTransparency=1,BorderTransparency=1})
       tw:Play(); tw.Completed:Wait(); f:Destroy()
     end)
   end)
 end
end

--========================= CORE > CONFIG STORE =============================
local Store = {Data={Toggles={}}}
do
 function Store.Save() P("SaveCfg",function()
   if type(writefile)=="function" then writefile(CONFIG.ConfigFile, HttpService:JSONEncode(Store.Data)) end
 end) end
 function Store.Load() P("LoadCfg",function()
   if type(readfile)=="function" and isfile and isfile(CONFIG.ConfigFile) then
     local d=HttpService:JSONDecode(readfile(CONFIG.ConfigFile))
     if type(d)=="table" and type(d.Toggles)=="table" then Store.Data=d end
   end
 end) end
 function Store.Set(n,v) Store.Data.Toggles[n]=v; Store.Save() end
 function Store.Get(n) return Store.Data.Toggles[n]==true end
end

--========================= CORE > TASK MANAGER =============================
local Tasks = {_b={}}
do
 function Tasks.Bucket(n) local b=Tasks._b[n]; if not b then b={c={},alive=true}; Tasks._b[n]=b end; return b end
 function Tasks.Stop(n) local b=Tasks._b[n]; if not b then return end; b.alive=false
   for _,c in ipairs(b.c) do pcall(function() c:Disconnect() end) end; Tasks._b[n]=nil
 end
 function Tasks.Ctx(n)
   local b=Tasks.Bucket(n)
   return {
     Loop=function(_,fn,iv) iv=iv or .1; local th=task.spawn(function()
       while b.alive do local ok,e=pcall(fn); if not ok then warn(("[MEIZU][Loop:%s] %s"):format(n,tostring(e))) end; task.wait(iv) end
     end)
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
     Notify.Show("✅ Bật: "..name,2)
   else
     Notify.Show("❌ Tắt: "..name,2)
   end
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
local function GetLevel()
 local lv=1; P("GetLv",function()
   local ls=LP:FindFirstChild("leaderstats"); if ls then
     local s=ls:FindFirstChild("Level"); if s then lv=tonumber(s.Value) or 1 end
   end
 end)
 return lv
end
local function OnRespawn(fn) return LP.CharacterAdded:Connect(function(ch) ch:WaitForChild("Humanoid",5); task.wait(.2); pcall(fn,ch) end) end
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
 local myLv = GetLevel()
 for _,m in ipairs(Workspace:GetDescendants()) do
   if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and m~=c then
     local h=m:FindFirstChildOfClass("Humanoid")
     if h and h.Health>0 and h.MaxHealth>0 and m:FindFirstChild("HumanoidRootPart") then
       local validName=false; local enemyName=""
       for _,en in ipairs(EnemyNames) do
         if m.Name:lower():find(en:lower(),1,true) then validName=true; enemyName=en; break end
       end
       if validName then
         local canTarget=true
         local enemyLv=1
         for _,npc in ipairs(QuestNPCData) do
           for _,tn in ipairs(npc.TargetNames or {}) do
             if enemyName:lower()==tn:lower() then enemyLv = npc.MinLv; break end
           end
         end
         if math.abs(enemyLv - myLv) > CONFIG.Farm.MaxTargetLevelDiff then
           canTarget=false
         end
         if canTarget then table.insert(out,m) end
       end
     end
   end
 end
 return out
end

local function NearestEnemy(targetNames)
 local r=Root(); if not r then return nil end
 local best,bd=nil,math.huge
 for _,m in ipairs(FindAllEnemies()) do
   if targetNames then
     local hasName=false
     for _,n in ipairs(targetNames) do
       if m.Name:lower():find(n:lower(),1,true) then hasName=true; break end
     end
     if not hasName then continue end
   end
   local p=m:FindFirstChild("HumanoidRootPart"); if p then
     local d=(p.Position-r.Position).Magnitude; if d<bd then bd=d; best=m end
   end
 end
 return best,bd
end

local function EquipTool(nameContains)
 local c=Char(); if not c then return end
 local bp=LP:FindFirstChildOfClass("Backpack"); if not bp then return end
 local tool=c:FindFirstChildOfClass("Tool")
 if tool then return true end
 for _,t in ipairs(bp:GetChildren()) do
   if t:IsA("Tool") and (not nameContains or t.Name:lower():find(nameContains:lower(),1,true)) then
     t.Parent=c; task.wait(CONFIG.Farm.EquipDelay); return true
   end
 end
 return false
end

--========================= CORE > QUEST MANAGER =============================
local QuestManager = {
 CurrentQuest = nil,
 KillCount = 0,
 TargetCount = 0,
 State = "IDLE",
}

function QuestManager:Reset()
 self.CurrentQuest=nil; self.KillCount=0; self.TargetCount=0; self.State="IDLE"
end

function QuestManager:FindAvailableQuest()
 local myLv = GetLevel()
 local best=nil
 for _,q in ipairs(QuestNPCData) do
   if q.MinLv <= myLv and (not best or q.MinLv > best.MinLv) then
     best=q
   end
 end
 return best
end

function QuestManager:UpdateKillCount(enemyName)
 if not self.CurrentQuest then return false end
 for _,tn in ipairs(self.CurrentQuest.TargetNames or {}) do
   if enemyName:lower():find(tn:lower(),1,true) then
     self.KillCount += 1
     return true
   end
 end
 return false
end

--========================= KEY SYSTEM ======================================
local KeySys = {}
do
 function KeySys.HWID()
   local id = tostring(LP.UserId)
   P("HWID-exec", function()
     if type(gethwid)=="function" then local r=gethwid(); if r and tostring(r):len()>0 then id=tostring(r); return end end
     if type(hwid)=="string" and #hwid>0 then id=hwid; return end
     pcall(function()
       local sas=game:GetService("RbxAnalyticsService")
       local cid=sas:GetClientId()
       if cid and #cid>10 then id=cid end
     end)
   end)
   return id
 end

 function KeySys.Cached()
   if type(readfile)=="function" and isfile and isfile(CONFIG.KeyCacheFile) then
     local cached=readfile(CONFIG.KeyCacheFile)
     if cached and #cached>10 then return cached end
   end
   return nil
 end

 function KeySys.SaveCache(key)
   if type(writefile)=="function" then writefile(CONFIG.KeyCacheFile, key) end
 end

 function KeySys.Verify(key, cb)
   local hwid=KeySys.HWID()
   local url=CONFIG.KeyVerifyUrl:format(HttpService:UrlEncode(key), HttpService:UrlEncode(hwid))
   P("KeyVerify", function()
     local res=game:HttpGet(url)
     local data=HttpService:JSONDecode(res)
     if data and data.success~=false and data.valid~=false then
       KeySys.SaveCache(key)
       cb(true, data.message or "Key hợp lệ")
     else
       cb(false, data.error or "Key không hợp lệ")
     end
   end)
 end
end

--========================= FEATURES =========================================
-- Player
Feature.Register("WalkSpeed", "Player", function(enabled, ctx)
 local hum = Hum()
 if enabled and hum then hum.WalkSpeed = 32 end
 ctx:Connect(LP.CharacterAdded, function() task.wait(.3)
   if enabled then local h=Hum(); if h then h.WalkSpeed=32 end end
 end)
 ctx:OnCleanup(function() local h=Hum(); if h then h.WalkSpeed=16 end end)
end)

Feature.Register("JumpPower", "Player", function(enabled, ctx)
 local hum = Hum()
 if enabled and hum then hum.JumpPower = 55 end
 ctx:Connect(LP.CharacterAdded, function() task.wait(.3)
   if enabled then local h=Hum(); if h then h.JumpPower=55 end end
 end)
 ctx:OnCleanup(function() local h=Hum(); if h then h.JumpPower=50 end end)
end)

Feature.Register("NoClip", "Player", function(enabled, ctx)
 local conn
 ctx:Connect(RunService.Stepped, function()
   if enabled then local c=Char(); if c then for _,p in ipairs(c:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end end end
 end)
 ctx:OnCleanup(function() local c=Char(); if c then for _,p in ipairs(c:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=true end end end end)
end)

Feature.Register("AntiAFK", "Player", function(enabled, ctx)
 ctx:Loop(function()
   if enabled then task.spawn(function() pcall(function()
       LP.Idled:FireServer()
       VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
       task.wait(0.05)
       VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
     end) end, 60)
   end
 end)
end)

-- Farming
Feature.Register("Auto Farm", "Farming", function(enabled, ctx)
 local lastTarget, lastPos, stuckTimer = nil, nil, 0
 ctx:Loop(function()
   if not enabled then return end
   local r=Root(); if not r then return end
   local target, dist = NearestEnemy()
   if target and dist then
     local tr=target:FindFirstChild("HumanoidRootPart")
     if tr then
       if dist > CONFIG.Farm.AttackRange then
         lastPos = r.Position; stuckTimer = 0
         pcall(function() r.CFrame = CFrame.new(tr.Position * Vector3.new(1,0,1) + Vector3.new(0,4,0)) end)
       else
         EquipTool()
         task.wait(0.15)
         pcall(function() workspace.CurrentCamera.CFrame = CFrame.new(r.Position, tr.Position) end)
         task.wait(0.1)
         local tool = Char() and Char():FindFirstChildOfClass("Tool")
         if tool then pcall(function() tool:Activate() end end
         QuestManager:UpdateKillCount(target.Name)
       end
     end
   else
     QuestManager.State = "FIND_NPC"
   end
 end, CONFIG.Farm.ScanInterval)
end)

Feature.Register("Auto Quest", "Farming", function(enabled, ctx)
 ctx:Loop(function()
   if not enabled then return end
   if QuestManager.State == "IDLE" or QuestManager.State == "COMPLETED" then
     local quest = QuestManager:FindAvailableQuest()
     if quest then
       QuestManager.CurrentQuest = quest
       QuestManager.KillCount = 0
       QuestManager.TargetCount = quest.TargetCount
       QuestManager.State = "KILLING"
       Notify.Show(("📋 Nhận: %s — %d/%d"):format(quest.Name:gsub("Quest Giver ",""), 0, quest.TargetCount), 3)
     end
   elseif QuestManager.State == "KILLING" and QuestManager.KillCount >= QuestManager.TargetCount then
     QuestManager.State = "RETURNING"
     Notify.Show("✅ Hoàn thành quest! Đang quay lại NPC...", 3)
     -- TODO: Auto return quest khi có API
     QuestManager.State = "COMPLETED"
   end
 end, 1.0)
end)

-- ESP
local ESPObjects = {}
Feature.Register("Player ESP", "ESP", function(enabled, ctx)
 ctx:Loop(function()
   if not enabled then
     for _,obj in pairs(ESPObjects) do pcall(function() obj:Destroy() end) end
     table.clear(ESPObjects)
     return
   end
   local r=Root(); if not r then return end
   for _,pl in ipairs(Players:GetPlayers()) do
     if pl~=LP and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
       local pr=pl.Character.HumanoidRootPart
       local ph=pl.Character:FindFirstChildOfClass("Humanoid")
       local uid = "esp_"..pl.UserId
       local dist = (pr.Position - r.Position).Magnitude
       local tag = ESPObjects[uid]
       if not tag then
         tag = Instance.new("BillboardGui")
         tag.Name = "MeizuESP_"..pl.Name
         tag.AlwaysOnTop = true
         tag.Size = UDim2.new(140,0,26,0)
         tag.StudsOffset = Vector3.new(0,-3,0)
         local txt = Instance.new("TextLabel")
         txt.BackgroundTransparency = 1
         txt.Size = UDim2.new(1,0,1,0)
         txt.Font = Enum.Font.GothamBold
         txt.TextSize = 12
         txt.TextColor3 = Color3.fromRGB(255,255,255)
         txt.TextStrokeTransparency = 0
         txt.TextStrokeColor3 = Color3.fromRGB(0,0,0)
         txt.Parent = tag
         tag.Parent = pr
         ESPObjects[uid] = tag
       end
       local health = ph and math.floor(ph.Health).."HP" or ""
       tag:FindFirstChildWhichIsA("TextLabel").Text = string.format("%s — %dm %s", pl.Name, math.floor(dist), health)
     else
       if ESPObjects["esp_"..pl.UserId] then
         ESPObjects["esp_"..pl.UserId]:Destroy()
         ESPObjects["esp_"..pl.UserId] = nil
       end
     end
   end
 end, 0.3)
end)

Feature.Register("Fruit ESP", "ESP", function(enabled, ctx)
 local lastSpawn = 0
 ctx:Loop(function()
   if not enabled then return end
   local r=Root(); if not r then return end
   for _,m in ipairs(Workspace:GetChildren()) do
     if m:IsA("BasePart") and m.Name:find("Fruit", 1, true) or m.Name:find("Blox", 1, true) then
       local dist = (m.Position - r.Position).Magnitude
       if dist < 80 and os.time() - lastSpawn > 8 then
         local rarity = "Common"
         for rname,list in pairs(FruitData) do
           for _,fn in ipairs(list) do
             if m.Name:lower():find(fn:lower(),1,true) then rarity = rname break end
           end
         end
         local col = {Common=Color3.fromRGB(180,180,180), Uncommon=Color3.fromRGB(85,180,255), Rare=Color3.fromRGB(180,85,255), Legendary=Color3.fromRGB(255,180,0), Mythical=Color3.fromRGB(255,50,180)}
         Notify.Show(("🍇 %s — %dm"):format(m.Name, math.floor(dist)), 4)
         lastSpawn = os.time()
         break
       end
     end
   end
 end, 1.5)
end)

-- Teleport
Feature.Register("Teleport Đảo", "Teleport", function(enabled, ctx)
 ctx:Loop(function() end)
end)

-- Server
Feature.Register("Rejoin", "Server", function(enabled, ctx)
 if enabled then TeleportSvc:TeleportToPlaceInstance(game.PlaceId, game.JobId) end
end)

Feature.Register("Copy JobId", "Server", function(enabled, ctx)
 if enabled and setclipboard then setclipboard(game.JobId or "Không lấy được JobId") Notify.Show("✅ Đã sao chép JobId", 2) end
 Feature.Fire("Copy JobId", false)
end)

--========================= UI BUILDER ======================================
local function BuildUI()
 local PG = LP:WaitForChild("PlayerGui")
 local Gui = Instance.new("ScreenGui")
 Gui.Name = "MeizuHubUI"; Gui.ResetOnSpawn = false
 Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

 -- Background glow
 local glow1 = Instance.new("Frame")
 glow1.Name = "Glow1"; glow1.BackgroundTransparency = 0.92
 glow1.BackgroundColor3 = CONFIG.UI.Gold; glow1.Size = UDim2.new(400,0,400,0)
 glow1.Position = UDim2.new(-0.15,0,-0.15,0); glow1.CornerRadius = UDim.new(0.5,0)
 local glow2 = glow1:Clone(); glow2.Name = "Glow2"
 glow2.BackgroundColor3 = CONFIG.UI.Blue; glow2.Position = UDim2.new(0.65,0,0.75,0)
 glow2.Parent = Gui; glow1.Parent = Gui

 -- Main Card
 local Card = Instance.new("Frame")
 Card.Name = "MainCard"
 Card.Size = UDim2.fromOffset(CONFIG.UI.Width, CONFIG.UI.Height)
 Card.Position = UDim2.new(0.5, -CONFIG.UI.Width/2, 0.5, -CONFIG.UI.Height/2)
 Card.BackgroundColor3 = CONFIG.UI.CardBg
 Card.BackgroundTransparency = 0.08
 Card.BorderSizePixel = 1
 Card.BorderColor3 = CONFIG.UI.Stroke
 local UIC = Instance.new("UICorner"); UIC.CornerRadius = UDim.new(0, CONFIG.UI.Corner); UIC.Parent = Card
 local UIS = Instance.new("UIStroke"); UIS.Color = CONFIG.UI.Gold; UIS.Thickness = 1.2; UIS.Transparency = 0.65; UIS.Parent = Card
 Card.Parent = Gui

 -- Drag
 local dragToggle, dragInput, dragStart, startPos
 Card.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = true; dragStart = i.Position; startPos = Card.Position end end)
 Card.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = false end end)
 LP:GetMouse().InputChanged:Connect(function(i) if dragToggle then i.Changed:Connect(function() if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i.Position; Card.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (dragInput.X - dragStart.X), startPos.Y.Scale, startPos.Y.Offset + (dragInput.Y - dragStart.Y)) end end) end end)

 -- Badge
 local Badge = Instance.new("Frame")
 Badge.Size = UDim2.fromOffset(110,26); Badge.Position = UDim2.new(1, -120, 0, 12)
 Badge.BackgroundColor3 = CONFIG.UI.Gold; Badge.BackgroundTransparency = 0.85
 local BadgeCorner = Instance.new("UICorner"); BadgeCorner.CornerRadius = UDim.new(1,0); BadgeCorner.Parent = Badge
 local BadgeText = Instance.new("TextLabel")
 BadgeText.Size = UDim2.fromScale(1,1); BadgeText.BackgroundTransparency = 1
 BadgeText.Text = "MEIZU HUB"; BadgeText.Font = Enum.Font.GothamBold
 BadgeText.TextSize = 11; BadgeText.TextColor3 = Color3.fromRGB(20,20,20)
 BadgeText.Parent = Badge; Badge.Parent = Card

 -- Title
 local Title = Instance.new("TextLabel")
 Title.Size = UDim2.new(1,-20,0,36); Title.Position = UDim2.new(0,10,0,12)
 Title.BackgroundTransparency = 1; Title.Text = CONFIG.HubName
 Title.Font = Enum.Font.GothamBold; Title.TextSize = 22
 Title.TextColor3 = CONFIG.UI.Text; Title.TextXAlignment = Enum.TextXAlignment.Left
 Title.Parent = Card

 -- Sidebar container
 local Sidebar = Instance.new("Frame")
 Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.fromOffset(CONFIG.UI.SidebarWidth, 0)
 Sidebar.Position = UDim2.new(0,0,0,50); Sidebar.BackgroundTransparency = 1
 Sidebar.Parent = Card

 -- Content container
 local Content = Instance.new("Frame")
 Content.Name = "Content"; Content.Size = UDim2.new(1, -CONFIG.UI.SidebarWidth - 16, 1, -66)
 Content.Position = UDim2.new(0, CONFIG.UI.SidebarWidth + 8, 0, 58)
 Content.BackgroundTransparency = 1; Content.ClipsDescendants = true
 Content.Parent = Card

 -- Group tabs
 local groups = {"Player", "Farming", "Combat", "Quest", "Teleport", "Fruit", "ESP", "Server"}
 local pages = {}; local buttons = {}; local activeGroup = groups[1]

 for idx,grp in ipairs(groups) do
   local btn = Instance.new("TextButton")
   btn.Size = UDim2.new(1, -12, 0, 44)
   btn.Position = UDim2.new(0,6,0, 8 + (idx-1)*50)
   btn.BackgroundTransparency = 1
   btn.Text = grp; btn.Font = Enum.Font.GothamSemibold
   btn.TextSize = 12; btn.TextColor3 = CONFIG.UI.Muted
   btn.Parent = Sidebar

   local page = Instance.new("ScrollingFrame")
   page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1
   page.ScrollBarThickness = 3; page.ScrollBarColor3 = CONFIG.UI.Stroke
   page.Visible = grp == activeGroup; page.Parent = Content
   local pl = Instance.new("UIListLayout")
   pl.Padding = UDim.new(0,6); pl.HorizontalAlignment = Enum.HorizontalAlignment.Center; pl.Parent = page
   pages[grp] = page

   btn.MouseButton1Click:Connect(function()
     activeGroup = grp
     for g,p in pairs(pages) do p.Visible = (g==grp) end
     for _,b in ipairs(buttons) do b.TextColor3 = CONFIG.UI.Muted; b.BackgroundTransparency = 1 end
     btn.TextColor3 = CONFIG.UI.Gold
     local sel = btn:FindFirstChild("Sel") or Instance.new("Frame")
     sel.Name = "Sel"; sel.Size = UDim2.new(1,0,1,0); sel.Position = UDim2.new(0,0,0,0)
     sel.BackgroundColor3 = CONFIG.UI.Gold; sel.BackgroundTransparency = 0.88
     sel.Parent = btn; Instance.new("UICorner", sel).CornerRadius = UDim.new(0,12)
   end)

   table.insert(buttons, btn)
 end

 -- Populate features
 for name,def in pairs(Feature._r) do
   local page = pages[def.group]
   if page then
     local item = Instance.new("Frame")
     item.Size = UDim2.new(1,0,0,46)
     item.BackgroundColor3 = CONFIG.UI.Stroke
     item.BackgroundTransparency = 0.88
     Instance.new("UICorner", item).CornerRadius = UDim.new(0,12)
     item.Parent = page

     local lbl = Instance.new("TextLabel")
     lbl.Size = UDim2.new(1,-50,1,0); lbl.Position = UDim2.new(0,14,0,0)
     lbl.BackgroundTransparency = 1; lbl.Text = name
     lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13
     lbl.TextColor3 = CONFIG.UI.Text; lbl.TextXAlignment = Enum.TextXAlignment.Left
     lbl.Parent = item

     local toggle = Instance.new("TextButton")
     toggle.Name = "Toggle"; toggle.Size = UDim2.fromOffset(44,24)
     toggle.Position = UDim2.new(1,-56,0.5,-12)
     toggle.BackgroundColor3 = Color3.fromRGB(60,60,80)
     toggle.BackgroundTransparency = 0.4
     Instance.new("UICorner", toggle).CornerRadius = UDim.new(1,0)
     toggle.Text = ""; toggle.AutoLocalize = false
     toggle.Parent = item

     local dot = Instance.new("Frame")
     dot.Size = UDim2.fromOffset(18,18); dot.Position = UDim2.new(0,3,0.5,-9)
     dot.BackgroundColor3 = Color3.fromRGB(160,160,180)
     Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
     dot.Parent = toggle

     local isOn = Store.Get(name)
     local function Set(on)
       isOn = on
       if on then
         toggle.BackgroundColor3 = CONFIG.UI.Blue
         toggle.BackgroundTransparency = 0
         dot.Position = UDim2.new(1,-21,0.5,-9)
         dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
       else
         toggle.BackgroundColor3 = Color3.fromRGB(60,60,80)
         toggle.BackgroundTransparency = 0.4
         dot.Position = UDim2.new(0,3,0.5,-9)
         dot.BackgroundColor3 = Color3.fromRGB(160,160,180)
       end
     end
     Set(isOn)

     toggle.MouseButton1Click:Connect(function()
       Set(not isOn)
       Feature.Fire(name, isOn)
     end)
   end
 end

 -- Active first tab
 buttons[1].TextColor3 = CONFIG.UI.Gold
 local sel = Instance.new("Frame")
 sel.Name = "Sel"; sel.Size = UDim2.new(1,0,1,0); sel.BackgroundColor3 = CONFIG.UI.Gold
 sel.BackgroundTransparency = 0.88; Instance.new("UICorner", sel).CornerRadius = UDim.new(0,12)
 sel.Parent = buttons[1]

 Gui.Parent = PG

 -- Cleanup
 getgenv().MEIZU_CLEANUP = function() Gui:Destroy() Tasks = nil end
end

--========================= KEY GATE ========================================
local function ShowKeyGate()
 local PG = LP:WaitForChild("PlayerGui")
 local Gate = Instance.new("ScreenGui")
 Gate.Name = "MeizuKeyGate"; Gate.ResetOnSpawn = false

 local Glow1 = Instance.new("Frame")
 Glow1.BackgroundTransparency = 0.93; Glow1.BackgroundColor3 = CONFIG.UI.Gold
 Glow1.Size = UDim2.new(350,0,350,0); Glow1.Position = UDim2.new(-0.1,0,-0.15,0)
 Glow1.CornerRadius = UDim.new(0.5,0); Glow1.Parent = Gate

 local Glow2 = Glow1:Clone(); Glow2.BackgroundColor3 = CONFIG.UI.Blue
 Glow2.Position = UDim2.new(0.7,0,0.8,0); Glow2.Parent = Gate

 local Card = Instance.new("Frame")
 Card.Size = UDim2.fromOffset(320, 380)
 Card.Position = UDim2.new(0.5, -160, 0.5, -190)
 Card.BackgroundColor3 = CONFIG.UI.CardBg
 Card.BackgroundTransparency = 0.05
 Card.BorderSizePixel = 1; Card.BorderColor3 = CONFIG.UI.Stroke
 Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 24)
 Instance.new("UIStroke", Card).Color = CONFIG.UI.Gold
 Instance.new("UIStroke", Card).Thickness = 1.5
 Instance.new("UIStroke", Card).Transparency = 0.6
 Card.Parent = Gate

 local Badge = Instance.new("Frame")
 Badge.Size = UDim2.fromOffset(90,24); Badge.Position = UDim2.new(0.5,-45,0,16)
 Badge.BackgroundColor3 = CONFIG.UI.Gold; Badge.BackgroundTransparency = 0.85
 Instance.new("UICorner", Badge).CornerRadius = UDim.new(1,0)
 local BadgeText = Instance.new("TextLabel")
 BadgeText.Size = UDim2.fromScale(1,1); BadgeText.BackgroundTransparency = 1
 BadgeText.Text = "MEIZU · KEY"; BadgeText.Font = Enum.Font.GothamBold
 BadgeText.TextSize = 11; BadgeText.TextColor3 = Color3.fromRGB(20,20,20)
 BadgeText.Parent = Badge; Badge.Parent = Card

 local Title = Instance.new("TextLabel")
 Title.Size = UDim2.new(1,0,0,32); Title.Position = UDim2.new(0,0,0,52)
 Title.BackgroundTransparency = 1; Title.Text = "Xác minh Key"
 Title.Font = Enum.Font.GothamBold; Title.TextSize = 22
 Title.TextColor3 = CONFIG.UI.Text; Title.Parent = Card

 local Sub = Instance.new("TextLabel")
 Sub.Size = UDim2.new(1,-40,0,36); Sub.Position = UDim2.new(0,20,0,88)
 Sub.BackgroundTransparency = 1; Sub.Text = "Nhập key để sử dụng MEIZU HUB\nKey được liên kết với thiết bị của bạn"
 Sub.Font = Enum.Font.GothamRegular; Sub.TextSize = 12
 Sub.TextColor3 = CONFIG.UI.Muted; Sub.TextWrapped = true; Sub.Parent = Card

 local HWIDLabel = Instance.new("TextLabel")
 HWIDLabel.Size = UDim2.new(1,-40,0,20); HWIDLabel.Position = UDim2.new(0,20,0,130)
 HWIDLabel.BackgroundTransparency = 1; HWIDLabel.Text = "Thiết bị: "..KeySys.HWID():sub(1,26).."…"
 HWIDLabel.Font = Enum.Font.GothamRegular; HWIDLabel.TextSize = 10
 HWIDLabel.TextColor3 = CONFIG.UI.Muted; HWIDLabel.Parent = Card

 local InputBg = Instance.new("Frame")
 InputBg.Size = UDim2.new(1,-40,0,48); InputBg.Position = UDim2.new(0,20,0,158)
 InputBg.BackgroundColor3 = CONFIG.UI.CardBg
 InputBg.BackgroundTransparency = 0.02
 InputBg.BorderSizePixel = 1; InputBg.BorderColor3 = CONFIG.UI.Stroke
 Instance.new("UICorner", InputBg).CornerRadius = UDim.new(0,12)
 InputBg.Parent = Card

 local Input = Instance.new("TextBox")
 Input.Size = UDim2.new(1,-24,1,0); Input.Position = UDim2.new(0,12,0,0)
 Input.BackgroundTransparency = 1; Input.PlaceholderText = "Nhập key của bạn…"
 Input.Text = ""; Input.Font = Enum.Font.GothamMedium; Input.TextSize = 14
 Input.TextColor3 = CONFIG.UI.Text; Input.PlaceholderColor3 = CONFIG.UI.Muted
 Input.TextXAlignment = Enum.TextXAlignment.Left; Input.Parent = InputBg

 local Status = Instance.new("TextLabel")
 Status.Size = UDim2.new(1,-40,0,24); Status.Position = UDim2.new(0,20,0,214)
 Status.BackgroundTransparency = 1; Status.Text = "Đang chờ xác minh…"
 Status.Font = Enum.Font.GothamRegular; Status.TextSize = 12
 Status.TextColor3 = Color3.fromRGB(250,204,21); Status.Parent = Card

 local BtnVerify = Instance.new("TextButton")
 BtnVerify.Size = UDim2.new(1,-40,0,48); BtnVerify.Position = UDim2.new(0,20,0,246)
 BtnVerify.BackgroundColor3 = CONFIG.UI.Gold
 BtnVerify.BackgroundTransparency = 0.1
 BtnVerify.AutoLocalize = false
 Instance.new("UICorner", BtnVerify).CornerRadius = UDim.new(0,14)
 local BtnText = Instance.new("TextLabel")
 BtnText.Size = UDim2.fromScale(1,1); BtnText.BackgroundTransparency = 1
 BtnText.Text = "Xác minh Key"; BtnText.Font = Enum.Font.GothamBold
 BtnText.TextSize = 14; BtnText.TextColor3 = Color3.fromRGB(20,20,20)
 BtnText.Parent = BtnVerify; BtnVerify.Parent = Card

 local BtnGetKey = Instance.new("TextButton")
 BtnGetKey.Size = UDim2.new(1,-40,0,40); BtnGetKey.Position = UDim2.new(0,20,0,304)
 BtnGetKey.BackgroundTransparency = 1
 BtnGetKey.AutoLocalize = false
 local BtnGetKeyText = Instance.new("TextLabel")
 BtnGetKeyText.Size = UDim2.fromScale(1,1); BtnGetKeyText.BackgroundTransparency = 1
 BtnGetKeyText.Text = "Lấy Key mới"; BtnGetKeyText.Font = Enum.Font.GothamMedium
 BtnGetKeyText.TextSize = 12; BtnGetKeyText.TextColor3 = CONFIG.UI.Blue
 BtnGetKeyText.Parent = BtnGetKey; BtnGetKey.Parent = Card

 local function SetStatus(text, color) Status.Text = text; Status.TextColor3 = color end

 local function Unlock()
   Gate:Destroy()
   BuildUI()
   Feature.Restore()
 end

 -- Check cached key
 local cached = KeySys.Cached()
 if cached and #cached > 10 then
   SetStatus("Đang kiểm tra key đã
