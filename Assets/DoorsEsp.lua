local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

local ESPObjects = {}
local Settings = {
    BoxESP = true,
    Tracers = true,
    Distance = true,
    NameTag = true,
    Highlight = true,
    MaxDistance = 500,
    BoxColor = Color3.fromRGB(0, 255, 100),
    TracerColor = Color3.fromRGB(100, 255, 0),
    TextColor = Color3.fromRGB(0, 255, 150),
    HighlightColor = Color3.fromRGB(50, 255, 50),
    BoxThickness = 2,
    TracerThickness = 2,
    BoxTransparency = 0,
    TracerTransparency = 0,
    FillTransparency = 0.7,
    UpdateRate = 0.1
}

local function worldToScreen(position)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen, screenPoint.Z
end

local function getCorners(part)
    local cf = part.CFrame
    local size = part.Size
    return {
        (cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position,
        (cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2)).Position,
        (cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)).Position,
        (cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2)).Position,
        (cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2)).Position,
        (cf * CFrame.new(size.X/2, size.Y/2, size.Z/2)).Position,
        (cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2)).Position,
        (cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position
    }
end

local function create2DBox()
    local box = {
        TopLeft = Drawing.new("Line"),
        TopRight = Drawing.new("Line"),
        BottomLeft = Drawing.new("Line"),
        BottomRight = Drawing.new("Line"),
        LeftSide = Drawing.new("Line"),
        RightSide = Drawing.new("Line"),
        TopSide = Drawing.new("Line"),
        BottomSide = Drawing.new("Line")
    }
    
    for _, line in pairs(box) do
        line.Thickness = Settings.BoxThickness
        line.Color = Settings.BoxColor
        line.Transparency = 1 - Settings.BoxTransparency
        line.Visible = false
    end
    
    return box
end

local function createTracer()
    local tracer = Drawing.new("Line")
    tracer.Thickness = Settings.TracerThickness
    tracer.Color = Settings.TracerColor
    tracer.Transparency = 1 - Settings.TracerTransparency
    tracer.Visible = false
    return tracer
end

local function createText()
    local text = Drawing.new("Text")
    text.Size = 16
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(0, 0, 0)
    text.Color = Settings.TextColor
    text.Font = 3
    text.Visible = false
    return text
end

local function createDistanceText()
    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(0, 0, 0)
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Font = 2
    text.Visible = false
    return text
end

local function createHighlight(object)
    local highlight = Instance.new("Highlight")
    highlight.Name = "DoorHighlight"
    highlight.Adornee = object
    highlight.FillColor = Settings.HighlightColor
    highlight.FillTransparency = Settings.FillTransparency
    highlight.OutlineColor = Settings.BoxColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = object
    return highlight
end

local function updateBox(box, corners)
    local min = Vector2.new(math.huge, math.huge)
    local max = Vector2.new(-math.huge, -math.huge)
    local allOnScreen = true
    
    for _, corner in ipairs(corners) do
        local screenPos, onScreen = worldToScreen(corner)
        if not onScreen then
            allOnScreen = false
        end
        min = Vector2.new(math.min(min.X, screenPos.X), math.min(min.Y, screenPos.Y))
        max = Vector2.new(math.max(max.X, screenPos.X), math.max(max.Y, screenPos.Y))
    end
    
    if allOnScreen then
        local topLeft = min
        local topRight = Vector2.new(max.X, min.Y)
        local bottomLeft = Vector2.new(min.X, max.Y)
        local bottomRight = max
        
        local width = max.X - min.X
        local height = max.Y - min.Y
        local cornerSize = math.min(width, height) * 0.25
        
        box.TopLeft.From = topLeft
        box.TopLeft.To = topLeft + Vector2.new(cornerSize, 0)
        box.TopLeft.Visible = true
        
        box.TopRight.From = topRight
        box.TopRight.To = topRight - Vector2.new(cornerSize, 0)
        box.TopRight.Visible = true
        
        box.BottomLeft.From = bottomLeft
        box.BottomLeft.To = bottomLeft + Vector2.new(cornerSize, 0)
        box.BottomLeft.Visible = true
        
        box.BottomRight.From = bottomRight
        box.BottomRight.To = bottomRight - Vector2.new(cornerSize, 0)
        box.BottomRight.Visible = true
        
        box.LeftSide.From = topLeft
        box.LeftSide.To = topLeft + Vector2.new(0, cornerSize)
        box.LeftSide.Visible = true
        
        box.RightSide.From = topRight
        box.RightSide.To = topRight + Vector2.new(0, cornerSize)
        box.RightSide.Visible = true
        
        box.TopSide.From = bottomLeft
        box.TopSide.To = bottomLeft - Vector2.new(0, cornerSize)
        box.TopSide.Visible = true
        
        box.BottomSide.From = bottomRight
        box.BottomSide.To = bottomRight - Vector2.new(0, cornerSize)
        box.BottomSide.Visible = true
        
        return true, topLeft, bottomRight
    else
        for _, line in pairs(box) do
            line.Visible = false
        end
        return false
    end
end

local function updateTracer(tracer, position)
    local screenPos, onScreen = worldToScreen(position)
    
    if onScreen then
        local viewportSize = Camera.ViewportSize
        local fromPos = Vector2.new(viewportSize.X / 2, viewportSize.Y)
        
        tracer.From = fromPos
        tracer.To = screenPos
        tracer.Visible = true
        return true
    else
        tracer.Visible = false
        return false
    end
end

local function updateText(text, nameText, position, topLeft, bottomRight)
    local screenPos, onScreen = worldToScreen(position)
    
    if onScreen and topLeft and bottomRight then
        text.Position = Vector2.new((topLeft.X + bottomRight.X) / 2, topLeft.Y - 20)
        text.Text = nameText
        text.Visible = true
        return true
    else
        text.Visible = false
        return false
    end
end

local function updateDistance(distText, position, topLeft, bottomRight)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        distText.Visible = false
        return false
    end
    
    local distance = (player.Character.HumanoidRootPart.Position - position).Magnitude
    
    if distance > Settings.MaxDistance then
        distText.Visible = false
        return false
    end
    
    local screenPos, onScreen = worldToScreen(position)
    
    if onScreen and topLeft and bottomRight then
        distText.Position = Vector2.new((topLeft.X + bottomRight.X) / 2, bottomRight.Y + 5)
        distText.Text = string.format("[%dm]", math.floor(distance))
        distText.Visible = true
        return true
    else
        distText.Visible = false
        return false
    end
end

local function createESP(object, name)
    if ESPObjects[object] then return end
    
    local espData = {
        Object = object,
        Name = name or "DOOR",
        Box = Settings.BoxESP and create2DBox() or nil,
        Tracer = Settings.Tracers and createTracer() or nil,
        NameTag = Settings.NameTag and createText() or nil,
        Distance = Settings.Distance and createDistanceText() or nil,
        Highlight = Settings.Highlight and createHighlight(object) or nil
    }
    
    ESPObjects[object] = espData
end

local function removeESP(object)
    local espData = ESPObjects[object]
    if not espData then return end
    
    if espData.Box then
        for _, line in pairs(espData.Box) do
            line:Remove()
        end
    end
    
    if espData.Tracer then
        espData.Tracer:Remove()
    end
    
    if espData.NameTag then
        espData.NameTag:Remove()
    end
    
    if espData.Distance then
        espData.Distance:Remove()
    end
    
    if espData.Highlight then
        espData.Highlight:Destroy()
    end
    
    ESPObjects[object] = nil
end

local function updateESP()
    for object, espData in pairs(ESPObjects) do
        if not object or not object.Parent then
            removeESP(object)
        else
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local distance = (player.Character.HumanoidRootPart.Position - object.Position).Magnitude
                
                if distance > Settings.MaxDistance then
                    if espData.Box then
                        for _, line in pairs(espData.Box) do
                            line.Visible = false
                        end
                    end
                    if espData.Tracer then espData.Tracer.Visible = false end
                    if espData.NameTag then espData.NameTag.Visible = false end
                    if espData.Distance then espData.Distance.Visible = false end
                    return
                end
                
                local corners = getCorners(object)
                local topLeft, bottomRight
                
                if espData.Box then
                    local visible, tl, br = updateBox(espData.Box, corners)
                    topLeft = tl
                    bottomRight = br
                end
                
                if espData.Tracer then
                    updateTracer(espData.Tracer, object.Position)
                end
                
                if espData.NameTag then
                    updateText(espData.NameTag, "🚪 " .. espData.Name, object.Position, topLeft, bottomRight)
                end
                
                if espData.Distance then
                    updateDistance(espData.Distance, object.Position, topLeft, bottomRight)
                end
            end)
        end
    end
end

local function findDoors()
    local currentRooms = Workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return end
    
    for _, room in pairs(currentRooms:GetChildren()) do
        local foundDoor = false
        
        for obj, _ in pairs(ESPObjects) do
            if obj and obj.Parent and obj:IsDescendantOf(room) then
                foundDoor = true
                break
            end
        end
        
        if not foundDoor then
            local door = room:FindFirstChild("Door")
            if door then
                for _, part in pairs(door:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name == "Door" then
                        createESP(part, "DOOR")
                        break
                    end
                end
            end
            
            for _, descendant in pairs(room:GetDescendants()) do
                if descendant:IsA("Model") and descendant.Name == "Door" then
                    local doorPart = descendant:FindFirstChild("Door")
                    if doorPart and doorPart:IsA("BasePart") then
                        createESP(doorPart, "DOOR")
                        break
                    end
                end
            end
        end
    end
end

local function scanDoors()
    while task.wait(2) do
        pcall(findDoors)
    end
end

local currentRooms = Workspace:WaitForChild("CurrentRooms", 10)
if currentRooms then
    currentRooms.DescendantAdded:Connect(function(descendant)
        task.wait(0.1)
        
        if descendant:IsA("Model") and descendant.Name == "Door" then
            local room = descendant.Parent
            if room and room.Parent == currentRooms then
                local hasDoor = false
                
                for obj, _ in pairs(ESPObjects) do
                    if obj and obj.Parent and obj:IsDescendantOf(room) then
                        hasDoor = true
                        break
                    end
                end
                
                if not hasDoor then
                    local doorPart = descendant:FindFirstChild("Door")
                    if doorPart and doorPart:IsA("BasePart") then
                        createESP(doorPart, "DOOR")
                    end
                end
            end
        end
        
        if descendant:IsA("BasePart") and descendant.Name == "Door" then
            local doorModel = descendant.Parent
            if doorModel and doorModel.Name == "Door" then
                local room = doorModel.Parent
                if room and room.Parent == currentRooms then
                    local hasDoor = false
                    
                    for obj, _ in pairs(ESPObjects) do
                        if obj and obj.Parent and obj:IsDescendantOf(room) then
                            hasDoor = true
                            break
                        end
                    end
                    
                    if not hasDoor then
                        createESP(descendant, "DOOR")
                    end
                end
            end
        end
    end)
end

RunService.RenderStepped:Connect(updateESP)

task.spawn(scanDoors)

findDoors()

local function rainbowEffect()
    local hue = 0
    while task.wait(0.05) do
        hue = (hue + 0.01) % 1
        local color = Color3.fromHSV(hue, 1, 1)
        
        for _, espData in pairs(ESPObjects) do
            if espData.Box then
                for _, line in pairs(espData.Box) do
                    line.Color = color
                end
            end
            if espData.Highlight then
                espData.Highlight.OutlineColor = color
            end
        end
    end
end

task.spawn(rainbowEffect)
