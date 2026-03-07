local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Emfein Hub - Brookhaven",
   LoadingTitle = "Brookhaven RP Mod",
   LoadingSubtitle = "v2.0 Update",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

local Settings = {
   Fly = false,
   FlySpeed = 50,
   WalkSpeed = 16,
   SpeedHack = false,
   InfiniteJump = false,
   ESPBox = false,
   SelectedPlayer = "",
   Spin = false,
   SpinSpeed = 50,
   ClickTP = false,
   Noclip = false,
   Follow = false
}

-- PLAYER LIST
local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    if #list == 0 then table.insert(list,"Oyuncu Yok") end
    return list
end

-- ESP
local function createESP(player)

    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(0,255,0)
    box.Visible = false

    RunService.RenderStepped:Connect(function()

        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and Settings.ESPBox then

            local root = player.Character.HumanoidRootPart
            local pos,onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen then
                box.Size = Vector2.new(2000/pos.Z,3000/pos.Z)
                box.Position = Vector2.new(pos.X-box.Size.X/2,pos.Y-box.Size.Y/2)
                box.Visible = true
            else
                box.Visible = false
            end

        else
            box.Visible = false
        end

    end)

end

-- MOVEMENT TAB
local MovementTab = Window:CreateTab("Hareket")

-- FLY
MovementTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(v)

      Settings.Fly = v

      local char = LocalPlayer.Character
      if not char then return end

      local root = char:FindFirstChild("HumanoidRootPart")
      if not root then return end

      if v then

          local bv = Instance.new("BodyVelocity")
          bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
          bv.Parent = root

          local bg = Instance.new("BodyGyro")
          bg.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
          bg.Parent = root

          task.spawn(function()

              while Settings.Fly do

                  local moveDir = Vector3.zero
                  local cam = Camera.CFrame

                  if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                      moveDir += cam.LookVector
                  end

                  if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                      moveDir -= cam.LookVector
                  end

                  if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                      moveDir -= cam.RightVector
                  end

                  if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                      moveDir += cam.RightVector
                  end

                  if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                      moveDir += Vector3.new(0,1,0)
                  end

                  if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                      moveDir -= Vector3.new(0,1,0)
                  end

                  bv.Velocity = moveDir * Settings.FlySpeed
                  bg.CFrame = Camera.CFrame

                  task.wait()

              end

              bv:Destroy()
              bg:Destroy()

          end)

      end

   end
})

-- SPEED
MovementTab:CreateSlider({
   Name = "Speed",
   Range = {16,250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v)

      Settings.WalkSpeed = v
      Settings.FlySpeed = v

      if Settings.SpeedHack and LocalPlayer.Character then
          LocalPlayer.Character.Humanoid.WalkSpeed = v
      end

   end
})

MovementTab:CreateToggle({
   Name = "Speed Hack",
   CurrentValue = false,
   Callback = function(v)

      Settings.SpeedHack = v

      if LocalPlayer.Character then
          LocalPlayer.Character.Humanoid.WalkSpeed = v and Settings.WalkSpeed or 16
      end

   end
})

-- INFINITE JUMP
MovementTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(v)
      Settings.InfiniteJump = v
   end
})

-- NOCLIP
MovementTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(v)
      Settings.Noclip = v
   end
})

RunService.Stepped:Connect(function()

    if Settings.Noclip and LocalPlayer.Character then

        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end

    end

end)

-- SPIN
MovementTab:CreateToggle({
   Name = "Spin",
   CurrentValue = false,
   Callback = function(v)
      Settings.Spin = v
   end
})

MovementTab:CreateSlider({
   Name = "Spin Speed",
   Range = {10,300},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v)
      Settings.SpinSpeed = v
   end
})

RunService.RenderStepped:Connect(function()

    if Settings.Spin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

        local root = LocalPlayer.Character.HumanoidRootPart
        root.CFrame = root.CFrame * CFrame.Angles(0,math.rad(Settings.SpinSpeed),0)

    end

end)

-- VISUAL
local VisualTab = Window:CreateTab("Görsel")

VisualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Callback = function(v)
      Settings.ESPBox = v
   end
})

-- TELEPORT
local TeleportTab = Window:CreateTab("Teleport")

local pDropdown = TeleportTab:CreateDropdown({
   Name = "Player",
   Options = getPlayerList(),
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Option)
      Settings.SelectedPlayer = Option[1]
   end
})

TeleportTab:CreateButton({
   Name = "Refresh Player List",
   Callback = function()
      pDropdown:Refresh(getPlayerList(),true)
   end
})

TeleportTab:CreateButton({
   Name = "Teleport To Player",
   Callback = function()

      local target = Players:FindFirstChild(Settings.SelectedPlayer)

      if target and target.Character then
          LocalPlayer.Character.HumanoidRootPart.CFrame =
          target.Character.HumanoidRootPart.CFrame * CFrame.new(0,3,0)
      end

   end
})

-- FOLLOW PLAYER
TeleportTab:CreateToggle({
   Name = "Follow Player",
   CurrentValue = false,
   Callback = function(v)
      Settings.Follow = v
   end
})

RunService.RenderStepped:Connect(function()

    if Settings.Follow then

        local target = Players:FindFirstChild(Settings.SelectedPlayer)

        if target and target.Character and LocalPlayer.Character then

            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")

            if root and targetRoot then
                root.CFrame = targetRoot.CFrame * CFrame.new(0,0,3)
            end

        end

    end

end)

-- CLICK TELEPORT
TeleportTab:CreateToggle({
   Name = "Click Teleport",
   CurrentValue = false,
   Callback = function(v)
      Settings.ClickTP = v
   end
})

mouse.Button1Down:Connect(function()

    if Settings.ClickTP and LocalPlayer.Character then

        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if root then
            root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
        end

    end

end)

-- INFINITE JUMP EVENT
UserInputService.JumpRequest:Connect(function()

    if Settings.InfiniteJump and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end

end)

-- INIT ESP
for _, p in pairs(Players:GetPlayers()) do
    createESP(p)
end

Players.PlayerAdded:Connect(createESP)
