local getinfo = getinfo or debug.getinfo
local DEBUG = false
local Hooked = {}

local Detected, Kill

setthreadidentity(2)

for i, v in getgc(true) do
    if typeof(v) == "table" then
        local DetectFunc = rawget(v, "Detected")
        local KillFunc = rawget(v, "Kill")

        if typeof(DetectFunc) == "function" and not Detected then
            Detected = DetectFunc

            local Old; Old = hookfunction(Detected, function(Action, Info, NoCrash)
                if Action ~= "_" then
                    if DEBUG then
                        warn(`Adonis AntiCheat flagged\nMethod: {Action}\nInfo: {Info}`)
                    end
                end

                return true
            end)

            table.insert(Hooked, Detected)
        end

        if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
            Kill = KillFunc
            local Old; Old = hookfunction(Kill, function(Info)
                if DEBUG then
                    warn(`Adonis AntiCheat tried to kill (fallback): {Info}`)
                end
            end)

            table.insert(Hooked, Kill)
        end
    end
end

local Old; Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local LevelOrFunc, Info = ...

    if Detected and LevelOrFunc == Detected then
        if DEBUG then
            warn(`zins | adonis bypassed`)
        end

        return coroutine.yield(coroutine.running())
    end

    return Old(...)
end))
setthreadidentity(7)

-- ── SESSION GUARD ────────────────────────────────────────────────
-- Matikan instance lama: flag di-set false dulu supaya semua loop milik
-- instance sebelumnya (yang ngecek isAlive) langsung break, baru sesi baru
-- daftar dengan id sendiri. Loop dari sesi lama otomatis mati karena
-- _G.KingVypersSession sudah beda.
if _G.KingVypersRunning then
    _G.KingVypersRunning = false
    task.wait(0.5)
end

local SESSION = tick()
_G.KingVypersRunning = true
_G.KingVypersSession = SESSION

-- Dipakai semua loop panjang: kalau false, loop-nya berhenti sendiri.
local function isAlive()
    return _G.KingVypersRunning == true and _G.KingVypersSession == SESSION
end

-- ── SNAPSHOT GUI SEBELUM VYPERS LOAD ─────────────────────────────
-- Catat semua GUI yang sudah ada SEBELUM UI dibuat, supaya kita TIDAK
-- salah hapus GUI milik game saat re-execute.
local function snapshotGuis(container)
    local names = {}
    pcall(function()
        for _, gui in ipairs(container:GetChildren()) do
            if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                names[gui] = true
            end
        end
    end)
    return names
end

local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local cg = game:GetService("CoreGui")
local pgBefore = snapshotGuis(pg)
local cgBefore = snapshotGuis(cg)

-- Hapus window lama kalau ada (dari execute sebelumnya)
pcall(function()
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:GetAttribute("VyperWindow") or gui.Name == "VypersUI" or gui.Name == "MachFishingButton" or gui.Name == "VypersOfficeHUD" then gui:Destroy() end
    end
end)
pcall(function()
    for _, gui in ipairs(cg:GetChildren()) do
        if gui:GetAttribute("VyperWindow") or gui.Name == "VypersUI" or gui.Name == "MachFishingButton" or gui.Name == "VypersOfficeHUD" then gui:Destroy() end
    end
end)

-- Tunggu game fully loaded sebelum apapun
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ================================================================
--  LOAD VYPERSLIB44  (UI baru)
-- ================================================================
local RAW_URL = "https://gitlab.com/kingvypers21/sukasukaaja/-/raw/main/VypersLib45.lua?ref_type=heads"
local Vypers  = loadstring(game:HttpGet(RAW_URL))()

-- Nonaktifkan print & warn untuk modul ini agar console tidak spam
local print = function(...) end
local warn  = function(...) end

-- ================================================================
--  COLORS  (dipakai juga oleh body script di bawah)
-- ================================================================
local Kings  = Color3.fromHex("#120324")
local Mains  = Color3.fromHex("#110029")
local Purple = Color3.fromHex("#7775F2")

-- ================================================================
--  SETUP GLOBAL VYPERS  (SEBELUM CreateWindow)
-- ================================================================
Vypers:SetFolder("KingVypers")
Vypers:SetAccent(Purple)
Vypers:SetTheme({
    Background   = Kings,
    Surface      = Mains,
})
Vypers:SetBuildBudget(4)   -- max 4ms kerja UI per frame -> game tetep smooth

-- ================================================================
--  LOADING SCREEN (dibuat SEBELUM CreateWindow)
-- ================================================================
local Loader = Vypers:CreateLoadingScreen({
    Title    = "King Vypers",
    SubTitle = "Menyiapkan antarmuka...",
    Accent   = Purple,
})
task.wait()   -- 1 frame biar loading screen kegambar dulu

-- ================================================================
--  WINDOW
-- ================================================================
local VWindow = Vypers:CreateWindow({
    Title           = "King Vypers",
    FloatIconRadius = 14,
    Icon            = "rbxassetid://107726435417936",    -- logo pas window di-minimize
    SubTitle        = "DDS V1.5",
    Background      = "rbxassetid://97514324988224",
    BackgroundTransparency = 0,
    Overlay         = 0.35,
    Size            = UDim2.new(0, 560, 0, 360),
    MinSize         = Vector2.new(480, 300),
    MaxSize         = Vector2.new(760, 500),
    SideBarWidth    = 150,
    Resizable       = true,
    Transparent     = false,

    SurfaceTransparency = 0.3,
    SectionTransparency = 0.3,
    TabTransparency     = 0.3,

    ItemColor    = Color3.fromRGB(40, 40, 60),
    SectionColor = Color3.fromRGB(28, 28, 44),
    TabColor     = Color3.fromRGB(34, 34, 52),
    WindowColor  = Kings,
    Accent       = Purple,

    ToggleKey   = Enum.KeyCode.RightShift,
    Deferred    = true,   -- build hidden, reveal setelah loading kelar
    Folder      = "KingVypers",
})

-- TAG DI TITLE BAR (pill kecil sebelah judul)
VWindow:Tag({ Title = "PREMIUM",       Color = Color3.fromRGB(220, 180, 70) })
VWindow:Tag({ Title = "Protected",     Color = Color3.fromRGB(80, 190, 120) })
VWindow:Tag({ Title = "VypersUI V0.4", Color = Purple })

-- ================================================================
--  ADAPTER WINDUI -> VYPERSLIB44
--  Semua element di bawah ini bikin element NATIVE VypersLib44,
--  tapi API-nya tetep gaya WindUI biar seluruh body script lama
--  (Toggle/Input/Dropdown/Paragraph/dll) jalan tanpa diubah.
-- ================================================================

-- ICON DIMATIKAN TOTAL
-- Semua opsi Icon / IconColor / IconShape dari kode lama diabaikan,
-- jadi tab & element tampil tanpa icon sama sekali.
local function mapIcon()
    return nil
end

-- ambil nilai default dari opts gaya WindUI (Value) maupun Vypers (Default)
local function pickDefault(opts)
    if opts.Value ~= nil then return opts.Value end
    return opts.Default
end

local function pickDesc(opts)
    return opts.Desc or opts.Description or opts.SubTitle
end

local idCounter = 0
local function autoId(prefix, title)
    idCounter = idCounter + 1
    return tostring(prefix or "el") .. "_" .. tostring(title or "item") .. "_" .. idCounter
end

-- ---- handle wrapper: nambahin API gaya WindUI ke handle native Vypers ----
local function wrapHandle(native, callback, kind)
    local h = { Type = kind, Instance = native.Instance, Native = native }

    function h:Get()  if native.Get then return native.Get() end end
    function h:Value() if native.Get then return native.Get() end end

    -- WindUI :Set() ikut nembak Callback (dipakai buat restore config)
    function h:Set(v, silent)
        if native.Set then pcall(native.Set, v) end
        if not silent and callback then pcall(callback, v) end
        return self
    end
    h.SetValue = h.Set

    function h:SetTitle(t) if native.SetTitle then native.SetTitle(t) end return self end
    function h:SetDesc(t)  if native.SetDesc  then native.SetDesc(t)  end return self end
    h.SetDescription = h.SetDesc
    function h:SetText(t)  if native.SetText  then native.SetText(t) elseif native.Set then native.Set(t) end return self end
    function h:Lock()   if native.Lock   then native.Lock()   end return self end
    function h:Unlock() if native.Unlock then native.Unlock() end return self end
    function h:Destroy() if native.Destroy then native.Destroy() end end
    function h:SetVisible(v) if native.Instance then native.Instance.Visible = v and true or false end return self end

    -- khusus dropdown
    function h:Refresh(list, default)
        if native.SetValues then pcall(native.SetValues, list, false) end
        if default ~= nil and native.Set then pcall(native.Set, default) end
        return self
    end
    h.SetOptions = h.Refresh
    h.SetValues  = h.Refresh
    function h:Select(v) return self:Set(v) end

    return h
end

-- ---- SECTION wrapper ----
local function wrapSection(nsec, ownerTitle)
    local S = { Native = nsec }

    function S:Toggle(o)
        o = o or {}
        local cb = o.Callback or function() end
        local nt = nsec:CreateToggle({
            Id = o.Id or autoId(ownerTitle, o.Title),
            Title = o.Title or "Toggle", Desc = pickDesc(o),
            Default = pickDefault(o) and true or false,
            Callback = cb,
        })
        return wrapHandle(nt, cb, "Toggle")
    end

    function S:Button(o)
        o = o or {}
        local cb = o.Callback or function() end
        local nt = nsec:CreateButton({
            Id = o.Id or autoId(ownerTitle, o.Title),
            Title = o.Title or "Button", Desc = pickDesc(o),
            Callback = cb,
        })
        return wrapHandle(nt, nil, "Button")
    end

    function S:ButtonRow(o)
        o = o or {}
        local list = {}
        for i, b in ipairs(o.Buttons or {}) do
            list[i] = { Title = b.Title, Color = b.Color, Callback = b.Callback }
        end
        return nsec:CreateButtonRow({ Buttons = list, Gap = o.Gap, Height = o.Height })
    end

    function S:Input(o)
        o = o or {}
        local cb = o.Callback or function() end
        local nt = nsec:CreateInput({
            Id = o.Id or autoId(ownerTitle, o.Title),
            Title = o.Title or "Input", Desc = pickDesc(o),
            Default = pickDefault(o) or "", Placeholder = o.Placeholder,
            Callback = cb,
        })
        return wrapHandle(nt, cb, "Input")
    end

    function S:Slider(o)
        o = o or {}
        local cb = o.Callback or function() end
        local step = o.Step or o.Increment or (o.Value and o.Value.Increment)
        local min, max, def = o.Min, o.Max, pickDefault(o)
        if type(o.Value) == "table" then
            min = min or o.Value.Min; max = max or o.Value.Max; def = o.Value.Default
        end
        if type(o.Step) == "table" then step = nil end
        local nt = nsec:CreateSlider({
            Id = o.Id or autoId(ownerTitle, o.Title),
            Title = o.Title or "Slider", Desc = pickDesc(o),
            Min = min or 0, Max = max or 100, Increment = step or 1,
            Default = def or min or 0, Suffix = o.Suffix,
            Callback = cb,
        })
        return wrapHandle(nt, cb, "Slider")
    end

    function S:Dropdown(o)
        o = o or {}
        local cb = o.Callback or function() end
        local nt = nsec:CreateDropdown({
            Id = o.Id or autoId(ownerTitle, o.Title),
            Title = o.Title or "Dropdown", Desc = pickDesc(o),
            Values = o.Options or o.Values or {},
            Default = pickDefault(o), Multi = o.Multi and true or false,
            AllowNone = o.AllowNone, Refresh = o.Refresh, RefreshInterval = o.RefreshInterval,
            Sidebar = o.Sidebar, SelectAll = o.SelectAll,
            Callback = cb,
        })
        return wrapHandle(nt, cb, "Dropdown")
    end

    function S:MultiDropdown(o)
        o = o or {}; o.Multi = true
        return S:Dropdown(o)
    end

    function S:Keybind(o)
        o = o or {}
        local cb = o.Callback or function() end
        local def = pickDefault(o)
        if type(def) == "string" and Enum.KeyCode[def] then def = Enum.KeyCode[def] end
        local nt = nsec:CreateKeybind({
            Id = o.Id or autoId(ownerTitle, o.Title),
            Title = o.Title or "Keybind", Desc = pickDesc(o),
            Default = def, Callback = cb,
        })
        return wrapHandle(nt, cb, "Keybind")
    end

    function S:Colorpicker(o)
        o = o or {}
        local cb = o.Callback or function() end
        local nt = nsec:CreateColorPicker({
            Id = o.Id or autoId(ownerTitle, o.Title),
            Title = o.Title or "Color", Desc = pickDesc(o),
            Default = pickDefault(o) or Color3.fromRGB(255, 255, 255),
            Callback = cb,
        })
        return wrapHandle(nt, cb, "Colorpicker")
    end
    S.ColorPicker = S.Colorpicker

    function S:Paragraph(o)
        o = o or {}
        local btns
        if type(o.Buttons) == "table" and #o.Buttons > 0 then
            btns = {}
            for i, b in ipairs(o.Buttons) do
                btns[i] = {
                    Title = b.Title, Callback = b.Callback,
                    Variant = b.Variant or (b.Color and "Primary" or "Secondary"),
                }
            end
        end
        local nt = nsec:CreateParagraph({
            Id = o.Id or autoId(ownerTitle, o.Title),
            Title = o.Title, Text = o.Desc or o.Content or o.Text or "",
            Image = o.Image, ImageHeight = o.ImageHeight, ImageScaleType = o.ImageScaleType,
            Thumbnail = o.Thumbnail, ThumbnailHeight = o.ThumbnailSize or o.ThumbnailHeight,
            Buttons = btns,
        })
        return wrapHandle(nt, nil, "Paragraph")
    end

    function S:Label(o)
        if type(o) == "string" then o = { Title = o } end
        o = o or {}
        return wrapHandle(nsec:CreateLabel({ Id = o.Id, Title = o.Title or "" }), nil, "Label")
    end

    function S:Code(o)
        o = o or {}
        return wrapHandle(nsec:CreateCode({ Id = o.Id, Title = o.Title, Code = o.Code or o.Text or "" }), nil, "Code")
    end

    function S:Tag(o)
        o = o or {}
        return wrapHandle(nsec:CreateTag({ Id = o.Id, Title = o.Title, Text = o.Text or o.Value, Color = o.Color }), nil, "Tag")
    end

    function S:Divider() return nsec:CreateDivider() end
    function S:Space(px) return nsec:CreateSpace(type(px) == "number" and px or 8) end
    function S:Developer(o) return nsec:CreateDeveloper(o or {}) end
    function S:Developers(o) return nsec:CreateDevelopers(o or {}) end

    function S:SetOpen(v) if nsec.SetOpen then nsec.SetOpen(v) end return S end
    function S:Open()  return S:SetOpen(true)  end
    function S:Close() return S:SetOpen(false) end
    function S:Section(o) return S end   -- WindUI kadang nested; balikin diri sendiri

    return S
end

-- ---- TAB wrapper ----
local ELEMENT_METHODS = {
    "Toggle", "Button", "ButtonRow", "Input", "Slider", "Dropdown", "MultiDropdown",
    "Keybind", "Colorpicker", "ColorPicker", "Paragraph", "Label", "Code", "Tag",
    "Divider", "Space", "Developer", "Developers",
}

local function wrapTab(ntab, title)
    local T = { Native = ntab, Title = title }
    local fallback

    local function defaultSection()
        if not fallback then
            fallback = wrapSection(ntab:CreateSection({
                Title = title or "General", Box = true, Opened = true,
            }), title)
        end
        return fallback
    end

    function T:Section(o)
        o = o or {}
        local ns = ntab:CreateSection({
            Title = o.Title or "Section",
            Box = (o.Box ~= false),
            Opened = (o.Opened ~= false),
            FontWeight = o.FontWeight,
        })
        return wrapSection(ns, o.Title or title)
    end
    T.CreateSection = T.Section

    -- element langsung di tab (tanpa section) -> otomatis masuk section default
    for _, name in ipairs(ELEMENT_METHODS) do
        T[name] = function(_, o)
            local sec = defaultSection()
            return sec[name](sec, o)
        end
    end

    function T:Select() if ntab.Activate then ntab.Activate() end return T end
    T.Activate = T.Select

    return T
end

-- ---- WINDOW wrapper (API gaya WindUI) ----
local Window = { Native = VWindow }
local tabBuilt = 0

function Window:Tab(o)
    o = o or {}
    tabBuilt = tabBuilt + 1
    pcall(function()
        Loader:Set(math.min(0.08 + tabBuilt * 0.11, 0.92), "Memuat " .. tostring(o.Title or "Tab"))
    end)
    local ntab = VWindow:CreateTab({ Title = o.Title or "Tab", Icon = mapIcon(o.Icon) })
    return wrapTab(ntab, o.Title)
end
Window.CreateTab = Window.Tab

-- WindUI "Tab Group" (Window:Section) -> di Vypers jadi grup tab biasa
function Window:Section(o)
    o = o or {}
    local G = { Title = o.Title }
    function G:Tab(oo)
        oo = oo or {}
        return Window:Tab(oo)
    end
    G.CreateTab = G.Tab
    function G:SetTitle() return G end
    return G
end

function Window:Tag(o) return VWindow:Tag(o or {}) end
function Window:Toggle() return VWindow:Toggle() end
function Window:Hide() return VWindow:Hide() end
function Window:Unhide() return VWindow:Unhide() end
function Window:Show() return VWindow:Show() end
function Window:IsHidden() return VWindow:IsHidden() end
function Window:SetToggleKey(k) return VWindow:SetToggleKey(k) end
function Window:Notify(o) return Vypers:Notify(o or {}) end
function Window:Dialog(o) return Vypers:Dialog(o or {}) end
function Window:Popup(o) return Vypers:Popup(o or {}) end
function Window:EditOpenButton() return Window end
function Window:SelectTab() return Window end
function Window:OnClose(fn) Window._onClose = fn return Window end
function Window:SetTitle() return Window end
function Window:Destroy() return VWindow:Hide() end

-- ---- WindUI global shim ----
local WindUI = { Vypers = Vypers, Themes = {} }

function WindUI:Notify(o)
    o = o or {}
    local t = o.Type
    if not t then
        local title = tostring(o.Title or "")
        if title:find("Gagal") or title:find("❌") then t = "error"
        elseif title:find("⚠") or title:find("Woi") then t = "warning"
        elseif title:find("✅") then t = "success"
        else t = "info" end
    end
    return Vypers:Notify({
        Title = o.Title or "King Vypers",
        Content = o.Content or o.Desc,
        Duration = o.Duration or 3,
        Type = t,
    })
end

function WindUI:Dialog(o) return Vypers:Dialog(o or {}) end
function WindUI:Popup(o) return Vypers:Popup(o or {}) end
function WindUI:AddTheme(t) if type(t) == "table" and t.Name then WindUI.Themes[t.Name] = t end return WindUI end
function WindUI:SetTheme() return WindUI end
function WindUI:SetFolder(f) Vypers:SetFolder(f) return WindUI end
function WindUI:CreateWindow() return Window end
function WindUI:SetNotificationLower() return WindUI end

-- ================================================================
--  BODY SCRIPT ASLI (semua fitur King Vypers) — TIDAK DIUBAH,
--  tapi sekarang jalan di atas VypersLib44 lewat adapter di atas.
-- ================================================================

-- ================================================================
--  CATATAN: tombol floating lama dari WindUI ("MachFishingButton")
--  sudah DIHAPUS. VypersLib44 sudah punya FloatIcon sendiri di kiri
--  bawah (muncul saat window di-minimize), jadi tombol lama itu cuma
--  bikin logo minimize kelihatan dobel: satu kiri atas, satu kiri bawah.
--  Buka/tutup window sekarang lewat FloatIcon atau toggle keybind.
-- ================================================================


-- Tag HANYA GUI baru yang muncul setelah Vyper dibuat (bukan snapshot lama)
task.defer(function()
    task.wait(0.5) -- beri waktu Vyper selesai bikin semua GUI-nya
    for _, gui in ipairs(pg:GetChildren()) do
        if not pgBefore[gui] and not gui:GetAttribute("VyperWindow") then
            gui:SetAttribute("VyperWindow", true)
        end
    end
    for _, gui in ipairs(cg:GetChildren()) do
        if not cgBefore[gui] and not gui:GetAttribute("VyperWindow") then
            -- Jangan tag GUI inti Roblox
            local n = gui.Name
            if not n:find("Roblox") and not n:find("Chat") and not n:find("TopBar") and not n:find("CoreGui") then
                gui:SetAttribute("VyperWindow", true)
            end
        end
    end
end)


local HttpService = game:GetService("HttpService")

-- =============================================
-- UNIVERSAL UI CONFIG AUTO-SAVE
-- =============================================


local function saveUIConfig(cfg) end

local uiConfig = {}
local isUILoading = true


local Players = game:GetService("Players")
Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local UIS = game:GetService("UserInputService")
local isMobileDevice = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- =============================================
-- =============================================
-- AUTO SKIP MAIN MENU (jalan otomatis saat execute)
-- Dipakai saat rejoin: HOME -> pilih Barista -> masuk game
-- =============================================

task.spawn(function()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    local mainMenu = playerGui:WaitForChild("mainMenuSystem", 10)
    if not mainMenu then return end
    if not mainMenu.Enabled then return end

    local mainUI = playerGui:FindFirstChild("MainUI")
    if mainUI and mainUI.Enabled then return end

    local baseFrame = mainMenu:FindFirstChild("baseFrame")
    if not baseFrame or not baseFrame.Visible then return end

    task.wait(1.5)

    local function clickBtn(btn)
        if not btn then return end
        pcall(function() firesignal(btn.MouseButton1Click) end)
        pcall(function() btn.MouseButton1Click:Fire() end)
        pcall(function() btn.Activated:Fire() end)
    end

    local applySelect = nil
    pcall(function()
        applySelect = baseFrame:FindFirstChild("homeFrame"):FindFirstChild("playFrame"):FindFirstChild("applySelect")
    end)
    clickBtn(applySelect)
    task.wait(1.5)

    local baristaBtn = nil
    pcall(function()
        baristaBtn = baseFrame:FindFirstChild("playFrame"):FindFirstChild("ScrollingFrame"):FindFirstChild("teamFiveTeamSelect")
    end)
    clickBtn(baristaBtn)
    task.wait(0.8)

    local deploySelect = nil
    pcall(function()
        deploySelect = baseFrame:FindFirstChild("playFrame"):FindFirstChild("deploySelect")
    end)
    clickBtn(deploySelect)

    local timeout = tick() + 30
    local entered = false
    while tick() < timeout do
        local mui = playerGui:FindFirstChild("MainUI")
        if mui and mui.Enabled then
            entered = true
            break
        end
        task.wait(0.5)
    end
    task.wait(3)

    if entered and baristaRunning == false and SpawnCar.SelectedCar and SpawnCar.SelectedCar ~= "Refresh dulu..." then
        task.spawn(startBaristaLoop)
    end
end)

-- HELPER: Ambil tombol Gas dari Interface
-- =============================================

local function getGasButton()
    local interface = LocalPlayer.PlayerGui:FindFirstChild("Interface")
    if not interface then return nil end
    local buttons = interface:FindFirstChild("Buttons")
    if not buttons then return nil end
    return buttons:FindFirstChild("Gas")
end

-- =============================================
-- VEHICLE SPEED MODULE
-- =============================================

local VehicleSpeed = {}
VehicleSpeed.Enabled = false
VehicleSpeed.CurrentSpeed = 100
VehicleSpeed.BoostActive = false
VehicleSpeed.BoostLoop = nil
VehicleSpeed.DecelActive = false
VehicleSpeed.DecelLoop = nil
VehicleSpeed.InputConn1 = nil
VehicleSpeed.InputConn2 = nil
VehicleSpeed._liveSpeed = 0

local function findMyMotor()
    local myName = LocalPlayer.Name
    for _, v in pairs(Workspace:GetChildren()) do
        if v.Name:match(myName) and v.Name:match("Montors") then
            return v
        end
    end
    return nil
end

local function getMotorPrimaryPart()
    local motor = findMyMotor()
    if not motor then return nil end
    return motor.PrimaryPart or motor:FindFirstChildWhichIsA("BasePart")
end

local function isRidingMotor()
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Sit == true and humanoid.SeatPart ~= nil
end

-- KEY FIX: Hanya override X dan Z, biarkan Y fisika game yang handle
local function applyVelocity(p, dir, targetSpeed, blend)
    local vel = p.AssemblyLinearVelocity
    local newX = vel.X + (dir.X * targetSpeed - vel.X) * blend
    local newZ = vel.Z + (dir.Z * targetSpeed - vel.Z) * blend
    -- Y TIDAK diubah sama sekali Ã¢â‚¬â€ biarkan physics engine yang handle gravity & suspensi
    p.AssemblyLinearVelocity = Vector3.new(newX, vel.Y, newZ)
end

local function stopDecelLoop()
    VehicleSpeed.DecelActive = false
    if VehicleSpeed.DecelLoop then
        task.cancel(VehicleSpeed.DecelLoop)
        VehicleSpeed.DecelLoop = nil
    end
end

local function startBoostLoop()
    stopDecelLoop()
    if VehicleSpeed.BoostActive then return end
    VehicleSpeed.BoostActive = true
    VehicleSpeed.BoostLoop = task.spawn(function()
        local currentSpeed = VehicleSpeed._liveSpeed
        local p = getMotorPrimaryPart()
        if p then
            local vel = p.AssemblyLinearVelocity
            local flatMag = Vector3.new(vel.X, 0, vel.Z).Magnitude
            currentSpeed = math.max(currentSpeed, flatMag)
        end

        while VehicleSpeed.BoostActive and VehicleSpeed.Enabled do
            if isRidingMotor() then
                p = getMotorPrimaryPart()
                if p then
                    local dir = -p.CFrame.LookVector
                    currentSpeed = currentSpeed + (VehicleSpeed.CurrentSpeed - currentSpeed) * 0.2
                    VehicleSpeed._liveSpeed = currentSpeed
                    applyVelocity(p, dir, currentSpeed, 0.35)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function stopBoostLoop()
    VehicleSpeed.BoostActive = false
    if VehicleSpeed.BoostLoop then
        task.cancel(VehicleSpeed.BoostLoop)
        VehicleSpeed.BoostLoop = nil
    end
    VehicleSpeed._liveSpeed = 0
end

function VehicleSpeed.Start()
    if VehicleSpeed.Enabled then return end
    VehicleSpeed.Enabled = true

    if isMobileDevice then
        task.spawn(function()
            local gasBtn = nil
            while VehicleSpeed.Enabled and not gasBtn do
                gasBtn = getGasButton()
                if not gasBtn then task.wait(0.5) end
            end
            if not gasBtn then return end

            VehicleSpeed.InputConn1 = gasBtn.MouseButton1Down:Connect(function()
                if VehicleSpeed.Enabled then startBoostLoop() end
            end)
            VehicleSpeed.InputConn2 = gasBtn.MouseButton1Up:Connect(function()
                if VehicleSpeed.Enabled then stopBoostLoop() end
            end)
        end)
    else
        VehicleSpeed.InputConn1 = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if not VehicleSpeed.Enabled then return end
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
                startBoostLoop()
            end
        end)
        VehicleSpeed.InputConn2 = UIS.InputEnded:Connect(function(input, gpe)
            if not VehicleSpeed.Enabled then return end
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
                if not UIS:IsKeyDown(Enum.KeyCode.W) and not UIS:IsKeyDown(Enum.KeyCode.Up) then
                    stopBoostLoop()
                end
            end
        end)
    end
end

function VehicleSpeed.Stop()
    if not VehicleSpeed.Enabled then return end
    VehicleSpeed.Enabled = false
    VehicleSpeed.BoostActive = false
    if VehicleSpeed.BoostLoop then task.cancel(VehicleSpeed.BoostLoop) VehicleSpeed.BoostLoop = nil end
    VehicleSpeed._liveSpeed = 0
    if VehicleSpeed.InputConn1 then VehicleSpeed.InputConn1:Disconnect() VehicleSpeed.InputConn1 = nil end
    if VehicleSpeed.InputConn2 then VehicleSpeed.InputConn2:Disconnect() VehicleSpeed.InputConn2 = nil end
end

function VehicleSpeed.SetSpeed(speed)
    VehicleSpeed.CurrentSpeed = speed
end

-- =============================================
-- SLOW RACE MODULE (Gradual Acceleration)
-- =============================================

local SlowRace = {}
SlowRace.Enabled = false
SlowRace.MaxSpeed = 200
SlowRace.AccelMultiplier = 3
SlowRace.BoostActive = false
SlowRace.BoostLoop = nil
SlowRace.DecelActive = false
SlowRace.DecelLoop = nil
SlowRace.InputConn1 = nil
SlowRace.InputConn2 = nil
SlowRace._liveSpeed = 0

local function stopSlowDecelLoop()
    SlowRace.DecelActive = false
    if SlowRace.DecelLoop then
        task.cancel(SlowRace.DecelLoop)
        SlowRace.DecelLoop = nil
    end
end

local function startSlowRaceLoop()
    stopSlowDecelLoop()
    if SlowRace.BoostActive then return end
    SlowRace.BoostActive = true
    SlowRace.BoostLoop = task.spawn(function()
        local currentSpeed = SlowRace._liveSpeed
        local p = getMotorPrimaryPart()
        if p then
            local vel = p.AssemblyLinearVelocity
            local flatMag = Vector3.new(vel.X, 0, vel.Z).Magnitude
            currentSpeed = math.max(currentSpeed, flatMag)
        end

        while SlowRace.BoostActive and SlowRace.Enabled do
            if isRidingMotor() then
                p = getMotorPrimaryPart()
                if p then
                    currentSpeed = math.min(
                        currentSpeed + (SlowRace.AccelMultiplier * 0.5),
                        SlowRace.MaxSpeed
                    )
                    SlowRace._liveSpeed = currentSpeed
                    local dir = -p.CFrame.LookVector
                    applyVelocity(p, dir, currentSpeed, 0.3)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function stopSlowRaceLoop()
    SlowRace.BoostActive = false
    if SlowRace.BoostLoop then
        task.cancel(SlowRace.BoostLoop)
        SlowRace.BoostLoop = nil
    end
    SlowRace._liveSpeed = 0
end

function SlowRace.Start()
    if SlowRace.Enabled then return end
    SlowRace.Enabled = true

    if isMobileDevice then
        task.spawn(function()
            local gasBtn = nil
            while SlowRace.Enabled and not gasBtn do
                gasBtn = getGasButton()
                if not gasBtn then task.wait(0.5) end
            end
            if not gasBtn then return end

            SlowRace.InputConn1 = gasBtn.MouseButton1Down:Connect(function()
                if SlowRace.Enabled then startSlowRaceLoop() end
            end)
            SlowRace.InputConn2 = gasBtn.MouseButton1Up:Connect(function()
                if SlowRace.Enabled then stopSlowRaceLoop() end
            end)
        end)
    else
        SlowRace.InputConn1 = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if not SlowRace.Enabled then return end
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
                startSlowRaceLoop()
            end
        end)
        SlowRace.InputConn2 = UIS.InputEnded:Connect(function(input, gpe)
            if not SlowRace.Enabled then return end
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
                if not UIS:IsKeyDown(Enum.KeyCode.W) and not UIS:IsKeyDown(Enum.KeyCode.Up) then
                    stopSlowRaceLoop()
                end
            end
        end)
    end
end

function SlowRace.Stop()
    if not SlowRace.Enabled then return end
    SlowRace.Enabled = false
    SlowRace.BoostActive = false
    if SlowRace.BoostLoop then task.cancel(SlowRace.BoostLoop) SlowRace.BoostLoop = nil end
    SlowRace._liveSpeed = 0
    if SlowRace.InputConn1 then SlowRace.InputConn1:Disconnect() SlowRace.InputConn1 = nil end
    if SlowRace.InputConn2 then SlowRace.InputConn2:Disconnect() SlowRace.InputConn2 = nil end
end

-- =============================================
-- SPAWN CAR MODULE
-- =============================================

local SpawnCar = {}
_G.SpawnCar = SpawnCar
SpawnCar.SelectedCar = nil
SpawnCar.CarList = {}
SpawnCar.AutoRide = false
SpawnCar.AutoRideAlways = false

local function exitMotor()
    local motor = findMyMotor()
    if not motor then return false end
    local char = LocalPlayer.Character
    if not char then return false end

    local anims = motor:FindFirstChild("Anims")
    if anims then
        pcall(function() anims:FireServer("RemovePlayer", char, nil) end)
        task.wait(0.3)
    end

    local driveSeat = motor:FindFirstChild("DriveSeat", true)
    if driveSeat then
        pcall(function() driveSeat:Sit(nil) end)
        task.wait(0.3)
    end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function() humanoid.Jump = true end)
    end

    return true
end

local function rideMotor()
    local motor = findMyMotor()
    if not motor then return false end

    local char = LocalPlayer.Character
    if not char then return false end

    local anims = motor:FindFirstChild("Anims")
    if anims then
        pcall(function() anims:FireServer("CreatePlayer", char) end)
        task.wait(0.2)
        pcall(function() anims:FireServer("RegisterPlayer", char) end)
        task.wait(0.2)
    end

    local kickstand = motor:FindFirstChild("Kickstand")
    if kickstand then
        pcall(function() kickstand:FireServer("StandUp", 0, 0, 0, 0, false) end)
        task.wait(0.2)
    end

    local driveSeat = motor:FindFirstChild("DriveSeat", true)
    if driveSeat then
        pcall(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = driveSeat.CFrame end
            driveSeat:Sit(char:FindFirstChildOfClass("Humanoid"))
        end)
    end
    return true
end

local function getCarList()
    local carNames = {}
    pcall(function()
        local mainUI = LocalPlayer.PlayerGui:WaitForChild("MainUI")
        local frame = mainUI:WaitForChild("Frame")
        local spawnBtn = mainUI:WaitForChild("Spawn"):WaitForChild("SpawnCar")
        frame.Visible = false
        firesignal(spawnBtn.MouseButton1Click)
        task.wait(2)
        local sf = frame:WaitForChild("MainFrame"):WaitForChild("ScrollingFrame")
        for _, v in ipairs(sf:GetChildren()) do
            if v.ClassName:sub(1,2) ~= "UI" then
                table.insert(carNames, v.Name)
            end
        end
        frame.Visible = false
    end)
    SpawnCar.CarList = carNames
    return #carNames > 0 and carNames or { "Refresh dulu..." }
end

function SpawnCar.Spawn()
    if not SpawnCar.SelectedCar or SpawnCar.SelectedCar == "Refresh dulu..." then return end
    local ok = pcall(function()
        ReplicatedStorage:WaitForChild("SpawnCarEvents"):WaitForChild("SpawnCar"):FireServer(SpawnCar.SelectedCar)
    end)
    if ok and SpawnCar.AutoRide then
        task.spawn(function()
            task.wait(4)
            rideMotor()
        end)
    end
end

function SpawnCar.Despawn()
    pcall(function()
        ReplicatedStorage:WaitForChild("SpawnCarEvents"):WaitForChild("DespawnCar"):FireServer()
    end)
end

local autoRideLoop = nil
function SpawnCar.StartAutoRideAlways()
    if autoRideLoop then return end
    autoRideLoop = task.spawn(function()
        while SpawnCar.AutoRideAlways do
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and not humanoid.Sit and findMyMotor() then
                rideMotor()
            end
            task.wait(2)
        end
        autoRideLoop = nil
    end)
end

function SpawnCar.StopAutoRideAlways()
    SpawnCar.AutoRideAlways = false
    if autoRideLoop then task.cancel(autoRideLoop) autoRideLoop = nil end
end

-- =============================================
-- =============================================
-- AUTO JOB BARISTA MODULE
-- =============================================

-- =============================================
-- AUTO JOB COURIER MODULE
-- =============================================
-- =================================================================
-- DATA KOORDINAT (MANUAL SPOTS)
-- =================================================================
local PackageData = {
    ["1"] = {
        Tween     = CFrame.new(Vector3.new(-6794.09, 3.23, -454.48), Vector3.new(-6794.09, 3.23, -454.48) + Vector3.new(0.0649, 0, 0.9979)),
        Walk      = Vector3.new(-6794.78, 3.23, -445.22),
        WalkLook  = Vector3.new(-0.1029, 0, 0.9947),
        AfterLook = Vector3.new(0.0865, 0, -0.9963),
        Camera    = CFrame.new(Vector3.new(-6793.75, 11.23, -455.17), Vector3.new(-6794.88, 3.23, -444.23)),
    },
    ["2"] = {
        Tween     = CFrame.new(Vector3.new(-8401.35, 2.76, -3819.80), Vector3.new(-8401.35, 2.76, -3819.80) + Vector3.new(1, 0, -0.0087)),
        Walk      = Vector3.new(-8383.13, 2.19, -3819.85),
        WalkLook  = Vector3.new(0.9998, 0, -0.0175),
        AfterLook = Vector3.new(-0.9971, 0, -0.0764),
        Camera    = CFrame.new(Vector3.new(-8393.13, 10.19, -3819.68), Vector3.new(-8382.13, 2.19, -3819.87)),
    },
    ["3"] = {
        Tween     = CFrame.new(Vector3.new(-8788.36, 2.54, 652.26), Vector3.new(-8788.36, 2.54, 652.26) + Vector3.new(0.8879, 0, -0.4600)),
        Walk      = Vector3.new(-8776.65, 3.15, 645.71),
        WalkLook  = Vector3.new(0.8627, 0, -0.5057),
        AfterLook = Vector3.new(-0.8474, 0, 0.5310),
        Camera    = CFrame.new(Vector3.new(-8786.53, 8.41, 652.19), Vector3.new(-8785.83, 8.01, 651.61)),
    },
    ["4"] = {
        Tween     = CFrame.new(Vector3.new(714.63, 3.24, -3980.11), Vector3.new(714.63, 3.24, -3980.11) + Vector3.new(0.0438, 0, 0.9990)),
        Walk      = Vector3.new(715.22, 3.24, -3961.31),
        WalkLook  = Vector3.new(0.0312, 0, 0.9995),
        AfterLook = Vector3.new(-0.0312, 0, -0.9995),
        Camera    = CFrame.new(Vector3.new(714.91, 11.24, -3971.31), Vector3.new(715.25, 3.24, -3960.31)),
    },
    ["5"] = {
        Tween     = CFrame.new(Vector3.new(-6745.15, 3.76, 2964.32), Vector3.new(-6745.15, 3.76, 2964.32) + Vector3.new(0.4324, 0, 0.9017)),
        Walk      = Vector3.new(-6739.83, 3.76, 2974.46),
        WalkLook  = Vector3.new(0.4652, 0, 0.8852),
        AfterLook = Vector3.new(-0.5570, 0, -0.8305),
        Camera    = CFrame.new(Vector3.new(-6744.48, 11.76, 2965.61), Vector3.new(-6739.36, 3.76, 2975.35)),
    },
    ["6"] = {
        Tween     = CFrame.new(Vector3.new(-3343.03, 31.66, -8173.29), Vector3.new(-3343.03, 31.66, -8173.29) + Vector3.new(-0.3950, 0, 0.9187)),
        Walk      = Vector3.new(-3351.09, 29.90, -8156.99),
        WalkLook  = Vector3.new(-0.4268, 0, 0.9043),
        AfterLook = Vector3.new(0.3799, 0, -0.9250),
        Camera    = CFrame.new(Vector3.new(-3346.82, 37.90, -8166.03), Vector3.new(-3351.52, 29.90, -8156.09)),
    },
    ["7"] = {
        Tween     = CFrame.new(Vector3.new(-9980.91, 3.38, -4056.40), Vector3.new(-9980.91, 3.38, -4056.40) + Vector3.new(0.9826, 0, 0.1855)),
        Walk      = Vector3.new(-9963.65, 3.38, -4053.40),
        WalkLook  = Vector3.new(0.9905, 0, 0.1375),
        AfterLook = Vector3.new(-0.9853, 0, -0.1707),
        Camera    = CFrame.new(Vector3.new(-9973.56, 11.38, -4054.77), Vector3.new(-9962.66, 3.38, -4053.26)),
    },
    ["8"] = {
        Tween     = CFrame.new(Vector3.new(-17039.63, 104.47, 6560.34), Vector3.new(-17039.63, 104.47, 6560.34) + Vector3.new(-0.8874, 0, 0.4610)),
        Walk      = Vector3.new(-17053.56, 105.04, 6567.01),
        WalkLook  = Vector3.new(-0.8930, 0, 0.4501),
        AfterLook = Vector3.new(0.7705, 0, -0.6375),
        Camera    = CFrame.new(Vector3.new(-17044.63, 113.04, 6562.51), Vector3.new(-17054.45, 105.04, 6567.46)),
    },
}

-- =================================================================
-- SHARED STATE
-- =================================================================
local CourierJob = { Name = "Courier", TeamId = 11378976, X = -5158.57, Y = 4.41, Z = -3757.87 }
local courierRunning   = false
local ServiceEventConn = nil
local TWEEN_DURATION   = 60
local uangAwalCourier = nil
local totalCourierCycle = 0
local sendCourierWebhook


-- =================================================================
-- HELPERS
-- =================================================================

local function jumpAndWait()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait(0.3)

    local t = tick()
    while tick() - t < 3 do
        local state = hum:GetState()
        if state ~= Enum.HumanoidStateType.Jumping
        and state ~= Enum.HumanoidStateType.Freefall then
            break
        end
        task.wait(0.1)
    end
    task.wait(0.2)
end

local function faceDirection(lookVec)
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos    = hrp.Position
    local target = pos + Vector3.new(lookVec.X, 0, lookVec.Z)
    hrp.CFrame = CFrame.new(pos, target)
end

local function setCameraBehindPlayer()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local back   = hrp.CFrame.LookVector * -10
    local camPos = hrp.Position + back + Vector3.new(0, 5, 0)
    local lookAt = hrp.Position + hrp.CFrame.LookVector * 5
    cam.CFrame = CFrame.new(camPos, lookAt)
end

local function lookToDirection(lookVec)
    faceDirection(lookVec)
    task.wait(0.3)
end

local function findCourierMotor()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, closestDist = nil, 50
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("DriveSeat", true) then
            local mp = model.PrimaryPart
            if mp and (mp.Position - hrp.Position).Magnitude < closestDist then
                closestDist = (mp.Position - hrp.Position).Magnitude
                closest     = model
            end
        end
    end
    return closest
end

local function rideCourierMotor()
    local motor = findCourierMotor()
    if not motor then return end
    local char      = LocalPlayer.Character
    local driveSeat = motor:FindFirstChild("DriveSeat", true)
    if driveSeat then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = driveSeat.CFrame end
        driveSeat:Sit(char:FindFirstChildOfClass("Humanoid"))
    end
    task.wait(0.5)
end

local function _tweenVehicle(vehicle, targetCFrame, duration)
    local TweenService = game:GetService("TweenService")

    local mainPart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
    if not mainPart then return end

    local parts = {}
    local originalAnchored = {}
    local tempWelds = {}

    for _, part in ipairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
            originalAnchored[part] = part.Anchored
        end
    end

    -- Anchor mainPart, unanchor sisanya dan pasang WeldConstraint sementara
    mainPart.Anchored = true
    for _, part in ipairs(parts) do
        if part ~= mainPart then
            part.Anchored = false
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = mainPart
            weld.Part1 = part
            weld.Parent = mainPart
            table.insert(tempWelds, weld)
        end
    end

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(mainPart, tweenInfo, { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Wait()

    -- Hapus weld sementara
    for _, weld in ipairs(tempWelds) do
        weld:Destroy()
    end

    -- Kembalikan state awal dan amankan physics
    for _, part in ipairs(parts) do
        pcall(function()
            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
        part.Anchored = originalAnchored[part] or false
    end
end

local function walkToAndFace(hum, char, targetPos, lookVec, radiusOK)
    radiusOK = radiusOK or 4

    for attempt = 1, 10 do
        if not courierRunning then break end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then break end

        local dist = (hrp.Position - targetPos).Magnitude
        if dist <= radiusOK then
            print("[Courier] Sudah di lokasi! (dist: " .. math.floor(dist) .. ")")
            break
        end

        faceDirection(lookVec)

        print("[Courier] Walk attempt #" .. attempt .. " | dist: " .. math.floor(dist))
        hum:MoveTo(targetPos)

        local t = tick()
        repeat
            task.wait(0.1)
            hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then break end
        until not courierRunning
            or (hrp and (hrp.Position - targetPos).Magnitude <= radiusOK)
            or (tick() - t >= 8)
    end

    lookToDirection(lookVec)
end

local function stopCourierLoop()
    courierRunning = false
    if ServiceEventConn then ServiceEventConn:Disconnect() ServiceEventConn = nil end
    local cam = Workspace.CurrentCamera
    if cam then cam.CameraType = Enum.CameraType.Custom end
    print("[Courier] Stopped.")
end

-- =================================================================
-- MAIN COURIER LOOP
-- =================================================================
local function startCourierLoop()
    local job = CourierJob
    if courierRunning then return end
    courierRunning = true
    print("[Courier] Loop Dimulai - Manual Spot Mode")

    local activePackageNum = nil

    local serviceEvent = ReplicatedStorage:FindFirstChild("ServiceEvent", true)
    if serviceEvent then
        ServiceEventConn = serviceEvent.OnClientEvent:Connect(function(eventName, action, paketNum)
            if action == "Create" then
                activePackageNum = tostring(paketNum)
                print("[Courier] Paket #" .. activePackageNum .. " Terdeteksi!")
            elseif action == "Remove" then
                if activePackageNum == tostring(paketNum) then activePackageNum = nil end
            end
        end)
    end

    pcall(function() ReplicatedStorage:WaitForChild("JobEvents"):WaitForChild("TeamChangeRequest"):FireServer("Courier", 11378976, 0, 0, "Detector") end)
    task.wait(1.5)

    local SELECTED_CAR = SpawnCar.SelectedCar or "Yamahax-MioSporty"

    -- Spawn Awal & Ambil Paket Pertama
    pcall(function() ReplicatedStorage:WaitForChild("SpawnCarEvents"):WaitForChild("SpawnCar"):FireServer(SELECTED_CAR) end)
    task.wait(5)
    rideCourierMotor()
    task.wait(1)
    local motor = findCourierMotor()
    if motor then
        print("[Courier] Tweening ke spot start job...")
        _tweenVehicle(motor, CFrame.new(job.X, job.Y, job.Z), TWEEN_DURATION)
    end
    task.wait(0.5)

    jumpAndWait()

    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:MoveTo(Vector3.new(-5109.06, 5.18, -3758.69))
        task.wait(3)

        setCameraBehindPlayer()
        task.wait(0.5)

        pcall(function()
            local prompt = Workspace.Livrason.Take1.Take.ProximityPrompt
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.1)
            prompt:InputHoldEnd()
        end)

        local cam = Workspace.CurrentCamera
        if cam then cam.CameraType = Enum.CameraType.Custom end
    end
    task.wait(2)

    -- =============================================================
    -- LOOP ANTAR PAKET
    -- =============================================================
    while courierRunning do
        while courierRunning and not activePackageNum do task.wait(0.5) end
        if not courierRunning then break end

        local data = PackageData[activePackageNum]
        if not data then
            warn("[Courier] Data koordinat untuk paket #" .. activePackageNum .. " tidak ditemukan!")
            activePackageNum = nil
            continue
        end

        -- 1. Cari motor yang ada dulu, kalau tidak ada baru spawn
        print("[Courier] Cek motor untuk paket #" .. activePackageNum)
        local existingMotor = findCourierMotor()
        if existingMotor then
            print("[Courier] Motor ditemukan, langsung naik!")
            rideCourierMotor()
            task.wait(1)
        else
            print("[Courier] Motor tidak ada, spawn baru...")
            pcall(function() ReplicatedStorage:WaitForChild("SpawnCarEvents"):WaitForChild("SpawnCar"):FireServer(SELECTED_CAR) end)
            task.wait(4)
            rideCourierMotor()
            task.wait(1)
        end

        -- 2. Tween ke Spot Teleport
        local currentMotor = findCourierMotor()
        if currentMotor then
            print("[Courier] Tweening ke spot aman paket #" .. activePackageNum)
            _tweenVehicle(currentMotor, data.Tween, TWEEN_DURATION)
        end

        -- 3. Sampai di lokasi tween → wait 2 detik → jump keluar kendaraan
        print("[Courier] Tiba di spot, wait 2 detik lalu jump keluar...")
        task.wait(2)
        jumpAndWait()
        print("[Courier] Sudah keluar kendaraan, mulai walk!")

        -- 4. Walk ke lokasi paket
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            print("[Courier] Walking ke titik paket #" .. activePackageNum)
            walkToAndFace(hum, char, data.Walk, data.WalkLook, 4)
        end
        task.wait(0.3)

        -- 5. Rotate player ke arah paket, set kamera sesuai data.Camera, wait 1 detik
        print("[Courier] Rotate player + set kamera khusus paket, wait 1 detik...")
        faceDirection(data.WalkLook)
        task.wait(0.5)

        local cam = Workspace.CurrentCamera
        if cam and data.Camera then
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = data.Camera
        end

        task.wait(1)

        -- 6. Hold paket setelah dipastikan sudah di lokasi
        local currentPackage = activePackageNum
        print("[Courier] Mencoba hold paket #" .. currentPackage)

        while courierRunning and activePackageNum == currentPackage do
            pcall(function()
                local LocationFolder = Workspace.Livrason.Location
                local paketModel     = LocationFolder:FindFirstChild(currentPackage)
                local block          = paketModel and paketModel:FindFirstChild("Block")
                if block then
                    local prompt = block:FindFirstChild("ProximityPrompt")
                    if prompt then
                        local box = LocalPlayer.Backpack:FindFirstChild("Box") or char:FindFirstChild("Box")
                        if box and hum then hum:EquipTool(box) task.wait(0.3) end
                        prompt:InputHoldBegin()
                        task.wait(prompt.HoldDuration + 0.1)
                        prompt:InputHoldEnd()
                    end
                end
            end)
            task.wait(1)
        end

        -- Kembalikan kamera ke normal
        if cam then cam.CameraType = Enum.CameraType.Custom end

        -- 6. Look ke arah AfterLook
        print("[Courier] Memutar arah sebelum spawn kendaraan...")
        lookToDirection(data.AfterLook)

        print("[Courier] Paket #" .. currentPackage .. " Selesai!")
        totalCourierCycle = totalCourierCycle + 1

        task.wait(3)
        if sendCourierWebhook then pcall(sendCourierWebhook) end

        task.wait(1)
    end

    stopCourierLoop()
end


-- CINEMATIC MODULE
-- =============================================
local cinemaPlayer = Players.LocalPlayer
local cinemaCamera = workspace.CurrentCamera

local SHOTS = {
    { name = "Sorot depan motor",     targetPart = "chassis",        offset = Vector3.new(0, 1.5, -12),   fov = 40, duration = 7 },
    { name = "Close up roda depan",   targetPart = "ban",            offset = Vector3.new(3, 1, -2),      fov = 28, duration = 7 },
    { name = "Velg roda depan",       targetPart = "RIMS",           offset = Vector3.new(3, 0.5, -1),    fov = 22, duration = 7 },
    { name = "Roda belakang",         targetPart = "ban.001",        offset = Vector3.new(-3, 1, 2),      fov = 28, duration = 7 },
    { name = "Body & Tangki",         targetPart = "PAINT",          offset = Vector3.new(4, 2.5, 0),     fov = 38, duration = 7 },
    { name = "Jok motor",             targetPart = "jok",            offset = Vector3.new(3, 2, 0),       fov = 30, duration = 7 },
    { name = "Dek depan",             targetPart = "dekdepan",       offset = Vector3.new(3, 1.5, -2),    fov = 28, duration = 7 },
    { name = "Dek belakang",          targetPart = "DDS_RearFender", offset = Vector3.new(-3, 1.5, 2),    fov = 28, duration = 7 },
    { name = "Lampu depan",           targetPart = "refdepan",       offset = Vector3.new(0, 1, -5),      fov = 22, duration = 7 },
    { name = "Lampu belakang",        targetPart = "stoplamp",       offset = Vector3.new(0, 1, -5),       fov = 22, duration = 7 },
    { name = "Spion",                 targetPart = "SPION",          offset = Vector3.new(0, 2, -3),      fov = 25, duration = 7 },
    { name = "Dashboard speedometer", targetPart = "dashboard",      offset = Vector3.new(0, 2.5, -3),    fov = 22, duration = 7 },
    { name = "Stang motor",           targetPart = "stang",          offset = Vector3.new(0, 2.5, -3),    fov = 25, duration = 7 },
    { name = "Mesin",                 targetPart = "mesineee",       offset = Vector3.new(3, 0.5, 1),     fov = 28, duration = 7 },
    { name = "Knalpot silencer",      targetPart = "silencer",       offset = Vector3.new(-4, 1, 2),      fov = 25, duration = 7 },
    { name = "Knalpot",               targetPart = "knalpot",        offset = Vector3.new(-3, 0.5, 1),    fov = 22, duration = 7 },
    { name = "Plat depan",            targetPart = "Plat",           offset = Vector3.new(0, 1, -3),      fov = 20, duration = 7 },
    { name = "Hero shot samping",     targetPart = "chassis",        offset = Vector3.new(12, 4, 0),      fov = 45, duration = 7 },
    { name = "Hero shot depan",       targetPart = "chassis",        offset = Vector3.new(0, 3, -12),     fov = 45, duration = 7 },
    { name = "Hero shot atas",        targetPart = "chassis",        offset = Vector3.new(0, 15, 0),      fov = 50, duration = 7 },
}

local DRIFT_PATTERNS = {
    Vector3.new( 0.8,  0.3,  0),
    Vector3.new(-0.8,  0.2,  0),
    Vector3.new( 0,    0.5, -0.4),
    Vector3.new( 0.5, -0.2,  0.3),
    Vector3.new(-0.5,  0.4, -0.3),
}

local function getCinemaMotor()
    local username = cinemaPlayer.Name
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:find(username, 1, true) then
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("VehicleSeat") then return obj end
            end
        end
    end
    return nil
end

local function findCinemaPart(motor, partName)
    local best, bestMag = nil, 0
    for _, part in ipairs(motor:GetDescendants()) do
        if part.Name == partName and part:IsA("BasePart") then
            local m = part.Size.Magnitude
            if m > bestMag then best = part; bestMag = m end
        end
    end
    if not best then
        for _, part in ipairs(motor:GetDescendants()) do
            if part.Name == "chassis" and part:IsA("BasePart") then return part end
        end
    end
    return best
end

local function easeInOutSine(t)
    return -(math.cos(math.pi * t) - 1) / 2
end

local hiddenUIs = {}

local function hideAllUI()
    hiddenUIs = {}
    for _, gui in ipairs(cinemaPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
            table.insert(hiddenUIs, { gui = gui, enabled = gui.Enabled })
            gui.Enabled = false
        end
    end
    local StarterGui = game:GetService("StarterGui")
    for _, item in ipairs({
        Enum.CoreGuiType.Backpack,
        Enum.CoreGuiType.Chat,
        Enum.CoreGuiType.Health,
        Enum.CoreGuiType.PlayerList,
        Enum.CoreGuiType.EmotesMenu,
    }) do
        pcall(function() StarterGui:SetCoreGuiEnabled(item, false) end)
    end
end

local function showAllUI()
    for _, data in ipairs(hiddenUIs) do
        if data.gui and data.gui.Parent then
            data.gui.Enabled = data.enabled
        end
    end
    hiddenUIs = {}
    local StarterGui = game:GetService("StarterGui")
    for _, item in ipairs({
        Enum.CoreGuiType.Backpack,
        Enum.CoreGuiType.Chat,
        Enum.CoreGuiType.Health,
        Enum.CoreGuiType.PlayerList,
        Enum.CoreGuiType.EmotesMenu,
    }) do
        pcall(function() StarterGui:SetCoreGuiEnabled(item, true) end)
    end
end

local cinematicRunning = false

local function playCinematic()
    if cinematicRunning then return end
    local motor = getCinemaMotor()
    if not motor then
        -- warn("Motor ga ketemu! Spawn motor dulu bro.")
        return
    end

    cinematicRunning = true
    hideAllUI()

    cinemaCamera.CameraType = Enum.CameraType.Scriptable

    local initPart = findCinemaPart(motor, SHOTS[1].targetPart)
    if initPart then
        local motorCF = motor:GetBoundingBox()
        local initOffset = motorCF:VectorToWorldSpace(SHOTS[1].offset)
        cinemaCamera.CFrame = CFrame.new(initPart.Position + initOffset, initPart.Position)
        cinemaCamera.FieldOfView = SHOTS[1].fov
    end

    for i, shot in ipairs(SHOTS) do
        if not cinematicRunning then break end

        local targetPart = findCinemaPart(motor, shot.targetPart)
        if not targetPart then
            -- warn("Skip: " .. shot.targetPart)
            continue
        end


        local motorCF = motor:GetBoundingBox()
        local worldOffset = motorCF:VectorToWorldSpace(shot.offset)
        local partPos = targetPart.Position
        local shotTargetCF = CFrame.new(partPos + worldOffset, partPos)

        local transStart = cinemaCamera.CFrame
        local transElapsed = 0
        local transDone = false
        local transConn

        game:GetService("TweenService"):Create(cinemaCamera,
            TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { FieldOfView = shot.fov }
        ):Play()

        transConn = game:GetService("RunService").RenderStepped:Connect(function(dt)
            transElapsed = transElapsed + dt
            local alpha = math.min(transElapsed / 3, 1)
            local smooth = easeInOutSine(alpha)
            cinemaCamera.CFrame = transStart:Lerp(shotTargetCF, smooth)
            if alpha >= 1 then transDone = true; transConn:Disconnect() end
        end)
        repeat task.wait(0.05) until transDone

        local holdTime = shot.duration - 3
        local holdElapsed = 0
        local driftDir = DRIFT_PATTERNS[(i - 1) % #DRIFT_PATTERNS + 1]
        local holdDone = false
        local holdConn

        holdConn = game:GetService("RunService").RenderStepped:Connect(function(dt)
            holdElapsed = holdElapsed + dt
            local driftProgress = math.sin(holdElapsed * 0.4)
            local driftOffset = driftDir * driftProgress * 1.5
            local currentPartPos = targetPart.Position
            local driftedCamPos = (partPos + worldOffset) + driftOffset
            local driftCF = CFrame.new(driftedCamPos, currentPartPos)
            cinemaCamera.CFrame = cinemaCamera.CFrame:Lerp(driftCF, 0.02)
            if holdElapsed >= holdTime then
                holdDone = true
                holdConn:Disconnect()
            end
        end)
        repeat task.wait(0.05) until holdDone
    end

    game:GetService("TweenService"):Create(cinemaCamera,
        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        { FieldOfView = 70 }
    ):Play()
    task.wait(2)
    cinemaCamera.CameraType = Enum.CameraType.Custom

    showAllUI()
    cinematicRunning = false
end

local function stopCinematic()
    cinematicRunning = false
    cinemaCamera.CameraType = Enum.CameraType.Custom
    cinemaCamera.FieldOfView = 70
    showAllUI()
end

-- =============================================
-- GUI - TAB RACE
-- =============================================


RaceTab = Window:Tab({
    Title = "Race",
	Border = true,
})

SpeedSection = RaceTab:Section({ Title = "Speed Hack", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = false })

speedValueInput = SpeedSection:Input({
    Type = "Input",
    Title = "Speed Value",
    Value = uiConfig.SpeedValue or "100",
    Placeholder = "Enter speed (10-1000)",
    Callback = function(value)
        local speed = tonumber(value)
        if speed and speed >= 10 and speed <= 1000 then
            VehicleSpeed.SetSpeed(speed)
        end
        if not isUILoading then
            uiConfig.SpeedValue = value
            saveUIConfig(uiConfig)
        end
    end
})
VehicleSpeed.SetSpeed(tonumber(uiConfig.SpeedValue) or 100)

speedHackToggle = SpeedSection:Toggle({
    Title = "Enable Speed Hack",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.SpeedHack = on
            saveUIConfig(uiConfig)
        end
        if on then VehicleSpeed.Start() else VehicleSpeed.Stop() end
    end
})

SlowSection = RaceTab:Section({ Title = "Slow Race (Gradual)", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = false })

slowMaxSpeedInput = SlowSection:Input({
    Type = "Input",
    Title = "Max Speed",
    Value = uiConfig.SlowMaxSpeed or "200",
    Placeholder = "Batas max speed (10-1000)",
    Callback = function(value)
        local v = tonumber(value)
        if v and v >= 10 and v <= 1000 then
            SlowRace.MaxSpeed = v
        end
        if not isUILoading then
            uiConfig.SlowMaxSpeed = value
            saveUIConfig(uiConfig)
        end
    end
})
SlowRace.MaxSpeed = tonumber(uiConfig.SlowMaxSpeed) or 200

slowAccelInput = SlowSection:Input({
    Type = "Input",
    Title = "Acceleration (kelipatan)",
    Value = uiConfig.SlowAccel or "3",
    Placeholder = "Kelipatan akselerasi (1-20)",
    Callback = function(value)
        local v = tonumber(value)
        if v and v >= 1 and v <= 20 then
            SlowRace.AccelMultiplier = v
        end
        if not isUILoading then
            uiConfig.SlowAccel = value
            saveUIConfig(uiConfig)
        end
    end
})
SlowRace.AccelMultiplier = tonumber(uiConfig.SlowAccel) or 3

slowRaceToggle = SlowSection:Toggle({
    Title = "Enable Slow Race",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.SlowRace = on
            saveUIConfig(uiConfig)
        end
        if on then SlowRace.Start() else SlowRace.Stop() end
    end
})

CinematicSection = RaceTab:Section({ Title = "Cinematic", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = false })

CinematicSection:Toggle({
    Title = "Enable Cinematic",
    Value = false,
    Callback = function(on)
        if on then
            task.spawn(playCinematic)
        else
            stopCinematic()
        end
    end
})

local LightingService = game:GetService("Lighting")
local originalLighting = {}

ultraGrafikToggle = CinematicSection:Toggle({
    Title = "Grafik Mode Ultra",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.UltraGrafik = on
            saveUIConfig(uiConfig)
        end
        if on then
            if not originalLighting.saved then
                pcall(function() originalLighting.Technology = LightingService.Technology end)
                originalLighting.Brightness = LightingService.Brightness
                originalLighting.ExposureCompensation = LightingService.ExposureCompensation
                originalLighting.Ambient = LightingService.Ambient
                originalLighting.OutdoorAmbient = LightingService.OutdoorAmbient
                originalLighting.ColorShift_Top = LightingService.ColorShift_Top
                originalLighting.ColorShift_Bottom = LightingService.ColorShift_Bottom
                originalLighting.GlobalShadows = LightingService.GlobalShadows
                originalLighting.ShadowSoftness = LightingService.ShadowSoftness
                originalLighting.saved = true
            end

            -- Hapus effect lama
            for _, e in ipairs(LightingService:GetChildren()) do
                if e.Name == "Blur"
                or e.Name == "menuBlur"
                or e.ClassName == "BloomEffect"
                or e.ClassName == "SunRaysEffect"
                or e.ClassName == "DepthOfFieldEffect"
                or e.ClassName == "ColorCorrectionEffect"
                or e.ClassName == "Atmosphere" then
                    e:Destroy()
                end
            end

            -- Technology ke Future
            pcall(function() LightingService.Technology = Enum.Technology.Future end)
            LightingService.Brightness           = 3
            LightingService.ExposureCompensation = 0.3
            LightingService.Ambient              = Color3.fromRGB(80, 80, 90)
            LightingService.OutdoorAmbient       = Color3.fromRGB(100, 110, 130)
            LightingService.ColorShift_Top       = Color3.fromRGB(255, 240, 200)
            LightingService.ColorShift_Bottom    = Color3.fromRGB(20, 20, 40)
            LightingService.GlobalShadows        = true
            LightingService.ShadowSoftness       = 0.1

            -- Bloom (cahaya highlight doang, ga blur)
            local bloom = Instance.new("BloomEffect")
            bloom.Name      = "UltraBloom"
            bloom.Intensity = 0.4
            bloom.Size      = 16
            bloom.Threshold = 0.98
            bloom.Parent    = LightingService

            -- Sun Rays
            local sunRays = Instance.new("SunRaysEffect")
            sunRays.Name      = "UltraSunRays"
            sunRays.Intensity = 0.12
            sunRays.Spread    = 0.5
            sunRays.Parent    = LightingService

            -- Color Correction (warna cinematic, NO blur)
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name       = "UltraCC"
            cc.Brightness = 0.02
            cc.Contrast   = 0.2
            cc.Saturation = 0.25
            cc.TintColor  = Color3.fromRGB(255, 248, 235)
            cc.Parent     = LightingService

            -- Atmosphere
            local atm = Instance.new("Atmosphere")
            atm.Name    = "UltraAtm"
            atm.Density = 0.25
            atm.Offset  = 0.2
            atm.Color   = Color3.fromRGB(199, 210, 230)
            atm.Decay   = Color3.fromRGB(90, 100, 120)
            atm.Glare   = 0.3
            atm.Haze    = 1.2
            atm.Parent  = LightingService

        else
            for _, e in ipairs(LightingService:GetChildren()) do
                if e.Name == "UltraBloom" or e.Name == "UltraSunRays" or e.Name == "UltraCC" or e.Name == "UltraAtm" then
                    e:Destroy()
                end
            end
            if originalLighting.saved then
                pcall(function() LightingService.Technology = originalLighting.Technology end)
                LightingService.Brightness = originalLighting.Brightness
                LightingService.ExposureCompensation = originalLighting.ExposureCompensation
                LightingService.Ambient = originalLighting.Ambient
                LightingService.OutdoorAmbient = originalLighting.OutdoorAmbient
                LightingService.ColorShift_Top = originalLighting.ColorShift_Top
                LightingService.ColorShift_Bottom = originalLighting.ColorShift_Bottom
                LightingService.GlobalShadows = originalLighting.GlobalShadows
                LightingService.ShadowSoftness = originalLighting.ShadowSoftness
            end
        end
    end
})

-- =============================================
-- GUI - TAB GARAGE
-- =============================================

local initialCarList = getCarList()

GarageTab = Window:Tab({
    Title = "Garasi",
	Border = true,
})

GarageSection = GarageTab:Section({ Title = "Spawn Kendaraan", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = true })

carDropdown = GarageSection:Dropdown({
    Title = "Pilih Kendaraan",
    Multi = false,
    Sidebar = true,
    Options = initialCarList,
    Value = initialCarList[1],
    Callback = function(selected)
        if selected ~= "Refresh dulu..." then
            SpawnCar.SelectedCar = selected
        end
    end
})
SpawnCar.SelectedCar = initialCarList[1] ~= "Refresh dulu..." and initialCarList[1] or nil

GarageSection:Button({
    Title = "Refresh List Kendaraan",
    Callback = function()
        local cars = getCarList()
        if cars[1] ~= "Refresh dulu..." then
            pcall(function()
                carDropdown:Refresh(cars, cars[1])
            end)
            SpawnCar.SelectedCar = cars[1]
        end
    end
})

GarageSection:Button({
    Title = "Spawn Kendaraan",
    Callback = function() SpawnCar.Spawn() end
})

GarageSection:Button({
    Title = "Despawn Kendaraan",
    Callback = function() SpawnCar.Despawn() end
})

GarageSection:Button({
    Title = "Ride Motor",
    Callback = function() rideMotor() end
})

autoRideToggle = GarageSection:Toggle({
    Title = "Auto Ride after Spawn",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.AutoRide = on
            saveUIConfig(uiConfig)
        end
        SpawnCar.AutoRide = on
    end
})

autoRideAlwaysToggle = GarageSection:Toggle({
    Title = "Auto Ride Always",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.AutoRideAlways = on
            saveUIConfig(uiConfig)
        end
        SpawnCar.AutoRideAlways = on
        if on then SpawnCar.StartAutoRideAlways()
        else SpawnCar.StopAutoRideAlways() end
    end
})

-- =============================================
-- FUNGSI UTAMA INJECTOR A-CHASSIS (AMAN DARI DETEKSI)
-- =============================================
local function InjectMesin(HP_Mult, RPM_Add, Ratio_Mult, FD_Mult, NamaMode)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local vehicle = char.Humanoid.SeatPart.Parent
        while vehicle and not vehicle:IsA("Model") do vehicle = vehicle.Parent end

        if vehicle then
            local foundTune = false
            for _, s in pairs(vehicle:GetDescendants()) do
                if s:IsA("LocalScript") then
                    local name = string.lower(s.Name)
                    if string.find(name, "limit") or string.find(name, "speed") or string.find(name, "cap") then
                        if name ~= "a-chassis interface" and name ~= "drive" then
                            pcall(function() s.Disabled = true s:Destroy() end)
                        end
                    end
                end
            end
            for _, v in pairs(vehicle:GetDescendants()) do
                if v:IsA("ModuleScript") and (v.Name == "Tune" or string.find(string.lower(v.Name), "tune")) then
                    pcall(function()
                        local tune = require(v)
                        if tune.Horsepower then tune.Horsepower = tune.Horsepower * HP_Mult end
                        if tune.Redline then tune.Redline = tune.Redline + RPM_Add end
                        if tune.Ratios then
                            for i, ratio in pairs(tune.Ratios) do
                                if type(ratio) == "number" and ratio > 0 then tune.Ratios[i] = ratio * Ratio_Mult end
                            end
                        end
                        if tune.FinalDrive then tune.FinalDrive = tune.FinalDrive * FD_Mult end
                        if tune.Limiter ~= nil then tune.Limiter = false end
                        if tune.RevLimit then tune.RevLimit = 999999 end
                        if tune.SpeedLimit then tune.SpeedLimit = false end
                        if tune.TopSpeed then tune.TopSpeed = 999999 end
                        if tune.MaxSpeed then tune.MaxSpeed = 999999 end
                        if tune.DragMult then tune.DragMult = tune.DragMult * 0.05 end
                        if tune.Weight then tune.Weight = tune.Weight * 0.7 end
                        foundTune = true
                    end)
                end
            end

            if foundTune then
                WindUI:Notify({ Title = "âœ… " .. NamaMode, Content = "Aman! Turun lalu naik motor lagi ya bosku!", Duration = 5 })
            else
                WindUI:Notify({ Title = "âŒ Gagal Inject", Content = "Bukan A-Chassis standar.", Duration = 4 })
            end
        end
    else
        WindUI:Notify({ Title = "âš ï¸ Woi Bosku!", Content = "Naik ke motornya dulu!", Duration = 3 })
    end
end

-- =============================================
-- GUI - TAB INJECTION
-- =============================================

InjectionTab = Window:Tab({
    Title = "Injection",
    Border = true,
})

PresetSection = InjectionTab:Section({ Title = "Preset Injection", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = false })

PresetSection:Button({ Title = "MODE SUNMORI", Callback = function() InjectMesin(1.5, 2000, 0.9, 0.9, "Mode Sunmori Aktif") end })
PresetSection:Button({ Title = "MODE BALAP LIAR", Callback = function() InjectMesin(3.5, 5000, 0.75, 0.75, "Mode Balap Aktif") end })
PresetSection:Button({ Title = "MODE DEWA", Callback = function() InjectMesin(8, 15000, 0.45, 0.45, "Mode Dewa Aktif") end })
PresetSection:Button({ Title = "RESET STANDAR PABRIK", Callback = function() WindUI:Notify({ Title = "â„¹ï¸ Info", Content = "Respawn kendaraan dari menu game untuk reset.", Duration = 5 }) end })

CustomSection = InjectionTab:Section({ Title = "Custom Injection", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = false })

local customHP, customRPM, customRatio, customFD = 2, 5000, 0.8, 0.8

customHP    = tonumber(uiConfig.CustomHP)    or customHP
customRPM   = tonumber(uiConfig.CustomRPM)   or customRPM
customRatio = tonumber(uiConfig.CustomRatio) or customRatio
customFD    = tonumber(uiConfig.CustomFD)    or customFD

CustomSection:Input({ Type = "Input", Title = "Pengali Tenaga (HP)", Value = uiConfig.CustomHP or "3", Placeholder = "Contoh: 3", Callback = function(Text) local val = tonumber(Text) if val then customHP = val end if not isUILoading then uiConfig.CustomHP = Text saveUIConfig(uiConfig) end end })
CustomSection:Input({ Type = "Input", Title = "Tambahan RPM", Value = uiConfig.CustomRPM or "8000", Placeholder = "Contoh: 8000", Callback = function(Text) local val = tonumber(Text) if val then customRPM = val end if not isUILoading then uiConfig.CustomRPM = Text saveUIConfig(uiConfig) end end })
CustomSection:Input({ Type = "Input", Title = "Pengali Rasio Gigi", Value = uiConfig.CustomRatio or "0.6", Placeholder = "Contoh: 0.6", Callback = function(Text) local val = tonumber(Text) if val then customRatio = val end if not isUILoading then uiConfig.CustomRatio = Text saveUIConfig(uiConfig) end end })
CustomSection:Input({ Type = "Input", Title = "Pengali Final Drive", Value = uiConfig.CustomFD or "0.6", Placeholder = "Contoh: 0.6", Callback = function(Text) local val = tonumber(Text) if val then customFD = val end if not isUILoading then uiConfig.CustomFD = Text saveUIConfig(uiConfig) end end })
CustomSection:Button({ Title = "INJECT CUSTOM TUNE SEKARANG", Callback = function() InjectMesin(customHP, customRPM, customRatio, customFD, "Custom Tune Aktif") end })

-- =============================================
-- =============================================
-- GUI - TAB JOB
-- =============================================


-- =============================================
-- CONFIG LOADER & WEBHOOK LOGIC
-- =============================================
local function saveJobConfig(data) end
local jobConfig = {}
if jobConfig.CourierTweenDuration then TWEEN_DURATION = jobConfig.CourierTweenDuration end
local isJobLoading = true

local function saveWebhookConfig(data) end
local whConfig      = {}
local isWhLoading   = true
local webhookURL    = whConfig.URL    or ""
local webhookActive = whConfig.Active or false
local webhookDelay  = whConfig.Delay  or 10

local uangAwal  = nil
local totalCycle = 0

local function parseUang(text)
    local clean = text:gsub("Rp%.", ""):gsub("%s+", "")
    return tonumber(clean) or 0
end

local function formatUang(num)
    local s      = tostring(math.floor(num))
    local result = ""
    local count  = 0
    for i = #s, 1, -1 do
        count  = count + 1
        result = s:sub(i, i) .. result
        if count % 3 == 0 and i ~= 1 then result = "." .. result end
    end
    return "Rp. " .. result
end

local function sendWebhook(uangAwalNum, uangSekarangNum, profit, cycle)
    if webhookURL == "" then return end
    local payload = {
        embeds = {{
            title       = "Monitoring Profit DDS Script By king Vypers!",
            description = "**Status:** `🟢 Farming Aktif`",
            color       = 3066993,
            fields      = {
                { name = "💰 Uang Awal",    value = "**" .. formatUang(uangAwalNum) .. "**",        inline = false },
                { name = "💵 Uang Sekarang",value = "**" .. formatUang(uangSekarangNum) .. "**",    inline = false },
                { name = "📈 Total Profit", value = "```diff\n+ " .. formatUang(profit) .. "\n```", inline = false },
                { name = "🔄 Total Cycle",  value = "**" .. tostring(cycle) .. "x**",               inline = false },
            },
            footer = { text = "DDS Premium Script • Time: " .. os.date("%H:%M:%S") }
        }}
    }
    local body = HttpService:JSONEncode(payload)
    task.spawn(function()
        pcall(function()
            if syn and syn.request then syn.request({ Url = webhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            elseif request then request({ Url = webhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end
        end)
    end)
end

task.spawn(function()
    while true do
        task.wait(webhookDelay)
        if not isAlive() then break end
        if not webhookActive or webhookURL == "" then continue end
        local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
        local moneyLabel  = nil
        pcall(function() moneyLabel = PlayerGui.MainUI.Frame4.TextLabel end)
        if not moneyLabel then continue end
        local uangSekarangNum = parseUang(moneyLabel.Text)
        if uangAwal == nil then uangAwal = uangSekarangNum end
        local profit = uangSekarangNum - uangAwal
        sendWebhook(uangAwal, uangSekarangNum, profit, totalCycle)
    end
end)

local function saveCourierWebhookConfig(data) end
local whCourierConfig      = {}
local isWhCourierLoading   = true
local webhookCourierURL    = whCourierConfig.URL    or ""
local webhookCourierActive = whCourierConfig.Active or false

function sendCourierWebhook()
    if not webhookCourierActive or webhookCourierURL == "" then return end
    local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
    local moneyLabel  = nil
    pcall(function() moneyLabel = PlayerGui.MainUI.Frame4.TextLabel end)
    if not moneyLabel then return end

    local uangSekarangNum = parseUang(moneyLabel.Text)
    if uangAwalCourier == nil then uangAwalCourier = uangSekarangNum end
    local profit = uangSekarangNum - uangAwalCourier

    local payload = {
        embeds = {{
            title       = "⚙️ Courier Job - Monitoring Profit",
            description = "**Status:** `🟢 Farming Courier Aktif`",
            color       = 15507969,
            fields      = {
                { name = "💰 Uang Awal",    value = "**" .. formatUang(uangAwalCourier) .. "**",     inline = false },
                { name = "💵 Uang Sekarang",value = "**" .. formatUang(uangSekarangNum) .. "**", inline = false },
                { name = "📈 Total Profit", value = "```diff\n+ " .. formatUang(profit) .. "\n```", inline = false },
                { name = "🔄 Total Cycle",  value = "**" .. tostring(totalCourierCycle) .. "x**",        inline = false },
            },
            footer = { text = "DDS Premium Script • Time: " .. os.date("%H:%M:%S") }
        }}
    }
    local body = HttpService:JSONEncode(payload)
    task.spawn(function()
        pcall(function()
            if syn and syn.request then syn.request({ Url = webhookCourierURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            elseif request then request({ Url = webhookCourierURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end
        end)
    end)
end

-- Forward declaration: modul render + HUD monitor didefinisikan jauh di bawah,
-- tapi harus sudah jadi upvalue supaya callback Auto Office di atas bisa manggil.
local DisableRendering
local OfficeMonitor

local OfficeModule -- Forward declaration agar bisa dibaca oleh sendOfficeWebhook
local function saveOfficeWebhookConfig(data) end
local whOfficeConfig      = {}
local isWhOfficeLoading   = true
local webhookOfficeURL    = whOfficeConfig.URL    or ""
local webhookOfficeActive = whOfficeConfig.Active or false
local uangAwalOffice      = nil

function sendOfficeWebhook()
    if not webhookOfficeActive or webhookOfficeURL == "" then return end
    local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
    local moneyLabel  = nil
    pcall(function() moneyLabel = PlayerGui.MainUI.Frame4.TextLabel end)
    if not moneyLabel then return end

    local uangSekarangNum = parseUang(moneyLabel.Text)
    if uangAwalOffice == nil then uangAwalOffice = uangSekarangNum end
    local profit = uangSekarangNum - uangAwalOffice
    local cycle = OfficeModule.totalCycle or 0

    local payload = {
        embeds = {{
            title       = "Office Job - Monitoring Profit V1.6 Debugging",
            description = "**Status:** `✅ Farming Office Aktif`",
            color       = 16766720,
            fields      = {
                { name = "Uang Awal",    value = "**" .. formatUang(uangAwalOffice) .. "**",     inline = false },
                { name = "Uang Sekarang",value = "**" .. formatUang(uangSekarangNum) .. "**", inline = false },
                { name = "Total Profit", value = "```diff\n+ " .. formatUang(profit) .. "\n```", inline = false },
                { name = "Total Cycle",  value = "**" .. tostring(cycle) .. "x**",        inline = false },
            },
            footer = { text = "DDS Premium Script   Time: " .. os.date("%H:%M:%S") }
        }}
    }
    local body = HttpService:JSONEncode(payload)
    task.spawn(function()
        pcall(function()
            if syn and syn.request then syn.request({ Url = webhookOfficeURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            elseif request then request({ Url = webhookOfficeURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end
        end)
    end)
end

local function sendWebhookRepairEvent(msg)
    if not webhookActive or webhookURL == "" then return end
    local payload = {
        embeds = {{
            title       = "⚙️ Auto Repair Event",
            description = "**Notice:** " .. tostring(msg),
            color       = 16711680,
            footer      = { text = "DDS Premium Script • Time: " .. os.date("%H:%M:%S") }
        }}
    }
    local body = HttpService:JSONEncode(payload)
    task.spawn(function()
        pcall(function()
            if syn and syn.request then syn.request({ Url = webhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            elseif request then request({ Url = webhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end
        end)
    end)
end

local function sendWebhookKickEvent(msg)
    if not webhookActive or webhookURL == "" then return end
    local payload = {
        embeds = {{
            title       = "🛑 Auto Kick Triggered",
            description = "**Notice:** " .. tostring(msg),
            color       = 16711680,
            footer      = { text = "DDS Premium Script • Time: " .. os.date("%H:%M:%S") }
        }}
    }
    local body = HttpService:JSONEncode(payload)
    task.spawn(function()
        pcall(function()
            if syn and syn.request then syn.request({ Url = webhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            elseif request then request({ Url = webhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end
        end)
    end)
end

-- =============================================
-- AUTO JOB Office Loader
-- =============================================

OfficeModule = loadstring(game:HttpGet(
		"https://gitlab.com/kingvypers21/sukasukaaja/-/raw/main/iniadeknya3.lua?ref_type=heads"
))()

OfficeModule.onCycle = sendOfficeWebhook


-- =============================================
-- AUTO JOB BARISTA LOADER
-- =============================================

-- ① Load module dari GitHub
local BaristaModule = loadstring(game:HttpGet(
    "https://gitlab.com/kingvypers21/sukasukaaja/-/raw/main/adekkedua.lua?ref_type=heads"
))()

-- ② Sambungkan webhook repair & kick event dari dds.lua ke module
BaristaModule.onRepairEvent = sendWebhookRepairEvent
BaristaModule.onKickEvent   = sendWebhookKickEvent

-- ③ Sync totalCycle tiap detik untuk webhook profit
task.spawn(function()
    while true do
        task.wait(1)
        if not isAlive() then break end
        totalCycle = BaristaModule.totalCycle
    end
end)

-- =============================================
-- CONFIG SAVE/LOAD (barista section)
-- =============================================


local function saveBaristaConfig(data) end

local bCfg       = {}
local isBLoading = true

local function saveOfficeConfig(data) end
local oCfg       = {}
local isOLoading = true

-- Apply saved config ke module
if bCfg.TimeoutMax     then BaristaModule.timeoutMax     = bCfg.TimeoutMax     end
if bCfg.TimeoutEnabled ~= nil then BaristaModule.timeoutEnabled = bCfg.TimeoutEnabled end
if bCfg.KickLimitMinutes then BaristaModule.kickLimitMinutes = bCfg.KickLimitMinutes end
if bCfg.KickLimitEnabled ~= nil then BaristaModule.kickLimitEnabled = bCfg.KickLimitEnabled end

if oCfg.TimeoutMax     then OfficeModule.timeoutMax     = oCfg.TimeoutMax     end
if oCfg.TimeoutEnabled ~= nil then OfficeModule.timeoutEnabled = oCfg.TimeoutEnabled end

-- =============================================
-- UI — JOB SECTION
-- =============================================

AutoJobTabSection = Window:Section({
    Title = "Auto Job",
    Opened = true,
})
-- Status tiap job: Barista = RISK, Courier = RISK, Office = STABLE (rekomendasi).
-- Detail peringatannya ada di section "Status Fitur" paling atas tiap tab.

BaristaTab = AutoJobTabSection:Tab({
    Title = "Barista",
    Border = true,
})

CourierTab = AutoJobTabSection:Tab({
    Title = "Courier",
    Border = true,
})

OfficeTab = AutoJobTabSection:Tab({
    Title = "Office",
    Border = true,
})


-- =============================================
-- OFFICE (Inside OfficeTab)
-- =============================================

-- ── STATUS FITUR ──────────────────────────────────────────────
local OfficeStatusSection = OfficeTab:Section({
    Title          = "Status Fitur",
    Box            = true,
    TextXAlignment = "Center",
    TextSize       = 15,
    Opened         = true,
})

OfficeStatusSection:Tag({
    Id    = "status_office",
    Title = "Auto Job Office",
    Text  = "STABLE",
    Color = Color3.fromRGB(70, 200, 120),
})

OfficeStatusSection:Divider()

local JobSectionOffice = OfficeTab:Section({
    Title          = "Auto Job Office",
    Box            = true,
    TextXAlignment = "Center",
    TextSize       = 15,
    Opened         = true,
})

-- Toggle Auto Office
OfficeToggle = JobSectionOffice:Toggle({
    Title = "Auto Office",
    Value = false,
    Callback = function(on)
        if not isOLoading then
            oCfg.AutoOffice = on
            saveOfficeConfig(oCfg)
        end
        if on then
            OfficeModule:Start()
            -- Layar langsung dikunci hitam + panel monitoring nyala.
            pcall(function() OfficeMonitor.Show() end)
            -- Samakan tampilan toggle Disable 3D Rendering di tab Performance.
            pcall(function() if disableRenderToggle then disableRenderToggle:Set(true) end end)
        else
            OfficeModule:Stop()
            pcall(function() OfficeMonitor.Hide() end)
            pcall(function() if disableRenderToggle then disableRenderToggle:Set(false) end end)
        end
    end
})

JobSectionOffice:Input({
    Type        = "Input",
    Title       = "Timeout Office (detik)",
    Value       = tostring(OfficeModule.timeoutMax),
    Placeholder = "Contoh: 300",
    Callback    = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            OfficeModule.timeoutMax = num
            if not isOLoading then
                oCfg.TimeoutMax = num
                saveOfficeConfig(oCfg)
                print("Office Timeout diset ke: " .. tostring(num) .. " detik")
            end
        end
    end
})

local OfficeRestartToggle = JobSectionOffice:Toggle({
    Title = "Auto Restart Office",
    Value = false,
    Callback = function(on)
        OfficeModule.timeoutEnabled = on
        if not isOLoading then
            oCfg.TimeoutEnabled = on
            saveOfficeConfig(oCfg)
        end
        if on then OfficeModule.lastActivity = tick() end
    end
})

JobSectionOffice:Button({
    Title = "Show Progress",
    Callback = function()
        if not OfficeMonitor.Active then
            Vypers:Notify({
                Title = "Show Progress",
                Content = "Nyalakan Auto Office dulu. Layar belum dikunci.",
                Type = "warning",
            })
            return
        end
        local ok, left = OfficeMonitor.Peek()
        if ok then
            Vypers:Notify({
                Title = "Show Progress",
                Content = "Layar dibuka 5 detik, habis itu dikunci hitam lagi.",
                Type = "success",
                Duration = 5,
            })
        elseif OfficeMonitor.Peeking then
            Vypers:Notify({
                Title = "Show Progress",
                Content = "Layar masih kebuka. Sabar bentar.",
                Type = "info",
            })
        else
            Vypers:Notify({
                Title = "Show Progress",
                Content = "Masih cooldown. Tunggu " .. tostring(left) .. " detik lagi.",
                Type = "warning",
                Duration = 5,
            })
        end
    end,
})

OfficeWebhookSection = OfficeTab:Section({ Title = "Discord Webhook Office", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = true })

whOfficeUrlInput = OfficeWebhookSection:Input({
    Type = "Input",
    Title = "Webhook URL",
    Value = whOfficeConfig.URL or "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v)
        webhookOfficeURL = v
        if not isWhOfficeLoading then
            whOfficeConfig.URL = v
            saveOfficeWebhookConfig(whOfficeConfig)
            print("Webhook Office URL disimpan!")
        end
    end
})

OfficeWebhookSection:Button({
    Title = "Test Office Webhook",
    Callback = function()
        if webhookOfficeURL == "" then
            print("Masukkan webhook URL dulu!")
            return
        end
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        local moneyLabel = nil
        pcall(function() moneyLabel = PlayerGui.MainUI.Frame4.TextLabel end)

        if moneyLabel then
            local uangSekarang = parseUang(moneyLabel.Text)
            if uangAwalOffice == nil then uangAwalOffice = uangSekarang end
            local profit = uangSekarang - uangAwalOffice
            local cycle = OfficeModule.totalCycle or 0

            local payload = {
                embeds = {{
                    title       = "💼 Office Job - Test Webhook",
                    description = "**Status:** `✅ Test Connection`",
                    color       = 16766720,
                    fields      = {
                        { name = "💵 Uang Awal",    value = "**" .. formatUang(uangAwalOffice) .. "**",     inline = false },
                        { name = "💰 Uang Sekarang",value = "**" .. formatUang(uangSekarang) .. "**", inline = false },
                        { name = "📈 Total Profit", value = "```diff\n+ " .. formatUang(profit) .. "\n```", inline = false },
                        { name = "🔄 Total Cycle",  value = "**" .. tostring(cycle) .. "x**",        inline = false },
                    },
                    footer = { text = "DDS Premium Script   Time: " .. os.date("%H:%M:%S") }
                }}
            }
            local body = HttpService:JSONEncode(payload)
            task.spawn(function()
                pcall(function()
                    if syn and syn.request then syn.request({ Url = webhookOfficeURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
                    elseif request then request({ Url = webhookOfficeURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end
                end)
            end)
        else
            print("Gagal membaca uang dari UI!")
        end
    end
})

whOfficeToggle = OfficeWebhookSection:Toggle({
    Title = "Aktifkan Webhook Office",
    Value = false,
    Callback = function(v)
        webhookOfficeActive = v
        if not isWhOfficeLoading then
            whOfficeConfig.Active = v
            saveOfficeWebhookConfig(whOfficeConfig)

            if v then
                local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
                local moneyLabel = nil
                pcall(function() moneyLabel = PlayerGui.MainUI.Frame4.TextLabel end)
                if moneyLabel then
                    uangAwalOffice = parseUang(moneyLabel.Text)
                    OfficeModule.totalCycle = 0
                    print("Webhook Office aktif! Uang awal: " .. formatUang(uangAwalOffice))
                end

                -- onCycle sudah di-set ke sendOfficeWebhook di loader OfficeModule
                -- Jadi tidak perlu di-set ulang atau di-nil-kan di sini
            else
                print("Webhook Office dimatikan!")
            end
        end
    end
})

task.spawn(function()
    task.wait(0.5)
    if whOfficeConfig.Active then
        whOfficeToggle:Set(true)
    end
    isWhOfficeLoading = false
end)


-- =============================================
-- BARISTA (Inside BaristaTab)
-- =============================================

-- ── STATUS FITUR ──────────────────────────────────────────────
local BaristaStatusSection = BaristaTab:Section({
    Title          = "Status Fitur",
    Box            = true,
    TextXAlignment = "Center",
    TextSize       = 15,
    Opened         = true,
})

BaristaStatusSection:Tag({
    Id    = "status_barista",
    Title = "Auto Job Barista",
    Text  = "RISK",
    Color = Color3.fromRGB(225, 75, 75),
})

BaristaStatusSection:Divider()

JobSection = BaristaTab:Section({
    Title          = "Auto Job Barista",
    Box            = true,
    TextXAlignment = "Center",
    TextSize       = 15,
    Opened         = true,
})

-- Toggle Auto Barista
baristaToggle = JobSection:Toggle({
    Title = "Auto Barista",
    Value = false,
    Callback = function(on)
        if not isBLoading then
            bCfg.AutoBarista = on
            saveBaristaConfig(bCfg)
        end
        if on then
            BaristaModule:Start()
        else
            BaristaModule:Stop()
        end
    end
})

JobSection:Space()

-- ---- AUTO RESTART TIMEOUT ----
JobSection:Paragraph({ Title = "Auto Restart Jika Timeout" })

JobSection:Input({
    Type        = "Input",
    Title       = "Timeout (detik)",
    Value       = tostring(BaristaModule.timeoutMax),
    Placeholder = "Contoh: 90",
    Callback    = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            BaristaModule.timeoutMax = num
            if not isBLoading then
                bCfg.TimeoutMax = num
                saveBaristaConfig(bCfg)
            end
        end
    end
})

restartToggle = JobSection:Toggle({
    Title = "Auto Restart",
    Value = false,
    Callback = function(on)
        BaristaModule.timeoutEnabled = on
        if not isBLoading then
            bCfg.TimeoutEnabled = on
            saveBaristaConfig(bCfg)
        end
        if on then BaristaModule.lastServeTime = tick() end
    end
})

JobSection:Space()

-- ---- KICK LIMIT ----
JobSection:Paragraph({ Title = "Limit Auto Job (Auto Kick)" })

JobSection:Input({
    Type        = "Input",
    Title       = "Limit Menit",
    Value       = tostring(BaristaModule.kickLimitMinutes),
    Placeholder = "Contoh: 120",
    Callback    = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            BaristaModule.kickLimitMinutes = num
            if not isBLoading then
                bCfg.KickLimitMinutes = num
                saveBaristaConfig(bCfg)
            end
        end
    end
})

kickToggle = JobSection:Toggle({
    Title = "Toggle Auto Kick",
    Value = false,
    Callback = function(on)
        BaristaModule.kickLimitEnabled = on
        if not isBLoading then
            bCfg.KickLimitEnabled = on
            saveBaristaConfig(bCfg)
        end
    end
})

-- =============================================
-- WEBHOOK SECTION (merged into BaristaTab)
-- =============================================

WebhookSection = BaristaTab:Section({ Title = "Discord Webhook", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = true })

whUrlInput = WebhookSection:Input({
    Type = "Input",
    Title = "Webhook URL",
    Value = whConfig.URL or "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v)
        webhookURL = v
        if not isWhLoading then
            whConfig.URL = v
            saveWebhookConfig(whConfig)
            print("Webhook URL disimpan!")
        end
    end
})

whDelayInput = WebhookSection:Input({
    Type = "Input",
    Title = "Delay Kirim (detik)",
    Value = tostring(whConfig.Delay or 10),
    Placeholder = "Contoh: 10",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then
            webhookDelay = num
            if not isWhLoading then
                whConfig.Delay = num
                saveWebhookConfig(whConfig)
                print("Webhook delay di-set ke: " .. num .. " detik.")
            end
        end
    end
})

WebhookSection:Button({
    Title = "Test Webhook",
    Callback = function()
        if webhookURL == "" then
            print("Masukkan webhook URL dulu!")
            return
        end
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        local moneyLabel = nil
        pcall(function() moneyLabel = PlayerGui.MainUI.Frame4.TextLabel end)

        if moneyLabel then
            local uangSekarang = parseUang(moneyLabel.Text)
            if uangAwal == nil then uangAwal = uangSekarang end
            local profit = uangSekarang - uangAwal
            sendWebhook(uangAwal, uangSekarang, profit, totalCycle)
        else
            print("Gagal membaca uang dari UI!")
        end
    end
})

whToggle = WebhookSection:Toggle({
    Title = "Aktifkan Webhook",
    Value = false,
    Callback = function(v)
        webhookActive = v
        if not isWhLoading then
            whConfig.Active = v
            saveWebhookConfig(whConfig)

            if v then
                local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
                local moneyLabel = nil
                pcall(function() moneyLabel = PlayerGui.MainUI.Frame4.TextLabel end)
                if moneyLabel then
                    uangAwal = parseUang(moneyLabel.Text)
                    totalCycle = 0
                    print("Webhook aktif! Uang awal: " .. formatUang(uangAwal))
                end
            else
                print("Webhook dimatikan!")
            end
        end
    end
})

-- =============================================
-- COURIER (Inside CourierTab)
-- =============================================

-- ── STATUS FITUR ──────────────────────────────────────────────
local CourierStatusSection = CourierTab:Section({
    Title          = "Status Fitur",
    Box            = true,
    TextXAlignment = "Center",
    TextSize       = 15,
    Opened         = true,
})

CourierStatusSection:Tag({
    Id    = "status_courier",
    Title = "Auto Job Courier",
    Text  = "RISK",
    Color = Color3.fromRGB(225, 75, 75),
})

CourierStatusSection:Divider()

CourierSection = CourierTab:Section({ Title = "Auto Job Courier", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = true })

CourierSection:Button({
    Title = "Accept Job Courier",
    Callback = function()
        setJob(CourierJob)
    end
})

courierToggle = CourierSection:Toggle({
    Title = "Auto Work Courier",
    Value = false,
    Callback = function(on)
        if not isJobLoading then
            jobConfig.AutoCourier = on
            saveJobConfig(jobConfig)
        end
        if on then
            task.spawn(startCourierLoop)
        else
            stopCourierLoop()
        end
    end
})

CourierSection:Input({
    Title       = "Kecepatan Tween (detik)",
    Desc        = "Makin kecil makin cepat.",
    Value       = tostring(TWEEN_DURATION),
    Placeholder = "Contoh: 60",
    Type        = "Input",
    Callback    = function(input)
        local val = tonumber(input)
        if val and val > 0 then
            TWEEN_DURATION = val
            if not isJobLoading then
                jobConfig.CourierTweenDuration = val
                saveJobConfig(jobConfig)
            end
            print("[Courier] Tween duration diset ke " .. val .. " detik")
        else
            print("[Courier] Input tidak valid, tetap " .. TWEEN_DURATION .. " detik")
        end
    end
})

CourierSection:Button({
    Title    = "Stop Manual",
    Callback = function() stopCourierLoop() end
})

CourierWebhookSection = CourierTab:Section({ Title = "Discord Webhook Courier", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = true })

whCourierUrlInput = CourierWebhookSection:Input({
    Type = "Input",
    Title = "Webhook URL",
    Value = whCourierConfig.URL or "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v)
        webhookCourierURL = v
        if not isWhCourierLoading then
            whCourierConfig.URL = v
            saveCourierWebhookConfig(whCourierConfig)
            print("Webhook Courier URL disimpan!")
        end
    end
})

CourierWebhookSection:Button({
    Title = "Test Courier Webhook",
    Callback = function()
        if webhookCourierURL == "" then
            print("Masukkan webhook URL dulu!")
            return
        end
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        local moneyLabel = nil
        pcall(function() moneyLabel = PlayerGui.MainUI.Frame4.TextLabel end)

        if moneyLabel then
            local uangSekarang = parseUang(moneyLabel.Text)
            if uangAwalCourier == nil then uangAwalCourier = uangSekarang end
            local profit = uangSekarang - uangAwalCourier

            local payload = {
                embeds = {{
                    title       = "⚙️ Courier Job - Test Webhook",
                    description = "**Status:** `🟢 Test Connection`",
                    color       = 15507969,
                    fields      = {
                        { name = "💰 Uang Awal",    value = "**" .. formatUang(uangAwalCourier) .. "**",     inline = false },
                        { name = "💵 Uang Sekarang",value = "**" .. formatUang(uangSekarang) .. "**", inline = false },
                        { name = "📈 Total Profit", value = "```diff\n+ " .. formatUang(profit) .. "\n```", inline = false },
                        { name = "🔄 Total Cycle",  value = "**" .. tostring(totalCourierCycle) .. "x**",        inline = false },
                    },
                    footer = { text = "DDS Premium Script • Time: " .. os.date("%H:%M:%S") }
                }}
            }
            local body = HttpService:JSONEncode(payload)
            task.spawn(function()
                pcall(function()
                    if syn and syn.request then syn.request({ Url = webhookCourierURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
                    elseif request then request({ Url = webhookCourierURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end
                end)
            end)
        else
            print("Gagal membaca uang dari UI!")
        end
    end
})

whCourierToggle = CourierWebhookSection:Toggle({
    Title = "Aktifkan Webhook Courier",
    Value = false,
    Callback = function(v)
        webhookCourierActive = v
        if not isWhCourierLoading then
            whCourierConfig.Active = v
            saveCourierWebhookConfig(whCourierConfig)

            if v then
                local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
                local moneyLabel = nil
                pcall(function() moneyLabel = PlayerGui.MainUI.Frame4.TextLabel end)
                if moneyLabel then
                    uangAwalCourier = parseUang(moneyLabel.Text)
                    totalCourierCycle = 0
                    print("Webhook Courier aktif! Uang awal: " .. formatUang(uangAwalCourier))
                end
            else
                print("Webhook Courier dimatikan!")
            end
        end
    end
})

task.spawn(function()
    task.wait(0.5)
    if whCourierConfig.Active then
        whCourierToggle:Set(true)
    end
    isWhCourierLoading = false
end)

task.spawn(function()
    task.wait(0.5)
    if jobConfig.TimeoutEnabled then
        restartToggle:Set(true)
    end
    if jobConfig.AutoBarista then
        baristaToggle:Set(true)
    end
    if jobConfig.AutoCourier then
        courierToggle:Set(true)
    end
    if jobConfig.KickLimitEnabled then
        kickToggle:Set(true)
    end
    if whConfig.Active then
        whToggle:Set(true)
    end
    isJobLoading = false
    isWhLoading = false
end)

-- CHARACTER ADDED
-- =============================================

local function onCharacterAdded(char)
    Character = char
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if Character then onCharacterAdded(Character) end

-- =============================================
-- HIDE STATS MODULE
-- =============================================

local HideStats = (function()
    local HS = {}

    local enabled = false
    local FakeName = "King Vypers"
    local FakeRank = "King Vypers Ã°Å¸â€˜â€˜"
    local updateLoop = nil

    local function getRankTags()
        local char = LocalPlayer.Character
        if not char then return nil end
        local head = char:FindFirstChild("Head")
        if not head then return nil end
        return head:FindFirstChild("RankTags")
    end

    local function updateStats()
        if not enabled then return end
        local rankTags = getRankTags()
        if not rankTags then return end

        local username = rankTags:FindFirstChild("Player_Username")
        local rank = rankTags:FindFirstChild("Player_Rank")

        if username then
            username.Text = FakeName
            local shadow = username:FindFirstChild("Shadow")
            if shadow then shadow.Text = FakeName end
        end
        if rank then rank.Text = FakeRank end
    end

    local function restoreStats()
        local rankTags = getRankTags()
        if not rankTags then return end

        local username = rankTags:FindFirstChild("Player_Username")
        local rank = rankTags:FindFirstChild("Player_Rank")

        if username then
            username.Text = LocalPlayer.Name
            local shadow = username:FindFirstChild("Shadow")
            if shadow then shadow.Text = LocalPlayer.Name end
        end
        if rank then rank.Text = "Member" end
    end

    local function startLoop()
        if updateLoop then return end
        updateLoop = true
        task.spawn(function()
            while updateLoop do
                task.wait(0.2)
                if enabled then updateStats() end
            end
        end)
    end

    function HS.Enable()
        enabled = true
        startLoop()
        updateStats()
    end

    function HS.Disable()
        enabled = false
        updateLoop = false
        restoreStats()
    end

    function HS.SetFakeName(name)
        FakeName = name or LocalPlayer.Name
        if enabled then updateStats() end
    end

    function HS.SetFakeRank(rank)
        FakeRank = rank or "Member"
        if enabled then updateStats() end
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if enabled then updateStats() end
    end)

    return HS
end)()

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

        -- Bypass Anti-AFK Roblox native yang paling ampuh (jalan di background saat idled)
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
-- =============================================
-- ANTI-STAFF MODULE
-- =============================================

local AntiStaff = (function()
    local AS = {}
    AS.Active = false

    local GROUP_ID = 35102746
    local STAFF_RANKS = {
        [2]=true, [3]=true, [4]=true, [75]=true, [79]=true,
        [145]=true, [250]=true, [252]=true, [254]=true, [255]=true,
        [55]=true, [30]=true, [35]=true, [100]=true, [76]=true
    }

    local function checkLoop()
        while AS.Active do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local ok, rank = pcall(function()
                        return player:GetRankInGroup(GROUP_ID)
                    end)
                    if ok and STAFF_RANKS[rank] then
                        LocalPlayer:Kick("Staff Detected! Auto Kicked for Safety.")
                        return
                    end
                end
            end
            task.wait(1)
        end
    end

    function AS.Start()
        if AS.Active then return end
        AS.Active = true
        task.spawn(checkLoop)
    end

    function AS.Stop()
        AS.Active = false
    end

    return AS
end)()

-- =============================================
-- AUTO RECONNECT + AUTO EXECUTE MODULE
-- =============================================

local AutoRejoin = (function()
    local AR = {}
    AR.Enabled = false
    AR.AutoExecEnabled = false

    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local disconnectSetup = false
    local hasTriggered = false

    -- URL script yang akan di-execute otomatis setelah rejoin
    -- WARNING: Ganti SCRIPT_URL dengan URL script UTAMA (misal pastebin/github raw cobadds.lua lo)
    -- JANGAN pakai URL vyperui.lua karena itu cuma UI-nya saja!
    local SCRIPT_URL = "https://raw.githubusercontent.com/AwoakwoakSikat/emangbowleh/refs/heads/main/loader-news.lua"
    local EXEC_DELAY = 30 -- detik tunggu sebelum execute setelah rejoin (dilebihin dikit biar game load)

    -- Cari queue_on_teleport dari berbagai executor secara aman
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
        return nil
    end

    local autoExecQueued = false
    local function setupAutoExecuteQueue()
        if autoExecQueued then return true end
        local queueTeleport = getQueueOnTeleport()
        if not queueTeleport then return false end
        if not AR.AutoExecEnabled then return false end

        local autoExecCode = string.format([[
            task.wait(%d)
            pcall(function()
                loadstring(game:HttpGet("%s"))()
            end)
        ]], EXEC_DELAY, SCRIPT_URL)

        local ok = pcall(function() queueTeleport(autoExecCode) end)
        if ok then autoExecQueued = true end
        return ok
    end

    local function doRejoin()
        if hasTriggered then return end
        if not AR.Enabled then return end
        hasTriggered = true

        -- Queue auto execute dulu sebelum teleport kalau fitur aktif
        if AR.AutoExecEnabled then
            setupAutoExecuteQueue()
        end

        task.spawn(function()
            while true do
                if not isAlive() then break end
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
                task.wait(3) -- Loop terus misal teleport gagal
            end
        end)
    end

    local function setupDetection()
        if disconnectSetup then return end
        disconnectSetup = true

        -- Method 1: GuiService ErrorMessageChanged
        pcall(function()
            game:GetService("GuiService").ErrorMessageChanged:Connect(function(message)
                if message and message ~= "" and AR.Enabled then
                    task.wait(1)
                    doRejoin()
                end
            end)
        end)

        -- Method 2: CoreGui RobloxPromptGui Ã¢â‚¬â€ popup "You were kicked" / error
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

        -- Method 3: LocalPlayer.Idled Ã¢â‚¬â€ kicked karena idle terlalu lama
        pcall(function()
            LocalPlayer.Idled:Connect(function(t)
                if t > 1150 and AR.Enabled then -- 1150 detik biar gakeduluan Roblox
                    doRejoin()
                end
            end)
        end)

        -- Method 4: OnTeleport Ã¢â‚¬â€ fallback
        pcall(function()
            LocalPlayer.OnTeleport:Connect(function(state)
                if state == Enum.TeleportState.RequestedFromServer and AR.Enabled then
                    task.wait(1)
                    doRejoin()
                end
            end)
        end)
    end

    function AR.Start()
        if AR.Enabled then return end
        AR.Enabled = true
        hasTriggered = false
        setupDetection()

        if AR.AutoExecEnabled then
            setupAutoExecuteQueue()
        end
    end

    function AR.Stop()
        AR.Enabled = false
        hasTriggered = false
    end

    function AR.EnableAutoExec()
        AR.AutoExecEnabled = true
        if AR.Enabled then
            setupAutoExecuteQueue()
        end
    end

    function AR.DisableAutoExec()
        AR.AutoExecEnabled = false
    end

    function AR.SetScriptURL(url)
        if type(url) == "string" and url ~= "" then
            SCRIPT_URL = url
        end
    end

    function AR.IsQueueSupported()
        return getQueueOnTeleport() ~= nil
    end

    return AR
end)()

-- =============================================
-- POTATO MODE MODULE
-- =============================================

local PotatoMode = (function()
    local PM = {}
    PM.Enabled = false

    local Lighting = game:GetService("Lighting")
    local StarterGui = game:GetService("StarterGui")
    local Terrain = Workspace:FindFirstChildOfClass("Terrain")

    local originalStates = { lighting = {}, waterProperties = {}, camera = {} }
    local pmConnections = {}
    local processedObjects = setmetatable({}, {__mode = "k"})

    local DESTROY_CLASSES = {
        BloomEffect=true, BlurEffect=true, ColorCorrectionEffect=true,
        SunRaysEffect=true, DepthOfFieldEffect=true, Atmosphere=true,
    }

    local function shouldDestroy(obj) return DESTROY_CLASSES[obj.ClassName] end

    local function isInVehicle(obj)
        local parent = obj.Parent
        while parent and parent ~= Workspace do
            if parent.Name:find("Montors") or parent.Name:find("Vehicle") or parent.Name:find("Car") then
                return true
            end
            parent = parent.Parent
        end
        return false
    end

    local function safeDestroy(obj)
        local ok, locked = pcall(function() return obj.Locked end)
        if ok and locked then return end
        if isInVehicle(obj) then return end
        pcall(function() obj:Destroy() end)
    end

    local function optimizeObject(obj)
        if not PM.Enabled or processedObjects[obj] then return end
        processedObjects[obj] = true
        if shouldDestroy(obj) then safeDestroy(obj) return end
        pcall(function()
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
                obj.Reflectance = 0
                obj.TopSurface = Enum.SurfaceType.SmoothNoOutlines
                obj.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
                obj.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
                obj.RightSurface = Enum.SurfaceType.SmoothNoOutlines
                obj.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
                obj.BackSurface = Enum.SurfaceType.SmoothNoOutlines
            elseif obj:IsA("Sound") then
                obj.Volume = 0
            end
        end)
    end

    local function optimizeCharacter(character)
        if not character or processedObjects[character] then return end
        processedObjects[character] = true
        pcall(function()
            for _, obj in ipairs(character:GetDescendants()) do
                if shouldDestroy(obj) then
                    local okL, isLocked = pcall(function() return obj.Locked end)
                    if not (okL and isLocked) then
                        pcall(function() obj:Destroy() end)
                    end
                elseif obj:IsA("BasePart") then
                    if obj.Name == "Head" then obj.Transparency = 1 end
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                    obj.CanCollide = obj.Name == "HumanoidRootPart" or obj.Name == "Head"
                    obj.Reflectance = 0
                    obj.TopSurface = Enum.SurfaceType.SmoothNoOutlines
                    obj.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
                    obj.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
                    obj.RightSurface = Enum.SurfaceType.SmoothNoOutlines
                    obj.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
                    obj.BackSurface = Enum.SurfaceType.SmoothNoOutlines
                elseif obj:IsA("Humanoid") then
                    for _, t in ipairs(obj:GetPlayingAnimationTracks()) do t:Stop() end
                    obj.HealthDisplayDistance = 0
                    obj.NameDisplayDistance = 0
                elseif obj:IsA("Sound") then
                    obj.Volume = 0
                end
            end
        end)
    end

    function PM.Enable()
        if PM.Enabled then return end
        PM.Enabled = true

        task.spawn(function()
            local all = Workspace:GetDescendants()
            for i = 1, #all, 200 do
                if not PM.Enabled then break end
                for j = i, math.min(i+199, #all) do optimizeObject(all[j]) end
                task.wait()
            end
        end)

        if LocalPlayer.Character then optimizeCharacter(LocalPlayer.Character) end

        table.insert(pmConnections, LocalPlayer.CharacterAdded:Connect(function(char)
            if PM.Enabled then task.wait(0.2) optimizeCharacter(char) end
        end))

        if Terrain then
            pcall(function()
                originalStates.waterProperties = {
                    WaterReflectance = Terrain.WaterReflectance,
                    WaterWaveSize = Terrain.WaterWaveSize,
                    WaterWaveSpeed = Terrain.WaterWaveSpeed,
                    WaterTransparency = Terrain.WaterTransparency
                }
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
                Terrain.Decoration = false
            end)
            local clouds = Terrain:FindFirstChildOfClass("Clouds")
            if clouds then clouds:Destroy() end
        end

        for _, sky in ipairs(Lighting:GetChildren()) do
            if sky:IsA("Sky") then
                sky.SkyboxBk="" sky.SkyboxDn="" sky.SkyboxFt=""
                sky.SkyboxLf="" sky.SkyboxRt="" sky.SkyboxUp=""
                sky.StarCount=0 sky.SunAngularSize=0 sky.MoonAngularSize=0
                sky.CelestialBodiesShown=false
            end
        end

        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then atmosphere:Destroy() end

        originalStates.lighting = {
            GlobalShadows = Lighting.GlobalShadows,
            Brightness = Lighting.Brightness,
            Technology = Lighting.Technology
        }
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 0
        Lighting.Brightness = 0
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.Technology = Enum.Technology.Legacy
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ShadowSoftness = 0

        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then effect.Enabled = false end
        end

        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        pcall(function()
            local cam = Workspace.CurrentCamera
            originalStates.camera = { FieldOfView = cam.FieldOfView }
            cam.FieldOfView = 70
        end)

        table.insert(pmConnections, Workspace.DescendantAdded:Connect(function(obj)
            if PM.Enabled then
                if shouldDestroy(obj) then safeDestroy(obj)
                else task.defer(optimizeObject, obj) end
            end
        end))

        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
        end)
    end

    function PM.Disable()
        if not PM.Enabled then return end
        PM.Enabled = false

        if Terrain and originalStates.waterProperties then
            pcall(function()
                Terrain.WaterReflectance = originalStates.waterProperties.WaterReflectance or 0
                Terrain.WaterWaveSize = originalStates.waterProperties.WaterWaveSize or 0
                Terrain.WaterWaveSpeed = originalStates.waterProperties.WaterWaveSpeed or 0
                Terrain.WaterTransparency = originalStates.waterProperties.WaterTransparency or 0
                Terrain.Decoration = true
            end)
        end

        if originalStates.lighting.GlobalShadows ~= nil then
            Lighting.GlobalShadows = originalStates.lighting.GlobalShadows
            Lighting.Brightness = originalStates.lighting.Brightness
            Lighting.Technology = originalStates.lighting.Technology
        end

        if originalStates.camera.FieldOfView then
            pcall(function() Workspace.CurrentCamera.FieldOfView = originalStates.camera.FieldOfView end)
        end

        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
        end)

        for _, conn in ipairs(pmConnections) do conn:Disconnect() end
        pmConnections = {}
        processedObjects = setmetatable({}, {__mode = "k"})
        originalStates = { lighting = {}, waterProperties = {}, camera = {} }
        pcall(function() collectgarbage("collect") end)
    end

    return PM
end)()

-- =============================================
-- DISABLE RENDERING MODULE
-- =============================================

DisableRendering = (function()
    local DR = {}
    DR.Enabled = false
    local renderConn = nil

    function DR.Start()
        if DR.Enabled then return end
        DR.Enabled = true
        renderConn = RunService.RenderStepped:Connect(function()
            pcall(function() RunService:Set3dRenderingEnabled(false) end)
        end)
    end

    function DR.Stop()
        if not DR.Enabled then return end
        DR.Enabled = false
        if renderConn then renderConn:Disconnect() renderConn = nil end
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
    end

    return DR
end)()

-- =============================================
-- OFFICE MONITOR HUD  (blackout + panel progres)
-- =============================================
-- Layar ditutup total hitam supaya cara kerja job tidak bisa dilihat/ditiru,
-- tapi user tetap tahu progresnya dari panel 2D. GUI 2D tetap ter-render
-- walau 3D rendering dimatikan.
--
-- Panel: layout grid (menyamping, bukan list panjang ke bawah), bisa digeser,
-- dan ukurannya menyesuaikan layar HP maupun PC secara otomatis.

OfficeMonitor = (function()
    local OM = {}
    OM.Active     = false
    OM.Peeking    = false
    OM.StartedAt  = 0
    OM.LastPeek   = -1e9
    OM.MoneyStart = nil   -- uang awal versi HUD (dipakai kalau webhook Office mati)
    OM.DX         = 0     -- offset geser panel (dari tengah layar)
    OM.DY         = 0

    local REVEAL_TIME   = 5    -- lama layar dibuka saat Show Progress ditekan
    local COOLDOWN_TIME = 30   -- jeda sebelum tombol bisa ditekan lagi

    local ACCENT = Color3.fromRGB(119, 117, 242)
    local PANELC = Color3.fromRGB(14, 8, 28)
    local CELLC  = Color3.fromRGB(24, 15, 45)
    local OKC    = Color3.fromRGB(70, 200, 120)
    local WARNC  = Color3.fromRGB(230, 170, 50)
    local DIMC   = Color3.fromRGB(155, 150, 180)
    local OFFC   = Color3.fromRGB(200, 70, 70)
    local WHITEC = Color3.fromRGB(240, 240, 250)

    local UIS = game:GetService("UserInputService")

    local gui, cover, panel, dot, hint, dragLayer
    local moneyHolder, statsHolder, moneyLayout, statsLayout
    local bigNow, bigProfit
    local rows       = {}
    local hbConn     = nil
    local viewConn   = nil
    local acc        = 0
    local STAT_COUNT = 7

    local function getParent()
        local ok, res = pcall(function()
            if gethui then return gethui() end
            return game:GetService("CoreGui")
        end)
        if ok and res then return res end
        return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    local function mk(class, props)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        return o
    end

    local function corner(parent, r)
        mk("UICorner", { CornerRadius = UDim.new(0, r), Parent = parent })
    end

    -- Sumber uang sama persis dengan sendOfficeWebhook.
    local function readMoney()
        local label = nil
        pcall(function()
            label = LocalPlayer:WaitForChild("PlayerGui").MainUI.Frame4.TextLabel
        end)
        if not label then return nil end
        local ok, num = pcall(parseUang, label.Text)
        if ok then return num end
        return nil
    end

    local function fmtClock(sec)
        sec = math.max(0, math.floor(sec or 0))
        return string.format("%02d:%02d", math.floor(sec / 60), sec % 60)
    end

    local function viewport()
        local cam = workspace.CurrentCamera
        if cam then return cam.ViewportSize end
        return Vector2.new(900, 600)
    end

    -- sel statistik kecil: label kiri, nilai kanan
    local function addStat(key, label, order)
        local cell = mk("Frame", {
            Name = key, Parent = statsHolder, BackgroundColor3 = CELLC,
            BorderSizePixel = 0, LayoutOrder = order, ZIndex = 12,
        })
        corner(cell, 8)
        mk("UIPadding", {
            Parent = cell,
            PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9),
        })
        mk("TextLabel", {
            Parent = cell, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0),
            Font = Enum.Font.Gotham, Text = label, TextSize = 12, TextColor3 = DIMC,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 13,
        })
        rows[key] = mk("TextLabel", {
            Name = "Value", Parent = cell, BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0),
            Font = Enum.Font.GothamBold, Text = "-", TextSize = 12, TextColor3 = WHITEC,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 13,
        })
    end

    -- kartu besar buat angka uang
    local function addBig(label, order, valueColor)
        local card = mk("Frame", {
            Parent = moneyHolder, BackgroundColor3 = CELLC, BorderSizePixel = 0,
            LayoutOrder = order, ZIndex = 12,
        })
        corner(card, 10)
        mk("UIStroke", { Parent = card, Color = ACCENT, Thickness = 1, Transparency = 0.6 })
        mk("UIPadding", {
            Parent = card,
            PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 7),
        })
        mk("TextLabel", {
            Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
            Font = Enum.Font.Gotham, Text = label, TextSize = 11, TextColor3 = DIMC,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
        })
        return mk("TextLabel", {
            Name = "Value", Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 16), Size = UDim2.new(1, 0, 0, 24),
            Font = Enum.Font.GothamBold, Text = "-", TextSize = 17,
            TextColor3 = valueColor or WHITEC,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 13,
        })
    end

    -- jaga panel tetap di dalam layar setelah digeser / layar diputar
    local function clampPos()
        if not panel then return end
        local vp = viewport()
        local sz = panel.AbsoluteSize
        if sz.X < 1 then sz = Vector2.new(panel.Size.X.Offset, panel.Size.Y.Offset) end
        local maxX = math.max(0, (vp.X - sz.X) / 2 - 6)
        local maxY = math.max(0, (vp.Y - sz.Y) / 2 - 6)
        OM.DX = math.clamp(OM.DX, -maxX, maxX)
        OM.DY = math.clamp(OM.DY, -maxY, maxY)
        panel.Position = UDim2.new(0.5, OM.DX, 0.5, OM.DY)
    end

    -- hitung ulang ukuran: 2 kolom di layar lebar, 1 kolom di HP sempit
    local function relayout()
        if not panel then return end

        local vp    = viewport()
        local w     = math.clamp(math.floor(vp.X * 0.92), 300, 470)
        local inner = w - 28
        local two   = inner >= 350

        local statW    = two and math.floor((inner - 6) / 2) or inner
        local statLine = two and math.ceil(STAT_COUNT / 2) or STAT_COUNT
        statsLayout.CellSize = UDim2.fromOffset(statW, 32)
        local statsH = statLine * 32 + math.max(0, statLine - 1) * 6

        local moneyW    = two and math.floor((inner - 6) / 2) or inner
        local moneyLine = two and 1 or 2
        moneyLayout.CellSize = UDim2.fromOffset(moneyW, 50)
        local moneyH = moneyLine * 50 + math.max(0, moneyLine - 1) * 6

        moneyHolder.Size     = UDim2.new(1, 0, 0, moneyH)
        statsHolder.Position = UDim2.new(0, 0, 0, 44 + moneyH + 8)
        statsHolder.Size     = UDim2.new(1, 0, 0, statsH)

        panel.Size = UDim2.fromOffset(w, 14 + 44 + moneyH + 8 + statsH + 8 + 16 + 12)
        clampPos()
    end

    local function build()
        if gui then return end

        gui = mk("ScreenGui", {
            Name = "VypersOfficeHUD", ResetOnSpawn = false,
            IgnoreGuiInset = true, DisplayOrder = 998,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Enabled = false, Parent = getParent(),
        })
        gui:SetAttribute("VyperWindow", true)

        cover = mk("Frame", {
            Name = "Blackout", Parent = gui, BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 1,
        })

        panel = mk("Frame", {
            Name = "Panel", Parent = gui, BackgroundColor3 = PANELC,
            BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(420, 300),
            ZIndex = 10,
        })
        corner(panel, 14)
        mk("UIStroke", { Parent = panel, Color = ACCENT, Thickness = 1.4, Transparency = 0.25 })
        mk("UIPadding", {
            Parent = panel,
            PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
        })

        -- header
        local head = mk("Frame", {
            Parent = panel, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40), ZIndex = 11,
        })
        dot = mk("Frame", {
            Parent = head, BackgroundColor3 = OKC, BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0, 9),
            Size = UDim2.fromOffset(9, 9), ZIndex = 12,
        })
        corner(dot, 5)
        mk("TextLabel", {
            Parent = head, BackgroundTransparency = 1,
            Position = UDim2.new(0, 17, 0, 0), Size = UDim2.new(1, -17, 0, 20),
            Font = Enum.Font.GothamBold, Text = "KING VYPERS — OFFICE MONITOR",
            TextSize = 14, TextColor3 = WHITEC,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 12,
        })
        mk("TextLabel", {
            Parent = head, BackgroundTransparency = 1,
            Position = UDim2.new(0, 17, 0, 19), Size = UDim2.new(1, -17, 0, 15),
            Font = Enum.Font.Gotham, Text = "Layar dikunci — tahan & geser panel ini",
            TextSize = 11, TextColor3 = DIMC,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 12,
        })

        -- kartu uang (menyamping)
        moneyHolder = mk("Frame", {
            Name = "Money", Parent = panel, BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 44), Size = UDim2.new(1, 0, 0, 50), ZIndex = 11,
        })
        moneyLayout = mk("UIGridLayout", {
            Parent = moneyHolder, CellPadding = UDim2.fromOffset(6, 6),
            CellSize = UDim2.fromOffset(200, 50),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        bigNow    = addBig("UANG SEKARANG", 1, WHITEC)
        bigProfit = addBig("TOTAL PROFIT",  2, OKC)

        -- grid statistik (auto 2 kolom / 1 kolom)
        statsHolder = mk("Frame", {
            Name = "Stats", Parent = panel, BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 102), Size = UDim2.new(1, 0, 0, 120), ZIndex = 11,
        })
        statsLayout = mk("UIGridLayout", {
            Parent = statsHolder, CellPadding = UDim2.fromOffset(6, 6),
            CellSize = UDim2.fromOffset(196, 32),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        addStat("status",   "Status",       1)
        addStat("cycle",    "Cycle",        2)
        addStat("runtime",  "Runtime",      3)
        addStat("idle",     "Idle",         4)
        addStat("uangAwal", "Uang Awal",    5)   -- uang saat Auto Office diaktifkan
        addStat("restart",  "Auto Restart", 6)
        addStat("render",   "Render 3D",    7)

        hint = mk("TextLabel", {
            Name = "Hint", Parent = panel, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 16),
            Font = Enum.Font.Gotham,
            Text = "Show Progress ada di window — buka game 5 detik",
            TextSize = 11, TextColor3 = DIMC,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 12,
        })

        -- lapisan geser: panel tidak punya tombol, jadi seluruh area bisa didrag
        dragLayer = mk("TextButton", {
            Name = "DragLayer", Parent = panel, BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, Active = true,
            Size = UDim2.new(1, 28, 1, 24), Position = UDim2.new(0, -14, 0, -12),
            ZIndex = 60,
        })

        local dragging, startInput, baseX, baseY = false, nil, 0, 0
        dragLayer.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging   = true
                startInput = input.Position
                baseX, baseY = OM.DX, OM.DY
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - startInput
                OM.DX = baseX + d.X
                OM.DY = baseY + d.Y
                clampPos()
            end
        end)

        -- ikut menyesuaikan kalau layar diputar / resolusi berubah
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then
                viewConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(relayout)
            end
        end)

        relayout()
    end

    local function setRow(key, text, color)
        local v = rows[key]
        if v then
            v.Text = text
            v.TextColor3 = color or WHITEC
        end
    end

    local function refresh()
        if not OM.Active or not gui then return end

        local running = false
        pcall(function() running = OfficeModule:IsRunning() and true or false end)
        setRow("status", running and "BERJALAN" or "BERHENTI", running and OKC or OFFC)
        setRow("cycle", tostring(OfficeModule.totalCycle or 0) .. "x", ACCENT)
        setRow("runtime", fmtClock(tick() - OM.StartedAt))

        local idle = 0
        if (OfficeModule.lastActivity or 0) > 0 then
            idle = tick() - OfficeModule.lastActivity
        end
        local tmax = OfficeModule.timeoutMax or 300
        setRow("idle", fmtClock(idle), idle > (tmax * 0.6) and WARNC or DIMC)

        if OfficeModule.timeoutEnabled then
            setRow("restart", "ON / " .. tostring(math.floor(tmax)) .. "s", OKC)
        else
            setRow("restart", "OFF", DIMC)
        end

        local peeking = OM.Peeking
        setRow("render", peeking and "ON" or "OFF", peeking and WARNC or OKC)

        -- ---- UANG & PROFIT ----
        local now = readMoney()
        if now then
            -- Uang Awal = uang tepat saat Auto Office diaktifkan (dipatok di OM.Show).
            -- Kalau saat itu label uang belum ke-load, baseline diambil dari
            -- pembacaan pertama yang berhasil.
            if OM.MoneyStart == nil then OM.MoneyStart = now end
            local base   = OM.MoneyStart
            local profit = now - base   -- profit = uang sekarang - uang awal

            setRow("uangAwal", formatUang(base), DIMC)
            bigNow.Text = formatUang(now)

            if profit > 0 then
                bigProfit.Text = "+ " .. formatUang(profit)
                bigProfit.TextColor3 = OKC
            elseif profit < 0 then
                bigProfit.Text = "- " .. formatUang(math.abs(profit))
                bigProfit.TextColor3 = OFFC
            else
                bigProfit.Text = formatUang(0)
                bigProfit.TextColor3 = DIMC
            end
        else
            setRow("uangAwal", "n/a", WARNC)
            bigNow.Text = "tidak terbaca"
            bigNow.TextColor3 = WARNC
            bigProfit.Text = "-"
            bigProfit.TextColor3 = DIMC
        end

        -- ---- HINT BAWAH ----
        if hint then
            if peeking then
                local left = REVEAL_TIME - (tick() - OM.LastPeek)
                hint.Text = string.format("LAYAR TERBUKA — nutup lagi %ds", math.max(0, math.ceil(left)))
                hint.TextColor3 = WARNC
            else
                local left = COOLDOWN_TIME - (tick() - OM.LastPeek)
                if left > 0 then
                    hint.Text = string.format("Show Progress cooldown — %ds", math.ceil(left))
                else
                    hint.Text = "Show Progress ada di window — buka game 5 detik"
                end
                hint.TextColor3 = DIMC
            end
        end

        if dot then
            dot.BackgroundColor3 = running and OKC or OFFC
            dot.BackgroundTransparency = (math.sin(tick() * 3) > 0) and 0 or 0.6
        end
    end

    -- Buka layar 5 detik, cooldown 30 detik. return ok, sisaCooldown
    function OM.Peek()
        if not OM.Active then return false, 0 end
        if OM.Peeking then return false, 0 end

        local left = COOLDOWN_TIME - (tick() - OM.LastPeek)
        if left > 0 then return false, math.ceil(left) end

        OM.LastPeek = tick()
        OM.Peeking  = true
        if cover then cover.Visible = false end
        pcall(function() DisableRendering.Stop() end)

        task.delay(REVEAL_TIME, function()
            OM.Peeking = false
            if OM.Active then
                if cover then cover.Visible = true end
                pcall(function() DisableRendering.Start() end)
            end
        end)
        return true, 0
    end

    function OM.PeekCooldown()
        local left = COOLDOWN_TIME - (tick() - OM.LastPeek)
        return left > 0 and math.ceil(left) or 0
    end

    function OM.Show()
        build()
        OM.Active     = true
        OM.StartedAt  = tick()
        OM.Peeking    = false
        -- Patok uang awal PERSIS saat Auto Office dinyalakan.
        -- Kalau masih nil (UI game belum load), refresh() bakal ngisi otomatis
        -- pada pembacaan pertama yang berhasil.
        OM.MoneyStart = readMoney()
        if cover then cover.Visible = true end
        gui.Enabled = true

        pcall(function() DisableRendering.Start() end)
        relayout()

        if not hbConn then
            hbConn = RunService.Heartbeat:Connect(function(dt)
                acc = acc + dt
                if acc < 0.2 then return end
                acc = 0
                if not isAlive() then
                    if hbConn then hbConn:Disconnect() hbConn = nil end
                    return
                end
                refresh()
            end)
        end
        refresh()
    end

    function OM.Hide()
        OM.Active  = false
        OM.Peeking = false
        if hbConn then hbConn:Disconnect() hbConn = nil end
        if gui then gui.Enabled = false end
        if cover then cover.Visible = false end
        pcall(function() DisableRendering.Stop() end)
    end

    return OM
end)()

-- =============================================
-- UNLOCK FPS MODULE
-- =============================================

local UnlockFPS = (function()
    local UF = {}
    UF.Enabled = false
    UF.CurrentCap = 60

    function UF.SetCap(fps)
        UF.CurrentCap = fps
        if UF.Enabled and setfpscap then setfpscap(fps) end
    end

    function UF.Start()
        if UF.Enabled then return end
        UF.Enabled = true
        if setfpscap then setfpscap(UF.CurrentCap) end
    end

    function UF.Stop()
        if not UF.Enabled then return end
        UF.Enabled = false
        if setfpscap then setfpscap(60) end
    end

    return UF
end)()

-- =============================================
-- GUI - TAB SETTINGS
-- =============================================

FreecamTab = Window:Tab({
    Title = "Settings",
	Border = true,
})

HideStatsSection = FreecamTab:Section({ Title = "Hide Stats", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = false })

hideStatsToggle = HideStatsSection:Toggle({
    Title = "Enable Hide Stats",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.HideStats = on
            saveUIConfig(uiConfig)
        end
        if on then HideStats.Enable() else HideStats.Disable() end
    end
})

fakeNameInput = HideStatsSection:Input({
    Type = "Input",
    Title = "Fake Name",
    Value = uiConfig.FakeName or "King Vypers",
    Placeholder = "Nama palsu",
    Callback = function(value)
        HideStats.SetFakeName(value)
        if not isUILoading then
            uiConfig.FakeName = value
            saveUIConfig(uiConfig)
        end
    end
})
HideStats.SetFakeName(uiConfig.FakeName or "King Vypers")

fakeRankInput = HideStatsSection:Input({
    Type = "Input",
    Title = "Fake Rank",
    Value = uiConfig.FakeRank or "King Vypers 👑",
    Placeholder = "Rank palsu",
    Callback = function(value)
        HideStats.SetFakeRank(value)
        if not isUILoading then
            uiConfig.FakeRank = value
            saveUIConfig(uiConfig)
        end
    end
})
HideStats.SetFakeRank(uiConfig.FakeRank or "King Vypers 👑")

-- =============================================
-- GUI - PERFORMANCE SECTION (di Settings tab)
-- =============================================

PerformanceSection = FreecamTab:Section({ Title = "Performance", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = false })

potatoToggle = PerformanceSection:Toggle({
    Title = "FPS Booster (Potato Mode)",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.PotatoMode = on
            saveUIConfig(uiConfig)
        end
        if on then PotatoMode.Enable() else PotatoMode.Disable() end
    end
})

disableRenderToggle = PerformanceSection:Toggle({
    Title = "Disable 3D Rendering",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.DisableRendering = on
            saveUIConfig(uiConfig)
        end
        if on then DisableRendering.Start() else DisableRendering.Stop() end
    end
})

local selectedFpsCap = 60

fpscapDropdown = PerformanceSection:Dropdown({
    Title = "FPS Cap",
    Options = {"60", "90", "120", "240"},
    Value = uiConfig.FpsCap or "60",
    Callback = function(value)
        selectedFpsCap = tonumber(value) or 60
        UnlockFPS.SetCap(selectedFpsCap)
        if not isUILoading then
            uiConfig.FpsCap = value
            saveUIConfig(uiConfig)
        end
    end
})
selectedFpsCap = tonumber(uiConfig.FpsCap) or 60

fpsUnlockToggle = PerformanceSection:Toggle({
    Title = "Enable FPS Unlock",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.FpsUnlock = on
            saveUIConfig(uiConfig)
        end
        if on then
            UnlockFPS.CurrentCap = selectedFpsCap
            UnlockFPS.Start()
        else
            UnlockFPS.Stop()
        end
    end
})

-- =============================================
-- GUI - PROTECTION SECTION (di Settings tab)
-- =============================================

ProtectionSection = FreecamTab:Section({ Title = "Protection", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = false })

antiAfkToggle = ProtectionSection:Toggle({
    Title = "Anti-AFK",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.AntiAFK = on
            saveUIConfig(uiConfig)
        end
        if on then AntiAFK.Start() else AntiAFK.Stop() end
    end
})

antiStaffToggle = ProtectionSection:Toggle({
    Title = "Anti Staff (Auto Kick)",
    Value = false,
    Callback = function(on)
        if not isUILoading then
            uiConfig.AntiStaff = on
            saveUIConfig(uiConfig)
        end
        if on then AntiStaff.Start() else AntiStaff.Stop() end
    end
})

-- =============================================
-- GUI - AUTO RECONNECT + AUTO EXECUTE SECTION
-- =============================================


local function saveSettingsConfig(data) end

local settingsConfig = {}
local isSettingsLoading = true

ReconnectSection = FreecamTab:Section({ Title = "Auto Reconnect & Execute", Box = true, TextXAlignment = "Center", TextSize = 15, Opened = false })

-- Toggle combined: Auto Reconnect
reconnectToggle = ReconnectSection:Toggle({
    Title = "Enable Auto Reconnect",
    Value = false,
    Callback = function(on)
        if not isSettingsLoading then
            settingsConfig.AutoReconnect = on
            saveSettingsConfig(settingsConfig)
        end
        if on then
            AutoRejoin.Start()
        else
            AutoRejoin.Stop()
        end
    end
})

-- Toggle: Auto Execute setelah rejoin
-- Kalau ON, script King Vypers akan otomatis ke-load lagi setelah rejoin
autoExecToggle = ReconnectSection:Toggle({
    Title = "Auto Execute Setelah Rejoin",
    Value = false,
    Callback = function(on)
        if not isSettingsLoading then
            settingsConfig.AutoExecute = on
            saveSettingsConfig(settingsConfig)
        end
        if on then
            if AutoRejoin.IsQueueSupported() then
                AutoRejoin.EnableAutoExec()
            else
                -- Executor tidak support queue_on_teleport, fitur tidak akan jalan
                -- Toggle tetap bisa di-ON tapi tidak akan ada efek
                AutoRejoin.EnableAutoExec()
            end
        else
            AutoRejoin.DisableAutoExec()
        end
    end
})

task.spawn(function()
    task.wait(0.5)

    -- Restore manual dari file JSON lama SUDAH DIHAPUS.
    -- Semua nilai toggle/slider/input/dropdown sekarang di-restore otomatis oleh
    -- config system VypersLib44 (Vypers:EnableConfig di bagian paling bawah file),
    -- yang juga mem-fire ulang Callback-nya jadi fiturnya benar-benar jalan lagi.
    isBLoading        = false
    isOLoading        = false
    isSettingsLoading = false
    isUILoading = false
end)

-- ================================================================
--  TAB TAMBAHAN: FITUR NATIVE VYPERSLIB44
--  (config system, keybind, accent color, dialog, popup, developer
--   card, tag, code block, paragraph, button row, divider)
-- ================================================================
pcall(function()
    local UITab = VWindow:CreateTab({ Title = "UI Vypers" })

    -- ---- WINDOW & TEMA ----
    local winSec = UITab:CreateSection({ Title = "Window & Tema", Box = true, Opened = true })

    pcall(function()
        winSec:CreateDeveloper({
            Id      = "devcard",
            Name    = "King Vypers",
            Caption = "DDS Premium Script • VypersUI V0.4",
            Image   = "rbxassetid://139467646163013",
            Accent  = Purple,
        })
    end)

    winSec:CreateKeybind({
        Id      = "ui_togglekey",
        Title   = "Keybind Buka/Tutup UI",
        Desc    = "Default RightShift. Klik untuk ganti tombol.",
        Default = Enum.KeyCode.RightShift,
        Callback = function()
            VWindow:Toggle()
        end,
    })

    winSec:CreateButtonRow({ Buttons = {
        { Title = "Sembunyikan UI", Callback = function() VWindow:Hide() end },
        { Title = "Tampilkan UI",   Color = Purple, Callback = function() VWindow:Unhide() end },
    } })

    -- ---- CONFIG SYSTEM VYPERS ----
    local cfgSec = UITab:CreateSection({ Title = "Config Vypers", Box = true, Opened = false })

    local autoSaveToggle = cfgSec:CreateToggle({
        Id = "ui_autosave", Title = "Auto Save Config", Default = true,
        Desc = "Aktif dari awal. Semua perubahan langsung kesimpen.",
        Callback = function(state)
            Vypers:AutoSave(state, "default")
        end,
    })

    cfgSec:CreateButtonRow({ Buttons = {
        { Title = "Save Config", Color = Purple, Callback = function()
            Vypers:SaveConfig("default")
            Vypers:Notify({ Title = "Config", Content = "Config berhasil disimpan.", Type = "success" })
        end },
        { Title = "Load Config", Callback = function()
            Vypers:LoadConfig("default")
            Vypers:Notify({ Title = "Config", Content = "Config berhasil dimuat.", Type = "info" })
        end },
    } })

    -- ---- SHARE CONFIG ANTAR USER ----
    cfgSec:CreateDivider()

    cfgSec:CreateParagraph({
        Title = "Share Config ke Teman",
        Text  = "Cara pakai: tekan Copy JSON buat nyalin semua setting lu, kirim teksnya ke "
             .. "teman. Teman lu tinggal paste ke kolom di bawah, tekan Enter, lalu tekan "
             .. "Load Config dari JSON. Semua toggle, slider, input, dan dropdown langsung "
             .. "ikut setting lu dan fiturnya otomatis jalan.",
    })

    -- Sengaja TANPA Id supaya teks JSON yang panjang tidak ikut kesimpen ke config.
    local shareInput = cfgSec:CreateInput({
        Title       = "Tempel Config",
        Placeholder = '{"Race_Speed Hack":true, ...}',
        Default     = "",
    })

    cfgSec:CreateButtonRow({ Buttons = {
        { Title = "Load Config dari JSON", Color = Purple, Callback = function()
            local json = ""
            pcall(function() json = shareInput.Get() or "" end)
            json = tostring(json):match("^%s*(.-)%s*$")
            if json == "" then
                Vypers:Notify({ Title = "Share Config", Content = "Kolom JSON masih kosong. Paste dulu config temen lu.", Type = "warning" })
                return
            end
            local ok, err = Vypers:LoadConfigFromJSON(json)
            if ok then
                pcall(function() Vypers:SaveConfig("default") end)
                Vypers:Notify({ Title = "Share Config", Content = "Config temen berhasil dipakai dan langsung disimpan.", Type = "success", Duration = 5 })
            else
                Vypers:Notify({ Title = "Share Config", Content = "Gagal: " .. tostring(err or "JSON tidak valid") .. ". Pastikan teksnya kecopy penuh.", Type = "error", Duration = 6 })
            end
        end },
        { Title = "Bersihkan Kolom", Callback = function()
            pcall(function() shareInput.Set("") end)
        end },
    } })

    cfgSec:CreateButtonRow({ Buttons = {
        { Title = "Copy JSON", Callback = function()
            local json = Vypers:GetConfigJSON()
            if setclipboard then pcall(setclipboard, json) end
            Vypers:Notify({ Title = "Config", Content = "JSON config dicopy. Kirim teksnya ke temen lu.", Type = "info", Duration = 5 })
        end },
        { Title = "Reset Config", Color = Color3.fromRGB(200, 70, 70), Callback = function()
            Vypers:Dialog({
                Title = "Reset Config",
                Content = "Yakin mau reset semua pengaturan UI ke default?",
                Buttons = {
                    { Title = "Batal" },
                    { Title = "Reset", Variant = "Primary", Callback = function()
                        Vypers:ResetConfig()
                        -- PENTING: ResetConfig cuma balikin nilai di memori. Tanpa
                        -- SaveConfig, file default.json masih isi setting lama, jadi
                        -- pas execute ulang fiturnya nyala lagi. Ini yang bikin bug
                        -- "udah reset tapi Auto Office nyala sendiri".
                        local okSave = pcall(function() Vypers:SaveConfig("default") end)
                        Vypers:Notify({
                            Title = "Config",
                            Content = okSave
                                and "Semua pengaturan direset dan file config ikut ditimpa."
                                or "Pengaturan direset, tapi file config gagal ditimpa.",
                            Type = "warning",
                            Duration = 5,
                        })
                    end },
                },
            })
        end },
    } })

    -- ---- DELETE CONFIG ----
    cfgSec:CreateDivider()

    cfgSec:CreateParagraph({
        Title = "Delete Config",
        Text  = "Hapus total file KingVypers/default.json dari executor. Bedanya sama Reset: "
             .. "Reset cuma balikin nilai ke default, sedangkan Delete benar-benar "
             .. "menghapus filenya, jadi pas execute berikutnya script mulai bersih "
             .. "seperti baru pertama kali dipakai.",
    })

    cfgSec:CreateButton({
        Title = "Delete Config",
        Color = Color3.fromRGB(200, 70, 70),
        Callback = function()
            Vypers:Dialog({
                Title = "Delete Config",
                Content = "Hapus permanen file config KingVypers/default.json? "
                       .. "Semua setting tersimpan hilang dan tidak bisa dibalikin.",
                Buttons = {
                    { Title = "Batal" },
                    { Title = "Hapus", Variant = "Primary", Callback = function()
                        -- Matikan auto save DULU, kalau tidak file-nya langsung
                        -- kebentuk lagi begitu ada element yang berubah.
                        Vypers:AutoSave(false, "default")
                        pcall(function() autoSaveToggle.Set(false) end)

                        local ok, removed = pcall(function()
                            local _, rm = Vypers:DeleteConfig("default")
                            return rm
                        end)

                        -- Balikin semua element ke default biar UI cocok sama
                        -- kondisi "config sudah tidak ada".
                        pcall(function() Vypers:ResetConfig() end)

                        if ok and removed then
                            Vypers:Notify({
                                Title = "Delete Config",
                                Content = "File config dihapus. Auto Save gw matikan biar nggak kebentuk lagi. Execute berikutnya mulai bersih.",
                                Type = "success",
                                Duration = 7,
                            })
                        else
                            Vypers:Notify({
                                Title = "Delete Config",
                                Content = "Tidak ada file config yang perlu dihapus (mungkin belum pernah disimpan atau executor tidak support delfile).",
                                Type = "info",
                                Duration = 6,
                            })
                        end
                    end },
                },
            })
        end,
    })

    -- ---- INFO & SUPPORT ----
    local infoSec = UITab:CreateSection({ Title = "Info & Support", Box = true, Opened = false })

    infoSec:CreateTag({ Id = "tag_ver",  Title = "Versi Script", Text = "DDS V1.5",    Color = Purple })
    infoSec:CreateTag({ Id = "tag_ui",   Title = "UI Library",   Text = "VypersLib44", Color = Color3.fromRGB(80, 190, 120) })
    infoSec:CreateTag({ Id = "tag_plan", Title = "Status",       Text = "PREMIUM",     Color = Color3.fromRGB(220, 180, 70) })
    infoSec:CreateDivider()
    infoSec:CreateSpace(6)
end)

-- ================================================================
--  FINISH LOADING -> TAMPILKAN WINDOW
-- ================================================================
pcall(function() Vypers:PreloadAssets(2) end)
pcall(function() Loader:Set(1, "Selesai") end)

-- ================================================================
--  CONFIG SYSTEM VYPERSLIB44 (pengganti semua config JSON lama)
--  Dipanggil PALING AKHIR setelah seluruh UI selesai dibangun, biar
--  semua element sudah ke-register dan callback-nya bisa di-replay.
-- ================================================================
task.spawn(function()
    task.wait(1.2)
    pcall(function()
        Vypers:EnableConfig("default")   -- load config tersimpan + auto save ON
    end)
    isUILoading        = false
    isJobLoading       = false
    isWhLoading        = false
    isWhCourierLoading = false
    isWhOfficeLoading  = false
    isBLoading         = false
    isOLoading         = false
    isSettingsLoading  = false
end)

Loader:Finish(function()
    VWindow:Show()
    Vypers:Notify({
        Title = "King Vypers",
        Content = "Script siap dipakai. Tekan RightShift atau ikon melayang buat buka/tutup UI.",
        Type = "success",
        Duration = 6,
    })
end)
