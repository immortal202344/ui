local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "ImmortalUi",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Vip Cheat",
   LoadingSubtitle = "by Immortal",
   ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Ocean", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "F", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = False,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Vip Secure",
      Subtitle = "Vip test",
      Note = "Key In https://t.me/Xsoqqviperr", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Immortal"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

Rayfield:Notify({
   Title = "Rank: Vip",
   Content = "Enjoy",
   Duration = 6.5,
   Image = House,
})

local Tab = Window:CreateTab("Main", House) -- Title, Image
local Section = Tab:CreateSection("Aimlock")

local Toggle = Tab:CreateToggle({
   Name = "AimLock",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(state)
    if state then
        -- Enable Script
_G.AimBotEnabled = true

local camera = workspace.CurrentCamera
local players = game:GetService("Players")
local user = players.LocalPlayer
local inputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local predictionFactor, aimSpeed = 0.042, 10
local holding = false

if not user then return warn("LocalPlayer не найден!") end

-- Создаем FOV круг
if not _G.FOVCircle then
    _G.FOVCircle = Drawing.new("Circle")
    _G.FOVCircle.Radius, _G.FOVCircle.Filled, _G.FOVCircle.Thickness = 200, false, 1 -- Начальный радиус: 200
    _G.FOVCircle.Color, _G.FOVCircle.Transparency, _G.FOVCircle.Visible = Color3.new(1, 1, 1), 0.7, true
end

-- Получение ближайшего игрока
local function getClosestPlayer()
    local closest, minDist = nil, math.huge
    local currentRadius = _G.FOVCircle and _G.FOVCircle.Radius or 200 -- Используем текущий радиус FOV
    for _, player in pairs(players:GetPlayers()) do
        if player ~= user and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local head = player.Character:FindFirstChild("Head")
            local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - inputService:GetMouseLocation()).Magnitude
            if onScreen and distance <= currentRadius and distance < minDist then
                closest, minDist = player, distance
            end
        end
    end
    return closest
end

-- Предсказание позиции
local function predictHead(target)
    local head = target.Character.Head
    local velocity = target.Character.HumanoidRootPart.AssemblyLinearVelocity or Vector3.zero
    return head.Position + velocity * predictionFactor
end

-- Обработчики ввода
inputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then holding = true end
end)

inputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then holding = false end
end)

-- Основной цикл
runService.RenderStepped:Connect(function()
    if not _G.AimBotEnabled then return end
    if _G.FOVCircle then
        _G.FOVCircle.Position = inputService:GetMouseLocation()
    end
    if holding then
        local target = getClosestPlayer()
        if target then
            local predicted = predictHead(target)
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, predicted), aimSpeed * 0.1)
        end
    end
end)
    else
        -- Disable Script
_G.AimBotEnabled = false -- Отключаем функционал аимбота

-- Удаляем FOV круг, если он существует
if _G.FOVCircle then
    _G.FOVCircle:Remove() -- Удаляем объект
    _G.FOVCircle = nil    -- Очищаем переменную
end

-- Очищаем глобальные переменные, если требуется
_G.PredictionFactor = nil
_G.AimSpeed = nil
    end
   end,
})

local Input = Tab:CreateInput({
   Name = "AimLock Fov",
   PlaceholderText = "FOV Radius set to:",
   RemoveTextAfterFocusLost = false,
   Callback = function(txt)
-- Настройка FOV через текстбокс
    local newRadius = tonumber(txt) -- Преобразуем введенный текст в число
    if newRadius and _G.FOVCircle then
        _G.FOVCircle.Radius = math.clamp(newRadius, 10, 500) -- Ограничиваем значение от 10 до 500
        print("FOV Radius set to:", _G.FOVCircle.Radius)
    else
        warn("Invalid input! Please enter a number.")
    end
   end,
})

local Section = Tab:CreateSection("AntiAim")

local spinSpeed = 10
local spinEnabled = false
local spinConnection = nil
local UserInputService = game:GetService("UserInputService")

-- Улучшенная функция для получения персонажа
local function getCharacterParts()
    local character = game.Players.LocalPlayer.Character
    if not character then return nil, nil, nil end
    
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid then
        humanoid = character:WaitForChild("Humanoid", 2)
    end
    if not rootPart then
        rootPart = character:WaitForChild("HumanoidRootPart", 2)
    end
    
    return character, humanoid, rootPart
end

local function updateSpin()
    local character, humanoid, rootPart = getCharacterParts()
    if not humanoid or not rootPart then return end
    
    -- Отключаем спин если нажата клавиша E
    if spinConnection and UserInputService:IsKeyDown(Enum.KeyCode.E) then
        spinConnection:Disconnect()
        spinConnection = nil
        humanoid.AutoRotate = true
        return
    end
    
    -- Включаем спин если нужно и не нажата E
    if spinEnabled and not spinConnection and not UserInputService:IsKeyDown(Enum.KeyCode.E) then
        humanoid.AutoRotate = false
        spinConnection = game:GetService("RunService").Heartbeat:Connect(function(delta)
            if not rootPart or not rootPart:IsDescendantOf(workspace) then
                if spinConnection then
                    spinConnection:Disconnect()
                    spinConnection = nil
                end
                return
            end
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed * delta * 60), 0)
        end)
    end
end

-- Обработчик клавиш
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        local _, humanoid = getCharacterParts()
        if humanoid then
            humanoid.AutoRotate = true
        end
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E and spinEnabled then
        updateSpin()
    end
end)

-- Toggle
local Toggle = Tab:CreateToggle({
    Name = "Spin-Bot",
    CurrentValue = false,
    Flag = "SpinToggle",
    Callback = function(Enabled)
        spinEnabled = Enabled
        if not Enabled then
            if spinConnection then
                spinConnection:Disconnect()
                spinConnection = nil
            end
            local _, humanoid = getCharacterParts()
            if humanoid then
                humanoid.AutoRotate = true
            end
        else
            updateSpin()
        end
    end
})

-- Slider
local Slider = Tab:CreateSlider({
    Name = "Spin-Bot Speed",
    Range = {1, 240},
    Increment = 1,
    Suffix = "° per second",
    CurrentValue = spinSpeed,
    Flag = "SpinSpeed",
    Callback = function(Value)
        spinSpeed = Value
        if spinEnabled then
            updateSpin()
        end
    end
})

-- Обработчик нового персонажа
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 2)
    if not humanoid then return end
    
    if spinEnabled then
        humanoid.AutoRotate = false
        updateSpin()
    else
        humanoid.AutoRotate = true
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Настройки
local SETTINGS = {
    Enabled = false,
    Angle = 180,
    Smoothness = 0.15,
    Noise = {
        Enable = true,
        Intensity = 2,
        Speed = 5
    }
}

-- Состояние
local player = Players.LocalPlayer
local character, humanoidRootPart
local currentRotation = 0
local noiseOffset = 0

local AntiAimToggle = Tab:CreateToggle({
    Name = "Anti-Aim",
    CurrentValue = false,
    Flag = "AntiAimToggle",
    Callback = function(Value)
        SETTINGS.Enabled = Value
    end,
})

local AngleSlider = Tab:CreateSlider({
    Name = "Angle Offset",
    Range = {-180, 180},
    Increment = 5,
    Suffix = "°",
    CurrentValue = 0,
    Flag = "AntiAimAngle",
    Callback = function(Value)
        SETTINGS.Angle = Value
    end,
})

local SmoothnessSlider = Tab:CreateSlider({
    Name = "Smoothness",
    Range = {0.05, 0.5},
    Increment = 0.05,
    CurrentValue = SETTINGS.Smoothness,
    Flag = "AntiAimSmoothness",
    Callback = function(Value)
        SETTINGS.Smoothness = Value
    end,
})

-- Обновление персонажа
local function updateCharacter()
    character = player.Character
    if character then
        humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    else
        humanoidRootPart = nil
    end
end

-- Инициализация
updateCharacter()
player.CharacterAdded:Connect(updateCharacter)
player.CharacterRemoving:Connect(function()
    SETTINGS.Enabled = false
    AntiAimToggle:Set(false)
end)

-- Обработчик ввода
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == SETTINGS.ToggleKey then
        SETTINGS.Enabled = not SETTINGS.Enabled
        AntiAimToggle:Set(SETTINGS.Enabled)
    end
end)

-- Основной цикл
RunService.Heartbeat:Connect(function()
    if not SETTINGS.Enabled or not humanoidRootPart or not Camera then return end
    
    -- Получаем угол камеры
    local lookVector = Camera.CFrame.LookVector
    local cameraAngle = math.atan2(lookVector.X, lookVector.Z)
    
    -- Целевой угол с учетом настроек
    local targetAngle = cameraAngle + math.rad(SETTINGS.Angle)
    
    -- Добавляем шум
    if SETTINGS.Noise.Enable then
        noiseOffset = noiseOffset + SETTINGS.Noise.Speed * 0.01
        targetAngle = targetAngle + math.sin(noiseOffset) * math.rad(SETTINGS.Noise.Intensity)
    end
    
    -- Плавный поворот
    currentRotation = currentRotation + (targetAngle - currentRotation) * SETTINGS.Smoothness
    
    -- Применяем поворот
    humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, currentRotation, 0)
end)

local Section = Tab:CreateSection("MainTabs")

local Slider = Tab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(s)
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
   end,
})

local Slider = Tab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(s)
game.Players.LocalPlayer.Character.Humanoid.JumpPower = s
   end,
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Ультра-настройки
local SETTINGS = {
    AIR_FORCE = 300,         -- Сила ускорения в воздухе
    GROUND_BRAKE = 0.4,      -- Жесткость замедления (0 = полный стоп)
    JUMP_POWER = 50,         -- Базовая сила прыжка (не multiplier!)
    TURN_SPEED = 8,         -- Скорость поворота
    MAX_SPEED = 500          -- Лимит скорости
}

-- Инициализация
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Состояние
local isEnabled = false
local lastGroundedState = false

-- Получаем вектор камеры
local function GetCameraVector()
    local cam = workspace.CurrentCamera
    return Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
end

-- Основной цикл
RunService.Heartbeat:Connect(function(dt)
    if not isEnabled then return end
    
    local camDir = GetCameraVector()
    local isGrounded = humanoid:GetState() == Enum.HumanoidStateType.Landed
    local spaceHeld = UserInputService:IsKeyDown(Enum.KeyCode.Space)
    
    -- Мгновенное замедление при ПРИЗЕМЛЕНИИ (даже если пробел зажат)
    if isGrounded and not lastGroundedState then
        local vel = rootPart.Velocity
        rootPart.Velocity = Vector3.new(
            vel.X * SETTINGS.GROUND_BRAKE,
            vel.Y,
            vel.Z * SETTINGS.GROUND_BRAKE
        )
    end
    
    -- Автопрыжок
    if isGrounded and spaceHeld then
        humanoid.JumpPower = SETTINGS.JUMP_POWER
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    -- Ускорение в воздухе
    if not isGrounded and spaceHeld then
        -- Мгновенный поворот
        rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + camDir)
        
        -- Мощное ускорение
        local newVel = rootPart.Velocity + (camDir * SETTINGS.AIR_FORCE * dt)
        
        -- Ограничение скорости
        local horizVel = Vector3.new(newVel.X, 0, newVel.Z)
        if horizVel.Magnitude > SETTINGS.MAX_SPEED then
            horizVel = horizVel.Unit * SETTINGS.MAX_SPEED
        end
        
        rootPart.Velocity = Vector3.new(horizVel.X, newVel.Y, horizVel.Z)
    end
    
    lastGroundedState = isGrounded
end)

-- Toggle
local Toggle = Tab:CreateToggle({
    Name = "Bunnyhop",
    CurrentValue = false,
    Flag = "BHopToggle",
    Callback = function(val)
        isEnabled = val
        if not val then
            humanoid.JumpPower = 50 -- Стандартная сила прыжка
        end
    end
})




local Slider = Tab:CreateSlider({
   Name = "HipHeight",
   Range = {0, 50},
   Increment = 1,
   Suffix = "HipHeight",
   CurrentValue = 0,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(s)
game.Players.LocalPlayer.Character.Humanoid.HipHeight = s
   end,
})

local Button = Tab:CreateButton({
   Name = "AntiFling",
   Callback = function()

local Services = setmetatable({}, {__index = function(Self, Index)
    local NewService = game.GetService(game, Index)
    if NewService then
        Self[Index] = NewService
    end
    return NewService
end})

-- [ LocalPlayer ] --
local LocalPlayer = Services.Players.LocalPlayer

-- // Functions \\ --
local function PlayerAdded(Player)
    local Detected = false
    local Character;
    local PrimaryPart;

    local function CharacterAdded(NewCharacter)
        Character = NewCharacter
        repeat
            wait()
            PrimaryPart = NewCharacter:FindFirstChild("HumanoidRootPart")
        until PrimaryPart
        Detected = false
    end

    CharacterAdded(Player.Character or Player.CharacterAdded:Wait())
    Player.CharacterAdded:Connect(CharacterAdded)
    Services.RunService.Heartbeat:Connect(function()
        if (Character and Character:IsDescendantOf(workspace)) and (PrimaryPart and PrimaryPart:IsDescendantOf(Character)) then
            if PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 or PrimaryPart.AssemblyLinearVelocity.Magnitude > 100 then
                if Detected == false then
                    -- game.StarterGui:SetCore("ChatMakeSystemMessage", { -- Removed chat message
                    --     Text = "Fling Exploit detected, Player: " .. tostring(Player);
                    --     Color = Color3.fromRGB(255, 200, 0);
                    -- })
                end
                Detected = true
                for i,v in ipairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                        v.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        v.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                    end
                end
                PrimaryPart.CanCollide = false
                PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                PrimaryPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
            end
        end
    end)
end

-- // Event Listeners \\ --
for i,v in ipairs(Services.Players:GetPlayers()) do
    if v ~= LocalPlayer then
        PlayerAdded(v)
    end
end
Services.Players.PlayerAdded:Connect(PlayerAdded)

local LastPosition = nil
Services.RunService.Heartbeat:Connect(function()
    pcall(function()
        local PrimaryPart = LocalPlayer.Character.PrimaryPart
        if PrimaryPart.AssemblyLinearVelocity.Magnitude > 250 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 250 then
            PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            PrimaryPart.CFrame = LastPosition

            -- game.StarterGui:SetCore("ChatMakeSystemMessage", { -- Removed self-fling message
            --     Text = "You were flung. Neutralizing velocity. :3";
            --     Color = Color3.fromRGB(255, 0, 0);
            -- })
        elseif PrimaryPart.AssemblyLinearVelocity.Magnitude < 50 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 then
            LastPosition = PrimaryPart.CFrame
        end
    end)
end)

   end,
})  


local Button = Tab:CreateButton({
   Name = "Float Pad",
   Callback = function()
		local name = game.Players.LocalPlayer.Name
local p = Instance.new("Part")
p.Parent = workspace
p.Locked = true
p.BrickColor = BrickColor.new("White")
p.BrickColor = BrickColor.new(104)
local pcolor = Color3.fromRGB(255, 0, 137)
p.Size = Vector3.new(8, 1.2, 8)
p.Anchored = true
local m = Instance.new("CylinderMesh")
m.Scale = Vector3.new(1, 0.5, 1)
m.Parent = p
while true do
	p.CFrame = CFrame.new(game.Players:findFirstChild(name).Character.HumanoidRootPart.CFrame.x, game.Players:findFirstChild(name).Character.HumanoidRootPart.CFrame.y - 4, game.Players:findFirstChild(name).Character.HumanoidRootPart.CFrame.z)
	wait()
end
end,
})



local Slider = Tab:CreateSlider({
   Name = "Gravity",
   Range = {0, 300},
   Increment = 1,
   Suffix = "Gravity",
   CurrentValue = 196.2,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(s)
workspace.Gravity = s
   end,
})


local Tab = Window:CreateTab("Visual", House) -- Title, Image
local Section = Tab:CreateSection("WallHack")

local Toggle = Tab:CreateToggle({
   Name = "Chams",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(state)
    if state then
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ThirdScripts/ChamsTeamColor/refs/heads/main/ChamsColorTeam.lua"))()
    else
        _G.ESP_Enabled = false

for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    if player.Character then
        for _, v in ipairs(player.Character:GetChildren()) do
            if v:IsA("Highlight") then
                v:Destroy()
            end
        end
    end
end
    end   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Button = Tab:CreateButton({
   Name = "Skelet Esp",
   Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ThirdScripts/ESPSkeletMod/refs/heads/main/ESPSkelet.lua"))()
   end,
})  

local Button = Tab:CreateButton({
   Name = "Esp",
   Callback = function()
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ThirdScripts/ESPteamcolor/refs/heads/main/ESP.lua"))()
   end,
})  

local Section = Tab:CreateSection("Visual")

local Slider = Tab:CreateSlider({
   Name = "Zoom",
   Range = {5, 2000},
   Increment = 5,
   Suffix = "CameraMaxZoomDistance",
   CurrentValue = 124,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(s)
    game.Players.LocalPlayer.CameraMaxZoomDistance = s
end,
})
 

local Button = Tab:CreateButton({
   Name = "Ghost",
   Callback = function()
		function nob(who,tra,hat)
c=who.Character
pcall(function()u=c["Body Colors"]
u.HeadColor=BrickColor.new("Black")
u.LeftLegColor=BrickColor.new("Black")
u.RightLegolor=BrickColor.new("Black")
u.LeftArmColor=BrickColor.new("Black")
u.TorsoColor=BrickColor.new("Black")
u.RightArmColor=BrickColor.new("Black")
end)
pcall(function()c.Shirt:Destroy() c.Pants:Destroy() end)
for i,v in pairs(c:GetChildren()) do
if v:IsA("BasePart") then
v.Transparency=tra
if v.Name=="HumanoidRootPart" or v.Name=="Head" then
v.Transparency=1
end
wait()
v.BrickColor=BrickColor.new("Black")
elseif v:IsA("Hat") then
v:Destroy()
end
end
xx=game:service("InsertService"):LoadAsset(hat)
xy=game:service("InsertService"):LoadAsset(47433)["LinkedSword"]
xy.Parent=who.Backpack
for a,hat in pairs(xx:children()) do
hat.Parent=c
end
xx:Destroy()
h=who.Character.Humanoid
h.MaxHealth=50000
wait(1.5)
h.Health=50000
h.WalkSpeed=32
end
nob(game.Players.LocalPlayer,0.6,21070012)
   end,
})  

local Toggle = Tab:CreateToggle({
   Name = "Blur",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(state)
    if state then
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ThirdScripts/Blur/refs/heads/main/blur.lua"))()
    else
        game:GetService("Lighting"):ClearAllChildren()
    end
   end,
})

local Slider = Tab:CreateSlider({
   Name = "Resolution",
   Range = {0, 1},
   Increment = 0.1,
   Suffix = "Resolution",
   CurrentValue = 1,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
getgenv().Resolution = {
    [".gg/scripters"] = Value
}

local Camera = workspace.CurrentCamera
if getgenv().gg_scripters == nil then
    game:GetService("RunService").RenderStepped:Connect(
        function()
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
        end
    )
end
getgenv().gg_scripters = "Aori0001"
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(state)
    if state then
        _G.LightingEnabled = true

local Lighting = game:GetService("Lighting")

if _G.LightingEnabled then
  
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.Brightness = 2
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.FogEnd = 1e10

   
    Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
        if _G.LightingEnabled then
            Lighting.Ambient = Color3.new(1, 1, 1)
        end
    end)

    Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
        if _G.LightingEnabled then
            Lighting.Brightness = 2
        end
    end)

    Lighting:GetPropertyChangedSignal("OutdoorAmbient"):Connect(function()
        if _G.LightingEnabled then
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        end
    end)

    Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
        if _G.LightingEnabled then
            Lighting.FogEnd = 1e10
        end
    end)
end

    else
        _G.LightingEnabled = false

local Lighting = game:GetService("Lighting")

-- Устанавливаем чуть более светлый нейтральный свет
Lighting.Ambient = Color3.new(0.7, 0.7, 0.7) -- Легкий серый оттенок
Lighting.Brightness = 1 -- Стандартная яркость
Lighting.OutdoorAmbient = Color3.new(0.7, 0.7, 0.7) -- Тот же светлый серый
Lighting.FogEnd = 100000 -- Ограничение на дальность тумана

    end
   end,
})


local Players = game:GetService("Players")
local player = Players.LocalPlayer
local coneColor = Color3.fromRGB(255, 0, 137) -- Нежно-голубой цвет
local coneCreated = true -- Конус ещё не создан

-- Функция для создания конуса
local function createCone(character)
    if not coneColor then return end -- Создаём конус только если цвет выбран

    local head = character:FindFirstChild("Head")
    if not head then return end

    local cone = Instance.new("Part")
    cone.Size = Vector3.new(1, 1, 1)
    cone.BrickColor = BrickColor.new("White")
    cone.Transparency = 0.3
    cone.Anchored = false
    cone.CanCollide = false

    local mesh = Instance.new("SpecialMesh", cone)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(1.7, 1.1, 1.7)

    local weld = Instance.new("Weld")
    weld.Part0 = head
    weld.Part1 = cone
    weld.C0 = CFrame.new(0, 0.9, 0)

    cone.Parent = character
    weld.Parent = cone

    -- Добавляем Highlight
    local highlight = Instance.new("Highlight", cone)
    highlight.FillColor = coneColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = coneColor
    highlight.OutlineTransparency = 0

    coneCreated = true -- Помечаем, что конус создан
end

-- Пересоздаём конус после респавна
local function onCharacterAdded(character)
    if coneCreated then -- Если конус уже был создан, пересоздаём
        createCone(character)
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Если персонаж уже существует
if player.Character then
    onCharacterAdded(player.Character)
end

-- ColorPicker
local ColorPicker = Tab:CreateColorPicker({
    Name = "China hat",
    Color = Color3.fromRGB(255,255,255),
    Flag = "ColorPicker1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(color)
    coneColor = color -- Обновляем цвет для конуса
    if player.Character and not coneCreated then
        createCone(player.Character) -- Создаём конус только после выбора цвета
    elseif player.Character and coneCreated then
        -- Обновляем цвет существующего конуса
        for _, v in ipairs(player.Character:GetChildren()) do
            if v:IsA("Part") and v:FindFirstChild("Highlight") then
                local highlight = v:FindFirstChild("Highlight")
                highlight.FillColor = coneColor
                highlight.OutlineColor = coneColor
            end
        end
    end   
end
})

local Tab = Window:CreateTab("Misc", House) -- Title, Image
local Section = Tab:CreateSection("Character")

local Button = Tab:CreateButton({
   Name = "Reset",
   Callback = function()
    game.workspace[game.Players.LocalPlayer.Name].Head:Destroy()
end,
})  

local Button = Tab:CreateButton({
   Name = "Destroy shirt and paints",
   Callback = function()
game.Players.LocalPlayer.Character.Shirt:destroy()
game.Players.LocalPlayer.Character.Pants:destroy()
end,
})  

local Section = Tab:CreateSection("Tools")

local Button = Tab:CreateButton({
   Name = "JerkOff (r6)",
   Callback = function()
loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))("Spider Script")
end,
})  

local Button = Tab:CreateButton({
   Name = "Click TP",
   Callback = function()
mouse = game.Players.LocalPlayer:GetMouse()
tool = Instance.new("Tool")
tool.RequiresHandle = false
tool.Name = "Click Teleport"
tool.Activated:connect(function()
local pos = mouse.Hit+Vector3.new(0,2.5,0)
pos = CFrame.new(pos.X,pos.Y,pos.Z)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos
end)
tool.Parent = game.Players.LocalPlayer.Backpack
end,
})  

local Section = Tab:CreateSection("Scripts")

local Button = Tab:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end,
})  

local Button = Tab:CreateButton({
   Name = "System Broken",
   Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script"))()
end,
})  

local Tab = Window:CreateTab("Sky", House) -- Title, Image
local Section = Tab:CreateSection("Sky Custom")

local Button = Tab:CreateButton({
   Name = "Moon Sky",
   Callback = function()
local sky = Instance.new("Sky")
sky.Name = "ColorfulSky"
sky.SkyboxBk = "rbxassetid://159454299"
sky.SkyboxDn = "rbxassetid://159454296"
sky.SkyboxFt = "rbxassetid://159454293"
sky.SkyboxLf = "rbxassetid://159454286"
sky.SkyboxRt = "rbxassetid://159454300"
sky.SkyboxUp = "rbxassetid://159454288"
sky.SunAngularSize = 21
sky.SunTextureId = ""
sky.MoonTextureId = ""
sky.Parent = game.Lighting

-- Texto no canto superior esquerdo
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkyboxChangerLabelUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0, 230, 0, 18)
nameLabel.Position = UDim2.new(0, 10, 0, 8)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = ""
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.Code
nameLabel.TextSize = 13
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = screenGui
end,
}) 

local Section = Tab:CreateSection("Sky Settings")

local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- Настройки дня и ночи
local daySettings = {
    ClockTime = 14,
    Ambient = Color3.fromRGB(178, 178, 178),
}

local nightSettings = {
    ClockTime = 0,
    Ambient = Color3.fromRGB(50, 50, 50),
}

local isDay = true

-- Функция переключения дня и ночи
local function toggleDayNight()
    isDay = not isDay
    
    if isDay then
        for property, value in pairs(daySettings) do
            Lighting[property] = value
        end
    else
        for property, value in pairs(nightSettings) do
            Lighting[property] = value
        end
    end
end

-- Создаем Keybind для переключения (предполагая, что Tab уже определен)
local DayNightKeybind = Tab:CreateKeybind({
    Name = "Day/Night",
    CurrentKeybind = "K",
    HoldToInteract = false,
    Flag = "DayNightKeybind",
    Callback = function()
        toggleDayNight()
    end,
})

local Tab = Window:CreateTab("Settings/Credits", House) -- Title, Image
local Section = Tab:CreateSection("Credits")

local Label = Tab:CreateLabel("Created by Immortal")
local Label = Tab:CreateLabel("You rank: Vip")
local Label = Tab:CreateLabel("!!!FREECAM ON P!!!")
local Label = Tab:CreateLabel("Version 2.1 Release")


local Section = Tab:CreateSection("Settings")



local Button = Tab:CreateButton({
   Name = "Unlock Camera",
   Callback = function()
Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
    end,
    })


local Button = Tab:CreateButton({
    Name = "Keystrokes",
    Callback = function()
        loadstring(game:HttpGet("https://github.com/TheXploiterYT/scripts/raw/main/keystrokes",true))()
    end,
})

--!nonstrict
------------------------------------------------------------------------
-- Freecam
-- Cinematic free camera for spectating and video production.
------------------------------------------------------------------------

local pi    = math.pi
local abs   = math.abs
local clamp = math.clamp
local exp   = math.exp
local rad   = math.rad
local sign  = math.sign
local sqrt  = math.sqrt
local tan   = math.tan

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Settings = UserSettings()
local GameSettings = Settings.GameSettings
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = Workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

local FreecamDepthOfField = nil

local FFlagUserExitFreecamBreaksWithShiftlock
do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserExitFreecamBreaksWithShiftlock")
	end)
	FFlagUserExitFreecamBreaksWithShiftlock = success and result
end

local FFlagUserShowGuiHideToggles
do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserShowGuiHideToggles")
	end)
	FFlagUserShowGuiHideToggles = success and result
end

local FFlagUserFixFreecamDeltaTimeCalculation
do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserFixFreecamDeltaTimeCalculation")
	end)
	FFlagUserFixFreecamDeltaTimeCalculation = success and result
end

local FFlagUserFixFreecamGuiChangeVisibility
do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserFixFreecamGuiChangeVisibility")
	end)
	FFlagUserFixFreecamGuiChangeVisibility = success and result
end

local FFlagUserFreecamControlSpeed
do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserFreecamControlSpeed")
	end)
	FFlagUserFreecamControlSpeed = success and result
end

local FFlagUserFreecamTiltControl
do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserFreecamTiltControl")
	end)
	FFlagUserFreecamTiltControl = success and result
end

local FFlagUserFreecamSmoothnessControl
do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserFreecamSmoothnessControl")
	end)
	FFlagUserFreecamSmoothnessControl = success and result
end

local FFlagUserFreecamGuiDestabilization
do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserFreecamGuiDestabilization")
	end)
	FFlagUserFreecamGuiDestabilization = success and result
end

local FFlagUserFreecamDepthOfFieldEffect
do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserFreecamDepthOfFieldEffect")
	end)
	FFlagUserFreecamDepthOfFieldEffect = success and result
end

------------------------------------------------------------------------

local FREECAM_ENABLED_ATTRIBUTE_NAME = "FreecamEnabled"
local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value
local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
local FREECAM_MACRO_KB = {Enum.KeyCode.P}
local FREECAM_TILT_RESET_KB = {
	[Enum.KeyCode.Z] = true,
	[Enum.KeyCode.C] = true
}
local FREECAM_TILT_RESET_GP = {
	[Enum.KeyCode.ButtonL1] = true,
	[Enum.KeyCode.ButtonR1] = true
}
local FREECAM_DOF_TOGGLE = {
	[Enum.KeyCode.BackSlash] = true
}

local NAV_GAIN = Vector3.new(1, 1, 1)*64
local PAN_GAIN = Vector2.new(0.75, 1)*8
local FOV_GAIN = 300
local ROLL_GAIN = -pi/2

local PITCH_LIMIT = rad(90)

local VEL_STIFFNESS = 1.5
local PAN_STIFFNESS = 1.0
local FOV_STIFFNESS = 4.0
local ROLL_STIFFNESS = 1.0

local VEL_ADJ_STIFFNESS = 0.75
local PAN_ADJ_STIFFNESS = 0.75
local FOV_ADJ_STIFFNESS = 0.75
local ROLL_ADJ_STIFFNESS = 0.75

local VEL_MIN_STIFFNESS = 0.01
local PAN_MIN_STIFFNESS = 0.01
local FOV_MIN_STIFFNESS = 0.01
local ROLL_MIN_STIFFNESS = 0.01

local VEL_MAX_STIFFNESS = 10.0
local PAN_MAX_STIFFNESS = 10.0
local FOV_MAX_STIFFNESS = 10.0
local ROLL_MAX_STIFFNESS = 10.0

local lastPressTime = {}
local lastResetTime = 0
local DOUBLE_TAP_TIME_THRESHOLD = 0.25
local DOUBLE_TAP_DEBOUNCE_TIME = 0.1

local postEffects = {}
------------------------------------------------------------------------

local Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:SetFreq(freq)
		self.f = freq
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

------------------------------------------------------------------------

local cameraPos = Vector3.new()
local cameraRot
if FFlagUserFreecamTiltControl then
	cameraRot = Vector3.new()
else 
	cameraRot = Vector2.new()
end
local cameraFov = 0

local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
local fovSpring = Spring.new(FOV_STIFFNESS, 0)
local rollSpring = Spring.new(ROLL_STIFFNESS, 0)

------------------------------------------------------------------------

local Input = {} do
	local thumbstickCurve do
		local K_CURVATURE = 2.0
		local K_DEADZONE = 0.15

		local function fCurve(x)
			return (exp(K_CURVATURE*x) - 1)/(exp(K_CURVATURE) - 1)
		end

		local function fDeadzone(x)
			return fCurve((x - K_DEADZONE)/(1 - K_DEADZONE))
		end

		function thumbstickCurve(x)
			return sign(x)*clamp(fDeadzone(abs(x)), 0, 1)
		end
	end

	local gamepad = {
		ButtonX = 0,
		ButtonY = 0,
		DPadDown = 0,
		DPadUp = 0,
		DPadLeft = 0,
		DPadRight = 0,
		ButtonL2 = 0,
		ButtonR2 = 0,
		ButtonL1 = 0,
		ButtonR1 = 0,
		Thumbstick1 = Vector2.new(),
		Thumbstick2 = Vector2.new(),
	}

	local keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		U = 0,
		H = 0,
		J = 0,
		K = 0,
		I = 0,
		Y = 0,
		Up = 0,
		Down = 0,
		Left = 0,
		Right = 0,
		LeftShift = 0,
		RightShift = 0,
		Z = 0,
		C = 0,
		Comma = 0,
		Period = 0,
		LeftBracket = 0,
		RightBracket = 0,
		Semicolon = 0,
		Quote = 0,
		V = 0,
		B = 0,
		N = 0,
		M = 0,
		BackSlash = 0,
		Minus = 0,
		Equals = 0
	}

	local mouse = {
		Delta = Vector2.new(),
		MouseWheel = 0,
	}

	local DEFAULT_FPS         = 60
	local NAV_GAMEPAD_SPEED   = Vector3.new(1, 1, 1)
	local NAV_KEYBOARD_SPEED  = Vector3.new(1, 1, 1)
	local PAN_MOUSE_SPEED     = Vector2.new(1, 1)*(pi/64)
	local PAN_MOUSE_SPEED_DT  = PAN_MOUSE_SPEED/DEFAULT_FPS
	local PAN_GAMEPAD_SPEED   = Vector2.new(1, 1)*(pi/8)
	local FOV_WHEEL_SPEED     = 1.0
	local FOV_WHEEL_SPEED_DT  = FOV_WHEEL_SPEED/DEFAULT_FPS
	local FOV_GAMEPAD_SPEED   = 0.25
	local ROLL_GAMEPAD_SPEED  = 1.0
	local ROLL_KEYBOARD_SPEED = 1.0
	local NAV_ADJ_SPEED       = 0.75
	local NAV_MIN_SPEED       = 0.01
	local NAV_MAX_SPEED       = 4.0
	local NAV_SHIFT_MUL       = 0.25
	local FOV_ADJ_SPEED       = 0.75
	local FOV_MIN_SPEED       = 0.01
	local FOV_MAX_SPEED       = 4.0
	local ROLL_ADJ_SPEED      = 0.75
	local ROLL_MIN_SPEED      = 0.01
	local ROLL_MAX_SPEED      = 4.0
	local DoFConstants = {
		FarIntensity = {
			ADJ = 0.1,
			MIN = 0.0,
			MAX = 1.0,
		},
		NearIntensity = {
			ADJ = 0.1,
			MIN = 0.0,
			MAX = 1.0,
		},
		FocusDistance = {
			ADJ = 20.0,
			MIN = 0.0,
			MAX = 200.0,
		},
		FocusRadius = {
			ADJ = 5.0,
			MIN = 0.0,
			MAX = 50.0,
		},
	}

	local navSpeed = 1
	local rollSpeed = 1
	local fovSpeed = 1

	function Input.Vel(dt)
		if FFlagUserFreecamControlSpeed then
			navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down + gamepad.DPadUp - gamepad.DPadDown)*NAV_ADJ_SPEED, NAV_MIN_SPEED, NAV_MAX_SPEED)
		else
			navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)
		end
		local kGamepad = Vector3.new(
			thumbstickCurve(gamepad.Thumbstick1.X),
			thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
			thumbstickCurve(-gamepad.Thumbstick1.Y)
		)*NAV_GAMEPAD_SPEED

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A + keyboard.K - keyboard.H,
			keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,
			keyboard.S - keyboard.W + keyboard.J - keyboard.U
		)*NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

		return (kGamepad + kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kGamepad = Vector2.new(
			thumbstickCurve(gamepad.Thumbstick2.Y),
			thumbstickCurve(-gamepad.Thumbstick2.X)
		)*PAN_GAMEPAD_SPEED
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		if FFlagUserFixFreecamDeltaTimeCalculation then
			if dt > 0 then
				kMouse = (mouse.Delta/dt)*PAN_MOUSE_SPEED_DT
			end
		end
		mouse.Delta = Vector2.new()
		return kGamepad + kMouse
	end

	function Input.Fov(dt)
		if FFlagUserFreecamControlSpeed then
			fovSpeed = clamp(fovSpeed + dt*(keyboard.Right - keyboard.Left + gamepad.DPadRight - gamepad.DPadLeft)*FOV_ADJ_SPEED, FOV_MIN_SPEED, FOV_MAX_SPEED)
		end
		local kGamepad = (gamepad.ButtonX - gamepad.ButtonY)*FOV_GAMEPAD_SPEED
		local kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED
		if FFlagUserFixFreecamDeltaTimeCalculation then
			if dt > 0 then
				kMouse = (mouse.MouseWheel/dt)*FOV_WHEEL_SPEED_DT
			end
		end
		mouse.MouseWheel = 0
		if FFlagUserFreecamControlSpeed then
			return (kGamepad + kMouse)*fovSpeed
		else
			return kGamepad + kMouse
		end
	end

	function Input.Roll(dt)
		rollSpeed = clamp(rollSpeed + dt*(keyboard.Period - keyboard.Comma)*ROLL_ADJ_SPEED, ROLL_MIN_SPEED, ROLL_MAX_SPEED)

		local kGamepad = (gamepad.ButtonR1 - gamepad.ButtonL1)*ROLL_GAMEPAD_SPEED
		local kKeyboard = (keyboard.C - keyboard.Z)*ROLL_KEYBOARD_SPEED

		return (kGamepad + kKeyboard)*rollSpeed
	end

	function Input.SpringControl(dt)
		if FFlagUserFreecamDepthOfFieldEffect then 
			local shiftIsDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
			local ctrlIsDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

			if shiftIsDown or ctrlIsDown then
				return -- reserve Shift+Keybinds for other actions, in this case Shift+Brackets for Depth of Field controls
			end
		end

		VEL_STIFFNESS = clamp(VEL_STIFFNESS + dt*(keyboard.RightBracket - keyboard.LeftBracket)*VEL_ADJ_STIFFNESS, VEL_MIN_STIFFNESS, VEL_MAX_STIFFNESS)
		velSpring:SetFreq(VEL_STIFFNESS)

		PAN_STIFFNESS = clamp(PAN_STIFFNESS + dt*(keyboard.Quote - keyboard.Semicolon)*PAN_ADJ_STIFFNESS, PAN_MIN_STIFFNESS, PAN_MAX_STIFFNESS)
		panSpring:SetFreq(PAN_STIFFNESS)

		FOV_STIFFNESS = clamp(FOV_STIFFNESS + dt*(keyboard.B - keyboard.V)*FOV_ADJ_STIFFNESS, FOV_MIN_STIFFNESS, FOV_MAX_STIFFNESS)
		fovSpring:SetFreq(FOV_STIFFNESS)

		ROLL_STIFFNESS = clamp(ROLL_STIFFNESS + dt*(keyboard.M - keyboard.N)*ROLL_ADJ_STIFFNESS, ROLL_MIN_STIFFNESS, ROLL_MAX_STIFFNESS)
		rollSpring:SetFreq(ROLL_STIFFNESS)
	end

	function Input.DoF(dt)
		local shiftIsDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
		local ctrlIsDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

		if shiftIsDown then
			FreecamDepthOfField.FarIntensity = clamp(
				FreecamDepthOfField.FarIntensity + dt * (keyboard.RightBracket - keyboard.LeftBracket) * DoFConstants.FarIntensity.ADJ,
				DoFConstants.FarIntensity.MIN,
				DoFConstants.FarIntensity.MAX
			)
			FreecamDepthOfField.InFocusRadius = clamp(
				FreecamDepthOfField.InFocusRadius + dt * (keyboard.Equals - keyboard.Minus) * DoFConstants.FocusRadius.ADJ,
				DoFConstants.FocusRadius.MIN,
				DoFConstants.FocusRadius.MAX
			)
		elseif ctrlIsDown then
			FreecamDepthOfField.NearIntensity = clamp(
				FreecamDepthOfField.NearIntensity + dt * (keyboard.RightBracket - keyboard.LeftBracket) * DoFConstants.NearIntensity.ADJ,
				DoFConstants.NearIntensity.MIN,
				DoFConstants.NearIntensity.MAX
			)
		else
			FreecamDepthOfField.FocusDistance = clamp(
				FreecamDepthOfField.FocusDistance + dt * (keyboard.Equals - keyboard.Minus) * DoFConstants.FocusDistance.ADJ,
				DoFConstants.FocusDistance.MIN,
				DoFConstants.FocusDistance.MAX
			)
		end
	end

	do
		local function resetKeys(keys, table)
			for keyEnum, _ in pairs(keys) do
				if table[keyEnum.Name] then 
					table[keyEnum.Name] = 0
				end
			end
		end

		local function handleDoubleTapReset(keyCode)
			local currentTime = os.clock()

			local previousPressTime = lastPressTime[keyCode]
			local timeSinceLastPress = previousPressTime and (currentTime - previousPressTime) or -1

			if previousPressTime and (timeSinceLastPress <= DOUBLE_TAP_TIME_THRESHOLD) then
				if (currentTime - lastResetTime) >= DOUBLE_TAP_DEBOUNCE_TIME then
					cameraRot = Vector3.new(cameraRot.x, cameraRot.y, 0)
					rollSpring:Reset(0)
					if FFlagUserFreecamDepthOfFieldEffect then 
						resetKeys(FREECAM_TILT_RESET_GP, gamepad)
						resetKeys(FREECAM_TILT_RESET_KB, keyboard)
					else 
						gamepad.ButtonL1 = 0
						gamepad.ButtonR1 = 0
						keyboard.C = 0
						keyboard.Z = 0
					end
					lastResetTime = currentTime
				end
			end
			lastPressTime[keyCode] = currentTime
		end

		local function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0

			if FFlagUserFreecamTiltControl then
				if FREECAM_TILT_RESET_KB[input.KeyCode] and input.UserInputState == Enum.UserInputState.Begin then
					handleDoubleTapReset(input.KeyCode)
				end
			end

			if FFlagUserFreecamDepthOfFieldEffect then
				if FREECAM_DOF_TOGGLE[input.KeyCode] and input.UserInputState == Enum.UserInputState.Begin then
					if not FreecamDepthOfField.Enabled then
						postEffects = {}
						-- Disable all existing DepthOfFieldEffects to be controlled by custom Freecam DoF.
						for _, effect in ipairs(Camera:GetChildren()) do
							if effect:IsA("DepthOfFieldEffect") and effect.Enabled then
								postEffects[#postEffects + 1] = effect
								effect.Enabled = false
							end
						end
						for _, effect in ipairs(Lighting:GetChildren()) do
							if effect:IsA("DepthOfFieldEffect") and effect.Enabled then
								postEffects[#postEffects + 1] = effect
								effect.Enabled = false
							end
						end
						Camera.ChildAdded:Connect(function(child)
							if child:IsA("DepthOfFieldEffect") and child.Enabled then
								postEffects[#postEffects + 1] = child
								child.Enabled = false
							end
						end)
						Lighting.ChildAdded:Connect(function(child)
							if child:IsA("DepthOfFieldEffect") and child.Enabled then
								postEffects[#postEffects + 1] = child
								child.Enabled = false
							end
						end)
					else
						-- Re-enable all existing DepthOfFieldEffects when custom Freecam DoF is off.
						for _, effect in ipairs(postEffects) do
							if effect.Parent then
								effect.Enabled = true
							end
						end
						postEffects = {}
					end
					FreecamDepthOfField.Enabled = not FreecamDepthOfField.Enabled
					resetKeys(FREECAM_DOF_TOGGLE, keyboard)
				end
			end

			return Enum.ContextActionResult.Sink
		end


		local function GpButton(action, state, input)
			gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0

			if FFlagUserFreecamTiltControl then
				if FREECAM_TILT_RESET_GP[input.KeyCode] and input.UserInputState == Enum.UserInputState.Begin then
					handleDoubleTapReset(input.KeyCode)
				end
			end

			return Enum.ContextActionResult.Sink
		end

		local function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		local function Thumb(action, state, input)
			gamepad[input.KeyCode.Name] = input.Position
			return Enum.ContextActionResult.Sink
		end

		local function Trigger(action, state, input)
			gamepad[input.KeyCode.Name] = input.Position.z
			return Enum.ContextActionResult.Sink
		end

		local function MouseWheel(action, state, input)
			mouse[input.UserInputType.Name] = -input.Position.z
			return Enum.ContextActionResult.Sink
		end

		local function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			if FFlagUserFreecamControlSpeed then
				ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
					Enum.KeyCode.W, Enum.KeyCode.U,
					Enum.KeyCode.A, Enum.KeyCode.H,
					Enum.KeyCode.S, Enum.KeyCode.J,
					Enum.KeyCode.D, Enum.KeyCode.K,
					Enum.KeyCode.E, Enum.KeyCode.I,
					Enum.KeyCode.Q, Enum.KeyCode.Y
				)
				ContextActionService:BindActionAtPriority("FreecamKeyboardControlSpeed", Keypress, false, INPUT_PRIORITY,
					Enum.KeyCode.Up, Enum.KeyCode.Down,
					Enum.KeyCode.Left, Enum.KeyCode.Right
				)
				ContextActionService:BindActionAtPriority("FreecamGamepadControlSpeed", GpButton, false, INPUT_PRIORITY, 
					Enum.KeyCode.DPadUp, Enum.KeyCode.DPadDown, 
					Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadRight
				)
			else
				ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
					Enum.KeyCode.W, Enum.KeyCode.U,
					Enum.KeyCode.A, Enum.KeyCode.H,
					Enum.KeyCode.S, Enum.KeyCode.J,
					Enum.KeyCode.D, Enum.KeyCode.K,
					Enum.KeyCode.E, Enum.KeyCode.I,
					Enum.KeyCode.Q, Enum.KeyCode.Y,
					Enum.KeyCode.Up, Enum.KeyCode.Down
				)
			end
			if FFlagUserFreecamTiltControl then
				ContextActionService:BindActionAtPriority("FreecamKeyboardTiltControl", Keypress, false, INPUT_PRIORITY,
					Enum.KeyCode.Z, Enum.KeyCode.C
				)
				ContextActionService:BindActionAtPriority("FreecamGamepadTiltControl", GpButton, false, INPUT_PRIORITY,
					Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1
				)
				ContextActionService:BindActionAtPriority("FreecamKeyboardTiltControlSpeed", Keypress, false, INPUT_PRIORITY,
					Enum.KeyCode.Comma, Enum.KeyCode.Period
				)
				if FFlagUserFreecamSmoothnessControl then
					ContextActionService:BindActionAtPriority("FreecamKeyboardSmoothnessControl", Keypress, false, INPUT_PRIORITY,
						Enum.KeyCode.LeftBracket, Enum.KeyCode.RightBracket, 
						Enum.KeyCode.Semicolon, Enum.KeyCode.Quote,
						Enum.KeyCode.V, Enum.KeyCode.B,
						Enum.KeyCode.N, Enum.KeyCode.M
					)
				end
			end
			if FFlagUserFreecamDepthOfFieldEffect then
				ContextActionService:BindActionAtPriority("FreecamKeyboardDoFToggle", Keypress, false, INPUT_PRIORITY, Enum.KeyCode.BackSlash)
				ContextActionService:BindActionAtPriority("FreecamKeyboardDoFControls", Keypress, false, INPUT_PRIORITY,
					Enum.KeyCode.Minus, Enum.KeyCode.Equals
				)
			end
			ContextActionService:BindActionAtPriority("FreecamMousePan",          MousePan,   false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
			ContextActionService:BindActionAtPriority("FreecamMouseWheel",        MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
			ContextActionService:BindActionAtPriority("FreecamGamepadButton",     GpButton,   false, INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
			ContextActionService:BindActionAtPriority("FreecamGamepadTrigger",    Trigger,    false, INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
			ContextActionService:BindActionAtPriority("FreecamGamepadThumbstick", Thumb,      false, INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
		end

		function Input.StopCapture()
			navSpeed = 1
			if FFlagUserFreecamControlSpeed then
				fovSpeed = 1
			end
			if FFlagUserFreecamTiltControl then
				rollSpeed = 1
			end
			Zero(gamepad)
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction("FreecamKeyboard")
			if FFlagUserFreecamControlSpeed then
				ContextActionService:UnbindAction("FreecamKeyboardControlSpeed")
				ContextActionService:UnbindAction("FreecamGamepadControlSpeed")
			end
			if FFlagUserFreecamTiltControl then
				ContextActionService:UnbindAction("FreecamKeyboardTiltControl")
				ContextActionService:UnbindAction("FreecamGamepadTiltControl")
				ContextActionService:UnbindAction("FreecamKeyboardTiltControlSpeed")
				if FFlagUserFreecamSmoothnessControl then
					ContextActionService:UnbindAction("FreecamKeyboardSmoothnessControl")
				end
			end
			if FFlagUserFreecamDepthOfFieldEffect then
				ContextActionService:UnbindAction("FreecamKeyboardDoFToggle")
				ContextActionService:UnbindAction("FreecamKeyboardDoFControls")
			end
			ContextActionService:UnbindAction("FreecamMousePan")
			ContextActionService:UnbindAction("FreecamMouseWheel")
			ContextActionService:UnbindAction("FreecamGamepadButton")
			ContextActionService:UnbindAction("FreecamGamepadTrigger")
			ContextActionService:UnbindAction("FreecamGamepadThumbstick")
		end
	end
end

------------------------------------------------------------------------

local function StepFreecam(dt)
	if FFlagUserFreecamSmoothnessControl then
		Input.SpringControl(dt)
	end

	if FFlagUserFreecamDepthOfFieldEffect then
		if FreecamDepthOfField and FreecamDepthOfField.Parent then
			Input.DoF(dt)
		end
	end

	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))
	local fov = fovSpring:Update(dt, Input.Fov(dt))
	local roll
	if FFlagUserFreecamTiltControl then
		roll = rollSpring:Update(dt, Input.Roll(dt))
	end

	local zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))

	cameraFov = clamp(cameraFov + fov*FOV_GAIN*(dt/zoomFactor), 1, 120)
	local cameraCFrame
	if FFlagUserFreecamTiltControl then
		local panVector: Vector2 = pan*PAN_GAIN*(dt/zoomFactor)
		cameraRot = cameraRot + Vector3.new(panVector.X, panVector.Y, roll*ROLL_GAIN*(dt/zoomFactor))
		if FFlagUserFreecamSmoothnessControl then
			cameraRot = Vector3.new(cameraRot.x%(2*pi), cameraRot.y%(2*pi), cameraRot.z%(2*pi))
		else
			cameraRot = Vector3.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y%(2*pi), cameraRot.z)
		end

		cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, cameraRot.z)*CFrame.new(vel*NAV_GAIN*dt)
	else 
		cameraRot = cameraRot + pan*PAN_GAIN*(dt/zoomFactor)
		cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y%(2*pi))

		cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*NAV_GAIN*dt)
	end

	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame 
	Camera.FieldOfView = cameraFov
end

local function CheckMouseLockAvailability()
	local devAllowsMouseLock = Players.LocalPlayer.DevEnableMouseLock
	local devMovementModeIsScriptable = Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local userHasMouseLockModeEnabled = GameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local userHasClickToMoveEnabled =  GameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
	local MouseLockAvailable = devAllowsMouseLock and userHasMouseLockModeEnabled and not userHasClickToMoveEnabled and not devMovementModeIsScriptable

	return MouseLockAvailable
end

------------------------------------------------------------------------

local PlayerState = {} do
	local mouseBehavior
	local mouseIconEnabled
	local cameraType
	local cameraFocus
	local cameraCFrame
	local cameraFieldOfView
	local screenGuis = {}
	local coreGuis = {
		Backpack = true,
		Chat = true,
		Health = true,
		PlayerList = true,
	}
	local setCores = {
		BadgesNotificationsActive = true,
		PointsNotificationsActive = true,
	}

	-- Save state and set up for freecam
	function PlayerState.Push()
		for name in pairs(coreGuis) do
			coreGuis[name] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[name])
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], false)
		end
		for name in pairs(setCores) do
			setCores[name] = StarterGui:GetCore(name)
			StarterGui:SetCore(name, false)
		end
		local playergui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if playergui then
			for _, gui in pairs(playergui:GetChildren()) do
				if gui:IsA("ScreenGui") and gui.Enabled then
					screenGuis[#screenGuis + 1] = gui
					gui.Enabled = false
				end
			end
			if FFlagUserFixFreecamGuiChangeVisibility then
				playergui.ChildAdded:Connect(function(child)
					if child:IsA("ScreenGui") and child.Enabled then
						screenGuis[#screenGuis + 1] = child
						child.Enabled = false
					end
				end)
			end
		end

		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		cameraType = Camera.CameraType
		Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		mouseIconEnabled = UserInputService.MouseIconEnabled
		UserInputService.MouseIconEnabled = false

		if FFlagUserExitFreecamBreaksWithShiftlock and CheckMouseLockAvailability() then
			mouseBehavior = Enum.MouseBehavior.Default
		else
			mouseBehavior = UserInputService.MouseBehavior
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	-- Restore state
	function PlayerState.Pop()
		for name, isEnabled in pairs(coreGuis) do
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], isEnabled)
		end
		for name, isEnabled in pairs(setCores) do
			StarterGui:SetCore(name, isEnabled)
		end
		for _, gui in pairs(screenGuis) do
			if gui.Parent then
				gui.Enabled = true
			end
		end
		if FFlagUserFixFreecamGuiChangeVisibility then
			screenGuis = {}
		end

		Camera.FieldOfView = cameraFieldOfView
		cameraFieldOfView = nil

		Camera.CameraType = cameraType
		cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

local function StartFreecam()
	if not FFlagUserFreecamGuiDestabilization then
		if FFlagUserShowGuiHideToggles then
			script:SetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME, true)
		end
	end

	local cameraCFrame = Camera.CFrame
	if FFlagUserFreecamTiltControl then
		cameraRot = Vector3.new(cameraCFrame:toEulerAnglesYXZ())
	else
		cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
	end
	cameraPos = cameraCFrame.p
	cameraFov = Camera.FieldOfView

	velSpring:Reset(Vector3.new())
	panSpring:Reset(Vector2.new())
	fovSpring:Reset(0)
	if FFlagUserFreecamTiltControl then 
		rollSpring:Reset(0)
	end

	if FFlagUserFreecamSmoothnessControl then
		VEL_STIFFNESS = 1.5
		PAN_STIFFNESS = 1.0
		FOV_STIFFNESS = 4.0
		ROLL_STIFFNESS = 1.0
	end

	PlayerState.Push()

	if FFlagUserFreecamDepthOfFieldEffect then
		if not FreecamDepthOfField or not FreecamDepthOfField.Parent then 
			FreecamDepthOfField = Instance.new("DepthOfFieldEffect")
			FreecamDepthOfField.Enabled = false
			FreecamDepthOfField.Name = "FreecamDepthOfField"
			FreecamDepthOfField.Parent = Camera
		end
	end

	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	Input.StartCapture()
end

local function StopFreecam()
	if not FFlagUserFreecamGuiDestabilization then
		if FFlagUserShowGuiHideToggles then
			script:SetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME, false)
		end
	end

	if FFlagUserFreecamDepthOfFieldEffect then
		if FreecamDepthOfField and FreecamDepthOfField.Parent then
			if FreecamDepthOfField.Enabled then 
				for _, effect in ipairs(postEffects) do 
					if effect.Parent then 
						effect.Enabled = true
					end
				end
				postEffects = {}
			end
			FreecamDepthOfField.Enabled = false
		end
	end

	Input.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	PlayerState.Pop()
end

------------------------------------------------------------------------

do
	local enabled = false

	local function ToggleFreecam()
		if enabled then
			StopFreecam()
		else
			StartFreecam()
		end
		enabled = not enabled
		if FFlagUserFreecamGuiDestabilization then
			script:SetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME, enabled)
		end
	end

	local function CheckMacro(macro)
		for i = 1, #macro - 1 do
			if not UserInputService:IsKeyDown(macro[i]) then
				return
			end
		end
		ToggleFreecam()
	end

	local function HandleActivationInput(action, state, input)
		if state == Enum.UserInputState.Begin then
			if input.KeyCode == FREECAM_MACRO_KB[#FREECAM_MACRO_KB] then
				CheckMacro(FREECAM_MACRO_KB)
			end
		end
		return Enum.ContextActionResult.Pass
	end

	ContextActionService:BindActionAtPriority("FreecamToggle", HandleActivationInput, false, TOGGLE_INPUT_PRIORITY, FREECAM_MACRO_KB[#FREECAM_MACRO_KB])

	if FFlagUserFreecamGuiDestabilization or FFlagUserShowGuiHideToggles then
		script:SetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME, enabled)
		script:GetAttributeChangedSignal(FREECAM_ENABLED_ATTRIBUTE_NAME):Connect(function()
			local attributeValue = script:GetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME)

			if typeof(attributeValue) ~= "boolean" then
				script:SetAttribute(FREECAM_ENABLED_ATTRIBUTE_NAME, enabled)
				return
			end

			-- If the attribute's value and `enabled` var don't match, pick attribute value as 
			-- source of truth
			if attributeValue ~= enabled then
				if attributeValue then
					StartFreecam()
					enabled = true
				else
					StopFreecam()
					enabled = false
				end
			end
		end)
	end
end



local Button = Tab:CreateButton({
    Name = "Panic",
    Callback = function()
        Rayfield:Destroy()
    end,
})



