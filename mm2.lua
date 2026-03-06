local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Emfein Hub - MM2",
   LoadingTitle = "Murder Mystery 2",
   LoadingSubtitle = "Coin Walk Farm",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    CoinFarm = false,
    MurderESP = false,
    SheriffESP = false
}

-- ROLE TESPİTİ
local function getRole(player)

    if player.Backpack:FindFirstChild("Knife") or
       (player.Character and player.Character:FindFirstChild("Knife")) then
        return "Murderer"
    end

    if player.Backpack:FindFirstChild("Gun") or
       (player.Character and player.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    end

    return "Innocent"

end

-- ESP
local function createESP(player)

    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Visible = false

    RunService.RenderStepped:Connect(function()

        if not player.Character then return end

        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

        if onScreen then

            local role = getRole(player)

            if role == "Murderer" and Settings.MurderESP then
                box.Color = Color3.fromRGB(255,0,0)

            elseif role == "Sheriff" and Settings.SheriffESP then
                box.Color = Color3.fromRGB(0,0,255)

            else
                box.Visible = false
                return
            end

            box.Size = Vector2.new(2000/pos.Z,3000/pos.Z)
            box.Position = Vector2.new(pos.X-box.Size.X/2,pos.Y-box.Size.Y/2)

            box.Visible = true

        else
            box.Visible = false
        end

    end)

end

for _,p in pairs(Players:GetPlayers()) do
    createESP(p)
end

Players.PlayerAdded:Connect(createESP)

-- EN YAKIN COIN
local function getClosestCoin()

    local closest = nil
    local shortest = math.huge

    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _,v in pairs(workspace:GetDescendants()) do

        if v.Name == "Coin_Server" or v.Name == "CoinContainer" then

            for _,coin in pairs(v:GetChildren()) do

                if coin:IsA("Part") then

                    local dist = (root.Position - coin.Position).Magnitude

                    if dist < shortest then
                        shortest = dist
                        closest = coin
                    end

                end

            end

        end

    end

    return closest

end

-- COINE YÜRÜ
local function walkToCoin(coin)

    local char = LocalPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    humanoid:MoveTo(coin.Position)

end

-- COIN FARM
local function startCoinFarm()

    while Settings.CoinFarm do

        local coin = getClosestCoin()

        if coin then
            walkToCoin(coin)
        end

        task.wait(0.4)

    end

end

-- UI TAB
local MainTab = Window:CreateTab("Main")

MainTab:CreateToggle({
   Name = "Coin Farm (Walk)",
   CurrentValue = false,
   Callback = function(v)

        Settings.CoinFarm = v

        if v then
            task.spawn(startCoinFarm)
        end

   end
})

MainTab:CreateToggle({
   Name = "Murderer ESP",
   CurrentValue = false,
   Callback = function(v)

        Settings.MurderESP = v

   end
})

MainTab:CreateToggle({
   Name = "Sheriff ESP",
   CurrentValue = false,
   Callback = function(v)

        Settings.SheriffESP = v

   end
})

MainTab:CreateSlider({
   Name = "Speed",
   Range = {16,120},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v)

        local char = LocalPlayer.Character
        if char then
            char.Humanoid.WalkSpeed = v
        end

   end
})
