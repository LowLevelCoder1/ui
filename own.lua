-- UI Library
local UiLibrary = {}

-- Services
local TweenService = game:GetService("TweenService")
local InputService = game:GetService("UserInputService")

-- Themes
UiLibrary.Themes = {
    Default = {
        Background = Color3.fromRGB(24, 24, 24),
        Accent = Color3.fromRGB(34, 34, 34),
        TextColor = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(0, 0, 0),
    }
}

UiLibrary.CurrentTheme = UiLibrary.Themes.Default

-- Utility Functions
UiLibrary.Utility = {}

function UiLibrary.Utility:Tween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function UiLibrary.Utility:Create(instanceType, properties, children)
    local instance = Instance.new(instanceType)

    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end

    for _, child in pairs(children or {}) do
        child.Parent = instance
    end

    return instance
end

-- Initialize Library
function UiLibrary:Init(title)
    local screenGui = UiLibrary.Utility:Create("ScreenGui", {
        Name = title,
        Parent = game.CoreGui,
        ResetOnSpawn = false,
    })

    local mainFrame = UiLibrary.Utility:Create("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        Size = UDim2.new(0, 600, 0, 400),
        BackgroundColor3 = self.CurrentTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        AnchorPoint = Vector2.new(0.5, 0.5),
    }, {
        UiLibrary.Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        UiLibrary.Utility:Create("UIStroke", {Color = self.CurrentTheme.Accent, Thickness = 2}),
    })

    self.MainFrame = mainFrame
    self.ScreenGui = screenGui

    return self
end

-- Add Page
function UiLibrary:AddPage(title)
    local pageButton = self.Utility:Create("TextButton", {
        Name = title,
        Parent = self.MainFrame,
        Text = title,
        Size = UDim2.new(0, 120, 0, 30),
        BackgroundColor3 = self.CurrentTheme.Accent,
        TextColor3 = self.CurrentTheme.TextColor,
        BorderSizePixel = 0,
    }, {
        self.Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)})
    })

    local pageFrame = self.Utility:Create("Frame", {
        Name = title .. "Page",
        Parent = self.MainFrame,
        Size = UDim2.new(1, -130, 1, -10),
        Position = UDim2.new(0, 130, 0, 10),
        BackgroundColor3 = self.CurrentTheme.Background,
        Visible = false,
        BorderSizePixel = 0,
    })

    pageButton.MouseButton1Click:Connect(function()
        for _, child in ipairs(self.MainFrame:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = false
            end
        end
        pageFrame.Visible = true
    end)

    return {
        Frame = pageFrame,
        Button = pageButton,
    }
end

-- Add Section
function UiLibrary:AddSection(parent, title)
    local sectionFrame = self.Utility:Create("Frame", {
        Name = title,
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 50),
        BackgroundColor3 = self.CurrentTheme.Accent,
        BorderSizePixel = 0,
    }, {
        self.Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        self.Utility:Create("TextLabel", {
            Name = "SectionTitle",
            Text = title,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            TextColor3 = self.CurrentTheme.TextColor,
            Font = Enum.Font.Gotham,
            TextSize = 14,
        }),
    })

    return sectionFrame
end

-- Add Button
function UiLibrary:AddButton(parent, title, callback)
    local button = self.Utility:Create("TextButton", {
        Name = title,
        Parent = parent,
        Text = title,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.CurrentTheme.Accent,
        TextColor3 = self.CurrentTheme.TextColor,
        BorderSizePixel = 0,
    }, {
        self.Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
    })

    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return button
end

-- Add Toggle
function UiLibrary:AddToggle(parent, title, default, callback)
    local toggleFrame = self.Utility:Create("Frame", {
        Name = title,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.CurrentTheme.Accent,
        BorderSizePixel = 0,
    }, {
        self.Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        self.Utility:Create("TextLabel", {
            Name = "ToggleLabel",
            Text = title,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = self.CurrentTheme.TextColor,
            Font = Enum.Font.Gotham,
            TextSize = 14,
        }),
    })

    local toggleButton = self.Utility:Create("TextButton", {
        Name = "ToggleButton",
        Parent = toggleFrame,
        Size = UDim2.new(0.2, -10, 0.6, 0),
        Position = UDim2.new(0.8, 0, 0.2, 0),
        BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0),
        Text = "",
        BorderSizePixel = 0,
    }, {
        self.Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
    })

    local state = default or false

    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        if callback then
            callback(state)
        end
    end)

    return toggleFrame
end

-- Add Slider
function UiLibrary:AddSlider(parent, title, min, max, default, callback)
    local sliderFrame = self.Utility:Create("Frame", {
        Name = title,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = self.CurrentTheme.Accent,
        BorderSizePixel = 0,
    }, {
        self.Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        self.Utility:Create("TextLabel", {
            Name = "SliderLabel",
            Text = title,
            Size = UDim2.new(0.8, 0, 0.4, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = self.CurrentTheme.TextColor,
            Font = Enum.Font.Gotham,
            TextSize = 14,
        }),
    })

    local sliderBar = self.Utility:Create("Frame", {
        Name = "SliderBar",
        Parent = sliderFrame,
        Size = UDim2.new(0.9, 0, 0.3, 0),
        Position = UDim2.new(0.05, 0, 0.6, 0),
        BackgroundColor3 = self.CurrentTheme.TextColor,
        BorderSizePixel = 0,
    }, {
        self.Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
    })

    local sliderKnob = self.Utility:Create("Frame", {
        Name = "SliderKnob",
        Parent = sliderBar,
        Size = UDim2.new(0.1, 0, 1, 0),
        BackgroundColor3 = self.CurrentTheme.Accent,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
    }, {
        self.Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
    })

    local valueLabel = self.Utility:Create("TextLabel", {
        Name = "ValueLabel",
        Parent = sliderFrame,
        Size = UDim2.new(0.2, 0, 0.4, 0),
        Position = UDim2.new(0.8, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.CurrentTheme.TextColor,
        Text = tostring(default or min),
        Font = Enum.Font.Gotham,
        TextSize = 14,
    })

    local dragging = false

    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    sliderKnob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    InputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = math.clamp(input.Position.X, sliderBar.AbsolutePosition.X, sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X)
            local percent = (mouseX - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
            local value = math.floor(min + (max - min) * percent)
            sliderKnob.Position = UDim2.new(percent, 0, 0, 0)
            valueLabel.Text = tostring(value)
            if callback then
                callback(value)
            end
        end
    end)

    return sliderFrame
end

return UiLibrary
