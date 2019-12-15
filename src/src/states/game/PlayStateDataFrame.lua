PlayStateDataFrame = Class{__includes = BaseState}

function PlayStateDataFrame:init(frame)
    if frame then
        self.numInStreak = deepcopy(frame.numInStreak)
        self.streakStarter = deepcopy(frame.streakStarter)
        self.lastPlayer = deepcopy(frame.lastPlayer)
        self.messageLog = deepcopy(frame.messageLog)
        self.currentPlayer = deepcopy(frame.currentPlayer)
        self.cycles = deepcopy(frame.cycles)

        self.players = {}
        for i, player in pairs(frame.players) do
            newPlayer = Player(0)
            newPlayer.points = deepcopy(player.points)
            newPlayer.moveData = deepcopy(player.moveData)
            newPlayer.area = deepcopy(player.area)
            self.players[i] = newPlayer
        end

        self.graph = Graph({})
        self.graph.nodes = deepcopy(frame.graph.nodes)
        self.graph.edges = deepcopy(frame.graph.edges)
        -- self.graph = frame.graph
    end
end
