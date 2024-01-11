--Server

function leadBoard(player)
    local lb, cash = Instance.new('Folder'), Instance.new('IntValue')
    cash.Parent, cash.Value = lb, 1000
    lb.Name, lb.Parent = 'leaderstats', player
end

-- Client

local staffEvent = Instance.new('RemoteEvent')

local hiringGui = {}
hiringGui.__index = hiringGui

local STAFF_SIZE = 3

function hiringGui.New()
    local self = setmetatable({}, hiringGui)
    self.Gui = self:CreateGui()
    self.Player = game.Players.LocalPlayer
    self.CurrentStaff = { cooks = {}, weithers = {}, hosteses = {}, admins = {}, couriers = {}}
    return self
end

function hiringGui:CreateGui()
    local scrGui, mainScreen = Instance.new('ScreenGui'), Instance.new('Frame')
    mainScreen.Position, mainScreen.Size, mainScreen.AnchorPoint, mainScreen.Visible = UDim2.fromScale(.5, .5), UDim2.fromScale(.7, .6), Vector2.new(.5,.5), false
    local exitButton = Instance.new('TextButton')
    exitButton.Text, exitButton.Size, exitButton.AnchorPoint = 'exit', UDim2.fromScale(.15, .1), Vector2.new(0, 1)

    local verticalMenu, staffMenu = Instance.new('Frame'), Instance.new('Frame')
    verticalMenu.Parent, staffMenu.Parent = mainScreen, mainScreen
    -- verticalMenu.Position, verticalMenu.Size = 

    scrGui.Parent = self.Player.PlayerGui
    return {verticalMenu = verticalMenu, staffMenu = staffMenu}
end

function hiringGui:Init()
    self:SetVerticalMenu(self.Gui.verticalMenu)
end

function hiringGui:SetVerticalMenu(verticalMenu)
    local names = { 'cooks', 'weithers', 'hosteses', 'admins', 'couriers'}
    for i = 0, 4 do
        local button = Instance.new('TextButton')
        button.Text = names[i]
        button.Size, button.Position = UDim2.fromScale(1, .2), UDim2.fromScale(0, .01 + .2 * i)
        button.Activated:Connect(function()
            self:SetStaffFrame(names[i])
        end)
    end
end

function hiringGui:SetControlPanel(currentStaff: table)
    local panelFolder = Instance.new('Folder')
    local fireButton, breakButton = Instance.new('TextButton'), Instance.new('TextButton')
    fireButton.AnchorPoint, fireButton.Size = Vector2.new(1, 0), UDim2.fromScale(.2, 1)
    breakButton.AnchorPoint, breakButton.Position, breakButton.Size = Vector2.new(1, 0), UDim2.fromScale(.2, 0), UDim2.fromScale(.2, 1)
    fireButton.Text, breakButton.Text = 'fire', 'break'

    fireButton.Activated:Connect(function(inputObject, clickCount)
        if self.CurrentStaff[currentStaff._type][currentStaff.index] then self.CurrentStaff[currentStaff._type][currentStaff.index] = nil end
        panelFolder:Destroy()
    end)

    local bool = false
    breakButton.Activated:Connect(function(inputObject, clickCount)
        bool = not bool
        staffEvent:FireServer(bool)
        breakButton.BackgroundColor3 = bool and Color3.new(1,0,0) or Color3.new(0, 0, 1)
    end)
end

function hiringGui:SetStaffMenu(staffType)
    self.Gui.staffMenu:ClearAllChildren()
    for i = 0, 4 do
        local frame = Instance.new('Frame')
        frame.Size, frame.Position = UDim2.fromScale(1, .2), UDim2.fromScale(0, .01 + .2 * i)
        local staffIcon, staffProperty = Instance.new('ImageButton'), Instance.new('TextLabel')
        staffIcon.Size = UDim2.fromScale(.2, 1)
        staffProperty.Position, staffProperty.Size = UDim2.fromScale(.2, 0), UDim2.fromScale(.8, 1)

        -- staffIcon.Image
        -- staffProperty.Text
        
        if self.CurrentStaff[staffType][tostring(i)] then self:SetControlPanel({ _type = staffType, index = tostring(i)}) end

        staffIcon.Activated:Connect(function(inputObject, clickCount)
            if #self.CurrentStaff[staffType] <= STAFF_SIZE and not self.CurrentStaff[staffType][tostring(i)] then
                self.CurrentStaff[staffType][tostring(i)] = {n = 'aaa', level = 2, _type = staffType}
            end
        end)
    end
end