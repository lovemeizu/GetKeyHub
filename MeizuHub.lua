--// MEIZUHUB - LIQUID GLASS UI
--// UI ONLY - no game automation

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GETKEY_URL = "https://lovemeizu.github.io/GetKeyHub/getkey.html"

--==================================================
-- CLEAN OLD UI
--==================================================

local old = PlayerGui:FindFirstChild("MeizuHub")
if old then
    old:Destroy()
end

--==================================================
-- HELPERS
--==================================================

local function Create(class, properties, parent)
    local obj = Instance.new(class)

    for property, value in pairs(properties or {}) do
        obj[property] = value
    end

    obj.Parent = parent
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, parent)
end

local function Stroke(parent, color, transparency, thickness)
    return Create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1
    }, parent)
end

local function Gradient(parent, colors, rotation)
    return Create("UIGradient", {
        Color = ColorSequence.new(colors),
        Rotation = rotation or 0
    }, parent)
end

local function Tween(object, info, properties)
    return TweenService:Create(object, info, properties)
end

--==================================================
-- ROOT
--==================================================

local ScreenGui = Create("ScreenGui", {
    Name = "MeizuHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

--==================================================
-- BACKGROUND
--==================================================

local Background = Create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(7, 7, 10),
    BorderSizePixel = 0
}, ScreenGui)

-- subtle black overlay
Create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    ZIndex = 1
}, Background)

--==================================================
-- LIQUID AMBIENT LIGHTS
--==================================================

local AmbientLeft = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.08, 0.15),
    Size = UDim2.fromOffset(330, 330),
    BackgroundColor3 = Color3.fromRGB(25, 105, 255),
    BackgroundTransparency = 0.90,
    BorderSizePixel = 0,
    ZIndex = 2
}, Background)

Corner(AmbientLeft, 170)

local AmbientLeft2 = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.15, 0.20),
    Size = UDim2.fromOffset(190, 190),
    BackgroundColor3 = Color3.fromRGB(40, 140, 255),
    BackgroundTransparency = 0.93,
    BorderSizePixel = 0,
    ZIndex = 3
}, Background)

Corner(AmbientLeft2, 100)

local AmbientRight = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.92, 0.86),
    Size = UDim2.fromOffset(350, 350),
    BackgroundColor3 = Color3.fromRGB(0, 190, 255),
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
    ZIndex = 2
}, Background)

Corner(AmbientRight, 180)

local AmbientRight2 = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.84, 0.78),
    Size = UDim2.fromOffset(190, 190),
    BackgroundColor3 = Color3.fromRGB(50, 120, 255),
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    ZIndex = 3
}, Background)

Corner(AmbientRight2, 100)

--==================================================
-- MAIN GLASS CARD
--==================================================

local Card = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.56),
    Size = UDim2.new(0, 430, 0, 510),
    BackgroundColor3 = Color3.fromRGB(20, 22, 29),
    BackgroundTransparency = 0.16,
    BorderSizePixel = 0,
    ZIndex = 10
}, Background)

Corner(Card, 27)

Stroke(
    Card,
    Color3.fromRGB(255, 255, 255),
    0.82,
    1
)

-- subtle blue glass tint
local GlassTint = Create("Frame", {
    Position = UDim2.fromOffset(1, 1),
    Size = UDim2.new(1, -2, 1, -2),
    BackgroundColor3 = Color3.fromRGB(80, 130, 255),
    BackgroundTransparency = 0.975,
    BorderSizePixel = 0,
    ZIndex = 11
}, Card)

Corner(GlassTint, 26)

--==================================================
-- GLASS TOP REFLECTION
--==================================================

local Shine = Create("Frame", {
    Position = UDim2.new(-0.65, 0, -0.15, 0),
    Size = UDim2.new(0.20, 0, 1.30, 0),
    Rotation = 13,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    ZIndex = 30
}, Card)

Corner(Shine, 40)

task.spawn(function()
    while ScreenGui.Parent do

        Shine.Position = UDim2.new(-0.65, 0, -0.15, 0)

        local animation = Tween(
            Shine,
            TweenInfo.new(
                2.7,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Position = UDim2.new(1.25, 0, -0.15, 0)
            }
        )

        animation:Play()
        animation.Completed:Wait()

        task.wait(1.7)
    end
end)

--==================================================
-- CONTENT
--==================================================

local Content = Create("Frame", {
    Position = UDim2.fromOffset(30, 27),
    Size = UDim2.new(1, -60, 1, -54),
    BackgroundTransparency = 1,
    ZIndex = 40
}, Card)

--==================================================
-- BADGE
--==================================================

local Badge = Create("Frame", {
    Size = UDim2.fromOffset(128, 30),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.93,
    BorderSizePixel = 0,
    ZIndex = 41
}, Content)

Corner(Badge, 15)

Stroke(
    Badge,
    Color3.fromRGB(255, 255, 255),
    0.89,
    1
)

local BadgeDot = Create("Frame", {
    Position = UDim2.fromOffset(11, 11),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = Color3.fromRGB(59, 130, 246),
    BorderSizePixel = 0,
    ZIndex = 42
}, Badge)

Corner(BadgeDot, 8)

Create("TextLabel", {
    Position = UDim2.fromOffset(27, 0),
    Size = UDim2.new(1, -30, 1, 0),
    BackgroundTransparency = 1,
    Text = "ONE-TIME KEY",
    TextColor3 = Color3.fromRGB(185, 205, 235),
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 42
}, Badge)

--==================================================
-- TITLE
--==================================================

Create("TextLabel", {
    Position = UDim2.fromOffset(0, 48),
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundTransparency = 1,
    Text = "MeizuHub",
    TextColor3 = Color3.fromRGB(242, 247, 255),
    TextSize = 32,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 42
}, Content)

--==================================================
-- SUBTITLE
--==================================================

Create("TextLabel", {
    Position = UDim2.fromOffset(0, 92),
    Size = UDim2.new(1, 0, 0, 43),
    BackgroundTransparency = 1,
    Text = "Blue Liquid Glass interface.\nĐồng bộ với giao diện Tạo Key Free.",
    TextColor3 = Color3.fromRGB(145, 160, 185),
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 42
}, Content)

--==================================================
-- STATUS
--==================================================

local Status = Create("TextLabel", {
    Position = UDim2.fromOffset(0, 143),
    Size = UDim2.new(1, 0, 0, 22),
    BackgroundTransparency = 1,
    Text = "●  Ready",
    TextColor3 = Color3.fromRGB(90, 220, 150),
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 42
}, Content)

--==================================================
-- KEY GLASS PANEL
--==================================================

local KeyPanel = Create("Frame", {
    Position = UDim2.fromOffset(0, 180),
    Size = UDim2.new(1, 0, 0, 116),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.955,
    BorderSizePixel = 0,
    ZIndex = 41
}, Content)

Corner(KeyPanel, 18)

Stroke(
    KeyPanel,
    Color3.fromRGB(255, 255, 255),
    0.90,
    1
)

Create("TextLabel", {
    Position = UDim2.fromOffset(15, 11),
    Size = UDim2.new(1, -30, 0, 18),
    BackgroundTransparency = 1,
    Text = "KEY STATUS",
    TextColor3 = Color3.fromRGB(115, 140, 175),
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 42
}, KeyPanel)

local KeyText = Create("TextLabel", {
    Position = UDim2.fromOffset(15, 35),
    Size = UDim2.new(1, -30, 0, 25),
    BackgroundTransparency = 1,
    Text = "No key entered",
    TextColor3 = Color3.fromRGB(225, 235, 250),
    TextSize = 13,
    Font = Enum.Font.GothamMedium,
    TextTruncate = Enum.TextTruncate.AtEnd,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 42
}, KeyPanel)

local ResultText = Create("TextLabel", {
    Position = UDim2.fromOffset(15, 69),
    Size = UDim2.new(1, -30, 0, 25),
    BackgroundTransparency = 1,
    Text = "Open Get Key Free to continue.",
    TextColor3 = Color3.fromRGB(150, 165, 190),
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 42
}, KeyPanel)

--==================================================
-- PRIMARY BUTTON
--==================================================

local GetKey = Create("TextButton", {
    Position = UDim2.fromOffset(0, 314),
    Size = UDim2.new(1, 0, 0, 49),
    BackgroundColor3 = Color3.fromRGB(59, 130, 246),
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "Tạo / Lấy Key Free",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    ZIndex = 42
}, Content)

Corner(GetKey, 15)

Gradient(GetKey, {
    ColorSequenceKeypoint.new(
        0,
        Color3.fromRGB(59, 130, 246)
    ),

    ColorSequenceKeypoint.new(
        1,
        Color3.fromRGB(37, 99, 235)
    )
}, 0)

Stroke(
    GetKey,
    Color3.fromRGB(120, 180, 255),
    0.72,
    1
)

--==================================================
-- VERIFY BUTTON
--==================================================

local Verify = Create("TextButton", {
    Position = UDim2.fromOffset(0, 373),
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "Xác thực Key",
    TextColor3 = Color3.fromRGB(195, 210, 235),
    TextSize = 13,
    Font = Enum.Font.GothamMedium,
    ZIndex = 42
}, Content)

Corner(Verify, 14)

Stroke(
    Verify,
    Color3.fromRGB(255, 255, 255),
    0.88,
    1
)

--==================================================
-- FOOTER
--==================================================

Create("TextLabel", {
    Position = UDim2.fromOffset(0, 427),
    Size = UDim2.new(1, 0, 0, 22),
    BackgroundTransparency = 1,
    Text = "make by LoveMeizu  •  Liquid Glass",
    TextColor3 = Color3.fromRGB(95, 110, 135),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 42
}, Content)

--==================================================
-- BUTTON ANIMATION
--==================================================

local function ButtonPress(button)
    local oldSize = button.Size

    Tween(
        button,
        TweenInfo.new(
            0.08,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.new(
                oldSize.X.Scale,
                oldSize.X.Offset,
                oldSize.Y.Scale,
                oldSize.Y.Offset - 3
            )
        }
    ):Play()

    task.delay(0.08, function()
        if button.Parent then
            Tween(
                button,
                TweenInfo.new(
                    0.12,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = oldSize
                }
            ):Play()
        end
    end)
end

--==================================================
-- GET KEY
--==================================================

GetKey.MouseButton1Click:Connect(function()

    ButtonPress(GetKey)

    Status.Text = "●  Get Key page ready"
    Status.TextColor3 = Color3.fromRGB(250, 190, 80)

    KeyText.Text = "Waiting for key..."
    ResultText.Text = "Get Key URL copied to clipboard."

    if setclipboard then
        pcall(function()
            setclipboard(GETKEY_URL)
        end)
    end

end)

--==================================================
-- VERIFY PLACEHOLDER
--==================================================

Verify.MouseButton1Click:Connect(function()

    ButtonPress(Verify)

    Status.Text = "●  Verification ready"
    Status.TextColor3 = Color3.fromRGB(100, 180, 255)

    ResultText.Text =
        "Connect your existing Key API here."

end)

--==================================================
-- HOVER EFFECT
--==================================================

GetKey.MouseEnter:Connect(function()

    Tween(
        GetKey,
        TweenInfo.new(0.15),
        {
            BackgroundTransparency = 0.08
        }
    ):Play()

end)

GetKey.MouseLeave:Connect(function()

    Tween(
        GetKey,
        TweenInfo.new(0.15),
        {
            BackgroundTransparency = 0
        }
    ):Play()

end)

Verify.MouseEnter:Connect(function()

    Tween(
        Verify,
        TweenInfo.new(0.15),
        {
            BackgroundTransparency = 0.89
        }
    ):Play()

end)

Verify.MouseLeave:Connect(function()

    Tween(
        Verify,
        TweenInfo.new(0.15),
        {
            BackgroundTransparency = 0.94
        }
    ):Play()

end)

--==================================================
-- AMBIENT ANIMATION
--==================================================

task.spawn(function()

    while ScreenGui.Parent do

        Tween(
            AmbientLeft,
            TweenInfo.new(
                4,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Position = UDim2.fromScale(0.14, 0.18),
                Size = UDim2.fromOffset(350, 350)
            }
        ):Play()

        Tween(
            AmbientRight,
            TweenInfo.new(
                4,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Position = UDim2.fromScale(0.86, 0.82),
                Size = UDim2.fromOffset(370, 370)
            }
        ):Play()

        task.wait(4)

        Tween(
            AmbientLeft,
            TweenInfo.new(
                4,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Position = UDim2.fromScale(0.07, 0.11),
                Size = UDim2.fromOffset(300, 300)
            }
        ):Play()

        Tween(
            AmbientRight,
            TweenInfo.new(
                4,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Position = UDim2.fromScale(0.93, 0.89),
                Size = UDim2.fromOffset(330, 330)
            }
        ):Play()

        task.wait(4)

    end

end)

--==================================================
-- ENTRANCE ANIMATION
--==================================================

Card.Position = UDim2.fromScale(0.5, 0.61)
Card.BackgroundTransparency = 1

Tween(
    Card,
    TweenInfo.new(
        0.65,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    ),
    {
        Position = UDim2.fromScale(0.5, 0.56),
        BackgroundTransparency = 0.16
    }
):Play()

--==================================================
-- DRAG SYSTEM - PC + MOBILE
--==================================================

local Dragging = false
local DragStart
local StartPosition

Card.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = input.Position
        StartPosition = Card.Position

    end

end)

Card.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not Dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local Delta = input.Position - DragStart

    Card.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )

end)

--==================================================
-- RETURN
--==================================================

return {
    Name = "MeizuHub",
    Theme = "Blue Liquid Glass",
    GUI = ScreenGui
}
