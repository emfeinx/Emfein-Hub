local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------
-- GUI
--------------------------------------------------

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Emfein Hub - Rivals ESP",
    LoadingTitle = "Rivals Helper Hub",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local Settings = {
    ESP = false
}

--------------------------------------------------
-- ESP SYSTEM
--------------------------------------------------

local function createESP(player)

    if player == LocalPlayer then return end

    local box = Drawing.new("Square")

    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(255,255,255)
    box.Visible = false

    RunService.RenderStepped:Connect(function()

        if not Settings.ESP then
            box.Visible = false
            return
        end

        if player.Character and
           player.Character:FindFirstChild("HumanoidRootPart") then

            local root = player.Character.HumanoidRootPart

            local pos, onScreen =
                Camera:WorldToViewportPoint(root.Position)

            if onScreen then

                local sizeX = 2000 / pos.Z
                local sizeY = 3000 / pos.Z

                box.Size = Vector2.new(sizeX, sizeY)

                box.Position = Vector2.new(
                    pos.X - sizeX / 2,
                    pos.Y - sizeY / 2
                )

                box.Visible = true

            else
                box.Visible = false
            end

        else
            box.Visible = false
        end

    end)

end

--------------------------------------------------
-- INIT PLAYERS
--------------------------------------------------

for _,v in pairs(Players:GetPlayers()) do
    createESP(v)
end

Players.PlayerAdded:Connect(createESP)

--------------------------------------------------
-- GUI MENU
--------------------------------------------------

local MainTab = Window:CreateTab("Main")

MainTab:CreateToggle({
    Name = "Box ESP",
    Callback = function(v)
        Settings.ESP = v
    end
})
