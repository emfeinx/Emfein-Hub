local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Emfein Hub",
   LoadingTitle = "Loading Hub",
   LoadingSubtitle = "v3",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
Fly=false,
FlySpeed=60,
WalkSpeed=16,
SpeedHack=false,
InfiniteJump=false,
ESPBox=false,
NameESP=false,
DistanceESP=false,
RainbowESP=false,
Spin=false,
SpinSpeed=30,
Noclip=false,
Follow=false,
FollowTarget=""
}

-- PLAYER LIST
local function getPlayers()
local t={}
for _,p in pairs(Players:GetPlayers()) do
if p~=LocalPlayer then
table.insert(t,p.Name)
end
end
return t
end

-- ESP
local function createESP(player)
if player==LocalPlayer then return end

local box=Drawing.new("Square")
box.Thickness=2
box.Color=Color3.fromRGB(0,255,0)
box.Filled=false
box.Visible=false

local name=Drawing.new("Text")
name.Size=16
name.Center=true
name.Outline=true
name.Visible=false

RunService.RenderStepped:Connect(function()

if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
box.Visible=false
name.Visible=false
return
end

local root=player.Character.HumanoidRootPart
local pos,onScreen=Camera:WorldToViewportPoint(root.Position)

if onScreen and Settings.ESPBox then

local size=Vector2.new(2000/pos.Z,3000/pos.Z)

box.Size=size
box.Position=Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
box.Visible=true

if Settings.RainbowESP then
box.Color=Color3.fromHSV(tick()%5/5,1,1)
end

local text=""

if Settings.NameESP then
text=player.Name
end

if Settings.DistanceESP then
local dist=math.floor((LocalPlayer.Character.HumanoidRootPart.Position-root.Position).Magnitude)
text=text.." ["..dist.."m]"
end

if text~="" then
name.Text=text
name.Position=Vector2.new(pos.X,pos.Y-size.Y/2-15)
name.Visible=true
else
name.Visible=false
end

else
box.Visible=false
name.Visible=false
end

end)

end

for _,p in pairs(Players:GetPlayers()) do
createESP(p)
end

Players.PlayerAdded:Connect(createESP)

-- ANTI AFK
LocalPlayer.Idled:Connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)

-- MOVEMENT TAB
local MovementTab=Window:CreateTab("Movement")

MovementTab:CreateToggle({
Name="Fly",
CurrentValue=false,
Callback=function(v)

Settings.Fly=v

local char=LocalPlayer.Character
if not char then return end
local root=char:FindFirstChild("HumanoidRootPart")

if v then

local bv=Instance.new("BodyVelocity",root)
bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
bv.Name="FlyVel"

local bg=Instance.new("BodyGyro",root)
bg.MaxTorque=Vector3.new(math.huge,math.huge,math.huge)
bg.Name="FlyGyro"

task.spawn(function()
while Settings.Fly do
bv.Velocity=Camera.CFrame.LookVector*Settings.FlySpeed
bg.CFrame=Camera.CFrame
task.wait()
end
bv:Destroy()
bg:Destroy()
end)

end

end
})

MovementTab:CreateSlider({
Name="Fly Speed",
Range={10,200},
Increment=1,
CurrentValue=60,
Callback=function(v)
Settings.FlySpeed=v
end
})

MovementTab:CreateToggle({
Name="Speed Hack",
CurrentValue=false,
Callback=function(v)
Settings.SpeedHack=v
if v then
LocalPlayer.Character.Humanoid.WalkSpeed=Settings.WalkSpeed
else
LocalPlayer.Character.Humanoid.WalkSpeed=16
end
end
})

MovementTab:CreateSlider({
Name="Walk Speed",
Range={16,200},
Increment=1,
CurrentValue=16,
Callback=function(v)
Settings.WalkSpeed=v
if Settings.SpeedHack then
LocalPlayer.Character.Humanoid.WalkSpeed=v
end
end
})

MovementTab:CreateToggle({
Name="Infinite Jump",
CurrentValue=false,
Callback=function(v)
Settings.InfiniteJump=v
end
})

UIS.JumpRequest:Connect(function()
if Settings.InfiniteJump then
LocalPlayer.Character.Humanoid:ChangeState("Jumping")
end
end)

MovementTab:CreateToggle({
Name="Noclip",
CurrentValue=false,
Callback=function(v)
Settings.Noclip=v
end
})

RunService.Stepped:Connect(function()
if Settings.Noclip and LocalPlayer.Character then
for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide=false
end
end
end
end)

MovementTab:CreateToggle({
Name="Spin",
CurrentValue=false,
Callback=function(v)
Settings.Spin=v
end
})

MovementTab:CreateSlider({
Name="Spin Speed",
Range={10,200},
Increment=1,
CurrentValue=30,
Callback=function(v)
Settings.SpinSpeed=v
end
})

RunService.RenderStepped:Connect(function()
if Settings.Spin and LocalPlayer.Character then
LocalPlayer.Character.HumanoidRootPart.CFrame=
LocalPlayer.Character.HumanoidRootPart.CFrame*
CFrame.Angles(0,math.rad(Settings.SpinSpeed),0)
end
end)

-- VISUAL TAB
local VisualTab=Window:CreateTab("Visual")

VisualTab:CreateToggle({
Name="ESP Box",
CurrentValue=false,
Callback=function(v)
Settings.ESPBox=v
end
})

VisualTab:CreateToggle({
Name="Name ESP",
CurrentValue=false,
Callback=function(v)
Settings.NameESP=v
end
})

VisualTab:CreateToggle({
Name="Distance ESP",
CurrentValue=false,
Callback=function(v)
Settings.DistanceESP=v
end
})

VisualTab:CreateToggle({
Name="Rainbow ESP",
CurrentValue=false,
Callback=function(v)
Settings.RainbowESP=v
end
})

-- TELEPORT TAB
local TeleportTab=Window:CreateTab("Teleport")

local playerDropdown=TeleportTab:CreateDropdown({
Name="Select Player",
Options=getPlayers(),
CurrentOption={""},
MultipleOptions=false,
Callback=function(opt)
Settings.FollowTarget=opt[1]
end
})

TeleportTab:CreateButton({
Name="Refresh Player List",
Callback=function()
playerDropdown:Refresh(getPlayers(),true)
end
})

TeleportTab:CreateButton({
Name="Teleport To Player",
Callback=function()
local t=Players:FindFirstChild(Settings.FollowTarget)
if t and t.Character then
LocalPlayer.Character.HumanoidRootPart.CFrame=
t.Character.HumanoidRootPart.CFrame*CFrame.new(0,3,0)
end
end
})

TeleportTab:CreateToggle({
Name="Follow Player",
CurrentValue=false,
Callback=function(v)
Settings.Follow=v
end
})

RunService.RenderStepped:Connect(function()

if Settings.Follow then

local t=Players:FindFirstChild(Settings.FollowTarget)

if t and t.Character and LocalPlayer.Character then

LocalPlayer.Character.HumanoidRootPart.CFrame=
t.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,3)

end

end

end)

TeleportTab:CreateButton({
Name="Rejoin Server",
Callback=function()
TeleportService:Teleport(game.PlaceId,LocalPlayer)
end
})

-- CLICK TP
UIS.InputBegan:Connect(function(input,gp)

if gp then return end

if input.UserInputType==Enum.UserInputType.MouseButton1 then

local mouse=LocalPlayer:GetMouse()

if mouse.Target then

LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(mouse.Hit.Position+Vector3.new(0,3,0))

end

end

end)
