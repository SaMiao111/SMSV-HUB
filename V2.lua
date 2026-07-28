-- ====== 1. 加载 Obsidian 库 ======
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Toggles = Library.Toggles
local Options = Library.Options

-- ====== 判断是否为PE端 ======
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- ====== 2. 核心功能逻辑 ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    HoldTime = 0,
    Distance = 25,
    HitboxEnabled = false,
    HitboxSize = 10,
    WhitelistEnabled = false,
    TeleportEnabled = false,
    NoclipEnabled = false,
}

local Whitelist = {}
local affectedHeads = {}
local frameCount = 0
local isDestroyed = false
local connections = {}
local noclipConnections = {}

-- ====== 传送点数据 ======
local function GetTeleportData()
    return {
        {n = "车辆经销商", p = Vector3.new(3719.9501953125, 3.018573522567749, -333.3118591308594), region = "圣奥里"},
        {n = "医院", p = Vector3.new(3980.091064453125, 2.876060724258423, -138.79454040527344), region = "圣奥里"},
        {n = "警察局", p = Vector3.new(3364.273193359375, 3.9188079834, -394.7233581542969), region = "圣奥里"},
        {n = "圣奥里修车店", p = Vector3.new(2782.46875, 2.630995750427246, -418.59930419921875), region = "圣奥里"},
        {n = "圣奥里银行", p = Vector3.new(3134.05419921875, 6.116048336029053, -171.36976623535156), region = "圣奥里"},
        {n = "圣奥里服装店", p = Vector3.new(3617.91259765625, 3.1072206497192383, -452.8206481933594), region = "圣奥里"},
        {n = "圣奥里平民重生", p = Vector3.new(3741.114990234375, 3.720573663711548, -438.1059875488281), region = "圣奥里"},
        {n = "圣奥里码头", p = Vector3.new(4527.65625, -23.968238830566406, -280.59356689453125), region = "圣奥里"},
        {n = "圣奥里餐饮店", p = Vector3.new(3182.416748046875, 3.01859188079834, 426.5179138183594), region = "圣奥里"},
        {n = "消防部门", p = Vector3.new(3578.676025390625, 8.408823013305664, 579.6567993164062), region = "圣奥里"},
        {n = "宠物店", p = Vector3.new(3678.237305, 3.017920, 693.114624), region = "圣奥里"},
        {n = "圣奥里大码头", p = Vector3.new(2736.307617, 2.630299, -1120.333008), region = "圣奥里"},
        {n = "圣奥里海滩桥下(消星点)", p = Vector3.new(3964.504395, -25.068211, -854.057251), region = "圣奥里"},
        {n = "大景超级超市", p = Vector3.new(3936.582764, 3.038293, 1136.326416), region = "大景"},
        {n = "转镜中心", p = Vector3.new(4152.919922, 2.631675, 941.446045), region = "大景"},
        {n = "道路服务", p = Vector3.new(4271.332520, 2.628108, 1200.086914), region = "大景"},
        {n = "大景餐饮店", p = Vector3.new(4476.997559, 3.037825, 906.802979), region = "大景"},
        {n = "送货中心(美团外卖)", p = Vector3.new(4399.419434, 3.038999, 1609.455933), region = "大景"},
        {n = "大景卖车店", p = Vector3.new(3434.377441, 42.931786, 2687.997070), region = "大景"},
        {n = "莱斯维尔餐饮店", p = Vector3.new(753.757812, 3.039824, 998.132996), region = "莱斯维尔"},
        {n = "莱斯维尔服装店", p = Vector3.new(820.745117, 2.766988, 1047.445679), region = "莱斯维尔"},
        {n = "莱斯维尔自由广场", p = Vector3.new(926.523376, 2.630995, 865.764771), region = "莱斯维尔"},
        {n = "莱斯维尔码头(游艇)", p = Vector3.new(947.840210, -22.529087, 1216.085693), region = "莱斯维尔"},
        {n = "米尔顿左上加油站", p = Vector3.new(1145.635742, 2.630916, -864.273682), region = "米尔顿"},
        {n = "米尔顿右下加油站", p = Vector3.new(-1646.802734, 2.630164, 1812.894653), region = "米尔顿"},
        {n = "米尔顿上方加油站", p = Vector3.new(-900.701660, 2.630927, 1124.683105), region = "米尔顿"},
        {n = "米尔顿居民区", p = Vector3.new(-528.565552, 2.630996, 1331.981689), region = "米尔顿"},
        {n = "约克镇小银行", p = Vector3.new(-668.217224, 2.630995, -65.347839), region = "约克镇"},
        {n = "约克镇修车厂", p = Vector3.new(-407.163025, 3.076807, -6.098211), region = "约克镇"},
        {n = "约克镇枪店", p = Vector3.new(-323.869293, 3.037825, 37.149670), region = "约克镇"},
        {n = "约克镇重生点", p = Vector3.new(-219.560318, 3.039824, -85.725433), region = "约克镇"},
        {n = "约克镇当铺", p = Vector3.new(-168.513733, 3.039000, -106.926529), region = "约克镇"},
        {n = "约克镇卫星车", p = Vector3.new(-302.093567, 3.037825, -167.621017), region = "约克镇"},
        {n = "约克镇中心点", p = Vector3.new(-275.995209, 2.630996, -139.985352), region = "约克镇"},
        {n = "黑色市场", p = Vector3.new(1038.969849, -22.732950, 895.430237), region = "其他"},
        {n = "鱼夫码头", p = Vector3.new(-50.147552, -24.555279, 1462.145996), region = "其他"},
        {n = "农场", p = Vector3.new(-1268.339233, 2.572412, 2560.060303), region = "其他"},
        {n = "监狱门口", p = Vector3.new(-1697.931885, 2.630666, 1284.567383), region = "其他"},
        {n = "监狱广场", p = Vector3.new(-1600.602417, 2.631028, 1268.060059), region = "其他"},
        {n = "代尔山", p = Vector3.new(847.062988, 194.115753, -326.212708), region = "其他"},
        {n = "水帘洞(消星点)", p = Vector3.new(3040.956055, 109.688538, 2711.069336), region = "其他"},
        {n = "大桥", p = Vector3.new(949.014954, 25.215754, 2897.654785), region = "其他"},
        {n = "地图右下(消星点)", p = Vector3.new(-1651.385010, 2.414712, 3225.278320), region = "其他"},
        {n = "下部加油站", p = Vector3.new(2270.378174, 2.630927, 154.161484), region = "其他"},
        {n = "游戏厅", p = Vector3.new(2934.893799, 2.956458, 1693.660034), region = "其他"},
        {n = "高尔夫", p = Vector3.new(2280.767090, 3.037836, 1982.357300), region = "其他"},
        {n = "修船厂", p = Vector3.new(4096.405273, -30.401447, 2865.045166), region = "其他"},
    }
end
local FIXED_TELEPORTS = GetTeleportData()

local function TeleportTo(pos)
    if not Settings.TeleportEnabled or isDestroyed then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        root.CFrame = CFrame.new(pos)
    end)
end

local function ApplyNoclip()
    if isDestroyed or not Settings.NoclipEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function ToggleNoclip(state)
    Settings.NoclipEnabled = state
    if state then
        ApplyNoclip()
    else
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

function ApplyHitbox()
    if isDestroyed or not Settings.HitboxEnabled then return end
    local players = Players:GetPlayers()
    local newAffected = {}
    for i = 1, #players do
        local player = players[i]
        if player ~= LocalPlayer and player.Character then
            if Settings.WhitelistEnabled and Whitelist[player.UserId] then
            else
                local char = player.Character
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and head then
                    head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    head.Transparency = 1
                    head.Color = Color3.fromRGB(255, 215, 0)
                    head.Material = Enum.Material.Neon
                    head.CanCollide = false
                    newAffected[head] = true
                end
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

function UpdateWhitelist()
    if isDestroyed then return end
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

-- ====== 3. 创建 Obsidian UI ======
local Window = Library:CreateWindow({
    Title = "SANA HUB",
    Footer = "稳定版 - Obsidian UI",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
    MobileButtonsSide = "Right",
})

local Tabs = {
    Main = Window:AddTab("主要", "target"),
    Teleports = Window:AddTab("传送点", "map-pin"),
    Settings = Window:AddTab("设置", "settings"),
}

-- ====== 主要标签页 ======
local mainLeftGroup = Tabs.Main:AddLeftGroupbox("交互设置", "hand")
local mainRightGroup = Tabs.Main:AddRightGroupbox("碰撞箱扩展", "target")

mainLeftGroup:AddSlider("HoldTime", {
    Text = "按住时间",
    Default = 0,
    Min = 0,
    Max = 10,
    Rounding = 0,
    Suffix = "秒",
    Callback = function(value)
        Settings.HoldTime = value
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = value
            end
        end
    end
})

mainLeftGroup:AddSlider("Distance", {
    Text = "触发距离",
    Default = 25,
    Min = 5,
    Max = 150,
    Rounding = 0,
    Suffix = "单位",
    Callback = function(value)
        Settings.Distance = value
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.MaxActivationDistance = value
            end
        end
    end
})

mainLeftGroup:AddDivider()
mainLeftGroup:AddToggle("NoclipToggle", {
    Text = "启用人物穿墙",
    Default = false,
    Callback = function(value)
        ToggleNoclip(value)
    end
})

mainRightGroup:AddToggle("HitboxToggle", {
    Text = "启用头部碰撞箱",
    Default = false,
    Callback = function(value)
        Settings.HitboxEnabled = value
        if value then ApplyHitbox() else ResetHitbox() end
    end
})

mainRightGroup:AddSlider("HitboxSize", {
    Text = "头部大小",
    Default = 10,
    Min = 5,
    Max = 40,
    Rounding = 0,
    Suffix = "单位",
    Callback = function(value)
        Settings.HitboxSize = value
        if Settings.HitboxEnabled then ApplyHitbox() end
    end
})

mainRightGroup:AddToggle("WhitelistToggle", {
    Text = "好友检测 (白名单)",
    Default = false,
    Callback = function(value)
        Settings.WhitelistEnabled = value
        if value then UpdateWhitelist() end
    end
})

-- ====== 传送点标签页 ======
local teleTab = Tabs.Teleports

local teleLeftGroup = teleTab:AddLeftGroupbox("传送控制", "navigation")
teleLeftGroup:AddToggle("TeleportToggle", {
    Text = "启用传送",
    Default = false,
    Callback = function(value)
        Settings.TeleportEnabled = value
    end
})

local function CreateRegionGroups()
    local regions = {}
    for _, data in ipairs(FIXED_TELEPORTS) do
        if not regions[data.region] then
            regions[data.region] = {}
        end
        table.insert(regions[data.region], data)
    end

    local regionNames = {}
    for name, _ in pairs(regions) do
        table.insert(regionNames, name)
    end
    table.sort(regionNames)

    for i = 1, #regionNames, 2 do
        local region1 = regionNames[i]
        local region2 = regionNames[i + 1]

        if region1 then
            local group = teleTab:AddLeftGroupbox(region1, "map-pin")
            for _, data in ipairs(regions[region1]) do
                group:AddButton({
                    Text = data.n,
                    Func = function()
                        TeleportTo(data.p)
                        Library:Notify({
                            Title = "传送",
                            Description = "正在传送至: " .. data.n,
                            Time = 2,
                        })
                    end,
                })
            end
        end

        if region2 then
            local group = teleTab:AddRightGroupbox(region2, "map-pin")
            for _, data in ipairs(regions[region2]) do
                group:AddButton({
                    Text = data.n,
                    Func = function()
                        TeleportTo(data.p)
                        Library:Notify({
                            Title = "传送",
                            Description = "正在传送至: " .. data.n,
                            Time = 2,
                        })
                    end,
                })
            end
        end
    end
end

task.spawn(function()
    task.wait(0.5)
    if not isDestroyed then
        CreateRegionGroups()
    end
end)

-- ====== 设置标签页 ======
local settingsGroup = Tabs.Settings:AddLeftGroupbox("菜单设置", "sliders")
settingsGroup:AddToggle("ShowCustomCursor", {
    Text = "自定义光标",
    Default = Library.ShowCustomCursor,
    Callback = function(value)
        Library.ShowCustomCursor = value
    end
})
settingsGroup:AddButton({
    Text = "卸载 SANA HUB",
    Func = function()
        Library:Unload()
    end,
    Risky = true,
})

-- ====== 保存与主题 ======
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("SANA_HUB")
SaveManager:SetFolder("SANA_HUB")
SaveManager:SetSubFolder("Configs")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- ====== 菜单切换按钮 ======
local menuLabel = Library:AddDraggableLabel("切换菜单")
menuLabel:AddButton({
    Text = "点击切换",
    Func = function()
        if Library.ToggleKeybind then
            local key = Library.ToggleKeybind.Value
            if key then
                local VirtualInputManager = game:GetService("VirtualInputManager")
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end
        else
            if Window and Window.Frame then
                Window.Frame.Visible = not Window.Frame.Visible
            end
        end
    end
})

-- 穿墙状态切换
local noclipStatusLabel = Library:AddDraggableLabel("穿墙: 关闭")
noclipStatusLabel:AddButton({
    Text = "切换",
    Func = function()
        Settings.NoclipEnabled = not Settings.NoclipEnabled
        ToggleNoclip(Settings.NoclipEnabled)
        noclipStatusLabel:SetText("穿墙: " .. (Settings.NoclipEnabled and "开启" or "关闭"))
        if Toggles and Toggles.NoclipToggle then
            Toggles.NoclipToggle:SetValue(Settings.NoclipEnabled)
        end
    end
})

-- ====== 事件与后台任务 ======
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        if Settings.HitboxEnabled and not isDestroyed then
            task.wait(0.5)
            ApplyHitbox()
        end
        if Settings.NoclipEnabled and not isDestroyed then
            task.wait(0.1)
            ApplyNoclip()
        end
    end)
    if Settings.WhitelistEnabled and not isDestroyed then
        UpdateWhitelist()
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
local playerAddedCon = Players.PlayerAdded:Connect(onPlayerAdded)
table.insert(connections, playerAddedCon)

local renderCon = RunService.RenderStepped:Connect(function()
    if isDestroyed then return end
    if Settings.HitboxEnabled then
        frameCount = frameCount + 1
        if frameCount % 3 == 0 then
            ApplyHitbox()
        end
    end
    if Settings.NoclipEnabled then
        ApplyNoclip()
    end
end)
table.insert(connections, renderCon)

task.spawn(function()
    while not isDestroyed do
        task.wait(10)
        if Settings.WhitelistEnabled and not isDestroyed then
            UpdateWhitelist()
        end
    end
end)

local function ScanPrompts()
    if isDestroyed then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = Settings.HoldTime
            obj.MaxActivationDistance = Settings.Distance
        end
    end
end
ScanPrompts()

local descendantCon = workspace.DescendantAdded:Connect(function(obj)
    if isDestroyed then return end
    task.wait(0.1)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = Settings.HoldTime
        obj.MaxActivationDistance = Settings.Distance
    end
end)
table.insert(connections, descendantCon)

Library:OnUnload(function()
    if isDestroyed then return end
    isDestroyed = true
    ResetHitbox()
    if Settings.NoclipEnabled then
        ToggleNoclip(false)
    end
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, conn in ipairs(noclipConnections) do
        pcall(function() conn:Disconnect() end)
    end
    print("SANA HUB 已完全卸载")
end)

SaveManager:LoadAutoloadConfig()
print("SANA HUB 已加载！")