local coreGui = game:GetService("CoreGui")
if coreGui:FindFirstChild("ScreenGui") then
    coreGui:FindFirstChild("ScreenGui"):Destroy()
end

loadstring(game:HttpGet('https://raw.githubusercontent.com/drillygzzly/Roblox-UI-Libs/main/Yun%20V2%20Lib/Yun%20V2%20Lib%20Source.lua'))()

local Library = initLibrary()
local Window = Library:Load({name = "Signal", sizeX = 425, sizeY = 300, color = Color3.fromRGB(255, 255, 255)})

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
end)

runService.Heartbeat:Connect(function()
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

    if holdingRMB and lockedTarget then
        local targetChar = lockedTarget.Character
        if targetChar and targetChar:FindFirstChild(targetPart) then
            local targetPos = targetChar[targetPart].Position
            local direction = (targetPos - camera.CFrame.Position).Unit
            local smoothFactor = math.max(0.1, (30 - smoothing) / 30)

            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + camera.CFrame.LookVector:Lerp(direction, smoothFactor))
        else
            lockedTarget = nil
        end
    end
end)

userInput.InputBegan:Connect(function(input, gameProcessed)
    if aimingEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        if not holdingRMB then
            holdingRMB = true
            lockedTarget = getClosestPlayerToCursor()
        end
    end
end)

userInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRMB = false
        lockedTarget = nil
    end
end)

function getClosestPlayerToCursor()
    local mouse = localPlayer:GetMouse()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if teamCheckEnabled and player.Team == localPlayer.Team then
                continue
            end

            local screenPos, onScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if distance < closestDistance then
                    closestPlayer = player
                    closestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end
