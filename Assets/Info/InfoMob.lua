-- DOORS MONSTER DETECTOR V2 (КРАСИВЫЙ)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- 🎨 GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsterWarning"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local notificationQueue = {}
local isShowing = false

-- 📢 Красивое уведомление
local function ShowWarning(title, message, color)
    table.insert(notificationQueue, {title = title, message = message, color = color})
    
    if isShowing then return end
    isShowing = true
    
    while #notificationQueue > 0 do
        local data = table.remove(notificationQueue, 1)
        
        -- Основной фрейм
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 320, 0, 85)
        Frame.Position = UDim2.new(1, 340, 0, 15)
        Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        Frame.BorderSizePixel = 0
        Frame.Parent = ScreenGui
        
        -- Тень/Обводка
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = data.color
        Stroke.Thickness = 2
        Stroke.Transparency = 0.3
        Stroke.Parent = Frame
        
        -- Закругление
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 10)
        Corner.Parent = Frame
        
        -- Градиент фона
        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
        }
        Gradient.Rotation = 45
        Gradient.Parent = Frame
        
        -- Цветная полоска слева
        local Accent = Instance.new("Frame")
        Accent.Size = UDim2.new(0, 4, 1, 0)
        Accent.BackgroundColor3 = data.color
        Accent.BorderSizePixel = 0
        Accent.Parent = Frame
        
        local AccentCorner = Instance.new("UICorner")
        AccentCorner.CornerRadius = UDim.new(0, 10)
        AccentCorner.Parent = Accent
        
        -- Светящаяся полоска
        local Glow = Instance.new("ImageLabel")
        Glow.Size = UDim2.new(1, 0, 1, 0)
        Glow.BackgroundTransparency = 1
        Glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        Glow.ImageColor3 = data.color
        Glow.ImageTransparency = 0.9
        Glow.Parent = Accent
        
        -- Иконка опасности
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(0, 50, 0, 50)
        Icon.Position = UDim2.new(0, 10, 0.5, -25)
        Icon.BackgroundTransparency = 1
        Icon.Text = "⚠️"
        Icon.TextColor3 = data.color
        Icon.Font = Enum.Font.GothamBold
        Icon.TextSize = 32
        Icon.Parent = Frame
        
        -- Заголовок
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -70, 0, 28)
        Title.Position = UDim2.new(0, 65, 0, 8)
        Title.BackgroundTransparency = 1
        Title.Text = data.title
        Title.TextColor3 = data.color
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 18
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Frame
        
        -- Сообщение
        local Message = Instance.new("TextLabel")
        Message.Size = UDim2.new(1, -70, 0, 40)
        Message.Position = UDim2.new(0, 65, 0, 38)
        Message.BackgroundTransparency = 1
        Message.Text = data.message
        Message.TextColor3 = Color3.fromRGB(200, 200, 200)
        Message.Font = Enum.Font.Gotham
        Message.TextSize = 13
        Message.TextXAlignment = Enum.TextXAlignment.Left
        Message.TextYAlignment = Enum.TextYAlignment.Top
        Message.TextWrapped = true
        Message.Parent = Frame
        
        -- Анимация появления
        local tweenIn = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -330, 0, 15)
        })
        tweenIn:Play()
        
        -- Пульсация иконки
        spawn(function()
            while Frame.Parent do
                TweenService:Create(Icon, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    TextSize = 36
                }):Play()
                task.wait(0.6)
                TweenService:Create(Icon, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    TextSize = 32
                }):Play()
                task.wait(0.6)
            end
        end)
        
        task.wait(4)
        
        -- Анимация исчезновения
        local tweenOut = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 340, 0, 15)
        })
        tweenOut:Play()
        tweenOut.Completed:Wait()
        
        Frame:Destroy()
        task.wait(0.2)
    end
    
    isShowing = false
end

-- 👹 МОНСТРЫ (обновленные имена)
local Monsters = {
    ["RushMoving"] = {
        message = "Прячься в шкаф СЕЙЧАС!",
        color = Color3.fromRGB(255, 50, 50),
        title = "⚡ RUSH"
    },
    ["AmbushMoving"] = {
        message = "Прячься и выходи несколько раз!",
        color = Color3.fromRGB(100, 255, 100),
        title = "🔄 AMBUSH"
    },
    ["Eyes"] = {
        message = "Не смотри на него!",
        color = Color3.fromRGB(150, 0, 255),
        title = "👁️ EYES"
    },
    ["Screech"] = {
        message = "Оглянись когда услышишь звук!",
        color = Color3.fromRGB(255, 255, 100),
        title = "👻 SCREECH"
    },
    ["Halt"] = {
        message = "Иди вперед, останавливайся на 'Turn Around'!",
        color = Color3.fromRGB(50, 150, 255),
        title = "🚫 HALT"
    },
    ["Seek"] = {
        message = "БЕГИТЕ ОТ НЕГО!",
        color = Color3.fromRGB(255, 100, 0),
        title = "🏃 SEEK"
    },
    ["Figure"] = {
        message = "Двигайся ТИХО! Не беги!",
        color = Color3.fromRGB(200, 0, 0),
        title = "👹 FIGURE"
    }
}

local detected = {}

-- Детект в Workspace
workspace.ChildAdded:Connect(function(child)
    for monsterName, info in pairs(Monsters) do
        if child.Name == monsterName and not detected[child] then
            detected[child] = true
            ShowWarning(info.title, info.message, info.color)
            print("🚨", info.title)
        end
    end
end)

-- Детект в CurrentRooms (для Eyes, Screech, Halt)
workspace.CurrentRooms.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)
    for monsterName, info in pairs(Monsters) do
        if descendant.Name == monsterName and not detected[descendant] then
            detected[descendant] = true
            ShowWarning(info.title, info.message, info.color)
            print("🚨", info.title)
            
            task.delay(8, function()
                detected[descendant] = nil
            end)
        end
    end
end)
