local RAW_URL = "https://raw.githubusercontent.com/AwoakwoakSikat/uikings/refs/heads/main/VypersLib44.lua"
local Vypers  = loadstring(game:HttpGet(RAW_URL))()
-- Nonaktifkan print & warn untuk modul ini agar console tidak spam
local print = function(...) end
local warn = function(...) end
-- ================================================================
--  SETUP GLOBAL  (panggil SEBELUM CreateWindow)
-- ================================================================
Vypers:SetFolder("VypersDemo")                    -- folder tempat simpan config
Vypers:SetAccent(Color3.fromRGB(120, 90, 240))    -- warna aksen global
Vypers:SetTheme({                                 -- override warna theme apapun (opsional)
    -- Success = Color3.fromRGB(80, 200, 130),     -- contoh ganti warna "success"
    -- Text    = Color3.fromRGB(240, 240, 255),    -- contoh ganti warna teks
})

-- ================================================================
--  LOADING SCREEN DULU (SEBELUM CreateWindow!)
--  biar kartu progress udah kelihatan sebelum build UI yang berat.
-- ================================================================
Vypers:SetBuildBudget(4)   -- max 4ms kerja UI per frame -> game tetep smooth

local Loader = Vypers:CreateLoadingScreen({
    Title    = "King Vypers",
    SubTitle = "Menyiapkan antarmuka...",
    Accent   = Color3.fromRGB(120, 90, 240),
})
task.wait()   -- 1 frame biar loading screen kegambar dulu

local Window = Vypers:CreateWindow({
    Title           = "King Vypers",                     -- judul di kiri atas
    Icon            = "rbxassetid://107726435417936",    -- logo pas window di-minimize
    FloatIconRadius = 14,                               -- sudut logo minimize: 0 tajam | 14 squircle | 25 bulat
    SubTitle        = "FAM V0.8",                            -- badge kecil sebelah judul (alias: Version)
    Background      = "rbxassetid://97514324988224",     -- gambar backdrop window
    BackgroundTransparency = 0,                          -- transparansi gambar backdrop (0 = solid)
    Overlay         = 0.3,                               -- tint gelap di atas gambar (0 terang .. 1 gelap)
    Size            = UDim2.new(0, 560, 0, 360),         -- ukuran awal window
    MinSize         = Vector2.new(480, 300),             -- batas minimal resize
    MaxSize         = Vector2.new(720, 480),             -- batas maksimal resize
    SideBarWidth    = 150,                               -- lebar sidebar tab
    Resizable       = true,                              -- boleh di-resize (pojok kanan bawah)
    Transparent     = false,                              -- mode glass (nyalain transparansi default)

    -- --- transparansi tiap layer (0 = solid .. 1 = ilang total) ---
    SurfaceTransparency = 0.3,   -- card tiap element
    SectionTransparency = 0.3,  -- panel section
    TabTransparency     = 0.3,   -- tombol tab sidebar

    -- --- warna background item ---
    ItemColor    = Color3.fromRGB(40, 40, 60),   -- card element
    SectionColor = Color3.fromRGB(28, 28, 44),   -- panel section
    TabColor     = Color3.fromRGB(34, 34, 52),   -- tab sidebar
    WindowColor  = Color3.fromRGB(20, 20, 30),   -- warna dasar window
    Accent       = Color3.fromRGB(120, 90, 240), -- aksen (bisa juga lewat SetAccent)
    -- Theme      = { Surface = ..., Border = ... }, -- override penuh sekaligus

    ToggleKey   = Enum.KeyCode.RightShift,  -- tombol buat show/hide window
    Deferred    = true,  -- build UI hidden dulu, reveal setelah loading kelar
    Folder      = "VypersDemo",             -- folder config (sama kayak SetFolder)
})

-- ================================================================
--  LOADING SCREEN  (progress bar clean di pojok kanan bawah)
--  UI di-build hidden + kesebar antar-frame biar gak nge-frame;
--  window baru MUNCUL setelah semua keload (lihat bagian paling akhir).
-- ================================================================
-- (Loader udah dibuat di atas, sebelum CreateWindow)

-- ================================================================
--  TAG DI TITLE BAR  (pill kecil sebelah judul)
-- ================================================================
Window:Tag({ Title = "PREMIUM",   Color = Color3.fromRGB(220, 180, 70) })                 -- pill teks doang
Window:Tag({ Title = "Protected", Color = Color3.fromRGB(80, 190, 120) })  -- pill + icon
Window:Tag({ Title = "VypersUI V0.4", Color = Color3.fromRGB(80, 190, 120) })  -- pill + icon

-- Window:Tag({ Title = "NEW", Radius = 4 })   -- Radius atur sudut pill (default 9)

-- ================================================================
--  Fishing Tab
-- ================================================================
Loader:Set(0.1, "Fishing")
task.wait()
local FishingTab = Window:CreateTab({ Title = "Fishing", Icon = "fish" })
local InstantFish = FishingTab:CreateSection({ Title = "Instant Fishing", Opened = true })

local instantFishEnabled = false
local instantFishTask = nil
local instantFishDelay = 3

InstantFish:CreateInput({
    Id = "instant_fish_delay",
    Title = "Fish Delay",
    Placeholder = "Angka (Contoh: 3)",
    Default = tostring(instantFishDelay),
    Callback = function(input)
        local val = tonumber(input)
        if val then
            instantFishDelay = val
            print("[Instant Fish] Delay diatur ke: " .. val .. " detik")
        else
            print("[Instant Fish] Input delay tidak valid!")
        end
    end
})

InstantFish:CreateToggle({
    Id = "instant_fishing_toggle",
    Title = "Instant Fishing",
    Icon = "zap",
    Default = instantFishEnabled,
    Callback = function(state)
        instantFishEnabled = state
        if state then
            print("[Instant Fish] ON")
            Window:Notify({
                Title = "Instant Fishing Active",
                Content = "Jika ikan sering lepas, silakan naikkan Fish Delay!",
                Type = "warning",
                Duration = 4
            })
            
            instantFishTask = task.spawn(function()
                local RS = game:GetService("ReplicatedStorage")
                local LP = game:GetService("Players").LocalPlayer
                local Knit = RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services
                
                local FishingRF = Knit.FishingReplicationService.RF
                local RewardRF  = Knit.FishingRewardService.RF
                local RewardRE  = Knit.FishingRewardService.RE
                
                local START_FISHING      = FishingRF.StartFishing
                local THROW_FLOATER      = FishingRF.ThrowFloater
                local CONFIRM_CAST       = FishingRF.ConfirmFloatingCast
                local REQUEST_FISH_BITE  = RewardRF.RequestFishBite
                local START_PULLING      = FishingRF.StartPulling
                local FISHING_PULL_INPUT = RewardRF.FishingPullInput
                local STOP_FISHING       = FishingRF.StopFishing
                local PULL_STATE_EVENT   = RewardRE:WaitForChild("FishingPullState")
                
                local FLOATER = "Floater_Doll"
                local FLOATER_PROPS = {
                    LightInfluence = 0,
                    Transparency   = 0.12,
                    LightEmission  = 0.6,
                    Color          = Color3.new(0, 1, 1),
                    FaceCamera     = true,
                    Width          = 0.16
                }
                
                local function getCastPos()
                    local char = LP.Character or LP.CharacterAdded:Wait()
                    local hrp = char:WaitForChild("HumanoidRootPart")
                    local playerPos = hrp.Position
                    local lookDir = hrp.CFrame.LookVector
                    local targetXZ = playerPos + (lookDir * 15)
                    
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {char}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.IgnoreWater = false
                    
                    local origin = targetXZ + Vector3.new(0, 15, 0)
                    local result = workspace:Raycast(origin, Vector3.new(0, -100, 0), rayParams)
                    local castPos = result and result.Position or (targetXZ + Vector3.new(0, -8, 0))
                    
                    local tool = char:FindFirstChildOfClass("Tool")
                    local rodName = tool and tool.Name or "BananaRod"
                    return playerPos, castPos, rodName
                end
                
                local isResolved = false
                local activeSessionId = nil
                local lastTooEarlyNotify = 0
                
                local function notifyTooEarly()
                    local now = tick()
                    if now - lastTooEarlyNotify > 5 then
                        lastTooEarlyNotify = now
                        Window:Notify({
                            Title = "Ikan Lepas!",
                            Content = "Fish delay terlalu cepat. Silakan naikkan Fish Delay.",
                            Type = "error",
                            Duration = 4
                        })
                    end
                end
                
                local resolvedConn
                resolvedConn = PULL_STATE_EVENT.OnClientEvent:Connect(function(data)
                    if type(data) == "table" then
                        if data.sessionId and data.type == "resolved" and data.sessionId == activeSessionId then
                            isResolved = true
                        elseif data.type == "cancelled" or data.type == "failed" or (data.reason and tostring(data.reason):lower():find("early")) then
                            notifyTooEarly()
                        end
                    end
                end)
                
                while instantFishEnabled do
                    if shared.isDoingEvent then task.wait(1) continue end
                    
                    isResolved = false
                    activeSessionId = nil
                    local playerPos, castPos, rodName = getCastPos()
                    
                    pcall(function() START_FISHING:InvokeServer(rodName, FLOATER) end)
                    pcall(function() THROW_FLOATER:InvokeServer(playerPos, castPos, rodName, FLOATER, FLOATER_PROPS, 10) end)
                    pcall(function() CONFIRM_CAST:InvokeServer(castPos) end)
                    
                    local sessionId = nil
                    local ok, result = pcall(function() return REQUEST_FISH_BITE:InvokeServer(castPos) end)
                    if ok and type(result) == "table" and result.SessionId then
                        sessionId = result.SessionId
                        activeSessionId = sessionId
                        print("[Instant Fish] Session:", sessionId)
                    else
                        print("[Instant Fish] RequestFishBite gagal / tidak ada session (Too Early!).")
                        notifyTooEarly()
                    end
                    
                    task.wait(instantFishDelay)
                    
                    pcall(function() START_PULLING:InvokeServer() end)
                    
                    if sessionId then
                        pcall(function() FISHING_PULL_INPUT:InvokeServer(sessionId, "begin") end)
                        local waitStart = tick()
                        while not isResolved and instantFishEnabled and tick() - waitStart < 15 do
                            task.spawn(function()
                                pcall(function() FISHING_PULL_INPUT:InvokeServer(sessionId, "tap") end)
                            end)
                            task.wait()
                        end
                        print("[Instant Fish] Selesai! resolved:", isResolved)
                    else
                        print("[Instant Fish] Gagal dapet SessionId, skip...")
                    end
                    
                    pcall(function() STOP_FISHING:InvokeServer() end)
                end
                
                resolvedConn:Disconnect()
            end)
        else
            print("[Instant Fish] OFF")
            instantFishEnabled = false
            if instantFishTask then
                task.cancel(instantFishTask)
                instantFishTask = nil
            end
        end
    end
})

-- ================================================================
--  Legit Fish Section
-- ================================================================
local LegitFishSection = FishingTab:CreateSection({ Title = "Legit Fish", Box = true, Opened = false })

local legitFishingEnabled = false
local legitFishingTask = nil

LegitFishSection:CreateToggle({
    Id = "legit_fishing_toggle",
    Title = "Legit Fishing",
    Icon = "fish",
    Default = false,
    Callback = function(state)
        legitFishingEnabled = state
        if state then
            print("[Legit Fish] ON")
            Window:Notify({
                Title = "Legit Fishing Active",
                Content = "Sedang menjalankan mode Legit Fishing!",
                Type = "success",
                Duration = 3
            })
            
            -- ⏱️ DELAY 1 DETIK CUMA DI SINI (sebelum spawn, cuma sekali)
            task.wait(1)
            print("[Legit Fish] Delay 1 detik selesai, mulai mancing!")
            
            legitFishingTask = task.spawn(function()
                local player = game:GetService("Players").LocalPlayer
                local char = player.Character or player.CharacterAdded:Wait()
                local VIM = game:GetService("VirtualInputManager")
                local Knit = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services
                local ReplicationRF = Knit.FishingReplicationService.RF
                local RewardRF = Knit.FishingRewardService.RF
                local RewardRE = Knit.FishingRewardService.RE
                
                -- Auto detect
                local reelButton = player.PlayerGui.FishingMobile:FindFirstChild("ReelButton")
                local IS_MOBILE = reelButton ~= nil
                print(IS_MOBILE and "Mobile detected!" or "PC detected!")
                
                local currentUUID = nil
                local isPulling = false
                local castSuccess = false
                local castFailed = false
                
                -- Listen FishCaught
                local caughtConn = RewardRE.FishCaught.OnClientEvent:Connect(function(data)
                    if data then
                        print("[CAUGHT]", data.FishID, "|", data.Weight, "Kg")
                    end
                    isPulling = false
                end)
                
                -- Hook ConfirmFloatingCast + StopFishing via __namecall
                local ConfirmRF = Knit.FishingReplicationService.RF.ConfirmFloatingCast
                local StopRF = Knit.FishingReplicationService.RF.StopFishing
                local mt = getrawmetatable(game)
                local oldNamecall = mt.__namecall
                setreadonly(mt, false)
                mt.__namecall = function(self, ...)
                    local method = getnamecallmethod()
                    if self == ConfirmRF and method == "InvokeServer" then
                        castSuccess = true
                        print("[Cast Sukses! ConfirmFloatingCast datang]")
                    elseif self == StopRF and method == "InvokeServer" then
                        castFailed = true
                        print("[Cast Gagal! StopFishing datang]")
                    end
                    return oldNamecall(self, ...)
                end
                setreadonly(mt, true)
                
                -- Langsung masuk loop, TANPA delay lagi
                while legitFishingEnabled do
                    castSuccess = false
                    castFailed = false
                    currentUUID = nil
                    isPulling = false
                    
                    -- [1] Cek dan equip rod
                    local equippedTool = char:FindFirstChildOfClass("Tool")
                    if equippedTool then
                        print("[1] Sudah pegang rod:", equippedTool.Name)
                    else
                        print("[1] Belum pegang rod, equip slot 1...")
                        VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                        task.wait(0.1)
                        VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                        task.wait(0.5)
                        print("[1] Slot 1 equipped!")
                    end
                    
                    -- [2] Cast loop sampai sukses
                    local fillbar = player.PlayerGui.FishingPanel.ThrowFrame.FillContainer.Fillbar
                    repeat
                        if not legitFishingEnabled then break end
                        castSuccess = false
                        castFailed = false
                        currentUUID = nil
                        print("[2] Casting...")
                        if IS_MOBILE then
                            firesignal(reelButton.MouseButton1Down)
                        else
                            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        end
                        
                        local maxFillWait = 0
                        repeat 
                            task.wait(0.05) 
                            maxFillWait += 0.05
                        until fillbar.Size.Y.Scale >= 0.99 or castFailed or not legitFishingEnabled or maxFillWait > 3
                        
                        if IS_MOBILE then
                            firesignal(reelButton.MouseButton1Up)
                        else
                            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end
                        
                        local timeout = 0
                        while not castSuccess and not castFailed and timeout < 10 and legitFishingEnabled do
                            task.wait(0.1)
                            timeout += 0.1
                        end
                        
                        if castFailed then
                            print("[Cast Gagal! StopFishing detected, retry...")
                            task.wait(1)
                        elseif not castSuccess then
                            print("[Cast Gagal] Timeout 10 detik, retry...")
                        end
                    until castSuccess or not legitFishingEnabled
                    
                    if not legitFishingEnabled then break end
                    print("[3] Cast done! Waiting fish...")
                    
                    -- [3] Tunggu UUID pake event
                    local uuidEvent = Instance.new("BindableEvent")
                    local uuidConn
                    uuidConn = RewardRE.FishingPullState.OnClientEvent:Connect(function(data)
                        if data and data.sessionId and currentUUID == nil then
                            currentUUID = data.sessionId
                            print("[UUID]", currentUUID)
                            uuidConn:Disconnect()
                            uuidEvent:Fire()
                        end
                    end)
                    
                    local uuidTimeout = task.delay(15, function()
                        uuidEvent:Fire()
                    end)
                    uuidEvent.Event:Wait()
                    uuidEvent:Destroy()
                    pcall(function() task.cancel(uuidTimeout) end)
                    
                    if currentUUID == nil then
                        print("[ERROR] UUID timeout!")
                        if not legitFishingEnabled then break end
                        task.wait(1)
                        continue
                    end
                    
                    -- [4] Pull instant
                    print("[4] Pulling UUID:", currentUUID)
                    isPulling = true
                    
                    local isResolved = false
                    local resolvedConn2
                    resolvedConn2 = RewardRE.FishingPullState.OnClientEvent:Connect(function(data)
                        if type(data) == "table" and data.sessionId == currentUUID and data.type == "resolved" then
                            isResolved = true
                            isPulling = false
                        end
                    end)
                    
                    RewardRF.FishingPullInput:InvokeServer(currentUUID, "begin")
                    task.wait(0.05)
                    
                    local pullStart = tick()
                    while isPulling and legitFishingEnabled and tick() - pullStart < 15 do
                        task.spawn(function()
                            for i = 1, 5 do
                                pcall(function() RewardRF.FishingPullInput:InvokeServer(currentUUID, "tap") end)
                            end
                        end)
                        task.wait()
                    end
                    resolvedConn2:Disconnect()
                    print("[5] Done! Looping...")
                    task.wait(3)
                end
                
                -- Cleanup
                caughtConn:Disconnect()
                setreadonly(mt, false)
                mt.__namecall = oldNamecall
                setreadonly(mt, true)
                print("[Legit Fish] OFF")
            end)
        else
            print("[Legit Fish] Stopping...")
            legitFishingEnabled = false
            if legitFishingTask then
                task.cancel(legitFishingTask)
                legitFishingTask = nil
            end
        end
    end
})
local autoMinigameEnabled = false
local autoMinigameConnUUID = nil
local autoMinigameConnCaught = nil

LegitFishSection:CreateToggle({
    Id = "auto_minigame_only_toggle",
    Title = "Auto Minigame Only",
    Icon = "gamepad-2",
    Default = false,
    Callback = function(state)
        autoMinigameEnabled = state
        local Knit = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services
        local RewardRF = Knit.FishingRewardService.RF
        local RewardRE = Knit.FishingRewardService.RE
        
        if state then
            print("[Auto Minigame] ON")
            Window:Notify({
                Title = "Auto Minigame Active",
                Content = "Hanya akan menjalankan minigame saat casting manual!",
                Type = "info",
                Duration = 3
            })
            
            local isPulling = false
            local pullTask = nil
            
            autoMinigameConnCaught = RewardRE.FishCaught.OnClientEvent:Connect(function(data)
                isPulling = false
                if pullTask then
                    task.cancel(pullTask)
                    pullTask = nil
                end
                print("[Auto Minigame] Ikan ketangkep!")
            end)
            
            autoMinigameConnUUID = RewardRE.FishingPullState.OnClientEvent:Connect(function(data)
                if data and data.sessionId and autoMinigameEnabled then
                    local currentUUID = data.sessionId
                    print("[Auto Minigame] Minigame mulai! UUID:", currentUUID)
                    isPulling = true
                    RewardRF.FishingPullInput:InvokeServer(currentUUID, "begin")
                    pullTask = task.spawn(function()
                        while isPulling and autoMinigameEnabled do
                            RewardRF.FishingPullInput:InvokeServer(currentUUID, "tap")
                            task.wait()
                        end
                    end)
                end
            end)
        else
            print("[Auto Minigame] OFF")
            if autoMinigameConnUUID then 
                autoMinigameConnUUID:Disconnect() 
                autoMinigameConnUUID = nil 
            end
            if autoMinigameConnCaught then 
                autoMinigameConnCaught:Disconnect() 
                autoMinigameConnCaught = nil 
            end
        end
    end
})


-- ================================================================
--  Support Fishing Section
-- ================================================================
local SupportFishSection = FishingTab:CreateSection({ Title = "Support Fishing", Box = true, Opened = false })

-- =============================================
-- HIDE FISH CAUGHT UI MODULE (PERMANENT HIDE)
-- =============================================
local HideFishCaught = (function()
    local M = { Enabled = false }
    local lp = game:GetService("Players").LocalPlayer
    local PlayerGui = lp:WaitForChild("PlayerGui")

    local targets = {
        { gui = "NewFishDiscovery_Display", name = "FishImg" },
        { gui = "NewFishDiscovery",         name = "FishImg" },
        { gui = "NewFishDiscovery_Display", name = "ShineImg" },
        { gui = "NewFishDiscovery",         name = "ShineImg" },
        { gui = "NewFishDiscovery_Display", name = "Viginatte" },
        { gui = "NewFishDiscovery",         name = "Viginatte" },
    }

    local function setVisibility(state)
        -- 1. Hide/Show main targets (Fish, Shine, Vignette)
        for _, t in ipairs(targets) do
            local gui = PlayerGui:FindFirstChild(t.gui)
            if gui then
                local obj = gui:FindFirstChild(t.name, true)
                if obj then
                    obj.Visible = state
                    if state == false then
                        print("[DDS] Hidden:", t.gui, "->", t.name)
                    else
                        print("[DDS] Restored:", t.gui, "->", t.name)
                    end
                end
            end
        end

        -- 2. Hide/Show Hotbar icons
        local hotbar = PlayerGui:FindFirstChild("HotbarGUI")
        if hotbar then
            local container = hotbar:FindFirstChild("HotbarContainer")
            if container then
                for _, slot in ipairs(container:GetChildren()) do
                    if slot:IsA("Frame") and slot.Name:find("Slot") then
                        local btn = slot:FindFirstChild("Button")
                        if btn then
                            local icon = btn:FindFirstChild("Icon")
                            if icon then
                                icon.Visible = state
                            end
                        end
                    end
                end
            end
        end
        
        if state == false then
            print("[DDS] Done! Semua gambar ikan permanen hidden!")
        else
            print("[DDS] Done! Semua gambar ikan dikembalikan!")
        end
    end

    function M.Start()
        if M.Enabled then return end
        M.Enabled = true
        setVisibility(false) -- Langsung hide semua
        Window:Notify({ 
            Title = "Anti Lag Active", 
            Content = "Semua gambar & efek ikan disembunyikan permanen!", 
            Type = "success", 
            Duration = 3 
        })
    end
    
    function M.Stop()
        if not M.Enabled then return end
        M.Enabled = false
        setVisibility(true) -- Balikin lagi kalau dimatikan
        Window:Notify({ 
            Title = "Anti Lag Disabled", 
            Content = "Tampilan ikan dikembalikan ke normal.", 
            Type = "info", 
            Duration = 3 
        })
    end
    
    return M
end)()

SupportFishSection:CreateToggle({
    Id = "hide_fish_caught_ui_toggle",
    Title = "Disable Fish Notification",
    Icon = "eye-off",
    Default = false,
    Callback = function(state)
        if state then
            HideFishCaught.Start()
        else
            HideFishCaught.Stop()
        end
    end
})

-- =============================================
-- AUTO EQUIP FLOATER MODULE
-- =============================================
local AutoEquipFloater = (function()
    local M = {
        Enabled = false,
        Thread = nil,
        CurrentEquipped = nil,
    }

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RodShopConfig = require(ReplicatedStorage.Modules.RodShopConfig)

    local Knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit
    local RodShopService = Knit.Services.RodShopService

    local GetOwnedItems = RodShopService.RF.GetOwnedItems
    local EquipFloater = RodShopService.RF.EquipFloater

    -- Cache OwnedItems
    local cachedOwnedFloaters = nil
    local lastFetchTime = 0
    local CACHE_DURATION = 10

    local function GetOwnedFloaters()
        local now = os.clock()
        if cachedOwnedFloaters and (now - lastFetchTime) < CACHE_DURATION then
            return cachedOwnedFloaters
        end

        local success, data = pcall(function()
            return GetOwnedItems:InvokeServer()
        end)

        if success and data and data.OwnedFloaters then
            cachedOwnedFloaters = data.OwnedFloaters
            lastFetchTime = now
            return cachedOwnedFloaters
        end

        warn("[AutoEquipFloater] Gagal ambil OwnedItems")
        return cachedOwnedFloaters
    end

    local function GetBestFloater()
        local ownedFloaters = GetOwnedFloaters()
        if not ownedFloaters then return nil end

        local bestFloater
        local bestInfo

        for _, floaterId in ipairs(ownedFloaters) do
            -- skip hidden floater ids (biasanya default/placeholder)
            local isHidden = false
            if RodShopConfig.HiddenFloaterIds then
                for _, hiddenId in ipairs(RodShopConfig.HiddenFloaterIds) do
                    if hiddenId == floaterId then
                        isHidden = true
                        break
                    end
                end
            end

            if not isHidden then
                local info = RodShopConfig.GetFloaterById(floaterId)

                if info then
                    if not bestInfo or RodShopConfig.CompareByRarity(bestInfo, info) then
                        bestInfo = info
                        bestFloater = floaterId
                    end
                end
            end
        end

        return bestFloater
    end

    local isEquipping = false

    local function EquipBestFloater()
        if isEquipping then return end
        isEquipping = true

        local bestFloater = GetBestFloater()

        if bestFloater and bestFloater ~= M.CurrentEquipped then
            local success, result = pcall(function()
                return EquipFloater:InvokeServer(bestFloater)
            end)

            if success then
                M.CurrentEquipped = bestFloater
                print("[AutoEquipFloater] Equip:", bestFloater)
            else
                warn("[AutoEquipFloater] Gagal equip floater:", result)
            end
        end

        task.wait(0.5)
        isEquipping = false
    end

    function M.Start()
        if M.Enabled then return end
        M.Enabled = true
        print("[AutoEquipFloater] ON")
        Window:Notify({ Title = "Auto Equip Floater Active", Content = "Otomatis mengequip floater terbaik.", Type = "info", Duration = 3 })

        EquipBestFloater()

        M.Thread = task.spawn(function()
            while M.Enabled do
                EquipBestFloater()
                task.wait(5)
            end
        end)
    end

    function M.Stop()
        if not M.Enabled then return end
        M.Enabled = false
        if M.Thread then
            task.cancel(M.Thread)
            M.Thread = nil
        end
        print("[AutoEquipFloater] OFF")
        Window:Notify({ Title = "Auto Equip Floater Deactivated", Content = "Fitur auto equip floater dimatikan.", Type = "success", Duration = 3 })
    end

    return M
end)()

SupportFishSection:CreateToggle({
    Id = "auto_equip_floater_toggle",
    Title = "Auto Equip Floater",
    Icon = "zap",
    Default = false,
    Callback = function(state)
        if state then
            AutoEquipFloater.Start()
        else
            AutoEquipFloater.Stop()
        end
    end
})

-- =============================================
-- AUTO EQUIP ROD MODULE
-- =============================================
local AutoEquipRod = (function()
    local M = {
        Enabled = false,
        Thread = nil,
    }

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RodConfig = require(ReplicatedStorage.Modules.RodShopConfig)

    local Knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit
    local RodShopService = Knit.Services.RodShopService

    local GetOwnedItems = RodShopService.RF.GetOwnedItems
    local EquipRod = RodShopService.RF.EquipRod

    -- Cache OwnedItems biar gak spam RemoteFunction tiap detik
    local cachedOwnedRods = nil
    local lastFetchTime = 0
    local CACHE_DURATION = 10

    local function GetOwnedRods()
        local now = os.clock()
        if cachedOwnedRods and (now - lastFetchTime) < CACHE_DURATION then
            return cachedOwnedRods
        end

        local success, data = pcall(function()
            return GetOwnedItems:InvokeServer()
        end)

        if success and data and data.OwnedRods then
            cachedOwnedRods = data.OwnedRods
            lastFetchTime = now
            return cachedOwnedRods
        end

        warn("[AutoEquipRod] Gagal ambil OwnedItems")
        return cachedOwnedRods
    end

    local function GetBestRod()
        local ownedRods = GetOwnedRods()
        if not ownedRods then return nil end

        local bestRod
        local bestInfo

        for _, rodId in ipairs(ownedRods) do
            local info = RodConfig.GetRodById(rodId)

            if info and not info.SkinOnly then
                if not bestInfo or RodConfig.CompareByRarity(bestInfo, info) then
                    bestInfo = info
                    bestRod = rodId
                end
            end
        end

        return bestRod
    end

    -- Cek Tool yang dipegang itu beneran rod, bukan fish/bait/item lain
    local function IsHoldingRod(character)
        if not character then return false end

        local tool = character:FindFirstChildOfClass("Tool")
        if not tool then
            return false
        end

        local info = RodConfig.GetRodById(tool.Name)

        if not info then
            local rodIdAttr = tool:GetAttribute("RodId") or tool:GetAttribute("Id")
            if rodIdAttr then
                info = RodConfig.GetRodById(rodIdAttr)
            end
        end

        return info ~= nil
    end

    local isEquipping = false

    local function EquipBestRod()
        if isEquipping then return end
        isEquipping = true

        local bestRod = GetBestRod()

        if bestRod then
            local success, err = pcall(function()
                EquipRod:InvokeServer(bestRod)
            end)

            if success then
                print("[AutoEquipRod] Equip:", bestRod)
            else
                warn("[AutoEquipRod] Gagal equip rod:", err)
            end
        else
            warn("[AutoEquipRod] Best rod tidak ditemukan")
        end

        task.wait(0.5)
        isEquipping = false
    end

    function M.Start()
        if M.Enabled then return end
        M.Enabled = true
        print("[AutoEquipRod] ON")
        Window:Notify({ Title = "Auto Equip Rod Active", Content = "Otomatis mengequip rod jika tangan kosong.", Type = "info", Duration = 3 })

        M.Thread = task.spawn(function()
            local LP = game:GetService("Players").LocalPlayer
            while M.Enabled do
                local char = LP.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if not IsHoldingRod(char) then
                            EquipBestRod()
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end

    function M.Stop()
        if not M.Enabled then return end
        M.Enabled = false
        if M.Thread then
            task.cancel(M.Thread)
            M.Thread = nil
        end
        print("[AutoEquipRod] OFF")
        Window:Notify({ Title = "Auto Equip Rod Deactivated", Content = "Fitur auto equip rod dimatikan.", Type = "success", Duration = 3 })
    end

    return M
end)()

SupportFishSection:CreateToggle({
    Id = "auto_equip_rod_toggle",
    Title = "Auto Equip Rod",
    Icon = "zap",
    Default = false,
    Callback = function(state)
        if state then
            AutoEquipRod.Start()
        else
            AutoEquipRod.Stop()
        end
    end
})
-- =============================================
-- WALK ON WATER MODULE
-- =============================================
local WalkOnWater = (function()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local M = { Enabled = false, Platform = nil, AlignPos = nil, Connection = nil }
    local PLATFORM_SIZE = 14
    local OFFSET = 2.5
    local WATER_Y = nil
    local TICK = 0
    local SCAN_INTERVAL = 10
    
    local function getChar()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        return char, hum, hrp
    end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = false
    
    local function isAboveWater(hrp)
        rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
        local result = Workspace:Raycast(hrp.Position, Vector3.new(0, -50, 0), rayParams)
        if result and result.Instance:IsA("Terrain") then
            return result.Material == Enum.Material.Water
        end
        return false
    end
    
    local function scanWaterY(hrp)
        rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
        local result = Workspace:Raycast(
            hrp.Position + Vector3.new(0, 100, 0),
            Vector3.new(0, -500, 0),
            rayParams
        )
        if result and result.Instance:IsA("Terrain") and result.Material == Enum.Material.Water then
            return result.Position.Y
        end
        return nil
    end
    
    local function createPlatform()
        if M.Platform then M.Platform:Destroy() end
        local p = Instance.new("Part")
        p.Name = "WaterLockPlatform"
        p.Size = Vector3.new(PLATFORM_SIZE, 1, PLATFORM_SIZE)
        p.Anchored = true
        p.CanCollide = true
        p.CanQuery = false
        p.CanTouch = false
        p.Transparency = 1
        p.Parent = Workspace
        M.Platform = p
    end
    
    local function setupAlign(hrp)
        if M.AlignPos then M.AlignPos:Destroy() end
        local att = hrp:FindFirstChild("WOW_Att") or Instance.new("Attachment")
        att.Name = "WOW_Att"
        att.Parent = hrp
        local ap = Instance.new("AlignPosition")
        ap.Attachment0 = att
        ap.MaxForce = math.huge
        ap.MaxVelocity = math.huge
        ap.Responsiveness = 200
        ap.RigidityEnabled = true
        ap.Parent = hrp
        M.AlignPos = ap
    end
    
    local function cleanup()
        if M.Connection then M.Connection:Disconnect() M.Connection = nil end
        if M.AlignPos then M.AlignPos:Destroy() M.AlignPos = nil end
        if M.Platform then M.Platform:Destroy() M.Platform = nil end
        WATER_Y = nil
        TICK = 0
    end
    
    function M.Start()
        if M.Enabled then return end
        local _, hum, hrp = getChar()
        if not hum or not hrp then
            print("[WOW] Karakter tidak ditemukan!")
            return
        end
        M.Enabled = true
        createPlatform()
        setupAlign(hrp)
        print("[WOW] ON")
        Window:Notify({ Title = "Walk on Water Active", Content = "Kamu sekarang bisa berjalan di atas air!", Type = "info", Duration = 3 })
        
        M.Connection = RunService.Heartbeat:Connect(function()
            if not M.Enabled then return end
            local _, curHum, curHRP = getChar()
            if not curHum or not curHRP then return end
            local pos = curHRP.Position
            TICK += 1
            
            if curHum:GetState() == Enum.HumanoidStateType.Swimming then
                curHRP.Velocity = Vector3.new(curHRP.Velocity.X, 60, curHRP.Velocity.Z)
            end
            
            if TICK % SCAN_INTERVAL == 0 then
                local y = scanWaterY(curHRP)
                if y then WATER_Y = y end
            end
            
            local aboveWater = isAboveWater(curHRP)
            if aboveWater and WATER_Y then
                M.Platform.CFrame = CFrame.new(pos.X, WATER_Y - 0.5, pos.Z)
                M.AlignPos.Position = Vector3.new(pos.X, WATER_Y + OFFSET, pos.Z)
            else
                M.Platform.CFrame = CFrame.new(pos.X, -9999, pos.Z)
                M.AlignPos.Position = pos
            end
        end)
    end
    
    function M.Stop()
        M.Enabled = false
        cleanup()
        print("[WOW] OFF")
        Window:Notify({ Title = "Walk on Water Deactivated", Content = "Fitur berjalan di atas air dimatikan.", Type = "success", Duration = 3 })
    end
    
    LocalPlayer.CharacterAdded:Connect(function()
        if M.Enabled then
            task.wait(0.5)
            cleanup()
            M.Enabled = false
            M.Start()
        end
    end)
    
    return M
end)()

SupportFishSection:CreateToggle({
    Id = "walk_on_water_toggle",
    Title = "Walk on Water",
    Icon = "waves",
    Default = false,
    Callback = function(state)
        if state then
            WalkOnWater.Start()
        else
            WalkOnWater.Stop()
        end
    end
})

-- =============================================
-- NOCLIP MODULE
-- =============================================
local noclipEnabled = false
local noclipConn = nil

local function setNoclip(state)
    noclipEnabled = state
    if state then
        noclipConn = game:GetService("RunService").Stepped:Connect(function()
            local char = game:GetService("Players").LocalPlayer.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        Window:Notify({ Title = "Noclip Active", Content = "Kamu sekarang bisa menembus objek!", Type = "info", Duration = 3 })
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
        local char = game:GetService("Players").LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = part:IsA("MeshPart") or part.Name == "HumanoidRootPart" and false or true
                end
            end
        end
        Window:Notify({ Title = "Noclip Deactivated", Content = "CanCollide telah dikembalikan ke normal.", Type = "success", Duration = 3 })
    end
end

SupportFishSection:CreateToggle({
    Id = "noclip_toggle",
    Title = "Noclip",
    Icon = "ghost",
    Default = false,
    Callback = function(state)
        setNoclip(state)
    end
})
-- ================================================================
--  Shop Tab
-- ================================================================
Loader:Set(0.25, "Shop")
task.wait()
local ShopTab = Window:CreateTab({ Title = "Shop", Icon = "fish" })
local AutoSellFish = ShopTab:CreateSection({ Title = "Auto Sell Fish", Opened = true })

-- =============================================
-- AUTO SELL MODULE
-- =============================================
local selectedRarities = {}
local autoSellInterval = 35 -- Default in minutes
local autoSellEnabled = false
local autoSellTask = nil

AutoSellFish:CreateMultiDropdown({
    Id = "auto_sell_rarity",
    Title = "Pilih Rarity",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary" },
    Default = {},
    Callback = function(selected)
        selectedRarities = {}
        if type(selected) == "table" then
            for _, rarity in ipairs(selected) do
                selectedRarities[rarity] = true
            end
        end
        print("[Auto Sell] Rarity dipilih:", #selected > 0 and table.concat(selected, ", ") or "All")
    end
})

AutoSellFish:CreateInput({
    Id = "auto_sell_interval",
    Title = "Auto Sell (Minutes)",
    Placeholder = "30",
    Default = tostring(autoSellInterval),
    Callback = function(text)
        local val = tonumber(text)
        if val and val > 0 then
            autoSellInterval = val
            print("[Auto Sell] Interval diatur ke:", val, "menit")
        else
            print("[Auto Sell] Input interval tidak valid!")
        end
    end
})

local function ExecuteSell()
    print("[AutoSell] Memulai Auto Sell (GUI Method)...")
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService") -- Panggil TweenService
    local LP = Players.LocalPlayer
    local PlayerGui = LP:FindFirstChild("PlayerGui")
    local RS = game:GetService("ReplicatedStorage")
    local Knit = RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services
    local FISH_SOLD = Knit.FishermanShopService.RE.FishSold
    
    local function waitForUI()
        print("⏳ Nunggu FishermanShopGUI kebuka...")
        local gui = PlayerGui:WaitForChild("FishermanShopGUI", 10)
        if not gui then
            print("❌ FishermanShopGUI ga muncul!")
            return false
        end
        print("✅ UI kebuka!")
        return true
    end
    
    local function clickButton(btn, name)
        local success = false
        while not success do
            local ok, err = pcall(function()
                firesignal(btn.MouseButton1Click)
            end)
            if ok then
                print("✅ Klik " .. name .. " berhasil!")
                success = true
            else
                print("❌ Gagal klik " .. name .. ":", err, "| Mencoba lagi...")
                task.wait(0.5)
            end
        end
        task.wait(0.5)
    end
    
    local character = LP.Character or LP.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local originalCFrame = nil
    
    if hrp then
        originalCFrame = hrp.CFrame
        print("[AutoSell] Tween ke lokasi sell...")
        
        local targetPosition = nil
        
        if game.PlaceId == 90457367396205 then
            -- Map 2 logic
            local hud = LP.PlayerGui:FindFirstChild("HUD")
            local statsPanel = hud and hud:FindFirstChild("PlayerStatsPanel", true)
            local levelLabel = statsPanel and statsPanel:FindFirstChild("LevelLabel", true)
            local level = 0
            if levelLabel then
                level = tonumber(levelLabel.Text:match("%d+")) or 0
            end
            local unlockIslands = {
                { name = "Bamboo",            pos = Vector3.new(-1119.28, 227.39, 256.52),    unlockLevel = 1  },
                { name = "Iceberg",           pos = Vector3.new(-521.57, 309.43, -818.11),    unlockLevel = 1  },
                { name = "Lost Whale Island", pos = Vector3.new(-2470.06, 65.96, -89.39),     unlockLevel = 10 },
                { name = "Bora Reef",         pos = Vector3.new(-3774.61, 200.02, 2078.67),   unlockLevel = 20 },
                { name = "Volcano Vent",      pos = Vector3.new(-1855.89, 316.16, 6046.96),   unlockLevel = 30 },
                { name = "Cape Town",         pos = Vector3.new(1259.36, 214.58, 2513.89),    unlockLevel = 35 },
            }
            local sellLocations = {
                Vector3.new(-605.20, 172.88, 25.43),
                Vector3.new(-2660.34, 172.12, 203.34),
                Vector3.new(-1409.31, 173.55, 400.75),
                Vector3.new(804.61, 187.62, 2952.89),
                Vector3.new(-3996.39, 171.44, 2028.85),
                Vector3.new(-1686.41, 173.81, 5931.25),
            }
            local validSellLocs = {}
            for _, sell in ipairs(sellLocations) do
                local nearest, nearestDist = nil, math.huge
                for _, island in ipairs(unlockIslands) do
                    local dist = (sell - island.pos).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = island
                    end
                end
                if nearest and level >= nearest.unlockLevel then
                    table.insert(validSellLocs, sell)
                end
            end
            local bestSellLoc = nil
            local bestDist = math.huge
            for _, loc in ipairs(validSellLocs) do
                local dist = (hrp.Position - loc).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestSellLoc = loc
                end
            end
            
            if bestSellLoc then
                targetPosition = bestSellLoc + Vector3.new(0, 15, 0)
            else
                targetPosition = sellLocations[1] + Vector3.new(0, 15, 0)
            end
        else
            -- Default / Map 1 logic (111385005478215)
            targetPosition = Vector3.new(280.2694396972656, 201.01766967773438 + 15, 1551.6795654296875)
        end
        
        -- Eksekusi Tween ke Lokasi Sell
        if targetPosition then
            local randomTime = math.random(30, 70) / 10 -- Random waktu antara 3.0 sampai 7.0 detik
            print("[AutoSell] Waktu tween ke shop: " .. randomTime .. " detik")
            
            local tweenInfo = TweenInfo.new(randomTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPosition)})
            tween:Play()
            tween.Completed:Wait() -- Tunggu sampai tween selesai
            task.wait(0.5) -- Kasih jeda dikit biar server sync posisi akhir
            print("✅ Sampai di lokasi sell!")
        end
    end
    
    local prompt = nil
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.ActionText == "Sell Fish" then
            prompt = v
            break
        end
    end
    
    if not prompt then
        print("❌ Prompt Sell Fish ga ketemu!")
        Window:Notify({ Title = "Auto Sell", Content = "Prompt Sell Fish tidak ditemukan!", Type = "error", Duration = 4 })
        if hrp and originalCFrame then 
            -- Tween balik kalau prompt ga ketemu
            local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            TweenService:Create(hrp, tweenInfo, {CFrame = originalCFrame}):Play()
        end
        return
    end
    
    print("🐟 Trigger Sell Fish...")
    local uiOpened = false
    while not uiOpened do
        fireproximityprompt(prompt)
        uiOpened = waitForUI()
        if not uiOpened then
            print("⚠️ UI Sell belum terbuka, mencoba fire proximity prompt lagi...")
            task.wait(1)
        end
    end
    
    task.wait(0.5)
    local ShopPanel = PlayerGui.FishermanShopGUI.ShopPanel
    local CartPanel = PlayerGui.FishermanShopGUI.CartPanel
    
    -- Listen FishSold sebelum klik confirm
    local sellDone = false
    local totalEarned = 0
    local soldConn
    soldConn = FISH_SOLD.OnClientEvent:Connect(function(data)
        sellDone = true
        totalEarned = data.Earned or 0
        print("💰 FishSold! Earned:", data.Earned, "| NewMoney:", data.NewMoney, "| Quantity:", data.Quantity)
        if data.SoldFish then
            for _, fish in ipairs(data.SoldFish) do
                print("   🐟", fish.Name, "x" .. fish.Count, "| Value:", fish.Value)
            end
        end
        soldConn:Disconnect()
    end)
    
    -- Step 1: Filter by selected rarities or "All"
    local validRarities = {"All", "Common", "Epic", "Legendary", "Rare", "Uncommon"}
    local raritiesToSell = {}
    for _, rarity in ipairs(validRarities) do
        if selectedRarities[rarity] then
            table.insert(raritiesToSell, rarity)
        end
    end
    
    if #raritiesToSell > 0 then
        for _, rarity in ipairs(raritiesToSell) do
            local filterBtnName = "Filter_" .. rarity
            local filterBtn = ShopPanel.FilterFrame:FindFirstChild(filterBtnName)
            while not filterBtn do
                print("⏳ Menunggu tombol " .. filterBtnName .. "...")
                task.wait(0.5)
                filterBtn = ShopPanel.FilterFrame:FindFirstChild(filterBtnName)
            end
            clickButton(filterBtn, filterBtnName)
            
            -- Insert to cart
            local sellAllBtn = ShopPanel.ActionBar.BtnFrame:FindFirstChild("SellAll")
            while not sellAllBtn do
                task.wait(0.5)
                sellAllBtn = ShopPanel.ActionBar.BtnFrame:FindFirstChild("SellAll")
            end
            clickButton(sellAllBtn, "SellAll (Add to cart for " .. rarity .. ")")
        end
    else
        local filterAllBtn = ShopPanel.FilterFrame:FindFirstChild("Filter_All")
        while not filterAllBtn do
            task.wait(0.5)
            filterAllBtn = ShopPanel.FilterFrame:FindFirstChild("Filter_All")
        end
        clickButton(filterAllBtn, "Filter_All")
        
        local sellAllBtn = ShopPanel.ActionBar.BtnFrame:FindFirstChild("SellAll")
        while not sellAllBtn do
            task.wait(0.5)
            sellAllBtn = ShopPanel.ActionBar.BtnFrame:FindFirstChild("SellAll")
        end
        clickButton(sellAllBtn, "SellAll")
    end
    
    -- Step 2: ViewCart
    clickButton(ShopPanel.ActionBar.BtnFrame.ViewCart, "ViewCart")
    
    -- Step 3: ConfirmSell
    clickButton(CartPanel.CartActionFrame.ConfirmSellBtn, "ConfirmSellBtn")
    
    -- Tunggu FishSold event max 5 detik
    local timeout = tick()
    while not sellDone and tick() - timeout < 5 do
        task.wait(0.1)
    end
    
    if sellDone then
        print("🏁 Auto Sell selesai! Total earned:", totalEarned)
        Window:Notify({ 
            Title = "Auto Sell", 
            Content = "Berhasil jual ikan! Earned: $" .. tostring(totalEarned), 
            Type = "success", 
            Duration = 4 
        })
    else
        print("⚠️ FishSold event ga kedetect, mungkin inventory kosong?")
        soldConn:Disconnect()
    end
    
    -- Tween kembali ke posisi awal
    if hrp and originalCFrame then
        print("[AutoSell] Tween kembali ke posisi awal...")
        task.wait(0.5)
        
        local randomTimeReturn = math.random(20, 50) / 10 -- Random waktu antara 2.0 sampai 5.0 detik
        print("[AutoSell] Waktu tween kembali: " .. randomTimeReturn .. " detik")
        
        local tweenInfo = TweenInfo.new(randomTimeReturn, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = originalCFrame})
        tween:Play()
        tween.Completed:Wait()
        print("✅ Kembali ke posisi awal!")
    end
end

AutoSellFish:CreateToggle({
    Id = "auto_sell_toggle",
    Title = "Enable Auto Sell",
    Icon = "refresh-cw",
    Default = false,
    Callback = function(state)
        autoSellEnabled = state
        if state then
            print("[Auto Sell] ON")
            Window:Notify({ 
                Title = "Auto Sell Active", 
                Content = "Auto sell akan berjalan tiap " .. autoSellInterval .. " menit.", 
                Type = "success", 
                Duration = 3 
            })
            
            autoSellTask = task.spawn(function()
                while autoSellEnabled do
                    -- Tunggu interval dulu sebelum sell pertama kali di loop
                    local waited = 0
                    while autoSellEnabled and waited < (autoSellInterval * 60) do
                        task.wait(1)
                        waited += 1
                    end
                    
                    -- Pause kalau lagi event biar ga tabrakan
                    if shared.isDoingEvent then
                        print("[Auto Sell] Lagi event, tunda sell dulu...")
                        while shared.isDoingEvent and autoSellEnabled do
                            task.wait(1)
                        end
                        print("[Auto Sell] Event selesai, lanjut sell!")
                    end
                    
                    -- Setelah tunggu, baru sell
                    if autoSellEnabled then
                        ExecuteSell()
                    end
                end
            end)
        else
            print("[Auto Sell] OFF")
            if autoSellTask then
                task.cancel(autoSellTask)
                autoSellTask = nil
            end
        end
    end
})

AutoSellFish:CreateButton({
    Id = "sell_now_button",
    Title = "Sell Now",
    Icon = "shopping-cart",
    Callback = function()
        Window:Notify({ 
            Title = "Auto Sell", 
            Content = "Menjalankan sell manual...", 
            Type = "info", 
            Duration = 2 
        })
        task.spawn(ExecuteSell)
    end
})

-- =============================================
-- ROD SHOP SECTION (scrape langsung dari GUI)
-- =============================================
local RodShopSection = ShopTab:CreateSection({ Title = "Rod Shop", Box = true, Opened = true })

local LP = game:GetService("Players").LocalPlayer

local Knit = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit
local RodShopService = Knit.Services.RodShopService
local BuyRod = RodShopService.RF.BuyRod

-- ================================
-- SCRAPE ROD LIST DARI GUI SHOP
-- ================================
local function GetContentFrame()
    local gui = LP:FindFirstChild("PlayerGui")
    local shopGui = gui and gui:FindFirstChild("EquipmentShopGUI")
    local mainPanel = shopGui and shopGui:FindFirstChild("MainPanel")
    local contentFrame = mainPanel and mainPanel:FindFirstChild("ContentFrame")
    return contentFrame
end

local rodOptions = {}
local rodMap = {} -- label -> { RodId = ..., Owned = true/false }

local function RefreshRodList()
    rodOptions = {}
    rodMap = {}

    local contentFrame = GetContentFrame()
    if not contentFrame then
        warn("[RodShop] ContentFrame tidak ditemukan, buka dulu Rod Shop GUI-nya!")
        return
    end

    local ownedList = {}
    local buyableList = {}

    for _, card in ipairs(contentFrame:GetChildren()) do
        if card:IsA("Frame") and card.Name:match("^RodCard_") then
            local imageContainer = card:FindFirstChild("ImageContainer")
            local bottomContainer = card:FindFirstChild("BottomContainer")

            local nameLabel = imageContainer and imageContainer:FindFirstChild("NameLabel")
            local equippedBadge = imageContainer and imageContainer:FindFirstChild("EquippedBadge")
            local actionButton = bottomContainer and bottomContainer:FindFirstChild("ActionButton")
            local buttonLabel = actionButton and actionButton:FindFirstChild("ButtonLabel")

            local owned = equippedBadge and equippedBadge.Visible or false
            local btnText = buttonLabel and buttonLabel.Text or ""
            local name = nameLabel and nameLabel.Text or card.Name
            local rodId = card.Name:gsub("^RodCard_", "")

            if owned then
                table.insert(ownedList, { RodId = rodId, Name = name })
            else
                local isRobux = btnText:find("R%$") ~= nil
                local isPriceFormat = btnText:find("%$") ~= nil

                if not isRobux and isPriceFormat then
                    table.insert(buyableList, {
                        RodId = rodId,
                        Name = name,
                        PriceText = btnText,
                        SortValue = (function()
                            local numPart, suffix = btnText:match("%$?([%d%.]+)([KM]?)")
                            local num = tonumber(numPart) or 0
                            if suffix == "K" then num = num * 1000
                            elseif suffix == "M" then num = num * 1000000 end
                            return num
                        end)()
                    })
                end
            end
        end
    end

    table.sort(buyableList, function(a, b) return a.SortValue < b.SortValue end)
    table.sort(ownedList, function(a, b) return a.Name < b.Name end)

    -- buyable rods dulu di atas
    for _, rod in ipairs(buyableList) do
        local label = rod.Name .. " - " .. rod.PriceText
        table.insert(rodOptions, label)
        rodMap[label] = { RodId = rod.RodId, Owned = false }
    end

    -- rod yang udah dimiliki di bawah, ditandain jelas
    for _, rod in ipairs(ownedList) do
        local label = rod.Name .. " - (Owned)"
        table.insert(rodOptions, label)
        rodMap[label] = { RodId = rod.RodId, Owned = true }
    end
end

RefreshRodList()

local selectedRod = nil

-- Dropdown Pilih Rod
RodShopSection:CreateDropdown({
    Id = "rod_shop_dropdown",
    Title = "Pilih Rod",
    Sidebar = true,
    Values = rodOptions,
    Default = nil,
    Callback = function(v)
        selectedRod = rodMap[v]
        print("[RodShop] Target:", v or "None")
    end
})

-- Tombol Beli Rod
RodShopSection:CreateButton({
    Id = "rod_shop_buy_btn",
    Title = "Beli Rod",
    Callback = function()
        if not selectedRod then
            Window:Notify({ Title = "Rod Shop", Content = "Pilih rod terlebih dahulu di dropdown!", Type = "warning", Duration = 3 })
            return
        end

        if selectedRod.Owned then
            Window:Notify({ Title = "Rod Shop", Content = "Rod ini udah kamu miliki!", Type = "info", Duration = 3 })
            return
        end

        local success, result = pcall(function()
            return BuyRod:InvokeServer(selectedRod.RodId)
        end)

        if success then
            Window:Notify({ Title = "Beli Berhasil", Content = selectedRod.RodId .. " berhasil dibeli!", Type = "success", Duration = 3 })
            RefreshRodList()
            selectedRod = nil
        else
            Window:Notify({ Title = "Beli Gagal", Content = "Gagal membeli " .. tostring(selectedRod.RodId) .. ". Cek saldo coin kamu!", Type = "error", Duration = 3 })
        end
    end
})

-- ================================
-- REFRESH BUTTON
-- ================================
RodShopSection:CreateDivider()
RodShopSection:CreateSpace(4)

RodShopSection:CreateButton({
    Id = "rod_shop_refresh_btn",
    Title = "Refresh Rod List",
    Callback = function()
        RefreshRodList()
        Window:Notify({ Title = "Rod Shop", Content = "List rod berhasil di-refresh!", Type = "info", Duration = 3 })
    end
})

-- =============================================
-- BAIT SHOP SECTION
-- =============================================
local BaitShopSection = ShopTab:CreateSection({ Title = "Bait Shop", Box = true, Opened = true })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaitShopConfig = require(ReplicatedStorage.Modules.BaitShopConfig)

local Knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit
local BaitShopService = Knit.Services.BaitShopService
local BuyBait = BaitShopService.RF.BuyBait

-- ================================
-- HELPER: format angka jadi K / M
-- ================================
local function FormatPrice(amount)
    amount = tonumber(amount) or 0

    if amount >= 1000000 then
        local val = amount / 1000000
        if val == math.floor(val) then
            return math.floor(val) .. "M"
        else
            return string.format("%.1fM", val)
        end
    elseif amount >= 1000 then
        local val = amount / 1000
        if val == math.floor(val) then
            return math.floor(val) .. "K"
        else
            return string.format("%.1fK", val)
        end
    else
        return tostring(math.floor(amount))
    end
end

-- ================================
-- BUILD BAIT LIST (cuma yang bisa dibeli pakai coin)
-- ================================
local baitOptions = {}
local baitMap = {} -- label -> BaitId

local function RefreshBaitList()
    baitOptions = {}
    baitMap = {}

    local catalog = BaitShopConfig.GetShopCatalog()

    -- sort dari termurah
    table.sort(catalog, function(a, b)
        local priceA = tonumber(a.CoinPrice) or math.huge
        local priceB = tonumber(b.CoinPrice) or math.huge
        return priceA < priceB
    end)

    for _, bait in ipairs(catalog) do
        -- cuma masukin yang punya CoinPrice (skip Robux-only)
        if bait.CoinPrice then
            local label = bait.DisplayName .. " - " .. FormatPrice(bait.CoinPrice) .. " coins"
            table.insert(baitOptions, label)
            baitMap[label] = bait.BaitId
        end
    end
end

RefreshBaitList()

local selectedBaitId = nil
local baitBuyAmount = 1

-- Dropdown Pilih Bait
BaitShopSection:CreateDropdown({
    Id = "bait_shop_dropdown",
    Title = "Pilih Bait",
    Sidebar = true,
    Values = baitOptions,
    Default = nil,
    Callback = function(v)
        selectedBaitId = baitMap[v]
        print("[BaitShop] Target:", v or "None")
    end
})

-- Input Jumlah Beli
BaitShopSection:CreateInput({
    Id = "bait_shop_amount",
    Title = "Jumlah Beli",
    Placeholder = "1",
    Default = "",
    Callback = function(text)
        local n = tonumber(tostring(text):match("%d+"))
        if n and n > 0 then
            baitBuyAmount = n
            print("[BaitShop] Jumlah beli:", n)
        else
            baitBuyAmount = 1
            print("[BaitShop] Jumlah beli: 1 (default)")
        end
    end
})

-- Tombol Beli Bait
BaitShopSection:CreateButton({
    Id = "bait_shop_buy_btn",
    Title = "Beli Bait",
    Callback = function()
        if not selectedBaitId then
            Window:Notify({ Title = "Bait Shop", Content = "Pilih bait terlebih dahulu di dropdown!", Type = "warning", Duration = 3 })
            return
        end

        local success, result = pcall(function()
            return BuyBait:InvokeServer(selectedBaitId, baitBuyAmount)
        end)

        if success then
            Window:Notify({ Title = "Beli Berhasil", Content = baitBuyAmount .. "x " .. selectedBaitId .. " berhasil dibeli!", Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Beli Gagal", Content = "Gagal membeli bait. Cek saldo coin kamu!", Type = "error", Duration = 3 })
        end
    end
})

-- ================================
-- REFRESH BUTTON
-- ================================
BaitShopSection:CreateDivider()
BaitShopSection:CreateSpace(4)

BaitShopSection:CreateButton({
    Id = "bait_shop_refresh_btn",
    Title = "Refresh Bait List",
    Callback = function()
        RefreshBaitList()
        Window:Notify({ Title = "Bait Shop", Content = "List bait berhasil di-refresh!", Type = "info", Duration = 3 })
    end
})

-- =============================================
-- POTION SHOP SECTION
-- =============================================
local PotionShopSection = ShopTab:CreateSection({ Title = "Potion Shop", Box = true, Opened = true })

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit
local PotionShopService = Knit.Services.PotionShopService
local BuyPotion = PotionShopService.RF.BuyPotion
local GetShopData = PotionShopService.RF.GetShopData

local function FormatPrice(amount)
    amount = tonumber(amount) or 0
    if amount >= 1000000 then
        local val = amount / 1000000
        return (val == math.floor(val) and math.floor(val) or string.format("%.1f", val)) .. "M"
    elseif amount >= 1000 then
        local val = amount / 1000
        return (val == math.floor(val) and math.floor(val) or string.format("%.1f", val)) .. "K"
    end
    return tostring(math.floor(amount))
end

-- ================================
-- AMBIL DATA SHOP (Money, Inventory, Catalog) - satu request, semua fresh
-- ================================
local MAX_STACK_COUNT = 999 -- dari BuffConfig.MaxStackCount
local shopData = nil

local function FetchShopData()
    local success, data = pcall(function()
        return GetShopData:InvokeServer()
    end)
    if success and type(data) == "table" then
        shopData = data
        return data
    end
    warn("[PotionShop] Gagal ambil shop data")
    return nil
end

-- ================================
-- HITUNG MAX ALLOWED QTY (persis formula game)
-- ================================
local function ComputeMaxAllowedQty(potionId, coinPrice)
    coinPrice = tonumber(coinPrice) or 0
    if coinPrice <= 0 or not shopData then return 0, "money" end

    local money = tonumber(shopData.Money) or 0
    local maxByMoney = math.floor(money / coinPrice)

    local owned = tonumber(shopData.Inventory and shopData.Inventory[potionId]) or 0
    local maxByInventory = math.max(0, MAX_STACK_COUNT - owned)

    local maxAllowed = math.min(99, maxByMoney, maxByInventory)

    if maxAllowed < 1 then
        if maxByMoney < 1 then return 0, "money" end
        return 0, "inventory"
    end

    return maxAllowed, nil
end

-- ================================
-- BUILD POTION LIST (Coin-only, langsung dari shopData.Catalog)
-- ================================
local potionOptions = {}
local potionMap = {} -- label -> { PotionId, CoinPrice }

local function RefreshPotionList()
    potionOptions = {}
    potionMap = {}

    local data = FetchShopData()
    if not data or not data.Catalog then return end

    for _, potion in ipairs(data.Catalog) do
        if not potion.IsRobuxOnly and potion.CoinPrice then
            local label = potion.DisplayName .. " - " .. FormatPrice(potion.CoinPrice) .. "/each"
            table.insert(potionOptions, label)
            potionMap[label] = { PotionId = potion.PotionId, CoinPrice = potion.CoinPrice }
        end
    end
end

RefreshPotionList()

local selectedPotion = nil
local buyQuantity = 1

-- Dropdown Pilih Potion
PotionShopSection:CreateDropdown({
    Id = "potion_shop_dropdown",
    Title = "Pilih Potion",
    Sidebar = true,
    Values = potionOptions,
    Default = nil,
    Callback = function(v)
        selectedPotion = potionMap[v]
        buyQuantity = 1
        print("[PotionShop] Target:", v or "None")
    end
})

-- Input Jumlah Beli
PotionShopSection:CreateInput({
    Id = "potion_shop_amount",
    Title = "Jumlah Beli",
    Placeholder = "1 (atau pakai tombol Max)",
    Default = "",
    Callback = function(text)
        local n = tonumber(tostring(text):match("%d+"))
        buyQuantity = (n and n > 0) and n or 1
        print("[PotionShop] Jumlah beli:", buyQuantity)
    end
})

-- Tombol Set Max Qty
PotionShopSection:CreateButton({
    Id = "potion_shop_max_btn",
    Title = "Set Jumlah Max",
    Callback = function()
        if not selectedPotion then
            Window:Notify({ Title = "Potion Shop", Content = "Pilih potion dulu!", Type = "warning", Duration = 3 })
            return
        end

        FetchShopData()
        local maxQty, reason = ComputeMaxAllowedQty(selectedPotion.PotionId, selectedPotion.CoinPrice)

        if maxQty < 1 then
            local msg = (reason == "inventory") and "Stok potion udah penuh!" or "Uang gak cukup buat beli 1x!"
            Window:Notify({ Title = "Potion Shop", Content = msg, Type = "error", Duration = 3 })
            return
        end

        buyQuantity = maxQty
        Window:Notify({ Title = "Potion Shop", Content = "Jumlah di-set ke max: " .. maxQty, Type = "info", Duration = 3 })
    end
})

-- Tombol Beli Potion
PotionShopSection:CreateButton({
    Id = "potion_shop_buy_btn",
    Title = "Beli Potion",
    Callback = function()
        if not selectedPotion then
            Window:Notify({ Title = "Potion Shop", Content = "Pilih potion terlebih dahulu!", Type = "warning", Duration = 3 })
            return
        end

        FetchShopData()
        local maxQty, reason = ComputeMaxAllowedQty(selectedPotion.PotionId, selectedPotion.CoinPrice)

        if maxQty < 1 then
            local msg = (reason == "inventory") and "Stok potion udah penuh!" or "Uang gak cukup!"
            Window:Notify({ Title = "Beli Gagal", Content = msg, Type = "error", Duration = 3 })
            return
        end

        local finalQty = math.min(buyQuantity, maxQty)

        local success, result = pcall(function()
            return BuyPotion:InvokeServer(selectedPotion.PotionId, finalQty)
        end)

        if success then
            Window:Notify({ Title = "Beli Berhasil", Content = finalQty .. "x " .. selectedPotion.PotionId .. " dibeli!", Type = "success", Duration = 3 })
            RefreshPotionList()
        else
            Window:Notify({ Title = "Beli Gagal", Content = "Gagal membeli potion.", Type = "error", Duration = 3 })
        end
    end
})

PotionShopSection:CreateDivider()
PotionShopSection:CreateSpace(4)

PotionShopSection:CreateButton({
    Id = "potion_shop_refresh_btn",
    Title = "Refresh Potion List",
    Callback = function()
        RefreshPotionList()
        Window:Notify({ Title = "Potion Shop", Content = "List potion di-refresh!", Type = "info", Duration = 3 })
    end
})
-- ================================================================
--  Favorit Tab
-- ================================================================
Loader:Set(0.4, "Favorit")
task.wait()
local FavoritTab = Window:CreateTab({ Title = "Favorit", Icon = "" })
local FavoritSection = FavoritTab:CreateSection({ Title = "Auto Favorit", Box = true, Opened = true })

local favSelectedRarities = {}
local favSelectedMutations = {}
local autoFavEnabled = false
local autoFavConnection = nil

-- =============================================
-- DROPDOWN PILIH RARITY
-- =============================================
FavoritSection:CreateMultiDropdown({
    Id = "fav_rarity",
    Sidebar = true,
    Title = "Pilih Rarity",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Monster" },
    Default = {},
    Callback = function(selected)
        favSelectedRarities = {}
        if type(selected) == "table" then
            for _, rarity in ipairs(selected) do
                favSelectedRarities[rarity] = true
            end
        end
        print("[Auto Favorit] Rarity dipilih:", #selected > 0 and table.concat(selected, ", ") or "None")
    end
})

-- =============================================
-- DROPDOWN PILIH MUTATION
-- =============================================
FavoritSection:CreateMultiDropdown({
    Id = "fav_mutation",
    Sidebar = true,
    Title = "Pilih Mutation",
    Values = { "Electric", "GlassFin", "Shiny", "Zombie", "Metal" },
    Default = {},
    Callback = function(selected)
        favSelectedMutations = {}
        if type(selected) == "table" then
            for _, mutation in ipairs(selected) do
                favSelectedMutations[mutation] = true
            end
        end
        print("[Auto Favorit] Mutation dipilih:", #selected > 0 and table.concat(selected, ", ") or "None")
    end
})

-- =============================================
-- TOGGLE AUTO FAVORIT
-- =============================================
FavoritSection:CreateToggle({
    Id = "auto_favorit_toggle",
    Title = "Enable Auto Favorit",
    Icon = "star",
    Default = false,
    Callback = function(state)
        autoFavEnabled = state
        local Knit = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services
        local RewardRE = Knit.FishingRewardService.RE
        local ShopRF = Knit.FishermanShopService.RF
        
        if state then
            print("[Auto Favorit] ON")
            Window:Notify({
                Title = "Auto Favorit Active",
                Content = "Ikan dengan rarity/mutation terpilih akan otomatis di-favorit!",
                Type = "success",
                Duration = 3
            })
            
            if autoFavConnection == nil then
                autoFavConnection = RewardRE.FishCaught.OnClientEvent:Connect(function(data)
                    if not autoFavEnabled then return end
                    if type(data) == "table" and data.InstanceId and data.FishData then
                        local rarity = data.FishData.Rarity
                        local fishName = data.FishData.Name or ""
                        local mutation = data.Mutation or data.FishData.Mutation
                        local shouldFavorite = false
                        
                        -- Cek Rarity
                        if rarity and favSelectedRarities[rarity] then
                            shouldFavorite = true
                        end
                        
                        -- Cek Mutation
                        if not shouldFavorite then
                            local fishNameLower = string.lower(fishName)
                            for mut, _ in pairs(favSelectedMutations) do
                                local mutLower = string.lower(mut)
                                
                                -- 1. Cek dari nama ikan (case insensitive)
                                if string.find(fishNameLower, mutLower) then
                                    shouldFavorite = true
                                    break
                                end
                                
                                -- 2. Cek dari properti Mutation/Mutations
                                local mutData = data.Mutation or data.Mutations or (data.FishData and (data.FishData.Mutation or data.FishData.Mutations))
                                if type(mutData) == "string" and string.find(string.lower(mutData), mutLower) then
                                    shouldFavorite = true
                                    break
                                elseif type(mutData) == "table" then
                                    for _, m in pairs(mutData) do
                                        if type(m) == "string" and string.find(string.lower(m), mutLower) then
                                            shouldFavorite = true
                                            break
                                        end
                                    end
                                    if shouldFavorite then break end
                                end
                            end
                        end
                        
                        if shouldFavorite then
                            print("[Auto Favorit] Favoriting " .. tostring(fishName))
                            pcall(function()
                                ShopRF.ToggleFavoriteFish:InvokeServer(data.InstanceId)
                            end)
                            Window:Notify({
                                Title = "Auto Favorit",
                                Content = "Ikan " .. fishName .. " berhasil di-favorit!",
                                Type = "info",
                                Duration = 3
                            })
                        end
                    end
                end)
            end
        else
            print("[Auto Favorit] OFF")
            if autoFavConnection then
                autoFavConnection:Disconnect()
                autoFavConnection = nil
            end
        end
    end
})


-- ================================================================
--  Teleport Tab
-- ================================================================
Loader:Set(0.52, "Teleport")
task.wait()

local TeleportTab = Window:CreateTab({ Title = "Teleport", Icon = "arrow-left-right" })

-- =============================================
-- TELEPORT ISLAND SECTION
-- =============================================
local TeleportIslandSection = TeleportTab:CreateSection({ Title = "Teleport Island", Box = true, Opened = true })

local LP = game:GetService("Players").LocalPlayer
local TeleportService = game:GetService("TeleportService")

-- Daftar Island di dalam Map Explore Island
local islands = {
    { name = "Bamboo",            cframe = CFrame.new(-1364.95, 180.10, 320.49) * CFrame.Angles(0, 2.70, 0),   unlockLevel = 1,  comingSoon = false },
    { name = "Iceberg",           cframe = CFrame.new(-582.31, 190.07, -529.37) * CFrame.Angles(0, -1.28, 0),  unlockLevel = 1,  comingSoon = false },
    { name = "Lost Whale Island", cframe = CFrame.new(-2676.25, 179.97, 39.09) * CFrame.Angles(0, 2.06, 0),   unlockLevel = 10, comingSoon = false },
    { name = "Bora Reef",         cframe = CFrame.new(-3996.39, 171.44, 2028.85),                              unlockLevel = 20, comingSoon = false },
    { name = "Volcano Vent",      cframe = CFrame.new(-1686.41, 173.81, 5931.25),                              unlockLevel = 30, comingSoon = false },
    { name = "Cape Town",         cframe = CFrame.new(804.61, 187.62, 2952.89),                                unlockLevel = 35, comingSoon = false },
    { name = "Mystic Mangrove",   cframe = CFrame.new(4428.54, 176.34, 1155.71),                              unlockLevel = 50, comingSoon = false },
    { name = "SeaBreeze",         cframe = CFrame.new(-2874.05, 184.70, -4826.07) * CFrame.Angles(0, -0.46, 0),   unlockLevel = 60, comingSoon = false },
    { name = "Dragon Cove",       cframe = CFrame.new(-2434.11, 852.64, -5550.45) * CFrame.Angles(0, -1.32, 0),   unlockLevel = 70, comingSoon = false },
    { name = "Emerald Island",    cframe = CFrame.new(1459.31, 151.90, -2823.35),                              unlockLevel = 80, comingSoon = true  },
    { name = "Ancient Abyss",     cframe = CFrame.new(3796.33, 77.89, 5944.52),                                unlockLevel = 90, comingSoon = true  },
}

local islandOptions = {}
local islandMap = {}
for _, island in ipairs(islands) do
    local displayName = island.name .. " (Lv. " .. island.unlockLevel .. ")"
    table.insert(islandOptions, displayName)
    islandMap[displayName] = island
end

local selectedIslandName = nil

-- Dropdown Pilih Island
TeleportIslandSection:CreateDropdown({
    Id = "tp_island",
    Title = "Pilih Island",
    Sidebar = true,
    Values = islandOptions,
    Default = nil,
    Callback = function(v)
        selectedIslandName = v
        print("[Teleport Island] Target:", v or "None")
    end
})

-- Tombol Teleport ke Island yang dipilih
TeleportIslandSection:CreateButton({
    Id = "tp_island_btn",
    Title = "Teleport to Island",
    Callback = function()
        if game.PlaceId ~= 90457367396205 then
            Window:Notify({ Title = "Salah Map", Content = "Kamu harus berada di map Explore Island dulu!", Type = "error", Duration = 4 })
            return
        end
        
        if not selectedIslandName then
            Window:Notify({ Title = "Teleport", Content = "Pilih island terlebih dahulu di dropdown!", Type = "warning", Duration = 3 })
            return
        end
        
        local island = islandMap[selectedIslandName]
        if not island then return end
        
        -- Cek apakah island coming soon
        if island.comingSoon then
            Window:Notify({ Title = "Coming Soon", Content = island.name .. " masih Coming Soon!", Type = "error", Duration = 3 })
            return
        end
        
        -- Cek Level Player
        local hud = LP.PlayerGui:FindFirstChild("HUD")
        local statsPanel = hud and hud:FindFirstChild("PlayerStatsPanel", true)
        local levelLabel = statsPanel and statsPanel:FindFirstChild("LevelLabel", true)
        local level = 0
        if levelLabel then
            level = tonumber(levelLabel.Text:match("%d+")) or 0
        end
        
        if level >= island.unlockLevel then
            local char = LP.Character or LP.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = island.cframe
                Window:Notify({ Title = "Teleport Berhasil", Content = "Berhasil teleport ke " .. island.name, Type = "success", Duration = 3 })
            end
        else
            Window:Notify({ Title = "Level Kurang", Content = "Level kamu belum cukup! Butuh Lv. " .. island.unlockLevel, Type = "error", Duration = 3 })
        end
    end
})
-- =============================================
-- MAP SWITCHING BUTTONS (2 Tombol Terpisah)
-- =============================================
TeleportIslandSection:CreateDivider()
TeleportIslandSection:CreateSpace(4)
-- Tombol 1: Ke Base Map
TeleportIslandSection:CreateButton({
    Id = "tp_base_map_btn",
    Title = "Teleport to Base",
    Callback = function()
        if game.PlaceId == 111385005478215 then
            Window:Notify({ Title = "Info", Content = "Kamu sudah berada di Base Map!", Type = "info", Duration = 3 })
            return
        end
        
        Window:Notify({ Title = "Teleporting...", Content = "Pindah ke Base Map...", Type = "info", Duration = 3 })
        task.wait(0.5) -- Delay kecil biar executor gak nge-bug saat request teleport
        TeleportService:Teleport(111385005478215, LP)
    end
})

-- Tombol 2: Ke Explore Island Map
TeleportIslandSection:CreateButton({
    Id = "tp_explore_map_btn",
    Title = "Teleport to Island",
    Callback = function()
        if game.PlaceId == 90457367396205 then
            Window:Notify({ Title = "Info", Content = "Kamu sudah berada di Explore Island!", Type = "info", Duration = 3 })
            return
        end
        
        Window:Notify({ Title = "Teleporting...", Content = "Pindah ke Explore Island...", Type = "info", Duration = 3 })
        task.wait(0.5) -- Delay kecil biar executor gak nge-bug saat request teleport
        TeleportService:Teleport(90457367396205, LP)
    end
})


-- =============================================
-- SPOT FISHING ISLAND SECTION
-- Titik mancing terbaik di tiap island (udah ngadep ke laut).
-- Level requirement-nya nyusul dari data Teleport Island.
-- =============================================
local SpotFishingSection = TeleportTab:CreateSection({ Title = "Spot Fishing Island", Box = true, Opened = false })

-- unlockLevel disamain dengan daftar Teleport Island biar konsisten
local fishingSpots = {
    { name = "Bamboo",            cframe = CFrame.new(-1591.93, 181.21, 219.34) * CFrame.Angles(0, 1.37, 0),   unlockLevel = 1  },
    { name = "Iceberg",           cframe = CFrame.new(-693.72, 184.38, -435.60) * CFrame.Angles(0, 0.85, 0),   unlockLevel = 1  },
    { name = "Lost Whale Island", cframe = CFrame.new(-2865.35, 172.42, -328.16) * CFrame.Angles(0, 2.40, 0),  unlockLevel = 10 },
    { name = "Bora Reef",         cframe = CFrame.new(-4148.83, 196.01, 2055.02) * CFrame.Angles(0, -2.24, 0), unlockLevel = 20 },
    { name = "Volcano Vent",      cframe = CFrame.new(-1803.64, 226.59, 5546.79) * CFrame.Angles(0, 1.76, 0),  unlockLevel = 30 },
    { name = "Cape Town",         cframe = CFrame.new(901.51, 183.63, 2888.07) * CFrame.Angles(0, 0.96, 0),    unlockLevel = 35 },
    { name = "Mystic Mangrove",   cframe = CFrame.new(4722.56, 242.54, 1530.84) * CFrame.Angles(0, -1.64, 0),  unlockLevel = 50 },
    { name = "Dragon Cove",   cframe = CFrame.new(-2372.15, 711.20, -5404.76) * CFrame.Angles(0, 0.86, 0),  unlockLevel = 70 },
    { name = "Sea Breeze",   cframe = CFrame.new(-3056.24, 173.96, -5010.23) * CFrame.Angles(0, 0.60, 0),  unlockLevel = 60 },
}

local spotOptions = {}
local spotMap = {}
for _, spot in ipairs(fishingSpots) do
    local displayName = spot.name .. " (Lv. " .. spot.unlockLevel .. ")"
    table.insert(spotOptions, displayName)
    spotMap[displayName] = spot
end

-- Baca level player dari HUD (dipakai bareng sama Teleport Island)
local function getPlayerLevel()
    local hud = LP.PlayerGui:FindFirstChild("HUD")
    local statsPanel = hud and hud:FindFirstChild("PlayerStatsPanel", true)
    local levelLabel = statsPanel and statsPanel:FindFirstChild("LevelLabel", true)
    if levelLabel then
        return tonumber(levelLabel.Text:match("%d+")) or 0
    end
    return 0
end

local selectedSpotName = nil

-- Dropdown Pilih Spot Fishing
SpotFishingSection:CreateDropdown({
    Id = "tp_fishing_spot",
    Title = "Pilih Spot Fishing",
    Values = spotOptions,
    Default = nil,
    Callback = function(v)
        selectedSpotName = v
        print("[Spot Fishing] Target:", v or "None")
    end
})

-- Tombol Teleport ke spot mancing yang dipilih
SpotFishingSection:CreateButton({
    Id = "tp_fishing_spot_btn",
    Title = "Teleport Now",
    Icon = "map-pin",
    Callback = function()
        if game.PlaceId ~= 90457367396205 then
            Window:Notify({ Title = "Salah Map", Content = "Kamu harus berada di map Explore Island dulu!", Type = "error", Duration = 4 })
            return
        end

        if not selectedSpotName then
            Window:Notify({ Title = "Spot Fishing", Content = "Pilih spot fishing terlebih dahulu di dropdown!", Type = "warning", Duration = 3 })
            return
        end

        local spot = spotMap[selectedSpotName]
        if not spot then return end

        -- Cek Level Player (sama kayak Teleport Island)
        local level = getPlayerLevel()
        if level < spot.unlockLevel then
            Window:Notify({ Title = "Level Kurang", Content = "Level kamu belum cukup! Butuh Lv. " .. spot.unlockLevel, Type = "error", Duration = 3 })
            return
        end

        local char = LP.Character or LP.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Window:Notify({ Title = "Gagal", Content = "Karakter belum siap!", Type = "error", Duration = 3 })
            return
        end

        hrp.CFrame = spot.cframe
        Window:Notify({ Title = "Teleport Berhasil", Content = "Sampai di spot fishing " .. spot.name .. "!", Type = "success", Duration = 3 })
    end
})

SpotFishingSection:CreateParagraph({
    Id   = "tp_fishing_spot_note",
    Text = "Sebelum teleport aktifkan Walk on Water dan Noclip di Tab Fishing.",
})

-- =============================================
-- TELEPORT PLAYER SECTION
-- =============================================
local TeleportPlayerSection = TeleportTab:CreateSection({ Title = "Teleport Player", Box = true, Opened = false })

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(names, p.Name)
        end
    end
    return names
end

local selectedPlayer = nil

TeleportPlayerSection:CreateDropdown({
    Id = "tp_player",
    Title = "Select Player",
    Sidebar = true,
    Values = getPlayerNames(),
    Refresh = getPlayerNames,
    RefreshInterval = 2,
    Callback = function(v)
        selectedPlayer = v
        print("[Teleport Player] Target:", v or "None")
    end
})

TeleportPlayerSection:CreateButton({
    Id = "tp_player_btn",
    Title = "Teleport Now",
    Icon = "map-pin",
    Callback = function()
        if not selectedPlayer then
            Window:Notify({ Title = "Teleport", Content = "Pilih player terlebih dahulu!", Type = "warning", Duration = 3 })
            return
        end
        
        local target = Players:FindFirstChild(selectedPlayer)
        if not target then
            Window:Notify({ Title = "Teleport", Content = "Player '" .. selectedPlayer .. "' tidak ditemukan!", Type = "error", Duration = 3 })
            return
        end
        
        if not target.Character then
            Window:Notify({ Title = "Teleport", Content = selectedPlayer .. " tidak punya karakter!", Type = "error", Duration = 3 })
            return
        end
        
        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then
            Window:Notify({ Title = "Teleport", Content = selectedPlayer .. " tidak punya HumanoidRootPart!", Type = "error", Duration = 3 })
            return
        end
        
        local localChar = LP.Character
        if not localChar then
            Window:Notify({ Title = "Teleport", Content = "Karakter kamu tidak ditemukan!", Type = "error", Duration = 3 })
            return
        end
        
        local localHRP = localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then
            Window:Notify({ Title = "Teleport", Content = "Kamu tidak punya HumanoidRootPart!", Type = "error", Duration = 3 })
            return
        end
        
        local success, err = pcall(function()
            localHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
        end)
        
        if success then
            Window:Notify({ Title = "Teleport", Content = "Berhasil teleport ke " .. selectedPlayer, Type = "success", Duration = 3 })
            print("✅ Teleported to " .. selectedPlayer)
        else
            Window:Notify({ Title = "Teleport", Content = "Teleport gagal: " .. tostring(err), Type = "error", Duration = 3 })
            print("❌ Teleport failed: " .. tostring(err))
        end
    end
})


-- =============================================
-- TELEPORT EVENT SECTION
-- =============================================
local TeleportEventSection = TeleportTab:CreateSection({ Title = "Teleport Event", Box = true, Opened = false })

local function getAvailableEvents()
    local list = {}
    local EventFolder = workspace:FindFirstChild("Event")
    if EventFolder then
        for _, child in ipairs(EventFolder:GetChildren()) do
            local clean = child.Name:gsub("Event$", "")
            if not table.find(list, clean) then
                table.insert(list, clean)
            end
        end
    end
    if #list == 0 then
        list = {"Losi", "Windah"}
    end
    return list
end

local function findEventPosition(eventName)
    -- 1. Check direct BossEventMarker (e.g. for Losi)
    if eventName:lower() == "losi" then
        local ok, losiPillar = pcall(function()
            return workspace.BossEventMarker_Losi_Clown.BossEventPillar
        end)
        if ok and losiPillar then
            return losiPillar.Position, "Losi_Clown"
        end
    end
    
    -- 2. General search in workspace.Event
    local EventFolder = workspace:FindFirstChild("Event")
    if EventFolder then
        for _, folder in ipairs(EventFolder:GetChildren()) do
            if folder.Name:lower():find(eventName:lower(), 1, true) then
                for _, point in ipairs(folder:GetChildren()) do
                    for _, obj in ipairs(point:GetChildren()) do
                        if obj:IsA("BasePart") then
                            return obj.Position, folder.Name
                        elseif obj.Name:find("Anchor", 1, true) or obj.Name:find("Pillar", 1, true) then
                            return obj.Position, folder.Name
                        end
                    end
                end
            end
        end
    end
    return nil
end

local selectedTeleportEvent = nil

local teleportEventDropdown = TeleportEventSection:CreateDropdown({
    Id = "tp_event",
    Title = "Select Event Boss",
    Values = getAvailableEvents(),
    Default = getAvailableEvents()[1] or "",
    Callback = function(v)
        selectedTeleportEvent = v
        print("[Teleport Event] Target:", v or "None")
    end
})

selectedTeleportEvent = getAvailableEvents()[1]

TeleportEventSection:CreateButton({
    Id = "tp_event_btn",
    Title = "Teleport to Event",
    Icon = "map-pin",
    Callback = function()
        if not selectedTeleportEvent or selectedTeleportEvent == "" then
            Window:Notify({ Title = "Error", Content = "Pilih event terlebih dahulu!", Type = "warning", Duration = 3 })
            return
        end
        
        local pos, realName = findEventPosition(selectedTeleportEvent)
        if pos then
            local char = LP.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                Window:Notify({ 
                    Title = "Teleport Success", 
                    Content = "Teleport ke event: " .. selectedTeleportEvent .. " (" .. tostring(realName) .. ")", 
                    Type = "success", 
                    Duration = 3 
                })
            else
                Window:Notify({ Title = "Error", Content = "Karakter tidak ditemukan!", Type = "error", Duration = 3 })
            end
        else
            Window:Notify({ Title = "Error", Content = "Event " .. selectedTeleportEvent .. " sedang tidak aktif!", Type = "error", Duration = 3 })
        end
    end
})

-- Auto-refresh dropdown values if a new event starts in the server
pcall(function()
    local EventFolder = workspace:FindFirstChild("Event")
    if EventFolder then
        EventFolder.ChildAdded:Connect(function()
            task.wait(0.5)
            if teleportEventDropdown then
                pcall(function()
                    local evs = getAvailableEvents()
                    if type(teleportEventDropdown.SetValues) == "function" then
                        teleportEventDropdown.SetValues(evs)
                    end
                end)
            end
        end)
    end
end)


-- ================================================================
--  Auto Tab
-- ================================================================
Loader:Set(0.64, "Auto")
task.wait()
local AutoTab = Window:CreateTab({ Title = "Auto", Icon = "rotate-ccw" })
local AutoEventSection = AutoTab:CreateSection({ Title = "Auto Event", Box = true, Opened = true })

-- =============================================
-- AUTO EVENT MODULE
-- =============================================
local function getAvailableEvents()
    local list = {}
    local EventFolder = workspace:FindFirstChild("Event")
    if EventFolder then
        for _, child in ipairs(EventFolder:GetChildren()) do
            local clean = child.Name:gsub("Event$", "")
            if not table.find(list, clean) then
                table.insert(list, clean)
            end
        end
    end
    if #list == 0 then
        list = {"Losi", "Windah"}
    end
    return list
end

local selectedEvents = {}

local eventDropdown = AutoEventSection:CreateMultiDropdown({
    Id = "auto_event_selection",
    Title = "Select Event Boss",
    Values = getAvailableEvents(),
    Default = {},
    Callback = function(selected)
        selectedEvents = {}
        if type(selected) == "table" then
            for _, v in ipairs(selected) do
                selectedEvents[v] = true
            end
        end
        print("[Auto Event] Event dipilih:", #selected > 0 and table.concat(selected, ", ") or "All")
    end
})

-- Auto-refresh pilihan dropdown jika ada folder Event baru yang muncul
pcall(function()
    local EventFolder = workspace:FindFirstChild("Event")
    if EventFolder then
        EventFolder.ChildAdded:Connect(function()
            task.wait(0.5)
            if eventDropdown then
                pcall(function()
                    local evs = getAvailableEvents()
                    if type(eventDropdown.SetValues) == "function" then
                        eventDropdown.SetValues(evs)
                    end
                end)
            end
        end)
    end
end)

local function getActiveBossId()
    local EventFolder = workspace:FindFirstChild("Event")
    if not EventFolder then return nil, nil end
    for _, folder in ipairs(EventFolder:GetChildren()) do
        for _, point in ipairs(folder:GetChildren()) do
            for _, obj in ipairs(point:GetChildren()) do
                -- Format: SeaMonsterTitleAnchor_BossId
                local bossId = obj.Name:match("SeaMonsterTitleAnchor_(.+)")
                if bossId then
                    return bossId, folder.Name
                end
            end
        end
    end
    return nil, nil
end

local autoEventEnabled = false
local eventAnnounceConn = nil
local eventScanTask = nil

local function handleEvent(position, bossName)
    if shared.isDoingEvent then return end
    shared.isDoingEvent = true
    
    local LP = game:GetService("Players").LocalPlayer
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local PlayerGui = LP:WaitForChild("PlayerGui")
    
    -- 1. Save original position
    local originalCFrame = hrp.CFrame
    print("✅ Menyimpan posisi awal:", originalCFrame)
    
    -- 2. Teleport ke event
    hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
    print("✅ Teleport ke event:", bossName, "| Pos:", position)
    task.wait(5) -- Jeda 5 detik biar map/UI server bener-bener keload
    
    print("🚨 LANGSUNG PARTICIPATE!")
    
    -- 3. Participate
    local ok, btn = pcall(function()
        return PlayerGui.BossFishEventGUI.FishMonsterContainer.FishMonsterBtn
    end)
    if ok and btn then
        firesignal(btn.Activated)
        print("✅ PARTICIPATE!")
    else
        print("❌ Tombol participate ga ketemu!")
    end
    
    task.wait(1)
    
    -- 4. Setup EventEnd listener DULU sebelum spam tap
    local RS = game:GetService("ReplicatedStorage")
    local Knit = RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services
    local isEventEnded = false
    local endConn
    endConn = Knit.BossFishEventService.RE.EventEnd.OnClientEvent:Connect(function(data)
        print("🏁 EventEnd diterima dari server! State:", data and data.State or "nil")
        isEventEnded = true
    end)
    
    -- 5. Listen to StartPulling via namecall hook
    print("⏳ Menunggu instruksi StartPulling dari game/server...")
    local isPullingStarted = false
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    pcall(function()
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "InvokeServer" and tostring(self) == "StartPulling" then
                isPullingStarted = true
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
    
    -- Scan text untuk nentuin timeout (kalau-kalau eventnya masih lama)
    local timeout = 600 -- fallback 10 menit
    pcall(function()
        local readyPanel = PlayerGui:WaitForChild("BossFishEventGUI", 2):WaitForChild("ReadyPanel", 2)
        local label = readyPanel:WaitForChild("TextLabel", 2)
        local text = label.Text
        print("📊 Status Event pas nunggu StartPulling:", text)
        local secs = string.match(text, "in: (%d+)s") or string.match(text, "(%d+)s")
        if secs then
            timeout = tonumber(secs) + 60 -- Kasih buffer 60 detik dari sisa waktu countdown
            print("⏱️ Sisa waktu event:", secs, "detik. Set timeout nunggu StartPulling jadi:", timeout, "detik")
        end
    end)
    
    -- Tunggu StartPulling sesuai timeout, atau sampai EventEnd keluar
    local waitPull = tick()
    while not isPullingStarted and not isEventEnded and tick() - waitPull < timeout do
        task.wait(0.1)
    end
    
    -- balikin namecall
    pcall(function()
        setreadonly(mt, false)
        mt.__namecall = oldNamecall
        setreadonly(mt, true)
    end)
    
    if isEventEnded then
        print("⚠️ EventEnd sudah keluar sebelum StartPulling, skip tap...")
        endConn:Disconnect()
        task.wait(1)
        pcall(function()
            local cBtn1 = PlayerGui.BossEndgameGUI.EndgameUI.CloseButton
            firesignal(cBtn1.Activated)
            print("🏆 Close EndgameUI")
        end)
        task.wait(0.3)
        pcall(function()
            local cBtn2 = PlayerGui.RewardGui.RewardPanel.Header.CloseBtn
            firesignal(cBtn2.MouseButton1Click)
            print("🎁 Close RewardGui")
        end)
        task.wait(1)
        hrp.CFrame = originalCFrame
        print("🔙 Kembali ke posisi awal!")
        shared.isDoingEvent = false
        print("▶️ Instant Fishing dilanjutkan!")
        return
    end
    
    if isPullingStarted then
        print("🎣 StartPulling terdeteksi! Lanjut ke tap...")
    else
        print("⚠️ Timeout nunggu StartPulling, lanjut aja...")
    end
    
    -- 6. Spam tap event dengan BossID dinamis
    local detectedBossId, activeEventName = getActiveBossId()
    local tapBossName = detectedBossId or (bossName:lower():find("losi") and "Losi_Coral" or "Windah_SM_Clown")
    print("👾 Spam tap boss ID:", tapBossName, "(Event:", tostring(activeEventName or bossName), ") mulai!")
    
    local PlayerTap = Knit.BossFishEventService.RF.PlayerTap
    
    -- Cek juga dari UI kalau-kalau onClientEvent kelewat
    task.spawn(function()
        task.wait(5) -- Kasih jeda dulu sebelum mulai ngecek UI biar gak false positive awal
        while not isEventEnded and shared.isDoingEvent do
            local hasVictory = false
            local hasReward = false
            pcall(function()
                hasVictory = PlayerGui.BossEndgameGUI.Enabled and PlayerGui.BossEndgameGUI.EndgameUI.Visible
            end)
            pcall(function()
                hasReward = PlayerGui.RewardGui.Enabled and PlayerGui.RewardGui.RewardPanel.Visible
            end)
            if hasVictory or hasReward then
                print("🏆 UI Kemenangan kedetect! Event berarti kelar.")
                isEventEnded = true
            end
            task.wait(1)
        end
    end)
    
    local count = 0
    -- Spam tap sampai EventEnd dari server, UI selesai, atau bossId sudah hilang
    while not isEventEnded and shared.isDoingEvent do
        local curBossId, _ = getActiveBossId()
        curBossId = curBossId or tapBossName
        local ok, res = pcall(function() return PlayerTap:InvokeServer(curBossId) end)
        if ok then
            count = count + 1
            if count % 20 == 0 then
                print("✅ Tap ke-" .. count .. " | BossID: " .. tostring(curBossId))
            end
        else
            print("❌ Error tap:", res)
            break
        end
        task.wait(0.05)
    end
    
    endConn:Disconnect()
    print("🏁 Event selesai! Total tap:", count)
    
    -- 7. Close GUI
    task.wait(1)
    pcall(function()
        local cBtn1 = PlayerGui.BossEndgameGUI.EndgameUI.CloseButton
        firesignal(cBtn1.Activated)
        print("🏆 Close EndgameUI")
    end)
    task.wait(0.3)
    pcall(function()
        local cBtn2 = PlayerGui.RewardGui.RewardPanel.Header.CloseBtn
        firesignal(cBtn2.MouseButton1Click)
        print("🎁 Close RewardGui")
    end)
    task.wait(1)
    
    -- 8. Teleport Back
    hrp.CFrame = originalCFrame
    print("🔙 Kembali ke posisi awal!")
    shared.isDoingEvent = false
    print("▶️ Instant Fishing dilanjutkan!")
end

local function scanActiveEvent()
    local bossId, folderName = getActiveBossId()
    if bossId and folderName then
        local cleanFolderName = folderName:gsub("Event$", "")
        local hasSelection = next(selectedEvents) ~= nil
        local isAllowed = not hasSelection or selectedEvents[cleanFolderName] or selectedEvents[folderName]
        
        if isAllowed then
            local EventFolder = workspace:FindFirstChild("Event")
            if EventFolder then
                local folderObj = EventFolder:FindFirstChild(folderName)
                if folderObj then
                    for _, point in ipairs(folderObj:GetChildren()) do
                        for _, obj in ipairs(point:GetChildren()) do
                            if obj.Name:find(bossId, 1, true) then
                                print("🎯 Event aktif ditemukan! Folder:", folderName, "| BossID:", bossId)
                                task.spawn(handleEvent, obj.Position, bossId)
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    
    if selectedEvents["Losi"] then
        local ok, losiPillar = pcall(function()
            return workspace.BossEventMarker_Losi_Clown.BossEventPillar
        end)
        if ok and losiPillar then
            print("🎯 Losi event aktif!")
            task.spawn(handleEvent, losiPillar.Position, "Losi_Clown")
            return true
        end
    end
    
    return false
end

AutoEventSection:CreateToggle({
    Id = "auto_event_toggle",
    Title = "Enable Auto Event",
    Icon = "zap",
    Default = false,
    Callback = function(state)
        autoEventEnabled = state
        if state then
            print("[Auto Event] ON")
            Window:Notify({
                Title = "Auto Event Active",
                Content = "Menunggu event boss muncul...",
                Type = "success",
                Duration = 3
            })
            
            local RS = game:GetService("ReplicatedStorage")
            local Knit = RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services
            local EVENT_ANNOUNCE = Knit.BossFishEventService.RE.EventAnnounce
            
            print("👂 Listen EventAnnounce...")
            eventAnnounceConn = EVENT_ANNOUNCE.OnClientEvent:Connect(function(data)
                if not autoEventEnabled then return end
                print("📢 EVENT ANNOUNCE!")
                print("   Boss:", data.BossDisplayName, "(" .. data.BossName .. ")")
                print("   State:", data.CurrentState)
                
                local bName = (data.BossName or ""):lower()
                local bDisplay = (data.BossDisplayName or ""):lower()
                local hasSelection = next(selectedEvents) ~= nil
                local isAllowed = not hasSelection
                
                if hasSelection then
                    for evName, enabled in pairs(selectedEvents) do
                        if enabled then
                            local lowEv = evName:lower()
                            if bName:find(lowEv) or bDisplay:find(lowEv) then
                                isAllowed = true
                                break
                            end
                        end
                    end
                end
                
                if isAllowed and (data.CurrentState == "Announcing" or data.CurrentState == "Gathering") then
                    local eventPos = Vector3.new(
                        data.EventPosition[1],
                        data.EventPosition[2],
                        data.EventPosition[3]
                    )
                    print("📍 Event Position:", eventPos)
                    task.spawn(handleEvent, eventPos, data.BossName)
                end
            end)
            
            print("✅ Auto Event aktif, nunggu event...")
            eventScanTask = task.spawn(function()
                while autoEventEnabled do
                    if not shared.isDoingEvent then
                        scanActiveEvent()
                    end
                    task.wait(3)
                end
            end)
        else
            print("[Auto Event] OFF")
            if eventAnnounceConn then
                eventAnnounceConn:Disconnect()
                eventAnnounceConn = nil
            end
            if eventScanTask then
                task.cancel(eventScanTask)
                eventScanTask = nil
            end
            -- Reset flag biar bisa deteksi event lagi kalau toggle dihidupin balik
            shared.isDoingEvent = false
            Window:Notify({
                Title = "Auto Event Deactivated",
                Content = "Auto event dimatikan.",
                Type = "info",
                Duration = 3
            })
        end
    end
})

AutoEventSection:CreateButton({
    Id = "auto_event_teleport_now",
    Title = "Teleport Now",
    Icon = "map-pin",
    Callback = function()
        local found = scanActiveEvent()
        if not found then
            Window:Notify({
                Title = "Auto Event",
                Content = "Tidak ada event aktif yang terdeteksi!",
                Type = "warning",
                Duration = 3
            })
        end
    end
})


local autoMinigameEnabled = false
local autoMinigameTask = nil

AutoEventSection:CreateToggle({
    Id = "auto_minigame_toggle",
    Title = "Auto Minigame Only",
    Icon = "activity",
    Default = false,
    Callback = function(state)
        autoMinigameEnabled = state

        if state then
            print("[Auto Minigame] ON")
            Window:Notify({
                Title = "Auto Minigame Active",
                Content = "Scanning event aktif...",
                Type = "success",
                Duration = 3
            })

            autoMinigameTask = task.spawn(function()
                while autoMinigameEnabled do
                    -- Scan event aktif
                    local bossId, folderName = getActiveBossId()

                    if not bossId then
                        print("[Auto Minigame] ⏳ Belum ada event aktif, retry...")
                        task.wait(3)
                        continue
                    end

                    -- Cek apakah sesuai pilihan dropdown
                    local cleanFolderName = folderName and folderName:gsub("Event$", "") or ""
                    local hasSelection = next(selectedEvents) ~= nil
                    local isAllowed = not hasSelection
                        or selectedEvents[cleanFolderName]
                        or selectedEvents[folderName]

                    if not isAllowed then
                        print("[Auto Minigame] ⚠️ Event", bossId, "tidak dipilih, skip...")
                        task.wait(3)
                        continue
                    end

                    print("[Auto Minigame] 🎯 Event ditemukan:", bossId)

                    local RS = game:GetService("ReplicatedStorage")
                    local Knit = RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services
                    local PlayerTap = Knit.BossFishEventService.RF.PlayerTap
                    local LP = game:GetService("Players").LocalPlayer
                    local PlayerGui = LP:WaitForChild("PlayerGui")

                    -- =============================================
                    -- STEP 1: Tunggu StartPulling dulu
                    -- =============================================
                    print("[Auto Minigame] ⏳ Nunggu StartPulling dari server...")
                    local isPullingStarted = false
                    local isEventEnded = false

                    -- Listen EventEnd
                    local endConn
                    endConn = Knit.BossFishEventService.RE.EventEnd.OnClientEvent:Connect(function(data)
                        print("[Auto Minigame] 🏁 EventEnd saat nunggu pull! State:", data and data.State or "nil")
                        isEventEnded = true
                    end)

                    -- Hook namecall buat detect StartPulling
                    local mt = getrawmetatable(game)
                    local oldNamecall = mt.__namecall
                    pcall(function()
                        setreadonly(mt, false)
                        mt.__namecall = newcclosure(function(self, ...)
                            local method = getnamecallmethod()
                            if method == "InvokeServer" then
                                local name = tostring(self.Name or "")
                                if name == "StartPulling" then
                                    print("[Auto Minigame] 🎣 StartPulling terdeteksi!")
                                    isPullingStarted = true
                                end
                            end
                            return oldNamecall(self, ...)
                        end)
                        setreadonly(mt, true)
                    end)

                    -- Tunggu sampai StartPulling atau EventEnd (max 10 menit)
                    local waitStart = tick()
                    while not isPullingStarted and not isEventEnded and autoMinigameEnabled do
                        task.wait(0.1)
                        if tick() - waitStart > 600 then
                            print("[Auto Minigame] ⚠️ Timeout nunggu StartPulling!")
                            break
                        end
                    end

                    -- Restore namecall
                    pcall(function()
                        setreadonly(mt, false)
                        mt.__namecall = oldNamecall
                        setreadonly(mt, true)
                    end)

                    -- Kalau event udah kelar sebelum pull
                    if isEventEnded or not autoMinigameEnabled then
                        endConn:Disconnect()
                        print("[Auto Minigame] ⚠️ Event berakhir sebelum pull dimulai, skip...")
                        task.wait(3)
                        continue
                    end

                    -- =============================================
                    -- STEP 2: StartPulling kedetect → spam tap
                    -- =============================================
                    print("[Auto Minigame] 🚀 StartPulling OK! Mulai spam tap...")

                    -- Monitor UI kemenangan
                    task.spawn(function()
                        task.wait(3)
                        while not isEventEnded and autoMinigameEnabled do
                            local hasVictory, hasReward = false, false
                            pcall(function()
                                hasVictory = PlayerGui.BossEndgameGUI.Enabled
                                    and PlayerGui.BossEndgameGUI.EndgameUI.Visible
                            end)
                            pcall(function()
                                hasReward = PlayerGui.RewardGui.Enabled
                                    and PlayerGui.RewardGui.RewardPanel.Visible
                            end)
                            if hasVictory or hasReward then
                                print("[Auto Minigame] 🏆 UI kemenangan kedetect!")
                                isEventEnded = true
                            end
                            task.wait(1)
                        end
                    end)

                    -- Spam tap loop
                    local count = 0
                    while not isEventEnded and autoMinigameEnabled do
                        local curBossId, _ = getActiveBossId()
                        curBossId = curBossId or bossId

                        local ok, res = pcall(function()
                            return PlayerTap:InvokeServer(curBossId)
                        end)

                        if ok then
                            count += 1
                            if count % 20 == 0 then
                                print("[Auto Minigame] ✅ Tap ke-" .. count .. " | Boss:", curBossId)
                            end
                        else
                            print("[Auto Minigame] ❌ Error tap:", res)
                            break
                        end

                        task.wait(0.05)
                    end

                    endConn:Disconnect()
                    print("[Auto Minigame] 🏁 Selesai! Total tap:", count)

                    -- Close GUI
                    task.wait(1)
                    pcall(function()
                        firesignal(PlayerGui.BossEndgameGUI.EndgameUI.CloseButton.Activated)
                        print("[Auto Minigame] 🏆 Close EndgameUI")
                    end)
                    task.wait(0.3)
                    pcall(function()
                        firesignal(PlayerGui.RewardGui.RewardPanel.Header.CloseBtn.MouseButton1Click)
                        print("[Auto Minigame] 🎁 Close RewardGui")
                    end)

                    print("[Auto Minigame] ⏳ Nunggu event berikutnya...")
                    task.wait(5)
                end
            end)

        else
            print("[Auto Minigame] OFF")
            if autoMinigameTask then
                task.cancel(autoMinigameTask)
                autoMinigameTask = nil
            end
            Window:Notify({
                Title = "Auto Minigame",
                Content = "Auto minigame dimatikan.",
                Type = "info",
                Duration = 3
            })
        end
    end
})

-- =============================================
-- AUTO GACHA PET SECTION (MULTI-EGG + REALTIME)
-- Egg: genesis_egg, ice_egg, + egg baru (auto-detect dari PetShopGui)
-- Semua opsi di bawah (harga & target pet) nyesuain egg yang dipilih.
-- =============================================
local GachaSection = AutoTab:CreateSection({ Title = "Auto Gacha Pet", Box = true, Opened = false })

local GachaModule = (function()
    local M = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players     = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    M.Running   = false
    M.Spins     = 0   -- berapa kali klik gacha (pembelian)
    M.Eggs      = 0   -- total egg kebuka
    M.Spent     = 0   -- total coin kepake
    M.PetCount  = {}
    M.PetCache  = {}  -- eggId -> list pet terakhir yang kebaca
    M.PetSource = {}  -- eggId -> sumber data terakhir
    M.Learned   = {}  -- eggId -> { petId = petName } (dari hasil hatch)
    M.EggList   = {}

    -- ================= HELPER =================
    function M.FormatMoney(n)
        local out = tostring(math.floor(tonumber(n) or 0))
        while true do
            local k
            out, k = out:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
            if k == 0 then break end
        end
        return out
    end

    local function trimNum(x)
        local s = string.format("%.2f", x)
        s = s:gsub("0+$", ""):gsub("%.$", "")
        return s
    end

    local function shortMoney(n)
        n = tonumber(n) or 0
        if n >= 1e9 then return trimNum(n / 1e9) .. "B" end
        if n >= 1e6 then return trimNum(n / 1e6) .. "M" end
        if n >= 1e3 then return trimNum(n / 1e3) .. "k" end
        return tostring(math.floor(n))
    end
    M.ShortMoney = shortMoney

    -- "Glacier Drake" -> "glacier_drake"
    local function slug(name)
        local s = tostring(name):lower():gsub("[^%w]+", "_")
        s = s:gsub("^_+", ""):gsub("_+$", "")
        return s
    end

    -- "ice_egg" -> "Ice Egg"
    local function pretty(id)
        local s = tostring(id):gsub("_", " ")
        s = s:gsub("(%a[%w]*)", function(w) return w:sub(1, 1):upper() .. w:sub(2) end)
        return s
    end

    -- "1.5M" / "300K" / "100,000" -> angka
    local function parseMoney(txt)
        local clean = tostring(txt):upper():gsub(",", "")
        local num, suf = clean:match("([%d%.]+)%s*([KMB]?)")
        local n = tonumber(num)
        if not n then return nil end
        if suf == "K" then n = n * 1e3
        elseif suf == "M" then n = n * 1e6
        elseif suf == "B" then n = n * 1e9 end
        return n
    end

    -- semua egg polanya sama: harga = harga dasar x jumlah egg
    local AMOUNTS = { 1, 3, 5 }
    local function makePrices(base)
        local list = {}
        for _, amt in ipairs(AMOUNTS) do
            local price = base and (base * amt) or 0
            local label = (price > 0)
                and string.format("%s Coin (%dx Egg)", shortMoney(price), amt)
                or  string.format("%dx Egg (harga ?)", amt)
            table.insert(list, { label = label, amount = amt, price = price })
        end
        return list
    end

    -- ================= CONFIG EGG BAWAAN =================
    -- base = harga 1x gacha. Genesis 100k (100k/300k/500k), Ice 300k (300k/900k/1.5M)
    M.EggConfig = {
        {
            id = "genesis_egg", label = "Genesis Egg", base = 100000,
            fallback = {
                { id = "losi_cat",      name = "Losi Cat",      chance = "70%"  },
                { id = "beach_bunny",   name = "Beach Bunny",   chance = "15%"  },
                { id = "coral_crab",    name = "Coral Crab",    chance = "5.2%" },
                { id = "storm_gull",    name = "Storm Gull",    chance = "5.2%" },
                { id = "ember_phoenix", name = "Ember Phoenix", chance = "2%"   },
                { id = "reef_otter",    name = "Reef Otter",    chance = "2%"   },
                { id = "cave_bat",      name = "Cave Bat",      chance = "0.5%" },
                { id = "pond_dragon",   name = "Pond Dragon",   chance = "0.1%" },
            },
        },
        {
            id = "ice_egg", label = "Ice Egg", base = 300000,
            fallback = {
                { id = "frosty",        name = "Frosty",        chance = "70%"  },
                { id = "froshi",        name = "Froshi",        chance = "15%"  },
                { id = "glacub",        name = "Glacub",        chance = "5.2%" },
                { id = "glacirora",     name = "Glacirora",     chance = "5.2%" },
                { id = "frostwing",     name = "Frostwing",     chance = "2%"   },
                { id = "popyun",        name = "Popyun",        chance = "2%"   },
                { id = "glacier_drake", name = "Glacier Drake", chance = "0.5%" },
                { id = "glacieron",     name = "Glacieron",     chance = "0.1%" },
            },
        },
    }

    -- ================= BACA DATA DARI PetShopGui =================
    local function getListEgg()
        local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return nil end
        local shop = pg:FindFirstChild("PetShopGui")
        if shop then
            local le = shop:FindFirstChild("ListEgg", true)
            if le then return le end
        end
        return pg:FindFirstChild("ListEgg", true)
    end

    local function getEggFrame(eggId)
        local le = getListEgg()
        if not le then return nil end
        return le:FindFirstChild(eggId, true)
    end

    -- coba baca harga dasar dari GUI (dipakai buat egg baru yang belum ke-config)
    local function priceFromGui(eggId)
        local frame = getEggFrame(eggId)
        if not frame then return nil end
        local best
        for _, d in ipairs(frame:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local n = d.Name:lower()
                if n:find("price") or n:find("cost") or n:find("coin") or n:find("money") then
                    local v = parseMoney(d.Text)
                    if v and v > 0 and (not best or v < best) then best = v end
                end
            end
        end
        return best
    end

    -- baca PetList (PetLabel + Chance) persis kaya cara manual lu
    local function petsFromGui(eggId)
        local out = {}
        local frame = getEggFrame(eggId)
        if not frame then return out end
        local petList = frame:FindFirstChild("PetList", true)
        if not petList then return out end
        for _, pet in ipairs(petList:GetChildren()) do
            if pet:IsA("GuiObject") then
                local lbl = pet:FindFirstChild("PetLabel", true)
                local ch  = pet:FindFirstChild("Chance", true)
                local name = lbl and lbl.Text
                if type(name) == "string" and name ~= "" and name ~= "Unknown" then
                    local chanceTxt = (ch and ch.Text ~= "" and ch.Text) or "?"
                    table.insert(out, {
                        id     = slug(name),
                        name   = name,
                        chance = chanceTxt,
                        _n     = tonumber(tostring(chanceTxt):match("[%d%.]+")) or -1,
                    })
                end
            end
        end
        return out
    end

    -- ================= FILTER: COIN ONLY =================
    -- Egg premium (Robux / gamepass / gem / ticket) di-skip, cuma egg coin yang masuk.
    local NON_COIN_WORDS = {
        "robux", "premium", "gamepass", "gamePass", "gem", "diamond", "ticket",
        "star", "token", "vip", "exclusive", "limited", "gift", "donate", "shop_robux",
    }

    local function hasNonCoinWord(txt)
        txt = tostring(txt):lower()
        for _, w in ipairs(NON_COIN_WORDS) do
            if txt:find(w, 1, true) then return true end
        end
        return false
    end

    -- true kalau egg ini dibeli pakai coin
    local function isCoinEgg(eggId)
        if hasNonCoinWord(eggId) then return false end
        local frame = getEggFrame(eggId)
        if not frame then return false end
        local sawCoin = false
        for _, d in ipairs(frame:GetDescendants()) do
            if hasNonCoinWord(d.Name) then return false end
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local t = tostring(d.Text)
                if t:find("R$", 1, true) or hasNonCoinWord(t) then return false end
                local nm = d.Name:lower()
                if nm:find("coin") or nm:find("money") or nm:find("price") or nm:find("cost") then
                    if parseMoney(t) then sawCoin = true end
                end
            elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
                if hasNonCoinWord(d.Name) then return false end
            end
        end
        return sawCoin
    end

    -- ================= DAFTAR EGG (REALTIME) =================
    function M.GetEggs()
        local list, seen = {}, {}
        for _, e in ipairs(M.EggConfig) do
            local base = e.base or priceFromGui(e.id)
            table.insert(list, {
                id = e.id, label = e.label, base = base,
                prices = makePrices(base), known = true,
            })
            seen[e.id] = true
        end
        -- egg baru yang muncul abis update -> otomatis masuk pilihan
        local le = getListEgg()
        if le then
            for _, child in ipairs(le:GetChildren()) do
                local id = child.Name
                if not seen[id] and child:FindFirstChild("PetList", true) then
                    seen[id] = true
                    local base = priceFromGui(id)
                    -- skip egg premium (Robux/gem/gamepass), coin only
                    if base and base > 0 and isCoinEgg(id) then
                        table.insert(list, {
                            id = id, label = pretty(id) .. " (baru)", base = base,
                            prices = makePrices(base), known = false,
                        })
                    end
                end
            end
        end
        M.EggList = list
        return list
    end

    function M.GetEgg(eggId)
        for _, e in ipairs(M.EggList) do if e.id == eggId then return e end end
        for _, e in ipairs(M.GetEggs()) do if e.id == eggId then return e end end
        return nil
    end

    -- ================= DAFTAR PET PER EGG (REALTIME) =================
    local function fallbackPets(eggId)
        for _, e in ipairs(M.EggConfig) do
            if e.id == eggId then
                local list = {}
                for _, p in ipairs(e.fallback or {}) do
                    table.insert(list, {
                        id = p.id, name = p.name or pretty(p.id), chance = p.chance,
                        _n = tonumber(tostring(p.chance):match("[%d%.]+")) or -1,
                    })
                end
                return list
            end
        end
        return {}
    end

    function M.GetPets(eggId)
        eggId = eggId or (M.EggConfig[1] and M.EggConfig[1].id)
        if not eggId then return {} end

        local list = petsFromGui(eggId)
        local src  = "PetShopGui (realtime)"

        if #list == 0 then
            local base = M.PetCache[eggId]
            src = "cache"
            if not base or #base == 0 then
                base = fallbackPets(eggId)
                src = (#base > 0) and "fallback list" or "-"
            end
            list = {}
            for _, p in ipairs(base) do
                table.insert(list, { id = p.id, name = p.name, chance = p.chance, _n = p._n })
            end
        end

        -- pet yang kedapetan pas gacha tapi belum ada di list -> ikut masuk
        for id, nm in pairs(M.Learned[eggId] or {}) do
            local exists = false
            for _, p in ipairs(list) do if p.id == id then exists = true break end end
            if not exists then
                table.insert(list, { id = id, name = nm, chance = "?", _n = -1 })
            end
        end

        table.sort(list, function(a, b)
            local an, bn = a._n or -1, b._n or -1
            if an ~= bn then return an > bn end
            return tostring(a.name or a.id) < tostring(b.name or b.id)
        end)

        if #list > 0 then M.PetCache[eggId] = list end
        M.PetSource[eggId] = src
        return list
    end

    function M.LearnPet(eggId, petId, petName)
        if type(petId) ~= "string" or petId == "" then return end
        M.Learned[eggId] = M.Learned[eggId] or {}
        if M.Learned[eggId][petId] then return end
        M.Learned[eggId][petId] = petName or pretty(petId)
    end

    -- ================= REMOTE =================
    local function getRemotes()
        local ok, buy, hatched = pcall(function()
            local knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit
            local svc  = knit.Services.PetShopService
            return svc.RF.BuyEgg, svc.RE.EggHatched
        end)
        if ok then return buy, hatched end
        return nil, nil
    end
    M.IsSupported = function() local b = getRemotes() return b ~= nil end

    -- cfg = { eggId, eggLabel, amount, price, label, targets = {petId=true},
    --         maxSpins, Delay, OnProgress, OnSuccess, OnFinish, OnError, OnStop }
    function M.Start(cfg)
        if M.Running then return false, "already running" end
        local BuyEgg, EggHatched = getRemotes()
        if not BuyEgg then return false, "remote not found" end

        local eggId = cfg.eggId or "genesis_egg"

        M.Running  = true
        M.Spins    = 0
        M.Eggs     = 0
        M.Spent    = 0
        M.PetCount = {}

        -- Bypass GUI hatch biar animasi egg ga muncul tiap gacha
        local conns = {}
        if typeof(getconnections) == "function" and EggHatched then
            pcall(function()
                conns = getconnections(EggHatched.OnClientEvent)
                for _, c in ipairs(conns) do c:Disable() end
            end)
        end

        task.spawn(function()
            while M.Running do
                local ok, r = pcall(function()
                    return table.pack(BuyEgg:InvokeServer(eggId, cfg.amount))
                end)

                if not ok or not r[1] then
                    if cfg.OnError then pcall(cfg.OnError, tostring((type(r) == "table" and r[2]) or r)) end
                    task.wait(3)
                else
                    M.Spins = M.Spins + 1
                    M.Eggs  = M.Eggs + cfg.amount
                    M.Spent = M.Spent + (cfg.price or 0)

                    local found = nil
                    local pets = r[2]
                    if type(pets) == "table" then
                        for _, pet in ipairs(pets) do
                            if type(pet) == "table" then
                                local pid  = pet.PetId or pet.Id
                                local name = pet.Name or pid or "Unknown"
                                local sid  = pid and slug(pid) or slug(name)
                                M.PetCount[name] = (M.PetCount[name] or 0) + 1
                                -- pet baru langsung didaftarin ke list egg ini
                                M.LearnPet(eggId, pid or sid, pet.Name)
                                if cfg.targets and (
                                    (pid and cfg.targets[pid]) or cfg.targets[sid] or cfg.targets[slug(name)]
                                ) then
                                    found = { id = pid or sid, name = name, rarity = pet.Rarity }
                                end
                            end
                        end
                    end

                    if cfg.OnProgress then pcall(cfg.OnProgress, M.Spins, M.Eggs, M.Spent) end

                    if found then
                        M.Running = false
                        if cfg.OnSuccess then pcall(cfg.OnSuccess, found, M.Spins, M.Eggs, M.Spent) end
                        break
                    end

                    if cfg.maxSpins and M.Spins >= cfg.maxSpins then
                        M.Running = false
                        if cfg.OnFinish then pcall(cfg.OnFinish, M.Spins, M.Eggs, M.Spent) end
                        break
                    end
                end
                task.wait(cfg.Delay or 0.35)
            end

            -- Balikin GUI hatch ke semula
            for _, c in ipairs(conns) do pcall(function() c:Enable() end) end
            M.Running = false
            if cfg.OnStop then pcall(cfg.OnStop, M.Spins, M.Eggs, M.Spent) end
        end)
        return true
    end

    function M.Stop()
        if not M.Running then return false end
        M.Running = false
        return true
    end

    M.GetEggs()
    return M
end)()

-- ---------- STATE UI ----------
local gachaEggOptions,   gachaEggMap   = {}, {}
local gachaPriceOptions, gachaPriceMap = {}, {}
local gachaPetOptions,   gachaPetMap   = {}, {}

local gachaCurrentEgg      = GachaModule.EggList[1]
local gachaSelectedPrice   = gachaCurrentEgg and gachaCurrentEgg.prices[1] or nil
local gachaSelectedTargets = {}
local gachaTargetNames     = {}
local gachaMaxSpins        = nil

local gachaEggDrop, gachaPriceDrop, gachaPetDrop, gachaStatus, gachaProgress

local function buildEggOptions()
    local opts, map = {}, {}
    for _, egg in ipairs(GachaModule.GetEggs()) do
        table.insert(opts, egg.label)
        map[egg.label] = egg
    end
    gachaEggOptions, gachaEggMap = opts, map
    return opts
end

local function buildPriceOptions(egg)
    local opts, map = {}, {}
    egg = egg or gachaCurrentEgg
    for _, o in ipairs((egg and egg.prices) or {}) do
        table.insert(opts, o.label)
        map[o.label] = o
    end
    gachaPriceOptions, gachaPriceMap = opts, map
    return opts
end

local function buildPetOptions(egg)
    local opts, map = {}, {}
    egg = egg or gachaCurrentEgg
    for _, pet in ipairs(GachaModule.GetPets(egg and egg.id)) do
        local display = string.format("%s (%s)", pet.name or pet.id, pet.chance or "?")
        table.insert(opts, display)
        map[display] = pet.id
    end
    gachaPetOptions, gachaPetMap = opts, map
    return opts
end

local function gachaUpdateStatus()
    if not (gachaStatus and gachaStatus.SetText) then return end
    local egg = gachaCurrentEgg
    if not egg then gachaStatus.SetText("Egg belum kedetek") return end
    local pets = GachaModule.GetPets(egg.id)
    gachaStatus.SetText(string.format("%s  -  %d pet", egg.label, #pets))
end

local function gachaApplySelection(selected)
    gachaSelectedTargets = {}
    gachaTargetNames = {}
    if type(selected) == "table" then
        for _, display in ipairs(selected) do
            local id = gachaPetMap[display]
            if not id then
                -- kalau teks chance berubah, nama pet-nya tetep kebaca
                local nm = tostring(display):match("^(.-)%s*%b()$") or tostring(display)
                id = (nm:lower():gsub("[^%w]+", "_"))
            end
            if id and id ~= "" then
                gachaSelectedTargets[id] = true
                table.insert(gachaTargetNames, id)
            end
        end
    end
end

-- ganti egg -> harga + target pet ikut nyesuain
local function gachaSelectEgg(egg, notify)
    if not egg then return end
    gachaCurrentEgg = egg

    local priceOpts = buildPriceOptions(egg)
    gachaSelectedPrice = egg.prices[1]
    if gachaPriceDrop then
        if gachaPriceDrop.SetValues then gachaPriceDrop.SetValues(priceOpts) end
        if gachaPriceDrop.Set then gachaPriceDrop.Set(priceOpts[1]) end
    end

    gachaSelectedTargets, gachaTargetNames = {}, {}
    local petOpts = buildPetOptions(egg)
    if gachaPetDrop then
        if gachaPetDrop.SetValues then gachaPetDrop.SetValues(petOpts) end
        if gachaPetDrop.Set then gachaPetDrop.Set({}) end
    end

    gachaUpdateStatus()
    if notify then
        Window:Notify({
            Title = "Auto Gacha",
            Content = string.format("%s  -  %d pet", egg.label, #petOpts),
            Type = "info", Duration = 2,
        })
    end
end

-- ---------- 1. DROPDOWN PILIH EGG ----------
gachaEggDrop = GachaSection:CreateDropdown({
    Id = "gacha_egg_type",
    Title = "Egg",
    Icon = "egg",
    Values = buildEggOptions(),
    Default = gachaEggOptions[1],
    Refresh = buildEggOptions,   -- egg baru abis update otomatis nongol
    RefreshInterval = 5,
    Callback = function(v)
        local egg = gachaEggMap[v]
        if egg and (not gachaCurrentEgg or egg.id ~= gachaCurrentEgg.id) then
            gachaSelectEgg(egg, true)
        end
    end
})

-- ---------- 2. DROPDOWN HARGA / JUMLAH EGG ----------
gachaPriceDrop = GachaSection:CreateDropdown({
    Id = "gacha_egg_price",
    Title = "Harga",
    Values = buildPriceOptions(gachaCurrentEgg),
    Default = gachaPriceOptions[1],
    Callback = function(v)
        gachaSelectedPrice = gachaPriceMap[v] or (gachaCurrentEgg and gachaCurrentEgg.prices[1])
        if gachaSelectedPrice then print("[Auto Gacha] Harga:", gachaSelectedPrice.label) end
    end
})

-- ---------- 3. MULTI DROPDOWN TARGET PET ----------
gachaPetDrop = GachaSection:CreateMultiDropdown({
    Id = "gacha_target_pets",
    Sidebar = true,
    Title = "Target Pet",
    Values = buildPetOptions(gachaCurrentEgg),
    Default = {},
    Refresh = function() return buildPetOptions(gachaCurrentEgg) end,
    RefreshInterval = 3,
    Callback = function(selected)
        gachaApplySelection(selected)
        print("[Auto Gacha] Target pet:", #gachaTargetNames > 0 and table.concat(gachaTargetNames, ", ") or "None")
    end
})

-- ---------- 4. INPUT JUMLAH GACHA ----------
GachaSection:CreateInput({
    Id = "gacha_max_spins",
    Title = "Jumlah Gacha",
    Placeholder = "0 = sampai dapat",
    Default = "",
    Callback = function(text)
        local n = tonumber(tostring(text):match("%d+"))
        if n and n > 0 then
            gachaMaxSpins = n
            print("[Auto Gacha] Max gacha:", n)
        else
            gachaMaxSpins = nil
            print("[Auto Gacha] Max gacha: unlimited (sampai dapat)")
        end
    end
})

-- ---------- 5. STATUS + REFRESH ----------
gachaStatus = GachaSection:CreateLabel({
    Id = "gacha_status",
    Title = "Memuat...",
})

GachaSection:CreateButton({
    Id = "gacha_refresh_pets",
    Title = "Refresh List",
    Icon = "refresh-cw",
    Callback = function()
        local eggs = buildEggOptions()
        if gachaEggDrop and gachaEggDrop.SetValues then gachaEggDrop.SetValues(eggs, true) end
        -- pastiin egg aktif masih ada, kalau ga balik ke egg pertama
        local stillThere = gachaCurrentEgg and GachaModule.GetEgg(gachaCurrentEgg.id) or nil
        gachaSelectEgg(stillThere or GachaModule.EggList[1], false)
        Window:Notify({
            Title = "Auto Gacha",
            Content = string.format("%d egg  -  %d pet", #eggs, #gachaPetOptions),
            Type = "success", Duration = 3,
        })
    end
})

-- ---------- 6. TOMBOL START & STOP ----------
local function gachaSetProgress(text)
    if gachaProgress and gachaProgress.SetText then gachaProgress.SetText(text) end
end

local function gachaTargetText()
    local c = #gachaTargetNames
    if c == 0 then return "semua pet" end
    if c <= 2 then return table.concat(gachaTargetNames, ", ") end
    return string.format("%s +%d", gachaTargetNames[1], c - 1)
end

GachaSection:CreateButtonRow({
    Buttons = {
        {
            Title = "Start",
            Color = Color3.fromRGB(80, 190, 120),
            Callback = function()
                if GachaModule.Running then
                    Window:Notify({ Title = "Auto Gacha", Content = "Udah jalan.", Type = "info", Duration = 2 })
                    return
                end
                if not GachaModule.IsSupported() then
                    Window:Notify({ Title = "Auto Gacha", Content = "Remote ga ketemu.", Type = "error", Duration = 3 })
                    return
                end

                local egg = gachaCurrentEgg
                if not egg then
                    Window:Notify({ Title = "Auto Gacha", Content = "Pilih egg dulu.", Type = "warning", Duration = 2 })
                    return
                end

                -- sync ulang pilihan dari dropdown (jaga-jaga list abis refresh)
                if gachaPetDrop and gachaPetDrop.Get then
                    gachaApplySelection(gachaPetDrop.Get())
                end

                local hasTarget = next(gachaSelectedTargets) ~= nil
                if not hasTarget and not gachaMaxSpins then
                    Window:Notify({ Title = "Auto Gacha", Content = "Pilih target pet atau isi jumlah gacha.", Type = "warning", Duration = 3 })
                    return
                end

                local priceOpt = gachaSelectedPrice or egg.prices[1]
                local targetTxt = gachaTargetText()

                gachaSetProgress(string.format("Jalan  -  %s  -  target: %s", egg.label, targetTxt))

                GachaModule.Start({
                    eggId    = egg.id,
                    eggLabel = egg.label,
                    amount   = priceOpt.amount,
                    price    = priceOpt.price,
                    label    = priceOpt.label,
                    targets  = hasTarget and gachaSelectedTargets or nil,
                    maxSpins = gachaMaxSpins,

                    OnProgress = function(spins, eggs, spent)
                        gachaSetProgress(string.format(
                            "%dx gacha  -  %d egg  -  %s coin",
                            spins, eggs, GachaModule.FormatMoney(spent)))
                    end,

                    OnSuccess = function(pet, spins, eggs, spent)
                        gachaSetProgress(string.format(
                            "Dapat %s!  -  %dx gacha  -  %s coin",
                            pet.name or pet.id, spins, GachaModule.FormatMoney(spent)))
                        Window:Notify({
                            Title = "Dapat " .. tostring(pet.name or pet.id) .. "!",
                            Content = string.format("%dx gacha  -  %s coin", spins, GachaModule.FormatMoney(spent)),
                            Type = "success", Duration = 6,
                        })
                    end,

                    OnFinish = function(spins, eggs, spent)
                        gachaSetProgress(string.format(
                            "Selesai  -  %dx gacha  -  %s coin  -  target belum dapat",
                            spins, GachaModule.FormatMoney(spent)))
                        Window:Notify({ Title = "Auto Gacha Selesai", Content = string.format("%dx gacha  -  %s coin", spins, GachaModule.FormatMoney(spent)), Type = "warning", Duration = 4 })
                    end,

                    OnError = function(err)
                        gachaSetProgress(string.format(
                            "Gagal beli (coin kurang?)  -  %dx gacha", GachaModule.Spins))
                    end,

                    OnStop = function(spins, eggs, spent)
                        print("[Auto Gacha] Berhenti. Egg:", egg.id, "| Total:", spins, "gacha | coin:", spent)
                    end,
                })

                Window:Notify({
                    Title = "Auto Gacha",
                    Content = string.format("%s  -  %s", egg.label, priceOpt.label),
                    Type = "success", Duration = 3,
                })
            end
        },
        {
            Title = "Stop",
            Color = Color3.fromRGB(220, 90, 90),
            Callback = function()
                if not GachaModule.Running then
                    Window:Notify({ Title = "Auto Gacha", Content = "Lagi ga jalan.", Type = "info", Duration = 2 })
                    return
                end
                GachaModule.Stop()
                gachaSetProgress(string.format(
                    "Berhenti  -  %dx gacha  -  %s coin",
                    GachaModule.Spins, GachaModule.FormatMoney(GachaModule.Spent)))
                Window:Notify({ Title = "Auto Gacha", Content = "Dihentikan.", Type = "info", Duration = 2 })
            end
        },
    }
})

-- ---------- 7. PARAGRAF PROGRES ----------
gachaProgress = GachaSection:CreateParagraph({
    Id    = "gacha_progress",
    Title = "Progres",
    Text  = "Belum jalan.",
})

-- ---------- 8. SINKRON AWAL + AUTO-SYNC EGG BARU ----------
gachaSelectEgg(gachaCurrentEgg, false)

task.spawn(function()
    while true do
        task.wait(5)
        if not GachaModule.Running then
            pcall(gachaUpdateStatus)
        end
    end
end)


-- =============================================
-- AUTO Equip & Buy Potions
-- =============================================
local AutoPotionSection = AutoTab:CreateSection({ Title = "Auto Equip Potions", Box = true, Opened = false })

-- === Dependencies (self-contained, biar gak nil) ===
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit

local PotionService = Knit.Services.PotionService
local ConsumePotion = PotionService.RF.ConsumePotion
local GetMyState = PotionService.RF.GetMyState
local StateChangedEvent = PotionService.RE.StateChanged

local PotionShopService = Knit.Services.PotionShopService
local GetShopData = PotionShopService.RF.GetShopData
local BuyPotion = PotionShopService.RF.BuyPotion

-- === Build potion list (dropdown options) ===
local potionOptions = {}
local potionMap = {} -- label -> { PotionId, DisplayName, CoinPrice }

local function RefreshPotionList()
    potionOptions = {}
    potionMap = {}

    local success, data = pcall(function()
        return GetShopData:InvokeServer()
    end)

    if success and type(data) == "table" and data.Catalog then
        for _, potion in ipairs(data.Catalog) do
            if not potion.IsRobuxOnly and potion.CoinPrice then
                local label = potion.DisplayName
                table.insert(potionOptions, label)
                potionMap[label] = {
                    PotionId = potion.PotionId,
                    DisplayName = potion.DisplayName,
                    CoinPrice = potion.CoinPrice
                }
            end
        end
    else
        warn("[AutoPotion] Gagal ambil shop data buat build list")
    end
end

RefreshPotionList()

-- =============================================
-- AUTO BUY POTION
-- =============================================
local AutoBuyPotion = (function()
    local M = { Enabled = false, Thread = nil }

    local selectedBuyPotion = nil
    local buyAmount = 1
    local buyDelay = 5 -- detik

    AutoPotionSection:CreateDropdown({
        Id = "autobuy_potion_dropdown",
        Title = "Pilih Potion (Auto Buy)",
        Sidebar = true,
        Values = potionOptions,
        Default = nil,
        Callback = function(v)
            selectedBuyPotion = potionMap[v]
            print("[AutoBuyPotion] Target:", v or "None")
        end
    })

    AutoPotionSection:CreateInput({
        Id = "autobuy_potion_amount",
        Title = "Jumlah Beli (per loop)",
        Placeholder = "1",
        Default = "",
        Callback = function(text)
            local n = tonumber(tostring(text):match("%d+"))
            buyAmount = (n and n > 0) and n or 1
            print("[AutoBuyPotion] Jumlah beli:", buyAmount)
        end
    })

    AutoPotionSection:CreateInput({
        Id = "autobuy_potion_delay",
        Title = "Delay Buy (detik)",
        Placeholder = "5",
        Default = "",
        Callback = function(text)
            local n = tonumber(tostring(text):match("%d+"))
            buyDelay = (n and n > 0) and n or 5
            print("[AutoBuyPotion] Delay:", buyDelay)
        end
    })

    function M.Start()
        if M.Enabled then return end
        if not selectedBuyPotion then
            if Window then
                Window:Notify({ Title = "Auto Buy Potion", Content = "Pilih potion dulu sebelum start!", Type = "warning", Duration = 3 })
            end
            return
        end

        M.Enabled = true
        print("[AutoBuyPotion] ON")
        if Window then
            Window:Notify({ Title = "Auto Buy Potion Active", Content = "Otomatis membeli potion secara berkala.", Type = "info", Duration = 3 })
        end

        M.Thread = task.spawn(function()
            while M.Enabled do
                if selectedBuyPotion then
                    local success, result = pcall(function()
                        return BuyPotion:InvokeServer(selectedBuyPotion.PotionId, buyAmount)
                    end)

                    if success then
                        print("[AutoBuyPotion] Beli:", buyAmount .. "x " .. selectedBuyPotion.PotionId)
                    else
                        warn("[AutoBuyPotion] Gagal beli:", result)
                    end
                end
                task.wait(buyDelay)
            end
        end)
    end

    function M.Stop()
        if not M.Enabled then return end
        M.Enabled = false
        if M.Thread then
            task.cancel(M.Thread)
            M.Thread = nil
        end
        print("[AutoBuyPotion] OFF")
        if Window then
            Window:Notify({ Title = "Auto Buy Potion Deactivated", Content = "Fitur auto buy potion dimatikan.", Type = "success", Duration = 3 })
        end
    end

    return M
end)()

AutoPotionSection:CreateToggle({
    Id = "autobuy_potion_toggle",
    Title = "Auto Buy Potion",
    Icon = "shopping-cart",
    Default = false,
    Callback = function(state)
        if state then
            AutoBuyPotion.Start()
        else
            AutoBuyPotion.Stop()
        end
    end
})

AutoPotionSection:CreateDivider()
AutoPotionSection:CreateSpace(4)

-- =============================================
-- AUTO EQUIP POTION (pake GetMyState + StateChanged)
-- =============================================
local AutoEquipPotion = (function()
    local M = { Enabled = false, Thread = nil }

    local selectedEquipPotion = nil
    local cachedState = nil
    local isConsuming = false

    local function RefreshState()
        local success, state = pcall(function()
            return GetMyState:InvokeServer()
        end)
        if success and type(state) == "table" then
            cachedState = state
        else
            warn("[AutoEquipPotion] Gagal ambil state:", state)
        end
        return cachedState
    end

    local function GetRemaining(potionId)
        if not cachedState or not cachedState.Active then return 0 end
        local active = cachedState.Active[potionId]
        return active and tonumber(active.RemainingSeconds) or 0
    end

    local function GetOwned(potionId)
        if not cachedState or not cachedState.Inventory then return 0 end
        return tonumber(cachedState.Inventory[potionId]) or 0
    end

    StateChangedEvent.OnClientEvent:Connect(function(...)
        RefreshState()
    end)

    AutoPotionSection:CreateDropdown({
        Id = "autoequip_potion_dropdown",
        Title = "Pilih Potion (Auto Equip)",
        Sidebar = true,
        Values = potionOptions,
        Default = nil,
        Callback = function(v)
            selectedEquipPotion = potionMap[v]
            print("[AutoEquipPotion] Target:", v or "None")
        end
    })

    local function TryConsume(potionId)
        if isConsuming then return false end
        isConsuming = true

        local owned = GetOwned(potionId)
        if owned <= 0 then
            warn("[AutoEquipPotion] Stok " .. potionId .. " habis!")
            if Window then
                Window:Notify({ Title = "Auto Equip Potion", Content = "Stok " .. potionId .. " habis! Nyalain Auto Buy dulu.", Type = "warning", Duration = 4 })
            end
            isConsuming = false
            return false
        end

        local success, result = pcall(function()
            return ConsumePotion:InvokeServer(potionId, 1)
        end)

        if success then
            print("[AutoEquipPotion] Consume berhasil:", potionId)
            RefreshState()
        else
            warn("[AutoEquipPotion] Consume gagal:", result)
        end

        isConsuming = false
        return success
    end

    function M.Start()
        if M.Enabled then return end
        M.Enabled = true
        print("[AutoEquipPotion] ON")
        if Window then
            Window:Notify({ Title = "Auto Equip Potion Active", Content = "Otomatis re-equip potion saat habis.", Type = "info", Duration = 3 })
        end

        RefreshState()

        M.Thread = task.spawn(function()
            while M.Enabled do
                if selectedEquipPotion and not isConsuming then
                    local remaining = GetRemaining(selectedEquipPotion.PotionId)
                    if remaining <= 0 then
                        TryConsume(selectedEquipPotion.PotionId)
                    end
                end
                task.wait(2)
            end
        end)
    end

    function M.Stop()
        if not M.Enabled then return end
        M.Enabled = false
        if M.Thread then
            task.cancel(M.Thread)
            M.Thread = nil
        end
        print("[AutoEquipPotion] OFF")
        if Window then
            Window:Notify({ Title = "Auto Equip Potion Deactivated", Content = "Fitur auto equip potion dimatikan.", Type = "success", Duration = 3 })
        end
    end

    return M
end)()

AutoPotionSection:CreateToggle({
    Id = "autoequip_potion_toggle",
    Title = "Auto Equip Potion",
    Icon = "zap",
    Default = false,
    Callback = function(state)
        if state then
            AutoEquipPotion.Start()
        else
            AutoEquipPotion.Stop()
        end
    end
})

AutoPotionSection:CreateDivider()
AutoPotionSection:CreateSpace(4)

AutoPotionSection:CreateButton({
    Id = "autopotion_refresh_btn",
    Title = "Refresh Potion List",
    Callback = function()
        RefreshPotionList()
        if Window then
            Window:Notify({ Title = "Auto Potion", Content = "List potion di-refresh!", Type = "info", Duration = 3 })
        end
    end
})
-- =============================================
-- AUTO QUEST SECTION
-- =============================================
local QuestSection = AutoTab:CreateSection({ Title = "Quest", Box = true, Opened = false })

local QuestModule = (function()
    local M = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    M.Running = false
    
    -- Ambil remote QuestService (knit)
    local function getQuestRF()
        local ok, rf = pcall(function()
            return ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.QuestService.RF
        end)
        if ok then return rf end
        return nil
    end
    
    M.IsSupported = function() return getQuestRF() ~= nil end
    
    -- Semua NPC + quest ID-nya
    local NPC_QUESTS = {
        ["Elder Hermit"]           = { "island_1_quest_1", "island_1_quest_2", "island_1_quest_3", "island_1_quest_4", "island_1_quest_5" },
        ["Grandpa Igloo"]          = { "island_2_quest_1", "island_2_quest_2", "island_2_quest_3", "island_2_quest_4" },
        ["Sanctuary Guard"]        = { "island_3_quest_1", "island_3_quest_2", "island_3_quest_3", "island_3_quest_4", "island_3_quest_5" },
        ["Deep Sea Diver"]         = { "island_4_quest_1", "island_4_quest_2", "island_4_quest_3", "island_4_quest_4", "island_4_quest_5" },
        ["Demonic Blacksmith"]     = { "island_5_quest_1", "island_5_quest_2", "island_5_quest_3", "island_5_quest_4", "island_5_quest_5" },
        ["Old Survivor"]           = { "island_6_quest_1", "island_6_quest_2", "island_6_quest_3", "island_6_quest_4" },
        ["Senior Fisherman"]       = { "island_7_quest_1", "island_7_quest_2", "island_7_quest_3", "island_7_quest_4" },
        ["Environmental Explorer"] = { "island_8_quest_1", "island_8_quest_2", "island_8_quest_3", "island_8_quest_4", "island_8_quest_5" },
        ["Fairy Forest Guard"]     = { "island_9_quest_1", "island_9_quest_2", "island_9_quest_3", "island_9_quest_4" },
        ["Dragon Knight"]          = { "island_10_quest_1", "island_10_quest_2", "island_10_quest_3", "island_10_quest_4", "island_10_quest_5" },
        ["Ancient Diver"]          = { "island_11_quest_1", "island_11_quest_2", "island_11_quest_3", "island_11_quest_4", "island_11_quest_5" },
    }
    
    -- cfg = { OnStart, OnProgress, OnFinish }
    function M.Start(cfg)
        if M.Running then return false, "already running" end
        local QuestRF = getQuestRF()
        if not QuestRF then return false, "remote not found" end
        
        M.Running = true
        
        task.spawn(function()
            -- Snapshot active + completed sebelum mulai
            local completed = QuestRF.GetCompletedQuests:InvokeServer() or {}
            local active    = QuestRF.GetActiveQuests:InvokeServer() or {}

            local accepted = 0
            local skipped  = 0
            local failed   = 0

            if cfg.OnStart then pcall(cfg.OnStart) end

            for npcName, quests in pairs(NPC_QUESTS) do
                if not M.Running then break end
                
                if cfg.OnProgress then pcall(cfg.OnProgress, accepted, skipped, failed, npcName) end

                -- InteractNPC sekali per NPC
                QuestRF.InteractNPC:InvokeServer(npcName)
                task.wait(0.2)

                for _, questId in ipairs(quests) do
                    if not M.Running then break end
                    
                    -- Skip kalau udah completed atau udah active
                    if completed[questId] then
                        skipped = skipped + 1
                        continue
                    end
                    if active[questId] then
                        skipped = skipped + 1
                        continue
                    end

                    -- Cek prerequisite
                    local questNum = tonumber(string.match(questId, "_(%d+)$"))
                    if questNum and questNum > 1 then
                        local prevId = string.gsub(questId, "_(%d+)$", "_" .. (questNum - 1))
                        if not completed[prevId] and not active[prevId] then
                            skipped = skipped + 1
                            continue
                        end
                    end

                    local ok, err = QuestRF.AcceptQuest:InvokeServer(questId)

                    if ok then
                        accepted = accepted + 1
                        active[questId] = { State = "Active", CurrentProgress = 0, Goal = 0 }
                    else
                        failed = failed + 1
                    end

                    task.wait(0.3) -- anti-spam
                end

                task.wait(0.2)
            end

            M.Running = false
            if cfg.OnFinish then pcall(cfg.OnFinish, accepted, skipped, failed) end
        end)
        
        return true
    end
    
    function M.Stop()
        if not M.Running then return false end
        M.Running = false
        return true
    end
    
    return M
end)()

-- ---------- STATE UI ----------
local questProgress

-- ---------- TOMBOL START (HIJAU) & STOP (MERAH) ----------
QuestSection:CreateButtonRow({
    Buttons = {
        {
            Title = "Auto Claim Quest",
            Color = Color3.fromRGB(80, 190, 120),
            Callback = function()
                if QuestModule.Running then
                    Window:Notify({ Title = "Auto Quest", Content = "Auto quest udah jalan bro!", Type = "info", Duration = 3 })
                    return
                end
                if not QuestModule.IsSupported() then
                    Window:Notify({ Title = "Auto Quest", Content = "Remote QuestService ga ketemu.", Type = "error", Duration = 4 })
                    return
                end

                QuestModule.Start({
                    OnStart = function()
                        Window:Notify({ Title = "Auto Quest", Content = "Mulai claim quest...", Type = "success", Duration = 3 })
                    end,
                    OnProgress = function(accepted, skipped, failed, currentNpc)
                        if questProgress and questProgress.SetText then
                            questProgress.SetText(string.format(
                                "Sedang proses NPC: %s\nAccepted: %d | Skipped: %d | Failed: %d",
                                currentNpc, accepted, skipped, failed
                            ))
                        end
                    end,
                    OnFinish = function(accepted, skipped, failed)
                        if questProgress and questProgress.SetText then
                            questProgress.SetText(string.format(
                                "Selesai!\nAccepted: %d | Skipped: %d | Failed: %d",
                                accepted, skipped, failed
                            ))
                        end
                        Window:Notify({ 
                            Title = "Auto Quest Selesai", 
                            Content = string.format("Accepted: %d | Skipped: %d | Failed: %d", accepted, skipped, failed), 
                            Type = "success", 
                            Duration = 5 
                        })
                    end
                })
            end
        },
        {
            Title = "Stop",
            Color = Color3.fromRGB(220, 90, 90),
            Callback = function()
                if not QuestModule.Running then
                    Window:Notify({ Title = "Auto Quest", Content = "Auto quest lagi ga jalan.", Type = "info", Duration = 3 })
                    return
                end
                QuestModule.Stop()
                Window:Notify({ Title = "Auto Quest", Content = "Auto quest dihentikan.", Type = "info", Duration = 3 })
                if questProgress and questProgress.SetText then
                    questProgress.SetText("Dihentikan manual.")
                end
            end
        }
    }
})

-- ---------- PARAGRAF PROGRES ----------
questProgress = QuestSection:CreateParagraph({
    Id    = "quest_progress",
    Title = "Progres Quest",
    Text  = "Tekan 'Auto Claim Quest' untuk mulai accept semua quest dari NPC.",
})


-- ================================================================
--  Webhook Tab
-- ================================================================
Loader:Set(0.78, "Webhook")
task.wait()
local WebhookTab = Window:CreateTab({ Title = "Webhook", Icon = "link" })

-- =============================================
-- WEBHOOK MODULE (LOGIKA INTI - 100% SAMA)
-- =============================================
local WebhookModule = (function()
    local M = {}
    
    -- Cari HTTP request function yang tersedia
    local function getHTTPRequest()
        local funcs = { request, http_request,
            (syn and syn.request),
            (fluxus and fluxus.request),
            (http and http.request),
            (solara and solara.request),
        }
        for _, f in ipairs(funcs) do
            if f and type(f) == "function" then return f end
        end
        return nil
    end
    
    local httpRequest = getHTTPRequest()
    local HttpService = game:GetService("HttpService")
    
    -- Config (state lokal, di-sync dari UI)
    M.FishConfig = {
        WebhookURL = "",
        DiscordUserID = "",
        HideIdentity = "",
        EnabledRarities = {},
        Enabled = false
    }
    M.DisconnectConfig = {
        WebhookURL = "",
        DiscordUserID = "",
        HideIdentity = "",
        Enabled = false
    }
    M.LeaderboardConfig = {
        WebhookURL = "",
        DiscordUserID = "",
        HideIdentity = "",
        DelayMinutes = 5,
        Enabled = false
    }
    
    local RARITY_COLORS = {
        Common    = 9807270,
        Uncommon  = 3066993,
        Rare      = 3447003,
        Epic      = 10181046,
        Legendary = 15844367,
        Mythic    = 16711680,
        Secret    = 65535,
        Monster   = 16711935,
    }
    
    local isFishRunning = false
    local fishEventConn = nil
    local isDisconnectEnabled = false
    local disconnectSetup = false
    local isLeaderboardRunning = false
    local leaderboardThread = nil
    
    local function getDisplayName(config)
        if config.HideIdentity and config.HideIdentity ~= "" then
            return config.HideIdentity
        end
        local lp = game:GetService("Players").LocalPlayer
        return lp.DisplayName or lp.Name
    end
    
    local function getImageUrl(imageID)
        if not imageID then return "https://i.imgur.com/UMWNYK7.png" end
        local id = tostring(imageID):match("%d+")
        if not id then return "https://i.imgur.com/UMWNYK7.png" end
        local thumbnailUrl = string.format(
            "https://thumbnails.roblox.com/v1/assets?assetIds=%s&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false",
            id
        )
        if httpRequest then
            local success, result = pcall(function()
                local response = httpRequest({ Url = thumbnailUrl, Method = "GET" })
                if response and response.Body then
                    local data = HttpService:JSONDecode(response.Body)
                    if data and data.data and data.data[1] and data.data[1].imageUrl then
                        return data.data[1].imageUrl
                    end
                end
            end)
            if success and result then return result end
        end
        return "https://tr.rbxcdn.com/180DAY-" .. id .. "/420/420/Image/Png"
    end
    
    local function formatPrice(price)
        local formatted = tostring(math.floor(tonumber(price) or 0))
        return formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    end
    
    local function sendFishWebhook(data)
        if not M.FishConfig.WebhookURL or M.FishConfig.WebhookURL == "" then return end
        if not httpRequest then return end
        
        local fishData = data.FishData or {}
        local rarity = fishData.Rarity or "Common"
        local color = RARITY_COLORS[rarity] or RARITY_COLORS.Common
        
        -- Filter rarity
        local enabledRarities = M.FishConfig.EnabledRarities
        if enabledRarities and next(enabledRarities) then
            local hasFilter = false
            local passed = false
            for k, v in pairs(enabledRarities) do
                hasFilter = true
                local r = (type(k) == "string" and v == true) and k or v
                if r == rarity then passed = true break end
            end
            if hasFilter and not passed then return end
        end
        
        local playerName = getDisplayName(M.FishConfig)
        local mention = M.FishConfig.DiscordUserID ~= "" and "<@" .. M.FishConfig.DiscordUserID .. ">" or ""
        local imageUrl = getImageUrl(fishData.ImageID)
        local fishName = fishData.Name or data.FishID or "Unknown"
        local weightStr = data.WeightFormatted or (string.format("%.2f Kg", data.Weight or 0))
        local weightTier = data.WeightTier or "-"
        local price = formatPrice(data.Price or fishData.Price or 0)
        local basePrice = formatPrice(fishData.Price or 0)
        
        local payload = {
            username = "King Vypers",
            avatar_url = "https://raw.githubusercontent.com/semuao621-wq/Kamunanya/main/Kingvyperslogo.jpg",
            content = mention ~= "" and (mention .. " **" .. playerName .. "** caught a **" .. rarity .. "** fish!") or nil,
            embeds = {{
                author = { name = "King Vypers | Fish Caught" },
                color = color,
                fields = {
                    { name = "🐟 Fish Name",   value = "```" .. fishName .. "```",  inline = false },
                    { name = "⭐ Rarity",       value = "```" .. rarity .. "```",    inline = true  },
                    { name = "⚖️ Weight",       value = "```" .. weightStr .. "```", inline = true  },
                    { name = "🏆 Weight Tier",  value = "```" .. weightTier .. "```",inline = true  },
                    { name = "💰 Base Price",   value = "```$" .. basePrice .. "```",inline = true  },
                    { name = "💸 Sold For",     value = "```$" .. price .. "```",    inline = true  },
                    { name = "👤 Player",       value = "```" .. playerName .. "```",inline = true  },
                },
                image = { url = imageUrl },
                footer = {
                    text = "King Vypers • " .. os.date("%m/%d/%Y at %I:%M %p"),
                    icon_url = "https://raw.githubusercontent.com/semuao621-wq/Kamunanya/main/Kingvyperslogo.jpg"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        
        pcall(function()
            httpRequest({
                Url = M.FishConfig.WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end
    
    local function sendDisconnectWebhook(reason)
        if not isDisconnectEnabled then return end
        local url = M.DisconnectConfig.WebhookURL
        if not url or url == "" then return end
        if not httpRequest then return end
        
        local playerName = getDisplayName(M.DisconnectConfig)
        local mention = M.DisconnectConfig.DiscordUserID ~= ""
            and "<@" .. M.DisconnectConfig.DiscordUserID:gsub("%D", "") .. ">"
            or ""
        
        local payload = {
            content = mention ~= "" and (mention .. " Account disconnected!") or nil,
            username = "King Vypers",
            avatar_url = "https://raw.githubusercontent.com/semuao621-wq/Kamunanya/main/Kingvyperslogo.jpg",
            embeds = {{
                author = { name = "King Vypers | Disconnect Alert" },
                title = "⚠️ Connection Lost",
                description = "Roblox session disconnected. Attempting rejoin...",
                color = 16711680,
                fields = {
                    { name = "���� Account", value = "```" .. playerName .. "```", inline = true },
                    { name = "🕐 Time",    value = "```" .. os.date("%m/%d/%Y at %I:%M %p") .. "```", inline = true },
                    { name = "📋 Reason",  value = "```" .. (reason or "Disconnected") .. "```", inline = false },
                },
                footer = {
                    text = "King Vypers • Auto-rejoin enabled",
                    icon_url = "https://raw.githubusercontent.com/semuao621-wq/Kamunanya/main/Kingvyperslogo.jpg"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        
        task.spawn(function()
            pcall(function()
                httpRequest({
                    Url = url, Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HttpService:JSONEncode(payload)
                })
            end)
        end)
    end
    
    local function setupDisconnectDetection()
        if disconnectSetup then return end
        disconnectSetup = true
        
        local done = false
        local function handleDisconnect(reason)
            if not done and isDisconnectEnabled then
                done = true
                sendDisconnectWebhook(reason or "Disconnected from server")
                task.wait(2)
                game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
            end
        end
        
        game:GetService("GuiService").ErrorMessageChanged:Connect(function(msg)
            if msg and msg ~= "" then handleDisconnect(msg) end
        end)
    end
    
    local function sendLeaderboardWebhook(isTest)
        local url = M.LeaderboardConfig.WebhookURL
        if not url or url == "" then return end
        if not httpRequest then return end
        
        local player = game.Players.LocalPlayer
        local playerName = M.LeaderboardConfig.HideIdentity ~= "" and M.LeaderboardConfig.HideIdentity or (player.DisplayName or player.Name)
        local mention = M.LeaderboardConfig.DiscordUserID ~= "" and "<@" .. M.LeaderboardConfig.DiscordUserID:gsub("%D", "") .. ">" or ""
        local headshotUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
        
        -- Extract stats
        local statsDict = {}
        if player:FindFirstChild("leaderstats") then
            for _, stat in pairs(player.leaderstats:GetChildren()) do
                statsDict[stat.Name] = tostring(stat.Value)
            end
        end
        if player:FindFirstChild("PlayerData") then
            for _, stat in pairs(player.PlayerData:GetChildren()) do
                if stat:IsA("ValueBase") then
                    statsDict[stat.Name] = tostring(stat.Value)
                end
            end
        end
        local levelLabel = player.PlayerGui:FindFirstChild("HUD")
        if levelLabel then
            local ok, lvl = pcall(function()
                return player.PlayerGui.HUD.PlayerStatsPanel.LevelExpRow.LevelLabel.Text
            end)
            if ok then statsDict["Level"] = lvl end
        end
        
        local orderedStats = {
            { key = "Level", name = "Level", emoji = "🌟" },
            { key = "Fish", name = "Fish", emoji = "🐟" },
            { key = "Playtime", name = "Playtime", emoji = "⏳" },
            { key = "Money", name = "Money", emoji = "💰" },
            { key = "Shards", name = "Shards", emoji = "💎" },
        }
        
        local fields = {}
        local processed = {}
        
        table.insert(fields, {
            name = "👤 Player Name",
            value = "```" .. playerName .. "```",
            inline = true
        })
        
        for _, entry in ipairs(orderedStats) do
            local foundKey = nil
            for k, _ in pairs(statsDict) do
                if k:lower() == entry.key:lower() then
                    foundKey = k
                    break
                end
            end
            if foundKey then
                local val = statsDict[foundKey]
                local displayVal = val
                if entry.key == "Money" then
                    local cleanNum = val:gsub("[^%d%.]", "")
                    local num = tonumber(cleanNum)
                    if num then
                        displayVal = "$" .. formatPrice(num)
                    else
                        displayVal = "$" .. val
                    end
                end
                table.insert(fields, {
                    name = entry.emoji .. " " .. entry.name,
                    value = "```" .. displayVal .. "```",
                    inline = true
                })
                processed[foundKey] = true
            end
        end
        
        for k, v in pairs(statsDict) do
            if not processed[k] then
                table.insert(fields, {
                    name = "📊 " .. k,
                    value = "```" .. v .. "```",
                    inline = true
                })
            end
        end
        
        local softGreen = 7855479
        
        local payload = {
            username = "King Vypers",
            avatar_url = "https://raw.githubusercontent.com/semuao621-wq/Kamunanya/main/Kingvyperslogo.jpg",
            content = isTest and "🧪 **Leaderboard Webhook Test**" or (mention ~= "" and mention or nil),
            embeds = {{
                author = { 
                    name = "King Vypers | Leaderboard Updates",
                    icon_url = "https://raw.githubusercontent.com/semuao621-wq/Kamunanya/main/Kingvyperslogo.jpg"
                },
                title = isTest and "✅ Webhook Test Success!" or "📈 Current Leaderboard & Progress",
                description = isTest and "Test leaderboard webhook configuration succeeded." or nil,
                color = softGreen,
                thumbnail = { url = headshotUrl },
                fields = fields,
                footer = {
                    text = "King Vypers • " .. os.date("%m/%d/%Y at %I:%M %p"),
                    icon_url = "https://raw.githubusercontent.com/semuao621-wq/Kamunanya/main/Kingvyperslogo.jpg"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        
        pcall(function()
            httpRequest({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end
    
    -- Public API
    function M:StartFishWebhook()
        if isFishRunning then return end
        if not httpRequest then print("[Webhook] HTTP ga tersedia!") return false end
        if not self.FishConfig.WebhookURL or self.FishConfig.WebhookURL == "" then
            print("[Webhook] URL belum diisi!") return false
        end
        
        local RS = game:GetService("ReplicatedStorage")
        local ok, FishCaught = pcall(function()
            return RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.FishingRewardService.RE.FishCaught
        end)
        if not ok or not FishCaught then print("[Webhook] FishCaught event ga ketemu!") return false end
        
        fishEventConn = FishCaught.OnClientEvent:Connect(function(data)
            task.spawn(sendFishWebhook, data)
        end)
        isFishRunning = true
        self.FishConfig.Enabled = true
        print("[Webhook] Fish Webhook ON!")
        return true
    end
    
    function M:StopFishWebhook()
        if not isFishRunning then return end
        if fishEventConn then fishEventConn:Disconnect() fishEventConn = nil end
        isFishRunning = false
        self.FishConfig.Enabled = false
        print("[Webhook] Fish Webhook OFF!")
    end
    
    function M:EnableDisconnectWebhook(enabled)
        self.DisconnectConfig.Enabled = enabled
        isDisconnectEnabled = enabled
        if enabled then setupDisconnectDetection() end
    end
    
    function M:StartLeaderboardWebhook()
        if isLeaderboardRunning then return end
        if not httpRequest then print("[Webhook] HTTP ga tersedia!") return false end
        if not self.LeaderboardConfig.WebhookURL or self.LeaderboardConfig.WebhookURL == "" then
            print("[Webhook] URL belum diisi!") return false
        end
        
        isLeaderboardRunning = true
        self.LeaderboardConfig.Enabled = true
        print("[Webhook] Leaderboard Webhook ON!")
        
        leaderboardThread = task.spawn(function()
            while isLeaderboardRunning do
                sendLeaderboardWebhook(false)
                local delayTime = (tonumber(self.LeaderboardConfig.DelayMinutes) or 5) * 60
                task.wait(delayTime)
            end
        end)
        return true
    end
    
    function M:StopLeaderboardWebhook()
        if not isLeaderboardRunning then return end
        isLeaderboardRunning = false
        self.LeaderboardConfig.Enabled = false
        if leaderboardThread then
            pcall(task.cancel, leaderboardThread)
            leaderboardThread = nil
        end
        print("[Webhook] Leaderboard Webhook OFF!")
    end
    
    function M:IsLeaderboardRunning() return isLeaderboardRunning end
    
    function M:TestFishWebhook()
        if not httpRequest then return false end
        if not self.FishConfig.WebhookURL or self.FishConfig.WebhookURL == "" then return false end
        local ok = pcall(function()
            httpRequest({
                Url = self.FishConfig.WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({
                    username = "King Vypers",
                    avatar_url = "https://raw.githubusercontent.com/semuao621-wq/Kamunanya/main/Kingvyperslogo.jpg",
                    embeds = {{
                        title = "✅ Webhook Test Berhasil!",
                        description = "Fish Webhook sudah terhubung dan siap menerima notifikasi!",
                        color = 3066993,
                        footer = {
                            text = "King Vypers • Test",
                            icon_url = "https://raw.githubusercontent.com/semuao621-wq/Kamunanya/main/Kingvyperslogo.jpg"
                        },
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                    }}
                })
            })
        end)
        return ok
    end
    
    function M:TestDisconnectWebhook()
        sendDisconnectWebhook("Test - Simulasi Disconnect")
    end
    
    function M:TestLeaderboardWebhook()
        if not httpRequest then return false end
        if not self.LeaderboardConfig.WebhookURL or self.LeaderboardConfig.WebhookURL == "" then return false end
        sendLeaderboardWebhook(true)
        return true
    end
    
    return M
end)()

-- =============================================
-- FISH CAUGHT WEBHOOK SECTION
-- =============================================
local FishWebhookSection = WebhookTab:CreateSection({ Title = "Fish Caught Webhook", Box = true, Opened = true })

FishWebhookSection:CreateInput({
    Id = "fish_webhook_url",
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    Callback = function(v)
        local val = v:gsub("^%s*(.-)%s*$", "%1")
        WebhookModule.FishConfig.WebhookURL = val
    end
})

FishWebhookSection:CreateInput({
    Id = "fish_discord_user_id",
    Title = "Discord User ID",
    Placeholder = "123456789012345678",
    Default = "",
    Callback = function(v)
        local val = v:gsub("^%s*(.-)%s*$", "%1")
        WebhookModule.FishConfig.DiscordUserID = val
    end
})

FishWebhookSection:CreateInput({
    Id = "fish_custom_name",
    Title = "Custom Name",
    Placeholder = "Masukkan nama custom...",
    Default = "",
    Callback = function(v)
        local val = v:gsub("^%s*(.-)%s*$", "%1")
        WebhookModule.FishConfig.HideIdentity = val
    end
})

FishWebhookSection:CreateMultiDropdown({
    Id = "fish_rarity_filter",
    Title = "Filter Rarity",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Monster" },
    Default = {},
    Callback = function(selected)
        local rarityMap = {}
        if type(selected) == "table" then
            for _, v in ipairs(selected) do
                rarityMap[v] = true
            end
        end
        WebhookModule.FishConfig.EnabledRarities = rarityMap
    end
})

local fishToggleRef = FishWebhookSection:CreateToggle({
    Id = "fish_webhook_toggle",
    Title = "Enable Fish Webhook",
    Icon = "zap",
    Default = false,
    Callback = function(state)
        if state then
            if WebhookModule.FishConfig.WebhookURL == "" then
                Window:Notify({ Title = "Webhook", Content = "URL belum diisi!", Type = "error", Duration = 3 })
                fishToggleRef.Set(false)
                return
            end
            local ok = WebhookModule:StartFishWebhook()
            if ok then
                Window:Notify({ Title = "Fish Webhook", Content = "Fish webhook aktif!", Type = "success", Duration = 3 })
            else
                fishToggleRef.Set(false)
            end
        else
            WebhookModule:StopFishWebhook()
            Window:Notify({ Title = "Fish Webhook", Content = "Fish webhook dimatikan.", Type = "info", Duration = 3 })
        end
    end
})

FishWebhookSection:CreateButton({
    Id = "fish_webhook_test",
    Title = "Test Fish Webhook",
    Icon = "send",
    Callback = function()
        if WebhookModule.FishConfig.WebhookURL == "" then
            Window:Notify({ Title = "Webhook", Content = "URL belum diisi!", Type = "error", Duration = 3 })
            return
        end
        local ok = WebhookModule:TestFishWebhook()
        Window:Notify({ 
            Title = "Fish Webhook Test", 
            Content = ok and "Test berhasil dikirim!" or "Gagal mengirim test.", 
            Type = ok and "success" or "error", 
            Duration = 3 
        })
    end
})

-- =============================================
-- DISCONNECT WEBHOOK SECTION
-- =============================================
local DisconnectSection = WebhookTab:CreateSection({ Title = "Disconnect Webhook", Box = true, Opened = false })

DisconnectSection:CreateInput({
    Id = "disconnect_webhook_url",
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    Callback = function(v)
        local val = v:gsub("^%s*(.-)%s*$", "%1")
        WebhookModule.DisconnectConfig.WebhookURL = val
    end
})

DisconnectSection:CreateInput({
    Id = "disconnect_discord_user_id",
    Title = "Discord User ID",
    Placeholder = "123456789012345678",
    Default = "",
    Callback = function(v)
        local val = v:gsub("^%s*(.-)%s*$", "%1")
        WebhookModule.DisconnectConfig.DiscordUserID = val
    end
})

DisconnectSection:CreateInput({
    Id = "disconnect_custom_name",
    Title = "Custom Name",
    Placeholder = "Masukkan nama custom...",
    Default = "",
    Callback = function(v)
        local val = v:gsub("^%s*(.-)%s*$", "%1")
        WebhookModule.DisconnectConfig.HideIdentity = val
    end
})

DisconnectSection:CreateToggle({
    Id = "disconnect_webhook_toggle",
    Title = "Enable Disconnect Webhook",
    Icon = "wifi-off",
    Default = false,
    Callback = function(state)
        if state then
            if WebhookModule.DisconnectConfig.WebhookURL == "" then
                Window:Notify({ Title = "Webhook", Content = "URL belum diisi!", Type = "error", Duration = 3 })
                return
            end
            WebhookModule:EnableDisconnectWebhook(true)
            Window:Notify({ Title = "Disconnect Webhook", Content = "Disconnect webhook aktif!", Type = "success", Duration = 3 })
        else
            WebhookModule:EnableDisconnectWebhook(false)
            Window:Notify({ Title = "Disconnect Webhook", Content = "Disconnect webhook dimatikan.", Type = "info", Duration = 3 })
        end
    end
})

DisconnectSection:CreateButton({
    Id = "disconnect_webhook_test",
    Title = "Test Disconnect Webhook",
    Icon = "send",
    Callback = function()
        if WebhookModule.DisconnectConfig.WebhookURL == "" then
            Window:Notify({ Title = "Webhook", Content = "URL belum diisi!", Type = "error", Duration = 3 })
            return
        end
        WebhookModule:TestDisconnectWebhook()
        Window:Notify({ Title = "Disconnect Webhook Test", Content = "Test dikirim!", Type = "success", Duration = 3 })
    end
})

-- =============================================
-- LEADERBOARD WEBHOOK SECTION
-- =============================================
local LeaderboardSection = WebhookTab:CreateSection({ Title = "Leaderboard Webhook", Box = true, Opened = false })

LeaderboardSection:CreateInput({
    Id = "leaderboard_webhook_url",
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    Callback = function(v)
        local val = v:gsub("^%s*(.-)%s*$", "%1")
        WebhookModule.LeaderboardConfig.WebhookURL = val
    end
})

LeaderboardSection:CreateInput({
    Id = "leaderboard_discord_user_id",
    Title = "Discord User ID",
    Placeholder = "123456789012345678",
    Default = "",
    Callback = function(v)
        local val = v:gsub("^%s*(.-)%s*$", "%1")
        WebhookModule.LeaderboardConfig.DiscordUserID = val
    end
})

LeaderboardSection:CreateInput({
    Id = "leaderboard_custom_name",
    Title = "Custom Name",
    Placeholder = "Masukkan nama custom...",
    Default = "",
    Callback = function(v)
        local val = v:gsub("^%s*(.-)%s*$", "%1")
        WebhookModule.LeaderboardConfig.HideIdentity = val
    end
})

LeaderboardSection:CreateInput({
    Id = "leaderboard_delay_minutes",
    Title = "Delay (Minutes)",
    Placeholder = "5",
    Default = "5",
    Callback = function(v)
        local val = tonumber(v:gsub("^%s*(.-)%s*$", "%1"))
        if val and val > 0 then
            WebhookModule.LeaderboardConfig.DelayMinutes = val
            -- Restart kalau lagi jalan biar delay baru kepake
            if WebhookModule:IsLeaderboardRunning() then
                WebhookModule:StopLeaderboardWebhook()
                WebhookModule:StartLeaderboardWebhook()
            end
        end
    end
})

local leaderboardToggleRef = LeaderboardSection:CreateToggle({
    Id = "leaderboard_webhook_toggle",
    Title = "Enable Leaderboard Webhook",
    Icon = "award",
    Default = false,
    Callback = function(state)
        if state then
            if WebhookModule.LeaderboardConfig.WebhookURL == "" then
                Window:Notify({ Title = "Webhook", Content = "URL belum diisi!", Type = "error", Duration = 3 })
                leaderboardToggleRef.Set(false)
                return
            end
            local ok = WebhookModule:StartLeaderboardWebhook()
            if ok then
                Window:Notify({ Title = "Leaderboard Webhook", Content = "Leaderboard webhook aktif!", Type = "success", Duration = 3 })
            else
                leaderboardToggleRef.Set(false)
            end
        else
            WebhookModule:StopLeaderboardWebhook()
            Window:Notify({ Title = "Leaderboard Webhook", Content = "Leaderboard webhook dimatikan.", Type = "info", Duration = 3 })
        end
    end
})

LeaderboardSection:CreateButton({
    Id = "leaderboard_webhook_test",
    Title = "Test Leaderboard Webhook",
    Icon = "send",
    Callback = function()
        if WebhookModule.LeaderboardConfig.WebhookURL == "" then
            Window:Notify({ Title = "Webhook", Content = "URL belum diisi!", Type = "error", Duration = 3 })
            return
        end
        local ok = WebhookModule:TestLeaderboardWebhook()
        Window:Notify({ 
            Title = "Leaderboard Webhook Test", 
            Content = ok and "Test berhasil dikirim!" or "Gagal mengirim test.", 
            Type = ok and "success" or "error", 
            Duration = 3 
        })
    end
})


-- ================================================================
--  Settings Tab
-- ================================================================
Loader:Set(0.9, "Settings")
task.wait()
local SettingsTab = Window:CreateTab({ Title = "Settings", Icon = "" })

-- =============================================
-- PROTECTION SECTION
-- =============================================
local ProtectionSection = SettingsTab:CreateSection({ Title = "Protection", Box = true, Opened = true })

-- =============================================
-- ANTI-AFK MODULE
-- =============================================
local AntiAFK = (function()
    local AA = {
        Enabled = false,
        Thread = nil,
        Conn = nil,
    }
    
    function AA.Start()
        if AA.Enabled then return end
        AA.Enabled = true
        local VirtualUser = game:GetService("VirtualUser")
        
        -- Bypass Anti-AFK Roblox native yang paling ampuh
        AA.Conn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
            if AA.Enabled then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                print("[Anti-AFK] Roblox Idle bypassed!")
            end
        end)
        
        AA.Thread = task.spawn(function()
            while AA.Enabled do
                task.wait(600)
                if not AA.Enabled then break end
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
    end
    
    function AA.Stop()
        if not AA.Enabled then return end
        AA.Enabled = false
        if AA.Thread then
            task.cancel(AA.Thread)
            AA.Thread = nil
        end
        if AA.Conn then
            AA.Conn:Disconnect()
            AA.Conn = nil
        end
    end
    
    return AA
end)()

ProtectionSection:CreateToggle({
    Id = "anti_afk_toggle",
    Title = "Anti-AFK",
    Icon = "shield-check",
    Default = false,
    Callback = function(state)
        if state then
            AntiAFK.Start()
            Window:Notify({ Title = "Anti-AFK", Content = "Anti-AFK aktif!", Type = "success", Duration = 3 })
        else
            AntiAFK.Stop()
            Window:Notify({ Title = "Anti-AFK", Content = "Anti-AFK dimatikan.", Type = "info", Duration = 3 })
        end
    end
})

-- =============================================
-- ANTI-ADMIN MODULE
-- =============================================
local AntiAdmin = (function()
    local AA = {
        Enabled = false,
        Conns = {},
        Kicked = false,
        PlayerConns = {}
    }
    
    local STAFF_KEYWORDS = {
        "admin", "mod", "moderator", "staff", "owner", "developer",
        "dev", "manager", "supervisor", "helper"
    }
    
    local function isAdminByAttribute(player)
        return player:GetAttribute("IsAdmin") == true
            or player:GetAttribute("IsPrimaryAdmin") == true
            or (player:GetAttribute("AdminAccess") ~= nil and player:GetAttribute("AdminAccess") ~= "")
    end
    
    local function checkAdminByGroupRole(player, onDetected)
        task.spawn(function()
            if not player or not player.Parent then return end
            local ok, role = pcall(function()
                return player:GetRoleInGroup(game.CreatorId)
            end)
            if not ok or not role then return end
            local roleLower = role:lower()
            
            for _, keyword in ipairs(STAFF_KEYWORDS) do
                if roleLower:find(keyword) then
                    onDetected(player, "GroupRole: " .. role)
                    return
                end
            end
        end)
    end
    
    local function isAdmin(player)
        return isAdminByAttribute(player)
    end
    
    local function safeKick(reason)
        warn("🚨 " .. reason)
        warn("🚪 Auto-kick untuk keamanan!")
        local LP = game:GetService("Players").LocalPlayer
        LP:Kick("🚨 SAFETY KICK\n" .. reason .. "\nScript otomatis keluar untuk keamanan.")
    end
    
    local function checkAdmin(player, context)
        if AA.Kicked then return end
        local LP = game:GetService("Players").LocalPlayer
        if player == LP then return end
        
        if isAdmin(player) then
            AA.Kicked = true
            safeKick("ADMIN/STAFF TERDETEKSI!\nNama: " .. player.Name .. "\nKonteks: " .. context)
            return
        end
        
        if game.CreatorType == Enum.CreatorType.Group then
            checkAdminByGroupRole(player, function(p, ctx)
                if AA.Kicked then return end
                AA.Kicked = true
                safeKick("STAFF/ADMIN TERDETEKSI (GROUP)!\nNama: " .. p.Name .. "\nKonteks: " .. ctx)
            end)
        end
    end
    
    local function cleanupPlayerConns(player)
        if AA.PlayerConns[player] then
            for _, conn in ipairs(AA.PlayerConns[player]) do
                if conn then conn:Disconnect() end
            end
            AA.PlayerConns[player] = nil
        end
    end
    
    local function setupPlayerListeners(player)
        cleanupPlayerConns(player)
        AA.PlayerConns[player] = {}
        table.insert(AA.PlayerConns[player], player:GetAttributeChangedSignal("IsAdmin"):Connect(function()
            if AA.Enabled then checkAdmin(player, "IsAdmin berubah jadi true") end
        end))
        table.insert(AA.PlayerConns[player], player:GetAttributeChangedSignal("IsPrimaryAdmin"):Connect(function()
            if AA.Enabled then checkAdmin(player, "IsPrimaryAdmin berubah jadi true") end
        end))
        table.insert(AA.PlayerConns[player], player:GetAttributeChangedSignal("AdminAccess"):Connect(function()
            if AA.Enabled then checkAdmin(player, "AdminAccess berubah") end
        end))
    end
    
    function AA.Start()
        if AA.Enabled then return end
        AA.Enabled = true
        AA.Kicked = false
        local Players = game:GetService("Players")
        local LP = Players.LocalPlayer
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LP then
                print("✅ " .. player.Name .. " = kamu sendiri")
            elseif isAdmin(player) then
                checkAdmin(player, "Already in server")
            else
                print("✅ " .. player.Name .. " = player biasa")
            end
        end
        
        table.insert(AA.Conns, Players.PlayerAdded:Connect(function(player)
            if not AA.Enabled then return end
            task.wait(1)
            checkAdmin(player, "Baru join server")
            setupPlayerListeners(player)
        end))
        
        table.insert(AA.Conns, Players.PlayerRemoving:Connect(function(player)
            cleanupPlayerConns(player)
        end))
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LP then continue end
            setupPlayerListeners(player)
        end
        
        print("🛡️ Anti-Admin aktif! Auto-kick kalau ada admin masuk.")
    end
    
    function AA.Stop()
        if not AA.Enabled then return end
        AA.Enabled = false
        for _, conn in ipairs(AA.Conns) do
            if conn then conn:Disconnect() end
        end
        AA.Conns = {}
        for player, _ in pairs(AA.PlayerConns) do
            cleanupPlayerConns(player)
        end
        AA.PlayerConns = {}
        AA.Kicked = false
        print("🛡️ Anti-Admin mati!")
    end
    
    return AA
end)()

ProtectionSection:CreateToggle({
    Id = "anti_admin_toggle",
    Title = "Anti Staff/Admin",
    Icon = "shield",
    Default = false,
    Callback = function(state)
        if state then
            AntiAdmin.Start()
            Window:Notify({ Title = "Anti-Admin", Content = "Auto-kick kalau ada staff masuk!", Type = "success", Duration = 3 })
        else
            AntiAdmin.Stop()
            Window:Notify({ Title = "Anti-Admin", Content = "Anti-admin dimatikan.", Type = "info", Duration = 3 })
        end
    end
})

-- =============================================
-- PERFORMANCE SECTION
-- =============================================
local PerformanceSection = SettingsTab:CreateSection({ Title = "Performance", Box = true, Opened = false })

PerformanceSection:CreateToggle({
    Id = "boost_fps_toggle",
    Title = "Boost FPS",
    Icon = "zap",
    Default = false,
    Callback = function(state)
        if state then
            local Lighting = game:GetService("Lighting")
            local Terrain = workspace.Terrain

            --// Lighting
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1
            Lighting.ClockTime = 14

            pcall(function()
                Lighting.EnvironmentDiffuseScale = 0
                Lighting.EnvironmentSpecularScale = 0
            end)

            --// Water
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0

            --// Workspace (One Scan Only)
            for _, v in ipairs(workspace:GetDescendants()) do

                -- BasePart
                if v:IsA("BasePart") then
                    pcall(function()
                        v.Material = Enum.Material.SmoothPlastic
                        v.MaterialVariant = ""
                        v.Reflectance = 0
                        v.CastShadow = false
                    end)
                end

                -- Texture / Decal
                if v:IsA("Texture") or v:IsA("Decal") then
                    v.Transparency = 1
                end

                -- Surface Appearance
                if v:IsA("SurfaceAppearance") then
                    v:Destroy()
                end

                -- Wrap
                if v:IsA("WrapLayer") or v:IsA("WrapTarget") then
                    v:Destroy()
                end

                -- SpecialMesh Texture
                if v:IsA("SpecialMesh") then
                    pcall(function()
                        v.TextureId = ""
                    end)
                end

                -- MeshPart Texture
                if v:IsA("MeshPart") then
                    pcall(function()
                        v.TextureID = ""
                    end)
                end

                -- Disable Effects
                if v:IsA("ParticleEmitter")
                or v:IsA("Trail")
                or v:IsA("Beam")
                or v:IsA("Smoke")
                or v:IsA("Fire")
                or v:IsA("Sparkles") then
                    v.Enabled = false
                end

                -- Highlight
                if v:IsA("Highlight") then
                    v:Destroy()
                end

                -- BillboardGui
                if v:IsA("BillboardGui") then
                    v.Enabled = false
                end

                -- Selection
                if v:IsA("SelectionBox") then
                    v.Visible = false
                end

                if v:IsA("SelectionSphere") then
                    v.SurfaceTransparency = 1
                end

                if v:IsA("HandleAdornment") then
                    v.Visible = false
                end

                -- Lights
                if v:IsA("PointLight")
                or v:IsA("SpotLight")
                or v:IsA("SurfaceLight") then
                    v.Enabled = false
                end

                -- ForceField
                if v:IsA("ForceField") then
                    v.Visible = false
                end
            end

            --// Lighting Effects
            for _, v in ipairs(Lighting:GetChildren()) do

                if v:IsA("Atmosphere")
                or v:IsA("Sky")
                or v:IsA("Clouds") then
                    v:Destroy()
                end

                if v:IsA("BloomEffect")
                or v:IsA("BlurEffect")
                or v:IsA("ColorCorrectionEffect")
                or v:IsA("DepthOfFieldEffect")
                or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                end
            end

            --// Lowest Graphics (Executor Dependent)
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            
            Window:Notify({ Title = "Performance", Content = "FPS Boost aktif!", Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Performance", Content = "FPS Boost butuh rejoin untuk di-reset.", Type = "warning", Duration = 3 })
        end
    end
})

-- =============================================
-- CONFIG SECTION
-- =============================================
local ConfigSection = SettingsTab:CreateSection({ Title = "Config", Box = true, Opened = false })

local function cfgNotify(content, kind, dur)
	Window:Notify({ Title = "Config", Content = content, Type = kind or "info", Duration = dur or 3 })
end

-- baca clipboard (support macam-macam executor)
local function getClipboard()
	local fn = (getclipboard or getclipboardtext or readclipboard
		or (syn and syn.get_clipboard) or (getgenv and getgenv().getclipboard))
	if not fn then return nil end
	local ok, res = pcall(fn)
	if ok then return res end
	return nil
end

-- 1) Copy config kamu ke clipboard (buat dibagi ke orang lain)
ConfigSection:CreateButton({
	Id = "copy_config_btn",
	Title = "Copy Your Config",
	Icon = "copy",
	Callback = function()
		if not setclipboard then
			return cfgNotify("Executor tidak support setclipboard!", "error")
		end
		local ok, jsonStr = pcall(function() return Vypers:GetConfigJSON() end)
		if ok and jsonStr and jsonStr ~= "" then
			setclipboard(jsonStr)
			cfgNotify("Config berhasil dicopy ke clipboard!", "success")
		else
			cfgNotify("Gagal meng-copy config!", "error")
		end
	end,
})

-- 2) Input paste (paling atas dari grup load)
local sharedConfigInput = ""
local loadConfigInput = ConfigSection:CreateInput({
	Id = "load_config_input",
	Title = "Load Config",
	Placeholder = "Paste config JSON disini...",
	Default = "",
	Callback = function(v)
		sharedConfigInput = (v or ""):gsub("^%s*(.-)%s*$", "%1")
	end,
})

-- 3) Dua button bersebelahan: Load Config | Paste Config
ConfigSection:CreateButtonRow({
	Buttons = {
		{
			Title = "Load Config",
			Callback = function()
				if sharedConfigInput == "" then
					return cfgNotify("Input config kosong!", "warning")
				end
				local ok, result = pcall(function()
					return Vypers:LoadConfigFromJSON(sharedConfigInput)
				end)
				if ok and result then
					cfgNotify("Config berhasil di-load!", "success", 5)
				else
					cfgNotify("Gagal meload config! Pastikan format JSON valid.", "error")
				end
			end,
		},
		{
			Title = "Paste Config",
			Callback = function()
				local text = getClipboard()
				if not text or text == "" then
					return cfgNotify("Clipboard kosong / executor tidak support,paste manual!", "error")
				end
				text = text:gsub("^%s*(.-)%s*$", "%1")
				sharedConfigInput = text
				loadConfigInput.Set(text)   -- otomatis masuk ke input
				cfgNotify("Config di-paste! Sekarang tekan Load Config.", "success")
			end,
		},
	},
})

-- 4) Reset ke default
-- 4) Restore & Delete bersebelahan
ConfigSection:CreateButtonRow({
	Buttons = {
		{
			Title = "Restore Config Default",
			Callback = function()
				local ok = pcall(function() Vypers:ResetConfig() end)
				if ok then
					cfgNotify("Config dikembalikan ke default!", "success", 5)
				else
					cfgNotify("Gagal restore config!", "error")
				end
			end,
		},
		{
			Title = "Delete Config",
			Color = Color3.fromRGB(200, 60, 60),  -- merah, tanda aksi hapus
			Callback = function()
				local ok = pcall(function() Vypers:DeleteConfig() end)
				-- bersihin juga input & config yang lagi kepaste
				sharedConfigInput = ""
				pcall(function() loadConfigInput.Set("") end)
				if ok then
					cfgNotify("Config tersimpan dihapus & input dibersihkan!", "success", 5)
				else
					cfgNotify("Gagal menghapus config!", "error")
				end
			end,
		},
	},
})

-- =============================================
-- CUSTOM SETTINGS SECTION
-- =============================================
Loader:Set(0.95, "Custom Settings")
task.wait()
local CustomSection = SettingsTab:CreateSection({ Title = "Custom Settings", Box = true, Opened = false })

-- =============================================
-- AUTO REJOIN & AUTO EXECUTE MODULE
-- =============================================
local AutoRejoin = (function()
    local AR = {}
    AR.Enabled = false
    AR.AutoExecEnabled = false
    AR.AutoToPosEnabled = false
    AR.SavedCFrame = nil      -- Menyimpan CFrame (Posisi + Rotasi)
    AR.SavedPlaceId = nil     -- Menyimpan ID Map tempat posisi di-save

    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local disconnectSetup = false
    local hasTriggered = false

    -- =====================================================
    -- PERSISTENSI SPOT (biar ga ilang pas keluar / execute ulang)
    -- Disimpan ke file executor: VypersHub/saved_spot.json
    -- =====================================================
    local HttpService = game:GetService("HttpService")
    local SAVE_FOLDER = "VypersHub"
    local SAVE_FILE   = SAVE_FOLDER .. "/saved_spot.json"

    AR.FileSupported = (typeof(writefile) == "function") and (typeof(readfile) == "function")

    local function fileExists(p)
        if typeof(isfile) == "function" then
            local ok, res = pcall(isfile, p)
            return ok and res == true
        end
        return (pcall(readfile, p))
    end

    local function ensureFolder()
        if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
            pcall(function()
                if not isfolder(SAVE_FOLDER) then makefolder(SAVE_FOLDER) end
            end)
        end
    end

    function AR.SaveToFile()
        if not AR.FileSupported then return false end
        ensureFolder()
        local data = { autoReturn = AR.AutoToPosEnabled and true or false }
        if AR.SavedCFrame and AR.SavedPlaceId then
            data.placeId = AR.SavedPlaceId
            data.cf = { AR.SavedCFrame:components() }
        end
        return (pcall(function() writefile(SAVE_FILE, HttpService:JSONEncode(data)) end))
    end

    function AR.LoadFromFile()
        if not AR.FileSupported then return false end
        if not fileExists(SAVE_FILE) then return false end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(SAVE_FILE)) end)
        if not ok or type(data) ~= "table" then return false end
        if type(data.cf) == "table" and #data.cf >= 12 and tonumber(data.placeId) then
            local c = data.cf
            AR.SavedCFrame  = CFrame.new(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12])
            AR.SavedPlaceId = tonumber(data.placeId)
        end
        AR.AutoToPosEnabled = data.autoReturn and true or false
        print("[Auto Rejoin] Spot tersimpan dimuat dari file. AutoReturn:", AR.AutoToPosEnabled)
        return true
    end

    -- Tween ke spot tersimpan. return ok, alasan/durasi
    function AR.TweenToSaved(duration)
        if not (AR.SavedCFrame and AR.SavedPlaceId) then return false, "no_save" end
        if game.PlaceId ~= AR.SavedPlaceId then return false, "wrong_map" end
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart", 10)
        if not hrp then return false, "no_char" end
        local TweenService = game:GetService("TweenService")
        local dist = (hrp.Position - AR.SavedCFrame.Position).Magnitude
        local t = duration or math.clamp(dist / 250, 1.5, 10)
        local tween = TweenService:Create(hrp,
            TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { CFrame = AR.SavedCFrame })
        tween:Play()
        return true, t
    end

    local SCRIPT_URL = "https://raw.githubusercontent.com/wsdpwtkj8g-cpu/sokasiklunyet/refs/heads/main/monyet.lua" 
    local EXEC_DELAY = 15 

    local function getQueueOnTeleport()
        local getQueue = nil
        pcall(function() getQueue = queue_on_teleport end)
        if getQueue then return getQueue end
        pcall(function() getQueue = queueonteleport end)
        if getQueue then return getQueue end
        pcall(function() getQueue = syn and syn.queue_on_teleport end)
        if getQueue then return getQueue end
        pcall(function() getQueue = fluxus and fluxus.queue_on_teleport end)
        if getQueue then return getQueue end
        pcall(function() getQueue = solara and solara.queue_on_teleport end)
        if getQueue then return getQueue end
        return nil
    end

    local autoExecQueued = false
    local function setupAutoExecuteQueue()
        if autoExecQueued then return true end
        local queueTeleport = getQueueOnTeleport()
        if not queueTeleport then 
            warn("[Auto Rejoin] Executor lu tidak mendukung queue_on_teleport!")
            return false 
        end
        if not AR.AutoExecEnabled then return false end

        -- Siapkan data posisi jika Auto To Position aktif DAN ada data yang tersimpan
        local positionTweenCode = ""
        if AR.AutoToPosEnabled and AR.SavedCFrame and AR.SavedPlaceId then
            -- Ambil 12 komponen CFrame (X, Y, Z + 9 matriks rotasi)
            local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = AR.SavedCFrame:components()
            local savedPlaceId = AR.SavedPlaceId
            
            -- Suntikkan pengecekan PlaceId di dalam kode yang akan di-execute nanti
            positionTweenCode = string.format([[
                task.wait(%d) -- Tunggu sedikit lebih lama dari EXEC_DELAY agar karakter & UI selesai load
                pcall(function()
                    if game.PlaceId == %d then
                        local player = game:GetService("Players").LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local hrp = character:WaitForChild("HumanoidRootPart", 5)
                        if hrp then
                            local targetCFrame = CFrame.new(%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f)
                            local TweenService = game:GetService("TweenService")
                            local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
                            tween:Play()
                            print("[Auto Exec] Kembali ke spot mancing yang disimpan di map ini!")
                        end
                    else
                        print("[Auto Exec] Posisi tersimpan untuk map lain (ID: %d). Skip tween agar tidak nyangkut.")
                    end
                end)
            ]], EXEC_DELAY + 2, savedPlaceId, x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22, savedPlaceId)
        end

        -- Gabungkan kode eksekusi utama dengan kode tween posisi
        local autoExecCode = string.format([[
            task.wait(%d)
            pcall(function()
                print("[Auto Exec] Menjalankan script setelah rejoin...")
                loadstring(game:HttpGet("%s"))()
            end)
            %s
        ]], EXEC_DELAY, SCRIPT_URL, positionTweenCode)

        local ok = pcall(function() queueTeleport(autoExecCode) end)
        if ok then 
            autoExecQueued = true 
            print("[Auto Rejoin] Queue on teleport berhasil diatur!")
        end
        return ok
    end

    local function doRejoin()
        if hasTriggered then return end
        if not AR.Enabled then return end
        hasTriggered = true

        print("[Auto Rejoin] Terdeteksi kick/disconnect! Melakukan rejoin...")
        
        if AR.AutoExecEnabled then
            setupAutoExecuteQueue()
        end

        task.spawn(function()
            local attempt = 0
            while attempt < 5 do 
                attempt += 1
                local success, err = pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
                
                if success then
                    print("[Auto Rejoin] Perintah teleport dikirim!")
                    break
                else
                    print("[Auto Rejoin] Gagal teleport, mencoba lagi dalam 3 detik... ("..attempt.."/5)")
                    task.wait(3)
                end
            end
        end)
    end

    local function setupDetection()
        if disconnectSetup then return end
        disconnectSetup = true

        pcall(function()
            game:GetService("GuiService").ErrorMessageChanged:Connect(function(message)
                if message and message ~= "" and AR.Enabled then
                    task.wait(1)
                    doRejoin()
                end
            end)
        end)

        pcall(function()
            local CoreGui = game:GetService("CoreGui")
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 5)
            if RobloxPromptGui then
                local promptOverlay = RobloxPromptGui:WaitForChild("promptOverlay", 5)
                if promptOverlay then
                    promptOverlay.ChildAdded:Connect(function(child)
                        if child.Name == "ErrorPrompt" and AR.Enabled then
                            task.wait(0.5)
                            doRejoin()
                        end
                    end)
                end
            end
        end)

        pcall(function()
            LocalPlayer.Idled:Connect(function(t)
                if t > 1150 and AR.Enabled then 
                    print("[Auto Rejoin] Terdeteksi Idle Kick, rejoining...")
                    doRejoin()
                end
            end)
        end)
    end

    -- Public Functions
    function AR.Start()
        if AR.Enabled then return end
        AR.Enabled = true
        hasTriggered = false
        setupDetection()
        if AR.AutoExecEnabled then setupAutoExecuteQueue() end
        print("[Auto Rejoin] Fitur diaktifkan.")
    end

    function AR.Stop()
        AR.Enabled = false
        hasTriggered = false
        print("[Auto Rejoin] Fitur dinonaktifkan.")
    end

    function AR.EnableAutoExec()
        AR.AutoExecEnabled = true
        if AR.Enabled then setupAutoExecuteQueue() end
    end

    function AR.DisableAutoExec()
        AR.AutoExecEnabled = false
        autoExecQueued = false
    end

    function AR.SetScriptURL(url)
        if type(url) == "string" and url ~= "" then
            SCRIPT_URL = url
            autoExecQueued = false
        end
    end

    function AR.IsQueueSupported()
        return getQueueOnTeleport() ~= nil
    end

    -- Fungsi Save Position (Update: Simpan PlaceId juga)
    function AR.SavePosition()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            AR.SavedCFrame = hrp.CFrame
            AR.SavedPlaceId = game.PlaceId
            AR.SaveToFile()
            print("[Auto Rejoin] Posisi berhasil disimpan di Map ID:", AR.SavedPlaceId, AR.SavedCFrame.Position)
            return true
        end
        return false
    end

    -- Fungsi Clear Position (Update: Reset PlaceId juga)
    function AR.ClearPosition()
        AR.SavedCFrame = nil
        AR.SavedPlaceId = nil
        AR.SaveToFile()
        print("[Auto Rejoin] Posisi yang disimpan telah dihapus.")
    end

    -- =====================================================
    -- DATA LOKASI ISLAND (diambil dari data "Teleport to Island")
    -- Dipakai buat deteksi otomatis lu lagi mancing paling deket island mana.
    -- =====================================================
    AR.Islands = {
        { name = "Bamboo",            pos = Vector3.new(-1364.95, 180.10, 320.49) },
        { name = "Iceberg",           pos = Vector3.new(-582.31, 190.07, -529.37) },
        { name = "Lost Whale Island", pos = Vector3.new(-2676.25, 179.97, 39.09) },
        { name = "Bora Reef",         pos = Vector3.new(-3996.39, 171.44, 2028.85) },
        { name = "Volcano Vent",      pos = Vector3.new(-1686.41, 173.81, 5931.25) },
        { name = "Cape Town",         pos = Vector3.new(804.61, 187.62, 2952.89) },
        { name = "Mystic Mangrove",   pos = Vector3.new(4428.54, 176.34, 1155.71) },
    }

    -- Cari island terdekat dari sebuah posisi. Return: nama, jarak (studs)
    function AR.GetNearestIsland(position)
        if not position then return nil, nil end
        local nearest, bestDist = nil, math.huge
        for _, isl in ipairs(AR.Islands) do
            local d = (position - isl.pos).Magnitude
            if d < bestDist then
                bestDist = d
                nearest = isl
            end
        end
        if nearest then return nearest.name, bestDist end
        return nil, nil
    end

    -- Label lokasi (nama island terdekat) buat posisi yang lagi disimpan.
    -- Kalau jaraknya deket (<= 800 studs) langsung pakai namanya, kalau jauh dikasih "Near".
    function AR.GetNearestIslandLabel(position)
        position = position or (AR.SavedCFrame and AR.SavedCFrame.Position)
        local name, dist = AR.GetNearestIsland(position)
        if name then
            if dist <= 800 then
                return name
            else
                return "Near " .. name
            end
        end
        return "Open Sea"
    end

    -- Ambil label lokasi realtime dari posisi karakter SEKARANG (belum tentu di-save).
    function AR.GetCurrentIslandLabel()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return "Karakter belum spawn" end
        return AR.GetNearestIslandLabel(hrp.Position)
    end

    -- Fungsi Get String (Update: Tampilkan nama Island terdekat + Map)
    function AR.GetSavedPositionString()
        if AR.SavedCFrame and AR.SavedPlaceId then
            local mapName = "Unknown Map"
            if AR.SavedPlaceId == 90457367396205 then
                mapName = "Explore Island"
            elseif AR.SavedPlaceId == 111385005478215 then
                mapName = "Base Map"
            else
                mapName = "Map " .. AR.SavedPlaceId
            end

            -- Nama spot = island terdekat (hanya relevan di map Explore Island)
            local spot
            if AR.SavedPlaceId == 90457367396205 then
                spot = AR.GetNearestIslandLabel(AR.SavedCFrame.Position)
            else
                spot = mapName
            end

            return string.format("%s @ %s (X: %.1f, Y: %.1f, Z: %.1f)", spot, mapName,
                AR.SavedCFrame.Position.X, AR.SavedCFrame.Position.Y, AR.SavedCFrame.Position.Z)
        end
        return "Belum ada posisi disimpan"
    end

    -- Muat spot yang tersimpan dari sesi sebelumnya
    pcall(AR.LoadFromFile)

    return AR
end)()

-- =============================================
-- UI ELEMENTS FOR AUTO REJOIN & POSITION
-- =============================================

-- 1. Toggle Auto Rejoin
CustomSection:CreateToggle({
    Id = "auto_rejoin_toggle",
    Title = "Auto Rejoin on Kick",
    Icon = "refresh-ccw",
    Default = false,
    Callback = function(state)
        if state then
            AutoRejoin.Start()
            Window:Notify({ Title = "Auto Rejoin", Content = "Fitur Auto Rejoin diaktifkan!", Type = "success", Duration = 3 })
        else
            AutoRejoin.Stop()
            Window:Notify({ Title = "Auto Rejoin", Content = "Fitur Auto Rejoin dinonaktifkan.", Type = "info", Duration = 3 })
        end
    end
})

-- 2. Toggle Auto Execute
CustomSection:CreateToggle({
    Id = "auto_exec_toggle",
    Title = "Auto Execute after Rejoin",
    Icon = "code",
    Default = false,
    Callback = function(state)
        if state then
            if not AutoRejoin.IsQueueSupported() then
                Window:Notify({ Title = "Auto Execute", Content = "Executor lu mungkin tidak mendukung queue_on_teleport!", Type = "warning", Duration = 4 })
            end
            AutoRejoin.EnableAutoExec()
            Window:Notify({ Title = "Auto Execute", Content = "Akan auto execute 15 detik setelah rejoin.", Type = "success", Duration = 3 })
        else
            AutoRejoin.DisableAutoExec()
            Window:Notify({ Title = "Auto Execute", Content = "Auto Execute dinonaktifkan.", Type = "info", Duration = 3 })
        end
    end
})

CustomSection:CreateDivider()
CustomSection:CreateSpace(4)

-- 3. 🎣 STATUS + SAVE/CLEAR (SIDE BY SIDE) 🎣
local statusLabel

local function refreshStatusLabel()
    if not statusLabel then return end
    if AutoRejoin.SavedCFrame then
        statusLabel.SetTitle("📍 Saved Spot: " .. AutoRejoin.GetSavedPositionString())
    else
        statusLabel.SetTitle("📡 Lokasi Sekarang: " .. AutoRejoin.GetCurrentIslandLabel())
    end
end

CustomSection:CreateButtonRow({
    Buttons = {
        {
            Title = "💾 Save Lokasi",
            Color = Color3.fromRGB(80, 190, 120),
            Callback = function()
                local success = AutoRejoin.SavePosition()
                if success then
                    local spot = AutoRejoin.GetNearestIslandLabel()
                    Window:Notify({
                        Title = "Posisi Disimpan",
                        Content = "Spot mancing di '" .. spot .. "' berhasil disimpan! Bakal otomatis balik ke sini setelah rejoin (map yang sama).",
                        Type = "success",
                        Duration = 3
                    })
                    refreshStatusLabel()
                else
                    Window:Notify({
                        Title = "Gagal Menyimpan",
                        Content = "Karakter tidak ditemukan. Pastikan lu sudah spawn di game.",
                        Type = "error",
                        Duration = 3
                    })
                end
            end
        },
        {
            Title = "🗑️ Hapus Lokasi",
            Color = Color3.fromRGB(220, 90, 90),
            Callback = function()
                AutoRejoin.ClearPosition()
                refreshStatusLabel()
                Window:Notify({ Title = "Dihapus", Content = "Posisi yang disimpan telah dihapus.", Type = "info", Duration = 2 })
            end
        },
    }
})

statusLabel = CustomSection:CreateLabel({
    Id = "saved_position_label",
    Title = "📡 Lokasi Sekarang: -",
    Description = "Update realtime pas klik Save / Clear."
})

task.spawn(function()
    while true do
        pcall(refreshStatusLabel)
        task.wait(0.5)
    end
end)

-- 4. Toggle Auto To Saved Position
CustomSection:CreateToggle({
    Id = "auto_to_position_toggle",
    Title = "Auto Return to Saved Spot",
    Icon = "navigation",
    Default = AutoRejoin.AutoToPosEnabled,
    Callback = function(state)
        AutoRejoin.AutoToPosEnabled = state
        AutoRejoin.SaveToFile()
        if state then
            if not AutoRejoin.SavedCFrame then
                Window:Notify({
                    Title = "Peringatan",
                    Content = "Lu belum save posisi apapun! Klik 'Save Lokasi' dulu.",
                    Type = "warning",
                    Duration = 4
                })
            else
                Window:Notify({
                    Title = "Auto Return Aktif",
                    Content = "Player akan otomatis tween ke spot yang disimpan (jika map-nya sama) setelah rejoin.",
                    Type = "success",
                    Duration = 3
                })
            end
        else
            Window:Notify({ Title = "Auto Return", Content = "Fitur kembali ke spot dinonaktifkan.", Type = "info", Duration = 3 })
        end
    end
})

-- 5. 🏃‍♂️ BUTTON: GO TO SAVED LOCATION (TWEEN) 🏃‍♂️
CustomSection:CreateButton({
    Id = "go_to_saved_location_btn",
    Title = "🏃‍♂️ Go to Saved Location (Tween)",
    Icon = "map-pin",
    Callback = function()
        -- 1. Cek apakah ada data yang di-save
        if not AutoRejoin.SavedCFrame then
            Window:Notify({
                Title = "Gagal",
                Content = "Belum ada lokasi yang disimpan! Klik 'Save Lokasi' dulu.",
                Type = "error",
                Duration = 3
            })
            return
        end

        -- 2. Cek apakah player berada di map yang sama dengan lokasi yang di-save
        if game.PlaceId ~= AutoRejoin.SavedPlaceId then
            Window:Notify({
                Title = "Salah Map",
                Content = "Lokasi tersimpan ada di map lain. Pindah ke map tersebut dulu!",
                Type = "warning",
                Duration = 3
            })
            return
        end

        -- 3. Eksekusi Tween
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")

        if not hrp then
            Window:Notify({
                Title = "Gagal",
                Content = "Karakter tidak ditemukan!",
                Type = "error",
                Duration = 3
            })
            return
        end

        Window:Notify({
            Title = "Menuju Lokasi",
            Content = "Sedang tween ke lokasi yang disimpan...",
            Type = "info",
            Duration = 2
        })

        local TweenService = game:GetService("TweenService")
        -- Tween selama 3 detik dengan gaya Quad agar mulus
        local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = AutoRejoin.SavedCFrame})
        
        tween:Play()
        
        -- Notif pas sampai
        tween.Completed:Connect(function()
            Window:Notify({
                Title = "Berhasil",
                Content = "Sampai di lokasi yang disimpan!",
                Type = "success",
                Duration = 3
            })
        end)
    end
})

-- =============================================
-- 6. AUTO RETURN OTOMATIS (pas execute ulang / respawn)
-- =============================================
local autoReturnBusy = false

local function autoReturnRun(reason)
    if autoReturnBusy then return end
    if not AutoRejoin.AutoToPosEnabled then return end
    if not (AutoRejoin.SavedCFrame and AutoRejoin.SavedPlaceId) then return end
    if game.PlaceId ~= AutoRejoin.SavedPlaceId then
        print("[Auto Return] Spot tersimpan ada di map lain, skip tween.")
        return
    end

    autoReturnBusy = true
    task.spawn(function()
        -- kasih waktu karakter & map selesai load
        task.wait(reason == "respawn" and 2 or 4)
        local ok = AutoRejoin.TweenToSaved()
        if ok then
            pcall(function()
                Window:Notify({
                    Title = "Auto Return",
                    Content = "Balik ke spot tersimpan (" .. AutoRejoin.GetNearestIslandLabel() .. ")...",
                    Type = "info",
                    Duration = 3
                })
            end)
        end
        task.wait(2)
        autoReturnBusy = false
    end)
end

-- jalan otomatis tiap script di-execute
task.spawn(function() autoReturnRun("execute") end)

-- jalan lagi kalau karakter respawn / abis mati
pcall(function()
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        autoReturnRun("respawn")
    end)
end)

-- kasih tau kalau executor ga support simpan file
task.spawn(function()
    task.wait(6)
    if not AutoRejoin.FileSupported then
        pcall(function()
            Window:Notify({
                Title = "Save Lokasi",
                Content = "Executor lu ga support simpan file, spot cuma bertahan selama sesi ini.",
                Type = "warning",
                Duration = 5
            })
        end)
    end
end)
-- 7. 🚨 TEST KICK BUTTON 🚨
-- CustomSection:CreateButton({
--     Id = "test_kick_button",
--     Title = "🚨 Test Kick (Uji Auto Rejoin & Return)",
--     Icon = "alert-triangle",
--     Callback = function()
--         if not AutoRejoin.Enabled then
--             Window:Notify({ Title = "Test Kick Gagal", Content = "Nyalakan dulu toggle 'Auto Rejoin on Kick' sebelum test!", Type = "error", Duration = 3 })
--             return
--         end

--         Window:Notify({ Title = "Test Kick", Content = "Mengkick player dalam 2 detik untuk test...", Type = "warning", Duration = 2 })
        
--         task.delay(2, function()
--             local LocalPlayer = game:GetService("Players").LocalPlayer
--             LocalPlayer:Kick("[TEST] Menguji fitur Auto Rejoin, Auto Execute & Auto Return to Position")
--         end)
--     end
-- })
-- ================================================================
--  TAB About
-- ================================================================
Loader:Set(0.97, "About")
task.wait()
local home = Window:CreateTab({ Title = "About", Icon = "" })
local welcome = home:CreateSection({ Title = "About", Opened = true })


-- Paragraph + gambar (sekarang FULL, ImageScaleType = "Crop")
local introPara = welcome:CreateParagraph({
	Id    = "intro",
	Text  = "Crafting smooth, clean, and powerful Roblox scripts with a focus on quality and performance.",
	Image = "rbxassetid://97514324988224",
	ImageHeight = 110,
	ImageScaleType = "Crop",   -- << gambar full penuhin card, gak ada bar hitam lagi
	Buttons = {
		{ Title = "Primary",   Variant = "Primary",   Icon = "bolt", Callback = function() Window:Notify({ Title = "Primary", Content = "Diklik!", Type = "success" }) end },
		{ Title = "Secondary", Variant = "Secondary", Callback = function() print("secondary") end },
		{ Title = "Tertiary",  Variant = "Tertiary",  Callback = function() print("tertiary") end },
	},
})

local statusLabel = welcome:CreateLabel({ Id = "status", Title = "Status: idle" })
welcome:CreateDivider()
-- >>> KARTU DEVELOPERS (compact, bisa banyak orang) <<<
welcome:CreateDevelopers({
	Id     = "devs",
	Title  = "Developers By:",                       -- header (opsional)
	Accent = Color3.fromRGB(120, 90, 240),       -- warna ring default (opsional)
	AvatarSize = 30,                             -- kecilin/gedein avatar (opsional)
	List = {
		{
			Name  = "King Vypers",
			Role  = "Lead Developer",
			Image = "rbxassetid://139467646163013",
		},
		{
			Name  = "King Akbar",
			Role  = "Co-Developer",
			Image = "rbxassetid://84070081307966",       -- ganti assetid foto temenmu
			Accent = Color3.fromRGB(80, 190, 120),   -- ring beda warna (opsional per orang)
		},
		-- tambah lagi kalau perlu:
		-- { Name = "...", Role = "...", Image = "rbxassetid://..." },
	},
})

welcome:CreateSpace(4)

welcome:CreateSpace(6)
welcome:CreateTag({ Id = "ver", Title = "Versi Library", Text = "v0.3", Color = Color3.fromRGB(120, 90, 240) })


-- ================================================================
--  ENABLE CONFIG  (PALING AKHIR) — DEFERRED biar ga nge-frame
-- ================================================================
-- ================================================================
--  SELESAI: load config -> tutup loading -> baru munculin window
-- ================================================================
Loader:Set(0.99, "Memuat konfigurasi")
task.wait()

local ok, err = pcall(function()
    Vypers:EnableConfig("default")
end)
if not ok then
    warn("[King Vypers] Gagal load config:", err)
end

-- isi bar ke 100%, fade out loading, LALU reveal window (anti nge-frame)
Loader:Finish(function()
    Window:Show()
    Window:Notify({
        Title = "King Vypers",
        Content = "Script berhasil di-load! Semua fitur siap digunakan.",
        Type = "success",
        Duration = 4,
    })
end)
