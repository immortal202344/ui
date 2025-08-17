local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "gamesense.vip",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Vip Cheat",
   LoadingSubtitle = "by Immortal",
   ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Ocean", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "F", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = gamesense, -- Create a custom folder for your hub/game
      FileName = "gamesensevip"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Vip Secure",
      Subtitle = "gamesense",
      Note = "Key In https://t.me/Xsoqqviperr", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"gamesense"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Tab = Window:CreateTab("Main", "square-mouse-pointer") -- Title, Image
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
    else
        warn("Invalid input! Please enter a number.")
    end
   end,
})

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
local player = Players.LocalPlayer
local humanoid

-- функция для обновления humanoid при респавне
local function setupCharacter(char)
    humanoid = char:WaitForChild("Humanoid")
end

-- первый персонаж
setupCharacter(player.Character or player.CharacterAdded:Wait())
-- обработка новых респавнов
player.CharacterAdded:Connect(setupCharacter)

local Slider = Tab:CreateSlider({
   Name = "HipHeight",
   Range = {0, 75},
   Increment = 0.1,
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

local Section = Tab:CreateSection("Movement")

local Keybind = Tab:CreateKeybind({
   Name = "Teleport on mouse",
   CurrentKeybind = "C", 
   HoldToInteract = false,
   Flag = "KeybindTP",
   Callback = function()
      local player = game.Players.LocalPlayer
      local mouse = player:GetMouse()
      local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

      if hrp and mouse then
         -- получаем позицию куда наведена мышка
         local pos = mouse.Hit.Position
         -- телепортируем
         hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) -- чуть выше земли
      end
   end,
})





local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local humanoid

-- Настройки "фейк лага"
local lagChance = 0.6 -- шанс того, что анимация залагает
local freezeTime = 0.2 -- сколько секунд будет "застревать"
local skipTime = 0.1 -- пауза перед резким продолжением

-- переменная для включения/выключения
local fakeLagEnabled = false

-- функция для обновления humanoid при респавне
local function setupCharacter(char)
    humanoid = char:WaitForChild("Humanoid")
end

-- первый персонаж
setupCharacter(player.Character or player.CharacterAdded:Wait())
-- обработка новых респавнов
player.CharacterAdded:Connect(setupCharacter)

-- сам Toggle
local Toggle = Tab:CreateToggle({
   Name = "Fake Lag",
   CurrentValue = false,
   Flag = "FakeLagToggle",
   Callback = function(Value)
       fakeLagEnabled = Value -- включаем или выключаем лаги
   end,
})

-- основной цикл
RunService.RenderStepped:Connect(function()
    if fakeLagEnabled and humanoid and math.random() < lagChance then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(0) -- стопаем
            end
            task.wait(freezeTime)
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(3) -- ускоренный рывок вперёд
            end
            task.wait(skipTime)
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(1) -- возвращаем нормальную скорость
            end
        end
    end
end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Настройки
local WALK_SPEED = 16
local BHOP_SPEED = 35
local JUMP_COOLDOWN = 0.3

-- ShakeBhop настройки
local shakeAngle = 10
local shakeInterval = 0.01
local lastShake = 0
local shakeDir = 1

-- SpinBhop угол
local spinAngle = 0

-- CircleBhop
local isCircleHopActive = false
local circleAngle = 0
local circleSpeed = 6
local lastJumpTime = 0

-- Глобальное состояние
local keys = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false
}
local isBunnyHopEnabled = false
local bhopMode = "Forward" -- ("Forward", "SpinBhop", "ShakeBhop")

-- Переменные персонажа
local humanoid, rootPart
local currentCharacter

-- Функция для инициализации персонажа
local function initializeCharacter(newCharacter)
    currentCharacter = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    rootPart = newCharacter:WaitForChild("HumanoidRootPart")

    humanoid.Died:Connect(function()
        spinAngle = 0
        circleAngle = 0
    end)
end

-- Инициализация первого персонажа
local player = Players.LocalPlayer
initializeCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(initializeCharacter)

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then keys.W = true end
    if input.KeyCode == Enum.KeyCode.A then keys.A = true end
    if input.KeyCode == Enum.KeyCode.S then keys.S = true end
    if input.KeyCode == Enum.KeyCode.D then keys.D = true end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keys.W = false end
    if input.KeyCode == Enum.KeyCode.A then keys.A = false end
    if input.KeyCode == Enum.KeyCode.S then keys.S = false end
    if input.KeyCode == Enum.KeyCode.D then keys.D = false end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space = false end
end)

-- Получение векторов камеры
local function getCameraVectors()
    local camera = workspace.CurrentCamera
    if not camera then return Vector3.new(), Vector3.new() end
    
    local forward = (camera.CFrame.LookVector * Vector3.new(1, 0, 1))
    if forward.Magnitude > 0 then forward = forward.Unit else forward = Vector3.new(0,0,1) end

    local right = (camera.CFrame.RightVector * Vector3.new(1, 0, 1))
    if right.Magnitude > 0 then right = right.Unit else right = Vector3.new(1,0,0) end

    return forward, right
end

-- ✅ UI элементы
local Toggle = Tab:CreateToggle({
    Name = "Bunny Hop",
    CurrentValue = false,
    Flag = "BunnyHopToggle",
    Callback = function(Value)
        isBunnyHopEnabled = Value
        if humanoid then
            humanoid.WalkSpeed = WALK_SPEED
        end
        if not Value then
            for key in pairs(keys) do keys[key] = false end
        end
    end,
})

-- Основной цикл
RunService.Heartbeat:Connect(function(dt)
    if not humanoid or not rootPart or humanoid.Health <= 0 then return end

    local currentState = humanoid:GetState()
    local isInAir = currentState == Enum.HumanoidStateType.Jumping 
                 or currentState == Enum.HumanoidStateType.Freefall
    local isGrounded = not isInAir

    -- BunnyHop обычный
    if isBunnyHopEnabled then
        humanoid.AutoRotate = isGrounded
        local forward, right = getCameraVectors()
        local moveDirection = Vector3.new()

        if keys.W then moveDirection = moveDirection + forward end
        if keys.S then moveDirection = moveDirection - forward end
        if keys.D then moveDirection = moveDirection + right end
        if keys.A then moveDirection = moveDirection - right end

        if moveDirection.Magnitude == 0 and keys.Space then
            moveDirection = forward
        end

        if isInAir and moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * BHOP_SPEED * dt

            if bhopMode == "SpinBhop" then
                spinAngle = spinAngle + math.rad(10)
                rootPart.CFrame = CFrame.new(rootPart.Position + moveDirection) * CFrame.Angles(0, spinAngle, 0)

            elseif bhopMode == "Forward" then
                rootPart.CFrame = CFrame.lookAt(
                    rootPart.Position + moveDirection,
                    rootPart.Position + moveDirection + forward
                )

            elseif bhopMode == "ShakeBhop" then
                local now = tick()
                if now - lastShake > shakeInterval then
                    shakeDir = -shakeDir
                    lastShake = now
                end

                local angle = math.rad(shakeAngle * shakeDir)
                rootPart.CFrame = CFrame.lookAt(
                    rootPart.Position + moveDirection,
                    rootPart.Position + moveDirection + forward
                ) * CFrame.Angles(0, angle, 0)
            end
        end

        -- прыжки
        if keys.Space and isGrounded then
            local now = tick()
            if now - lastJumpTime > JUMP_COOLDOWN then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                lastJumpTime = now
            end
        end
    end

    -- 🔄 CircleHop (по бинду)
    if isCircleHopActive then
        humanoid.AutoRotate = false
        circleAngle = circleAngle + circleSpeed * dt

        -- поворот на месте
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, circleAngle, 0)

        -- прыжки
        if not isInAir then
            local now = tick()
            if now - lastJumpTime > JUMP_COOLDOWN then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                lastJumpTime = now
            end
        end
    end
end)


-- Dropdown для выбора режима
local Dropdown = Tab:CreateDropdown({
    Name = "Bhop Mode",
    Options = {"SpinBhop", "Forward", "ShakeBhop"},
    CurrentOption = {"Forward"},
    MultipleOptions = false,
    Flag = "BhopDropdown",
    Callback = function(Option)
        bhopMode = Option[1]
    end,
})

local Tab = Window:CreateTab("Target", "target") -- Title, Image

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local SelectedTarget = nil

local function GetPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)
    return names
end


-- Dropdown
local Dropdown
Dropdown = Tab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "PlayerDropdown",
    Callback = function(Options)
        local targetName = Options[1]
        SelectedTarget = Players:FindFirstChild(targetName)
        if SelectedTarget then
        end
    end,
})

-- Auto update player list
Players.PlayerAdded:Connect(function()
    Dropdown:Refresh(GetPlayerNames())
end)
Players.PlayerRemoving:Connect(function()
    Dropdown:Refresh(GetPlayerNames())
end)

-- Teleport
local function TeleportToPlayer(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(0,3,0))
    end
end

-- Spectate toggle
local Toggle = Tab:CreateToggle({
    Name = "Spectate",
    CurrentValue = false,
    Flag = "SpectateToggle",
    Callback = function(Value)
        if Value then
            if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = SelectedTarget.Character:FindFirstChild("Humanoid")
            end
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
            end
        end
    end,
})

local function FlingPlayer(target)
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local thrp = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not thrp then return end

    -- Save old position
    local oldCFrame = hrp.CFrame

    -- Enable collisions
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = true
            p.Massless = false
        end
    end

    -- Create BodyVelocity
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Parent = hrp

    -- Do fling inside target
    local t0 = tick()
    while tick() - t0 < 1.5 do
        if not (target.Character and target.Character:FindFirstChild("HumanoidRootPart")) then break end
        thrp = target.Character.HumanoidRootPart

        -- Stay inside the target
        hrp.CFrame = thrp.CFrame

        -- Strong velocity bursts
        bv.Velocity = Vector3.new(
            math.random(-6000,6000),
            math.random(6000,9000),
            math.random(-6000,6000)
        )

        task.wait()
    end

    -- Cleanup and restore
    bv:Destroy()
    hrp.CFrame = oldCFrame
    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
end


-- Teleport button
Tab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if SelectedTarget then
            TeleportToPlayer(SelectedTarget)
        else
            warn("No player selected")
        end
    end,
})

-- Fling button
Tab:CreateButton({
    Name = "Fling Player",
    Callback = function()
        if SelectedTarget then
            FlingPlayer(SelectedTarget)
        else
            warn("No player selected")
        end
    end,
})

local Tab = Window:CreateTab("Visual", "eye")
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

local Section = Tab:CreateSection("Camera")

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

-- Улучшенная Debug Camera для Roblox с поддержкой keybind из библиотеки
local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera
local debugEnabled = false
local cameraSpeed = 50  -- Увеличенная базовая скорость
local fastSpeedMultiplier = 3
local slowSpeedMultiplier = 0.3
local mouseSensitivity = 0.5  -- Чувствительность мыши

-- Сохраняем оригинальные настройки камеры
local originalCameraType
local originalCameraSubject
local originalFieldOfView = 70

-- Настройки управления (можно изменить)
local moveKeys = {
    forward = Enum.KeyCode.W,
    backward = Enum.KeyCode.S,
    left = Enum.KeyCode.A,
    right = Enum.KeyCode.D,
    up = Enum.KeyCode.Space,
    down = Enum.KeyCode.LeftControl
}

-- Переменные для вращения камеры
local yaw = 0
local pitch = 0

-- Функция для включения debug камеры
local function enableDebugCamera()
    if debugEnabled then return end
    debugEnabled = true
    
    -- Сохраняем текущие настройки камеры
    originalCameraType = camera.CameraType
    originalCameraSubject = camera.CameraSubject
    originalFieldOfView = camera.FieldOfView
    
    -- Устанавливаем камеру в ручной режим
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CameraSubject = nil
    
    -- Инициализируем углы вращения
    local look = camera.CFrame.LookVector
    yaw = math.atan2(look.X, look.Z)
    pitch = math.asin(look.Y)
    
    -- Останавливаем персонажа, если он существует
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = 0
        Player.Character.Humanoid.JumpPower = 0
    end
    
    -- Скрываем интерфейс для лучшего обзора
    if Player:FindFirstChild("PlayerGui") then
        Player.PlayerGui:SetTopbarTransparency(1)
    end
    
    -- Захватываем мышь для плавного вращения
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

-- Функция для выключения debug камеры
local function disableDebugCamera()
    if not debugEnabled then return end
    debugEnabled = false
    
    -- Восстанавливаем оригинальные настройки камеры
    camera.CameraType = originalCameraType or Enum.CameraType.Custom
    camera.CameraSubject = originalCameraSubject or Player.Character and Player.Character:FindFirstChild("Humanoid")
    camera.FieldOfView = originalFieldOfView or 70
    
    -- Восстанавливаем скорость персонажа, если он существует
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = 16
        Player.Character.Humanoid.JumpPower = 50
    end
    
    -- Восстанавливаем интерфейс
    if Player:FindFirstChild("PlayerGui") then
        Player.PlayerGui:SetTopbarTransparency(0)
    end
    
    -- Возвращаем нормальное поведение мыши
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

-- Функция для переключения debug камеры
local function toggleDebugCamera()
    if debugEnabled then
        disableDebugCamera()
    else
        enableDebugCamera()
    end
end

-- Создаем keybind через библиотеку
local Keybind = Tab:CreateKeybind({
   Name = "Debug camera",
   CurrentKeybind = "P",
   HoldToInteract = false,
   Flag = "Keybind1",
   Callback = function(knopka)
       toggleDebugCamera()
   end,
})

-- Основной цикл движения камеры
RunService.RenderStepped:Connect(function(deltaTime)
    if not debugEnabled then return end
    
    -- Определяем текущую скорость
    local currentSpeed = cameraSpeed
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        currentSpeed = currentSpeed * slowSpeedMultiplier
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        currentSpeed = currentSpeed * fastSpeedMultiplier
    end
    
    -- Обработка вращения камеры мышью
    local mouseDelta = UserInputService:GetMouseDelta()
    yaw = yaw - mouseDelta.X * 0.01 * mouseSensitivity
    pitch = math.clamp(pitch - mouseDelta.Y * 0.01 * mouseSensitivity, -math.pi/2 + 0.1, math.pi/2 - 0.1)
    
    -- Создаем новую ориентацию камеры
    local newCFrame = CFrame.new(camera.CFrame.Position) * 
                     CFrame.fromOrientation(pitch, yaw, 0)
    
    -- Движение камеры
    local moveVector = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(moveKeys.forward) then
        moveVector = moveVector + newCFrame.LookVector
    end
    if UserInputService:IsKeyDown(moveKeys.backward) then
        moveVector = moveVector - newCFrame.LookVector
    end
    if UserInputService:IsKeyDown(moveKeys.left) then
        moveVector = moveVector - newCFrame.RightVector
    end
    if UserInputService:IsKeyDown(moveKeys.right) then
        moveVector = moveVector + newCFrame.RightVector
    end
    if UserInputService:IsKeyDown(moveKeys.up) then
        moveVector = moveVector + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(moveKeys.down) then
        moveVector = moveVector - Vector3.new(0, 1, 0)
    end
    
    -- Применяем движение
    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit * currentSpeed * deltaTime
        newCFrame = newCFrame + moveVector
    end
    
    -- Обновляем позицию и поворот камеры
    camera.CFrame = newCFrame
    
    -- Изменение FOV колесиком мыши
    local mouseWheel = UserInputService:GetMouseWheel()
    if mouseWheel ~= 0 then
        camera.FieldOfView = math.clamp(camera.FieldOfView - mouseWheel * 2, 5, 120)
    end
end)

-- Автоматическое отключение debug-камеры при смерти
Player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").Died:Connect(function()
        disableDebugCamera()
    end)
end)

local Section = Tab:CreateSection("Visual")

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

local Section = Tab:CreateSection("Trail")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Настройки по умолчанию
local trailSettings = {
    Enabled = false,
    Color = Color3.fromRGB(0, 255, 0),
    Height = 0,    -- 0 = уровень rootpart, >0 = выше, <0 = ниже
    Width = 0.03,  -- Толщина трейла
    Lifetime = 0.2 -- Длина следа
}

local trailObj, attach1, attach2

-- Функция создания/обновления трейла
local function updateTrail(character)
    if not character then return end
    
    -- Удаляем старые объекты
    if trailObj then trailObj:Destroy() end
    if attach1 then attach1:Destroy() end
    if attach2 then attach2:Destroy() end
    
    local root = character:WaitForChild("HumanoidRootPart")
    if not root then return end
    
    -- Создаем аттачменты
    attach1 = Instance.new("Attachment")
    attach1.Name = "TrailAttachment1"
    attach1.Parent = root
    attach1.CFrame = CFrame.new(0, trailSettings.Height, 0)
    
    attach2 = Instance.new("Attachment")
    attach2.Name = "TrailAttachment2"
    attach2.Parent = root
    attach2.CFrame = CFrame.new(0, trailSettings.Height - 0.05, 0) -- Чуть ниже
    
    -- Создаем трейл
    trailObj = Instance.new("Trail")
    trailObj.Name = "CustomTrail"
    trailObj.Attachment0 = attach1
    trailObj.Attachment1 = attach2
    trailObj.Color = ColorSequence.new(trailSettings.Color)
    trailObj.LightEmission = 0.5
    trailObj.Transparency = NumberSequence.new(0.3)
    trailObj.Lifetime = trailSettings.Lifetime
    trailObj.MinLength = 0.01
    trailObj.WidthScale = NumberSequence.new(trailSettings.Width)
    trailObj.Parent = root
end

-- Обработчик респавна
local function onCharacterAdded(character)
    if trailSettings.Enabled then
        updateTrail(character)
    end
end

-- Toggle
local Toggle = Tab:CreateToggle({
    Name = "Trail",
    CurrentValue = trailSettings.Enabled,
    Flag = "TrailToggle",
    Callback = function(value)
        trailSettings.Enabled = value
        if value then
            if player.Character then
                updateTrail(player.Character)
            end
        else
            if trailObj then trailObj:Destroy() end
            if attach1 then attach1:Destroy() end
            if attach2 then attach2:Destroy() end
        end
    end
})

-- ColorPicker
local ColorPicker = Tab:CreateColorPicker({
    Name = "Trail color",
    Color = trailSettings.Color,
    Flag = "TrailColor",
    Callback = function(color)
        trailSettings.Color = color
        if trailSettings.Enabled and trailObj then
            trailObj.Color = ColorSequence.new(color)
        end
    end
})

-- Slider для высоты
local HeightSlider = Tab:CreateSlider({
    Name = "Trail height",
    Range = {-3, 2},  -- От -2 до +2
    Increment = 0.1,
    CurrentValue = trailSettings.Height,
    Flag = "TrailHeight",
    Callback = function(value)
        trailSettings.Height = value
        if trailSettings.Enabled and player.Character then
            updateTrail(player.Character)
        end
    end
})

-- Slider для ширины
local WidthSlider = Tab:CreateSlider({
    Name = "Trail width",
    Range = {0.5, 3},  -- От 0.01 до 0.5
    Increment = 0.01,
    CurrentValue = trailSettings.Width,
    Flag = "TrailWidth",
    Callback = function(value)
        trailSettings.Width = value
        if trailSettings.Enabled and trailObj then
            trailObj.WidthScale = NumberSequence.new(value)
        end
    end
})

-- Slider для длины следа
local LifetimeSlider = Tab:CreateSlider({
    Name = "Trail life time",
    Range = {0.05, 1},  -- От 0.05 до 1
    Increment = 0.05,
    CurrentValue = trailSettings.Lifetime,
    Flag = "TrailLifetime",
    Callback = function(value)
        trailSettings.Lifetime = value
        if trailSettings.Enabled and trailObj then
            trailObj.Lifetime = value
        end
    end
})

-- Инициализация
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end

local Section = Tab:CreateSection("Localplayer")

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Глобальные настройки
local originalMaterials = {}
local originalFace = nil
local originalHRPTransparency
local currentColor = Color3.fromRGB(255, 255, 255)
local forceFieldEnabled = false

-- Сохраняем оригинальные данные
local function saveOriginalAssets()
    originalMaterials = {}
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            originalMaterials[part] = {
                Material = part.Material,
                Transparency = part.Transparency,
                Color = part.Color
            }
            
            if part.Name == "HumanoidRootPart" then
                originalHRPTransparency = part.Transparency
            end
        end
    end
    
    -- Сохраняем лицо
    local head = character:FindFirstChild("Head")
    if head then
        for _, decal in ipairs(head:GetChildren()) do
            if decal:IsA("Decal") and decal.Name == "face" then
                originalFace = decal:Clone()
                break
            end
        end
    end
end

-- Применяем ForceField ко всем частям и аксессуарам
local function applyForceField()
    for part, _ in pairs(originalMaterials) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.ForceField
            part.Color = currentColor
            part.Transparency = 0
            
            if part.Name == "HumanoidRootPart" then
                part.Transparency = 1 -- Полностью скрываем
            end
        end
    end
    
    -- Обрабатываем аксессуары
    for _, accessory in ipairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle then
                handle.Material = Enum.Material.ForceField
                handle.Color = currentColor
                handle.Transparency = 0
            end
        end
    end
    
    -- Удаляем лицо
    local head = character:FindFirstChild("Head")
    if head then
        for _, decal in ipairs(head:GetChildren()) do
            if decal:IsA("Decal") and decal.Name == "face" then
                decal:Destroy()
            end
        end
    end
end

-- Восстанавливаем оригинальные материалы
local function restoreOriginalAssets()
    for part, data in pairs(originalMaterials) do
        if part:IsA("BasePart") then
            part.Material = data.Material
            part.Color = data.Color
            part.Transparency = data.Transparency
        end
    end
    
    -- Восстанавливаем HumanoidRootPart
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp and originalHRPTransparency then
        hrp.Transparency = originalHRPTransparency
    end
    
    -- Восстанавливаем лицо
    local head = character:FindFirstChild("Head")
    if head and originalFace then
        for _, decal in ipairs(head:GetChildren()) do
            if decal:IsA("Decal") and decal.Name == "face" then
                decal:Destroy()
            end
        end
        originalFace:Clone().Parent = head
    end
    
    -- Восстанавливаем аксессуары
    for _, accessory in ipairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle and originalMaterials[handle] then
                handle.Material = originalMaterials[handle].Material
                handle.Color = originalMaterials[handle].Color
                handle.Transparency = originalMaterials[handle].Transparency
            end
        end
    end
end

-- Обновляем цвет всех частей
local function updateColor(newColor)
    currentColor = newColor
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = currentColor
        end
    end
    
    -- Обновляем цвет аксессуаров
    for _, accessory in ipairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle then
                handle.Color = currentColor
            end
        end
    end
end

-- Обработчик смены персонажа
local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    
    -- Ждем полной загрузки персонажа
    character:WaitForChild("HumanoidRootPart")
    
    -- Сохраняем оригинальные данные
    saveOriginalAssets()
    
    -- Применяем текущие настройки
    if forceFieldEnabled then
        applyForceField()
    else
        restoreOriginalAssets()
        updateColor(currentColor) -- Применяем текущий цвет
    end
    
    -- Обработчик смерти
    humanoid.Died:Connect(function()
        task.wait(2) -- Ждем респавна
    end)
end

-- Инициализация
saveOriginalAssets()

-- Подписываемся на события
localPlayer.CharacterAdded:Connect(onCharacterAdded)

-- UI элементы
local Toggle = Tab:CreateToggle({
    Name = "ForceField Material",
    CurrentValue = forceFieldEnabled,
    Flag = "ForceFieldToggle",
    Callback = function(Value)
        forceFieldEnabled = Value
        if Value then
            applyForceField()
        else
            restoreOriginalAssets()
        end
        updateColor(currentColor) -- Обновляем цвет в любом случае
    end,
})

local ColorPicker = Tab:CreateColorPicker({
    Name = "Player Color",
    Color = currentColor,
    Flag = "PlayerColorPicker",
    Callback = function(Value)
        currentColor = Value
        updateColor(Value)
    end
})

local players = game:GetService("Players")
local runService = game:GetService("RunService")

-- заранее объявляем переменные
local Toggle, Slider, ColorPicker
local clientPredictionRootPart

-- Основной код
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: Part

clientPredictionRootPart = Instance.new("Part")
clientPredictionRootPart.Name = "PingPredictionPart"
clientPredictionRootPart.Anchored = true
clientPredictionRootPart.CanCollide = false
clientPredictionRootPart.CanTouch = false
clientPredictionRootPart.CanQuery = false
clientPredictionRootPart.EnableFluidForces = false
clientPredictionRootPart.Massless = true
clientPredictionRootPart.Locked = true
clientPredictionRootPart.Material = Enum.Material.SmoothPlastic
clientPredictionRootPart.Size = Vector3.new(2, 2, 1)
clientPredictionRootPart.CastShadow = false
clientPredictionRootPart.Parent = character

local connection = runService.Heartbeat:Connect(function()
    if not Toggle or not Toggle.CurrentValue or not clientPredictionRootPart or clientPredictionRootPart.Transparency == 1 then
        return
    end
    
    local savedCFrame = humanoidRootPart.CFrame
    local ping = player:GetNetworkPing()
    task.wait(ping * 2)
    if clientPredictionRootPart then
        clientPredictionRootPart.CFrame = savedCFrame
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: Part
    
    if clientPredictionRootPart then
        clientPredictionRootPart:Destroy()
    end
    
    clientPredictionRootPart = Instance.new("Part")
    clientPredictionRootPart.Name = "PingPredictionPart"
    clientPredictionRootPart.Anchored = true
    clientPredictionRootPart.CanCollide = false
    clientPredictionRootPart.CanTouch = false
    clientPredictionRootPart.CanQuery = false
    clientPredictionRootPart.EnableFluidForces = false
    clientPredictionRootPart.Massless = true
    clientPredictionRootPart.Locked = true
    clientPredictionRootPart.Material = Enum.Material.SmoothPlastic
    clientPredictionRootPart.Size = Vector3.new(2, 2, 1)
    clientPredictionRootPart.CastShadow = false
    clientPredictionRootPart.Parent = character

    if ColorPicker then
        clientPredictionRootPart.Color = ColorPicker.CurrentValue
    end
    if Toggle and Slider then
        clientPredictionRootPart.Transparency = Toggle.CurrentValue and Slider.CurrentValue or 1
    else
        clientPredictionRootPart.Transparency = 1
    end
end)

-- Функция очистки (если надо вручную вызвать)
local function cleanup()
    if connection then connection:Disconnect() end
    if clientPredictionRootPart then clientPredictionRootPart:Destroy() end
end

-- UI элементы создаём после Tab
Toggle = Tab:CreateToggle({
    Name = "Ping Prediction",
    CurrentValue = false,
    Flag = "PingPredictionToggle",
    Callback = function(Value)
        if clientPredictionRootPart then
            clientPredictionRootPart.Transparency = Value and Slider.CurrentValue or 1
        end
    end
})

Slider = Tab:CreateSlider({
    Name = "Prediction Transparency",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "%",
    CurrentValue = 0.5,
    Flag = "TransparencySlider",
    Callback = function(Value)
        if clientPredictionRootPart and Toggle.CurrentValue then
            clientPredictionRootPart.Transparency = Value
        end
    end
})

ColorPicker = Tab:CreateColorPicker({
    Name = "Prediction Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "PredictionColorPicker",
    Callback = function(Value)
        if clientPredictionRootPart then
            clientPredictionRootPart.Color = Value
        end
    end
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local coneColor = Color3.fromRGB(255, 0, 137) -- Начальный цвет (розовый)
local conePart = nil -- Хранит текущий конус

-- Функция для создания конуса
local function createCone(character)
    if not character or not character:FindFirstChild("Head") then return end

    -- Удаляем старый конус, если он есть
    if conePart and conePart.Parent then
        conePart:Destroy()
    end

    local head = character.Head

    -- Создаём конус
    conePart = Instance.new("Part")
    conePart.Name = "ChinaHat"
    conePart.Size = Vector3.new(1, 1, 1)
    conePart.BrickColor = BrickColor.new("White")
    conePart.Transparency = 0.3
    conePart.Anchored = false
    conePart.CanCollide = false

    local mesh = Instance.new("SpecialMesh", conePart)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(1.7, 1.1, 1.7)

    local weld = Instance.new("Weld")
    weld.Part0 = head
    weld.Part1 = conePart
    weld.C0 = CFrame.new(0, 0.9, 0)

    -- Добавляем Highlight
    local highlight = Instance.new("Highlight", conePart)
    highlight.FillColor = coneColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = coneColor
    highlight.OutlineTransparency = 0

    conePart.Parent = character
    weld.Parent = conePart

    return conePart
end

-- Проверяем наличие конуса и пересоздаём при необходимости
local function checkCone()
    if not player.Character then return end
    
    local hatExists = player.Character:FindFirstChild("ChinaHat") or false
    if not hatExists then
        createCone(player.Character)
    else
        -- Обновляем цвет, если конус уже есть
        local highlight = player.Character.ChinaHat:FindFirstChild("Highlight")
        if highlight then
            highlight.FillColor = coneColor
            highlight.OutlineColor = coneColor
        end
    end
end

-- Автоматическое пересоздание при респавне
player.CharacterAdded:Connect(function(character)
    createCone(character)
    
    -- Проверяем конус каждую секунду (на случай удаления)
    while character and character:IsDescendantOf(game) do
        checkCone()
        task.wait(1) -- Проверка каждую секунду
    end
end)

-- Если персонаж уже есть при запуске скрипта
if player.Character then
    createCone(player.Character)
end

-- ColorPicker (пример для вашего UI)
local ColorPicker = Tab:CreateColorPicker({
    Name = "China hat",
    Color = coneColor,
    Flag = "ColorPicker1",
    Callback = function(color)
        coneColor = color
        checkCone() -- Обновляем цвет при изменении
    end
})

local Tab = Window:CreateTab("Misc", "boxes") -- Title, Image
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

local Tab = Window:CreateTab("Sky", "cloud") -- Title, Image
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

-- 🌐 Tab Server Info
local Tab = Window:CreateTab("Server") -- Title, Image

-- Сервисы
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")

-- Название плейса
local PlaceName = "Unknown Place"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    PlaceName = info.Name or PlaceName
end)

-- Лейбл с названием плейса (⚡ без второго аргумента!)
Tab:CreateLabel("Place: " .. PlaceName)

-- 🔄 Кнопка Rejoin (тот же сервер)
Tab:CreateButton({
   Name = "Rejoin",
   Callback = function()
       local ok, err = pcall(function()
           TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
       end)
       if not ok then
           warn("Rejoin failed:", err)
       end
   end,
})

-- 🌍 Кнопка Serverhop (другой сервер)
Tab:CreateButton({
   Name = "Serverhop",
   Callback = function()
       local ok, err = pcall(function()
           TeleportService:Teleport(game.PlaceId, LocalPlayer)
       end)
       if not ok then
           warn("Serverhop failed:", err)
       end
   end,
})

local Tab = Window:CreateTab("Settings/Credits", "settings") -- Title, Image
local Section = Tab:CreateSection("Credits")

local Label = Tab:CreateLabel("Created by Immortal")
local Label = Tab:CreateLabel("You rank: vip")
local Label = Tab:CreateLabel("Version 3.6")

local Section = Tab:CreateSection("Watermark")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- параметры watermark
local wmX, wmY = 100, 100
local width, height = 260, 22 -- сделал чуть выше (22 вместо 20)

-- фон (тёмно-серый прямоугольник)
local background = Drawing.new("Square")
background.Visible = true
background.Color = Color3.fromRGB(25, 25, 25) -- был чёрный, теперь серо-тёмный
background.Filled = true
background.Transparency = 1 -- 1 = полностью видимый
background.Size = Vector2.new(width, height)

-- градиентная полоска (будем рисовать линиями)
local gradientLines = {}
local gradientHeight = height
for i = 1, gradientHeight do
    local line = Drawing.new("Line")
    line.Visible = true
    line.Thickness = 2
    table.insert(gradientLines, line)
end

-- текст
local watermark = Drawing.new("Text")
watermark.Size = 16
watermark.Color = Color3.fromRGB(255, 255, 255)
watermark.Outline = true
watermark.Font = 2
watermark.Center = false
watermark.Visible = true

-- функция для интерполяции цвета (градиент)
local function lerpColor(c1, c2, t)
    return Color3.new(
        c1.R + (c2.R - c1.R) * t,
        c1.G + (c2.G - c1.G) * t,
        c1.B + (c2.B - c1.B) * t
    )
end

-- обновление watermark
local function updateWatermark()
    local player = Players.LocalPlayer
    local nickname = player and player.Name or "Unknown"

    -- пинг
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) 
    local timeStr = os.date("%H:%M:%S")

    -- текст
    watermark.Text = "gamesense | " .. nickname .. " | delay: " .. ping .. "ms | " .. timeStr

    -- авто-ширина по тексту
    local textLen = watermark.TextBounds.X + 20
    background.Size = Vector2.new(textLen, height)

    -- позиции
    background.Position = Vector2.new(wmX, wmY)
    watermark.Position = Vector2.new(wmX + 6, wmY + 2)

    -- градиент полоски (зелёный → оранжевый)
    local topColor = Color3.fromRGB(0, 255, 0)
    local bottomColor = Color3.fromRGB(255, 128, 0)

    for i, line in ipairs(gradientLines) do
        local t = i / gradientHeight
        local col = lerpColor(topColor, bottomColor, t)
        line.Color = col
        line.From = Vector2.new(wmX - 2, wmY + i)
        line.To = Vector2.new(wmX, wmY + i)
    end
end

RunService.RenderStepped:Connect(updateWatermark)

------------------------------------------------
-- Drag & Drop логика (поверх watermark)
------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragOffset = Vector2.new(0, 0)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouse = UserInputService:GetMouseLocation()
        -- проверка: клик внутри watermark
        if mouse.X >= wmX and mouse.X <= wmX + background.Size.X
           and mouse.Y >= wmY and mouse.Y <= wmY + background.Size.Y then
            dragging = true
            dragOffset = Vector2.new(mouse.X - wmX, mouse.Y - wmY)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouse = UserInputService:GetMouseLocation()
        wmX = mouse.X - dragOffset.X
        wmY = mouse.Y - dragOffset.Y
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)


-- слайдер X
local SliderX = Tab:CreateSlider({
   Name = "Watermark X",
   Range = {0, 1920}, -- FHD
   Increment = 5,
   Suffix = "px",
   CurrentValue = wmX,
   Flag = "WM_X",
   Callback = function(Value)
       wmX = Value
   end,
})

-- слайдер Y
local SliderY = Tab:CreateSlider({
   Name = "Watermark Y",
   Range = {0, 1080}, -- FHD
   Increment = 5,
   Suffix = "px",
   CurrentValue = wmY,
   Flag = "WM_Y",
   Callback = function(Value)
       wmY = Value
   end,
})



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

local speedEnabled = false
local Keybind = Tab:CreateKeybind({
    Name = "SpeedMod",
    CurrentKeybind = "L",
    HoldToInteract = false, -- Режим переключателя
    Flag = "SpeedToggleKeybind",
    Callback = function()
        speedEnabled = not speedEnabled
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedEnabled and 60 or 16
        end
    end,
})

local Button = Tab:CreateButton({
    Name = "Panic",
    Callback = function()
        Rayfield:Destroy()
    end,
})



