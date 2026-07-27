-- ====== 创建UI ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ====== 设置变量 ======
local Settings = {
    HoldTime = 0,
    Distance = 25,
    HitboxEnabled = false,
    HitboxSize = 10,
    WhitelistEnabled = false,
    TeleportEnabled = false,
}

local Whitelist = {}
local affectedHeads = {}
local frameCount = 0

-- ====== 固定传送点数据 ======
local function GetTeleportData()
    return {
        {n = "🚗 车辆经销商", p = Vector3.new(3719.9501953125, 3.018573522567749, -333.3118591308594)},
        {n = "🏥 医院", p = Vector3.new(3980.091064453125, 2.876060724258423, -138.79454040527344)},
        {n = "👮 警察局", p = Vector3.new(3364.273193359375, 3.9188079834, -394.7233581542969)},
        {n = "🔧 圣奥里修车店", p = Vector3.new(2782.46875, 2.630995750427246, -418.59930419921875)},
        {n = "🏦 圣奥里银行", p = Vector3.new(3134.05419921875, 6.116048336029053, -171.36976623535156)},
        {n = "👗 圣奥里服装店", p = Vector3.new(3617.91259765625, 3.1072206497192383, -452.8206481933594)},
        {n = "🏠 圣奥里平民重生", p = Vector3.new(3741.114990234375, 3.720573663711548, -438.1059875488281)},
        {n = "⛵ 圣奥里码头", p = Vector3.new(4527.65625, -23.968238830566406, -280.59356689453125)},
        {n = "🍽️ 圣奥里餐饮店", p = Vector3.new(3182.416748046875, 3.01859188079834, 426.5179138183594)},
        {n = "🚒 消防部门", p = Vector3.new(3578.676025390625, 8.408823013305664, 579.6567993164062)},
        {n = "🐾 宠物店", p = Vector3.new(3678.237305, 3.017920, 693.114624)},
        {n = "⛵ 圣奥里大码头", p = Vector3.new(2736.307617, 2.630299, -1120.333008)},
        {n = "🌉 圣奥里海滩桥下(消星点)", p = Vector3.new(3964.504395, -25.068211, -854.057251)},
        {n = "🛒 大景超级超市", p = Vector3.new(3936.582764, 3.038293, 1136.326416)},
        {n = "📦 转镜中心", p = Vector3.new(4152.919922, 2.631675, 941.446045)},
        {n = "🛣️ 道路服务", p = Vector3.new(4271.332520, 2.628108, 1200.086914)},
        {n = "🍽️ 大景餐饮店", p = Vector3.new(4476.997559, 3.037825, 906.802979)},
        {n = "📦 送货中心(美团外卖)", p = Vector3.new(4399.419434, 3.038999, 1609.455933)},
        {n = "🚗 大景卖车店", p = Vector3.new(3434.377441, 42.931786, 2687.997070)},
        {n = "🍽️ 莱斯维尔餐饮店", p = Vector3.new(753.757812, 3.039824, 998.132996)},
        {n = "👗 莱斯维尔服装店", p = Vector3.new(820.745117, 2.766988, 1047.445679)},
        {n = "🏛️ 莱斯维尔自由广场", p = Vector3.new(926.523376, 2.630995, 865.764771)},
        {n = "⛵ 莱斯维尔码头(游艇)", p = Vector3.new(947.840210, -22.529087, 1216.085693)},
        {n = "⛽ 米尔顿左上加油站", p = Vector3.new(1145.635742, 2.630916, -864.273682)},
        {n = "⛽ 米尔顿右下加油站", p = Vector3.new(-1646.802734, 2.630164, 1812.894653)},
        {n = "⛽ 米尔顿上方加油站", p = Vector3.new(-900.701660, 2.630927, 1124.683105)},
        {n = "🏘️ 米尔顿居民区", p = Vector3.new(-528.565552, 2.630996, 1331.981689)},
        {n = "🏦 约克镇小银行", p = Vector3.new(-668.217224, 2.630995, -65.347839)},
        {n = "🔧 约克镇修车厂", p = Vector3.new(-407.163025, 3.076807, -6.098211)},
        {n = "🔫 约克镇枪店", p = Vector3.new(-323.869293, 3.037825, 37.149670)},
        {n = "🏠 约克镇重生点", p = Vector3.new(-219.560318, 3.039824, -85.725433)},
        {n = "🏪 约克镇当铺", p = Vector3.new(-168.513733, 3.039000, -106.926529)},
        {n = "🚗 约克镇卫星车", p = Vector3.new(-302.093567, 3.037825, -167.621017)},
        {n = "📍 约克镇中心点", p = Vector3.new(-275.995209, 2.630996, -139.985352)},
        {n = "🖤 黑色市场", p = Vector3.new(1038.969849, -22.732950, 895.430237)},
        {n = "🎣 鱼夫码头", p = Vector3.new(-50.147552, -24.555279, 1462.145996)},
        {n = "🌾 农场", p = Vector3.new(-1268.339233, 2.572412, 2560.060303)},
        {n = "🏛️ 监狱门口", p = Vector3.new(-1697.931885, 2.630666, 1284.567383)},
        {n = "🏛️ 监狱广场", p = Vector3.new(-1600.602417, 2.631028, 1268.060059)},
        {n = "🏔️ 代尔山", p = Vector3.new(847.062988, 194.115753, -326.212708)},
        {n = "💧 水帘洞(消星点)", p = Vector3.new(3040.956055, 109.688538, 2711.069336)},
        {n = "🌉 大桥", p = Vector3.new(949.014954, 25.215754, 2897.654785)},
        {n = "🗺️ 地图右下(消星点)", p = Vector3.new(-1651.385010, 2.414712, 3225.278320)},
        {n = "⛽ 下部加油站", p = Vector3.new(2270.378174, 2.630927, 154.161484)},
        {n = "🎮 游戏厅", p = Vector3.new(2934.893799, 2.956458, 1693.660034)},
        {n = "⛳ 高尔夫", p = Vector3.new(2280.767090, 3.037836, 1982.357300)},
        {n = "🔧 修船厂", p = Vector3.new(4096.405273, -30.401447, 2865.045166)},
    }
end

local FIXED_TELEPORTS = GetTeleportData()

-- ====== 延迟加载函数 ======
local function DelayedTask(fn, delay)
    local d = delay or 2
    task.spawn(function()
        task.wait(d)
        fn()
    end)
end

-- ====== 传送功能 ======
local function TeleportTo(pos)
    if not Settings.TeleportEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        root.CFrame = CFrame.new(pos)
    end)
end

-- ====== 创建主GUI ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UtilityHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ====== 悬浮窗按钮 ======
local floatingBtn = Instance.new("TextButton")
floatingBtn.Size = UDim2.new(0, 50, 0, 50)
floatingBtn.Position = UDim2.new(0.02, 0, 0.5, -25)
floatingBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
floatingBtn.BackgroundTransparency = 0.3
floatingBtn.Text = "📌"
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.TextSize = 24
floatingBtn.Font = Enum.Font.GothamBold
floatingBtn.Parent = screenGui

local floatBorder = Instance.new("UICorner")
floatBorder.CornerRadius = UDim.new(1, 0)
floatBorder.Parent = floatingBtn

-- ====== 主框架 ======
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 310)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -155)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.3
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local border = Instance.new("UICorner")
border.CornerRadius = UDim.new(0, 4)
border.Parent = mainFrame

-- 标题
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleBar.BackgroundTransparency = 0.3
titleBar.Parent = mainFrame

local titleBorder = Instance.new("UICorner")
titleBorder.CornerRadius = UDim.new(0, 4)
titleBorder.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "SANA HUB [稳定版]"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- ====== 悬浮窗开关功能 ======
local floatOpen = true
floatingBtn.MouseButton1Click:Connect(function()
    floatOpen = not floatOpen
    mainFrame.Visible = floatOpen
    if floatOpen then
        floatingBtn.Text = "📌"
        floatingBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    else
        floatingBtn.Text = "✕"
        floatingBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- ====== 滚动容器 ======
local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Size = UDim2.new(1, -20, 1, -45)
scrollContainer.Position = UDim2.new(0, 10, 0, 40)
scrollContainer.BackgroundTransparency = 1
scrollContainer.ScrollBarThickness = 6
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 2000)
scrollContainer.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollContainer

-- ====== 辅助函数 ======
local function CreateSection(text)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, 0, 0, 22)
    section.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    section.BackgroundTransparency = 0.3
    section.Text = " " .. text
    section.TextColor3 = Color3.fromRGB(200, 200, 255)
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.TextSize = 12
    section.Font = Enum.Font.GothamBold
    section.Parent = scrollContainer
    
    local secBorder = Instance.new("UICorner")
    secBorder.CornerRadius = UDim.new(0, 3)
    secBorder.Parent = section
end

local function CreateSlider(name, min, max, default, suffix, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scrollContainer
    
    local fBorder = Instance.new("UICorner")
    fBorder.CornerRadius = UDim.new(0, 4)
    fBorder.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default) .. suffix
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 16)
    slider.Position = UDim2.new(0, 10, 0, 24)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    slider.Parent = frame
    
    local sBorder = Instance.new("UICorner")
    sBorder.CornerRadius = UDim.new(0, 3)
    sBorder.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    fill.Parent = slider
    
    local fFill = Instance.new("UICorner")
    fFill.CornerRadius = UDim.new(0, 3)
    fFill.Parent = fill
    
    local value = default
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local x = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = math.round((min + (max - min) * x) / 1) * 1
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            label.Text = name .. ": " .. tostring(value) .. suffix
            callback(value)
        end
    end)
    
    slider.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local x = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = math.round((min + (max - min) * x) / 1) * 1
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            label.Text = name .. ": " .. tostring(value) .. suffix
            callback(value)
        end
    end)
end

local function CreateToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scrollContainer
    
    local fBorder = Instance.new("UICorner")
    fBorder.CornerRadius = UDim.new(0, 4)
    fBorder.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 25, 0, 16)
    toggle.Position = UDim2.new(1, -35, 0, 7)
    toggle.BackgroundColor3 = default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    toggle.Parent = frame
    
    local tBorder = Instance.new("UICorner")
    tBorder.CornerRadius = UDim.new(0, 8)
    tBorder.Parent = toggle
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = default and UDim2.new(0, 11, 0, 2) or UDim2.new(0, 2, 0, 2)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.Parent = toggle
    
    local iBorder = Instance.new("UICorner")
    iBorder.CornerRadius = UDim.new(0, 6)
    iBorder.Parent = indicator
    
    local state = default
    
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
            indicator.Position = state and UDim2.new(0, 11, 0, 2) or UDim2.new(0, 2, 0, 2)
            callback(state)
        end
    end)
end

-- ====== 创建固定传送点按钮 ======
local function CreateFixedTeleportPoint(name, position)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scrollContainer
    
    local fBorder = Instance.new("UICorner")
    fBorder.CornerRadius = UDim.new(0, 4)
    fBorder.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 200, 100)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = frame
    
    clickBtn.MouseButton1Click:Connect(function()
        TeleportTo(position)
    end)
end

-- ====== 加载传送点 ======
local function LoadTeleports()
    for _, data in ipairs(FIXED_TELEPORTS) do
        CreateFixedTeleportPoint(data.n, data.p)
    end
end

-- ====== 构建UI内容 ======
CreateSection("交互设置")

CreateSlider("按住时间", 0, 10, 0, "秒", function(value)
    Settings.HoldTime = value
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then 
            obj.HoldDuration = value 
        end
    end
end)

CreateSlider("触发距离", 5, 150, 25, "单位", function(value)
    Settings.Distance = value
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then 
            obj.MaxActivationDistance = value 
        end
    end
end)

CreateSection("碰撞箱扩展")

CreateToggle("启用头部碰撞箱", false, function(value)
    Settings.HitboxEnabled = value
    if value then
        ApplyHitbox()
    else
        ResetHitbox()
    end
end)

CreateSlider("头部大小", 5, 40, 10, "单位", function(value)
    Settings.HitboxSize = value
    if Settings.HitboxEnabled then
        ApplyHitbox()
    end
end)

CreateToggle("好友检测 (白名单)", false, function(value)
    Settings.WhitelistEnabled = value
    if value then
        UpdateWhitelist()
    end
end)

CreateSection("📍 固定传送点")

CreateToggle("启用传送", false, function(value)
    Settings.TeleportEnabled = value
end)

-- ====== 延迟2秒加载传送点 ======
DelayedTask(LoadTeleports, 2)

-- ====== 碰撞箱功能 ======
function ApplyHitbox()
    if not Settings.HitboxEnabled then return end
    
    local players = Players:GetPlayers()
    local newAffected = {}
    
    for i = 1, #players do
        local player = players[i]
        if player ~= LocalPlayer and player.Character then
            if Settings.WhitelistEnabled and Whitelist[player.UserId] then
                continue
            end
            
            local char = player.Character
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if hum and hum.Health > 0 and head then
                if head.Size.X ~= Settings.HitboxSize then
                    head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                end
                
                if head.Transparency ~= 1 then
                    head.Transparency = 1
                end
                
                if head.Color ~= Color3.fromRGB(255, 215, 0) then
                    head.Color = Color3.fromRGB(255, 215, 0)
                end
                
                if head.Material ~= Enum.Material.Neon then
                    head.Material = Enum.Material.Neon
                end
                
                if head.CanCollide ~= false then
                    head.CanCollide = false
                end
                
                newAffected[head] = true
            end
        end
    end
    
    for head, _ in pairs(affectedHeads) do
        if not newAffected[head] and head and head.Parent then
            head.Size = Vector3.new(2, 1, 1)
            head.Transparency = 0
            head.CanCollide = true
            head.Color = Color3.new(1, 1, 1)
            head.Material = Enum.Material.Plastic
        end
    end
    
    affectedHeads = newAffected
end

function ResetHitbox()
    for head, _ in pairs(affectedHeads) do
        if head and head.Parent then
            head.Size = Vector3.new(2, 1, 1)
            head.Transparency = 0
            head.CanCollide = true
            head.Color = Color3.new(1, 1, 1)
            head.Material = Enum.Material.Plastic
        end
    end
    affectedHeads = {}
end

-- ====== 好友检测功能 ======
function UpdateWhitelist()
    Whitelist = {}
    local players = Players:GetPlayers()
    
    for i = 1, #players do
        local player = players[i]
        if player ~= LocalPlayer then
            pcall(function()
                if player:IsFriendsWith(LocalPlayer.UserId) then
                    Whitelist[player.UserId] = true
                end
            end)
        end
    end
end

-- ====== 玩家事件 ======
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if Settings.HitboxEnabled then
            task.wait(0.5)
            ApplyHitbox()
        end
    end)
    
    if Settings.WhitelistEnabled then
        UpdateWhitelist()
    end
end)

-- ====== 每帧更新 ======
RunService.RenderStepped:Connect(function()
    if Settings.HitboxEnabled then
        frameCount = frameCount + 1
        if frameCount % 3 == 0 then
            ApplyHitbox()
        end
    end
end)

-- ====== 定期更新好友列表 ======
task.spawn(function()
    while true do
        task.wait(10)
        if Settings.WhitelistEnabled then
            UpdateWhitelist()
        end
    end
end)

-- ====== INS键隐藏/显示 ======
local visible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        visible = not visible
        mainFrame.Visible = visible
    end
end)

-- ====== 扫描现有交互 ======
local function ScanPrompts()
    local descendants = workspace:GetDescendants()
    for i = 1, #descendants do
        local obj = descendants[i]
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = Settings.HoldTime
            obj.MaxActivationDistance = Settings.Distance
        end
    end
end

ScanPrompts()

workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = Settings.HoldTime
        obj.MaxActivationDistance = Settings.Distance
    end
end)

print("综合工具已加载！按 INS 键切换菜单")