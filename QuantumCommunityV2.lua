
--[[
    QUANTUM ONYX
    BLACKOUT EDITION | CRYSTAL ULTIMATE
    Roblox Studio LocalScript
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local Config = {
    Name = "Quantum Onyx",
    IdleTimeout = 60,
    Theme = {
        Background = Color3.fromRGB(10, 8, 16),
        Panel = Color3.fromRGB(18, 13, 28),
        Element = Color3.fromRGB(28, 20, 42),
        Purple = Color3.fromRGB(160, 80, 255),
        PurpleDark = Color3.fromRGB(95, 40, 160),
        Text = Color3.fromRGB(240, 230, 255),
        Muted = Color3.fromRGB(160, 145, 180),
    }
}

local T = Config.Theme

--==================================================
-- CLEANUP
--==================================================

local Connections = {}

local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function Cleanup()
    for _, connection in ipairs(Connections) do
        connection:Disconnect()
    end
    table.clear(Connections)
end

--==================================================
-- UI HELPERS
--==================================================

local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function Stroke(parent, color, transparency)
    return Create("UIStroke", {
        Color = color or T.Purple,
        Transparency = transparency or 0.4,
        Thickness = 1
    }, parent)
end

local function Animate(object, properties, duration)
    TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quint),
        properties
    ):Play()
end

local function Button(parent, text)
    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = T.Element,
        Text = text,
        TextColor3 = T.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        AutoButtonColor = false
    }, parent)

    Corner(button, 8)
    Stroke(button, T.Purple, 0.75)

    Connect(button.MouseEnter, function()
        Animate(button, {BackgroundColor3 = T.PurpleDark})
    end)

    Connect(button.MouseLeave, function()
        Animate(button, {BackgroundColor3 = T.Element})
    end)

    return button
end

local function Label(parent, text, size)
    return Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, size or 25),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = T.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, parent)
end

--==================================================
-- SCREEN GUI
--==================================================

local Screen = Create("ScreenGui", {
    Name = "QuantumOnyx",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local Main = Create("Frame", {
    Size = UDim2.fromOffset(560, 390),
    Position = UDim2.new(0.5, -280, 0.5, -195),
    BackgroundColor3 = T.Background,
    BorderSizePixel = 0
}, Screen)

Corner(Main, 14)
Stroke(Main, T.Purple, 0.25)

Create("UISizeConstraint", {
    MaxSize = Vector2.new(560, 390),
    MinSize = Vector2.new(320, 300)
}, Main)

-- Responsive scaling
local Scale = Create("UIScale", {}, Main)

local function UpdateScale()
    local viewport = workspace.CurrentCamera.ViewportSize
    Scale.Scale = math.min(
        1,
        viewport.X / 600,
        viewport.Y / 430
    )
end

UpdateScale()

Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), UpdateScale)

--==================================================
-- HEADER
--==================================================

local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 54),
    BackgroundColor3 = T.Panel,
    BorderSizePixel = 0
}, Main)

Corner(Header, 14)

Label(Header, "  ◈ QUANTUM ONYX", 54).TextSize = 17

local Close = Create("TextButton", {
    Size = UDim2.fromOffset(40, 40),
    Position = UDim2.new(1, -46, 0, 7),
    BackgroundColor3 = T.Element,
    Text = "×",
    TextColor3 = T.Text,
    TextSize = 24,
    Font = Enum.Font.Gotham
}, Header)

Corner(Close, 8)

Connect(Close.Activated, function()
    Screen:Destroy()
    Cleanup()
end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Create("Frame", {
    Position = UDim2.fromOffset(12, 66),
    Size = UDim2.new(0, 145, 1, -78),
    BackgroundTransparency = 1
}, Main)

Create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
}, Sidebar)

--==================================================
-- CONTENT
--==================================================

local Content = Create("Frame", {
    Position = UDim2.fromOffset(169, 66),
    Size = UDim2.new(1, -181, 1, -78),
    BackgroundColor3 = T.Panel,
    BorderSizePixel = 0
}, Main)

Corner(Content, 10)

local Pages = {}
local CurrentPage

local function CreatePage(name)
    local page = Create("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Purple,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, Content)

    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    Pages[name] = page
    return page
end

local function SwitchPage(name)
    if CurrentPage then
        CurrentPage.Visible = false
    end

    CurrentPage = Pages[name]
    CurrentPage.Visible = true
end

local function AddTab(name)
    local tab = Button(Sidebar, name)
    tab.LayoutOrder = #Pages + 1

    Connect(tab.Activated, function()
        SwitchPage(name)
    end)

    return CreatePage(name)
end

--==================================================
-- HOME TAB
--==================================================

local Home = AddTab("Home")

Label(Home, "Welcome to Blackout Edition", 35)

Label(Home, "Crystal Ultimate UI initialized.", 25)

local Status = Label(Home, "SYSTEM  •  ONLINE", 25)
Status.TextColor3 = T.Purple

--==================================================
-- SETTINGS TAB
--==================================================

local Settings = AddTab("Settings")

Label(Settings, "Interface Settings", 30)

local UIEnabled = true

local Toggle = Button(Settings, "Interface Glow  •  ON")

Connect(Toggle.Activated, function()
    UIEnabled = not UIEnabled

    Toggle.Text = "Interface Glow  •  "
        .. (UIEnabled and "ON" or "OFF")

    for _, item in ipairs(Main:GetDescendants()) do
        if item:IsA("UIStroke") then
            item.Enabled = UIEnabled
        end
    end
end)

--==================================================
-- CONSOLE TAB
--==================================================

local Console = AddTab("Console")

Label(Console, "SYSTEM LOG", 30)

local LogBox = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 160),
    BackgroundColor3 = Color3.fromRGB(7, 5, 12),
    TextColor3 = T.Purple,
    Text = "",
    Font = Enum.Font.Code,
    TextSize = 12,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
}, Console)

Corner(LogBox, 8)

local Logs = {}

local function Log(message)
    table.insert(Logs, os.date("%H:%M:%S") .. " > " .. tostring(message))

    while #Logs > 15 do
        table.remove(Logs, 1)
    end

    LogBox.Text = table.concat(Logs, "\n")
end

Button(Console, "Clear Console").Activated:Connect(function()
    table.clear(Logs)
    LogBox.Text = ""
end)

Log("Quantum Onyx initialized")
Log("Blackout Edition loaded")

--==================================================
-- NOTIFICATIONS
--==================================================

local function Notify(message)
    local notification = Create("TextLabel", {
        Size = UDim2.fromOffset(260, 45),
        Position = UDim2.new(1, -280, 1, -65),
        BackgroundColor3 = T.Panel,
        Text = tostring(message),
        TextColor3 = T.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium
    }, Screen)

    Corner(notification, 8)
    Stroke(notification, T.Purple, 0.2)

    notification.BackgroundTransparency = 1
    notification.TextTransparency = 1

    Animate(notification, {
        BackgroundTransparency = 0,
        TextTransparency = 0
    })

    task.delay(3, function()
        if notification.Parent then
            Animate(notification, {
                BackgroundTransparency = 1,
                TextTransparency = 1
            }, 0.25)

            task.wait(0.3)
            notification:Destroy()
        end
    end)
end

--==================================================
-- OLED IDLE SAVER
--==================================================

local Saver = Create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    Visible = false,
    ZIndex = 100
}, Screen)

local SaverText = Create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "QUANTUM ONYX\n\nBLACKOUT",
    TextColor3 = T.PurpleDark,
    Font = Enum.Font.Gotham,
    TextSize = 24,
    ZIndex = 101
}, Saver)

local LastInput = os.clock()

local function ResetIdle()
    LastInput = os.clock()

    if Saver.Visible then
        Saver.Visible = false
    end
end

Connect(UserInputService.InputBegan, ResetIdle)
Connect(UserInputService.InputChanged, ResetIdle)

task.spawn(function()
    while Screen.Parent do
        task.wait(1)

        if os.clock() - LastInput >= Config.IdleTimeout then
            Saver.Visible = true
        end
    end
end)

--==================================================
-- DRAG WINDOW
--==================================================

local Dragging = false
local DragStart
local StartPosition

Connect(Header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position
    end
end)

Connect(UserInputService.InputChanged, function(input)
    if Dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local delta = input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + delta.Y
        )
    end
end)

Connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = false
    end
end)

--==================================================
-- START
--==================================================

SwitchPage("Home")
Notify("BLACKOUT EDITION ONLINE")
Log("UI ready")
