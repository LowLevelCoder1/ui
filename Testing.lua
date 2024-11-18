local UILibrary = {}

-- Main theme configuration
UILibrary.Theme = {
    BackgroundColor = Color3.fromRGB(25, 25, 25),
    TabBackgroundColor = Color3.fromRGB(30, 30, 30),
    AccentColor = Color3.fromRGB(0, 120, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    ButtonColor = Color3.fromRGB(40, 40, 40),
    HoverColor = Color3.fromRGB(50, 50, 50),
}

-- Function to create a new UI window
function UILibrary:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local WindowFrame = Instance.new("Frame")
    WindowFrame.Size = UDim2.new(0.4, 0, 0.5, 0)
    WindowFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
    WindowFrame.BackgroundColor3 = self.Theme.BackgroundColor
    WindowFrame.BorderSizePixel = 0
    WindowFrame.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0.1, 0)
    TitleBar.BackgroundColor3 = self.Theme.AccentColor
    TitleBar.TextColor3 = self.Theme.TextColor
    TitleBar.Font = Enum.Font.SourceSansBold
    TitleBar.TextScaled = true
    TitleBar.Text = title or "My Custom UI"
    TitleBar.Parent = WindowFrame

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0.9, 0)
    TabContainer.Position = UDim2.new(0, 0, 0.1, 0)
    TabContainer.BackgroundColor3 = self.Theme.TabBackgroundColor
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = WindowFrame

    return {
        Window = WindowFrame,
        TitleBar = TitleBar,
        TabContainer = TabContainer,
        Tabs = {},
    }
end

function UILibrary:AddTab(window, tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Text = tabName
    TabButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    TabButton.Position = UDim2.new(#window.Tabs * 0.2, 0, 0, 0)
    TabButton.BackgroundColor3 = self.Theme.ButtonColor
    TabButton.TextColor3 = self.Theme.TextColor
    TabButton.Font = Enum.Font.SourceSansBold
    TabButton.Parent = window.TabContainer

    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 0.9, 0)
    TabContent.Position = UDim2.new(0, 0, 0.1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = #window.Tabs == 0 -- Show the first tab by default
    TabContent.Parent = window.TabContainer

    -- Tab button interaction
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(window.Tabs) do
            tab.Content.Visible = false
        end
        TabContent.Visible = true
    end)

    table.insert(window.Tabs, {Button = TabButton, Content = TabContent})

    return TabContent
end

function UILibrary:AddToggle(parent, toggleName, defaultState, callback)
    local Toggle = Instance.new("TextButton")
    Toggle.Text = toggleName .. ": " .. (defaultState and "ON" or "OFF")
    Toggle.Size = UDim2.new(0.9, 0, 0.1, 0)
    Toggle.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    Toggle.BackgroundColor3 = self.Theme.ButtonColor
    Toggle.TextColor3 = self.Theme.TextColor
    Toggle.Font = Enum.Font.SourceSans
    Toggle.Parent = parent

    local state = defaultState
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = toggleName .. ": " .. (state and "ON" or "OFF")
        if callback then
            callback(state)
        end
    end)

    return Toggle
end

function UILibrary:AddDropdown(parent, dropdownName, options, callback)
    local Dropdown = Instance.new("TextButton")
    Dropdown.Text = dropdownName
    Dropdown.Size = UDim2.new(0.9, 0, 0.1, 0)
    Dropdown.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    Dropdown.BackgroundColor3 = self.Theme.ButtonColor
    Dropdown.TextColor3 = self.Theme.TextColor
    Dropdown.Font = Enum.Font.SourceSans
    Dropdown.Parent = parent

    local expanded = false
    local OptionButtons = {}

    Dropdown.MouseButton1Click:Connect(function()
        expanded = not expanded
        for _, button in pairs(OptionButtons) do
            button.Visible = expanded
        end
    end)

    for i, option in pairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Text = option
        OptionButton.Size = UDim2.new(0.9, 0, 0.1, 0)
        OptionButton.Position = UDim2.new(0.05, 0, Dropdown.Position.Y.Scale + i * 0.12, 0)
        OptionButton.BackgroundColor3 = self.Theme.ButtonColor
        OptionButton.TextColor3 = self.Theme.TextColor
        OptionButton.Font = Enum.Font.SourceSans
        OptionButton.Parent = parent
        OptionButton.Visible = false

        OptionButton.MouseButton1Click:Connect(function()
            Dropdown.Text = dropdownName .. ": " .. option
            expanded = false
            for _, button in pairs(OptionButtons) do
                button.Visible = false
            end
            if callback then
                callback(option)
            end
        end)

        table.insert(OptionButtons, OptionButton)
    end

    return Dropdown
end

function UILibrary:AddKeybind(parent, keybindName, defaultKey, callback)
    local Keybind = Instance.new("TextButton")
    Keybind.Text = keybindName .. ": " .. defaultKey.Name
    Keybind.Size = UDim2.new(0.9, 0, 0.1, 0)
    Keybind.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    Keybind.BackgroundColor3 = self.Theme.ButtonColor
    Keybind.TextColor3 = self.Theme.TextColor
    Keybind.Font = Enum.Font.SourceSans
    Keybind.Parent = parent

    local key = defaultKey

    Keybind.MouseButton1Click:Connect(function()
        Keybind.Text = keybindName .. ": Press a Key..."
        local connection
        connection = game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                Keybind.Text = keybindName .. ": " .. key.Name
                connection:Disconnect()
                if callback then
                    callback(key)
                end
            end
        end)
    end)

    return Keybind
end

function UILibrary:AddColorPicker(parent, colorPickerName, defaultColor, callback)
    local ColorPickerButton = Instance.new("TextButton")
    ColorPickerButton.Text = colorPickerName
    ColorPickerButton.Size = UDim2.new(0.9, 0, 0.1, 0)
    ColorPickerButton.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    ColorPickerButton.BackgroundColor3 = defaultColor
    ColorPickerButton.TextColor3 = self.Theme.TextColor
    ColorPickerButton.Font = Enum.Font.SourceSans
    ColorPickerButton.Parent = parent

    local function OpenColorPicker()
        local PickerFrame = Instance.new("Frame")
        PickerFrame.Size = UDim2.new(0.4, 0, 0.4, 0)
        PickerFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
        PickerFrame.BackgroundColor3 = self.Theme.BackgroundColor
        PickerFrame.BorderSizePixel = 0
        PickerFrame.Parent = parent

        local ColorPicker = Instance.new("ImageButton")
        ColorPicker.Image = "rbxassetid://6523286724" -- A color gradient asset
        ColorPicker.Size = UDim2.new(0.8, 0, 0.8, 0)
        ColorPicker.Position = UDim2.new(0.1, 0, 0.1, 0)
        ColorPicker.BackgroundTransparency = 1
        ColorPicker.Parent = PickerFrame

        ColorPicker.MouseButton1Click:Connect(function()
            local input = game:GetService("UserInputService").InputChanged:Wait()
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouseX, mouseY = game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y
                local relativeX = math.clamp((mouseX - ColorPicker.AbsolutePosition.X) / ColorPicker.AbsoluteSize.X, 0, 1)
                local relativeY = math.clamp((mouseY - ColorPicker.AbsolutePosition.Y) / ColorPicker.AbsoluteSize.Y, 0, 1)
                local selectedColor = Color3.fromHSV(relativeX, 1 - relativeY, 1)
                ColorPickerButton.BackgroundColor3 = selectedColor
                if callback then
                    callback(selectedColor)
                end
                PickerFrame:Destroy()
            end
        end)
    end

    ColorPickerButton.MouseButton1Click:Connect(OpenColorPicker)

    return ColorPickerButton
end

function UILibrary:AddConsole(parent, consoleName, options)
    local ConsoleFrame = Instance.new("Frame")
    ConsoleFrame.Size = UDim2.new(0.9, 0, options.y or 0.3, 0)
    ConsoleFrame.Position = UDim2.new(0.05, 0, #parent:GetChildren() * 0.12, 0)
    ConsoleFrame.BackgroundColor3 = self.Theme.ButtonColor
    ConsoleFrame.BorderSizePixel = 0
    ConsoleFrame.Parent = parent

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -10, 1, -10)
    TextBox.Position = UDim2.new(0, 5, 0, 5)
    TextBox.BackgroundTransparency = options.readonly and 1 or 0
    TextBox.TextColor3 = self.Theme.TextColor
    TextBox.Font = Enum.Font.Code
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.TextYAlignment = Enum.TextYAlignment.Top
    TextBox.ClearTextOnFocus = false
    TextBox.MultiLine = true
    TextBox.Text = ""
    TextBox.TextScaled = false
    TextBox.Parent = ConsoleFrame

    local function Log(message)
        TextBox.Text = TextBox.Text .. "\n" .. message
        TextBox.CursorPosition = #TextBox.Text
    end

    local function Set(text)
        TextBox.Text = text
    end

    local function Get()
        return TextBox.Text
    end

    return {
        Log = Log,
        Set = Set,
        Get = Get
    }

end
function UILibrary:FormatWindows()
    local xOffset = 0
    for _, tab in ipairs(self.Elements.Tabs) do
        tab.Button.Position = UDim2.new(0, xOffset, 0, 0)
        xOffset = xOffset + tab.Button.Size.X.Offset + 10
    end
end

function UILibrary:Unload()
    if self.Elements.Window then
        self.Elements.Window:Destroy()
    end
end
