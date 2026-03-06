local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Emfein Hub - Brookhaven",
   LoadingTitle = "Brookhaven RP Mod",
   LoadingSubtitle = "v2.0 - Fix Update",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
   Fly = false,
   FlySpeed = 50,
   WalkSpeed = 16,
   SpeedHack = false,
   InfiniteJump = false,
   ESPBox = false,
   ESPTracer = false,
   SelectedPlayer = ""
}

-- [DÜZELTME] Oyuncu Listesi Fonksiyonu
local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    if #list == 0 then table.insert(list, "Oyuncu Yok") end
    return list
end

-- [ESP SİSTEMİ]
local function createESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Visible = false

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and Settings.ESPBox then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                box.Visible = true
            else box.Visible = false end
        else
            box.Visible = false
            if not player.Parent then connection:Disconnect(); box:Remove() end
        end
    end)
end

-- [HAREKET SEKEMESİ]
local MovementTab = Window:CreateTab("Hareket")

MovementTab:CreateToggle({
   Name = "Uçma (Fly)",
   CurrentValue = false,
   SectionParent = MovementTab,
   Info = "WASD ile kontrol edilir, durunca havada asılı kalır.", -- Toolbox Açıklaması
   Callback = function(v)
      Settings.Fly = v
      local char = LocalPlayer.Character
      if not char or not char:FindFirstChild("HumanoidRootPart") then return end
      local root = char.HumanoidRootPart
      
      if v then
          local bv = Instance.new("BodyVelocity", root)
          bv.Name = "FlyVel"
          bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
          
          local bg = Instance.new("BodyGyro", root)
          bg.Name = "FlyGyro"
          bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

          task.spawn(function()
              while Settings.Fly do
                  bv.Velocity = char.Humanoid.MoveDirection * Settings.FlySpeed
                  bg.CFrame = Camera.CFrame
                  task.wait()
              end
              bv:Destroy(); bg:Destroy()
          end)
      end
   end
})

MovementTab:CreateSlider({
   Name = "Hız Seviyesi",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Info = "Hem yürüme hem uçma hızını etkiler.",
   Callback = function(v) 
      Settings.WalkSpeed = v 
      Settings.FlySpeed = v
      if Settings.SpeedHack then LocalPlayer.Character.Humanoid.WalkSpeed = v end
   end
})

MovementTab:CreateToggle({
   Name = "Speed Hack",
   CurrentValue = false,
   Info = "Yürüme hızını aktifleştirir.",
   Callback = function(v)
      Settings.SpeedHack = v
      LocalPlayer.Character.Humanoid.WalkSpeed = v and Settings.WalkSpeed or 16
   end
})

MovementTab:CreateToggle({
   Name = "Sınırsız Zıplama",
   CurrentValue = false,
   Info = "Zıplama engelini kaldırır.",
   Callback = function(v) Settings.InfiniteJump = v end
})

-- [GÖRSEL SEKEMESİ]
local VisualTab = Window:CreateTab("Görsel")
VisualTab:CreateToggle({
   Name = "Oyuncu Kutuları (ESP)",
   CurrentValue = false,
   Info = "Oyuncuların yerini kutu içine alarak gösterir.",
   Callback = function(v) Settings.ESPBox = v end
})

-- [IŞINLANMA SEKEMESİ]
local TeleportTab = Window:CreateTab("Işınlanma")

local pDropdown = TeleportTab:CreateDropdown({
   Name = "Oyuncu Seçiniz",
   Options = getPlayerList(),
   CurrentOption = {""},
   MultipleOptions = false,
   Info = "Gitmek istediğiniz oyuncuyu listeden bulun.",
   Callback = function(Option)
      Settings.SelectedPlayer = Option[1]
   end
})

TeleportTab:CreateButton({
   Name = "Listeyi Güncelle",
   Info = "Yeni giren oyuncuları listeye eklemek için basın.",
   Callback = function()
      pDropdown:Refresh(getPlayerList(), true)
   end
})

TeleportTab:CreateButton({
   Name = "Seçili Kişiye Git",
   Info = "Seçtiğiniz oyuncunun yanına ışınlar.",
   Callback = function()
      local target = Players:FindFirstChild(Settings.SelectedPlayer)
      if target and target.Character then
          LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
      else
          Rayfield:Notify({Title = "Hata", Content = "Oyuncu seçilmedi veya oyunda değil!", Duration = 2})
      end
   end
})

-- [Zıplama Event]
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end
end)

-- Başlat
for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
