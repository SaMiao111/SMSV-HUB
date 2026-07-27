-- ==========================================
-- SANA HUB 测试版v2（带云端密钥验证）
-- 服务器地址：https://ansn.3793085275.workers.dev/
-- ==========================================

-- ★★★ 在这里配置你的云端验证服务器 ★★★
local API_URL = "https://ansn.3793085275.workers.dev/"

-- ★★★ 预设的有效密钥列表（本地缓存，用于快速验证） ★★★
-- 注意：最终验证以服务器为准，这里仅用于缓存
local VALID_KEYS_CACHE = {
    ["SANA-2026-A1B2C3"] = true,
    ["SANA-2026-D4E5F6"] = true,
    ["SANA-2026-G7H8I9"] = true,
    ["SANA-2026-J0K1L2"] = true,
    ["SANA-2026-M3N4O5"] = true,
    ["SANA-2026-P6Q7R8"] = true,
    ["SANA-2026-S9T0U1"] = true,
    ["SANA-2026-V2W3X4"] = true,
    ["SANA-2026-Y5Z6A7"] = true,
    ["SANA-2026-B8C9D0"] = true,
}

-- ==========================================
-- 云端验证模块
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local isKeyValidated = false
local validationAttempts = 0
local MAX_ATTEMPTS = 5

-- 生成机器码（用于绑定设备）
local function GetMachineID()
    local info = {
        UserInputService:GetUserId(),
        UserInputService:GetPlatform(),
        UserInputService:GetDeviceType(),
        os.time() % 100000,
    }
    local combined = table.concat(info, "|")
    local hash = 0
    for i = 1, #combined do
        hash = (hash * 31 + string.byte(combined, i)) % 1000000
    end
    return tostring(hash)
end

-- 向云端服务器验证密钥
local function VerifyKeyOnCloud(key)
    validationAttempts = validationAttempts + 1
    if validationAttempts > MAX_ATTEMPTS then
        return false, "尝试次数过多，请重新注入"
    end
    
    local success, response = pcall(function()
        local data = { key = key }
        local jsonData = HttpService:JSONEncode(data)
        
        local result = HttpService:PostAsync(
            API_URL,
            jsonData,
            Enum.HttpContentType.ApplicationJson,
            false,
            { ["Content-Type"] = "application/json" }
        )
        
        return HttpService:JSONDecode(result)
    end)
    
    if success and response and response.valid then
        return true, response.message or "验证成功"
    else
        local errMsg = "网络错误，请重试"
        if response and response.message then
            errMsg = response.message
        end
        return false, errMsg
    end
end

-- 保存验证状态到本地
local function SaveValidation(key)
    local saved = Instance.new("StringValue")
    saved.Name = "SANA_Validated_" .. key
    saved.Value = GetMachineID()
    saved.Parent = LocalPlayer
end

-- 检查是否有已保存的有效验证
local function HasSavedValidation()
    for _, child in ipairs(LocalPlayer:GetChildren()) do
        if string.match(child.Name, "^SANA_Validated_") then
            if child.Value == GetMachineID() then
                return true, string.gsub(child.Name, "^SANA_Validated_", "")
            end
        end
    end
    return false, nil
end

-- 清除所有验证状态
local function ClearAllValidation()
    for _, child in ipairs(LocalPlayer:GetChildren()) do
        if string.match(child.Name, "^SANA_Validated_") then
            child:Destroy()
        end
    end
end

-- ==========================================
-- 密钥输入UI
-- ==========================================

local keyGui = nil

local function CreateKeyInputUI(onSuccess)
    -- 如果已经有保存的验证，直接跳过
    local hasSaved, savedKey = HasSavedValidation()
    if hasSaved and savedKey then
        print("✅ 检测到已保存的验证: " .. savedKey)
        isKeyValidated = true
        if onSuccess then onSuccess() end
        return
    end
    
    keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeyValidator"
    keyGui.ResetOnSpawn = false
    keyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 240)
    frame.Position = UDim2.new(0.5, -210, 0.5, -120)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.1
    frame.Parent = keyGui
    
    local border = Instance.new("UICorner")
    border.CornerRadius = UDim.new(0, 12)
    border.Parent = frame
    
    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    titleBar.Parent = frame
    
    local titleBorder = Instance.new("UICorner")
    titleBorder.CornerRadius = UDim.new(0, 12)
    titleBorder.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔑 SANA HUB 授权验证"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- 机器码显示
    local machineLabel = Instance.new("TextLabel")
    machineLabel.Size = UDim2.new(1, -30, 0, 22)
    machineLabel.Position = UDim2.new(0, 15, 0, 60)
    machineLabel.BackgroundTransparency = 1
    machineLabel.Text = "🖥️ 设备ID: " .. GetMachineID()
    machineLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    machineLabel.TextSize = 13
    machineLabel.Font = Enum.Font.Gotham
    machineLabel.Parent = frame
    
    -- 输入框
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.8, 0, 0, 40)
    inputBox.Position = UDim2.new(0.1, 0, 0, 90)
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    inputBox.PlaceholderText = "请输入授权密钥..."
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 18
    inputBox.Font = Enum.Font.Gotham
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = frame
    
    local inputBorder = Instance.new("UICorner")
    inputBorder.CornerRadius = UDim.new(0, 6)
    inputBorder.Parent = inputBox
    
    -- 状态标签
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.8, 0, 0, 30)
    statusLabel.Position = UDim2.new(0.1, 0, 0, 138)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "请输入您收到的授权密钥"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = frame
    
    -- 验证按钮
    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0.35, 0, 0, 40)
    confirmBtn.Position = UDim2.new(0.325, 0, 0, 175)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    confirmBtn.Text = "✅ 验证"
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.TextSize = 18
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.Parent = frame
    
    local btnBorder = Instance.new("UICorner")
    btnBorder.CornerRadius = UDim.new(0, 6)
    btnBorder.Parent = confirmBtn
    
    -- 关闭按钮（右上角小X）
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local function OnConfirm()
        local key = inputBox.Text
        if key == "" then
            statusLabel.Text = "❌ 请输入密钥！"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        -- 先检查本地缓存
        if not VALID_KEYS_CACHE[key] then
            statusLabel.Text = "❌ 无效密钥格式"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            inputBox.Text = ""
            return
        end
        
        statusLabel.Text = "⏳ 正在验证..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        confirmBtn.Visible = false
        
        task.spawn(function()
            local isValid, msg = VerifyKeyOnCloud(key)
            
            if isValid then
                statusLabel.Text = "✅ " .. msg
                statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                SaveValidation(key)
                isKeyValidated = true
                
                task.wait(0.5)
                keyGui:Destroy()
                if onSuccess then onSuccess() end
            else
                statusLabel.Text = "❌ " .. msg
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                inputBox.Text = ""
                confirmBtn.Visible = true
            end
        end)
    end
    
    confirmBtn.MouseButton1Click:Connect(OnConfirm)
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then OnConfirm() end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        keyGui:Destroy()
        print("❌ 用户取消了验证")
    end)
end

-- ==========================================
-- 主UI创建函数（你原来的所有功能）
-- ==========================================

local function CreateMainUI()
    -- ====== 设置变量 ======
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
    
    -- ====== 固定传送点数据 ======
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
    
    -- ====== 延迟加载函数 ======
    local function DelayedTask(fn, delay)
        local d = delay or 2
        task.spawn(function()
            task.wait(d)
            if isDestroyed then return end
            fn()
        end)
    end
    
    -- ====== 传送功能 ======
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
    
    -- ====== 穿墙功能 ======
    local function ToggleNoclip(enabled)
        if isDestroyed then return end
        for _, conn in ipairs(noclipConnections) do
            pcall(function() conn:Disconnect() end)
        end
        noclipConnections = {}
        
        if enabled then
            local con = RunService.Stepped:Connect(function()
                if isDestroyed or not Settings.NoclipEnabled then return end
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
            table.insert(noclipConnections, con)
            
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
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
    
    -- ====== 创建主GUI ======
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UtilityHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 550, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    mainFrame.ClipsDescendants = true
    
    local border = Instance.new("UICorner")
    border.CornerRadius = UDim.new(0, 8)
    border.Parent = mainFrame
    
    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 55)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    titleBar.BackgroundTransparency = 0.3
    titleBar.Parent = mainFrame
    
    local titleBorder = Instance.new("UICorner")
    titleBorder.CornerRadius = UDim.new(0, 8)
    titleBorder.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -135, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SANA HUB 测试版v2"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- 验证状态显示
    local authStatus = Instance.new("TextLabel")
    authStatus.Size = UDim2.new(0, 120, 1, 0)
    authStatus.Position = UDim2.new(1, -250, 0, 0)
    authStatus.BackgroundTransparency = 1
    authStatus.Text = "✅ 已授权"
    authStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
    authStatus.TextSize = 14
    authStatus.Font = Enum.Font.Gotham
    authStatus.TextXAlignment = Enum.TextXAlignment.Right
    authStatus.Parent = titleBar
    
    -- 收纳按钮
    local foldBtn = Instance.new("TextButton")
    foldBtn.Size = UDim2.new(0, 45, 0, 45)
    foldBtn.Position = UDim2.new(1, -110, 0, 5)
    foldBtn.BackgroundColor3 = Color3.fromRGB(200, 170, 0)
    foldBtn.BackgroundTransparency = 0.3
    foldBtn.Text = "▲"
    foldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    foldBtn.TextSize = 24
    foldBtn.Font = Enum.Font.GothamBold
    foldBtn.Parent = titleBar
    
    local foldBorder = Instance.new("UICorner")
    foldBorder.CornerRadius = UDim.new(0, 6)
    foldBorder.Parent = foldBtn
    
    -- 关闭按钮
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 45, 0, 45)
    closeBtn.Position = UDim2.new(1, -55, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeBorder = Instance.new("UICorner")
    closeBorder.CornerRadius = UDim.new(0, 6)
    closeBorder.Parent = closeBtn
    
    -- 内容容器
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, 0, 1, -55)
    contentContainer.Position = UDim2.new(0, 0, 0, 55)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = mainFrame
    
    -- 滚动容器
    local scrollContainer = Instance.new("ScrollingFrame")
    scrollContainer.Size = UDim2.new(1, -30, 1, 0)
    scrollContainer.Position = UDim2.new(0, 15, 0, 0)
    scrollContainer.BackgroundTransparency = 1
    scrollContainer.ScrollBarThickness = 8
    scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 3400)
    scrollContainer.Parent = contentContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollContainer
    
    -- ====== 折叠功能 ======
    local isCollapsed = false
    local function ToggleFold()
        if isDestroyed then return end
        isCollapsed = not isCollapsed
        if isCollapsed then
            contentContainer.Size = UDim2.new(1, 0, 0, 0)
            mainFrame.Size = UDim2.new(0, 550, 0, 55)
            foldBtn.Text = "▼"
        else
            contentContainer.Size = UDim2.new(1, 0, 1, -55)
            mainFrame.Size = UDim2.new(0, 550, 0, 500)
            foldBtn.Text = "▲"
        end
    end
    foldBtn.MouseButton1Click:Connect(ToggleFold)
    
    -- ====== 自毁函数 ======
    local function DestroyScript()
        if isDestroyed then return end
        isDestroyed = true
        ResetHitbox()
        ToggleNoclip(false)
        for _, conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        for _, conn in ipairs(noclipConnections) do
            pcall(function() conn:Disconnect() end)
        end
        pcall(function() screenGui:Destroy() end)
        print("SANA HUB 已完全卸载")
    end
    closeBtn.MouseButton1Click:Connect(DestroyScript)
    
    -- ====== 辅助函数 ======
    local function CreateSection(text)
        if isDestroyed then return end
        local section = Instance.new("TextLabel")
        section.Size = UDim2.new(1, 0, 0, 35)
        section.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        section.BackgroundTransparency = 0.3
        section.Text = " " .. text
        section.TextColor3 = Color3.fromRGB(200, 200, 255)
        section.TextXAlignment = Enum.TextXAlignment.Left
        section.TextSize = 18
        section.Font = Enum.Font.GothamBold
        section.Parent = scrollContainer
        local secBorder = Instance.new("UICorner")
        secBorder.CornerRadius = UDim.new(0, 5)
        secBorder.Parent = section
    end
    
    local function CreateSlider(name, min, max, default, suffix, callback)
        if isDestroyed then return end
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 80)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        frame.BackgroundTransparency = 0.3
        frame.Parent = scrollContainer
        
        local fBorder = Instance.new("UICorner")
        fBorder.CornerRadius = UDim.new(0, 6)
        fBorder.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 28)
        label.Position = UDim2.new(0, 8, 0, 2)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(default) .. suffix
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.TextSize = 16
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, -30, 0, 24)
        slider.Position = UDim2.new(0, 15, 0, 38)
        slider.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        slider.Parent = frame
        
        local sBorder = Instance.new("UICorner")
        sBorder.CornerRadius = UDim.new(0, 4)
        sBorder.Parent = slider
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        fill.Parent = slider
        
        local fFill = Instance.new("UICorner")
        fFill.CornerRadius = UDim.new(0, 4)
        fFill.Parent = fill
        
        local value = default
        
        local function UpdateSlider(input)
            local x = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = math.round((min + (max - min) * x) / 1) * 1
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            label.Text = name .. ": " .. tostring(value) .. suffix
            callback(value)
        end
        
        local con1 = slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                UpdateSlider(input)
            end
        end)
        table.insert(connections, con1)
        
        local con2 = slider.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                UpdateSlider(input)
            end
        end)
        table.insert(connections, con2)
    end
    
    local function CreateToggle(name, default, callback)
        if isDestroyed then return end
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 45)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        frame.BackgroundTransparency = 0.3
        frame.Parent = scrollContainer
        
        local fBorder = Instance.new("UICorner")
        fBorder.CornerRadius = UDim.new(0, 6)
        fBorder.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -70, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(0, 40, 0, 26)
        toggle.Position = UDim2.new(1, -55, 0, 10)
        toggle.BackgroundColor3 = default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        toggle.Parent = frame
        
        local tBorder = Instance.new("UICorner")
        tBorder.CornerRadius = UDim.new(0, 13)
        tBorder.Parent = toggle
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 20, 0, 20)
        indicator.Position = default and UDim2.new(0, 18, 0, 3) or UDim2.new(0, 3, 0, 3)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.Parent = toggle
        
        local iBorder = Instance.new("UICorner")
        iBorder.CornerRadius = UDim.new(0, 10)
        iBorder.Parent = indicator
        
        local state = default
        
        local con = toggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                toggle.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
                indicator.Position = state and UDim2.new(0, 18, 0, 3) or UDim2.new(0, 3, 0, 3)
                callback(state)
            end
        end)
        table.insert(connections, con)
    end
    
    -- ====== 创建可折叠区域 ======
    local function CreateRegionFolder(regionName)
        if isDestroyed then return nil end
        
        local folderBtn = Instance.new("TextButton")
        folderBtn.Size = UDim2.new(1, 0, 0, 40)
        folderBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 60)
        folderBtn.BackgroundTransparency = 0.3
        folderBtn.Text = "▶ " .. regionName
        folderBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
        folderBtn.TextSize = 17
        folderBtn.TextXAlignment = Enum.TextXAlignment.Left
        folderBtn.Font = Enum.Font.GothamBold
        folderBtn.Parent = scrollContainer
        
        local fbBorder = Instance.new("UICorner")
        fbBorder.CornerRadius = UDim.new(0, 6)
        fbBorder.Parent = folderBtn
        
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, 0, 0, 0)
        contentFrame.BackgroundTransparency = 1
        contentFrame.ClipsDescendants = true
        contentFrame.Parent = scrollContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentFrame
        
        local isOpen = false
        
        local function UpdateContentHeight()
            local totalHeight = 0
            for _, child in ipairs(contentFrame:GetChildren()) do
                if child:IsA("Frame") and child.Size then
                    totalHeight = totalHeight + child.Size.Y.Offset + 6
                end
            end
            contentFrame.Size = UDim2.new(1, 0, 0, isOpen and totalHeight or 0)
        end
        
        local con = folderBtn.MouseButton1Click:Connect(function()
            if isDestroyed then return end
            isOpen = not isOpen
            folderBtn.Text = (isOpen and "▼" or "▶") .. " " .. regionName
            UpdateContentHeight()
        end)
        table.insert(connections, con)
        
        local function AddChildToRegion(child)
            child.Parent = contentFrame
            task.wait(0.05)
            UpdateContentHeight()
        end
        
        task.wait(0.1)
        UpdateContentHeight()
        
        return {
            AddChild = AddChildToRegion,
            UpdateHeight = UpdateContentHeight,
            IsOpen = function() return isOpen end,
        }
    end
    
    -- ====== 创建传送点按钮 ======
    local function CreateFixedTeleportPoint(name, position, regionFolder)
        if isDestroyed then return end
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -15, 0, 38)
        frame.Position = UDim2.new(0, 8, 0, 0)
        frame.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
        frame.BackgroundTransparency = 0.3
        
        local fBorder = Instance.new("UICorner")
        fBorder.CornerRadius = UDim.new(0, 6)
        fBorder.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 200, 100)
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = frame
        
        local con = clickBtn.MouseButton1Click:Connect(function()
            TeleportTo(position)
        end)
        table.insert(connections, con)
        
        if regionFolder then
            regionFolder.AddChild(frame)
        else
            frame.Parent = scrollContainer
        end
    end
    
    -- ====== 加载传送点 ======
    local function LoadTeleports()
        if isDestroyed then return end
        
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
        
        for _, regionName in ipairs(regionNames) do
            local folder = CreateRegionFolder(regionName)
            for _, data in ipairs(regions[regionName]) do
                CreateFixedTeleportPoint(data.n, data.p, folder)
            end
            task.wait(0.1)
            if folder then
                folder.UpdateHeight()
            end
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
    
    CreateSection("穿墙")
    
    CreateToggle("穿墙模式", false, function(value)
        Settings.NoclipEnabled = value
        ToggleNoclip(value)
    end)
    
    CreateSection("固定传送点")
    
    CreateToggle("启用传送", false, function(value)
        Settings.TeleportEnabled = value
    end)
    
    DelayedTask(LoadTeleports, 2)
    
    -- ====== 碰撞箱功能 ======
    function ApplyHitbox()
        if isDestroyed or not Settings.HitboxEnabled then return end
        
        local players = Players:GetPlayers()
        local newAffected = {}
        
        for i = 1, #players do
            local player = players[i]
            if player ~= LocalPlayer and player.Character then
                if Settings.WhitelistEnabled and Whitelist[player.UserId] then
                    -- 跳过白名单玩家
                else
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
    
    -- ====== 玩家事件 ======
    local con1 = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            if Settings.HitboxEnabled and not isDestroyed then
                task.wait(0.5)
                ApplyHitbox()
            end
            if Settings.NoclipEnabled and not isDestroyed then
                task.wait(0.5)
                ToggleNoclip(true)
            end
        end)
        if Settings.WhitelistEnabled and not isDestroyed then
            UpdateWhitelist()
        end
    end)
    table.insert(connections, con1)
    
    -- ====== 每帧更新 ======
    local con2 = RunService.RenderStepped:Connect(function()
        if Settings.HitboxEnabled and not isDestroyed then
            frameCount = frameCount + 1
            if frameCount % 3 == 0 then
                ApplyHitbox()
            end
        end
    end)
    table.insert(connections, con2)
    
    -- ====== 定期更新好友列表 ======
    task.spawn(function()
        while not isDestroyed do
            task.wait(10)
            if Settings.WhitelistEnabled and not isDestroyed then
                UpdateWhitelist()
            end
        end
    end)
    
    -- ====== INS键隐藏/显示 ======
    local visible = true
    local con3 = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert and not isDestroyed then
            visible = not visible
            mainFrame.Visible = visible
        end
    end)
    table.insert(connections, con3)
    
    -- ====== 扫描现有交互 ======
    local function ScanPrompts()
        if isDestroyed then return end
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
    
    local con4 = workspace.DescendantAdded:Connect(function(obj)
        if isDestroyed then return end
        task.wait(0.1)
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = Settings.HoldTime
            obj.MaxActivationDistance = Settings.Distance
        end
    end)
    table.insert(connections, con4)
    
    print("SANA HUB 已加载！按 INS 键切换菜单")
end

-- ==========================================
-- 脚本入口：先验证，再加载功能
-- ==========================================

print("🔑 SANA HUB 启动中...")

-- 检查是否有已保存的验证
local hasSaved, savedKey = HasSavedValidation()
if hasSaved and savedKey then
    print("✅ 检测到已保存的验证: " .. savedKey)
    isKeyValidated = true
    CreateMainUI()
else
    print("🔑 需要输入密钥进行验证")
    CreateKeyInputUI(CreateMainUI)
end