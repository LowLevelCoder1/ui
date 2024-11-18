local library = {}

local ui_options = {
    main_color = Color3.fromRGB(0, 162, 255),
    background_color = Color3.fromRGB(30, 30, 30),
    text_color = Color3.fromRGB(255, 255, 255),
    toggle_key = Enum.KeyCode.RightShift
}

local function create_instance(class, properties)
    local object = Instance.new(class)
    for property, value in pairs(properties) do
        object[property] = value
    end
    return object
end

function library:AddWindow(title)
    local window = {}
    local gui = create_instance("ScreenGui", {Parent = game:GetService("CoreGui")})
    local frame = create_instance("Frame", {
        Parent = gui,
        Size = UDim2.new(0, 400, 0, 300),
        BackgroundColor3 = ui_options.background_color,
        BorderSizePixel = 0,
        Draggable = true,
        Active = true,
        Position = UDim2.new(0.5, -200, 0.5, -150)
    })
    create_instance("UICorner", {Parent = frame})

    local title_bar = create_instance("Frame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = ui_options.main_color,
        BorderSizePixel = 0
    })
    create_instance("UICorner", {Parent = title_bar})

    create_instance("TextLabel", {
        Parent = title_bar,
        Size = UDim2.new(1, 0, 1, 0),
        Text = title or "Window",
        TextColor3 = ui_options.text_color,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 16
    })

    local container = create_instance("ScrollingFrame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarImageColor3 = ui_options.text_color
    })

    create_instance("UIListLayout", {Parent = container, Padding = UDim.new(0, 5)})

    function window:AddTab(title)
        local tab = {}
        local tab_button = create_instance("TextButton", {
            Parent = container,
            Text = title or "Tab",
            BackgroundColor3 = ui_options.background_color,
            TextColor3 = ui_options.text_color,
            Size = UDim2.new(1, -10, 0, 30),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            BorderSizePixel = 0
        })
        create_instance("UICorner", {Parent = tab_button})

        local tab_container = create_instance("Frame", {
            Parent = container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 200)
        })
        create_instance("UIListLayout", {Parent = tab_container, Padding = UDim.new(0, 5)})

        function tab:AddButton(title, callback)
            local button = create_instance("TextButton", {
                Parent = tab_container,
                Text = title or "Button",
                BackgroundColor3 = ui_options.background_color,
                TextColor3 = ui_options.text_color,
                Size = UDim2.new(1, -10, 0, 30),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                BorderSizePixel = 0
            })
            create_instance("UICorner", {Parent = button})
            button.MouseButton1Click:Connect(callback)
        end

        function tab:AddSwitch(title, callback)
            local switch = {}
            local button = create_instance("TextButton", {
                Parent = tab_container,
                Text = title or "Switch",
                BackgroundColor3 = ui_options.background_color,
                TextColor3 = ui_options.text_color,
                Size = UDim2.new(1, -10, 0, 30),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                BorderSizePixel = 0
            })
            create_instance("UICorner", {Parent = button})

            local toggled = false

            function switch:Set(state)
                toggled = state
                button.Text = title .. (toggled and " [ON]" or " [OFF]")
                callback(toggled)
            end

            button.MouseButton1Click:Connect(function()
                switch:Set(not toggled)
            end)

            return switch
        end

        function tab:AddSlider(title, callback, options)
            local slider = {}
            options = options or {min = 0, max = 100}
            local value = options.min

            local frame = create_instance("Frame", {
                Parent = tab_container,
                BackgroundColor3 = ui_options.background_color,
                Size = UDim2.new(1, -10, 0, 50),
                BorderSizePixel = 0
            })
            create_instance("UICorner", {Parent = frame})

            local label = create_instance("TextLabel", {
                Parent = frame,
                Text = title or "Slider",
                BackgroundTransparency = 1,
                TextColor3 = ui_options.text_color,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                TextSize = 14
            })

            local slider_bar = create_instance("Frame", {
                Parent = frame,
                Size = UDim2.new(1, -20, 0, 10),
                Position = UDim2.new(0, 10, 0, 30),
                BackgroundColor3 = ui_options.main_color,
                BorderSizePixel = 0
            })
            create_instance("UICorner", {Parent = slider_bar})

            local slider_knob = create_instance("Frame", {
                Parent = slider_bar,
                Size = UDim2.new(0, 10, 0, 10),
                BackgroundColor3 = ui_options.text_color,
                BorderSizePixel = 0
            })
            create_instance("UICorner", {Parent = slider_knob})

            local function update_slider(input_position)
                local scale = math.clamp((input_position.X - slider_bar.AbsolutePosition.X) / slider_bar.AbsoluteSize.X, 0, 1)
                slider_knob.Position = UDim2.new(scale, -5, 0, 0)
                value = math.floor(options.min + scale * (options.max - options.min))
                label.Text = title .. ": " .. value
                callback(value)
            end

            slider_bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    update_slider(input.Position)
                    local move_connection
                    move_connection = game:GetService("UserInputService").InputChanged:Connect(function(movement)
                        if movement.UserInputType == Enum.UserInputType.MouseMovement then
                            update_slider(movement.Position)
                        end
                    end)
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            move_connection:Disconnect()
                        end
                    end)
                end
            end)

            function slider:Set(new_value)
                value = math.clamp(new_value, options.min, options.max)
                local scale = (value - options.min) / (options.max - options.min)
                slider_knob.Position = UDim2.new(scale, -5, 0, 0)
                label.Text = title .. ": " .. value
                callback(value)
            end

            slider:Set(options.min)
            return slider
        end

        return tab
    end

    return window
end

return library
