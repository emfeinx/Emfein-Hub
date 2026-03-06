local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Emfein Hub - Arsenal LOCK-ON",
   LoadingTitle = "Rage Execution",
   LoadingSubtitle = "v2.5 - Hedefe Kilitlen",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

local Settings = {
   LockOn = false, -- Otomatik Kilitlenme
   AimPart = "Head", -- Nereye kitlensin? (Head / HumanoidRootPart)
   FOV = 200,
   ShowFOV = true,
   Smoothing = 0, -- 0 olması anında yapışmasını sağlar (Rage)
   TeamCheck = true
}

-- [FOV Dairesi]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8

-- [EN YAKIN HEDEFİ BUL]
local function getTarget()
    local target = nil
    local shortestDistance = Settings.FOV

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
            
            -- Can kontrolü (Arsenal bazen ölü oyuncuları temizlemez)
            if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health <= 0 then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

            if magnitude < shortestDistance and onScreen then
                target = v
                shortestDistance = magnitude
            end
        end
    end
    return target
end

-- [HER KAREDE KİLİTLENME DÖNGÜSÜ]
game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

    if Settings.LockOn and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getTarget()
        if target then
            -- Smoothing 0 ise anında kilitlenir
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[Settings.AimPart].Position)
        end
    end
end)

-- [TABLAR]
local RageTab = Window:CreateTab("Rage/Kilit")

RageTab:CreateToggle({
   Name = "Düşmanlara Kitlen (Sağ Tık Tutunca)",
   CurrentValue = false,
   Callback = function(v) Settings.LockOn = v end
})

RageTab:CreateDropdown({
   Name = "Kilitlenme Bölgesi",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = "Head",
   Callback = function(v) Settings.AimPart = v end
})

RageTab:CreateSlider({
   Name = "Kilit Alanı (FOV)",
   Range = {50, 1000},
   Increment = 10,
   CurrentValue = 200,
   Callback = function(v) Settings.FOV = v end
})

RageTab:CreateToggle({
   Name = "Menzili Göster",
   CurrentValue = true,
   Callback = function(v) Settings.ShowFOV = v end
})

local Visuals = Window:CreateTab("Görsel")
Visuals:CreateToggle({
   Name = "Duvar Arkası Gör (Highlight)",
   CurrentValue = false,
   Callback = function(v)
      for _, p in pairs(Players:GetPlayers()) do
          if p ~= LocalPlayer and p.Character then
              if v then
                  local hi = p.Character:FindFirstChild("EmfeinESP") or Instance.new("Highlight", p.Character)
                  hi.Name = "EmfeinESP"
                  hi.FillColor = Color3.fromRGB(255, 0, 0)
                  hi.OutlineColor = Color3.fromRGB(255, 255, 255)
              else
                  if p.Character:FindFirstChild("EmfeinESP") then p.Character.EmfeinESP:Destroy() end
              end
          end
      end
   end
})

Rayfield:Notify({Title = "LOCK-ON MODU", Content = "Düşmana kilitlenme aktif!", Duration = 3})
