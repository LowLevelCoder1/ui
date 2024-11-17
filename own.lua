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
    Dropdown = "rbxassetid://4531687341",
    DropdownItem = "rbxassetid://4531683854",
}
local assets = setmetatable({}, {__index = DEFAULT_ASSETS})

-- Determine GUI parent (CoreGui or PlayerGui)
local function getParent()
    local success, player = pcall(function() return game:GetService("Players").LocalPlayer end)
    return success and player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
end
local parentGui = getParent()

-- Load assets dynamically
function OwlLib:LoadAssets(customAssets)
    if customAssets then
        for key, value in pairs(customAssets) do
            assets[key] = value
        end
    end
end

-- Initialize GUI
local owlLibGui = game:GetObjects(assets.OwlLibGui)[1]
owlLibGui.Parent = parentGui
owlLibGui.Name = httpService:GenerateGUID(false)
local mainFrame = owlLibGui.mainFrame
local tabsFrame = mainFrame.tabsFrame
local minimized = false -- State for minimize animation

-- Animations for open/close
local function toggleVisibility(frame, visible)
    if visible then
        frame.Visible = true
        frame:TweenSize(UDim2.new(0, 400, 0, 300), "Out", "Quad", 0.3, true) -- Expand
    else
        frame:TweenSize(UDim2.new(0, 400, 0, 0), "Out", "Quad", 0.3, true) -- Collapse
        wait(0.3)
        frame.Visible = false
    end
end

-- Prevent UI Destruction on Spawn
mainFrame.ResetOnSpawn = false

-- Minimize/Expand Functionality
mainFrame.topBarFrame.miniBtn.MouseButton1Click:Connect(function()
    if not minimized then
        mainFrame:TweenSize(UDim2.new(0, 400, 0, 30), "Out", "Quad", 0.3, true)
    else
        mainFrame:TweenSize(UDim2.new(0, 400, 0, 300), "Out", "Quad", 0.3, true)
    end
    minimized = not minimized
end)

-- Close Button Functionality
mainFrame.topBarFrame.exitBtn.MouseButton1Click:Connect(function()
    toggleVisibility(mainFrame, false)
    wait(0.3)
    owlLibGui:Destroy()
end)

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

-- GUI Tabs Functionality
local activeTab = nil

function OwlLib:newTab(title)
    local self = setmetatable({}, {__index = self.Content})
    self.bodyFrame = game:GetObjects(assets.BodyFrame)[1]
    self.bodyFrame.Parent = mainFrame
    self.bodyFrame.Name = title .. "BodyFrame"
    self.bodyFrame.Visible = false

    local tabBtn = game:GetObjects(assets.TabButton)[1]
    tabBtn.Parent = tabsFrame
    tabBtn.tabLabel.Text = title

    tabBtn.MouseButton1Click:Connect(function()
        if activeTab then
            activeTab.bodyFrame.Visible = false
        end
        activeTab = self
        self.bodyFrame.Visible = true

        for _, button in ipairs(tabsFrame:GetChildren()) do
            if button:IsA("ImageButton") then
                button.ImageColor3 = Color3.fromRGB(50, 50, 50)
            end
        end
        tabBtn.ImageColor3 = Color3.fromRGB(30, 30, 30)
    end)

    -- Default to the first tab as active
    if not activeTab then
        activeTab = self
        self.bodyFrame.Visible = true
        tabBtn.ImageColor3 = Color3.fromRGB(30, 30, 30)
    end

    return self
end

-- Create Sliders
function OwlLib.Content:newSlider(title, callback, min, max, defaultValue)
    local slider = game:GetObjects(assets.Slider)[1]
    assert(slider.sliderFrame, "SliderFrame is missing from slider object.")
    
    slider.Parent = self.bodyFrame
    slider.titleLabel.Text = title

    local dragging = false
    local sliderValue = defaultValue or min

    local function updateSlider(input)
        local percent = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        sliderValue = math.floor((max - min) * percent + min)
        slider.valueLabel.Text = tostring(sliderValue)
        callback(sliderValue)
    end

    slider.sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)

    slider.sliderFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    slider.sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return slider
end

return OwlLib
