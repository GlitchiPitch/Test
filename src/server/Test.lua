local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- Players.CharacterAutoLoads = false

local Crossbow = game:GetService('InsertService'):LoadAsset(4842204072).Crossbow

local redSpawn, blueSpawn = Instance.new('Part'), Instance.new('Part')
redSpawn.Parent, blueSpawn.Parent = workspace, workspace
redSpawn.Position, blueSpawn.Position = Vector3.new(100, 1, 0), Vector3.new(-100, 1, 0)


local TeamBasses = {redSpawn, blueSpawn}

local function iteratePlayers(action, iteratedList)
    -- print('iteratePlayers')
    for i, player in pairs(iteratedList) do
        -- print(player, ' is iterated')
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
        -- print(player, 'is on server')
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

function Game_:SetupGui(player)
    local gui, text = Instance.new('ScreenGui'), Instance.new('TextLabel')
    gui.Name = 'MainGui'
    text.Size, text.Position = UDim2.fromScale(.5,.5), UDim2.fromScale(.5,.5)
    text.AnchorPoint = Vector2.new(.5,.5)
    text.Visible = false
    gui.Parent, text.Parent = player.PlayerGui, gui
end

function Game_:SetupTeams()
    local red, spawnPoint = Instance.new('Team'), Instance.new('ObjectValue')
    red.Name, red.Parent = 'RedTeam', Teams
    spawnPoint.Parent, spawnPoint.Name = red, 'SpawnPoint'
    local blue, spawnPoint = Instance.new('Team'), Instance.new('ObjectValue')
    blue.Name, blue.Parent = 'BlueTeam', Teams
    spawnPoint.Parent, spawnPoint.Name = blue, 'SpawnPoint'
    red.SpawnPoint.Value, blue.SpawnPoint.Value = TeamBasses[1], TeamBasses[2]
    red.AutoAssignable, blue.AutoAssignable = false, false
    red.TeamColor, blue.TeamColor = BrickColor.Red(), BrickColor.Blue()

end

function Game_:CheckPlayerDeath(player)
    player.Character:FindFirstChild('Humanoid').Died:Connect(function()
        player.leaderstats.Death.Value += 1
        player:LoadCharacter()
        player.Character:MoveTo(player.Team.SpawnPoint.Value.Position)
        local crossbow = Crossbow:Clone()
        crossbow.Parent = player.Backpack
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
    if self.IsOver then self.Winner = checkedTeam == TeamList[1] and TeamList[2] or TeamList[1] end
end

function Game_:Reset()
    self:Init()
    self.IsOver = false
end

function Game_:Warning()
    iteratePlayers(function(player, ...)
        local playerGui = player.PlayerGui
        print(playerGui)
        local MainGui = playerGui:FindFirstChild('MainGui')
        print(MainGui)
        MainGui.TextLabel.Text = self.Winner.Name .. ' ' .. 'is Winner'
        coroutine.wrap(function() 
            MainGui.TextLabel.Visible = true 
            task.wait(5) 
            MainGui.TextLabel.Visible = false 
        end)()    
    end, self.Players)
end

function Game_:SetupPlayer()

    iteratePlayers(function(player, ...)
        print(player, ' is setuped')
        local i = ... 
        if not player:FindFirstChild('leaderstats') then self:Leaderstats(player) else player.leaderstats.Death.Value = 0 end
        if not player:FindFirstChild('MainGui') then self:SetupGui(player) end
        -- coroutine.wrap(self:CheckPlayerDeath)(player)
        player:LoadCharacter()
        self:CheckPlayerDeath(player)
        player.Team = i % 2 == 0 and Teams.RedTeam or Teams.BlueTeam
        player.Character:MoveTo(player.Team.SpawnPoint.Value.Position)
        local crossbow = Crossbow:Clone()
        crossbow.Parent = player.Backpack
            
    end, self.Players)
end

function Game_:Init()
    if #self.Players == 0 then self:CheckPlayerAdded() end
    -- print('waiting players')
    repeat wait() until #self.Players == self.PlayerQuantity
    print('players are connected')
    if #Teams:GetTeams() == 0 then self:SetupTeams() end
    self:SetupPlayer()
    repeat wait() until self.IsOver
    self:Warning()
    self:Reset()
end

return Game_