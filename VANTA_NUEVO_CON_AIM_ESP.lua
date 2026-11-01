

getgenv().uiLE = getgenv().uiLE or {}



if getgenv().uiLE.loading then return end



getgenv().uiLE.loading = true



local function fetchUrlList(urls)

for _, url in ipairs(urls) do

local ok, result = pcall(function() return game:HttpGet(url) end)

if ok and result and result ~= "" then return result end

end

return nil

end



local function tryLoadFromURL(url)

local content = fetchUrlList({url})

if not content then return nil end

local func = loadstring(content)

if not func then return nil end

local ok, result = pcall(func)

if not ok then return nil end

return result

end



local function safeLoadString(urls)

for _, url in ipairs(urls) do

local result = tryLoadFromURL(url)

if result then return result end

end

return nil

end



local limbExtenderURLs = {

    "https://raw.githubusercontent.com/Aurora-Script/UiLibSb/refs/heads/main/LimbExtender3%20(1).lua"

}



getgenv().uiLE.le = getgenv().uiLE.le or safeLoadString(limbExtenderURLs)



if not getgenv().uiLE.le then

    getgenv().uiLE.loading = false

return

end



if getgenv().uiLE.gcontroller then

    getgenv().uiLE.gcontroller:Destroy()

    getgenv().uiLE.gcontroller = nil

end



getgenv().uiLE.gcontroller = getgenv().uiLE.le.new()



local ctrl = getgenv().uiLE.gcontroller



local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer



getgenv().uiLE.targetLimbDropdown = nil

getgenv().uiLE.whitelistTeamsDropdown = nil

getgenv().uiLE.blacklistTeamsDropdown = nil

getgenv().uiLE.whitelistPlayersDropdown = nil

getgenv().uiLE.blacklistPlayersDropdown = nil



local scannedLimbs = {}



local limbPriority = {

    "Head","HumanoidRootPart","UpperTorso","LowerTorso","Torso",

    "LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand",

    "Left Arm","Right Arm",

    "LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot",

    "Left Leg","Right Leg",

}



local function getLimbPriority(name)

local lower = name:lower()

for index, limb in ipairs(limbPriority) do

if lower:find(limb:lower(), 1, true) then return index end

end

return math.huge

end



local function sortLimbs()

    table.sort(scannedLimbs, function(a, b)

local pa = getLimbPriority(a)

local pb = getLimbPriority(b)

if pa ~= pb then return pa < pb end

return a:lower() < b:lower()

end)

end



local function registerLimb(name)

if not name or table.find(scannedLimbs, name) then return end

    table.insert(scannedLimbs, name)

    sortLimbs()



if getgenv().uiLE.targetLimbDropdown then

        getgenv().uiLE.targetLimbDropdown:Refresh(scannedLimbs)

end

end



local function getPartPath(part, character)

local path = part.Name

local parent = part.Parent



while parent and parent ~= character do

        path = parent.Name .. "." .. path

        parent = parent.Parent

end



return path

end



local function scanCharacter(character)

if not character then return end

    table.clear(scannedLimbs)



for _, desc in ipairs(character:GetDescendants()) do

if desc:IsA("BasePart") then

            registerLimb(getPartPath(desc, character))

end

end

end



local charAddedConn



local function InitializeLimbScanning()

if charAddedConn then charAddedConn:Disconnect() end



    charAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)

        scanCharacter(character)



        character.DescendantAdded:Connect(function(desc)

if desc:IsA("BasePart") then

                registerLimb(getPartPath(desc, character))

end

end)

end)



if LocalPlayer.Character then

        scanCharacter(LocalPlayer.Character)



        LocalPlayer.Character.DescendantAdded:Connect(function(desc)

if desc:IsA("BasePart") then

                registerLimb(getPartPath(desc, LocalPlayer.Character))

end

end)

end

end



local scannedTeams = {}



local function sortTeams()

    table.sort(scannedTeams, function(a, b)

return a:lower() < b:lower()

end)

end



local function registerTeam(name)

if not name or table.find(scannedTeams, name) then return end

    table.insert(scannedTeams, name)

    sortTeams()



if getgenv().uiLE.whitelistTeamsDropdown then

        getgenv().uiLE.whitelistTeamsDropdown:Refresh(scannedTeams)

end



if getgenv().uiLE.blacklistTeamsDropdown then

        getgenv().uiLE.blacklistTeamsDropdown:Refresh(scannedTeams)

end

end



local function unregisterTeam(name)

local idx = table.find(scannedTeams, name)



if idx then

        table.remove(scannedTeams, idx)



if getgenv().uiLE.whitelistTeamsDropdown then

            getgenv().uiLE.whitelistTeamsDropdown:Refresh(scannedTeams)

end



if getgenv().uiLE.blacklistTeamsDropdown then

            getgenv().uiLE.blacklistTeamsDropdown:Refresh(scannedTeams)

end

end

end



local function scanTeams()

    table.clear(scannedTeams)

local teamsService = game:GetService("Teams")



for _, team in ipairs(teamsService:GetChildren()) do

if team:IsA("Team") then

            registerTeam(team.Name)

end

end

end



local teamsConn



local function InitializeTeamScanning()

if teamsConn then teamsConn:Disconnect() end



local teamsService = game:GetService("Teams")

    scanTeams()



    teamsConn = teamsService.ChildAdded:Connect(function(child)

if child:IsA("Team") then

            registerTeam(child.Name)

end

end)



    teamsService.ChildRemoved:Connect(function(child)

if child:IsA("Team") then

            unregisterTeam(child.Name)

end

end)

end



local scannedPlayers = {}

local nameToUserId = {}

local userIdToName = {}



local function sortPlayers()

    table.sort(scannedPlayers, function(a, b)

return a:lower() < b:lower()

end)

end



local function registerPlayer(player)

if not player or not player:IsA("Player") then return end



local name = player.Name

if table.find(scannedPlayers, name) then return end



    table.insert(scannedPlayers, name)

    nameToUserId[name] = player.UserId

    userIdToName[player.UserId] = name

    sortPlayers()



if getgenv().uiLE.whitelistPlayersDropdown then

        getgenv().uiLE.whitelistPlayersDropdown:Refresh(scannedPlayers)

end



if getgenv().uiLE.blacklistPlayersDropdown then

        getgenv().uiLE.blacklistPlayersDropdown:Refresh(scannedPlayers)

end

end



local function unregisterPlayer(player)

if not player or not player:IsA("Player") then return end



local name = player.Name

local idx = table.find(scannedPlayers, name)



if idx then

        table.remove(scannedPlayers, idx)

        nameToUserId[name] = nil

        userIdToName[player.UserId] = nil



if getgenv().uiLE.whitelistPlayersDropdown then

            getgenv().uiLE.whitelistPlayersDropdown:Refresh(scannedPlayers)

end



if getgenv().uiLE.blacklistPlayersDropdown then

            getgenv().uiLE.blacklistPlayersDropdown:Refresh(scannedPlayers)

end

end

end



local function scanPlayers()

    table.clear(scannedPlayers)

    table.clear(nameToUserId)

    table.clear(userIdToName)



for _, player in ipairs(Players:GetPlayers()) do

if player ~= LocalPlayer then

            registerPlayer(player)

end

end

end



local playerAddedConn, playerRemovingConn



local function InitializePlayerScanning()

if playerAddedConn then playerAddedConn:Disconnect() end

if playerRemovingConn then playerRemovingConn:Disconnect() end



    scanPlayers()



    playerAddedConn = Players.PlayerAdded:Connect(function(player)

if player ~= LocalPlayer then

            registerPlayer(player)

end

end)



    playerRemovingConn = Players.PlayerRemoving:Connect(function(player)

        unregisterPlayer(player)

end)

end



local function userIdArrayToNames(userIdArray)

if type(userIdArray) ~= "table" then return {} end



local names = {}



for _, uid in ipairs(userIdArray) do

local name = userIdToName[uid]

if name then

            table.insert(names, name)

end

end



return names

end



--// ==================== AIM + ESP RUNTIME (EXTRAIDO DE SCRIPT V2) ====================
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local AIM_IS_MOBILE = UserInputService.TouchEnabled

local AimState = {
    Enabled = false,
    TeamCheck = false,
    FOV = 90,
    Smoothing = 1,
    PredictionFactor = 0.01,
    MaxDistance = 150,
    HoldMode = "MouseButton2",
    LockPart = "Head",
    UsePrediction = false,
    IgnoredPlayers = {},
    IdleColor = Color3.fromRGB(255, 255, 255),
    LockColor = Color3.fromRGB(255, 255, 255),
    CurrentTarget = nil,
}

local aimLimbList = {}
local aimLimbDropdown = nil
local aimIgnoreDropdown = nil

local function refreshAimDropdown(dropdown, values)
    if not dropdown then return end
    pcall(function()
        if dropdown.Refresh then
            dropdown:Refresh(values)
        elseif dropdown.SetValues then
            dropdown:SetValues(values)
        end
    end)
end

local function registerAimLimb(name)
    if not name or table.find(aimLimbList, name) then return end
    table.insert(aimLimbList, name)
    table.sort(aimLimbList)
    refreshAimDropdown(aimLimbDropdown, aimLimbList)
end

local function scanAimCharacter(character)
    if not character then return end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") then registerAimLimb(child.Name) end
    end
end

if LocalPlayer.Character then
    scanAimCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(character)
    table.clear(aimLimbList)
    scanAimCharacter(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then registerAimLimb(child.Name) end
    end)
end)
if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then registerAimLimb(child.Name) end
    end)
end
if #aimLimbList == 0 then
    table.insert(aimLimbList, "Head")
end

local FOVring
pcall(function()
    FOVring = Drawing.new("Circle")
    FOVring.Visible = false
    FOVring.Thickness = 0.8
    FOVring.Radius = AimState.FOV
    FOVring.Transparency = 1
    FOVring.Color = AimState.IdleColor
end)

local function isAimIgnored(player)
    return AimState.IgnoredPlayers[player.Name] == true
end

local function isValidAimTarget(player)
    if not player or player == LocalPlayer or isAimIgnored(player) then return false end
    local character = player.Character
    if not character then return false end

    local targetPart = character:FindFirstChild(AimState.LockPart)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not targetPart or not humanoid or not root or humanoid.Health <= 0 then return false end
    if AimState.TeamCheck and player.Team == LocalPlayer.Team then return false end

    Camera = workspace.CurrentCamera
    if not Camera then return false end
    return (root.Position - Camera.CFrame.Position).Magnitude <= AimState.MaxDistance
end

local function getClosestAimTarget()
    Camera = workspace.CurrentCamera
    if not Camera then return nil end

    local closest, minDistance = nil, math.huge
    local center = Camera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidAimTarget(player) then
            local part = player.Character:FindFirstChild(AimState.LockPart)
            local screenPosition, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local screenDistance = (Vector2.new(screenPosition.X, screenPosition.Y) - center).Magnitude
                if screenDistance <= AimState.FOV and screenDistance < minDistance then
                    minDistance = screenDistance
                    closest = player
                end
            end
        end
    end
    return closest
end

local function getPredictedAimPosition(player)
    local character = player and player.Character
    if not character then return nil end

    local part = character:FindFirstChild(AimState.LockPart)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not part then return nil end

    if AimState.UsePrediction and root then
        return part.Position + (root.AssemblyLinearVelocity * AimState.PredictionFactor)
    end
    return part.Position
end

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    if not AimState.Enabled or AIM_IS_MOBILE or not Camera then
        if FOVring then FOVring.Visible = false end
        AimState.CurrentTarget = nil
        return
    end

    if FOVring then
        FOVring.Visible = true
        FOVring.Position = Camera.ViewportSize / 2
        FOVring.Radius = AimState.FOV
    end

    local holding =
        (AimState.HoldMode == "MouseButton2" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
        or (AimState.HoldMode == "Q" and UserInputService:IsKeyDown(Enum.KeyCode.Q))

    if not holding then
        if FOVring then FOVring.Color = AimState.IdleColor end
        AimState.CurrentTarget = nil
        return
    end

    if not AimState.CurrentTarget or not isValidAimTarget(AimState.CurrentTarget) then
        AimState.CurrentTarget = getClosestAimTarget()
    end

    if AimState.CurrentTarget then
        local predictedPosition = getPredictedAimPosition(AimState.CurrentTarget)
        if predictedPosition then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, predictedPosition),
                AimState.Smoothing
            )
            if FOVring then FOVring.Color = AimState.LockColor end
        end
    elseif FOVring then
        FOVring.Color = AimState.IdleColor
    end
end)

local function refreshAimIgnoreList()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then table.insert(names, player.Name) end
    end
    table.sort(names)
    refreshAimDropdown(aimIgnoreDropdown, names)
end

--// ESP runtime
local ESP = {}
local ESP_ENABLED = false
local ESP_SETTINGS = {
    Distance = 900,
    ShowName = false,
    ShowHealth = false,
    ShowTool = false,
    NameColor = Color3.new(1, 1, 1),
    ToolColor = Color3.new(1, 1, 1),
    HealthFull = Color3.fromRGB(0, 255, 0),
    HealthMid = Color3.fromRGB(255, 255, 0),
    HealthLow = Color3.fromRGB(255, 0, 0),
    BoxEnabled = false,
    LineEnabled = false,
    HealthBarEnabled = false,
    SkeletonEnabled = false,
    BoxColor = Color3.new(1, 1, 1),
    LineColor = Color3.new(1, 1, 1),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonThickness = 1,
}

local R15_JOINTS = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local function isR15(character)
    return character
        and character:FindFirstChild("UpperTorso") ~= nil
        and character:FindFirstChild("LowerTorso") ~= nil
end

local function removeSkeletonLines(esp)
    if not esp or not esp.SkeletonLines then return end
    for _, line in ipairs(esp.SkeletonLines) do
        pcall(function() line:Remove() end)
    end
    table.clear(esp.SkeletonLines)
end

local function drawSkeleton(player, esp, camera)
    local character = player.Character
    if not character or not isR15(character) then
        removeSkeletonLines(esp)
        return
    end

    -- Reuse the same Drawing lines each frame instead of allocating new ones every Heartbeat.
    if #esp.SkeletonLines ~= #R15_JOINTS then
        removeSkeletonLines(esp)
        for _ = 1, #R15_JOINTS do
            local ok, line = pcall(function() return Drawing.new("Line") end)
            if ok and line then
                line.Visible = false
                line.Transparency = 1
                table.insert(esp.SkeletonLines, line)
            end
        end
    end

    for index, joint in ipairs(R15_JOINTS) do
        local line = esp.SkeletonLines[index]
        local part1 = character:FindFirstChild(joint[1])
        local part2 = character:FindFirstChild(joint[2])
        if line and part1 and part2 then
            local pos1, onScreen1 = camera:WorldToViewportPoint(part1.Position)
            local pos2, onScreen2 = camera:WorldToViewportPoint(part2.Position)
            if onScreen1 and onScreen2 then
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Color = ESP_SETTINGS.SkeletonColor
                line.Thickness = ESP_SETTINGS.SkeletonThickness
                line.Transparency = 1
                line.Visible = true
            else
                line.Visible = false
            end
        elseif line then
            line.Visible = false
        end
    end
end

local function createESP(player)
    if player == LocalPlayer or ESP[player] then return end

    local function newText(size)
        local object = Drawing.new("Text")
        object.Center = true
        object.Outline = true
        object.OutlineColor = Color3.new(0, 0, 0)
        object.Visible = false
        object.Size = size
        object.Color = Color3.new(1, 1, 1)
        return object
    end

    local ok, objects = pcall(function()
        local box = Drawing.new("Square")
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        box.Visible = false
        box.Color = Color3.new(1, 1, 1)

        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Transparency = 1
        line.Visible = false
        line.Color = Color3.new(1, 1, 1)

        local healthBar = Drawing.new("Square")
        healthBar.Thickness = 1
        healthBar.Filled = true
        healthBar.Transparency = 1
        healthBar.Visible = false
        healthBar.Color = Color3.fromHSV(0.3, 1, 1)

        return {
            Name = newText(16),
            HP = newText(14),
            Tool = newText(14),
            Box = box,
            Line = line,
            HealthBar = healthBar,
            SkeletonLines = {},
        }
    end)

    if ok and objects then
        ESP[player] = objects
    end
end

local function hideESP(esp)
    if not esp then return end
    for key, object in pairs(esp) do
        if key ~= "SkeletonLines" and object then
            pcall(function() object.Visible = false end)
        end
    end
    removeSkeletonLines(esp)
end

local function removeESP(player)
    local esp = ESP[player]
    if not esp then return end
    hideESP(esp)
    for key, object in pairs(esp) do
        if key ~= "SkeletonLines" and object then
            pcall(function() object:Remove() end)
        end
    end
    ESP[player] = nil
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(function(player)
    createESP(player)
    refreshAimIgnoreList()
end)
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    AimState.IgnoredPlayers[player.Name] = nil
    refreshAimIgnoreList()
    if AimState.CurrentTarget == player then AimState.CurrentTarget = nil end
end)

local playerCache = {}
local lastCacheUpdate = 0
local function updatePlayerCache()
    local now = tick()
    if now - lastCacheUpdate < 0.4 then return end
    lastCacheUpdate = now

    local refreshedCache = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if character and root and humanoid then
                refreshedCache[player] = {
                    character = character,
                    root = root,
                    humanoid = humanoid,
                }
            end
        end
    end
    playerCache = refreshedCache
end

RunService.Heartbeat:Connect(function()
    Camera = workspace.CurrentCamera
    if not ESP_ENABLED or not Camera then
        for _, esp in pairs(ESP) do hideESP(esp) end
        return
    end

    updatePlayerCache()
    local cameraPosition = Camera.CFrame.Position

    for player, data in pairs(playerCache) do
        local esp = ESP[player]
        if not esp then continue end

        local root, humanoid = data.root, data.humanoid
        if not root or not humanoid or humanoid.Health <= 0 then
            hideESP(esp)
            continue
        end

        local position, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen or (cameraPosition - root.Position).Magnitude > ESP_SETTINGS.Distance then
            hideESP(esp)
            continue
        end

        local baseX, baseY = position.X, position.Y
        local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.6, 0))
        local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        local boxHeight = math.abs(top.Y - bottom.Y)
        local boxSize = Vector2.new(boxHeight / 1.5, boxHeight)
        local boxPosition = Vector2.new(position.X - boxSize.X / 2, position.Y - boxSize.Y / 2)

        if ESP_SETTINGS.ShowName then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(baseX, baseY - 25)
            esp.Name.Color = ESP_SETTINGS.NameColor
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end

        if ESP_SETTINGS.ShowHealth then
            local health = humanoid.Health
            local percent = humanoid.MaxHealth > 0 and health / humanoid.MaxHealth or 0
            esp.HP.Position = Vector2.new(baseX, baseY - 5)
            esp.HP.Text = tostring(math.floor(health))
            if health <= 0 then
                esp.HP.Color = Color3.fromRGB(0, 0, 0)
            elseif percent <= 0.30 then
                esp.HP.Color = ESP_SETTINGS.HealthLow
            elseif percent < 0.70 then
                esp.HP.Color = ESP_SETTINGS.HealthMid
            else
                esp.HP.Color = ESP_SETTINGS.HealthFull
            end
            esp.HP.Visible = true
        else
            esp.HP.Visible = false
        end

        if ESP_SETTINGS.ShowTool then
            local tool = data.character:FindFirstChildOfClass("Tool")
            if tool then
                esp.Tool.Text = "[" .. tool.Name .. "]"
                esp.Tool.Position = Vector2.new(baseX, baseY + 15)
                esp.Tool.Color = ESP_SETTINGS.ToolColor
                esp.Tool.Visible = true
            else
                esp.Tool.Visible = false
            end
        else
            esp.Tool.Visible = false
        end

        if ESP_SETTINGS.BoxEnabled and boxHeight >= 2 then
            esp.Box.Visible = true
            esp.Box.Size = boxSize
            esp.Box.Position = boxPosition
            esp.Box.Color = ESP_SETTINGS.BoxColor
        else
            esp.Box.Visible = false
        end

        if ESP_SETTINGS.LineEnabled and data.character:FindFirstChild("Head") then
            local headPosition = Camera:WorldToViewportPoint(data.character.Head.Position)
            esp.Line.Visible = true
            esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
            esp.Line.To = Vector2.new(headPosition.X, headPosition.Y)
            esp.Line.Color = ESP_SETTINGS.LineColor
        else
            esp.Line.Visible = false
        end

        if ESP_SETTINGS.HealthBarEnabled and boxHeight >= 2 then
            local percent = humanoid.MaxHealth > 0 and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 0
            local barHeight = percent * boxSize.Y
            esp.HealthBar.Visible = true
            esp.HealthBar.Size = Vector2.new(2, barHeight)
            esp.HealthBar.Position = Vector2.new(boxPosition.X - 5, boxPosition.Y + (boxSize.Y - barHeight))
            esp.HealthBar.Color = Color3.fromHSV(percent * 0.3, 1, 1)
        else
            esp.HealthBar.Visible = false
        end

        if ESP_SETTINGS.SkeletonEnabled and isR15(data.character) then
            drawSkeleton(player, esp, Camera)
        else
            removeSkeletonLines(esp)
        end
    end
end)

refreshAimIgnoreList()
--// ==================== FIN AIM + ESP RUNTIME ====================



local function BuildUI(version)

local oldActive = getgenv().uiLE.ActiveUI



if oldActive then

local w = oldActive.Window

local v = oldActive.version



if v == 1 then

            getgenv().uiLE.uilibray:Destroy()

elseif v == 2 then

            w:Unload()

end



        getgenv().uiLE.ActiveUI = nil

end



    getgenv().uiLE.uiVersion = version

    getgenv().RAYFIELD_SECURE = true

    getgenv().RAYFIELD_ASSET_ID = 84895246331982



local libURL = version == 1 and "https://sirius.menu/rayfield" or "https://sirius.menu/gen2"



    getgenv().uiLE.uilibray = safeLoadString({libURL})



if not getgenv().uiLE.uilibray then

        getgenv().uiLE.loading = false

return

end



local Rayfield = getgenv().uiLE.uilibray



local LOADING_SUBTITLES = {

        "FREE",

    }



local Window



if version == 1 then

        Window = Rayfield:CreateWindow({

            Name = "V A N TA",

            ScriptID = "sid_k2rgzy25rkgy",

            LoadingTitle = "V A N TA",

            LoadingSubtitle = LOADING_SUBTITLES[math.random(#LOADING_SUBTITLES)],

            Theme = "Amethyst",

            DisableRayfieldPrompts = true,

            ConfigurationSaving = {

                Enabled = true,

                FolderName = "LimbExtenderConfigs",

                FileName = "Configuration",

            },

        })

else

        Window = Rayfield:CreateWindow({

            name = "V A N TA",

            subtitle = LOADING_SUBTITLES[math.random(#LOADING_SUBTITLES)],

            theme = "Amethyst",

            configuration = {

                autoSave = true,

                autoLoad = true,

                fileName = "Configuration",

                customFolder = "LimbExtenderConfigs",

            },

        })



        getgenv().uiLE.uilibray.Window = Window

end



    getgenv().uiLE.ActiveUI = {Window = Window, version = version}



local function createSection(tab, title)

if version == 1 then

            tab:CreateSection(title)

else

            tab:CreateSection({ name = title })

end

end



local function createToggle(tab, name, flag, default, customCallback, skipController)

        default = default or false

        local saved = skipController and nil or ctrl:Get(flag)

        local value = saved ~= nil and saved or default

        local callbackFn = customCallback or function(v) ctrl:Set(flag, v) end

        if version == 1 then

            return tab:CreateToggle({

                Name = name, Flag = flag, CurrentValue = value,

                Callback = function(v)

                    callbackFn(v)

                    if not skipController and customCallback then ctrl:Set(flag, v) end

                end,

            })

        else

            return tab:CreateToggle({

                name = name, flag = flag, value = value,

                callback = function(v)

                    callbackFn(v)

                    if not skipController and customCallback then ctrl:Set(flag, v) end

                end,

            })

        end

    end

    local function createSlider(tab, name, flag, range, increment, suffix, default, customCallback, skipController)

        default = default or range[1]

        local saved = skipController and nil or ctrl:Get(flag)

        local value = saved ~= nil and saved or default

        local function onChanged(v)
            if not skipController then ctrl:Set(flag, v) end
            if customCallback then customCallback(v) end
        end

        if version == 1 then

            return tab:CreateSlider({

                Name = name, Flag = flag, CurrentValue = value,

                Range = range, Increment = increment, Suffix = suffix or "",

                Callback = onChanged,

            })

        else

            return tab:CreateSlider({

                name = name, flag = flag, value = value,

                range = range, increment = increment, suffix = suffix or "",

                callback = onChanged,

            })

        end

    end

    local function createColorPicker(tab, name, flag, customCallback, defaultColor, skipController)

        local saved = skipController and nil or ctrl:Get(flag)

        local color = saved or defaultColor or Color3.new(1, 1, 1)

        local function onChanged(v)
            if not skipController then ctrl:Set(flag, v) end
            if customCallback then customCallback(v) end
        end

        if version == 1 then

            return tab:CreateColorPicker({

                Name = name, Flag = flag, Color = color,

                Callback = onChanged,

            })

        else

            return tab:CreateColorPicker({

                name = name, flag = flag, value = color,

                callback = onChanged,

            })

        end

    end

    local function createKeybind(tab, name, flag, defaultKey, callback)

if version == 1 then

return tab:CreateKeybind({

                Name = name,

                Flag = flag,

                CurrentKeybind = defaultKey,

                HoldToInteract = false,

                Callback = callback,

            })

else

return tab:CreateKeybind({

                name = name,

                flag = flag,

                value = Enum.KeyCode[defaultKey] or Enum.KeyCode.L,

                holdToInteract = false,

                callback = callback,

                onChanged = function(newKey)

                    ctrl:Set(flag, newKey)

end,

            })

end

end



local function createDropdown(tab, name, flag, options, defaultOption, multi, callback)

if version == 1 then

local currentOption = defaultOption and (multi and defaultOption or {defaultOption}) or {}



return tab:CreateDropdown({

                Name = name,

                Flag = flag,

                Options = options,

                CurrentOption = currentOption,

                MultipleOptions = multi or false,

                Callback = function(opts)

if multi then

                        callback(opts)

else

                        callback(opts[1])

end

end,

            })

else

return tab:CreateDropdown({

                name = name,

                flag = flag,

                options = options,

                value = defaultOption,

                multiSelect = multi or false,

                callback = function(selection)

                    callback(selection)

end,

            })

end

end



local function createButton(tab, name, callback)

if version == 1 then

return tab:CreateButton({Name = name, Callback = callback})

else

return tab:CreateButton({name = name, callback = callback})

end

end



local function createParagraph(tab, title, content)

if version == 1 then

            tab:CreateParagraph({Title = title, Content = content})

end

end



local Tabs = {

        General = version == 1 and Window:CreateTab("General") or Window:CreateTab({name = "General"}),

        Targeting = version == 1 and Window:CreateTab("Targeting") or Window:CreateTab({name = "Targeting"}),

        Appearance = version == 1 and Window:CreateTab("Appearance") or Window:CreateTab({name = "Appearance"}),

        Aim = version == 1 and Window:CreateTab("Aim") or Window:CreateTab({name = "Aim"}),

        ESP = version == 1 and Window:CreateTab("ESP") or Window:CreateTab({name = "ESP"}),

    }



    --// AIM TAB (controles originales de SCRIPT V2 adaptados a Rayfield)
    createSection(Tabs.Aim, "Aimbot PC")

    createToggle(Tabs.Aim, "Aimbot", "V2_AIM_ENABLED", AimState.Enabled, function(value)
        if value and IS_MOBILE then
            AimState.Enabled = false
            if FOVring then FOVring.Visible = false end
            pcall(function()
                if getgenv().uiLE.uilibray and getgenv().uiLE.uilibray.Notify then
                    getgenv().uiLE.uilibray:Notify({Title = "VANTA", Content = "Aimbot no disponible en mobile", Duration = 3})
                end
            end)
            return
        end
        AimState.Enabled = value
        if FOVring then FOVring.Visible = value end
    end, true)

    createSlider(Tabs.Aim, "FOV", "V2_AIM_FOV", {10, 670}, 1, "", AimState.FOV, function(v)
        AimState.FOV = v
        if FOVring then FOVring.Radius = v end
    end, true)
    createSlider(Tabs.Aim, "FOV Transparency", "V2_AIM_FOV_TRANSPARENCY", {0, 1}, 0.01, "", 1, function(v)
        if FOVring then FOVring.Transparency = v end
    end, true)
    createSlider(Tabs.Aim, "Max Distance", "V2_AIM_MAX_DISTANCE", {100, 3000}, 1, "", AimState.MaxDistance, function(v)
        AimState.MaxDistance = v
    end, true)
    createSlider(Tabs.Aim, "Smoothing", "V2_AIM_SMOOTHING", {0.1, 1}, 0.01, "", AimState.Smoothing, function(v)
        AimState.Smoothing = v
    end, true)
    createSlider(Tabs.Aim, "Prediction", "V2_AIM_PREDICTION_FACTOR", {0, 0.2}, 0.001, "", AimState.PredictionFactor, function(v)
        AimState.PredictionFactor = v
    end, true)

    -- Connect slider values to runtime state (callbacks are assigned by the helper).
    -- The controls are recreated safely whenever the UI version is switched.
    createToggle(Tabs.Aim, "Use Prediction", "V2_AIM_USE_PREDICTION", AimState.UsePrediction, function(value)
        AimState.UsePrediction = value
    end, true)
    createToggle(Tabs.Aim, "Team Check", "V2_AIM_TEAM_CHECK", AimState.TeamCheck, function(value)
        AimState.TeamCheck = value
    end, true)

    createSection(Tabs.Aim, "Target Selection")
    aimLimbDropdown = createDropdown(
        Tabs.Aim, "Target Part", "V2_AIM_TARGET_PART",
        aimLimbList, AimState.LockPart, false,
        function(selected)
            if type(selected) == "table" then selected = selected[1] end
            if type(selected) == "string" and selected ~= "" then
                AimState.LockPart = selected
            end
        end
    )

    local ignoreNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then table.insert(ignoreNames, player.Name) end
    end
    table.sort(ignoreNames)
    local ignoredDefaults = {}
    for name, isIgnored in pairs(AimState.IgnoredPlayers) do
        if isIgnored and table.find(ignoreNames, name) then
            table.insert(ignoredDefaults, name)
        end
    end

    aimIgnoreDropdown = createDropdown(
        Tabs.Aim, "Ignore Players", "V2_AIM_IGNORE_PLAYERS",
        ignoreNames, ignoredDefaults, true,
        function(selection)
            local normalized = {}
            if type(selection) == "table" then
                for key, value in pairs(selection) do
                    if type(key) == "number" and type(value) == "string" then
                        normalized[value] = true
                    elseif type(key) == "string" and value then
                        normalized[key] = true
                    end
                end
            end
            AimState.IgnoredPlayers = normalized
        end
    )

    createDropdown(
        Tabs.Aim, "Hold Key", "V2_AIM_HOLD_MODE",
        {"MouseButton2", "Q"}, AimState.HoldMode, false,
        function(selected)
            if type(selected) == "table" then selected = selected[1] end
            if selected == "MouseButton2" or selected == "Q" then
                AimState.HoldMode = selected
            end
        end
    )

    createColorPicker(Tabs.Aim, "FOV Idle Color", "V2_AIM_IDLE_COLOR", function(c) AimState.IdleColor = c; if FOVring then FOVring.Color = c end end, AimState.IdleColor, true)
    createColorPicker(Tabs.Aim, "FOV Lock Color", "V2_AIM_LOCK_COLOR", function(c) AimState.LockColor = c end, AimState.LockColor, true)

    createSection(Tabs.ESP, "ESP")
    createToggle(Tabs.ESP, "Enable ESP", "V2_ESP_ENABLED", ESP_ENABLED, function(value)
        ESP_ENABLED = value
    end, true)
    createSlider(Tabs.ESP, "Distance", "V2_ESP_DISTANCE", {200, 5000}, 1, "", ESP_SETTINGS.Distance, function(v)
        ESP_SETTINGS.Distance = v
    end, true)
    createToggle(Tabs.ESP, "Names", "V2_ESP_NAMES", ESP_SETTINGS.ShowName, function(value)
        ESP_SETTINGS.ShowName = value
    end, true)
    createToggle(Tabs.ESP, "Health", "V2_ESP_HEALTH", ESP_SETTINGS.ShowHealth, function(value)
        ESP_SETTINGS.ShowHealth = value
    end, true)
    createToggle(Tabs.ESP, "Tools", "V2_ESP_TOOLS", ESP_SETTINGS.ShowTool, function(value)
        ESP_SETTINGS.ShowTool = value
    end, true)
    createToggle(Tabs.ESP, "Box", "V2_ESP_BOX", ESP_SETTINGS.BoxEnabled, function(value)
        if value and IS_MOBILE then
            ESP_SETTINGS.BoxEnabled = false
            return
        end
        ESP_SETTINGS.BoxEnabled = value
    end, true)
    createToggle(Tabs.ESP, "Line", "V2_ESP_LINE", ESP_SETTINGS.LineEnabled, function(value)
        ESP_SETTINGS.LineEnabled = value
    end, true)
    createToggle(Tabs.ESP, "Health Bar V2", "V2_ESP_HEALTH_BAR", ESP_SETTINGS.HealthBarEnabled, function(value)
        ESP_SETTINGS.HealthBarEnabled = value
    end, true)
    createToggle(Tabs.ESP, "Skeleton (R15)", "V2_ESP_SKELETON", ESP_SETTINGS.SkeletonEnabled, function(value)
        ESP_SETTINGS.SkeletonEnabled = value
    end, true)

    createSection(Tabs.ESP, "ESP Colors")
    createColorPicker(Tabs.ESP, "Name Color", "V2_ESP_NAME_COLOR", function(c) ESP_SETTINGS.NameColor = c end, ESP_SETTINGS.NameColor, true)
    createColorPicker(Tabs.ESP, "Tool Color", "V2_ESP_TOOL_COLOR", function(c) ESP_SETTINGS.ToolColor = c end, ESP_SETTINGS.ToolColor, true)
    createColorPicker(Tabs.ESP, "Health Full", "V2_ESP_HEALTH_FULL", function(c) ESP_SETTINGS.HealthFull = c end, ESP_SETTINGS.HealthFull, true)
    createColorPicker(Tabs.ESP, "Health Mid", "V2_ESP_HEALTH_MID", function(c) ESP_SETTINGS.HealthMid = c end, ESP_SETTINGS.HealthMid, true)
    createColorPicker(Tabs.ESP, "Health Low", "V2_ESP_HEALTH_LOW", function(c) ESP_SETTINGS.HealthLow = c end, ESP_SETTINGS.HealthLow, true)
    createColorPicker(Tabs.ESP, "Box Color", "V2_ESP_BOX_COLOR", function(c) ESP_SETTINGS.BoxColor = c end, ESP_SETTINGS.BoxColor, true)
    createColorPicker(Tabs.ESP, "Line Color", "V2_ESP_LINE_COLOR", function(c) ESP_SETTINGS.LineColor = c end, ESP_SETTINGS.LineColor, true)
    createColorPicker(Tabs.ESP, "Skeleton Color", "V2_ESP_SKELETON_COLOR", function(c) ESP_SETTINGS.SkeletonColor = c end, ESP_SETTINGS.SkeletonColor, true)
    createSlider(Tabs.ESP, "Skeleton Thickness", "V2_ESP_SKELETON_THICKNESS", {1, 3}, 1, "", ESP_SETTINGS.SkeletonThickness, function(v)
        ESP_SETTINGS.SkeletonThickness = v
    end, true)

    createSection(Tabs.General, "Master Control")



local flagModify = "ModifyLimbs"

local modifySaved = ctrl:Get(flagModify)

local modifyVal = modifySaved ~= nil and modifySaved or false



local modifyLimbsToggle



if version == 1 then

        modifyLimbsToggle = Tabs.General:CreateToggle({

            Name = "Modify Limbs",

            Flag = flagModify,

            CurrentValue = modifyVal,

            Callback = function(v)

                ctrl:Set(flagModify, v)

                ctrl:Toggle(v)

end,

        })

else

        modifyLimbsToggle = Tabs.General:CreateToggle({

            name = "Modify Limbs",

            flag = flagModify,

            value = modifyVal,

            callback = function(v)

                ctrl:Set(flagModify, v)

                ctrl:Toggle(v)

end,

        })

end



local function toggleLimbs()

        modifyLimbsToggle:Set(not ctrl._running)

end



    createKeybind(Tabs.General, "Toggle Keybind", "ToggleKeybind", "L", toggleLimbs)



    createSection(Tabs.General, "Target Selection")



local existingLimbs = #scannedLimbs > 0 and table.clone(scannedLimbs) or {"Head"}



local targetLimbDropdown = createDropdown(

        Tabs.General,

        "Target Limb",

        "TARGET_LIMB",

        existingLimbs,

        ctrl:Get("TARGET_LIMB") or "Head",

false,

function(selected)

if type(selected) == "table" then

                selected = selected[1]

end

            ctrl:Set("TARGET_LIMB", selected)

end

    )



    getgenv().uiLE.targetLimbDropdown = targetLimbDropdown



    createSection(Tabs.General, "Proximity Shrink")



    createToggle(Tabs.General, "Shrink Enabled", "DYNAMIC_SCALE_ENABLED", false)



    createSlider(Tabs.General, "Shrink Range", "DYNAMIC_SCALE_RANGE_MULT", {0.2, 5}, 0.1, "x", 1)



    createSlider(Tabs.General, "Update Rate", "DYNAMIC_SCALE_UPDATE_RATE", {5, 60}, 1, "Hz", 30)



    createSection(Tabs.Targeting, "Target Selection")



    createToggle(Tabs.Targeting, "Players", "PLAYER_ENABLED", true)

    createToggle(Tabs.Targeting, "NPCs", "NPC_ENABLED", false)

    createToggle(Tabs.Targeting, "ForceField Check", "FORCEFIELD_CHECK", false)



local teamModeOptions = {"None", "Different Team", "Whitelist", "Blacklist"}

local teamModeValues = {"none", "different", "whitelist", "blacklist"}



local savedTeamMode = ctrl:Get("TEAM_MODE") or "none"

local defaultTeamOption = "None"



for i, v in ipairs(teamModeValues) do

if v == savedTeamMode then

            defaultTeamOption = teamModeOptions[i]

break

end

end



    createDropdown(Tabs.Targeting, "Team Filter", "TEAM_MODE", teamModeOptions, defaultTeamOption, false, function(selected)

local mode = "none"



for i, opt in ipairs(teamModeOptions) do

if opt == selected then

                mode = teamModeValues[i]

break

end

end



        ctrl:Set("TEAM_MODE", mode)

end)



    createSection(Tabs.Targeting, "Team Lists")



local savedTeamWhitelist = ctrl:Get("TEAM_WHITELIST") or {}

local savedTeamBlacklist = ctrl:Get("TEAM_BLACKLIST") or {}



local teamOptions = #scannedTeams > 0 and table.clone(scannedTeams) or {"(no teams found)"}



local whitelistTeamsCallback = function(selected)

        ctrl:Set("TEAM_WHITELIST", type(selected) == "table" and selected or {selected})

end



local whitelistTeamsDropdown = createDropdown(

        Tabs.Targeting,

        "Whitelist Teams",

        "TEAM_WHITELIST_DROPDOWN",

        teamOptions,

        savedTeamWhitelist,

true,

        whitelistTeamsCallback

    )



    getgenv().uiLE.whitelistTeamsDropdown = whitelistTeamsDropdown

    whitelistTeamsCallback(savedTeamWhitelist)



local blacklistTeamsCallback = function(selected)

        ctrl:Set("TEAM_BLACKLIST", type(selected) == "table" and selected or {selected})

end



local blacklistTeamsDropdown = createDropdown(

        Tabs.Targeting,

        "Blacklist Teams",

        "TEAM_BLACKLIST_DROPDOWN",

        teamOptions,

        savedTeamBlacklist,

true,

        blacklistTeamsCallback

    )



    getgenv().uiLE.blacklistTeamsDropdown = blacklistTeamsDropdown

    blacklistTeamsCallback(savedTeamBlacklist)



    createSection(Tabs.Targeting, "Player Lists")



local savedPlayerWhitelistUserIds = ctrl:Get("PLAYER_WHITELIST") or {}

local savedPlayerBlacklistUserIds = ctrl:Get("PLAYER_BLACKLIST") or {}



local savedPlayerWhitelistNames = userIdArrayToNames(savedPlayerWhitelistUserIds)

local savedPlayerBlacklistNames = userIdArrayToNames(savedPlayerBlacklistUserIds)



local playerOptions = #scannedPlayers > 0 and table.clone(scannedPlayers) or {"(no players online)"}



local whitelistPlayersCallback = function(selectedNames)

local userIds = {}



if type(selectedNames) == "table" then

for _, name in ipairs(selectedNames) do

local uid = nameToUserId[name]

if uid then

                    table.insert(userIds, uid)

end

end

end



        ctrl:Set("PLAYER_WHITELIST", userIds)

end



local whitelistPlayersDropdown = createDropdown(

        Tabs.Targeting,

        "Blacklist Player",

        "PLAYER_WHITELIST_DROPDOWN",

        playerOptions,

        savedPlayerWhitelistNames,

true,

        whitelistPlayersCallback

    )



    getgenv().uiLE.whitelistPlayersDropdown = whitelistPlayersDropdown

    whitelistPlayersCallback(savedPlayerWhitelistNames)



local blacklistPlayersCallback = function(selectedNames)

local userIds = {}



if type(selectedNames) == "table" then

for _, name in ipairs(selectedNames) do

local uid = nameToUserId[name]

if uid then

                    table.insert(userIds, uid)

end

end

end



        ctrl:Set("PLAYER_BLACKLIST", userIds)

end



local blacklistPlayersDropdown = createDropdown(

        Tabs.Targeting,

        "Whitelist Players",

        "PLAYER_BLACKLIST_DROPDOWN",

        playerOptions,

        savedPlayerBlacklistNames,

true,

        blacklistPlayersCallback

    )



    getgenv().uiLE.blacklistPlayersDropdown = blacklistPlayersDropdown

    blacklistPlayersCallback(savedPlayerBlacklistNames)



    createSection(Tabs.Appearance, "Limb Properties")



    createToggle(Tabs.Appearance, "Limb Collisions", "LIMB_CAN_COLLIDE", false)



    createSlider(Tabs.Appearance, "Limb Transparency", "LIMB_TRANSPARENCY", {0, 1}, 0.1, "", 0)



    createSlider(Tabs.Appearance, "Limb Size", "LIMB_SIZE", {1, 30}, 0.5, "", 1)



    createSection(Tabs.Appearance, "Chams")



    createToggle(Tabs.Appearance, "Chams Enabled", "CHAMS", false)

    createToggle(Tabs.Appearance, "Always On Top", "CHAMS_OCCLUSION", false)



if version == 1 then

        createColorPicker(Tabs.Appearance, "Fill Color", "CHAMS_FILL_COLOR")

        createColorPicker(Tabs.Appearance, "Outline Color", "CHAMS_OUTLINE_COLOR")



        createSlider(Tabs.Appearance, "Fill Transparency", "CHAMS_FILL_TRANSPARENCY", {0, 1}, 0.05, "", 0.5)

        createSlider(Tabs.Appearance, "Outline Transparency", "CHAMS_OUTLINE_TRANSPARENCY", {0, 1}, 0.05, "", 0.5)

else

local savedFillTrans = ctrl:Get("CHAMS_FILL_TRANSPARENCY")

local savedOutlineTrans = ctrl:Get("CHAMS_OUTLINE_TRANSPARENCY")



local defaultFillAlpha = 1 - (savedFillTrans ~= nil and savedFillTrans or 0.5)

local defaultOutlineAlpha = 1 - (savedOutlineTrans ~= nil and savedOutlineTrans or 0.5)



        Tabs.Appearance:CreateColorPicker({

            name = "Fill Color",

            flag = "CHAMS_FILL_COLOR",

            alpha = defaultFillAlpha,

            callback = function(color, alpha)

                ctrl:Set("CHAMS_FILL_COLOR", color)

                ctrl:Set("CHAMS_FILL_TRANSPARENCY", 1 - alpha)

end,

        })



        Tabs.Appearance:CreateColorPicker({

            name = "Outline Color",

            flag = "CHAMS_OUTLINE_COLOR",

            alpha = defaultOutlineAlpha,

            callback = function(color, alpha)

                ctrl:Set("CHAMS_OUTLINE_COLOR", color)

                ctrl:Set("CHAMS_OUTLINE_TRANSPARENCY", 1 - alpha)

end,

        })

end



if version == 1 then

        Rayfield:LoadConfiguration()

else

        Window:Load()

end

end



InitializeLimbScanning()

InitializeTeamScanning()

InitializePlayerScanning()



local initialVersion = 2



BuildUI(initialVersion)



getgenv().uiLE.loading = false
