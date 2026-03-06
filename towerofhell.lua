local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- GUI
--------------------------------------------------

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Emfein Hub - Tower Of Hell",
    LoadingTitle = "TOH Helper",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local Settings = {
    Speed = 22,
    JumpPower = 85,
    AntiFall = true
}

--------------------------------------------------
-- APPLY CHARACTER STATS
--------------------------------------------------

local function applyStats(char)

    local humanoid = char:WaitForChild("Humanoid")

    humanoid.WalkSpeed = Settings.Speed
    humanoid.JumpPower = Settings.JumpPower

end

--------------------------------------------------
-- CHARACTER FIX
--------------------------------------------------

if LocalPlayer.Character then
    applyStats(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    applyStats(char)
end)

--------------------------------------------------
-- ANTI FALL HELPER
--------------------------------------------------

task.spawn(function()

    while task.wait(0.1) do

        if Settings.AntiFall and LocalPlayer.Character then

            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if root then

                local part = Instance.new("Part")
                part.Size = Vector3.new(8,1,8)
                part.Anchored = true
                part.Transparency = 1
                part.CanCollide = true
                part.Position = root.Position - Vector3.new(0,4,0)
                part.Parent = workspace

                game.Debris:AddItem(part,0.3)

            end

        end

    end

end)

--------------------------------------------------
-- GUI MENU
--------------------------------------------------

local MainTab = Window:CreateTab("Main")

MainTab:CreateSlider({
    Name = "Speed",
    Range = {16,60},
    Increment = 1,
    CurrentValue = 22,
    Callback = function(v)

        Settings.Speed = v

        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end

    end
})

MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50,120},
    Increment = 1,
    CurrentValue = 85,
    Callback = function(v)

        Settings.JumpPower = v

        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.JumpPower = v
        end

    end
})

MainTab:CreateToggle({
    Name = "Anti Fall Helper",
    CurrentValue = true,
    Callback = function(v)
        Settings.AntiFall = v
    end
})
