-- QUANTUM // NEON UI
-- LocalScript for Roblox Studio / an experience you own.
-- UI, output console, module placeholders, mobile-friendly controls.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local C = {
    bg = Color3.fromRGB(7, 10, 17),
    panel = Color3.fromRGB(13, 19, 30),
    panel2 = Color3.fromRGB(18, 27, 41),
    cyan = Color3.fromRGB(0, 235, 255),
    violet = Color3.fromRGB(154, 90, 255),
    pink = Color3.fromRGB(255, 55, 155),
    text = Color3.fromRGB(225, 245, 255),
    muted = Color3.fromRGB(115, 145, 165),
    green = Color3.fromRGB(70, 255, 170),
    yellow = Color3.fromRGB(255, 205, 80),
    red = Color3.fromRGB(255, 80, 100),
}

local function corner(obj, radius)
    local u = Instance.new("UICorner")
    u.CornerRadius = UDim.new(0, radius or 8)
    u.Parent = obj
    return u
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.cyan
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.35
    s.Parent = obj
    return s
end

local function label(parent, text, size, color, font)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 12
    l.TextColor3 = color or C.text
    l.Font = font or Enum.Font.Code
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local gui = Instance.new("ScreenGui")
gui.Name = "QUANTUM_NEON"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 40
gui.Parent = pg

local main = Instance.new("Frame")
main.Name = "Window"
main.AnchorPoint = Vector2.new(0.5,0.5)
main.Position = UDim2.fromScale(0.5,0.5)
main.Size = UDim2.new(0.92,0,0,510)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Parent = gui
corner(main,14)
stroke(main,C.cyan,1.3,0.2)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(280,390)
sizeConstraint.MaxSize = Vector2.new(520,650)
sizeConstraint.Parent = main

local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,58)
top.BackgroundColor3 = C.panel
top.BorderSizePixel = 0
top.Parent = main
corner(top,14)

local title = label(top,"◆  QUANTUM",18,C.cyan,Enum.Font.GothamBlack)
title.Position = UDim2.fromOffset(16,7)
title.Size = UDim2.new(0.65,0,0,24)

local subtitle = label(top,"NEURAL INTERFACE  //  v2.7",9,C.muted)
subtitle.Position = UDim2.fromOffset(18,32)
subtitle.Size = UDim2.new(0.7,0,0,15)

local live = label(top,"● ONLINE",10,C.green,Enum.Font.Code)
live.TextXAlignment = Enum.TextXAlignment.Right
live.Position = UDim2.new(1,-110,0,18)
live.Size = UDim2.fromOffset(94,22)

local accent = Instance.new("Frame")
accent.Size = UDim2.new(1,0,0,2)
accent.Position = UDim2.fromOffset(0,57)
accent.BackgroundColor3 = C.cyan
accent.BorderSizePixel = 0
accent.Parent = top

local nav = Instance.new("Frame")
nav.Position = UDim2.fromOffset(12,72)
nav.Size = UDim2.new(1,-24,0,36)
nav.BackgroundTransparency = 1
nav.Parent = main

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.Padding = UDim.new(0,6)
navLayout.Parent = nav

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(12,116)
content.Size = UDim2.new(1,-24,1,-128)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}
local selected = "MODULES"
local navButtons = {}

local function newPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.fromScale(1,1)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = C.violet
    p.CanvasSize = UDim2.new(0,0,0,0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = p
    pages[name] = p
    return p
end

local function switchPage(name)
    selected = name
    for k,p in pairs(pages) do p.Visible = (k == name) end
    for k,b in pairs(navButtons) do
        b.BackgroundColor3 = (k == name) and C.panel2 or C.panel
        b.TextColor3 = (k == name) and C.cyan or C.muted
    end
end

for _,name in ipairs({"MODULES","OUTPUT","SETTINGS"}) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1/3,-5,1,0)
    b.BackgroundColor3 = C.panel
    b.BorderSizePixel = 0
    b.Text = name
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = C.muted
    b.Parent = nav
    corner(b,7)
    stroke(b,C.violet,0.7,0.75)
    b.Activated:Connect(function() switchPage(name) end)
    navButtons[name] = b
end

local modulePage = newPage("MODULES")
local outputPage = newPage("OUTPUT")
local settingsPage = newPage("SETTINGS")

-- Output console: capped log history to avoid unbounded memory growth.
local logLines = {}
local outputText
local MAX_LOGS = 100

local function log(level, message)
    local timestamp = os.date("%H:%M:%S")
    local entry = string.format("[%s] [%s] %s",timestamp,level,string.gsub(tostring(message),"\n"," "))
    table.insert(logLines,entry)
    if #logLines > MAX_LOGS then table.remove(logLines,1) end
    if outputText then outputText.Text = table.concat(logLines,"\n") end
end

local function section(parent, titleText, detail)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,58)
    card.BackgroundColor3 = C.panel
    card.BorderSizePixel = 0
    card.Parent = parent
    corner(card,9)
    stroke(card,C.violet,0.8,0.75)
    local t = label(card,titleText,12,C.cyan,Enum.Font.GothamBold)
    t.Position = UDim2.fromOffset(12,8)
    t.Size = UDim2.new(1,-24,0,18)
    local d = label(card,detail or "",9,C.muted)
    d.Position = UDim2.fromOffset(12,30)
    d.Size = UDim2.new(1,-24,0,16)
    return card
end

local states = {}
local function addModule(name, description)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,66)
    card.BackgroundColor3 = C.panel
    card.BorderSizePixel = 0
    card.Parent = modulePage
    corner(card,9)
    stroke(card,C.cyan,0.7,0.82)

    local nameLabel = label(card,"▸ "..name,12,C.text,Enum.Font.GothamBold)
    nameLabel.Position = UDim2.fromOffset(12,9)
    nameLabel.Size = UDim2.new(0.62,0,0,20)
    local desc = label(card,description,9,C.muted)
    desc.Position = UDim2.fromOffset(12,34)
    desc.Size = UDim2.new(0.68,0,0,16)

    local btn = Instance.new("TextButton")
    btn.AnchorPoint = Vector2.new(1,0.5)
    btn.Position = UDim2.new(1,-12,0.5,0)
    btn.Size = UDim2.fromOffset(74,30)
    btn.BackgroundColor3 = C.panel2
    btn.BorderSizePixel = 0
    btn.Text = "OFF"
    btn.TextColor3 = C.muted
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = card
    corner(btn,7)
    stroke(btn,C.violet,1,0.45)

    states[name] = false
    btn.Activated:Connect(function()
        states[name] = not states[name]
        btn.Text = states[name] and "ON" or "OFF"
        btn.TextColor3 = states[name] and C.green or C.muted
        btn.BackgroundColor3 = states[name] and Color3.fromRGB(15,45,45) or C.panel2
        log("INFO",name.." toggled "..(states[name] and "ON" or "OFF").." (placeholder)")
    end)
end

section(modulePage,"SYSTEM MODULES","Toggle UI demo • connect game-owned logic")
addModule("Katakuri","Boss module placeholder")
addModule("Fruit","Collectible module placeholder")
addModule("Pirate Raid","Raid module placeholder")
addModule("Quest Flow","Quest module placeholder")
addModule("Performance","Metrics placeholder")

local outCard = Instance.new("Frame")
outCard.Size = UDim2.new(1,0,0,270)
outCard.BackgroundColor3 = Color3.fromRGB(4,8,12)
outCard.BorderSizePixel = 0
outCard.Parent = outputPage
corner(outCard,9)
stroke(outCard,C.cyan,1,0.55)

local outHead = label(outCard,"▰  LIVE OUTPUT / DIAGNOSTICS",11,C.cyan,Enum.Font.GothamBold)
outHead.Position = UDim2.fromOffset(12,10)
outHead.Size = UDim2.new(1,-24,0,20)

outputText = Instance.new("TextLabel")
outputText.Position = UDim2.fromOffset(12,38)
outputText.Size = UDim2.new(1,-24,1,-82)
outputText.BackgroundTransparency = 1
outputText.Text = "[BOOT] Quantum UI initialized\n[INFO] Output console ready"
outputText.TextColor3 = C.green
outputText.Font = Enum.Font.Code
outputText.TextSize = 10
outputText.TextXAlignment = Enum.TextXAlignment.Left
outputText.TextYAlignment = Enum.TextYAlignment.Top
outputText.TextWrapped = true
outputText.Parent = outCard

local clear = Instance.new("TextButton")
clear.Position = UDim2.new(1,-92,1,-34)
clear.Size = UDim2.fromOffset(80,24)
clear.BackgroundColor3 = C.panel2
clear.Text = "CLEAR LOG"
clear.TextColor3 = C.cyan
clear.TextSize = 9
clear.Font = Enum.Font.GothamBold
clear.Parent = outCard
corner(clear,6)
clear.Activated:Connect(function()
    table.clear(logLines)
    outputText.Text = "[INFO] Log cleared"
end)

section(settingsPage,"DISPLAY","OLED-friendly idle overlay")
local saverRow = Instance.new("Frame")
saverRow.Size = UDim2.new(1,0,0,64)
saverRow.BackgroundColor3 = C.panel
saverRow.BorderSizePixel = 0
saverRow.Parent = settingsPage
corner(saverRow,9)
local saverLabel = label(saverRow,"Idle screensaver",12,C.text,Enum.Font.GothamBold)
saverLabel.Position = UDim2.fromOffset(12,10)
saverLabel.Size = UDim2.new(0.65,0,0,20)
local saverHint = label(saverRow,"Activates after 90 seconds",9,C.muted)
saverHint.Position = UDim2.fromOffset(12,35)
saverHint.Size = UDim2.new(0.7,0,0,16)

local saverToggle = Instance.new("TextButton")
saverToggle.Position = UDim2.new(1,-86,0,17)
saverToggle.Size = UDim2.fromOffset(72,30)
saverToggle.BackgroundColor3 = C.panel2
saverToggle.Text = "ON"
saverToggle.TextColor3 = C.green
saverToggle.Font = Enum.Font.GothamBold
saverToggle.TextSize = 10
saverToggle.Parent = saverRow
corner(saverToggle,7)

-- Saver overlay: pure black + one dim moving pixel.
local overlay = Instance.new("Frame")
overlay.Name = "OLED_IDLE"
overlay.Size = UDim2.fromScale(1,1)
overlay.BackgroundColor3 = Color3.new(0,0,0)
overlay.BorderSizePixel = 0
overlay.Visible = false
overlay.ZIndex = 100
overlay.Parent = gui

local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(2,2)
dot.BackgroundColor3 = Color3.fromRGB(22,22,22)
dot.BorderSizePixel = 0
dot.ZIndex = 101
dot.Parent = overlay

local saverEnabled = true
local idleAfter = 90
local lastInput = os.clock()
local saverOn = false

local function setSaver(on)
    saverOn = on
    overlay.Visible = on
    log("INFO",on and "Screensaver activated" or "Screensaver dismissed")
end

local function inputActivity()
    lastInput = os.clock()
    if saverOn then setSaver(false) end
end
UIS.InputBegan:Connect(inputActivity)
UIS.InputChanged:Connect(inputActivity)

saverToggle.Activated:Connect(function()
    saverEnabled = not saverEnabled
    saverToggle.Text = saverEnabled and "ON" or "OFF"
    saverToggle.TextColor3 = saverEnabled and C.green or C.red
    if not saverEnabled and saverOn then setSaver(false) end
    log("INFO","Screensaver "..(saverEnabled and "enabled" or "disabled"))
end)

-- Drag window (mouse + touch) without a permanent input polling loop.
local dragging, dragInput, dragStart, startPosition
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        dragInput = input
    end
end)
top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale,startPosition.X.Offset+delta.X,
                                  startPosition.Y.Scale,startPosition.Y.Offset+delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local heartbeat
heartbeat = RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if saverEnabled and not saverOn and now-lastInput >= idleAfter then
        setSaver(true)
    end
    if saverOn then
        dot.Position = UDim2.fromScale(
            0.1 + 0.8*((math.sin(now*0.08)+1)/2),
            0.1 + 0.8*((math.sin(now*0.06+1.2)+1)/2)
        )
    end
end)

switchPage("MODULES")
log("INFO","Neon interface ready")
log("WARN","Game automation modules are placeholders")

gui.Destroying:Connect(function()
    if heartbeat then heartbeat:Disconnect() end
end)

-- Small output helper for your own module callbacks:
_G.QuantumLog = log
