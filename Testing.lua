local UILibrary = {}
UILibrary.Theme = {
    BackgroundColor = Color3.fromRGB(30, 30, 30),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(85, 170, 255),
    ButtonColor = Color3.fromRGB(50, 50, 50),
    HoverColor = Color3.fromRGB(70, 70, 70)
}

UILibrary.Registry = {}
UILibrary.Windows = {}

-- Utility functions
local function AddToRegistry(object, properties)
    table.insert(UILibrary.Registry, {Object = object, Properties = properties})
end

local function UpdateColors()
    for _, entry in ipairs(UILibrary.Registry) do
        for prop, color in pairs(entry.Properties) do
            entry.Object[prop] = UILibrary.Theme[color]
        end
    end
end

-- Draggable functionality
local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput, startPos, startOffset

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position
            startOffset = frame.Position
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            frame.Position = UDim2.new(startOffset.X.Scale, startOffset.X.Offset + delta.X, startOffset.Y.Scale, startOffset.Y.Offset + delta.Y)
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Create a new window
function UILibrary:CreateWindow(title)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "UILibrary"

    local window = Instance.new("Frame", gui)
    window.Size = UDim2.new(0.3, 0, 0.5, 0)
    window.Position = UDim2.new(0.35, 0, 0.25, 0)
    window.BackgroundColor3 = self.Theme.BackgroundColor
    window.BorderSizePixel = 0

    local titleBar = Instance.new("TextLabel", window)
    titleBar.Size = UDim2.new(1, 0, 0.1, 0)
    titleBar.BackgroundColor3 = self.Theme.AccentColor
    titleBar.Text = title
    titleBar.Font = Enum.Font.SourceSansBold
    titleBar.TextColor3 = self.Theme.TextColor
    titleBar.TextSize = 18

    MakeDraggable(window, titleBar)

    self.Windows[title] = {Window = window, Tabs = {}}
    AddToRegistry(window, {BackgroundColor3 = "BackgroundColor"})
    AddToRegistry(titleBar, {BackgroundColor3 = "AccentColor", TextColor3 = "TextColor"})
    return self.Windows[title]
end

-- Add a tab
function UILibrary:AddTab(windowTitle, tabName)
    local window = self.Windows[windowTitle].Window
    local tab = Instance.new("Frame", window)
    tab.Size = UDim2.new(1, 0, 0.9, 0)
    tab.Position = UDim2.new(0, 0, 0.1, 0)
    tab.BackgroundTransparency = 1
    tab.Visible = #self.Windows[windowTitle].Tabs == 0 -- Show the first tab by default
    self.Windows[windowTitle].Tabs[tabName] = tab

    local tabButton = Instance.new("TextButton", window)
    tabButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    tabButton.Position = UDim2.new((#self.Windows[windowTitle].Tabs - 1) * 0.2, 0, 0, 0)
    tabButton.BackgroundColor3 = self.Theme.ButtonColor
    tabButton.TextColor3 = self.Theme.TextColor
    tabButton.Font = Enum.Font.SourceSans
    tabButton.Text = tabName
    tabButton.TextSize = 16

    tabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Windows[windowTitle].Tabs) do
            t.Visible = false
        end
        tab.Visible = true
    end)

    AddToRegistry(tabButton, {BackgroundColor3 = "ButtonColor", TextColor3 = "TextColor"})
    return tab
end

-- Add a button
function UILibrary:AddButton(tab, buttonText, callback)
    local button = Instance.new("TextButton", tab)
    button.Size = UDim2.new(0.9, 0, 0.1, 0)
    button.Position = UDim2.new(0.05, 0, #tab:GetChildren() * 0.12, 0)
    button.BackgroundColor3 = self.Theme.ButtonColor
    button.TextColor3 = self.Theme.TextColor
    button.Font = Enum.Font.SourceSans
    button.Text = buttonText
    button.TextSize = 16

    button.MouseButton1Click:Connect(callback)
    AddToRegistry(button, {BackgroundColor3 = "ButtonColor", TextColor3 = "TextColor"})
    return button
end

function UILibrary:AddToggle(tab, toggleText, default, callback)
    local toggle = Instance.new("TextButton", tab)
    toggle.Size = UDim2.new(0.9, 0, 0.1, 0)
    toggle.Position = UDim2.new(0.05, 0, #tab:GetChildren() * 0.12, 0)
    toggle.BackgroundColor3 = self.Theme.ButtonColor
    toggle.TextColor3 = self.Theme.TextColor
    toggle.Font = Enum.Font.SourceSans
    toggle.TextSize = 16
    toggle.Text = toggleText .. ": " .. (default and "ON" or "OFF")

    local state = default or false

    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = toggleText .. ": " .. (state and "ON" or "OFF")
        if callback then
            callback(state)
        end
    end)

    AddToRegistry(toggle, {BackgroundColor3 = "ButtonColor", TextColor3 = "TextColor"})
    return toggle
end

function UILibrary:AddSlider(tab, sliderText, min, max, default, callback)
    local sliderFrame = Instance.new("Frame", tab)
    sliderFrame.Size = UDim2.new(0.9, 0, 0.1, 0)
    sliderFrame.Position = UDim2.new(0.05, 0, #tab:GetChildren() * 0.12, 0)
    sliderFrame.BackgroundColor3 = self.Theme.BackgroundColor

    local sliderLabel = Instance.new("TextLabel", sliderFrame)
    sliderLabel.Size = UDim2.new(1, 0, 0.5, 0)
    sliderLabel.TextColor3 = self.Theme.TextColor
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = sliderText .. ": " .. tostring(default)
    sliderLabel.Font = Enum.Font.SourceSans
    sliderLabel.TextSize = 14

    local sliderBar = Instance.new("Frame", sliderFrame)
    sliderBar.Size = UDim2.new(1, 0, 0.3, 0)
    sliderBar.Position = UDim2.new(0, 0, 0.5, 0)
    sliderBar.BackgroundColor3 = self.Theme.ButtonColor

    local sliderKnob = Instance.new("TextButton", sliderBar)
    sliderKnob.Size = UDim2.new(0, 10, 1, 0)
    sliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0, 0)
    sliderKnob.BackgroundColor3 = self.Theme.AccentColor
    sliderKnob.Text = ""

    local function updateSlider(input)
        local x = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + x * (max - min))
        sliderLabel.Text = sliderText .. ": " .. tostring(value)
        sliderKnob.Position = UDim2.new(x, 0, 0, 0)
        if callback then
            callback(value)
        end
    end

    sliderKnob.MouseButton1Down:Connect(function()
        local connection
        connection = game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end)

    AddToRegistry(sliderFrame, {BackgroundColor3 = "BackgroundColor"})
    AddToRegistry(sliderBar, {BackgroundColor3 = "ButtonColor"})
    AddToRegistry(sliderKnob, {BackgroundColor3 = "AccentColor"})
    AddToRegistry(sliderLabel, {TextColor3 = "TextColor"})
    return sliderFrame
end

function UILibrary:AddTextBox(tab, textBoxText, callback)
    local textBoxFrame = Instance.new("Frame", tab)
    textBoxFrame.Size = UDim2.new(0.9, 0, 0.1, 0)
    textBoxFrame.Position = UDim2.new(0.05, 0, #tab:GetChildren() * 0.12, 0)
    textBoxFrame.BackgroundColor3 = self.Theme.ButtonColor

    local textBoxLabel = Instance.new("TextLabel", textBoxFrame)
    textBoxLabel.Size = UDim2.new(0.5, 0, 1, 0)
    textBoxLabel.Text = textBoxText
    textBoxLabel.TextColor3 = self.Theme.TextColor
    textBoxLabel.BackgroundTransparency = 1
    textBoxLabel.Font = Enum.Font.SourceSans
    textBoxLabel.TextSize = 14

    local textBoxInput = Instance.new("TextBox", textBoxFrame)
    textBoxInput.Size = UDim2.new(0.5, 0, 1, 0)
    textBoxInput.Position = UDim2.new(0.5, 0, 0, 0)
    textBoxInput.BackgroundColor3 = self.Theme.BackgroundColor
    textBoxInput.TextColor3 = self.Theme.TextColor
    textBoxInput.Font = Enum.Font.SourceSans
    textBoxInput.TextSize = 14
    textBoxInput.PlaceholderText = "Enter text..."

    textBoxInput.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(textBoxInput.Text)
        end
    end)

    AddToRegistry(textBoxFrame, {BackgroundColor3 = "ButtonColor"})
    AddToRegistry(textBoxInput, {BackgroundColor3 = "BackgroundColor", TextColor3 = "TextColor"})
    AddToRegistry(textBoxLabel, {TextColor3 = "TextColor"})
    return textBoxFrame
end

function UILibrary:AddDropdown(tab, dropdownText, options, callback)
    local dropdownFrame = Instance.new("Frame", tab)
    dropdownFrame.Size = UDim2.new(0.9, 0, 0.1, 0)
    dropdownFrame.Position = UDim2.new(0.05, 0, #tab:GetChildren() * 0.12, 0)
    dropdownFrame.BackgroundColor3 = self.Theme.ButtonColor

    local dropdownLabel = Instance.new("TextLabel", dropdownFrame)
    dropdownLabel.Size = UDim2.new(0.6, 0, 1, 0)
    dropdownLabel.Text = dropdownText
    dropdownLabel.TextColor3 = self.Theme.TextColor
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Font = Enum.Font.SourceSans
    dropdownLabel.TextSize = 14

    local dropdownButton = Instance.new("TextButton", dropdownFrame)
    dropdownButton.Size = UDim2.new(0.4, 0, 1, 0)
    dropdownButton.Position = UDim2.new(0.6, 0, 0, 0)
    dropdownButton.Text = "Select"
    dropdownButton.BackgroundColor3 = self.Theme.AccentColor
    dropdownButton.TextColor3 = self.Theme.TextColor
    dropdownButton.Font = Enum.Font.SourceSans
    dropdownButton.TextSize = 14

    local dropdownList = Instance.new("Frame", tab)
    dropdownList.Size = UDim2.new(0.9, 0, 0.2 * #options, 0)
    dropdownList.Position = UDim2.new(0.05, 0, dropdownFrame.Position.Y.Scale + 0.1, 0)
    dropdownList.Visible = false
    dropdownList.BackgroundColor3 = self.Theme.BackgroundColor

    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton", dropdownList)
        optionButton.Size = UDim2.new(1, 0, 1 / #options, 0)
        optionButton.Position = UDim2.new(0, 0, (i - 1) / #options, 0)
        optionButton.Text = option
        optionButton.BackgroundColor3 = self.Theme.ButtonColor
        optionButton.TextColor3 = self.Theme.TextColor
        optionButton.Font = Enum.Font.SourceSans
        optionButton.TextSize = 14

        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option
            dropdownList.Visible = false
            if callback then
                callback(option)
            end
        end)

        AddToRegistry(optionButton, {BackgroundColor3 = "ButtonColor", TextColor3 = "TextColor"})
    end

    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)

    AddToRegistry(dropdownFrame, {BackgroundColor3 = "ButtonColor"})
    AddToRegistry(dropdownLabel, {TextColor3 = "TextColor"})
    AddToRegistry(dropdownButton, {BackgroundColor3 = "AccentColor", TextColor3 = "TextColor"})
    AddToRegistry(dropdownList, {BackgroundColor3 = "BackgroundColor"})
    return dropdownFrame
end

return UILibrary
