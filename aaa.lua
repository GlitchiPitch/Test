local STUFF = {
    'tomato',
    'brokkoli'
}

-- client

local foodGui = {}; foodGui.__index = foodGui
function foodGui.New()
    local self = setmetatable({}< foodGui)
    self.Gui = self:CreateGui()
    return self
end

function  foodGui:CreateGui()
    local screen, frame = Instance.new('ScreenGui'), Instance.new('Frame')
    frame.Size, frame.Position, frame.AnchorPoint, frame.Parent = UDim2.fromScale(.7, .6), UDim2.fromScale(.5, .5), Vector2.new(.5,.5), screen

    local foodMenu = Instance.new('ScrollingFrame')
	foodMenu.Size, foodMenu.Parent = UDim2.fromScale(1, .8), frame

    local buttonPosX = 0
	local buttonPosY = 0

	for _, food in pairs(STUFF) do
		local button = Instance.new("TextButton")
		button.Parent, button.Size = foodMenu, UDim2.fromScale(.2,.2)

		if buttonPosX < 1 then
			button.Position = UDim2.new(buttonPosX, 0, buttonPosY, 0)
			buttonPosX += button.Size.X.Scale
		else
			buttonPosX = 0
			buttonPosY += button.Size.Y.Scale
			button.Position = UDim2.new(buttonPosX, 0, buttonPosY, 0)
			buttonPosX += button.Size.X.Scale
		end
    end

    local propertyFrame = Instance.new("Frame")
	propertyFrame.BackgroundTransparency, propertyFrame.Parent = 1, frame
    propertyFrame.Position, propertyFrame.Size = UDim2.fromScale(1, 1), UDim2.fromScale(1, .2)

    local function createLabel(sign, pos)
		local label = Instance.new("TextLabel")
		label.Position, label.Size, label.Parent = pos, UDim2.fromScale(.3, 1), propertyFrame
	end

	local costLabel = createLabel("Cost", UDim2.fromScale(0, 0))
	costLabel.Text = 0 .. "$"
	costLabel.Size = UDim2.fromScale(.2, 1)

    local exitButton, buyButton, dropButton = Instance.new('TextButton'), Instance.new('TextButton'), Instance.new('TextButton')
    exitButton.Parent, buyButton.Parent, dropButton.Parent = frame, propertyFrame, propertyFrame

    exitButton.AnchorPoint = Vector2.new(0, 1)
    buyButton.AnchorPoint, buyButton.Position = Vector2.new(1, 1), UDim2.fromScale(1, 1)

    local picture, nameLabel = Instance.new('ImageLabel'), Instance.new('TextLabel')
    local freezeVolumeLabel = Instance.new('TextLabel')

    return {
            frame = frame,
            exitButton = exitButton, buyButton = buyButton, dropButton = dropButton,
            propertyFrame = {costLabel = costLabel, picture = picture, nameLabel = nameLabel}
        }

end

function foodGui:SetupGui()
    self.Gui.exitButton.Activated:Connect(function() self.Gui.frame.Visible = false end)
    for _, button in pairs(self.Gui.propertyFrame:GetChildren()) do
        button.Activated:Connect(function()
            local propFrame = self.Gui.propertyFrame
            -- propFrame.costLabel
            -- propFrame.picture
            -- propFrame.nameLabel
        end)
    end
    
    self.Gui.buyButton.Activated:Connect(function()
        
    end)

    self.Gui.dropButton.Activated:Connect(function()
        
    end)


end