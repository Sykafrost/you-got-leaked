-- Leaked by Y4ru at https://github.com/Sykafrost/you-got-leaked/shadowscripts
-- Using shitty ass vault ?
-- Script "dev": https://rscripts.net/@shadowscripts
-- ULTRA SCRIPT HUB - Made by Junejo
-- Game: Jump to Steal Brainrots

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- State Variables
local AutoCollectCash = false
local SpeedBoostEnabled = false
local FlyEnabled = false
local InfJumpEnabled = false

local NormalSpeed = 16
local BoostSpeed = 50
local FlySpeed = 60

-- Helpers
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function getHum()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum and SpeedBoostEnabled then
        hum.WalkSpeed = BoostSpeed
    end
end)

----------------------------------------------------------------
-- GUI Creation (Pixel-Perfect ULTRA SCRIPT HUB Design)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraScriptHub_Brainrots"
ScreenGui.ResetOnSpawn = false

-- Safe GUI Parent Resolution
local parentGui = nil
if gethui then
    pcall(function() parentGui = gethui() end)
end

if not parentGui then
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
        end
        parentGui = CoreGui
    end)
end

if not parentGui then
    pcall(function()
        parentGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    end)
end

-- Clean previous instance
pcall(function()
    if parentGui and parentGui:FindFirstChild("UltraScriptHub_Brainrots") then
        parentGui:FindFirstChild("UltraScriptHub_Brainrots"):Destroy()
    end
end)

ScreenGui.Parent = parentGui or LocalPlayer:FindFirstChildOfClass("PlayerGui")

-- Main Outer Frame (Compact exact design)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 275)
MainFrame.Position = UDim2.new(0.5, -160, 0.35, -137)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Header Title (Large & Prominent)
local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -50, 0, 35)
HeaderTitle.Position = UDim2.new(0, 16, 0, 10)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "JUMP TO STEAL BRAINROTS"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextSize = 16
HeaderTitle.Font = Enum.Font.SourceSansBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = MainFrame

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -34, 0, 10)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Container for Toggles (Clear gap below title)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -32, 0, 140)
Container.Position = UDim2.new(0, 16, 0, 54)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 7)
UIListLayout.Parent = Container

-- Footer Branding (Bold, Large & Clearly Distinct)
local FooterTitle = Instance.new("TextLabel")
FooterTitle.Size = UDim2.new(1, 0, 0, 22)
FooterTitle.Position = UDim2.new(0, 0, 1, -46)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "ULTRA SCRIPT HUB"
FooterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterTitle.TextSize = 17
FooterTitle.Font = Enum.Font.SourceSansBold
FooterTitle.Parent = MainFrame

local FooterSub = Instance.new("TextLabel")
FooterSub.Size = UDim2.new(1, 0, 0, 16)
FooterSub.Position = UDim2.new(0, 0, 1, -24)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Made by Junejo"
FooterSub.TextColor3 = Color3.fromRGB(150, 150, 150)
FooterSub.TextSize = 13
FooterSub.Font = Enum.Font.SourceSans
FooterSub.Parent = MainFrame

-- Helper Function for Checkbox Row (Exact UI Theme)
local function CreateToggleRow(name, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 27)
    Row.BackgroundTransparency = 1
    Row.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -35, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 225)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSansBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Checkbox = Instance.new("TextButton")
    Checkbox.Size = UDim2.new(0, 21, 0, 21)
    Checkbox.Position = UDim2.new(1, -23, 0.5, -10)
    Checkbox.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
    Checkbox.BorderColor3 = Color3.fromRGB(45, 48, 60)
    Checkbox.Text = ""
    Checkbox.AutoButtonColor = false
    Checkbox.Parent = Row

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Checkbox

    local CheckIcon = Instance.new("Frame")
    CheckIcon.Size = UDim2.new(1, -6, 1, -6)
    CheckIcon.Position = UDim2.new(0, 3, 0, 3)
    CheckIcon.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    CheckIcon.Visible = false
    CheckIcon.Parent = Checkbox

    local CheckIconCorner = Instance.new("UICorner")
    CheckIconCorner.CornerRadius = UDim.new(0, 2)
    CheckIconCorner.Parent = CheckIcon

    local toggled = false
    Checkbox.MouseButton1Click:Connect(function()
        toggled = not toggled
        CheckIcon.Visible = toggled
        callback(toggled)
    end)
end

----------------------------------------------------------------
-- Helper Interactions
----------------------------------------------------------------
local function triggerTouch(part)
    local root = getRoot()
    if root and part and part:IsA("BasePart") and firetouchinterest then
        firetouchinterest(root, part, 0)
        task.wait(0.01)
        firetouchinterest(root, part, 1)
    end
end

local function triggerPrompts(obj)
    for _, p in ipairs(obj:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            p.HoldDuration = 0
            if fireproximityprompt then
                fireproximityprompt(p, 0, true)
            end
        end
    end
end

local function triggerClicks(obj)
    for _, cd in ipairs(obj:GetDescendants()) do
        if cd:IsA("ClickDetector") and fireclickdetector then
            fireclickdetector(cd)
        end
    end
end

----------------------------------------------------------------
-- 1. Auto Collect Cash
----------------------------------------------------------------
CreateToggleRow("Auto Collect Cash", function(state)
    AutoCollectCash = state
    if AutoCollectCash then
        task.spawn(function()
            while AutoCollectCash do
                pcall(function()
                    local root = getRoot()
                    if not root then return end

                    -- Detect and collect floating Cash ($836, etc.) on BillboardGuis
                    for _, gui in ipairs(workspace:GetDescendants()) do
                        if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                            local hasCashText = false
                            for _, textLabel in ipairs(gui:GetDescendants()) do
                                if textLabel:IsA("TextLabel") then
                                    local txt = textLabel.Text
                                    if string.find(txt, "%$") and not string.find(string.lower(txt), "robux") and not string.find(string.lower(txt), "r%$") then
                                        hasCashText = true
                                        break
                                    end
                                end
                            end

                            if hasCashText then
                                local targetPart = gui.Adornee or gui.Parent
                                if targetPart and (targetPart:IsA("BasePart") or targetPart:IsA("Model")) then
                                    local part = targetPart:IsA("BasePart") and targetPart or targetPart:FindFirstChildWhichIsA("BasePart")
                                    if part then
                                        triggerTouch(part)
                                        triggerPrompts(targetPart)
                                        triggerClicks(targetPart)
                                    end
                                end
                            end
                        end
                    end

                    -- Touch base collector pads, beds, slots
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local lower = string.lower(obj.Name)
                            local parentLower = obj.Parent and string.lower(obj.Parent.Name) or ""
                            
                            if not string.find(lower, "group") and not string.find(lower, "wheel") and not string.find(lower, "spin") and not string.find(lower, "chest") then
                                if string.find(lower, "collector") 
                                    or string.find(lower, "cash") 
                                    or string.find(lower, "money") 
                                    or string.find(lower, "income") 
                                    or string.find(lower, "giver") 
                                    or string.find(lower, "bed") 
                                    or string.find(lower, "pad") 
                                    or string.find(lower, "slot") 
                                    or string.find(parentLower, "collector") 
                                    or string.find(parentLower, "slots") 
                                    or string.find(parentLower, "beds") then
                                    triggerTouch(obj)
                                    triggerPrompts(obj)
                                    triggerClicks(obj)
                                end
                            end
                        end
                    end

                    -- Fire Remotes
                    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                        if rem:IsA("RemoteEvent") then
                            local lower = string.lower(rem.Name)
                            if not string.find(lower, "group") and not string.find(lower, "spin") and not string.find(lower, "pass") then
                                if string.find(lower, "cash") or string.find(lower, "money") or string.find(lower, "income") or string.find(lower, "collect") or string.find(lower, "claim") or string.find(lower, "sell") then
                                    rem:FireServer()
                                    rem:FireServer(1)
                                end
                            end
                        elseif rem:IsA("RemoteFunction") then
                            local lower = string.lower(rem.Name)
                            if string.find(lower, "cash") or string.find(lower, "collect") or string.find(lower, "claim") then
                                pcall(function() rem:InvokeServer() end)
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

----------------------------------------------------------------
-- 2. WalkSpeed Boost (50)
----------------------------------------------------------------
CreateToggleRow("WalkSpeed Boost (50)", function(state)
    SpeedBoostEnabled = state
    local hum = getHum()
    if hum then
        if SpeedBoostEnabled then
            hum.WalkSpeed = BoostSpeed
        else
            hum.WalkSpeed = NormalSpeed
        end
    end
end)

----------------------------------------------------------------
-- 3. Fly Mode (Smooth Camera Flying)
----------------------------------------------------------------
local flyBodyVel, flyBodyGyro

CreateToggleRow("Fly Mode", function(state)
    FlyEnabled = state
    local char = LocalPlayer.Character
    local root = getRoot()
    local hum = getHum()

    if FlyEnabled and root and hum then
        -- Create Fly Controllers
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.Name = "UltraFlyVel"
        flyBodyVel.Velocity = Vector3.new(0, 0, 0)
        flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBodyVel.Parent = root

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.Name = "UltraFlyGyro"
        flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.CFrame = root.CFrame
        flyBodyGyro.Parent = root

        hum.PlatformStand = true

        task.spawn(function()
            while FlyEnabled and root and flyBodyVel and flyBodyGyro do
                local moveDir = Vector3.new(0, 0, 0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + Camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - Camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - Camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + Camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir = moveDir + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDir = moveDir - Vector3.new(0, 1, 0)
                end

                if moveDir.Magnitude > 0 then
                    flyBodyVel.Velocity = moveDir.Unit * FlySpeed
                else
                    flyBodyVel.Velocity = Vector3.new(0, 0, 0)
                end

                flyBodyGyro.CFrame = Camera.CFrame
                RunService.RenderStepped:Wait()
            end
        end)
    else
        if flyBodyVel then flyBodyVel:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end)

----------------------------------------------------------------
-- 4. Infinite Jump
----------------------------------------------------------------
CreateToggleRow("Infinite Jump", function(state)
    InfJumpEnabled = state
end)

UserInputService.JumpRequest:Connect(function()
    local hum = getHum()
    if InfJumpEnabled and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
