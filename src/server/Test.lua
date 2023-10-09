local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local Teams = game:GetService("Teams")

-- Players.CharacterAutoLoads = false
-- респавн и gui можно было настроить по-другому без повторной подгрузки

local Crossbow = game:GetService('InsertService'):LoadAsset(4842204072).Crossbow
Crossbow.Parent = StarterPack

local baseTemplate = game:GetService('ServerStorage'):FindFirstChild('baseTemplate')


function SetupGui()
    local gui, text = Instance.new('ScreenGui'), Instance.new('TextLabel')
    gui.Name = 'MainGui'
    text.Size, text.Position = UDim2.fromScale(.5,.5), UDim2.fromScale(.5,.5)
    text.AnchorPoint = Vector2.new(.5,.5)
    text.Visible = false
    text.TextScaled = true
    text.TextStrokeTransparency = 0
    text.TextColor3 = Color3.new(1,1,1)
    text.BackgroundTransparency = 1
    gui.Parent, text.Parent = StarterGui, gui
end

SetupGui()

local redBase, blueBase = baseTemplate:Clone(), baseTemplate:Clone()
for _, o in pairs(redBase:GetChildren()) do if o:IsA('Part') then o.BrickColor = BrickColor.Red() end end
for _, o in pairs(blueBase:GetChildren()) do if o:IsA('Part') then o.BrickColor = BrickColor.Blue() end end
redBase.Parent, blueBase.Parent = workspace, workspace
local _, s = redBase:GetBoundingBox()
local _, s1 = blueBase:GetBoundingBox()

redBase:PivotTo(CFrame.new(100, s.Y / 2, 0) * CFrame.Angles(0, math.rad(90), 0))
blueBase:PivotTo(CFrame.new(-100, s1.Y / 2, 0) * CFrame.Angles(0, math.rad(-90), 0))

local TeamBasses = {redBase, blueBase}

local function iteratePlayers(action, iteratedList)
    for i, player in pairs(iteratedList) do
        action(player, i)
    end
end

local PLAYER_QUANTITY = 2

local Game_ = {}

Game_.__index = Game_

function Game_.New()
    local self = setmetatable({}, Game_)
    self.PlayerQuantity = PLAYER_QUANTITY
    self.Players = {}
    self.IsOver = false
    self.WinnerTeam = nil
    self:Init()
    return self
end

function Game_:CheckPlayerAdded()
    Players.PlayerAdded:Connect(function(player)
        table.insert(self.Players, player)
    end)
end

function Game_:Leaderstats(player)
    local leadboard = Instance.new('Folder')
    leadboard.Name = 'leaderstats'
    local deathCount = Instance.new('IntValue')
    deathCount.Parent = leadboard
    deathCount.Name = 'Death'
    leadboard.Parent = player
end



function Game_:SetupTeams()
    local red, spawnPoint = Instance.new('Team'), Instance.new('Vector3Value')
    red.Name, red.Parent = 'RedTeam', Teams
    spawnPoint.Parent, spawnPoint.Name = red, 'SpawnPoint'
    local blue, spawnPoint = Instance.new('Team'), Instance.new('Vector3Value')
    blue.Name, blue.Parent = 'BlueTeam', Teams
    spawnPoint.Parent, spawnPoint.Name = blue, 'SpawnPoint'
    red.SpawnPoint.Value, blue.SpawnPoint.Value = TeamBasses[1]:GetPivot().Position, TeamBasses[2]:GetPivot().Position
    red.AutoAssignable, blue.AutoAssignable = false, false
    red.TeamColor, blue.TeamColor = BrickColor.Red(), BrickColor.Blue()

end

function Game_:CheckPlayerDeath(player)
    player.Character:FindFirstChild('Humanoid').Died:Connect(function()
        player.leaderstats.Death.Value += 1
        player:LoadCharacter()
        player.Character:MoveTo(player.Team.SpawnPoint.Value)
        self:CheckFinalOfGame(player)
        self:CheckPlayerDeath(player)
    end)
end

function Game_:CheckFinalOfGame(deathPlayer)
    local TeamList = Teams:GetTeams()
    local sumOfDeath = 0
    local checkedTeam = deathPlayer.Team
    iteratePlayers(function(player, ...) sumOfDeath += player.leaderstats.Death.Value end, checkedTeam:GetPlayers())
    self.IsOver = sumOfDeath >= 2 and true or false
    if self.IsOver then self.Winner = table.find(TeamList, checkedTeam, 1) == 1 and TeamList[2] or TeamList[1] end
end

function Game_:Reset()
    self.IsOver = false
    self.Winner = nil
    self:Init()
end

function Game_:Warning()
    iteratePlayers(function(player, ...)
        local playerGui = player.PlayerGui
        local MainGui = playerGui:FindFirstChild('MainGui')
        if MainGui then
            MainGui.TextLabel.Text = self.Winner.Name .. ' ' .. 'is Winner'
            coroutine.wrap(function() 
                MainGui.TextLabel.Visible = true 
                task.wait(5) 
                MainGui.TextLabel.Visible = false 
            end)()
        end
    end, self.Players)
end

function Game_:SetupPlayer()

    iteratePlayers(function(player, ...)
        local i = ... 
        if not player:FindFirstChild('leaderstats') then self:Leaderstats(player) else player.leaderstats.Death.Value = 0 end
        local playerGui = player.PlayerGui
        player:LoadCharacter()
        self:CheckPlayerDeath(player)
        local setTeam = i % 2 == 0 and Teams.RedTeam or Teams.BlueTeam
        local randTeam = math.random(2) == 1 and Teams.RedTeam or Teams.BlueTeam
        player.Team = #self.Players % 2 == 0 and setTeam or (i == #self.Players and randTeam or setTeam)
        player.Character:MoveTo(player.Team.SpawnPoint.Value)
    end, self.Players)
end

function Game_:Init()
    if #self.Players == 0 then self:CheckPlayerAdded() end
    -- print('waiting players')
    repeat wait() until #self.Players == self.PlayerQuantity
    print('players are connected')
    if #Teams:GetTeams() == 0 then self:SetupTeams() end

    wait(10)
    print('go')

    self:SetupPlayer()
    print(self.IsOver, 'before')
    repeat wait() until self.IsOver
    print(self.IsOver, 'after')
    self:Warning()
    self:Reset()
end

return Game_