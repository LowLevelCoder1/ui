-- Core UI Library
local UILibrary = {}

-- Theme Settings
UILibrary.Theme = {
    BackgroundColor = Color3.fromRGB(30, 30, 30),
    AccentColor = Color3.fromRGB(0, 162, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    ButtonColor = Color3.fromRGB(45, 45, 45),
    Font = Enum.Font.SourceSans,
}

-- Function: Create Window
function UILibrary:CreateWindow(title)
    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SexyUILibrary"
    screenGui.Parent = game.CoreGui
    screenGui.ResetOnSpawn = false

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = self.Theme.BackgroundColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Title Bar
    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = self.Theme.AccentColor
    titleBar.TextColor3 = self.Theme.TextColor
    titleBar.Font = self.Theme.Font
    titleBar.Text = title or "Sexy UI"
    titleBar.TextSize = 20
    titleBar.TextXAlignment = Enum.TextXAlignment.Center
    titleBar.Parent = mainFrame

    self.Windows[title] = mainFrame
    return mainFrame, titleBar
end

-- Function: Enable Dragging
function UILibrary:EnableDragging(frame, dragHandle)
    local dragging, dragStart, startPos
    local userInput = game:GetService("UserInputService")

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            userInput.InputChanged:Connect(function(input)
                if dragging then
                    update(input)
                end
            end)
        end
    end)
end

-- Function: Add Tabs
function UILibrary:AddTab(mainFrame, tabName)
    -- Tab Button
    local tabsContainer = mainFrame:FindFirstChild("TabsContainer")
    if not tabsContainer then
        tabsContainer = Instance.new("Frame")
        tabsContainer.Size = UDim2.new(1, 0, 0, 30)
        tabsContainer.BackgroundTransparency = 1
        tabsContainer.Parent = mainFrame
    end

    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 100, 0, 30)
    tabButton.Position = UDim2.new(#tabsContainer:GetChildren() * 0.25, 0, 0, 0)
    tabButton.BackgroundColor3 = self.Theme.ButtonColor
    tabButton.TextColor3 = self.Theme.TextColor
    tabButton.Font = self.Theme.Font
    tabButton.Text = tabName
    tabButton.Parent = tabsContainer

    -- Tab Content
    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 0.9, 0)
    tabContent.Position = UDim2.new(0, 0, 0.1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = #tabsContainer:GetChildren() == 1
    tabContent.Parent = mainFrame

    -- Tab Switching
    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(tabsContainer:GetChildren()) do
            if tab:IsA("Frame") then
                tab.Visible = false
            end
        end
        tabContent.Visible = true
    end)

    return tabContent
end

-- Function: Add Button
function UILibrary:AddButton(parentTab, buttonText, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.Position = UDim2.new(0.05, 0, #parentTab:GetChildren() * 0.035, 0)
    button.BackgroundColor3 = self.Theme.ButtonColor
    button.TextColor3 = self.Theme.TextColor
    button.Font = self.Theme.Font
    button.TextSize = 14
    button.Text = buttonText
    button.Parent = parentTab

    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return button
end

-- Function: Add Toggle
function UILibrary:AddToggle(parentTab, toggleText, defaultState, callback)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.9, 0, 0, 30)
    toggle.Position = UDim2.new(0.05, 0, #parentTab:GetChildren() * 0.035, 0)
    toggle.BackgroundColor3 = self.Theme.ButtonColor
    toggle.TextColor3 = self.Theme.TextColor
    toggle.Font = self.Theme.Font
    toggle.TextSize = 14
    toggle.Text = toggleText .. ": " .. (defaultState and "ON" or "OFF")
    toggle.Parent = parentTab

    local state = defaultState or false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = toggleText .. ": " .. (state and "ON" or "OFF")
        if callback then
            callback(state)
        end
    end)

    return toggle
end

-- Function: Add Slider
function UILibrary:AddSlider(parentTab, sliderText, min, max, default, callback)
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0.9, 0, 0, 30)
    sliderLabel.Position = UDim2.new(0.05, 0, #parentTab:GetChildren() * 0.045, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextColor3 = self.Theme.TextColor
    sliderLabel.Font = self.Theme.Font
    sliderLabel.TextSize = 14
    sliderLabel.Text = sliderText .. ": " .. tostring(default)
    sliderLabel.Parent = parentTab

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 10)
    sliderFrame.Position = UDim2.new(0.05, 0, sliderLabel.Position.Y.Scale + 0.04, 0)
    sliderFrame.BackgroundColor3 = self.Theme.ButtonColor
    sliderFrame.Parent = parentTab

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0.05, 0, 1, 0)
    sliderButton.BackgroundColor3 = self.Theme.AccentColor
    sliderButton.Text = ""
    sliderButton.Parent = sliderFrame

    local dragging = false
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relativeX)
            sliderLabel.Text = sliderText .. ": " .. value
            sliderButton.Position = UDim2.new(relativeX, 0, 0, 0)
            if callback then
                callback(value)
            end
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return sliderButton
end

-- Function: Add Dropdown
function UILibrary:AddDropdown(parentTab, dropdownText, options, callback)
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.9, 0, 0, 30)
    dropdown.Position = UDim2.new(0.05, 0, #parentTab:GetChildren() * 0.045, 0)
    dropdown.BackgroundColor3 = self.Theme.ButtonColor
    dropdown.TextColor3 = self.Theme.TextColor
    dropdown.Font = self.Theme.Font
    dropdown.TextSize = 14
    dropdown.Text = dropdownText .. ": Select"
    dropdown.Parent = parentTab

    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0.9, 0, 0, 30 * #options)
    dropdownFrame.Position = UDim2.new(0.05, 0, dropdown.Position.Y.Scale + 0.045, 0)
    dropdownFrame.BackgroundColor3 = self.Theme.BackgroundColor
    dropdownFrame.Visible = false
    dropdownFrame.Parent = parentTab

    dropdown.MouseButton1Click:Connect(function()
        dropdownFrame.Visible = not dropdownFrame.Visible
    end)

    for _, option in pairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.BackgroundColor3 = self.Theme.ButtonColor
        optionButton.TextColor3 = self.Theme.TextColor
        optionButton.Font = self.Theme.Font
        optionButton.TextSize = 14
        optionButton.Text = option
        optionButton.Parent = dropdownFrame

        optionButton.MouseButton1Click:Connect(function()
            dropdown.Text = dropdownText .. ": " .. option
            dropdownFrame.Visible = false
            if callback then
                callback(option)
            end
        end)
    end

    return dropdown
end

-- Function: Add Keybind
function UILibrary:AddKeybind(parentTab, keybindText, defaultKey, callback)
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Size = UDim2.new(0.9, 0, 0, 30)
    keybindLabel.Position = UDim2.new(0.05, 0, #parentTab:GetChildren() * 0.045, 0)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.TextColor3 = self.Theme.TextColor
    keybindLabel.Font = self.Theme.Font
    keybindLabel.TextSize = 14
    keybindLabel.Text = keybindText .. ": " .. tostring(defaultKey.Name)
    keybindLabel.Parent = parentTab

    local listening = false
    local currentKey = defaultKey or Enum.KeyCode.E

    keybindLabel.InputBegan:Connect(function(input)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            keybindLabel.Text = keybindText .. ": " .. tostring(currentKey.Name)
            listening = false
            if callback then
                callback(currentKey)
            end
        end
    end)

    keybindLabel.MouseButton1Click:Connect(function()
        listening = true
        keybindLabel.Text = keybindText .. ": Listening..."
    end)

    return keybindLabel
end

-- Function: Add Color Picker
function UILibrary:AddColorPicker(parentTab, pickerText, defaultColor, callback)
    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(0.9, 0, 0, 30)
    colorLabel.Position = UDim2.new(0.05, 0, #parentTab:GetChildren() * 0.045, 0)
    colorLabel.BackgroundTransparency = 1
    colorLabel.TextColor3 = self.Theme.TextColor
    colorLabel.Font = self.Theme.Font
    colorLabel.TextSize = 14
    colorLabel.Text = pickerText
    colorLabel.Parent = parentTab

    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    colorButton.Position = UDim2.new(0.85, 0, 0.1, 0)
    colorButton.BackgroundColor3 = defaultColor or self.Theme.AccentColor
    colorButton.Text = ""
    colorButton.Parent = colorLabel

    colorButton.MouseButton1Click:Connect(function()
        -- Example color picker logic
        local selectedColor = Color3.new(math.random(), math.random(), math.random())
        colorButton.BackgroundColor3 = selectedColor
        if callback then
            callback(selectedColor)
        end
    end)

    return colorButton
end

-- Function: Add Console
function UILibrary:AddConsole(parentTab, consoleTitle, options)
    options = options or {y = 200, readonly = true, source = "Lua"}
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Size = UDim2.new(0.9, 0, 0, options.y or 200)
    consoleFrame.Position = UDim2.new(0.05, 0, #parentTab:GetChildren() * 0.05, 0)
    consoleFrame.BackgroundColor3 = self.Theme.ButtonColor
    consoleFrame.Parent = parentTab

    local consoleText = Instance.new("TextBox")
    consoleText.Size = UDim2.new(1, 0, 1, 0)
    consoleText.BackgroundTransparency = 1
    consoleText.TextColor3 = self.Theme.TextColor
    consoleText.Font = self.Theme.Font
    consoleText.TextSize = 12
    consoleText.Text = ""
    consoleText.ClearTextOnFocus = not options.readonly
    consoleText.TextEditable = not options.readonly
    consoleText.MultiLine = true
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.TextYAlignment = Enum.TextYAlignment.Top
    consoleText.Parent = consoleFrame

    local function log(message)
        consoleText.Text = consoleText.Text .. "\n" .. message
        consoleText.CursorPosition = -1
    end

    return {Log = log, Get = function() return consoleText.Text end, Set = function(input) consoleText.Text = input end}
end

-- Function: Add Animation
function UILibrary:AnimateButton(button, hoverColor, clickColor)
    local originalColor = button.BackgroundColor3

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)

    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = clickColor
    end)

    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)
end

-- Function: Add Theme Support
function UILibrary:AddTheme(name, themeColors)
    self.Themes = self.Themes or {}
    self.Themes[name] = themeColors
end

-- Function: Apply Theme
function SexyUILibrary:ApplyTheme(theme)
    if type(theme) ~= "table" then
        warn("ApplyTheme: Theme must be a table!")
        return
    end

    for property, value in pairs(theme) do
        if self.Theme[property] ~= nil then
            self.Theme[property] = value
        else
            warn("Invalid theme property:", property)
        end
    end

    -- Update existing UI elements with the new theme
    for _, element in pairs(self.Elements) do
        if element.UpdateTheme then
            element:UpdateTheme(self.Theme)
        end
    end
end

-- Function: Add Tooltip
function UILibrary:AddTooltip(uiElement, text)
    local tooltip = Instance.new("TextLabel")
    tooltip.Size = UDim2.new(0, 150, 0, 30)
    tooltip.BackgroundColor3 = self.Theme.AccentColor
    tooltip.TextColor3 = self.Theme.TextColor
    tooltip.Font = self.Theme.Font
    tooltip.TextScaled = true
    tooltip.Text = text
    tooltip.Visible = false
    tooltip.Parent = self.Elements.Window

    uiElement.MouseEnter:Connect(function()
        tooltip.Position = UDim2.new(0, uiElement.AbsolutePosition.X + 10, 0, uiElement.AbsolutePosition.Y - 30)
        tooltip.Visible = true
    end)

    uiElement.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)
end

-- Function: Animate Tab Transition
function UILibrary:AnimateTabSwitch(oldTab, newTab)
    local duration = 0.25
    local tweenService = game:GetService("TweenService")

    if oldTab then
        local oldTween = tweenService:Create(oldTab, TweenInfo.new(duration), {Position = UDim2.new(-1, 0, 0, 0)})
        oldTween:Play()
        oldTween.Completed:Connect(function()
            oldTab.Visible = false
        end)
    end

    if newTab then
        newTab.Position = UDim2.new(1, 0, 0, 0)
        newTab.Visible = true
        local newTween = tweenService:Create(newTab, TweenInfo.new(duration), {Position = UDim2.new(0, 0, 0, 0)})
        newTween:Play()
    end
end

-- Function: Add Watermark
function UILibrary:AddWatermark(text)
    local watermark = Instance.new("TextLabel")
    watermark.Size = UDim2.new(0, 200, 0, 50)
    watermark.Position = UDim2.new(0.8, 0, 0, 0)
    watermark.BackgroundTransparency = 1
    watermark.TextColor3 = self.Theme.AccentColor
    watermark.Font = Enum.Font.SourceSansBold
    watermark.TextScaled = true
    watermark.Text = text
    watermark.Parent = self.Elements.Window

    return watermark
end

-- Function: Save Config
function UILibrary:SaveConfig(configName)
    local data = {}
    for key, value in pairs(self.Settings or {}) do
        data[key] = value
    end
    writefile(configName .. ".json", game:GetService("HttpService"):JSONEncode(data))
end

-- Function: Load Config
function UILibrary:LoadConfig(configName)
    if isfile(configName .. ".json") then
        local data = game:GetService("HttpService"):JSONDecode(readfile(configName .. ".json"))
        for key, value in pairs(data) do
            if self.Settings[key] then
                self.Settings[key](value)
            end
        end
    end
end

-- Store all active windows
UILibrary.Windows = {}

return UILibrary
