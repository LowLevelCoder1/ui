-- Custom UI Library (GitHub Ready)
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local UILibrary = {}

-- Create the main UI window
function UILibrary:CreateWindow(config)
    local Window = {}
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = config.Name or "CustomUILibrary"

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, config.Width or 400, 0, config.Height or 500)
    MainFrame.Position = UDim2.new(0.5, -(config.Width or 400) / 2, 0.5, -(config.Height or 500) / 2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.Text = config.Title or "Custom UI"
    TitleBar.TextColor3 = Color3.new(1, 1, 1)
    TitleBar.TextSize = 16
    TitleBar.Parent = MainFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -30)
    ContentFrame.Position = UDim2.new(0, 0, 0, 30)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame

    -- Dragging Logic
    local Draggable = false
    local DragStart, StartPosition

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Draggable = true
            DragStart = input.Position
            StartPosition = MainFrame.Position
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Draggable = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if Draggable and input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
        end
    end)

    -- API for adding components
    function Window:AddToggle(name, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = ContentFrame

        local Label = Instance.new("TextLabel")
        Label.Text = name
        Label.Size = UDim2.new(0.8, 0, 1, 0)
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.Parent = ToggleFrame

        local Button = Instance.new("TextButton")
        Button.Text = "OFF"
        Button.Size = UDim2.new(0.2, 0, 1, 0)
        Button.Position = UDim2.new(0.8, 0, 0, 0)
        Button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.Parent = ToggleFrame

        local State = false

        Button.MouseButton1Click:Connect(function()
            State = not State
            Button.Text = State and "ON" or "OFF"
            Button.BackgroundColor3 = State and Color3.new(0, 1, 0) or Color3.new(0.2, 0.2, 0.2)
            callback(State)
        end)
    end

    function Window:AddSlider(name, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = ContentFrame

        local Label = Instance.new("TextLabel")
        Label.Text = name
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.Parent = SliderFrame

        local SliderBar = Instance.new("Frame")
        SliderBar.Size = UDim2.new(1, 0, 0, 5)
        SliderBar.Position = UDim2.new(0, 0, 0.5, -2)
        SliderBar.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        SliderBar.BorderSizePixel = 0
        SliderBar.Parent = SliderFrame

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 10, 0, 10)
        Knob.Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5)
        Knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Knob.BorderSizePixel = 0
        Knob.Parent = SliderBar

        local Dragging = false

        Knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
            end
        end)

        Knob.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local MouseX = input.Position.X
                local BarStart = SliderBar.AbsolutePosition.X
                local BarEnd = BarStart + SliderBar.AbsoluteSize.X
                local ClampedX = math.clamp(MouseX, BarStart, BarEnd)
                local Value = min + ((ClampedX - BarStart) / (BarEnd - BarStart)) * (max - min)
                Knob.Position = UDim2.new((Value - min) / (max - min), -5, 0.5, -5)
                callback(math.floor(Value))
            end
        end)
    end

    return Window
end

return UILibrary
