local coreGui = game:GetService("CoreGui")
if coreGui:FindFirstChild("ScreenGui") then
    coreGui:FindFirstChild("ScreenGui"):Destroy()
end

loadstring(game:HttpGet('https://raw.githubusercontent.com/drillygzzly/Roblox-UI-Libs/main/Yun%20V2%20Lib/Yun%20V2%20Lib%20Source.lua'))()

local Library = initLibrary()
local Window = Library:Load({name = "Signal", sizeX = 425, sizeY = 512, color = Color3.fromRGB(255, 255, 255)})

local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local aimTab = Window:Tab("Aiming")
local visualTab = Window:Tab("Visuals")
local miscTab = Window:Tab("Miscellaneous")

local Aimingsec1 = aimTab:Section{name = "Aimbot", column = 1}
local Visualssec1 = visualTab:Section{name = "ESP", column = 1}
local MiscSec = miscTab:Section{name = "UI Controls", column = 1}

local holdingRMB = false
local aimingEnabled = false
local teamCheckEnabled = false
local targetPart = "Head"
local smoothing = 0
local lockedTarget = nil

local lineESPEnabled = false
local lineESP = {}
local headESPEnabled = false
local headESP = {}
local boxESPEnabled = false
local boxESP = {}
local soundESPEnabled = false
local soundESP = {}
local playerSpeeds = {}

Aimingsec1:Toggle {
    Name = "Enabled",
    flag = "aimEnabled",
    callback = function(bool)
        aimingEnabled = bool
    end
}

Aimingsec1:Toggle {
    Name = "Team Check",
    flag = "teamCheck",
    callback = function(bool)
        teamCheckEnabled = bool
    end
}

Aimingsec1:Slider {
    Name = "Smoothing",
    Default = 0,
    Min = 0,
    Max = 30,
    Decimals = 1,
    Flag = "smoothValue",
    callback = function(value)
        smoothing = value
    end
}

Aimingsec1:Dropdown {
    Name = "Target Part",
    content = {"Head", "Torso", "HumanoidRootPart"},
    multichoice = false,
    callback = function(selected)
        targetPart = selected
    end
}

Visualssec1:Toggle {
    Name = "Line ESP",
    flag = "lineESP",
    callback = function(bool)
        lineESPEnabled = bool
        if not lineESPEnabled then
            for _, esp in pairs(lineESP) do
                if esp then
                    esp:Remove()
                end
            end
            lineESP = {}
        end
    end
}

Visualssec1:Toggle {
    Name = "Head ESP",
    flag = "headESP",
    callback = function(bool)
        headESPEnabled = bool
        if not headESPEnabled then
            for _, esp in pairs(headESP) do
                if esp then
                    esp:Remove()
                end
            end
            headESP = {}
        end
    end
}

Visualssec1:Toggle {
    Name = "Box ESP",
    flag = "boxESP",
    callback = function(bool)
        boxESPEnabled = bool
        if not boxESPEnabled then
            for _, esp in pairs(boxESP) do
                if esp then
                    esp:Remove()
                end
            end
            boxESP = {}
        end
    end
}

Visualssec1:Toggle {
    Name = "Sound ESP",
    flag = "soundESP",
    callback = function(bool)
        soundESPEnabled = bool
        if not soundESPEnabled then
            for _, esp in pairs(soundESP) do
                if esp then
                    esp:Remove()
                end
            end
            soundESP = {}
        end
    end
}

MiscSec:Button {
    Name = "Unload UI",
    callback = function()
        if coreGui:FindFirstChild("ScreenGui") then
            coreGui:FindFirstChild("ScreenGui"):Destroy()
        end
    end
}

players.PlayerRemoving:Connect(function(player)
    if lineESP[player] then
        lineESP[player]:Remove()
        lineESP[player] = nil
    end
    if headESP[player] then
        headESP[player]:Remove()
        headESP[player] = nil
    end
    if boxESP[player] then
        boxESP[player]:Remove()
        boxESP[player] = nil
    end
    if soundESP[player] then
        soundESP[player]:Remove()
        soundESP[player] = nil
    end
    playerSpeeds[player] = nil
end)

runService.Heartbeat:Connect(function()
    -- Line ESP
    if lineESPEnabled then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if teamCheckEnabled and player.Team == localPlayer.Team then
                    if lineESP[player] then
                        lineESP[player].Visible = false
                    end
                    continue
                end

                if not lineESP[player] then
                    local line = Drawing.new("Line")
                    line.Thickness = 1
                    line.Transparency = 1
                    line.Color = Color3.fromRGB(255, 255, 255)
                    lineESP[player] = line
                end

                local headPos = player.Character.Head.Position
                local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                local line = lineESP[player]

                if onScreen then
                    line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    line.To = Vector2.new(screenPos.X, screenPos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            elseif lineESP[player] then
                lineESP[player]:Remove()
                lineESP[player] = nil
            end
        end
    end

    -- Head ESP
    if headESPEnabled then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if teamCheckEnabled and player.Team == localPlayer.Team then
                    if headESP[player] then
                        headESP[player].Visible = false
                    end
                    continue
                end

                if not headESP[player] then
                    local circle = Drawing.new("Circle")
                    circle.Thickness = 1
                    circle.Transparency = 1
                    circle.Color = Color3.fromRGB(255, 255, 255)
                    circle.FillTransparency = 0.6
                    headESP[player] = circle
                end

                local headPos = player.Character.Head.Position
                local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                local circle = headESP[player]

                if onScreen then
                    local size = 50 / (screenPos.Z / 10)
                    circle.Position = Vector2.new(screenPos.X, screenPos.Y)
                    circle.Radius = size
                    circle.Visible = true
                else
                    circle.Visible = false
                end
            elseif headESP[player] then
                headESP[player]:Remove()
                headESP[player] = nil
            end
        end
    end

    -- Box ESP
    if boxESPEnabled then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if teamCheckEnabled and player.Team == localPlayer.Team then
                    if boxESP[player] then
                        boxESP[player].Visible = false
                    end
                    continue
                end

                if not boxESP[player] then
                    local box = Drawing.new("Square")
                    box.Thickness = 1
                    box.Transparency = 1
                    box.Color = Color3.fromRGB(255, 255, 255)
                    box.Filled = false
                    boxESP[player] = box
                end

                local char = player.Character
                local rootPart = char.HumanoidRootPart
                local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                local box = boxESP[player]

                if onScreen then
                    local size = Vector3.new(4, 7, 0)
                    local corners = {
                        camera:WorldToViewportPoint(rootPart.Position + Vector3.new(-size.X, size.Y, 0)),
                        camera:WorldToViewportPoint(rootPart.Position + Vector3.new(size.X, size.Y, 0)),
                        camera:WorldToViewportPoint(rootPart.Position + Vector3.new(size.X, -size.Y, 0)),
                        camera:WorldToViewportPoint(rootPart.Position + Vector3.new(-size.X, -size.Y, 0))
                    }

                    box.PointA = Vector2.new(corners[1].X, corners[1].Y)
                    box.PointB = Vector2.new(corners[2].X, corners[2].Y)
                    box.PointC = Vector2.new(corners[3].X, corners[3].Y)
                    box.PointD = Vector2.new(corners[4].X, corners[4].Y)
                    box.Visible = true
                else
                    box.Visible = false
                end
            elseif boxESP[player] then
                boxESP[player]:Remove()
                boxESP[player] = nil
            end
        end
    end

    -- Sound ESP
    if soundESPEnabled then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local char = player.Character
                local rootPart = char.HumanoidRootPart
                local currentPosition = rootPart.Position
                local lastPosition = playerSpeeds[player] and playerSpeeds[player].lastPosition or currentPosition
                local velocity = (currentPosition - lastPosition).Magnitude / (1 / 60)
                playerSpeeds[player] = {speed = velocity, lastPosition = currentPosition}

                if not soundESP[player] then
                    local circle = Drawing.new("Circle")
                    circle.Thickness = 2
                    circle.Transparency = 1
                    circle.Color = Color3.fromRGB(255, 255, 255)
                    soundESP[player] = circle
                end

                local circle = soundESP[player]
                local screenPos, onScreen = camera:WorldToViewportPoint(currentPosition)

                if onScreen then
                    circle.Position = Vector2.new(screenPos.X, screenPos.Y)
                    circle.Radius = math.clamp(playerSpeeds[player].speed * 3, 10, 100)
                    circle.Visible = true
                else
                    circle.Visible = false
                end
            elseif soundESP[player] then
                soundESP[player]:Remove()
                soundESP[player] = nil
            end
        end
    end
end)
