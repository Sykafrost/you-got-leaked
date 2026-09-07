-- =====================================================================
-- KING VYPERS GAG2 HUB  |  Powered by WindUI
-- Merged from: hub.lua + server_hop.lua + resources.lua
-- =====================================================================

-- =====================================================================
-- Disable console logs
-- =====================================================================
local print = function() end
local warn = function() end

-- =====================================================================
-- [1] WINDUI SETUP
-- =====================================================================

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "King Vypers",
    Icon = "rbxassetid://139467646163013",
    Folder = "KingVypers",
    Background = "rbxassetid://97514324988224",
    BackgroundImageTransparency = 0.35,
    Size = UDim2.new(0, 580, 0, 340),
    MinSize = Vector2.new(580, 340),
    MaxSize = Vector2.new(580, 340),
    NewElements = true,
    OpenButton = {
        Enabled = false,
    },
})

-- Colors
local Kings  = Color3.fromHex("#120324")
local Mains  = Color3.fromHex("#110029")
local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green  = Color3.fromHex("#10C550")
local Grey   = Color3.fromHex("#292828")
local Blue   = Color3.fromHex("#257AF7")
local Red    = Color3.fromHex("#EF4F1D")

WindUI:AddTheme({
    Name = "MachTheme",
    Background = Kings,
})
WindUI:SetTheme("MachTheme")

Window:Tag({ Title = "PREMIUM", Color = Mains })
Window:Tag({ Title = "BETA",    Color = Purple })

-- =====================================================================
-- [2] TOGGLE BUTTON (PC + MOBILE)
-- =====================================================================

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local protectGui
local _ok, _res = pcall(function()
    if gethui then return gethui()
    elseif syn and syn.protect_gui then
        local sg = Instance.new("ScreenGui")
        syn.protect_gui(sg)
        sg.Parent = CoreGui
        return sg.Parent
    else return CoreGui end
end)
protectGui = _ok and _res or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KVToggleButton"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = protectGui

local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(0, 42, 0, 42)
buttonFrame.Position = UDim2.new(0, 20, 0, 20)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = screenGui

local imageButton = Instance.new("ImageButton")
imageButton.Size = UDim2.new(1, 0, 1, 0)
imageButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
imageButton.BackgroundTransparency = 0.2
imageButton.Image = "rbxassetid://107726435417936"
imageButton.ScaleType = Enum.ScaleType.Fit
imageButton.Parent = buttonFrame

do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = imageButton
    local s = Instance.new("UIStroke"); s.Thickness = 2; s.Color = Color3.fromRGB(60, 60, 60); s.Parent = imageButton
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(Color3.fromRGB(20, 20, 20), Color3.fromRGB(60, 60, 60))
    g.Parent = s
end

-- Drag logic
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

imageButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos  = buttonFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

imageButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and dragInput and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        buttonFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Click to toggle
local clickStart = nil
imageButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        clickStart = input.Position
    end
end)
imageButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        if clickStart then
            if (input.Position - clickStart).Magnitude < 10 then
                if Window and Window.Toggle then Window:Toggle() end
            end
            clickStart = nil
        end
    end
end)

imageButton.MouseEnter:Connect(function()
    TweenService:Create(imageButton, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
end)
imageButton.MouseLeave:Connect(function()
    TweenService:Create(imageButton, TweenInfo.new(0.15), { BackgroundTransparency = 0.2 }):Play()
end)

-- =====================================================================
-- [3] SERVICES
-- =====================================================================

local Players        = game:GetService("Players")
local RS             = game:GetService("ReplicatedStorage")
local HttpService    = game:GetService("HttpService")
local VirtualUser    = game:GetService("VirtualUser")
local TeleportSvc    = game:GetService("TeleportService")
local CollectionSvc  = game:GetService("CollectionService")

local LP           = Players.LocalPlayer
local PlaceId      = game.PlaceId
local CurrentJobId = game.JobId

-- =====================================================================
-- [4] CONFIG
-- =====================================================================

local Config = {
    Timings = {
        HarvestInterval       = 0.2,
        SellInterval          = 5,
        WaterInterval         = 3,
        PlantInterval         = 5,
        RestockPollInterval   = 1,
        MutationScanInterval  = 3,
        WeatherPollInterval   = 5,
        StealInterval         = 1.5,
        InventoryCheckInterval= 10,
        PetHatchInterval      = 2,
        SeedPackPollInterval  = 2,
        PetCatchInterval      = 3,
    },
    Restock   = { TargetSeeds = {}, BlacklistedSeeds = {} },
    Steal     = { MinFruitValue = 10000, MaxAttemptsPerNight = 20 },
    Sell      = { Mode = "all", UseDailyDeal = false },
    Plant     = { PreferSeed = nil, GridSpacing = 3, PlantOrder = "Top", BlacklistMutated = true },
    Water     = { WaterAll = false, WaterFullyGrown = false, RequiredCan = "" },
    Inventory = { FavoriteThreshold = 500, AutoPromote = true },
    Pet       = { MinRarity = "Rare", AutoSellUnwanted = false },
    Gear      = { TargetGears = {}, PollInterval = 2 },
    Mutation  = {
        AlertMutations   = { "Rainbow", "Starstruck", "Gold", "Frozen", "Electric", "Bloodlit", "Chained" },
        PriceMultipliers = { Gold=20, Rainbow=50, Electric=12, Frozen=10, Bloodlit=5, Chained=8, Starstruck=100 },
        LogToConsole     = true,
    },
    Server    = { TargetJobId = "", RejoinDelay = 5, MaxRetries = 10 },
    PetCatch  = { MinRarity = "Common", AutoReturn = true },
    ServerHop = { MinPlayers = 1, MaxPlayers = 0, HopInterval = 30 },
    UI        = { NotifyDuration = 5 },
}

function Config.Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "King Vypers",
            Text  = text  or "",
            Duration = duration or Config.UI.NotifyDuration,
        })
    end)
end

-- =====================================================================
-- [5] NETWORKING MODULE
-- =====================================================================

local Networking = {}
Networking._module      = nil
Networking._cache       = {}
Networking._connections = {}

function Networking._resolve()
    if Networking._module then return Networking._module end
    -- Method 1: require() from SharedModules
    local ok, result = pcall(function()
        local shared = RS:WaitForChild("SharedModules", 10)
        if not shared then error("SharedModules not found") end
        return require(shared:WaitForChild("Networking", 10))
    end)
    if ok and result and type(result) == "table" then
        Networking._module = result; return result
    end
    -- Method 2: getgc scan
    local gcOk, gcResult = pcall(function()
        if not getgc then return nil end
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local hasPlant    = type(v.Plant)    == "table" and type(v.Plant.PlantSeed)       ~= "nil"
                local hasGarden   = type(v.Garden)   == "table" and type(v.Garden.CollectFruit)   ~= "nil"
                local hasSeedShop = type(v.SeedShop) == "table" and type(v.SeedShop.PurchaseSeed) ~= "nil"
                if hasPlant and hasGarden and hasSeedShop then return v end
            end
        end
        return nil
    end)
    if gcOk and gcResult and type(gcResult) == "table" then
        print("[KV] Networking resolved via getgc")
        Networking._module = gcResult; return gcResult
    end
    -- Method 3: pre-require Packet
    local pktOk, pktResult = pcall(function()
        local shared = RS:WaitForChild("SharedModules", 10)
        if not shared then error("not found") end
        local pkt = shared:WaitForChild("Packet", 5)
        local net = shared:WaitForChild("Networking", 5)
        if not pkt or not net then return nil end
        require(pkt)
        return require(net)
    end)
    if pktOk and pktResult and type(pktResult) == "table" then
        Networking._module = pktResult; return pktResult
    end
    warn("[KV] Failed to resolve Networking module")
    return nil
end

function Networking._resolveRemote(path)
    if Networking._cache[path] then return Networking._cache[path] end
    local net = Networking._resolve()
    if not net then return nil end
    local current = net
    for segment in string.gmatch(path, "[^%.]+") do
        if type(current) ~= "table" then return nil end
        current = current[segment]
        if current == nil then return nil end
    end
    Networking._cache[path] = current
    return current
end

function Networking.fire(path, ...)
    local remote = Networking._resolveRemote(path)
    if not remote then return false end
    local args = {...}; local argc = select("#", ...)
    local ok = pcall(function()
        if remote.Fire then remote:Fire(unpack(args, 1, argc))
        elseif type(remote) == "table" and remote.fire then remote:fire(unpack(args, 1, argc))
        else error("No :Fire method") end
    end)
    return ok
end

function Networking.invoke(path, ...)
    local remote = Networking._resolveRemote(path)
    if not remote then return nil end
    local args = {...}; local argc = select("#", ...)
    local ok, result = pcall(function()
        if remote.Invoke then return remote:Invoke(unpack(args, 1, argc))
        else error("No :Invoke method") end
    end)
    return ok and result or nil
end

function Networking.on(path, callback)
    local remote = Networking._resolveRemote(path)
    if not remote then return nil end
    local ok, conn = pcall(function()
        if remote.OnClientEvent then return remote.OnClientEvent:Connect(callback)
        elseif remote.Connect     then return remote:Connect(callback)
        else return nil end
    end)
    if ok and conn then table.insert(Networking._connections, conn); return conn end
    return nil
end

Networking._resolve()

-- =====================================================================
-- [6] UTILS
-- =====================================================================

local Utils = {}

function Utils.getLocalPlayer() return Players.LocalPlayer end
function Utils.getCharacter()
    local lp = Players.LocalPlayer
    return lp and lp.Character or nil
end
function Utils.getHumanoidRootPart()
    local char = Utils.getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end
function Utils.getHumanoid()
    local char = Utils.getCharacter()
    return char and char:FindFirstChildWhichIsA("Humanoid")
end
function Utils.getPlotId()
    local lp = Players.LocalPlayer
    return lp and lp:GetAttribute("PlotId")
end
function Utils.getMyGarden()
    local plotId = Utils.getPlotId()
    if not plotId then return nil end
    local gardens = workspace:FindFirstChild("Gardens")
    return gardens and gardens:FindFirstChild("Plot" .. tostring(plotId))
end
function Utils.getPlantsInGarden(garden)
    if not garden then return {} end
    local plants = {}
    for _, child in ipairs(garden:GetDescendants()) do
        if child:IsA("Model") and child:GetAttribute("SeedName") then
            table.insert(plants, child)
        end
    end
    return plants
end
function Utils.getPlantInfo(plant)
    if not plant then return nil end
    return {
        Name     = plant:GetAttribute("SeedName") or plant.Name,
        Growth   = plant:GetAttribute("Growth") or 0,
        Mutation = plant:GetAttribute("Mutation"),
        Size     = plant:GetAttribute("Size") or 1,
        IsRipe   = (plant:GetAttribute("Growth") or 0) >= 1,
        Instance = plant,
    }
end
function Utils.isNight()
    local night = RS:FindFirstChild("Night")
    if night then return night.Value == true end
    local clock = game:GetService("Lighting").ClockTime
    return clock >= 18 or clock < 6
end
function Utils.getSheckles()
    local lp = Players.LocalPlayer
    local ls = lp and lp:FindFirstChild("leaderstats")
    if not ls then return 0 end
    local sh = ls:FindFirstChild("Sheckles")
    return sh and sh.Value or 0
end
function Utils.formatNumber(n)
    if n >= 1e12 then return string.format("%.1fT", n/1e12) end
    if n >= 1e9  then return string.format("%.1fB", n/1e9)  end
    if n >= 1e6  then return string.format("%.1fM", n/1e6)  end
    if n >= 1e3  then return string.format("%.1fK", n/1e3)  end
    return tostring(n)
end
function Utils.formatTime(seconds)
    local h = math.floor(seconds/3600)
    local m = math.floor((seconds%3600)/60)
    local s = math.floor(seconds%60)
    if h > 0 then return string.format("%dh %dm %ds", h, m, s) end
    if m > 0 then return string.format("%dm %ds", m, s) end
    return string.format("%ds", s)
end

-- =====================================================================
-- [7] MODULE REGISTRY
-- =====================================================================

local Modules = {}
local Running = {}

local function startModule(name)
    if Running[name] then return end
    local mod = Modules[name]
    if mod and mod.start then
        mod.start(Config, Networking, Utils)
        Running[name] = true
        print("[KV] Started:", name)
    end
end

local function stopModule(name)
    if not Running[name] then return end
    local mod = Modules[name]
    if mod and mod.stop then
        mod.stop()
        Running[name] = false
        print("[KV] Stopped:", name)
    end
end

-- =====================================================================
-- [8] RESOURCES (Seed & Gear Prices)
-- =====================================================================

local Resources = nil
pcall(function()
    local src = game:HttpGet(
        "https://raw.githubusercontent.com/taurusss1000-design/bujangGlapuksAGmantap2/refs/heads/main/resources.lua",
        true
    )
    if src and #src > 100 then Resources = loadstring(src)() end
end)
if not Resources then
    Resources = { SeedPrices = {}, GearPrices = {}, SeedMeta = {}, GearMeta = {}, AllSeeds = {}, AllGears = {} }
    warn("[KV] Could not load resources.lua")
end

-- =====================================================================
-- [9] MODULE: AUTO HARVEST
-- =====================================================================

Modules.AutoHarvest = {}
do
    local Harvest = Modules.AutoHarvest
    Harvest._running = false; Harvest._thread = nil
    Harvest._connections = {}
    Harvest._stats = { harvested = 0, scans = 0, errors = 0 }

    local function getMyPlot()
        local lp = Players.LocalPlayer
        if not lp then return nil end
        local id = lp:GetAttribute("PlotId")
        if not id then return nil end
        local g = workspace:FindFirstChild("Gardens")
        return g and g:FindFirstChild("Plot" .. tostring(id))
    end

    local function isAlive()
        local lp = Players.LocalPlayer
        local char = lp and lp.Character
        local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
        return hum and hum.Health > 0
    end

    local function isHarvestable(model)
        if not model or not model.Parent then return false end
        local hp = model:FindFirstChild("HarvestPart")
        if not hp then return false end
        local pr = hp:FindFirstChild("HarvestPrompt")
        return pr and pr.Enabled
    end

    local function collectAll(Net)
        if not isAlive() then return 0 end
        local plot = getMyPlot()
        if not plot then return 0 end
        local count = 0
        local plantsFolder = plot:FindFirstChild("Plants")
        if not plantsFolder then return 0 end
        for _, plantModel in ipairs(plantsFolder:GetChildren()) do
            if not Harvest._running then break end
            local plantId = plantModel:GetAttribute("PlantId")
            if not plantId then continue end
            local fruitsFolder = plantModel:FindFirstChild("Fruits")
            if fruitsFolder then
                for _, fruitModel in ipairs(fruitsFolder:GetChildren()) do
                    if not Harvest._running then break end
                    if not isHarvestable(fruitModel) then continue end
                    local fruitId = fruitModel:GetAttribute("FruitId")
                    pcall(function() Net.fire("Garden.CollectFruit", plantId, fruitId or "") end)
                    count += 1
                    task.wait(0.1)
                end
            end
            if isHarvestable(plantModel) then
                pcall(function() Net.fire("Garden.CollectFruit", plantId, "") end)
                count += 1
                task.wait(0.1)
            end
        end
        return count
    end

    function Harvest.start(config, Net, Utils_)
        if Harvest._running then return end
        Harvest._running = true
        local conn = Net.on("Garden.FruitAdded", function(plantId, fruitId)
            if not Harvest._running or not isAlive() then return end
            task.wait(0.15)
            pcall(function() Net.fire("Garden.CollectFruit", plantId, fruitId or "") end)
            Harvest._stats.harvested += 1
        end)
        if conn then table.insert(Harvest._connections, conn) end
        Harvest._thread = task.spawn(function()
            while Harvest._running do
                Harvest._stats.scans += 1
                Harvest._stats.harvested += collectAll(Net)
                task.wait(config.Timings.HarvestInterval or 0.5)
            end
        end)
        print("[KV] Auto-Harvest started")
    end

    function Harvest.stop()
        Harvest._running = false
        for _, c in ipairs(Harvest._connections) do pcall(function() c:Disconnect() end) end
        Harvest._connections = {}
    end

    function Harvest.getStats() return Harvest._stats end
end

-- =====================================================================
-- [10] MODULE: AUTO SELL
-- =====================================================================

Modules.AutoSell = {}
do
    local Sell = Modules.AutoSell
    Sell._running = false; Sell._thread = nil
    Sell._stats = { sold = 0, errors = 0 }

    local function hasFruitInBag()
        local lp = Players.LocalPlayer
        local function check(container)
            if not container then return false end
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and (t:GetAttribute("FruitName") or t:GetAttribute("IsFruit")) then return true end
            end
            return false
        end
        return check(lp and lp:FindFirstChild("Backpack"))
            or check(lp and lp.Character)
    end

    function Sell.start(config, Net, Utils_)
        if Sell._running then return end
        Sell._running = true
        Sell._thread = task.spawn(function()
            while Sell._running do
                if hasFruitInBag() then
                    if Net.fire("NPCS.SellAll") then Sell._stats.sold += 1 else Sell._stats.errors += 1 end
                    if (config.Sell or {}).UseDailyDeal then Net.fire("NPCS.UseDailyDealAll") end
                end
                task.wait(config.Timings.SellInterval or 5)
            end
        end)
        print("[KV] Auto-Sell started")
    end

    function Sell.stop() Sell._running = false end
    function Sell.getStats() return Sell._stats end
end

-- =====================================================================
-- [11] MODULE: AUTO WATER
-- =====================================================================

Modules.AutoWater = {}
do
    local Water = Modules.AutoWater
    Water._running = false; Water._thread = nil; Water._connections = {}
    Water._stats = { watered = 0, scans = 0, errors = 0, noCan = 0 }

    local function trim(s)
        if type(s) ~= "string" then return "" end
        return s:match("^%s*(.-)%s*$") or ""
    end

    local function findCan(requiredCan)
        local LP_ = Players.LocalPlayer
        if not LP_ then return nil, nil end
        local reqNorm = trim(requiredCan)
        local function matchFn(n) return reqNorm == "" or trim(n) == reqNorm end
        local function scan(container)
            if not container then return nil end
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and t:GetAttribute("WateringCan") ~= nil and matchFn(t.Name) then
                    return t, t.Name
                end
            end
            return nil
        end
        local t, n = scan(LP_.Character)
        if t then return t, n end
        return scan(LP_:FindFirstChild("Backpack"))
    end

    local function equipCan(tool)
        local LP_ = Players.LocalPlayer
        local char = LP_ and LP_.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return false end
        if tool.Parent == char then return true end
        pcall(function() hum:EquipTool(tool) end)
        task.wait(0.2)
        return tool.Parent == char
    end

    function Water.start(config, Net, Utils_)
        if Water._running then return end
        Water._running = true
        Water._thread = task.spawn(function()
            while Water._running do
                Water._stats.scans += 1
                local garden = Utils_.getMyGarden()
                if garden then
                    local canTool, canName = findCan(config.Water.RequiredCan)
                    if not canTool then
                        Water._stats.noCan += 1
                    elseif not equipCan(canTool) then
                        Water._stats.errors += 1
                    else
                        local plants = Utils_.getPlantsInGarden(garden)
                        for _, plant in ipairs(plants) do
                            if not Water._running then break end
                            local info = Utils_.getPlantInfo(plant)
                            if not info then continue end
                            if info.Growth >= 1 and not config.Water.WaterFullyGrown then continue end
                            local root = plant:FindFirstChildWhichIsA("BasePart")
                            if not root then continue end
                            local ok = pcall(function()
                                Net.fire("WateringCan.UseWateringCan", root.Position - Vector3.new(0, 0.3, 0), canName, canTool)
                            end)
                            if ok then Water._stats.watered += 1 else Water._stats.errors += 1 end
                            task.wait(0.5)
                        end
                    end
                end
                task.wait(config.Timings.WaterInterval or 3)
            end
        end)
        print("[KV] Auto-Water started")
    end

    function Water.stop()
        Water._running = false
        for _, c in ipairs(Water._connections) do pcall(function() c:Disconnect() end) end
        Water._connections = {}
    end

    function Water.getStats() return Water._stats end
end

-- =====================================================================
-- [12] MODULE: AUTO PLANT
-- =====================================================================

Modules.AutoPlant = {}
do
    local Plant = Modules.AutoPlant
    Plant._running = false; Plant._thread = nil; Plant._connections = {}
    Plant._stats = { planted = 0, scans = 0, errors = 0, noSeeds = 0 }

    local function getEquippedSeed()
        local char = Players.LocalPlayer and Players.LocalPlayer.Character
        if not char then return nil, nil end
        local tool = char:FindFirstChildWhichIsA("Tool")
        if not tool or tool:GetAttribute("MainCategory") ~= "Seed" then return nil, nil end
        local sn = tool:GetAttribute("SeedTool")
        return sn and sn, sn and tool or nil
    end

    local function isMutatedSeed(sn)
        if not sn then return false end
        return sn == "Gold" or sn == "Rainbow"
            or string.match(sn, "^Gold ")    ~= nil
            or string.match(sn, "^Rainbow ") ~= nil
    end

    local function findSeedsInBackpack(preferSeed, skipMutated)
        local lp = Players.LocalPlayer
        local bp = lp and lp:FindFirstChild("Backpack")
        if not bp then return {} end
        local seeds = {}
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local sn  = tool:GetAttribute("SeedTool")
                local cat = tool:GetAttribute("MainCategory")
                if sn and cat == "Seed" then
                    if not (skipMutated and isMutatedSeed(sn)) then
                        table.insert(seeds, { tool = tool, seedName = sn })
                    end
                end
            end
        end
        table.sort(seeds, function(a, b)
            if preferSeed then
                local am = (a.seedName == preferSeed) and 1 or 0
                local bm = (b.seedName == preferSeed) and 1 or 0
                if am ~= bm then return am > bm end
            end
            return a.seedName < b.seedName
        end)
        return seeds
    end

    local function equipSeed(preferSeed, skipMutated)
        local lp   = Players.LocalPlayer
        local char = lp and lp.Character
        if not char then return nil, nil end
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if not hum then return nil, nil end
        local sn, tool = getEquippedSeed()
        if sn and not (skipMutated and isMutatedSeed(sn)) then return sn, tool end
        local seeds = findSeedsInBackpack(preferSeed, skipMutated)
        if #seeds == 0 then return nil, nil end
        local target = seeds[1]
        if not pcall(function() hum:EquipTool(target.tool) end) then return nil, nil end
        local waited = 0
        while waited < 2 do
            task.wait(0.1); waited += 0.1
            local eq = char:FindFirstChild(target.tool.Name)
            if eq and eq:IsA("Tool") and eq:GetAttribute("SeedTool") then
                return target.seedName, target.tool
            end
        end
        return nil, nil
    end

    local function unequipTool()
        local lp = Players.LocalPlayer
        local char = lp and lp.Character
        if not char then return end
        local tool = char:FindFirstChildWhichIsA("Tool")
        if tool then pcall(function() tool.Parent = lp:FindFirstChild("Backpack") end) end
    end

    local function getMyPlot()
        local lp = Players.LocalPlayer
        if not lp then return nil end
        local id = lp:GetAttribute("PlotId")
        if not id then return nil end
        local g = workspace:FindFirstChild("Gardens")
        return g and g:FindFirstChild("Plot" .. tostring(id))
    end

    local function isPosEmpty(pos, myPlot, minDist)
        minDist = minDist or 2.5
        local pf = myPlot:FindFirstChild("Plants")
        if not pf then return true end
        for _, pm in ipairs(pf:GetChildren()) do
            if pm:GetAttribute("PlantId") then
                local root = pm.PrimaryPart or pm:FindFirstChildWhichIsA("BasePart")
                if root then
                    local d = (Vector2.new(root.Position.X, root.Position.Z) - Vector2.new(pos.X, pos.Z)).Magnitude
                    if d < minDist then return false end
                end
            end
        end
        return true
    end

    local function generateGrid(part, spacing)
        spacing = spacing or 3
        local positions = {}
        local size = part.Size; local cf = part.CFrame
        local halfX = size.X/2; local halfZ = size.Z/2
        local stepsX = math.max(1, math.floor(size.X/spacing))
        local stepsZ = math.max(1, math.floor(size.Z/spacing))
        for ix = 0, stepsX do
            for iz = 0, stepsZ do
                local lx = -halfX + (ix/stepsX)*size.X
                local lz = -halfZ + (iz/stepsZ)*size.Z
                table.insert(positions, cf * Vector3.new(lx, size.Y/2, lz))
            end
        end
        return positions
    end

    local function findEmptySpots(myPlot, spacing, sortMode)
        spacing = spacing or 3
        local areas = {}
        for _, part in ipairs(CollectionSvc:GetTagged("PlantArea")) do
            if part:IsA("BasePart") and part:IsDescendantOf(myPlot) then table.insert(areas, part) end
        end
        for _, desc in ipairs(myPlot:GetDescendants()) do
            if desc:IsA("BasePart") and desc:GetAttribute("PlantArea") and not table.find(areas, desc) then
                table.insert(areas, desc)
            end
        end
        if #areas == 0 then
            for _, part in ipairs(CollectionSvc:GetTagged("GardenTotalArea")) do
                if part:IsA("BasePart") and part:IsDescendantOf(myPlot) then table.insert(areas, part) end
            end
        end
        local allPos = {}
        for _, part in ipairs(areas) do
            for _, pos in ipairs(generateGrid(part, spacing)) do table.insert(allPos, pos) end
        end
        local empty = {}
        for _, pos in ipairs(allPos) do
            if isPosEmpty(pos, myPlot) then table.insert(empty, pos) end
        end
        sortMode = sortMode or "Top"
        if     sortMode == "Top"    then table.sort(empty, function(a, b) return a.Y > b.Y end)
        elseif sortMode == "Bottom" then table.sort(empty, function(a, b) return a.Y < b.Y end)
        else
            for i = #empty, 2, -1 do
                local j = math.random(1, i); empty[i], empty[j] = empty[j], empty[i]
            end
        end
        return empty
    end

    function Plant.start(config, Net, Utils_)
        if Plant._running then return end
        Plant._running = true
        Plant._thread = task.spawn(function()
            while Plant._running do
                Plant._stats.scans += 1
                local pc = config.Plant or {}
                local seedName, toolInst = equipSeed(pc.PreferSeed, pc.BlacklistMutated)
                if not seedName then Plant._stats.noSeeds += 1
                else
                    local myPlot = getMyPlot()
                    if not myPlot then unequipTool()
                    else
                        local spots = findEmptySpots(myPlot, pc.GridSpacing or 3, pc.PlantOrder or "Top")
                        for _, pos in ipairs(spots) do
                            if not Plant._running then break end
                            local curSn = getEquippedSeed()
                            if not curSn then
                                seedName, toolInst = equipSeed(pc.PreferSeed, pc.BlacklistMutated)
                                if not seedName then break end
                            end
                            if pcall(function() Net.fire("Plant.PlantSeed", pos, seedName, toolInst) end) then
                                Plant._stats.planted += 1
                            else
                                Plant._stats.errors += 1
                            end
                            task.wait(0.3)
                        end
                        unequipTool()
                    end
                end
                task.wait(config.Timings.PlantInterval or 5)
            end
        end)
        print("[KV] Auto-Plant started")
    end

    function Plant.stop()
        Plant._running = false
        for _, c in ipairs(Plant._connections) do pcall(function() c:Disconnect() end) end
        Plant._connections = {}
    end

    function Plant.getStats() return Plant._stats end
end

-- =====================================================================
-- [13] MODULE: RESTOCK SNIPER
-- =====================================================================

Modules.RestockSniper = {}
do
    local Restock = Modules.RestockSniper
    Restock._running = false; Restock._thread = nil
    Restock._stats = { bought = 0, scanned = 0, moneySpent = 0, errors = 0, skipped = 0 }

    local SeedPrices = Resources.SeedPrices or {}

    local function getStock(seedName)
        local ok, folder = pcall(function()
            return RS:WaitForChild("StockValues", 5):WaitForChild("SeedShop", 5):WaitForChild("Items", 5)
        end)
        if not ok or not folder then return -1 end
        local val = folder:FindFirstChild(seedName)
        if not val or not val:IsA("ValueBase") then return 0 end
        return val.Value or 0
    end

    function Restock.start(config, Net, Utils_)
        if Restock._running then return end
        Restock._running = true
        Restock._thread = task.spawn(function()
            while Restock._running do
                Restock._stats.scanned += 1
                local rc = config.Restock or {}
                local targets   = rc.TargetSeeds or {}
                local blacklist = {}
                for _, n in ipairs(rc.BlacklistedSeeds or {}) do blacklist[n] = true end
                for _, seedName in ipairs(targets) do
                    if not Restock._running then break end
                    if blacklist[seedName] then continue end
                    local price    = SeedPrices[seedName] or 0
                    local sheckles = Utils_.getSheckles()
                    if price > 0 and sheckles < price then Restock._stats.skipped += 1; continue end
                    local stock = getStock(seedName)
                    if stock == 0 then Restock._stats.skipped += 1; continue end
                    local maxBuys = (stock > 0 and stock) or 50
                    for i = 1, maxBuys do
                        if not Restock._running then break end
                        if price > 0 and Utils_.getSheckles() < price then break end
                        local prev = getStock(seedName)
                        pcall(function() Net.fire("SeedShop.PurchaseSeed", seedName) end)
                        task.wait(0.15)
                        if getStock(seedName) < prev then
                            Restock._stats.bought += 1
                            Restock._stats.moneySpent += price
                        else break end
                    end
                end
                task.wait(config.Timings.RestockPollInterval or 1)
            end
        end)
        print("[KV] Restock Sniper started")
    end

    function Restock.stop() Restock._running = false end
    function Restock.getStats() return Restock._stats end
end

-- =====================================================================
-- [14] MODULE: MUTATION TRACKER
-- =====================================================================

Modules.MutationTracker = {}
do
    local Mutation = Modules.MutationTracker
    Mutation._running = false; Mutation._thread = nil; Mutation._connections = {}
    Mutation._stats = { tracked = 0, alerts = 0 }
    Mutation._log   = {}

    function Mutation.start(config, Net, Utils_)
        if Mutation._running then return end
        Mutation._running = true
        local mc = config.Mutation or {}

        local function onMut(source, plantId, mutation)
            if not mutation or mutation == "" then return end
            Mutation._stats.tracked += 1
            table.insert(Mutation._log, { source = source, plantId = plantId, mutation = mutation, time = os.time() })
            if #Mutation._log > 500 then table.remove(Mutation._log, 1) end
            for _, name in ipairs(mc.AlertMutations or {}) do
                if name == mutation then
                    Mutation._stats.alerts += 1
                    local mult = (mc.PriceMultipliers or {})[mutation] or 1
                    local msg  = string.format("[%s] %s -> %s (x%d)", source, tostring(plantId), mutation, mult)
                    if mc.LogToConsole then print("[KV] Mutasi: " .. msg) end
                    Config.Notify("Mutasi Detected!", msg, 8)
                    break
                end
            end
        end

        local c1 = Net.on("Garden.PlantMutationUpdated",  function(pid, mut)       onMut("plant",  pid, mut) end)
        local c2 = Net.on("Garden.FruitMutationUpdated",  function(pid, fid, mut) onMut("fruit",  pid, mut) end)
        local c3 = Net.on("Garden.PlantGrowthUpdated",    function(pid, g, s, mut) if mut and mut ~= "" then onMut("growth", pid, mut) end end)
        for _, c in ipairs({c1, c2, c3}) do if c then table.insert(Mutation._connections, c) end end

        Mutation._thread = task.spawn(function()
            while Mutation._running do
                local garden = Utils_.getMyGarden()
                if garden then
                    for _, plant in ipairs(Utils_.getPlantsInGarden(garden)) do
                        local info = Utils_.getPlantInfo(plant)
                        if info and info.Mutation and info.Mutation ~= "" then
                            Mutation._stats.tracked += 1
                        end
                    end
                end
                task.wait(config.Timings.MutationScanInterval or 3)
            end
        end)
        print("[KV] Mutation Tracker started")
    end

    function Mutation.stop()
        Mutation._running = false
        for _, c in ipairs(Mutation._connections) do pcall(function() c:Disconnect() end) end
        Mutation._connections = {}
    end

    function Mutation.getStats() return Mutation._stats end
end

-- =====================================================================
-- [15] MODULE: WEATHER BOT
-- =====================================================================

Modules.WeatherBot = {}
do
    local Weather = Modules.WeatherBot
    Weather._running = false; Weather._thread = nil; Weather._connections = {}
    Weather._stats = { events = 0, alerts = 0, scans = 0 }

    local WEATHER_EVENTS = {
        "WeatherEffects.BloodmoonBeam", "WeatherEffects.RainbowStart", "WeatherEffects.RainbowEnd",
        "WeatherEffects.GoldMoonStrike", "WeatherEffects.BlizzardStart", "WeatherEffects.BlizzardEnd",
        "WeatherEffects.ShootingStar",   "WeatherEffects.ChainPull",
    }

    function Weather.start(config, Net, Utils_)
        if Weather._running then return end
        Weather._running = true
        for _, eventPath in ipairs(WEATHER_EVENTS) do
            local conn = Net.on(eventPath, function()
                Weather._stats.events += 1
                local wt = eventPath:match("WeatherEffects%.(.+)") or eventPath
                if wt:match("Start") or wt:match("Strike") or wt:match("Beam") or wt:match("Star") then
                    Weather._stats.alerts += 1
                    local msg = "Weather event: " .. wt
                    print("[KV] " .. msg)
                    Config.Notify("Weather Event!", msg, 10)
                end
            end)
            if conn then table.insert(Weather._connections, conn) end
        end
        local nightVal = RS:FindFirstChild("Night")
        if nightVal then
            local conn = nightVal.Changed:Connect(function(isNight)
                print("[KV] Phase:", isNight and "Night" or "Day")
            end)
            table.insert(Weather._connections, conn)
        end
        Weather._thread = task.spawn(function()
            while Weather._running do
                Weather._stats.scans += 1
                task.wait(config.Timings.WeatherPollInterval or 5)
            end
        end)
        print("[KV] Weather Bot started")
    end

    function Weather.stop()
        Weather._running = false
        for _, c in ipairs(Weather._connections) do pcall(function() c:Disconnect() end) end
        Weather._connections = {}
    end

    function Weather.getStats() return Weather._stats end
end

-- =====================================================================
-- [16] MODULE: STEAL BOT
-- =====================================================================

Modules.StealBot = {}
do
    local Steal = Modules.StealBot
    Steal._running = false; Steal._thread = nil; Steal._connections = {}
    Steal._stats = { attempts = 0, stolen = 0, errors = 0, nightCycles = 0 }

    local function isGardenUnlocked(garden)
        local ownerUID = tonumber(garden:GetAttribute("OwnerUserId") or garden:GetAttribute("Owner"))
        if ownerUID then
            local owner = Players:GetPlayerByUserId(ownerUID)
            if owner and owner.Character then
                local ownerHRP = owner.Character:FindFirstChild("HumanoidRootPart")
                if ownerHRP then
                    for _, part in ipairs(garden:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local rel = part.CFrame:PointToObjectSpace(ownerHRP.Position)
                            local hs  = part.Size/2
                            if math.abs(rel.X) <= hs.X and math.abs(rel.Y) <= hs.Y+10 and math.abs(rel.Z) <= hs.Z then
                                return false
                            end
                        end
                    end
                end
            end
        end
        return true
    end

    local function findStealablePrompts(myPlotId)
        local results = {}
        local gardens = workspace:FindFirstChild("Gardens")
        if not gardens then return results end
        for _, garden in ipairs(gardens:GetChildren()) do
            local plotNum = tonumber(garden.Name:match("Plot(%d+)"))
            if plotNum and plotNum ~= myPlotId and isGardenUnlocked(garden) then
                local pf = garden:FindFirstChild("Plants")
                if pf then
                    for _, pm in ipairs(pf:GetChildren()) do
                        local ff = pm:FindFirstChild("Fruits")
                        if ff then
                            for _, fm in ipairs(ff:GetChildren()) do
                                local pr = fm:FindFirstChild("StealPrompt", true)
                                if pr and pr:IsA("ProximityPrompt") and pr.Enabled
                                    and not pr:GetAttribute("Collected") and pr.HoldDuration == 0 then
                                    local uid = tonumber(fm:GetAttribute("UserId"))
                                    local pid = fm:GetAttribute("PlantId")
                                    if uid and pid then
                                        table.insert(results, {
                                            prompt = pr, userId = uid,
                                            plantId = pid, fruitId = fm:GetAttribute("FruitId") or "",
                                            gardenName = garden.Name,
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return results
    end

    local function attemptSteal(entry, Net, Utils_)
        local pr = entry.prompt
        if not pr or not pr.Parent or not pr.Enabled or pr:GetAttribute("Collected") then return false end
        Steal._stats.attempts += 1
        local hrp = Utils_.getHumanoidRootPart()
        if not hrp then return false end
        local savedCF = hrp.CFrame
        local fruitPart = pr.Parent
        if not fruitPart or not fruitPart:IsA("BasePart") then
            fruitPart = pr.Parent and pr.Parent:FindFirstChildWhichIsA("BasePart")
        end
        if not fruitPart then return false end
        pcall(function() hrp.CFrame = fruitPart.CFrame + Vector3.new(0, 3, 0) end)
        task.wait(0.8)
        local triggered = false
        pcall(function()
            if fireproximityprompt then fireproximityprompt(pr)
            else
                pr:InputHoldBegin()
                task.wait(math.max(0.09, pr.HoldDuration + 0.1))
                if pr and pr:IsDescendantOf(workspace) then pr:InputHoldEnd() end
            end
            triggered = true
        end)
        if not triggered then pcall(function() hrp.CFrame = savedCF end); return false end
        task.wait(0.5)
        local carrying = Players.LocalPlayer:GetAttribute("CarryingStolenFruit")
        local garden = Utils_.getMyGarden()
        if garden then
            local sp = garden:FindFirstChild("SpawnPoint") or garden:FindFirstChildWhichIsA("BasePart")
            if sp then pcall(function() hrp.CFrame = sp.CFrame + Vector3.new(0, 3, 0) end) end
        else
            pcall(function() hrp.CFrame = savedCF end)
        end
        return carrying and true or false
    end

    function Steal.start(config, Net, Utils_)
        if Steal._running then return end
        Steal._running = true
        local sc = config.Steal or {}
        Steal._thread = task.spawn(function()
            local wasNight = false
            while Steal._running do
                local isNight = Utils_.isNight()
                if isNight and not wasNight then
                    Steal._stats.nightCycles += 1
                    Steal._stats.attempts = 0
                    print("[KV] Malam! Steal Bot aktif")
                end
                if isNight then
                    local myPlotId = Players.LocalPlayer and Players.LocalPlayer:GetAttribute("PlotId")
                    if myPlotId and Steal._stats.attempts < (sc.MaxAttemptsPerNight or 20) then
                        for _, entry in ipairs(findStealablePrompts(myPlotId)) do
                            if not Steal._running or Steal._stats.attempts >= (sc.MaxAttemptsPerNight or 20) then break end
                            if attemptSteal(entry, Net, Utils_) then
                                Steal._stats.stolen += 1; break
                            end
                            task.wait(0.5)
                        end
                    end
                end
                wasNight = isNight
                task.wait(config.Timings.StealInterval or 1.5)
            end
        end)
        print("[KV] Steal Bot started")
    end

    function Steal.stop()
        Steal._running = false
        for _, c in ipairs(Steal._connections) do pcall(function() c:Disconnect() end) end
        Steal._connections = {}
    end

    function Steal.getStats() return Steal._stats end
end

-- =====================================================================
-- [17] MODULE: AUTO BUY PET (Egg Hatch)
-- =====================================================================

Modules.AutoBuyPet = {}
do
    local Pet = Modules.AutoBuyPet
    Pet._running = false; Pet._thread = nil
    Pet._stats = { hatched = 0, kept = 0, sold = 0, errors = 0, noEggs = 0 }

    local RARITY_ORDER = { Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=4, Mythic=5, Super=6 }
    local PetData = nil
    pcall(function()
        PetData = require(RS:WaitForChild("SharedData"):WaitForChild("PetData"))
    end)

    local function getRarity(petName)
        return (PetData and PetData[petName] and PetData[petName].Rarity) or "Common"
    end

    local function passesFilter(petName, minRarity)
        return (RARITY_ORDER[getRarity(petName)] or 1) >= (RARITY_ORDER[minRarity] or 1)
    end

    local function findEggs()
        local lp = Players.LocalPlayer
        local bp = lp and lp:FindFirstChild("Backpack")
        if not bp then return {} end
        local eggs = {}
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local en = tool:GetAttribute("Egg")
                if en and en ~= "" then table.insert(eggs, { tool = tool, eggName = en }) end
            end
        end
        return eggs
    end

    local function hatchEgg(eggName, Net)
        local result, done = nil, false
        local conn
        conn = Net.on("Egg.ReplicateOpenEgg", function(player, eName, petName, size, pos, petType)
            if player == Players.LocalPlayer and eName == eggName then
                result = { petName = petName, size = size, petType = petType }
                done = true
                if conn then pcall(function() conn:Disconnect() end) end
            end
        end)
        if not pcall(function() Net.fire("Egg.OpenEgg", eggName) end) then
            if conn then pcall(function() conn:Disconnect() end) end
            return nil
        end
        local t = 0
        while not done and t < 5 do task.wait(0.1); t += 0.1 end
        if conn then pcall(function() conn:Disconnect() end) end
        if not result then return nil end
        pcall(function() Net.fire("Egg.ConfirmEgg", eggName, result.petName, result.size or "") end)
        return result
    end

    function Pet.start(config, Net, Utils_)
        if Pet._running then return end
        Pet._running = true
        Pet._thread = task.spawn(function()
            while Pet._running do
                local pc   = config.Pet or {}
                local eggs = findEggs()
                if #eggs == 0 then Pet._stats.noEggs += 1
                else
                    local result = hatchEgg(eggs[1].eggName, Net)
                    if not result then Pet._stats.errors += 1
                    else
                        Pet._stats.hatched += 1
                        local passes = passesFilter(result.petName, pc.MinRarity or "Rare")
                        print(string.format("[KV] Hatched: %s [%s] - %s",
                            result.petName, result.size or "?", passes and "KEPT" or "below filter"))
                        if passes then
                            Pet._stats.kept += 1
                        elseif pc.AutoSellUnwanted then
                            task.wait(1)
                            local lp = Players.LocalPlayer
                            local bp = lp and lp:FindFirstChild("Backpack")
                            if bp then
                                for _, tool in ipairs(bp:GetChildren()) do
                                    if tool:IsA("Tool") and tool:GetAttribute("Pet") == result.petName then
                                        local petId = tool:GetAttribute("PetId")
                                        if petId then
                                            pcall(function() Net.invoke("NPCS.SellPet", petId) end)
                                            Pet._stats.sold += 1; break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(config.Timings.PetHatchInterval or 2)
            end
        end)
        print("[KV] Auto-Buy Pet started")
    end

    function Pet.stop() Pet._running = false end
    function Pet.getStats() return Pet._stats end
end

-- =====================================================================
-- [18] MODULE: INVENTORY OPTIMIZER
-- =====================================================================

Modules.InventoryOptimizer = {}
do
    local Inventory = Modules.InventoryOptimizer
    Inventory._running = false; Inventory._thread = nil
    Inventory._stats = { favorited = 0, promoted = 0, scanned = 0 }

    local BASE_VALUES = {
        Carrot=5, Strawberry=3, Blueberry=5, Tomato=9, Apple=12, Cactus=40,
        Pineapple=30, Banana=35, Corn=34, Grape=45, Mango=90, Coconut=60,
        Cherry=350, Pomegranate=900, ["Dragon Fruit"]=150, Mushroom=13000,
        Sunflower=1750, ["Venus Fly Trap"]=3000, ["Moon Bloom"]=9000,
        ["Dragon's Breath"]=3400, ["Ghost Pepper"]=2500, Lotus=6500,
    }
    local MUT_MULT = { Gold=20, Rainbow=50, Electric=12, Frozen=10, Bloodlit=5, Chained=8, Starstruck=100 }

    function Inventory.start(config, Net, Utils_)
        if Inventory._running then return end
        Inventory._running = true
        Inventory._thread = task.spawn(function()
            while Inventory._running do
                Inventory._stats.scanned += 1
                local ic = config.Inventory or {}
                local bp = Players.LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _, tool in ipairs(bp:GetChildren()) do
                        if not tool:IsA("Tool") then continue end
                        local fn   = tool:GetAttribute("FruitName") or ""
                        local mut  = tool:GetAttribute("Mutation")  or ""
                        local size = tool:GetAttribute("Size")      or 1
                        local base = BASE_VALUES[fn ~= "" and fn or tool.Name] or 0
                        local val  = base * (size ^ 2.65) * (MUT_MULT[mut] or 1)
                        if ic.AutoFavorite ~= false and val >= (ic.FavoriteThreshold or 500) then
                            if pcall(function() Net.fire("Backpack.SetFruitFavorite", tool.Name, true) end) then
                                Inventory._stats.favorited += 1
                            end
                        end
                        if ic.AutoPromote and (tool:GetAttribute("ItemType") == "HarvestedFruit" or fn ~= "") then
                            if pcall(function() Net.fire("Backpack.PromoteFruit", tool.Name) end) then
                                Inventory._stats.promoted += 1
                            end
                        end
                    end
                end
                task.wait(config.Timings.InventoryCheckInterval or 10)
            end
        end)
        print("[KV] Inventory Optimizer started")
    end

    function Inventory.stop() Inventory._running = false end
    function Inventory.getStats() return Inventory._stats end
end

-- =====================================================================
-- [19] MODULE: GEAR BUYER
-- =====================================================================

Modules.GearBuyer = {}
do
    local Gear = Modules.GearBuyer
    Gear._running = false; Gear._thread = nil
    Gear._stats = { scanned = 0, bought = 0, skipped = 0, errors = 0 }

    local GearCosts = Resources.GearPrices or {}

    local function getGearStock(gearName)
        local ok, folder = pcall(function()
            return RS:WaitForChild("StockValues",5):WaitForChild("GearShop",5):WaitForChild("Items",5)
        end)
        if not ok or not folder then return -1 end
        local val = folder:FindFirstChild(gearName)
        if not val or not val:IsA("ValueBase") then return 0 end
        return val.Value or 0
    end

    function Gear.start(config, Net, Utils_)
        if Gear._running then return end
        Gear._running = true
        local gc = config.Gear or {}
        Gear._thread = task.spawn(function()
            while Gear._running do
                Gear._stats.scanned += 1
                for _, gearName in ipairs(gc.TargetGears or {}) do
                    if not Gear._running then break end
                    local stock = getGearStock(gearName)
                    if stock == 0 then Gear._stats.skipped += 1; continue end
                    local cost = GearCosts[gearName] or 0
                    if cost > 0 and Utils_.getSheckles() < cost then Gear._stats.skipped += 1; continue end
                    local maxBuys = (stock > 0 and stock) or 10
                    for i = 1, maxBuys do
                        if not Gear._running then break end
                        if cost > 0 and Utils_.getSheckles() < cost then break end
                        local prev = getGearStock(gearName)
                        if pcall(function() Net.fire("GearShop.PurchaseGear", gearName) end) then
                            task.wait(0.15)
                            if getGearStock(gearName) < prev then Gear._stats.bought += 1 else break end
                        else break end
                    end
                end
                task.wait(gc.PollInterval or 2)
            end
        end)
        print("[KV] Gear Buyer started")
    end

    function Gear.stop() Gear._running = false end
    function Gear.getStats() return Gear._stats end
end

-- =====================================================================
-- [20] MODULE: SEED PACK CLAIMER
-- =====================================================================

Modules.SeedPackClaimer = {}
do
    local SeedPack = Modules.SeedPackClaimer
    SeedPack._running = false; SeedPack._thread = nil; SeedPack._connections = {}
    SeedPack._stats   = { claimed = 0, rainbow = 0, gold = 0, regular = 0, scanned = 0 }
    SeedPack._claimed = {}

    local function claimOne(spawn, Net, root)
        local part = spawn.part
        if not part or not part.Parent or SeedPack._claimed[part] then return end
        local origCF = root.CFrame
        pcall(function() root.CFrame = part.CFrame * CFrame.new(0, 3, 0) end)
        task.wait(0.3)
        local claimed = false
        local pr = part:FindFirstChildWhichIsA("ProximityPrompt", true)
        if pr then
            pcall(function()
                pr.HoldDuration = 0
                pr:InputHoldBegin(); task.wait(0.1); pr:InputHoldEnd()
                claimed = true
            end)
        end
        if not claimed then pcall(function() Net.fire("SeedPack.ClickPack", part); claimed = true end) end
        task.wait(0.1)
        SeedPack._claimed[part] = true
        if spawn.rainbow then
            SeedPack._stats.rainbow += 1; SeedPack._stats.claimed += 1
            print("[KV] RAINBOW SEED claimed!"); Config.Notify("Rainbow Seed!", "Rainbow Seed diklaim!", 10)
        elseif spawn.gold then
            SeedPack._stats.gold += 1; SeedPack._stats.claimed += 1
            print("[KV] GOLD SEED claimed!"); Config.Notify("Gold Seed!", "Gold Seed diklaim!", 10)
        else
            SeedPack._stats.regular += 1; SeedPack._stats.claimed += 1
        end
        task.wait(0.1)
        pcall(function() root.CFrame = origCF end)
        task.spawn(function()
            while part and part.Parent do task.wait(1) end
            SeedPack._claimed[part] = nil
        end)
    end

    function SeedPack.start(config, Net, Utils_)
        if SeedPack._running then return end
        SeedPack._running = true
        local spawnFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SeedPackSpawnServerLocations")
        if spawnFolder then
            local conn = spawnFolder.ChildAdded:Connect(function(part)
                if not SeedPack._running or not part:IsA("BasePart") or SeedPack._claimed[part] then return end
                task.wait(0.5)
                local LP_ = Utils_.getLocalPlayer()
                local root = LP_ and LP_.Character and LP_.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    claimOne({
                        part = part,
                        rainbow = part:GetAttribute("RainbowSeed") == true,
                        gold    = part:GetAttribute("GoldSeed")    == true,
                    }, Net, root)
                end
            end)
            table.insert(SeedPack._connections, conn)
        end
        SeedPack._thread = task.spawn(function()
            while SeedPack._running do
                SeedPack._stats.scanned += 1
                local LP_ = Utils_.getLocalPlayer()
                local root = LP_ and LP_.Character and LP_.Character:FindFirstChild("HumanoidRootPart")
                if root and spawnFolder then
                    local spawns = {}
                    for _, part in ipairs(spawnFolder:GetChildren()) do
                        if part:IsA("BasePart") and not SeedPack._claimed[part] then
                            local isRainbow = part:GetAttribute("RainbowSeed") == true
                            local isGold    = part:GetAttribute("GoldSeed")    == true
                            table.insert(spawns, {
                                part = part, rainbow = isRainbow, gold = isGold,
                                priority = isRainbow and 3 or (isGold and 2 or 1),
                                dist = (part.Position - root.Position).Magnitude,
                            })
                        end
                    end
                    table.sort(spawns, function(a, b)
                        if a.priority ~= b.priority then return a.priority > b.priority end
                        return a.dist < b.dist
                    end)
                    for _, sp in ipairs(spawns) do
                        if not SeedPack._running then break end
                        claimOne(sp, Net, root)
                    end
                end
                task.wait(config.Timings.SeedPackPollInterval or 2)
            end
        end)
        print("[KV] Seed Pack Claimer started")
    end

    function SeedPack.stop()
        SeedPack._running = false
        for _, c in ipairs(SeedPack._connections) do pcall(function() c:Disconnect() end) end
        SeedPack._connections = {}
    end

    function SeedPack.getStats() return SeedPack._stats end
end

-- =====================================================================
-- [21] MODULE: AUTO PET CATCH
-- =====================================================================

Modules.AutoPetCatch = {}
do
    local M = Modules.AutoPetCatch
    M._running = false; M._thread = nil; M._connections = {}
    M._stats   = { caught = 0, scanned = 0 }
    M._tamed   = {}

    local RARITY_ORDER = { Common=1, Uncommon=2, Rare=3, Legendary=4, Mythic=5, Super=6 }

    local function getRef(uuid)
        local rf = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetRef")
        return rf and rf:FindFirstChild("WildPet_" .. uuid)
    end

    local function passFilter(refPart, pc)
        if not refPart then return true end
        if (refPart:GetAttribute("OwnerUserId") or 0) ~= 0 then return false end
        if (refPart:GetAttribute("State") or "") ~= "wandering" then return false end
        local rarity = refPart:GetAttribute("Rarity") or "Common"
        return (RARITY_ORDER[rarity] or 0) >= (RARITY_ORDER[pc.MinRarity or "Common"] or 0)
    end

    local function catchOne(petInfo, pc, Net, root)
        local model = petInfo.model
        if not model or not model.Parent or M._tamed[model] then return false end
        local refPart = petInfo.uuid and getRef(petInfo.uuid)
        if refPart and not passFilter(refPart, pc) then return false end
        local rootPart = model:FindFirstChild("RootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        if not rootPart then return false end
        local origCF = root.CFrame
        pcall(function() root.CFrame = rootPart.CFrame * CFrame.new(0, 5, 0) end)
        task.wait(0.8)
        local caught = false
        local nearest, nearDist = nil, math.huge
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then
                local pp = desc.Parent
                if pp and pp:IsA("BasePart") then
                    local d = (pp.Position - root.Position).Magnitude
                    if d < nearDist and d <= desc.MaxActivationDistance then
                        nearDist = d; nearest = desc
                    end
                end
            end
        end
        if nearest then
            pcall(function()
                nearest.HoldDuration = 0
                nearest:InputHoldBegin(); task.wait(0.2); nearest:InputHoldEnd()
                caught = true
            end)
        end
        if not caught then pcall(function() Net.fire("Pets.WildPetTame", model); caught = true end) end
        task.wait(1)
        if pc.AutoReturn ~= false then pcall(function() root.CFrame = origCF end) end
        M._tamed[model] = true
        M._stats.caught += 1
        local petName = petInfo.petName or "Unknown"
        local rarity  = refPart and refPart:GetAttribute("Rarity") or "?"
        print(string.format("[KV] Caught Pet: %s (%s)", petName, rarity))
        Config.Notify("Pet Caught!", petName .. " (" .. rarity .. ")", 6)
        task.spawn(function()
            while model and model.Parent do task.wait(1) end
            M._tamed[model] = nil
        end)
        return true
    end

    function M.start(config, Net, Utils_)
        if M._running then return end
        M._running = true
        local pc = config.PetCatch or {}
        local interval = config.Timings.PetCatchInterval or 3
        local spawnFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetSpawns")
        if spawnFolder then
            local conn = spawnFolder.ChildAdded:Connect(function(model)
                if not M._running or not model:IsA("Model") then return end
                task.wait(1)
                local uuid    = model.Name:match("WildPet_%w+_WildPet_(.+)")
                local refPart = uuid and getRef(uuid)
                if refPart and passFilter(refPart, pc) then
                    local LP_ = Utils_.getLocalPlayer()
                    local root = LP_ and LP_.Character and LP_.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        catchOne({ model=model, petName=model:GetAttribute("PetName") or model.Name, uuid=uuid }, pc, Net, root)
                    end
                end
            end)
            table.insert(M._connections, conn)
        end
        M._thread = task.spawn(function()
            while M._running do
                M._stats.scanned += 1
                local LP_ = Utils_.getLocalPlayer()
                local root = LP_ and LP_.Character and LP_.Character:FindFirstChild("HumanoidRootPart")
                if root and spawnFolder then
                    for _, model in ipairs(spawnFolder:GetChildren()) do
                        if not M._running then break end
                        if model:IsA("Model") and not M._tamed[model] then
                            local uuid    = model.Name:match("WildPet_%w+_WildPet_(.+)")
                            local refPart = uuid and getRef(uuid)
                            if refPart and passFilter(refPart, pc) then
                                catchOne({ model=model, petName=model:GetAttribute("PetName") or model.Name, uuid=uuid }, pc, Net, root)
                                task.wait(0.5)
                            end
                        end
                    end
                end
                task.wait(interval)
            end
        end)
        print("[KV] Auto Pet Catch started")
    end

    function M.stop()
        M._running = false
        for _, c in ipairs(M._connections) do pcall(function() c:Disconnect() end) end
        M._connections = {}
    end

    function M.getStats() return M._stats end
end

-- =====================================================================
-- [22] MODULE: AUTO CENTER PLOT
-- =====================================================================

Modules.AutoCenterPlot = {}
do
    local Center = Modules.AutoCenterPlot
    Center._running = false

    function Center.start(config, Net, Utils_)
        if Center._running then return end
        Center._running = true
        task.spawn(function()
            task.wait(1)
            local hrp    = Utils_.getHumanoidRootPart()
            local garden = Utils_.getMyGarden()
            if hrp and garden then
                local totalPos, count = Vector3.new(0,0,0), 0
                for _, part in ipairs(CollectionSvc:GetTagged("PlantArea")) do
                    if part:IsA("BasePart") and part:IsDescendantOf(garden) then
                        totalPos = totalPos + part.Position; count += 1
                    end
                end
                if count > 0 then
                    pcall(function() hrp.CFrame = CFrame.new(totalPos/count + Vector3.new(0,3,0)) end)
                    print("[KV] Centered to soil")
                    Config.Notify("Centered!", "Teleport ke tengah plot berhasil", 3)
                end
            end
            Center._running = false
        end)
    end

    function Center.stop() Center._running = false end
end

-- =====================================================================
-- [23] MODULE: AUTO JOIN SERVER
-- =====================================================================

Modules.AutoJoinServer = {}
do
    local M = Modules.AutoJoinServer
    M._running = false; M._thread = nil
    M._stats = { teleports = 0, errors = 0 }

    function M.start(config, Net, Utils_)
        if M._running then return end
        M._running = true
        local sc = config.Server or {}
        local targetJobId = sc.TargetJobId or ""
        if targetJobId == "" then
            warn("[KV] AutoJoinServer: set TargetJobId dulu")
            M._running = false; return
        end
        if game.JobId == targetJobId then print("[KV] Sudah di server target"); return end
        M._thread = task.spawn(function()
            local LP_      = Utils_.getLocalPlayer()
            local maxRetry = sc.MaxRetries or 10
            local retries  = 0
            while M._running and retries < maxRetry do
                retries += 1
                if pcall(function() TeleportSvc:TeleportToPlaceInstance(game.PlaceId, targetJobId, LP_) end) then
                    M._stats.teleports += 1; task.wait(10)
                else
                    M._stats.errors += 1
                end
                task.wait(sc.RejoinDelay or 5)
            end
        end)
        print("[KV] AutoJoinServer -> " .. targetJobId)
    end

    function M.stop() M._running = false end
    function M.getStats() return M._stats end
end

-- =====================================================================
-- [24] ANTI-AFK
-- =====================================================================

task.spawn(function()
    LP.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end)

-- =====================================================================
-- [25] SERVER HOP
-- =====================================================================

local SHState = {
    Hopping    = false,
    AutoHop    = false,
    HopsDone   = 0,
    LastStatus = "Idle",
    AutoThread = nil,
}

local function fetchServers()
    local allServers = {}
    local cursor = ""; local pages = 0
    while pages < 5 do
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100%s",
            PlaceId, cursor ~= "" and ("&cursor=" .. cursor) or ""
        )
        local ok, raw = pcall(function() return HttpService:GetAsync(url) end)
        if not ok or not raw then break end
        local jOk, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if not jOk or not data then break end
        if not data.data or #data.data == 0 then break end
        for _, s in ipairs(data.data) do table.insert(allServers, s) end
        pages += 1
        cursor = data.nextPageCursor or ""
        if cursor == "" then break end
        task.wait(0.5)
    end
    return allServers
end

local function doHop()
    if SHState.Hopping then return end
    SHState.Hopping = true
    SHState.LastStatus = "Fetching servers..."
    local minP = Config.ServerHop.MinPlayers
    local maxP = Config.ServerHop.MaxPlayers
    for attempt = 1, 5 do
        SHState.LastStatus = string.format("Attempt %d/5...", attempt)
        local servers = fetchServers()
        if servers and #servers > 0 then
            local candidates = {}
            for _, s in ipairs(servers) do
                if s.id ~= CurrentJobId and s.playing < s.maxPlayers
                    and s.playing > 0 and s.playing >= minP
                    and (maxP == 0 or s.playing <= maxP) then
                    table.insert(candidates, s)
                end
            end
            if #candidates > 0 then
                local target = candidates[math.random(1, #candidates)]
                SHState.LastStatus = string.format("Hopping -> %s (%d players)", target.id:sub(1,8), target.playing)
                if pcall(function() TeleportSvc:TeleportToPlaceInstance(PlaceId, target.id, LP) end) then
                    SHState.HopsDone += 1
                    SHState.LastStatus = "Teleport pending..."
                    SHState.Hopping = false
                    return
                end
            end
        end
        task.wait(3)
    end
    SHState.LastStatus = "Failed after 5 attempts"
    SHState.Hopping = false
end

-- =====================================================================
-- [26] LIVE STATS
-- =====================================================================

local Stats = {
    startSheckles = 0,
    startTime     = os.clock(),
}

function Stats.init()
    Stats.startSheckles = Utils.getSheckles()
    Stats.startTime     = os.clock()
end

function Stats.getProfit()  return Utils.getSheckles() - Stats.startSheckles end
function Stats.getElapsed() return os.clock() - Stats.startTime end

function Stats.getPlantCount()
    local garden = Utils.getMyGarden()
    if not garden then return 0 end
    local pf = garden:FindFirstChild("Plants")
    return pf and #pf:GetChildren() or 0
end

function Stats.getBackpackInfo()
    local lp = Players.LocalPlayer
    local bp = lp and lp:FindFirstChild("Backpack")
    if not bp then return 0, 0, 0 end
    local total, seeds, fruits = 0, 0, 0
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            total += 1
            if tool:GetAttribute("SeedTool") then seeds += 1
            elseif tool:GetAttribute("FruitName") or tool:GetAttribute("IsFruit") then fruits += 1 end
        end
    end
    return total, seeds, fruits
end

function Stats.buildText()
    local sheckles  = Utils.getSheckles()
    local profit    = Stats.getProfit()
    local elapsed   = Stats.getElapsed()
    local plantCnt  = Stats.getPlantCount()
    local total, seeds, fruits = Stats.getBackpackInfo()
    local activeCount = 0
    for _, active in pairs(Running) do if active then activeCount += 1 end end
    local sign  = profit >= 0 and "+" or ""
    local emoji = profit >= 0 and "[+]" or "[-]"
    return string.format(
        "Sheckles : %s\n%s Profit : %s%s\nRuntime  : %s\nPlants   : %d\nItems    : %d (Seeds: %d, Fruits: %d)\nAktif    : %d modul",
        Utils.formatNumber(sheckles),
        emoji, sign, Utils.formatNumber(profit),
        Utils.formatTime(elapsed),
        plantCnt,
        total, seeds, fruits,
        activeCount
    )
end

Stats.init()

-- =====================================================================
-- [27] SEED / GEAR LISTS
-- =====================================================================

local AllSeeds = Resources.AllSeeds or {
    "Strawberry","Carrot","Blueberry","Tomato","Green Bean","Apple","Pineapple",
    "Corn","Banana","Cactus","Grape","Coconut","Tulip","Baby Cactus","Mango",
    "Pinetree","Thorn Rose","Dragon Fruit","Acorn","Horned Melon","Pumpkin",
    "Cherry","Glow Mushroom","Bamboo","Pomegranate","Poison Apple","Romanesco",
    "Poison Ivy","Sunflower","Beanstalk","Ghost Pepper","Venus Fly Trap",
    "Dragon's Breath","Lotus","Moon Bloom","Mushroom",
}

local AllGears = Resources.AllGears or {
    "Trowel","Speed Mushroom","Jump Mushroom","Common Watering Can",
    "Common Sprinkler","Sign","Shrink Mushroom","Supersize Mushroom","Flashbang",
    "Uncommon Sprinkler","Lantern","Teleporter","Rare Sprinkler","Gnome",
    "Basic Pot","Legendary Sprinkler","Super Watering Can","Super Sprinkler","Wheelbarrow",
}

-- =====================================================================
-- [28] DISCORD INFO
-- =====================================================================

local memberCount = "N/A"
local onlineCount = "N/A"

local function fetchDiscordInfo()
    local req = request or http_request or (syn and syn.request)
    if not req then return end
    local ok, result = pcall(function()
        return req({
            Url = "https://discord.com/api/v9/invites/XmWf3YQPpZ?with_counts=true",
            Method = "GET",
            Headers = { ["User-Agent"] = "Mozilla/5.0" }
        })
    end)
    if ok and result and result.StatusCode == 200 then
        local jOk, data = pcall(function() return HttpService:JSONDecode(result.Body) end)
        if jOk and data then
            memberCount = tostring(data.approximate_member_count  or "N/A")
            onlineCount = tostring(data.approximate_presence_count or "N/A")
        end
    end
end

fetchDiscordInfo()

-- =====================================================================
-- [29] WINDUI TABS
-- =====================================================================

-- ──────────────────────────────────────────────────────────────────────
-- INFO TAB
-- ──────────────────────────────────────────────────────────────────────
local InfoTab = Window:Tab({
    Title     = "Info",
    Icon      = "solar:info-square-bold",
    IconColor = Mains,
    IconShape = "Square",
    Border    = true,
})

local ServerInfo = InfoTab:Paragraph({
    Title = "King Vypers | Official",
    Desc  = "Member Count: " .. memberCount .. "\nOnline Count: " .. onlineCount,
    Image     = "rbxassetid://107726435417936",
    Thumbnail = "rbxassetid://83197533072664",
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
            Title    = "Refresh Info",
            Icon     = "refresh-cw",
            Callback = function()
                fetchDiscordInfo()
                ServerInfo:SetDesc("Member Count: " .. memberCount .. "\nOnline Count: " .. onlineCount)
            end
        }
    }
})

-- ──────────────────────────────────────────────────────────────────────
-- FARM TAB
-- ──────────────────────────────────────────────────────────────────────
local FarmTab = Window:Tab({
    Title     = "Farm",
    Icon      = "sprout",
    IconColor = Green,
    IconShape = "Square",
    Border    = true,
})

FarmTab:Section({ Title = "Auto Modules" })

FarmTab:Toggle({ Title = "Auto Harvest", Default = false,
    Callback = function(v) if v then startModule("AutoHarvest") else stopModule("AutoHarvest") end end })

FarmTab:Toggle({ Title = "Auto Sell", Default = false,
    Callback = function(v) if v then startModule("AutoSell") else stopModule("AutoSell") end end })

FarmTab:Toggle({ Title = "Auto Water", Default = false,
    Callback = function(v) if v then startModule("AutoWater") else stopModule("AutoWater") end end })

FarmTab:Toggle({ Title = "Auto Plant", Default = false,
    Callback = function(v) if v then startModule("AutoPlant") else stopModule("AutoPlant") end end })

FarmTab:Section({ Title = "Intervals" })

FarmTab:Slider({ Title = "Harvest Interval", Step = 0.1, Value = {Min = 0.1, Max = 10, Default = 0.2}, Suffix = "s",
    Callback = function(v) Config.Timings.HarvestInterval = v end })

FarmTab:Slider({ Title = "Sell Interval", Step = 1, Value = {Min = 1, Max = 30, Default = 5}, Suffix = "s",
    Callback = function(v) Config.Timings.SellInterval = v end })

FarmTab:Slider({ Title = "Water Interval", Step = 1, Value = {Min = 1, Max = 15, Default = 3}, Suffix = "s",
    Callback = function(v) Config.Timings.WaterInterval = v end })

FarmTab:Slider({ Title = "Plant Interval", Step = 1, Value = {Min = 1, Max = 15, Default = 5}, Suffix = "s",
    Callback = function(v) Config.Timings.PlantInterval = v end })

FarmTab:Section({ Title = "Water Config" })

FarmTab:Toggle({ Title = "Water Fully Grown", Default = false,
    Callback = function(v) Config.Water.WaterFullyGrown = v end })

FarmTab:Dropdown({ Title = "Required Can",
    Values = { "Any", "Common Watering Can", "Super Watering Can" }, Default = "Any",
    Callback = function(v) Config.Water.RequiredCan = (v == "Any") and "" or v end })

FarmTab:Section({ Title = "Plant Config" })

FarmTab:Dropdown({ Title = "Plant Order", Values = { "Top", "Bottom", "Random" }, Default = "Top",
    Callback = function(v) Config.Plant.PlantOrder = v end })

FarmTab:Slider({ Title = "Grid Spacing", Step = 0.5, Value = {Min = 2, Max = 8, Default = 3}, Suffix = " studs",
    Callback = function(v) Config.Plant.GridSpacing = v end })

FarmTab:Input({ Title = "Prefer Seed (kosong = bebas)", Default = "", Placeholder = "e.g. Carrot",
    Callback = function(v) Config.Plant.PreferSeed = (v ~= "" and v or nil) end })

FarmTab:Toggle({ Title = "Skip Mutated Seeds", Default = true,
    Callback = function(v) Config.Plant.BlacklistMutated = v end })

-- ──────────────────────────────────────────────────────────────────────
-- SHOP TAB
-- ──────────────────────────────────────────────────────────────────────
local ShopTab = Window:Tab({
    Title     = "Shop",
    Icon      = "shopping-cart",
    IconColor = Yellow,
    IconShape = "Square",
    Border    = true,
})

ShopTab:Section({ Title = "Restock Sniper" })

ShopTab:Toggle({ Title = "Enabled", Default = false,
    Callback = function(v) if v then startModule("RestockSniper") else stopModule("RestockSniper") end end })

ShopTab:Slider({ Title = "Poll Interval", Step = 0.5, Value = {Min = 0.5, Max = 5, Default = 1}, Suffix = "s",
    Callback = function(v) Config.Timings.RestockPollInterval = v end })

ShopTab:Dropdown({ Title = "Target Seeds (multi)", Values = AllSeeds, Default = "", Multi = true,
    Callback = function(v)
        Config.Restock.TargetSeeds = type(v) == "table" and v or (v ~= "" and {v} or {})
    end })

ShopTab:Dropdown({ Title = "Blacklist Seeds (multi)", Values = AllSeeds, Default = "", Multi = true,
    Callback = function(v)
        Config.Restock.BlacklistedSeeds = type(v) == "table" and v or (v ~= "" and {v} or {})
    end })

ShopTab:Section({ Title = "Gear Buyer" })

ShopTab:Toggle({ Title = "Enabled", Default = false,
    Callback = function(v) if v then startModule("GearBuyer") else stopModule("GearBuyer") end end })

ShopTab:Slider({ Title = "Poll Interval", Step = 1, Value = {Min = 1, Max = 10, Default = 2}, Suffix = "s",
    Callback = function(v) Config.Gear.PollInterval = v end })

ShopTab:Dropdown({ Title = "Target Gears (multi)", Values = AllGears, Default = "", Multi = true,
    Callback = function(v)
        Config.Gear.TargetGears = type(v) == "table" and v or (v ~= "" and {v} or {})
    end })

ShopTab:Section({ Title = "Inventory Optimizer" })

ShopTab:Toggle({ Title = "Enabled", Default = false,
    Callback = function(v) if v then startModule("InventoryOptimizer") else stopModule("InventoryOptimizer") end end })

ShopTab:Slider({ Title = "Check Interval", Step = 5, Value = {Min = 5, Max = 60, Default = 10}, Suffix = "s",
    Callback = function(v) Config.Timings.InventoryCheckInterval = v end })

ShopTab:Slider({ Title = "Favorite Threshold", Step = 100, Value = {Min = 100, Max = 100000, Default = 500}, Suffix = " $",
    Callback = function(v) Config.Inventory.FavoriteThreshold = v end })

ShopTab:Toggle({ Title = "Auto Promote Fruit", Default = true,
    Callback = function(v) Config.Inventory.AutoPromote = v end })

ShopTab:Section({ Title = "Auto Hatch Pet" })

ShopTab:Toggle({ Title = "Auto Hatch", Default = false,
    Callback = function(v) if v then startModule("AutoBuyPet") else stopModule("AutoBuyPet") end end })

ShopTab:Slider({ Title = "Hatch Interval", Step = 0.5, Value = {Min = 1, Max = 10, Default = 2}, Suffix = "s",
    Callback = function(v) Config.Timings.PetHatchInterval = v end })

ShopTab:Dropdown({ Title = "Min Rarity (Pet)",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super" }, Default = "Rare",
    Callback = function(v) Config.Pet.MinRarity = type(v) == "table" and v[1] or v end })

ShopTab:Toggle({ Title = "Auto Sell Unwanted", Default = false,
    Callback = function(v) Config.Pet.AutoSellUnwanted = v end })

-- ──────────────────────────────────────────────────────────────────────
-- EVENTS TAB
-- ──────────────────────────────────────────────────────────────────────
local EventsTab = Window:Tab({
    Title     = "Events",
    Icon      = "zap",
    IconColor = Purple,
    IconShape = "Square",
    Border    = true,
})

EventsTab:Section({ Title = "Mutation Tracker" })

EventsTab:Toggle({ Title = "Enabled", Default = false,
    Callback = function(v) if v then startModule("MutationTracker") else stopModule("MutationTracker") end end })

EventsTab:Slider({ Title = "Scan Interval", Step = 1, Value = {Min = 1, Max = 10, Default = 3}, Suffix = "s",
    Callback = function(v) Config.Timings.MutationScanInterval = v end })

EventsTab:Section({ Title = "Weather Bot" })

EventsTab:Toggle({ Title = "Enabled", Default = false,
    Callback = function(v) if v then startModule("WeatherBot") else stopModule("WeatherBot") end end })

EventsTab:Slider({ Title = "Poll Interval", Step = 1, Value = {Min = 1, Max = 15, Default = 5}, Suffix = "s",
    Callback = function(v) Config.Timings.WeatherPollInterval = v end })

EventsTab:Section({ Title = "Seed Pack Claimer" })

EventsTab:Toggle({ Title = "Auto Claim", Default = false,
    Callback = function(v) if v then startModule("SeedPackClaimer") else stopModule("SeedPackClaimer") end end })

EventsTab:Slider({ Title = "Poll Interval", Step = 0.5, Value = {Min = 0.5, Max = 5, Default = 2}, Suffix = "s",
    Callback = function(v) Config.Timings.SeedPackPollInterval = v end })

EventsTab:Section({ Title = "Wild Pet Catch" })

EventsTab:Toggle({ Title = "Auto Catch", Default = false,
    Callback = function(v) if v then startModule("AutoPetCatch") else stopModule("AutoPetCatch") end end })

EventsTab:Slider({ Title = "Scan Interval", Step = 1, Value = {Min = 1, Max = 15, Default = 3}, Suffix = "s",
    Callback = function(v) Config.Timings.PetCatchInterval = v end })

EventsTab:Dropdown({ Title = "Min Rarity (Wild)",
    Values = { "Common", "Uncommon", "Rare", "Legendary", "Mythic", "Super" }, Default = "Common",
    Callback = function(v) Config.PetCatch.MinRarity = type(v) == "table" and v[1] or v end })

EventsTab:Toggle({ Title = "Return After Catch", Default = true,
    Callback = function(v) Config.PetCatch.AutoReturn = v end })

EventsTab:Section({ Title = "Steal Bot (Night Only)" })

EventsTab:Toggle({ Title = "Enabled", Default = false,
    Callback = function(v) if v then startModule("StealBot") else stopModule("StealBot") end end })

EventsTab:Slider({ Title = "Steal Interval", Step = 0.5, Value = {Min = 0.5, Max = 5, Default = 1.5}, Suffix = "s",
    Callback = function(v) Config.Timings.StealInterval = v end })

EventsTab:Slider({ Title = "Max Steals / Night", Step = 5, Value = {Min = 5, Max = 100, Default = 20},
    Callback = function(v) Config.Steal.MaxAttemptsPerNight = v end })

EventsTab:Slider({ Title = "Min Fruit Value", Step = 1000, Value = {Min = 0, Max = 100000, Default = 10000}, Suffix = " $",
    Callback = function(v) Config.Steal.MinFruitValue = v end })

EventsTab:Section({ Title = "Auto Center Plot" })

EventsTab:Button({ Title = "Center to Soil (One-Shot)",
    Callback = function() startModule("AutoCenterPlot") end })

-- ──────────────────────────────────────────────────────────────────────
-- SERVER TAB
-- ──────────────────────────────────────────────────────────────────────
local ServerTab = Window:Tab({
    Title     = "Server",
    Icon      = "globe",
    IconColor = Blue,
    IconShape = "Square",
    Border    = true,
})

ServerTab:Section({ Title = "Current Server" })

ServerTab:Paragraph({
    Title = "Your JobId",
    Desc  = (game.JobId ~= "" and game.JobId or "N/A (Studio Mode)"),
})

ServerTab:Button({ Title = "Copy JobId", Callback = function()
    if setclipboard then setclipboard(game.JobId) end
    Config.Notify("Copied!", "JobId disalin ke clipboard", 3)
end })

ServerTab:Section({ Title = "Auto Join Target Server" })

ServerTab:Input({ Title = "Target JobId", Default = "", Placeholder = "Paste JobId server target...",
    Callback = function(v) Config.Server.TargetJobId = v end })

ServerTab:Toggle({ Title = "Auto Join Server", Default = false, Callback = function(v)
    if v then
        if Config.Server.TargetJobId == "" then
            Config.Notify("Error", "Set Target JobId dulu!", 5); return
        end
        startModule("AutoJoinServer")
    else
        stopModule("AutoJoinServer")
    end
end })

ServerTab:Slider({ Title = "Rejoin Delay", Step = 1, Value = {Min = 3, Max = 30, Default = 5}, Suffix = "s",
    Callback = function(v) Config.Server.RejoinDelay = v end })

ServerTab:Section({ Title = "Server Hop" })

ServerTab:Slider({ Title = "Min Players", Step = 1, Value = {Min = 0, Max = 20, Default = 1},
    Callback = function(v) Config.ServerHop.MinPlayers = v end })

ServerTab:Slider({ Title = "Max Players (0 = bebas)", Step = 1, Value = {Min = 0, Max = 20, Default = 0},
    Callback = function(v) Config.ServerHop.MaxPlayers = v end })

ServerTab:Slider({ Title = "Auto-Hop Interval", Step = 5, Value = {Min = 10, Max = 120, Default = 30}, Suffix = "s",
    Callback = function(v) Config.ServerHop.HopInterval = v end })

ServerTab:Button({ Title = "Hop Now", Callback = function()
    if not SHState.Hopping then task.spawn(doHop) end
end })

ServerTab:Toggle({ Title = "Auto-Hop", Default = false, Callback = function(v)
    SHState.AutoHop = v
    if v then
        if SHState.AutoThread then pcall(function() task.cancel(SHState.AutoThread) end) end
        SHState.AutoThread = task.spawn(function()
            while SHState.AutoHop do
                if not SHState.Hopping then task.spawn(doHop) end
                task.wait(Config.ServerHop.HopInterval or 30)
            end
        end)
    end
end })

-- ──────────────────────────────────────────────────────────────────────
-- STATUS TAB
-- ──────────────────────────────────────────────────────────────────────
local StatusTab = Window:Tab({
    Title     = "Status",
    Icon      = "activity",
    IconColor = Green,
    IconShape = "Square",
    Border    = true,
})

StatusTab:Section({ Title = "Live Session Stats" })

local StatsParagraph = StatusTab:Paragraph({
    Title = "Session Overview",
    Desc  = Stats.buildText(),
})

StatusTab:Section({ Title = "Global Controls" })

StatusTab:Button({ Title = "Enable All Modules", Callback = function()
    for n in pairs(Modules) do startModule(n) end
    Config.Notify("King Vypers", "Semua modul diaktifkan!", 3)
end })

StatusTab:Button({ Title = "Disable All Modules", Callback = function()
    for n in pairs(Modules) do stopModule(n) end
    Config.Notify("King Vypers", "Semua modul dimatikan!", 3)
end })

StatusTab:Button({ Title = "Refresh Stats Now", Callback = function()
    pcall(function() StatsParagraph:SetDesc(Stats.buildText()) end)
end })

-- Live auto-refresh setiap 2 detik
task.spawn(function()
    while true do
        pcall(function() StatsParagraph:SetDesc(Stats.buildText()) end)
        task.wait(2)
    end
end)

-- =====================================================================
-- [30] STARTUP
-- =====================================================================

-- Auto-restart modules setelah respawn
LP.CharacterAdded:Connect(function()
    task.wait(3)
    for name, active in pairs(Running) do
        if active then
            task.spawn(function()
                stopModule(name)
                task.wait(1)
                startModule(name)
            end)
        end
    end
end)

-- Global API via console
_G.KingVypers = {
    Config   = Config,
    Modules  = Modules,
    Net      = Networking,
    Utils    = Utils,
    start    = startModule,
    stop     = stopModule,
    toggle   = function(name)
        if Running[name] then stopModule(name) else startModule(name) end
    end,
    enableAll  = function() for n in pairs(Modules) do startModule(n)  end end,
    disableAll = function() for n in pairs(Modules) do stopModule(n) end end,
}

InfoTab:Select()

Config.Notify("King Vypers Loaded!", "Script aktif! Tap toggle button untuk buka UI.", 5)
print("================================================")
print("  King Vypers GAG2 Hub - Loaded!")
print("  Console API: _G.KingVypers")
print("================================================")
