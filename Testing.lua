local SexyUILibrary = {}

SexyUILibrary.Settings = {
    BackgroundColor = Color3.fromRGB(32, 34, 37),
    AccentColor = Color3.fromRGB(114, 137, 218),
    TextColor = Color3.fromRGB(255, 255, 255),
    HoverColor = Color3.fromRGB(54, 57, 63),
    Font = Enum.Font.GothamBold,
}

SexyUILibrary.Components = {}

-- Function to create a base window
function SexyUILibrary:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SexyUI"
    ScreenGui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
    MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = self.Settings.BackgroundColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0.1, 0)
    TitleBar.BackgroundColor3 = self.Settings.AccentColor
    TitleBar.TextColor3 = self.Settings.TextColor
    TitleBar.Text = title
    TitleBar.Font = self.Settings.Font
    TitleBar.TextScaled = true
    TitleBar.Parent = MainFrame

    -- Store elements for future use
    self.Components.Window = ScreenGui
    self.Components.MainFrame = MainFrame

    return self
end

function SexyUILibrary:AddTab(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    tabButton.Position = UDim2.new(#self.Components.Tabs * 0.2, 0, 0, 0)
    tabButton.BackgroundColor3 = self.Settings.BackgroundColor
    tabButton.TextColor3 = self.Settings.TextColor
    tabButton.Font = self.Settings.Font
    tabButton.Text = tabName
    tabButton.Parent = self.Components.MainFrame

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 0.9, 0)
    tabContent.Position = UDim2.new(0, 0, 0.1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = (#self.Components.Tabs == 0) -- First tab visible by default
    tabContent.Parent = self.Components.MainFrame

    -- Smooth transition between tabs
    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Components.Tabs) do
            tab.Content:TweenPosition(UDim2.new(1, 0, tab.Content.Position.Y.Scale, 0), "Out", "Quad", 0.3, true)
            task.wait(0.3)
            tab.Content.Visible = false
        end
        tabContent.Visible = true
        tabContent:TweenPosition(UDim2.new(0, 0, tabContent.Position.Y.Scale, 0), "Out", "Quad", 0.3, true)
    end)

    table.insert(self.Components.Tabs, {Button = tabButton, Content = tabContent})
    return tabContent
end

function SexyUILibrary:AddButton(parent, buttonText, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0.1, 0)
    button.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    button.BackgroundColor3 = self.Settings.HoverColor
    button.TextColor3 = self.Settings.TextColor
    button.Font = self.Settings.Font
    button.Text = buttonText
    button.Parent = parent

    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    -- Hover animation
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = self.Settings.AccentColor
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = self.Settings.HoverColor
    end)

    return button
end

function SexyUILibrary:AddToggle(parent, toggleName, default, callback)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.9, 0, 0.1, 0)
    toggle.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    toggle.BackgroundColor3 = self.Settings.HoverColor
    toggle.TextColor3 = self.Settings.TextColor
    toggle.Font = self.Settings.Font
    toggle.Text = toggleName .. ": " .. (default and "ON" or "OFF")
    toggle.Parent = parent

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = toggleName .. ": " .. (state and "ON" or "OFF")
        if callback then callback(state) end
    end)

    -- Hover animation
    toggle.MouseEnter:Connect(function()
        toggle.BackgroundColor3 = self.Settings.AccentColor
    end)
    toggle.MouseLeave:Connect(function()
        toggle.BackgroundColor3 = self.Settings.HoverColor
    end)

    return toggle
end

function SexyUILibrary:AddSlider(parent, sliderName, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0.1, 0)
    sliderFrame.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    sliderFrame.BackgroundColor3 = self.Settings.HoverColor
    sliderFrame.Parent = parent

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0.5, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextColor3 = self.Settings.TextColor
    sliderLabel.Font = self.Settings.Font
    sliderLabel.Text = sliderName .. ": " .. default
    sliderLabel.Parent = sliderFrame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0.3, 0)
    sliderBar.Position = UDim2.new(0, 0, 0.5, 0)
    sliderBar.BackgroundColor3 = self.Settings.AccentColor
    sliderBar.Parent = sliderFrame

    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0.05, 0, 1, 0)
    sliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0, 0)
    sliderKnob.BackgroundColor3 = self.Settings.TextColor
    sliderKnob.Parent = sliderBar

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

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            sliderKnob.Position = UDim2.new(relativeX, 0, 0, 0)
            local value = math.floor(min + (max - min) * relativeX)
            sliderLabel.Text = sliderName .. ": " .. value
            if callback then callback(value) end
        end
    end)

    return sliderFrame
end

function SexyUILibrary:AddDropdown(parent, dropdownName, options, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0.9, 0, 0.1, 0)
    dropdownFrame.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    dropdownFrame.BackgroundColor3 = self.Settings.HoverColor
    dropdownFrame.Parent = parent

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundColor3 = self.Settings.ButtonColor
    dropdownButton.TextColor3 = self.Settings.TextColor
    dropdownButton.Font = self.Settings.Font
    dropdownButton.Text = dropdownName .. ": " .. (options[1] or "None")
    dropdownButton.Parent = dropdownFrame

    local expanded = false
    local dropdownOptions = {}

    dropdownButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        for _, optionButton in pairs(dropdownOptions) do
            optionButton.Visible = expanded
        end
    end)

    for i, option in pairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0.1, 0)
        optionButton.Position = UDim2.new(0, 0, i * 0.1, 0)
        optionButton.BackgroundColor3 = self.Settings.ButtonColor
        optionButton.TextColor3 = self.Settings.TextColor
        optionButton.Font = self.Settings.Font
        optionButton.Text = option
        optionButton.Visible = false
        optionButton.Parent = dropdownFrame

        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = dropdownName .. ": " .. option
            expanded = false
            for _, btn in pairs(dropdownOptions) do
                btn.Visible = false
            end
            if callback then callback(option) end
        end)

        table.insert(dropdownOptions, optionButton)
    end

    return dropdownFrame
end

function SexyUILibrary:AddKeybind(parent, keybindName, defaultKey, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(0.9, 0, 0.1, 0)
    keybindFrame.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    keybindFrame.BackgroundColor3 = self.Settings.HoverColor
    keybindFrame.Parent = parent

    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.TextColor3 = self.Settings.TextColor
    keybindLabel.Font = self.Settings.Font
    keybindLabel.Text = keybindName
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Parent = keybindFrame

    local keybindButton = Instance.new("TextButton")
    keybindButton.Size = UDim2.new(0.4, 0, 1, 0)
    keybindButton.Position = UDim2.new(0.6, 0, 0, 0)
    keybindButton.BackgroundColor3 = self.Settings.ButtonColor
    keybindButton.TextColor3 = self.Settings.TextColor
    keybindButton.Font = self.Settings.Font
    keybindButton.Text = defaultKey.Name
    keybindButton.Parent = keybindFrame

    local listening = false

    keybindButton.MouseButton1Click:Connect(function()
        keybindButton.Text = "Press Key"
        listening = true
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            keybindButton.Text = input.KeyCode.Name
            listening = false
            if callback then callback(input.KeyCode) end
        end
    end)

    return keybindFrame
end

function SexyUILibrary:AddColorPicker(parent, pickerName, defaultColor, callback)
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(0.9, 0, 0.1, 0)
    pickerFrame.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    pickerFrame.BackgroundColor3 = self.Settings.HoverColor
    pickerFrame.Parent = parent

    local pickerLabel = Instance.new("TextLabel")
    pickerLabel.Size = UDim2.new(0.6, 0, 1, 0)
    pickerLabel.BackgroundTransparency = 1
    pickerLabel.TextColor3 = self.Settings.TextColor
    pickerLabel.Font = self.Settings.Font
    pickerLabel.Text = pickerName
    pickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    pickerLabel.Parent = pickerFrame

    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.4, 0, 1, 0)
    colorButton.Position = UDim2.new(0.6, 0, 0, 0)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.Text = ""
    colorButton.Parent = pickerFrame

    colorButton.MouseButton1Click:Connect(function()
        local colorPicker = Instance.new("Color3Value")
        colorPicker.Value = colorButton.BackgroundColor3
        if callback then callback(colorPicker.Value) end
    end)

    return pickerFrame
end

function SexyUILibrary:Animate(element, property, value, duration)
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = tweenService:Create(element, tweenInfo, {[property] = value})
    tween:Play()
end

function SexyUILibrary:AddNotification(message, duration)
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0.3, 0, 0.05, 0)
    notificationFrame.Position = UDim2.new(0.35, 0, -0.1, 0)
    notificationFrame.BackgroundColor3 = self.Settings.AccentColor
    notificationFrame.Parent = game.CoreGui

    local notificationLabel = Instance.new("TextLabel")
    notificationLabel.Size = UDim2.new(1, 0, 1, 0)
    notificationLabel.BackgroundTransparency = 1
    notificationLabel.TextColor3 = self.Settings.TextColor
    notificationLabel.Font = self.Settings.Font
    notificationLabel.Text = message
    notificationLabel.Parent = notificationFrame

    self:Animate(notificationFrame, "Position", UDim2.new(0.35, 0, 0.05, 0), 0.5)
    task.wait(duration)
    self:Animate(notificationFrame, "Position", UDim2.new(0.35, 0, -0.1, 0), 0.5)
    task.wait(0.5)
    notificationFrame:Destroy()
end

function SexyUILibrary:ApplyTheme(themeSettings)
    for key, value in pairs(themeSettings) do
        if self.Settings[key] then
            self.Settings[key] = value
        end
    end

    -- Update all existing elements to match the new theme
    for _, element in pairs(self.Elements) do
        if element:IsA("Frame") or element:IsA("TextButton") or element:IsA("TextLabel") then
            element.BackgroundColor3 = self.Settings.BackgroundColor
            element.TextColor3 = self.Settings.TextColor
        end
    end
end

-- Example of setting a custom theme
SexyUILibrary:ApplyTheme({
    BackgroundColor = Color3.fromRGB(30, 30, 30),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(255, 0, 100),
    ButtonColor = Color3.fromRGB(50, 50, 50),
    HoverColor = Color3.fromRGB(70, 70, 70),
})

function SexyUILibrary:AddSearchableDropdown(parent, dropdownName, options, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0.9, 0, 0.1, 0)
    dropdownFrame.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    dropdownFrame.BackgroundColor3 = self.Settings.ButtonColor
    dropdownFrame.Parent = parent

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Text = dropdownName
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundColor3 = self.Settings.ButtonColor
    dropdownButton.TextColor3 = self.Settings.TextColor
    dropdownButton.Font = self.Settings.Font
    dropdownButton.Parent = dropdownFrame

    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(1, 0, 0, #options * 30)
    dropdownList.Position = UDim2.new(0, 0, 1, 0)
    dropdownList.BackgroundTransparency = 1
    dropdownList.Visible = false
    dropdownList.Parent = dropdownFrame

    for _, option in pairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Text = option
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.BackgroundColor3 = self.Settings.ButtonColor
        optionButton.TextColor3 = self.Settings.TextColor
        optionButton.Font = self.Settings.Font
        optionButton.Parent = dropdownList

        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option
            dropdownList.Visible = false
            if callback then callback(option) end
        end)
    end

    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)

    return dropdownFrame
end
