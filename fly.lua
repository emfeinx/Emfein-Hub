local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local FlyEnabled = false
local FlySpeed = 50

--------------------------------------------------
-- GUI LOAD
--------------------------------------------------

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Emfein Hub - Universal Fly",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local MainTab = Window:CreateTab("Fly")

--------------------------------------------------
-- FLY SYSTEM
--------------------------------------------------

local function enableFly()

    local character = LocalPlayer.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")

    if not root or not humanoid then return end

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(99999,99999,99999)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    local moveDirection = Vector3.zero

    RunService.RenderStepped:Connect(function()

        if not FlyEnabled then
            bodyVelocity:Destroy()
            return
        end

        local camCF = Camera.CFrame

        local forward = camCF.LookVector
        local right = camCF.RightVector

        moveDirection = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection += forward
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection -= forward
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection += right
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection -= right
        end

        bodyVelocity.Velocity = moveDirection * FlySpeed

    end)

end

--------------------------------------------------
-- GUI MENU
--------------------------------------------------

MainTab:CreateToggle({
    Name = "Fly Toggle",
    Callback = function(v)

        FlyEnabled = v

        if v then
            enableFly()
        end

    end
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20,120},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v)
        FlySpeed = v
    end
})
