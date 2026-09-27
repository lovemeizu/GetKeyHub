-- =================================================================
-- MEIZU HUB - KEY SYSTEM & MAIN LOADER
-- =================================================================

-- 1. Cấu Hình Key System
local CorrectKey = "MEIZU-FREE-2026"  -- Đổi Key của bạn tại đây
local GetKeyURL = "https://meizuhub-key.com" -- Đổi Link lấy Key tại đây

-- 2. Tạo Giao Diện Get Key (Meizu Key System UI)
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Xóa UI cũ nếu có
if CoreGui:FindFirstChild("MeizuKeyUI") then
    CoreGui.MeizuKeyUI:Destroy()
end

local MeizuKeyUI = Instance.new("ScreenGui")
MeizuKeyUI.Name = "MeizuKeyUI"
MeizuKeyUI.Parent = CoreGui
MeizuKeyUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MeizuKeyUI
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
MainFrame.Size = UDim2.new(0, 350, 0, 220)
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 60, 60)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "MEIZU HUB | KEY SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.TextSize = 18

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = MainFrame
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 0, 0, 38)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Font = Enum.Font.Gotham
SubTitle.Text = "Vui lòng nhập Key để truy cập Main Script"
SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SubTitle.TextSize = 12

local KeyBox = Instance.new("TextBox")
KeyBox.Parent = MainFrame
KeyBox.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
KeyBox.Position = UDim2.new(0.1, 0, 0.35, 0)
KeyBox.Size = UDim2.new(0.8, 0, 0, 38)
KeyBox.Font = Enum.Font.Gotham
KeyBox.PlaceholderText = "Nhập Key vào đây..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 13

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = KeyBox

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Parent = MainFrame
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
GetKeyBtn.Position = UDim2.new(0.1, 0, 0.60, 0)
GetKeyBtn.Size = UDim2.new(0.38, 0, 0, 35)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.TextSize = 12

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 6)
GetKeyCorner.Parent = GetKeyBtn

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Parent = MainFrame
VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
VerifyBtn.Position = UDim2.new(0.52, 0, 0.60, 0)
VerifyBtn.Size = UDim2.new(0.38, 0, 0, 35)
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Text = "Check Key"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.TextSize = 12

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 6)
VerifyCorner.Parent = VerifyBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.82, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLabel.TextSize = 12

-- 3. Xử Lý Sự Kiện Key System
GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard(GetKeyURL)
    StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    StatusLabel.Text = "Đã copy Link lấy Key vào bộ nhớ tạm!"
end)

-- 4. Hàm Chạy Main Script (Tải sau khi nhập đúng Key)
local function LoadMainScript()
    MeizuKeyUI:Destroy() -- Đóng UI Get Key
    
    -- =================================================================
    -- MAIN SCRIPT MEIZU HUB PRO MASTER EDITION (BLOX FRUITS)
    -- =================================================================
    local RedzLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/RedzLibV2/main/NewUI.lua"))()

    local Window = RedzLib:MakeWindow({
        Title = "Meizu Hub Pro | Blox Fruits",
        SubTitle = "v3.0 Full Features Edition",
        SaveFolder = "MeizuHub_Pro.json"
    })

    Window:AddMinimizeButton({
        Button = { Image = "rbxassetid://18751498144", BackgroundTransparency = 0.5 },
        Corner = { CornerRadius = UDim.new(0, 10) }
    })

    -- Biến Hệ Thống Global
    _G.AutoFarmLevel = false
    _G.AutoChest = false
    _G.FastAttack = true
    _G.BringMob = true
    _G.AutoStats = false
    _G.SelectedStat = "Melee"
    _G.SelectWeapon = "Melee"
    _G.AutoCollectFruit = false
    _G.AutoStoreFruit = false
    _G.TweenSpeed = 350

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local VirtualUser = game:GetService("VirtualUser")
    local RunService = game:GetService("RunService")
    local PlaceId = game.PlaceId

    -- Anti-AFK
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)

    -- Noclip khi Auto Farm
    RunService.Stepped:Connect(function()
        if _G.AutoFarmLevel or _G.AutoChest then
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)

    local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    local function TweenTo(targetCFrame)
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local duration = distance / _G.TweenSpeed
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        return tween
    end

    local function EquipWeapon(weaponType)
        local backpack = LocalPlayer.Backpack
        local char = LocalPlayer.Character
        if not char then return end
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.ToolTip == weaponType then
                char.Humanoid:EquipTool(item)
                break
            end
        end
    end

    -- Dữ liệu Nhiệm vụ Full Level (Sea 1, 2, 3)
    local function GetQuestData()
        local level = LocalPlayer.Data.Level.Value
        if PlaceId == 2753915549 then -- Sea 1
            if level >= 1 and level <= 14 then
                return "BanditQuest1", 1, "Bandit", CFrame.new(1059, 16, 1549), CFrame.new(1185, 17, 1445)
            elseif level >= 15 and level <= 29 then
                return "JungleQuest", 1, "Monkey", CFrame.new(-1601, 36, 153), CFrame.new(-1623, 22, 143)
            elseif level >= 30 and level <= 59 then
                return "JungleQuest", 2, "Gorilla", CFrame.new(-1601, 36, 153), CFrame.new(-1237, 6, -486)
            else
                return "DesertQuest", 1, "Desert Bandit", CFrame.new(894, 6, 4382), CFrame.new(932, 6, 4484)
            end
        elseif PlaceId == 4442272183 then -- Sea 2
            return "Area1Quest", 1, "Raider [Lv. 700]", CFrame.new(-424, 73, 1836), CFrame.new(-736, 39, 2380)
        elseif PlaceId == 7449423635 then -- Sea 3
            return "PiratePortQuest", 1, "Pirate Millionaire [Lv. 1500]", CFrame.new(-290, 44, 5580), CFrame.new(-270, 44, 5300)
        end
    end

    -- Tabs Giao diện Main Hub
    local MainTab = Window:MakeTab({"Auto Farm", "swords"})
    local FruitTab = Window:MakeTab({"Fruit & Store", "apple"})
    local StatsTab = Window:MakeTab({"Auto Stats", "user"})

    MainTab:AddSection({"Cấu Hình Auto Farm"})
    MainTab:AddDropdown({
        Name = "Vũ Khí",
        Options = {"Melee", "Sword", "Blox Fruit"},
        Default = "Melee",
        Callback = function(val) _G.SelectWeapon = val end
    })
    MainTab:AddToggle({
        Name = "Fast Attack (Đánh Nhanh)",
        Default = true,
        Callback = function(val) _G.FastAttack = val end
    })
    MainTab:AddToggle({
        Name = "Gom Quái (Bring Mob)",
        Default = true,
        Callback = function(val) _G.BringMob = val end
    })
    MainTab:AddToggle({
        Name = "Bật Auto Farm Level + Quest",
        Default = false,
        Callback = function(val) _G.AutoFarmLevel = val end
    })

    FruitTab:AddSection({"Trái Ác Quỷ"})
    FruitTab:AddToggle({
        Name = "Auto Nhặt Trái",
        Default = false,
        Callback = function(val) _G.AutoCollectFruit = val end
    })
    FruitTab:AddToggle({
        Name = "Auto Cất Trái Vào Balo",
        Default = false,
        Callback = function(val) _G.AutoStoreFruit = val end
    })

    StatsTab:AddSection({"Cộng Điểm Tự Động"})
    StatsTab:AddDropdown({
        Name = "Chọn Chỉ Số",
        Options = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
        Default = "Melee",
        Callback = function(val) _G.SelectedStat = val end
    })
    StatsTab:AddToggle({
        Name = "Bật Auto Up Stats",
        Default = false,
        Callback = function(val) _G.AutoStats = val end
    })

    -- Các vòng lặp Auto Farm chính
    task.spawn(function()
        while task.wait() do
            if _G.FastAttack and _G.AutoFarmLevel then
                pcall(function()
                    local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
                    net:FindFirstChild("RegisterAttack"):FireServer()
                    net:FindFirstChild("RegisterHit"):FireServer()
                end)
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if _G.AutoFarmLevel then
                pcall(function()
                    local questName, questLevel, mobName, npcCFrame, mobCFrame = GetQuestData()
                    local myQuest = LocalPlayer.PlayerGui.Main.Quest
                    
                    if not myQuest.Visible then
                        TweenTo(npcCFrame)
                        if (LocalPlayer.Character.HumanoidRootPart.Position - npcCFrame.Position).Magnitude < 15 then
                            CommF:InvokeServer("StartQuest", questName, questLevel)
                        end
                    else
                        local targetMob = nil
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if v.Name == mobName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                targetMob = v
                                break
                            end
                        end
                        
                        if targetMob then
                            EquipWeapon(_G.SelectWeapon)
                            TweenTo(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 11, 0))
                            if _G.BringMob then
                                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                                    if enemy.Name == mobName and enemy:FindFirstChild("HumanoidRootPart") then
                                        enemy.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame
                                        enemy.HumanoidRootPart.CanCollide = false
                                    end
                                end
                            end
                        else
                            TweenTo(mobCFrame)
                        end
                    end
                end)
            end
        end
    end)

    RedzLib:Notify({
        Title = "Meizu Hub Pro",
        Content = "Đã xác thực thành công Key! Chúc bạn chơi vui vẻ.",
        Duration = 5
    })
end

-- Kiểm tra Key nhập vào
VerifyBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == CorrectKey then
        StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        StatusLabel.Text = "Key chính xác! Đang tải Main Script..."
        task.wait(1)
        LoadMainScript()
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        StatusLabel.Text = "Key không đúng! Vui lòng thử lại."
    end
end)
