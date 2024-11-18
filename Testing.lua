local UILibrary = {}

-- Main table to store UI elements and theme settings
UILibrary.Elements = {}
UILibrary.Theme = {
    BackgroundColor = Color3.fromRGB(40, 40, 40),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(0, 120, 255),
    ButtonColor = Color3.fromRGB(60, 60, 60)
}

-- Function to create a new UI window
function UILibrary:CreateWindow(title)
    local window = Instance.new("ScreenGui")
    window.Name = title or "UIWindow"
    window.Parent = game.CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.4, 0, 0.5, 0)
    mainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
    mainFrame.BackgroundColor3 = self.Theme.BackgroundColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = window

    -- Title Bar
    local titleBar = Instance.new("TextLabel")
    titleBar.Text = title
    titleBar.Size = UDim2.new(1, 0, 0.1, 0)
    titleBar.BackgroundColor3 = self.Theme.AccentColor
    titleBar.TextColor3 = self.Theme.TextColor
    titleBar.Font = Enum.Font.SourceSansBold
    titleBar.TextScaled = true
    titleBar.Parent = mainFrame

    -- Store the window and frame
    self.Elements.Window = window
    self.Elements.MainFrame = mainFrame
    self.Elements.Tabs = {}

    return self
end

-- Function to add a tab
function UILibrary:AddTab(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Text = tabName
    tabButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    tabButton.Position = UDim2.new(#self.Elements.Tabs * 0.2, 0, 0, 0)
    tabButton.BackgroundColor3 = self.Theme.ButtonColor
    tabButton.TextColor3 = self.Theme.TextColor
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.Parent = self.Elements.MainFrame

    -- Tab Content
    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 0.9, 0)
    tabContent.Position = UDim2.new(0, 0, 0.1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = #self.Elements.Tabs == 0 -- First tab is visible by default
    tabContent.Parent = self.Elements.MainFrame

    -- Tab Button Interaction
    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Elements.Tabs) do
            tab.Content.Visible = false
        end
        tabContent.Visible = true
    end)

    table.insert(self.Elements.Tabs, {Button = tabButton, Content = tabContent})
    return tabContent
end

-- Function to add a button
function UILibrary:AddButton(parent, buttonName, callback)
    local button = Instance.new("TextButton")
    button.Text = buttonName
    button.Size = UDim2.new(0.8, 0, 0.1, 0)
    button.Position = UDim2.new(0.1, 0, #parent:GetChildren() * 0.12, 0)
    button.BackgroundColor3 = self.Theme.ButtonColor
    button.TextColor3 = self.Theme.TextColor
    button.Font = Enum.Font.SourceSans
    button.Parent = parent

    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return button
end

-- Function to add a toggle
function UILibrary:AddToggle(parent, toggleName, default, callback)
    local toggle = Instance.new("TextButton")
    toggle.Text = toggleName .. ": " .. (default and "ON" or "OFF")
    toggle.Size = UDim2.new(0.8, 0, 0.1, 0)
    toggle.Position = UDim2.new(0.1, 0, #parent:GetChildren() * 0.12, 0)
    toggle.BackgroundColor3 = self.Theme.ButtonColor
    toggle.TextColor3 = self.Theme.TextColor
    toggle.Font = Enum.Font.SourceSans
    toggle.Parent = parent

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = toggleName .. ": " .. (state and "ON" or "OFF")
        if callback then
            callback(state)
        end
    end)

    return toggle
end

-- Function to add a slider
function UILibrary:AddSlider(parent, sliderName, min, max, default, callback)
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Text = sliderName .. ": " .. default
    sliderLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
    sliderLabel.Position = UDim2.new(0.1, 0, #parent:GetChildren() * 0.12, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextColor3 = self.Theme.TextColor
    sliderLabel.Font = Enum.Font.SourceSans
    sliderLabel.Parent = parent

    local slider = Instance.new("TextButton")
    slider.Text = ""
    slider.Size = UDim2.new(0.8, 0, 0.05, 0)
    slider.Position = UDim2.new(0.1, 0, sliderLabel.Position.Y.Scale + 0.1, 0)
    slider.BackgroundColor3 = self.Theme.ButtonColor
    slider.Parent = parent

    local dragging = false
    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)

    slider.MouseButton1Up:Connect(function()
        dragging = false
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relativeX)
            sliderLabel.Text = sliderName .. ": " .. value
            if callback then
                callback(value)
            end
        end
    end)

    return slider
end

-- Function to add a dropdown
function UILibrary:AddDropdown(parent, dropdownName, options, callback)
    local dropdown = Instance.new("TextButton")
    dropdown.Text = dropdownName
    dropdown.Size = UDim2.new(0.8, 0, 0.1, 0)
    dropdown.Position = UDim2.new(0.1, 0, #parent:GetChildren() * 0.12, 0)
    dropdown.BackgroundColor3 = self.Theme.ButtonColor
    dropdown.TextColor3 = self.Theme.TextColor
    dropdown.Font = Enum.Font.SourceSans
    dropdown.Parent = parent

    local expanded = false
    local optionButtons = {}

    dropdown.MouseButton1Click:Connect(function()
        expanded = not expanded
        for _, button in pairs(optionButtons) do
            button.Visible = expanded
        end
    end)

    for i, option in pairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Text = option
        optionButton.Size = UDim2.new(0.8, 0, 0.1, 0)
        optionButton.Position = UDim2.new(0.1, 0, dropdown.Position.Y.Scale + i * 0.1, 0)
        optionButton.BackgroundColor3 = self.Theme.ButtonColor
        optionButton.TextColor3 = self.Theme.TextColor
        optionButton.Font = Enum.Font.SourceSans
        optionButton.Parent = parent
        optionButton.Visible = false

        optionButton.MouseButton1Click:Connect(function()
            dropdown.Text = dropdownName .. ": " .. option
            expanded = false
            for _, button in pairs(optionButtons) do
                button.Visible = false
            end
            if callback then
                callback(option)
            end
        end)

        table.insert(optionButtons, optionButton)
    end

    return dropdown
end

return UILibrary
