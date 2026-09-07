--[[
================================================================================
  👑 KING AKBAR - INDO HANGOUT HUB (WINDUI + SILENT MODE + INFO TAB) 👑
================================================================================
--]]

-- ============================================================================
-- // 0. LOAD WINDUI (SAFE)
-- ============================================================================
local WindUI
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(
            "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
        ))()
    end)
    if ok and result then
        WindUI = result
    else
        -- Silent mode: tidak ada output console
        return
    end
end

-- ============================================================================
-- // 0.5 BYPASS PAUSE (HANCURKAN NETWORK PAUSE)
-- ============================================================================
pcall(function()
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("RobloxGui") then
        local pauseScript = CoreGui.RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
        if pauseScript then
            pauseScript:Destroy()
        end
    end
end)

-- ============================================================================
-- // 1. SERVICES & DEVICE DETECTOR
-- ============================================================================
local Services = {
    Players           = game:GetService("Players"),
    RunService        = game:GetService("RunService"),
    UserInput         = game:GetService("UserInputService"),
    TweenSvc          = game:GetService("TweenService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    CoreGui           = game:GetService("CoreGui"),
    VirtualUser       = game:GetService("VirtualUser"),
    HttpService       = game:GetService("HttpService"),
    Workspace         = game:GetService("Workspace")
}

local LocalPlayer = Services.Players.LocalPlayer
local IsMobile = Services.UserInput.TouchEnabled and not Services.UserInput.MouseEnabled

-- ============================================================================
-- // 2. SPLASH SCREEN (KING AKBAR STYLE)
-- ============================================================================
do
    local sg = Instance.new("ScreenGui")
    sg.Name = "KingAkbarSplash"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.DisplayOrder = 999
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.fromScale(1,1); bg.BackgroundColor3 = Color3.fromHex("#0a0a0a")
    bg.BorderSizePixel = 0; bg.ZIndex = 1

    local grad = Instance.new("UIGradient", bg)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#0a0a0a")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#1e1e1e")),
    }); grad.Rotation = 135

    local ct = Instance.new("Frame", bg)
    ct.Size = UDim2.fromOffset(500, 300); ct.Position = UDim2.fromScale(0.5, 0.5)
    ct.AnchorPoint = Vector2.new(0.5, 0.5); ct.BackgroundTransparency = 1; ct.ZIndex = 2

    local function mkLabel(txt, yOff, sz)
        local l = Instance.new("TextLabel", ct)
        l.Size = UDim2.fromOffset(500, 70); l.Position = UDim2.fromOffset(0, yOff)
        l.BackgroundTransparency = 1; l.Text = txt; l.TextSize = sz
        l.Font = Enum.Font.GothamBold; l.TextColor3 = Color3.fromHex("#ffffff")
        l.TextTransparency = 1; l.ZIndex = 3; return l
    end

    local icon = Instance.new("ImageLabel", ct)
    icon.Size = UDim2.fromOffset(120, 120); icon.Position = UDim2.fromOffset(190, -40)
    icon.BackgroundTransparency = 1; icon.Image = "rbxassetid://91115084979317"
    icon.ImageTransparency = 1; icon.ZIndex = 3

    local title = mkLabel("King Akbar", 70, IsMobile and 38 or 50)
    local tg = Instance.new("UIGradient", title)
    tg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromHex("#ffffff")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("#aaaaaa")),
        ColorSequenceKeypoint.new(1,   Color3.fromHex("#555555")),
    }); tg.Rotation = 45

    local stat = mkLabel("Mempersiapkan mesin memancing...", 200, 12)
    stat.Font = Enum.Font.Gotham; stat.TextColor3 = Color3.fromHex("#555555")
    stat.TextXAlignment = Enum.TextXAlignment.Left; stat.Position = UDim2.fromOffset(50, 200)

    local line = Instance.new("Frame", ct)
    line.Size = UDim2.fromOffset(0, 2); line.Position = UDim2.fromOffset(250, 152)
    line.AnchorPoint = Vector2.new(0.5, 0); line.BackgroundColor3 = Color3.fromHex("#444444")
    line.BorderSizePixel = 0; line.ZIndex = 3

    local barBg = Instance.new("Frame", ct)
    barBg.Size = UDim2.fromOffset(400, 5); barBg.Position = UDim2.fromOffset(50, 190)
    barBg.BackgroundColor3 = Color3.fromHex("#222222"); barBg.BackgroundTransparency = 1
    barBg.BorderSizePixel = 0; barBg.ZIndex = 3
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local bar = Instance.new("Frame", barBg)
    bar.Size = UDim2.fromOffset(0, 5); bar.BackgroundColor3 = Color3.fromHex("#ffffff")
    bar.BorderSizePixel = 0; bar.ZIndex = 4
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local function tw(obj, props, t)
        Services.TweenSvc:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end

    task.spawn(function()
        tw(icon,  { ImageTransparency = 0 }, 0.5); task.wait(0.15)
        tw(title, { TextTransparency  = 0 }, 0.6); task.wait(0.35)
        tw(line,  { Size = UDim2.fromOffset(400, 2) }, 0.7); task.wait(0.4)
        tw(barBg, { BackgroundTransparency = 0 }, 0.3)
        tw(stat,  { TextTransparency = 0 }, 0.3)

        for _, s in ipairs({
            { "Memuat UI Library...", 0.30 },
            { "Mengecek Server Indo Hangout...", 0.60 },
            { "Welcome, King Akbar!", 1.00 },
        }) do
            stat.Text = s[1]
            tw(bar, { Size = UDim2.fromOffset(400 * s[2], 5) }, 0.5)
            task.wait(0.55)
        end

        task.wait(0.3)
        for _, p in ipairs({ bg, icon, title, line, barBg, bar, stat }) do
            local prop = p == stat and "TextTransparency"
                or (p == icon  and "ImageTransparency" or "BackgroundTransparency")
            if p == title then prop = "TextTransparency" end
            tw(p, { [prop] = 1 }, 0.4)
        end
        task.wait(0.8); sg:Destroy()
    end)
    task.wait(3)
end

-- ============================================================================
-- // 3. CREATE WINDOW (WINDUI)
-- ============================================================================
local wSz  = IsMobile and UDim2.fromOffset(420, 320) or UDim2.fromOffset(580, 460)
local mnSz = IsMobile and Vector2.new(600, 300) or Vector2.new(600, 350)
local mxSz = IsMobile and Vector2.new(650, 400) or Vector2.new(850, 560)

local Window = WindUI:CreateWindow({
    Title                       = "King Akbar - Indo Hangout",
    Icon                        = "crown",
    Author                      = "King Akbar",
    Folder                      = "KingAkbarHub",
    Size                        = wSz,
    MinSize                     = mnSz,
    MaxSize                     = mxSz,
    Transparent                 = false,
    Background                  = "rbxassetid://127295801178451",
    BackgroundImageTransparency = 0.5,
    Theme                       = "Dark",
    Resizable                   = true,
    SideBarWidth                = 210,
    HideSearchBar               = false,
    ScrollBarEnabled            = true,
})

-- ============================================================================
-- // 4. TABS
-- ============================================================================
local InfoTab = Window:Tab({ Title = "Info", Icon = "info", Border = true })
local MainTab = Window:Tab({ Title = "Main", Icon = "anchor", Border = true })
local AutomaticTab = Window:Tab({ Title = "Automatic", Icon = "shopping-cart", Border = true })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings", Border = true })

-- ============================================================================
-- // 5. CORE VARIABLES & LOGIC
-- ============================================================================
local RodEvent = Services.ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteEvent"):WaitForChild("Rod")
local SellEvent = Services.ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunction"):WaitForChild("SellFish")
local BackpackEvent = Services.ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunction"):WaitForChild("Backpack")
local PickaxeEvent = Services.ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteEvent"):WaitForChild("Pickaxe")
local SellCrystalEvent = Services.ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunction"):WaitForChild("SellCrystal")

local ReelingGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Reeling")

getgenv().AutoFishing = false
getgenv().AutoSell = false
getgenv().AutoSellInterval = 1 
getgenv().AutoSellCrystal = false
getgenv().AutoSellCrystalInterval = 1
getgenv().AntiAFK = false
getgenv().AutoMining = false
getgenv().MaxCrystalHP = 10
getgenv().AutoFavorite = false
getgenv().AutoFavoriteMinWeight = 25
getgenv().MiningHitDelay = 1.6
getgenv().MiningWalkSpeed = 16
getgenv().MiningStopDistance = 5

local lagiNungguIkan = false
local sellTimer = 0
local sellCrystalTimer = 0
local antiAfkConnection = nil
local currentMiningTarget = nil
local currentMiningAnim = nil

-- ID Animasi Mining
local MiningAnimationId = "rbxassetid://138639123067444"

-- ═══════════════════════════════════════════════════════════
--  FUNGSI ANIMASI MINING
-- ═══════════════════════════════════════════════════════════
local function PlayMiningAnimation(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    if currentMiningAnim then
        currentMiningAnim:Stop()
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = MiningAnimationId
    currentMiningAnim = animator:LoadAnimation(animation)
    currentMiningAnim:Play()
end

-- FITUR 1: Aimbot Minigame
pcall(function()
    Services.RunService:UnbindFromRenderStep("AimbotMancing")
end)

Services.RunService:BindToRenderStep("AimbotMancing", 2000, function()
    if getgenv().AutoFishing and ReelingGui.Enabled then
        local redBar = ReelingGui:FindFirstChild("RedBar", true)
        local whiteBar = ReelingGui:FindFirstChild("WhiteBar", true)
        
        if redBar and whiteBar then
            whiteBar.Position = redBar.Position
        end
    end
end)

-- FITUR 2: Smart Auto-Throw (TANPA EVENT "Equipped")
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoFishing then
            local character = LocalPlayer.Character
            if not character then continue end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then continue end
            local backpack = LocalPlayer.Backpack

            -- Cari rod di backpack atau sudah dipegang
            local rod = nil
            local currentTool = character:FindFirstChildOfClass("Tool")
            if currentTool and currentTool.Name:lower():find("rod") then
                rod = currentTool
            else
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                        rod = tool
                        break
                    end
                end
            end

            if not rod then
                lagiNungguIkan = false
                continue
            end

            -- Equip rod jika belum dipegang
            if not currentTool or currentTool ~= rod then
                humanoid:EquipTool(rod)
                task.wait(0.5)
            end

            -- Jika ReelingGui aktif (sedang reeling), set flag menunggu false
            if ReelingGui.Enabled then
                lagiNungguIkan = false
            else
                -- Jika tidak sedang reeling dan belum lempar, lempar sekarang
                if not lagiNungguIkan then
                    task.wait(1.5)
                    -- Hanya kirim Throw
                    pcall(function()
                        RodEvent:FireServer("Throw")
                    end)
                    lagiNungguIkan = true
                end
            end
        else
            -- Reset saat AutoFishing dimatikan
            lagiNungguIkan = false
        end
    end
end)

-- FITUR 3: Smart Auto-Sell (Ikan)
task.spawn(function()
    while task.wait(1) do 
        if getgenv().AutoSell then
            sellTimer = sellTimer + 1
            local batasWaktu = getgenv().AutoSellInterval * 60 

            if sellTimer >= batasWaktu then
                sellTimer = 0 
                pcall(function()
                    SellEvent:InvokeServer("SellFish", "Sell All")
                end)
            end
        else
            sellTimer = 0 
        end
    end
end)

-- FITUR 3b: Smart Auto-Sell Crystal
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoSellCrystal then
            sellCrystalTimer = sellCrystalTimer + 1
            local batasWaktu = getgenv().AutoSellCrystalInterval * 60

            if sellCrystalTimer >= batasWaktu then
                sellCrystalTimer = 0
                pcall(function()
                    SellCrystalEvent:InvokeServer("SellCrystal", "Sell All")
                end)
            end
        else
            sellCrystalTimer = 0
        end
    end
end)

-- FITUR 4: Anti AFK Logic
local function ToggleAntiAFK(state)
    getgenv().AntiAFK = state
    
    if state then
        pcall(function()
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                v:Disable()
            end
        end)
        
        if not antiAfkConnection then
            antiAfkConnection = LocalPlayer.Idled:Connect(function()
                if getgenv().AntiAFK then
                    Services.VirtualUser:CaptureController()
                    Services.VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        end
    else
        pcall(function()
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                v:Enable()
            end
        end)
        
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end
end

-- ═══════════════════════════════════════════════════════════
-- FITUR 5: AUTO FAVORIT
-- ═══════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(2) do
        if getgenv().AutoFavorite then
            local character = LocalPlayer.Character
            local backpack = LocalPlayer.Backpack

            local allTools = {}
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then table.insert(allTools, tool) end
                end
            end
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then table.insert(allTools, tool) end
                end
            end

            for _, tool in pairs(allTools) do
                local weight = tonumber(tool.Name:match("%((%d+%.?%d*) Kg%)"))
                local isFavorite = tool.Name:find("%(favorite%)") ~= nil

                if weight and weight >= getgenv().AutoFavoriteMinWeight and not isFavorite then
                    pcall(function()
                        BackpackEvent:InvokeServer("ChangeFavoriteStatus", tool)
                    end)
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- FITUR 6: AUTO MINING (BERJALAN + ANIMASI LANGSUNG HIT)
-- ═══════════════════════════════════════════════════════════
local function getCrystalHP(crystal)
    local hp = crystal:GetAttribute("HP")
    if hp == nil then
        local hpObj = crystal:FindFirstChild("HP") or crystal:FindFirstChild("Health")
        if hpObj and (hpObj:IsA("IntValue") or hpObj:IsA("NumberValue")) then
            hp = hpObj.Value
        end
    end
    return hp
end

local function getNearestCrystal()
    local crystalsFolder = Services.Workspace:FindFirstChild("MapContent") and Services.Workspace.MapContent:FindFirstChild("Crystals")
    if not crystalsFolder then return nil end

    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local root = character.HumanoidRootPart

    local nearest = nil
    local nearestDist = math.huge

    for _, crystal in pairs(crystalsFolder:GetChildren()) do
        if crystal:IsA("BasePart") and crystal:IsDescendantOf(crystalsFolder) then
            local hp = getCrystalHP(crystal)
            if hp and hp < 10 then
                continue
            end

            local mag = (crystal.Position - root.Position).Magnitude
            if mag < nearestDist then
                nearestDist = mag
                nearest = crystal
            end
        end
    end
    return nearest
end

task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoMining then
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end

            local root = character.HumanoidRootPart
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then continue end

            local pickaxe = nil
            for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("pickaxe") then
                    pickaxe = tool
                    break
                end
            end
            if not pickaxe and character:FindFirstChildOfClass("Tool") and character:FindFirstChildOfClass("Tool").Name:lower():find("pickaxe") then
                pickaxe = character:FindFirstChildOfClass("Tool")
            end

            if not pickaxe then
                task.wait(2)
                continue
            end

            if humanoid and character:FindFirstChildOfClass("Tool") ~= pickaxe then
                humanoid:EquipTool(pickaxe)
                task.wait(0.5)
            end

            local target = currentMiningTarget
            if not target or not target.Parent then
                target = getNearestCrystal()
                if not target then
                    task.wait(3)
                    continue
                end
                currentMiningTarget = target
            end

            humanoid.WalkSpeed = getgenv().MiningWalkSpeed or 16
            local crystalPos = target.Position
            local stopDistance = getgenv().MiningStopDistance or 5
            local maxWaitTime = 10
            local waitStart = tick()

            humanoid:MoveTo(crystalPos)

            local isNear = false
            while tick() - waitStart < maxWaitTime and getgenv().AutoMining do
                if not target.Parent then
                    currentMiningTarget = nil
                    break
                end
                local dist = (root.Position - crystalPos).Magnitude
                if dist <= stopDistance then
                    isNear = true
                    break
                end
                task.wait(0.3)
            end

            if not isNear then
                currentMiningTarget = nil
                continue
            end

            humanoid:MoveTo(root.Position)
            task.wait(0.2)

            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(crystalPos.X, root.Position.Y, crystalPos.Z))
            task.wait(0.3)

            local safetyCounter = 0
            while target and target.Parent and getgenv().AutoMining and safetyCounter < 200 do
                PlayMiningAnimation(character)
                pcall(function()
                    PickaxeEvent:FireServer("Hit")
                end)

                task.wait(getgenv().MiningHitDelay)
                safetyCounter += 1

                if not target.Parent then
                    currentMiningTarget = nil
                    break
                end
            end
            currentMiningTarget = nil
        else
            currentMiningTarget = nil
        end
    end
end)

-- ============================================================================
-- // 6. UI CONTENT
-- ============================================================================

-- [ INFO TAB ] --
local memberCount = "N/A"
local onlineCount = "N/A"

local function fetchDiscordInfo()
    local req = request or http_request or (syn and syn.request)
    if not req then return end
    local ok, res = pcall(function()
        return req({
            Url     = "https://discord.com/api/v9/invites/XmWf3YQPpZ?with_counts=true",
            Method  = "GET",
            Headers = { ["User-Agent"] = "Mozilla/5.0" }
        })
    end)
    if ok and res and res.StatusCode == 200 then
        local ok2, data = pcall(function() return Services.HttpService:JSONDecode(res.Body) end)
        if ok2 and data then
            memberCount = tostring(data.approximate_member_count   or "N/A")
            onlineCount = tostring(data.approximate_presence_count or "N/A")
        end
    end
end
fetchDiscordInfo()

local ServerInfo = InfoTab:Paragraph({
    Title         = "King Vypers | Official",
    Desc          = "• Member Count: " .. memberCount .. "\n• Online Count: " .. onlineCount,
    Image         = "rbxassetid://107726435417936",
    Thumbnail     = "rbxassetid://83197533072664",
    ThumbnailSize = 80,
    Buttons = {
        {
            Title    = "Copy Discord Invite",
            Color    = Color3.fromHex("#5707AB"),
            Icon     = "link",
            Callback = function()
                if setclipboard then setclipboard("https://discord.gg/XmWf3YQPpZ") end
            end
        },
        {
            Title    = "Update Info",
            Icon     = "refresh-cw",
            Callback = function()
                fetchDiscordInfo()
                ServerInfo:SetDesc("• Member Count: " .. memberCount .. "\n• Online Count: " .. onlineCount)
            end
        }
    }
})

-- [ MAIN TAB ] --
local FishingSection = MainTab:Section({ Title = "Auto Fishing Settings" })

FishingSection:Toggle({
    Title    = "Auto Fishing",
    Icon     = "zap",
    State    = false,
    Callback = function(state)
        getgenv().AutoFishing = state
        if not state then
            lagiNungguIkan = false
        end
    end
})

-- AUTO MINING SECTION
local MiningSection = MainTab:Section({ Title = "Auto Mining Settings" })

MiningSection:Toggle({
    Title    = "Auto Mining",
    Icon     = "pickaxe",
    State    = false,
    Callback = function(state)
        getgenv().AutoMining = state
        currentMiningTarget = nil
    end
})

MiningSection:Input({
    Title    = "Walk Speed",
    Icon     = "footprints",
    Value    = tostring(getgenv().MiningWalkSpeed),
    Placeholder = "Default: 16",
    Callback = function(val)
        local angka = tonumber(val)
        if angka and angka > 0 then
            getgenv().MiningWalkSpeed = angka
        end
    end
})

MiningSection:Input({
    Title    = "Stop Distance (stud)",
    Icon     = "ruler",
    Value    = tostring(getgenv().MiningStopDistance),
    Placeholder = "Default: 5",
    Callback = function(val)
        local angka = tonumber(val)
        if angka and angka > 0 then
            getgenv().MiningStopDistance = angka
        end
    end
})

MiningSection:Input({
    Title    = "Hit Delay (detik)",
    Icon     = "timer",
    Value    = tostring(getgenv().MiningHitDelay),
    Placeholder = "Contoh: 1.6",
    Callback = function(val)
        local angka = tonumber(val)
        if angka and angka > 0 then
            getgenv().MiningHitDelay = angka
        end
    end
})

-- [ AUTOMATIC TAB ] --
local SellFishSection = AutomaticTab:Section({ Title = "Auto Sell Ikan" })

SellFishSection:Toggle({
    Title    = "Automatic Sell All Fish",
    Icon     = "fish",
    State    = false,
    Callback = function(state)
        getgenv().AutoSell = state
        if state then
            sellTimer = 0 
        end
    end
})

SellFishSection:Input({
    Title    = "Interval Waktu (Menit)",
    Icon     = "clock",
    Value    = tostring(getgenv().AutoSellInterval),
    Placeholder = "Masukkan angka (menit)...",
    Callback = function(val)
        local angka = tonumber(val)
        if angka and angka > 0 then
            getgenv().AutoSellInterval = angka
            sellTimer = 0 
        end
    end
})

local SellCrystalSection = AutomaticTab:Section({ Title = "Auto Sell Crystal" })

SellCrystalSection:Toggle({
    Title    = "Automatic Sell All Crystal",
    Icon     = "gem",
    State    = false,
    Callback = function(state)
        getgenv().AutoSellCrystal = state
        if state then
            sellCrystalTimer = 0
        end
    end
})

SellCrystalSection:Input({
    Title    = "Interval Waktu (Menit)",
    Icon     = "clock",
    Value    = tostring(getgenv().AutoSellCrystalInterval),
    Placeholder = "Masukkan angka (menit)...",
    Callback = function(val)
        local angka = tonumber(val)
        if angka and angka > 0 then
            getgenv().AutoSellCrystalInterval = angka
            sellCrystalTimer = 0
        end
    end
})

local AutoFavSection = AutomaticTab:Section({ Title = "Auto Favorite Settings" })

AutoFavSection:Toggle({
    Title    = "Auto Favorite",
    Icon     = "star",
    State    = false,
    Callback = function(state)
        getgenv().AutoFavorite = state
    end
})

AutoFavSection:Input({
    Title    = "Minimal Berat (Kg)",
    Icon     = "scale",
    Value    = tostring(getgenv().AutoFavoriteMinWeight),
    Placeholder = "Contoh: 25",
    Callback = function(val)
        local angka = tonumber(val)
        if angka and angka > 0 then
            getgenv().AutoFavoriteMinWeight = angka
        end
    end
})

-- [ SETTINGS TAB ] --
local GeneralSection = SettingsTab:Section({ Title = "General Settings" })

GeneralSection:Toggle({
    Title    = "Anti AFK",
    Icon     = "shield",
    State    = false,
    Callback = function(state)
        ToggleAntiAFK(state)
    end
})

-- ============================================================================
-- // 7. OPEN BUTTON & INIT
-- ============================================================================
Window:EditOpenButton({
    Title           = "Open King Akbar",
    Icon            = "crown",
    CornerRadius    = UDim.new(0, 12),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#ffffff")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#0a0a0a")),
    }),
    Enabled   = true,
    Draggable = true,
})

Window:SetIconSize(47)
WindUI:SetTheme("dark")

-- Membuka Tab Info sebagai halaman utama saat UI pertama kali muncul
InfoTab:Select()
