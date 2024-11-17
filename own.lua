local OwlLib = {Content = {}}
local config = {}

local placeID = tostring(game.PlaceId)
local httpService = game:GetService("HttpService")
local inputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- Default asset IDs
local DEFAULT_ASSETS = {
    PopupGui = "rbxassetid://4743303040",
    OwlLibGui = "rbxassetid://4530443679",
    BodyFrame = "rbxassetid://4531111462",
    TabButton = "rbxassetid://4530456835",
    ToggleButton = "rbxassetid://4531129509",
    Slider = "rbxassetid://4531326550",
    Textbox = "rbxassetid://4531463561",
    KeyBind = "rbxassetid://4531229816",
    Dropdown = "rbxassetid://4531687341",
    DropdownItem = "rbxassetid://4531683854",
    ColorPicker = "rbxassetid://4531551348",
}
local assets = setmetatable({}, {__index = DEFAULT_ASSETS})

-- Determine GUI parent (CoreGui or PlayerGui)
local function getParent()
    local success, player = pcall(function() return game:GetService("Players").LocalPlayer end)
    return success and player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
end
local parentGui = getParent()

-- Configuration handling
pcall(function()
    config = httpService:JSONDecode(readfile(placeID .. ".txt"))
end)

local function saveConfig()
    local success, err = pcall(function()
        writefile(placeID .. ".txt", httpService:JSONEncode(config))
    end)
    if not success then
        warn("Failed to save config: " .. tostring(err))
    end
end

-- Load assets dynamically
function OwlLib:LoadAssets(customAssets)
    if customAssets then
        for key, value in pairs(customAssets) do
            assets[key] = value
        end
    end
end

-- Initialize GUI
local popupGui = game:GetObjects(assets.PopupGui)[1]
popupGui.Parent = parentGui
popupGui.Name = httpService:GenerateGUID(false)

local owlLibGui = game:GetObjects(assets.OwlLibGui)[1]
owlLibGui.Parent = parentGui
owlLibGui.Name = httpService:GenerateGUID(false)
local mainFrame = owlLibGui.mainFrame

-- Draggable UI functionality
local dragging = false
local startPos
local draggableStart

mainFrame.topBarFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        draggableStart = input.Position
        startPos = mainFrame.AbsolutePosition
    end
end)

mainFrame.topBarFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

inputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        mainFrame.Position = UDim2.new(0, startPos.X + (input.Position.X - draggableStart.X), 0, startPos.Y + (input.Position.Y - draggableStart.Y))
    end
end)

-- Keybind toggling
local toggleKey = Enum.KeyCode.P
function OwlLib:SetToggleKey(key)
    toggleKey = key or Enum.KeyCode.P
end

inputService.InputBegan:Connect(function(input, onGui)
    if not onGui and input.KeyCode == toggleKey then
        owlLibGui.Enabled = not owlLibGui.Enabled
    end
end)

-- Close Button Functionality
mainFrame.topBarFrame.exitBtn.MouseButton1Click:Connect(function()
    owlLibGui:Destroy()
end)

-- Universal UI Components
function OwlLib.Content:Resize(scrollingFrame)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, (#scrollingFrame:GetChildren() - 1) * 36)
end

function OwlLib.Content:Ripple(btn)
    spawn(function()
        local ripple = Instance.new("ImageLabel", btn)
        ripple.Image = "rbxassetid://2708891598"
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.ImageTransparency = 0.8
        ripple.BackgroundTransparency = 1
        ripple:TweenSize(UDim2.new(2, 0, 2, 0), "Out", "Quad", 0.5, true)
        wait(0.5)
        ripple:Destroy()
    end)
end

function OwlLib.Content:initBtnEffect(btn)
    local hoverTween = tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85})
    local leaveTween = tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1})

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            hoverTween:Play()
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            leaveTween:Play()
        end
    end)
end

function OwlLib:new(title)
    local self = setmetatable({}, {__index = self.Content})

    -- Create a body frame for the new category
    self.bodyFrame = game:GetObjects(assets.BodyFrame)[1]
    self.bodyFrame.Parent = mainFrame
    self.bodyFrame.Name = title .. "BodyFrame"
    self.bodyFrame.Visible = false

    -- Create a tab button for the new category
    local tabBtn = game:GetObjects(assets.TabButton)[1]
    tabBtn.Parent = mainFrame.tabsFrame
    tabBtn.tabLabel.Text = title

    tabBtn.MouseButton1Click:Connect(function()
        for _, v in ipairs(mainFrame:GetChildren()) do
            if v.Name:find("BodyFrame") then
                v.Visible = false
            end
        end
        for _, v in ipairs(mainFrame.tabsFrame:GetChildren()) do
            if v:IsA("ImageButton") then
                v.ImageColor3 = Color3.fromRGB(50, 50, 50)
            end
        end
        tabBtn.ImageColor3 = Color3.fromRGB(30, 30, 30)
        self.bodyFrame.Visible = true
    end)

    return self
end

function OwlLib.Content:newButton(title, callback)
    self:Resize(self.bodyFrame)
    local btn = game:GetObjects(assets.ToggleButton)[1]
    btn.Parent = self.bodyFrame
    btn.titleLabel.Text = title

    btn.MouseButton1Click:Connect(function()
        self:Ripple(btn)
        callback()
    end)

    self:initBtnEffect(btn)
    return btn
end

function OwlLib.Content:newSlider(title, callback, min, max, start)
    self:Resize(self.bodyFrame)
    local slider = game:GetObjects(assets.Slider)[1]
    slider.Parent = self.bodyFrame
    slider.titleLabel.Text = title

    -- Slider functionality
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            callback(slider.valueLabel.Text)
        end
    end)

    return slider
end

function OwlLib.Content:newDropdown(title, callback, list, noCallbackOnStart)
    self:Resize(self.bodyFrame)
    local dropdown = game:GetObjects(assets.Dropdown)[1]
    dropdown.Parent = self.bodyFrame
    dropdown.titleLabel.Text = title

    local arrowLabel = dropdown.arrowLabel
    local bodyFrame = dropdown.bodyFrame

    local function refresh(list)
        for _, v in ipairs(bodyFrame:GetChildren()) do
            if not v:IsA("UIListLayout") then
                v:Destroy()
            end
        end
        for _, item in ipairs(list) do
            local btn = game:GetObjects(assets.DropdownItem)[1]
            btn.Parent = bodyFrame
            btn.Text = item
            btn.MouseButton1Click:Connect(function()
                callback(item)
                bodyFrame.Visible = false
                dropdown.bodyFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                arrowLabel.Rotation = 0
            end)
        end
    end

    refresh(list)

    dropdown.MouseButton1Click:Connect(function()
        bodyFrame.Visible = not bodyFrame.Visible
        arrowLabel.Rotation = bodyFrame.Visible and 180 or 0
    end)

    return {
        Refresh = function(_, newList)
            refresh(newList)
        end
    }
end

function OwlLib.Content:newTextbox(title, callback, presetText, noCallbackOnStart)
    self:Resize(self.bodyFrame)
    local textbox = game:GetObjects(assets.Textbox)[1]
    textbox.Parent = self.bodyFrame
    textbox.titleLabel.Text = title
    textbox.inputBox.Text = presetText or ""

    if not noCallbackOnStart and presetText then
        callback(presetText)
    end

    textbox.inputBox.FocusLost:Connect(function()
        callback(textbox.inputBox.Text)
    end)

    return textbox
end

function OwlLib.Content:newKeybind(title, callback, presetKey)
    self:Resize(self.bodyFrame)
    local keybind = game:GetObjects(assets.KeyBind)[1]
    keybind.Parent = self.bodyFrame
    keybind.titleLabel.Text = title
    keybind.bindBtn.Text = presetKey and presetKey.Name or "None"

    local listening = false
    local boundKey = presetKey

    keybind.bindBtn.MouseButton1Click:Connect(function()
        keybind.bindBtn.Text = "..."
        listening = true
    end)

    inputService.InputBegan:Connect(function(input)
        if listening then
            boundKey = input.KeyCode
            keybind.bindBtn.Text = input.KeyCode.Name
            callback(boundKey)
            listening = false
        elseif input.KeyCode == boundKey then
            callback()
        end
    end)

    return keybind
end

function OwlLib.Content:newColorPicker(title, callback, presetColor)
    self:Resize(self.bodyFrame)
    local colorPicker = game:GetObjects(assets.ColorPicker)[1]
    colorPicker.Parent = self.bodyFrame
    colorPicker.titleLabel.Text = title

    local colorFrame = colorPicker.colorFrame
    colorFrame.BackgroundColor3 = presetColor or Color3.fromRGB(255, 255, 255)

    local rainbowMode = false
    local function updateColor(color)
        if not rainbowMode then
            colorFrame.BackgroundColor3 = color
            callback(color)
        end
    end

    colorPicker.colorFrame.MouseButton1Click:Connect(function()
        rainbowMode = not rainbowMode
        if rainbowMode then
            while rainbowMode do
                for hue = 0, 1, 0.01 do
                    updateColor(Color3.fromHSV(hue, 1, 1))
                    wait(0.05)
                end
            end
        end
    end)

    return colorPicker
end


return OwlLib
