PlayState = Class{__includes = BaseState}

function PlayState:init(numPlayers, levelNum, AI)
    self.AI = AI
    self.buttons = {
        Button(
            gTextures['buttons']['hamburger'],
            VIRTUAL_WIDTH - ICON_SIZE, 0, ICON_SIZE, ICON_SIZE,
            function()
                gStateStack:push(LevelSelectState(
                    {
                    {
                        ['text'] = 'Rules',
                        ["font"] = gFonts['medium'],
                        ["arrowFunction"] = function(incr) end,
                        ["enter"] = function() gStateStack:push(ScrollState(HELP_DATA)) end
                    },
                    {
                        ['text'] = 'Restart',
                        ["font"] = gFonts['medium'],
                        ["arrowFunction"] = function(incr) end,
                        ["enter"] = function()
                            gStateStack:push(FadeInState({r = 255, g = 255, b = 255}, 0.5, function()
                                gStateStack:pop()
                                self:init(#self.players, self.levelNum, self.AI)
                                gStateStack:push(FadeOutState({r = 255, g = 255, b = 255}, 0.5, function() end))
                            end))
                        end
                    },
                    {
                        ['text'] = 'Home',
                        ["font"] = gFonts['medium'],
                        ["arrowFunction"] = function(incr) end,
                        ["enter"] = function()
                            gStateStack:push(FadeInState({r = 255, g = 255, b = 255}, 0.2, function()
                                gStateStack:pop()
                                gStateStack:pop()
                                gStateStack:push(StartState())
                                gStateStack:push(FadeOutState({r = 255, g = 255, b = 255}, 0.5, function() end))
                            end))
                        end
                    },
                }, nil, nil, gTextures['buttons']['hamburger']))
            end
        ),
        Button(
            gTextures['buttons']['undo'],
            VIRTUAL_WIDTH - ICON_SIZE * 2, 0, ICON_SIZE, ICON_SIZE,
            function()
                self:undoMove()
            end
        )
    }
    self.levelNum = levelNum
    self.level = generateLevel(levelNum)

    gPoints = self.level.points

    self.pointData = {}
    local nodeNumbers = {}
    for i = 1, #gPoints do
        table.insert(nodeNumbers, i)
        self.pointData[i] = {
            ['fill'] = {0, 0, 0, 255},
            ['outline'] = {0, 0, 0, 255}
        }
    end

    shiftX = gFonts['medium']:getWidth('Player 1') * 1.5
    scale = (VIRTUAL_WIDTH - shiftX) / VIRTUAL_WIDTH
    shiftY = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT * scale
    translatePoints(gPoints, shiftX, shiftY, scale)

    self.playerTriangle = Triangle(shiftX, 0, 25, gFonts['medium']:getHeight() - 10)

    self.numInStreak = 0
    self.streakStarter = nil
    self.lastPlayer = nil
    self.moveNum = 1
    self.moveHistory = {}

    self.messageLog = {}

    self.numPlayers = numPlayers
    self.players = {}
    for i = 1, self.numPlayers do
        table.insert(self.players, Player(0, {}))
    end
    self.currentPlayer = 1

    self.graph = Graph(nodeNumbers)

    for i, edge in pairs(self.level.edges) do
        self.graph:add_edge(edge[1], edge[2])
    end

    self.cycles = minimum_cycle_basis(self.graph)

    self.selected = nil
    self.updateLocked = false
end

function PlayState:undoMove()
    local moveNum = self.moveNum - 1
    if moveNum == 0 then return end

    local pentagonExists = false

    for i, player in pairs(self.players) do
        if player.moveData[moveNum] then
            player.points = player.points - (player.moveData[moveNum].points or 0)
            player.area = player.area - (player.moveData[moveNum].area or 0)

            if player.moveData[moveNum].shapes then
                for i, shape in pairs(player.moveData[moveNum].shapes) do
                    if #shape == 5 then
                        pentagonExists = true
                        break
                    end
                end
            end

            player.moveData[moveNum] = nil
        end
    end

    if pentagonExists then
        self.numInStreak = self.numInStreak - 1
    end

    for i, message in pairs(self.messageLog) do
        if message.move == moveNum then
            self.messageLog[i] = nil
        end
    end

    local move = self.moveHistory[moveNum]
    self.graph:remove_edge(move[1], move[2])
    self.cycles = minimum_cycle_basis(self.graph)
    -- print_r(self.cycles)
    -- print_r(self.graph.nodes)
    -- print_r(self.graph.edges)

    self.currentPlayer = scaleIncrement(self.currentPlayer, 1, #self.players, - 1)

    local h = (self.currentPlayer - 1) * gFonts['medium']:getHeight() + (2 * (self.currentPlayer - 1)) * gFonts['small']:getHeight()
    Timer.tween(0.5, {
        [self.playerTriangle] = {y = h}
    })

    self.moveHistory[moveNum] = nil

    self.moveNum = moveNum
end

function PlayState:possibleEdges()
    local edges = {}
    for n1 = 1, #gPoints do
        for n2 = n1 + 1, #gPoints do
            if n1 ~= n2 and self:validLine({n1, n2}) then
                table.insert(edges, {n1, n2})
            end
        end
    end
    return edges
end

function PlayState:processAI()
    local edges = self:possibleEdges()
    self:registerMove(edges[math.random(#edges)])
end

function PlayState:checkGameOver()
    -- return false
    for n1 = 1, #gPoints do
        for n2 = 1, #gPoints do
            if n1 ~= n2 and self:validLine({n1, n2}) then
                return false
            end
        end
    end
    return true
end

function PlayState:validLine(line1)
    a = gPoints[line1[1]]
    c = gPoints[line1[2]]

    local midpoint = {(a[1] + c[1]) / 2, (a[2] + c[2]) / 2}

    for i, c in pairs(self.cycles) do
        v = getVertices(c)
        if pointInPolygon(midpoint, v) then
            return false
        end
    end

    for i, line2 in pairs(self.graph.edges) do
        -- check if the line already exists
        if (line1[1] == line2[1] and line1[2] == line2[2]) or (line1[2] == line2[1] and line1[1] == line2[2]) then
            return false
        end
        coordinateLine1 = deepcopy({gPoints[line1[1]], gPoints[line1[2]]})
        coordinateLine2 = deepcopy({gPoints[line2[1]], gPoints[line2[2]]})

        if lines_intersect(coordinateLine1, coordinateLine2) then
            return false
        end
    end

    for i, b in pairs(gPoints) do
        if table.contains(line1, i) then
            goto continue
        end

        if lies_between(a, c, b) then
            return false
        end

        ::continue::
    end

    return true
end

function validateCycle(cycle)
    cyc_copy = deepcopy(cycle)
    table.insert(cyc_copy, cyc_copy[1])
    table.insert(cyc_copy, cyc_copy[2])

    remove = {}
    for i = 1, #cyc_copy - 2 do
        a = gPoints[cyc_copy[i]]
        b = gPoints[cyc_copy[i + 1]]
        c = gPoints[cyc_copy[i + 2]]
        if lies_between(a, c, b) then
            remove[cyc_copy[i + 1]] = true
        end
    end

    new_cyc = {}
    for i = 1, #cyc_copy - 2 do
        if not remove[cyc_copy[i]] then
            table.insert(new_cyc, cyc_copy[i])
        end
    end

    for i, point in gPoints do
        if pointInPolygon(point, getVertices(cycle)) then
            return false
        end
    end

    return new_cyc
end

function PlayState:selectPoint(point)
    for i = 1, #gPoints do
        if point == i then
            Timer.tween(0.25, {
                [self.pointData[i]['fill']] = {255, 0, 0, 255}
            })
        else
            if self:validLine({point, i}) then
                Timer.tween(0.25, {
                    [self.pointData[i]['fill']] = {0, 255, 0, 255}
                })
            else
                Timer.tween(0.25, {
                    [self.pointData[i]['fill']] = {0, 0, 0, 255}
                })
            end
        end
    end
end

function PlayState:deselectPoints()
    for i = 1, #gPoints do
        Timer.tween(0.25, {
            [self.pointData[i]['fill']] = {0, 0, 0, 255}
        })
    end
end

function PlayState:registerMove(move)
    self.graph:add_edge(move[1], move[2])

    self.moveHistory[self.moveNum] = move

    local nextCycles = minimum_cycle_basis(self.graph)

    for i, c in pairs(nextCycles) do
        nextCycles[i] = validateCycle(c)
    end

    local newCycles = getNewCycles(nextCycles, self.cycles)

    local pentagonExists = false
    for i, c in pairs(newCycles) do
        table.insert(self.cycles, c)
        if #c == 5 then
            pentagonExists = true
        end
        sign = (shapepoints(c) and shapepoints(c) > 0) and '+' or ''
        table.insert(self.messageLog, {
            ['move'] = self.moveNum,
            ['player'] = self.currentPlayer,
            ['points'] = shapepoints(c) or 0
        })
    end

    if pentagonExists then
        if self.numInStreak == 0 then
            self.streakStarter = self.lastPlayer
        end
        self.numInStreak = self.numInStreak + 1
    elseif STREAK_POINTS[self.numInStreak] then
        self.players[self.streakStarter].points = self.players[self.streakStarter].points + STREAK_POINTS[self.numInStreak]
        self.players[self.streakStarter].moveData[self.moveNum] = self.players[self.streakStarter].moveData[self.moveNum] or {}
        self.players[self.streakStarter].moveData[self.moveNum]['points'] = (self.players[self.streakStarter].moveData[self.moveNum]['points'] or 0) + STREAK_POINTS[self.numInStreak]
        table.insert(self.messageLog, {
            ['move'] = self.moveNum,
            ['player'] = self.currentPlayer,
            ['points'] = STREAK_POINTS[self.numInStreak]
        })
        self.numInStreak = 0
        self.streakStarter = nil
    end

    self.players[self.currentPlayer]:update(newCycles, self.moveNum)

    self.lastPlayer = self.currentPlayer
    self.currentPlayer = math.max((self.currentPlayer + 1)%(self.numPlayers + 1), 1)
    self.moveNum = self.moveNum + 1
    local h = (self.currentPlayer - 1) * gFonts['medium']:getHeight() + (2 * (self.currentPlayer - 1)) * gFonts['small']:getHeight()
    Timer.tween(0.5, {
        [self.playerTriangle] = {y = h}
    })
    self.gameOver = self:checkGameOver()
    if self.gameOver then
        if self.numInStreak > 0 then
            self.players[self.streakStarter].points = self.players[self.streakStarter].points + (STREAK_POINTS[self.numInStreak] or 0)
            self.numInStreak = 0
            self.streakStarter = nil
        end

        bestArea = 0
        bestPlayersArea = {}

        for i, player in pairs(self.players) do
            if player.area > bestArea then
                bestArea = player.area
                bestPlayersArea = {i, }
            elseif player.area == bestArea then
                table.insert(bestPlayersArea, i)
            end
        end

        local points = #bestPlayersArea == 1 and MOST_AREA_POINTS or TIED_AREA_POINTS
        for i, player in pairs(bestPlayersArea) do
            self.players[player].points = self.players[player].points + points
        end

        bestPlayers = {1, }
        bestScore = self.players[1].points

        for i = 2, #self.players do
            player = self.players[i]
            if player.points > bestScore then
                bestScore = player.points
                bestPlayers = {i, }
            elseif player.points == bestScore then
                table.insert(bestPlayers, i)
            end
        end

        if #bestPlayers ~= 1 then
            bestPlayer = nil
        else
            bestPlayer = bestPlayers[1]
        end

        gStateStack:push(GameOverState(bestPlayer, bestPlayersArea, self.players))
    end
end

function PlayState:update(dt)
    for i, button in pairs(self.buttons) do
        button:update()
    end

    if self.updateLocked then
        goto continue
    end

    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    if self.AI[self.currentPlayer] then
        self.updateLocked = true
        Timer.after(AI_DELAY, function()
            self:processAI(dt)
            self.updateLocked = false
        end)
    end

    if love.mouse.keysPressed[1] and not self.gameover and not self.AI[self.currentPlayer] and mouseX and mouseY then
        if self.selected then
            local other = nil
            for i, point in pairs(gPoints) do
                if point_length(mouseX, mouseY, point[1], point[2]) <= POINT_HITBOX then
                    other = i
                end
            end
            if other and self.selected ~= other then
                -- at this point
                if self:validLine({self.selected, other}) then
                    self:registerMove({self.selected, other})
                else
                    gSounds['deny-connection']:play()
                    -- graphics to show line and then fade it out
                end
            end
            self.selected = nil
            self:deselectPoints()
        else
            for i, point in pairs(gPoints) do
                if point_length(mouseX, mouseY, point[1], point[2]) <= POINT_HITBOX then
                    self.selected = i
                    break
                end
            end
            if self.selected then
                self:selectPoint(self.selected)
            else
                self:deselectPoints()
            end
        end
    end

    ::continue::
end

function PlayState:render()
    love.graphics.clear(255, 255, 255, 255)
    self.playerTriangle:render()

    for i, cycle in pairs(self.cycles) do
        if #cycle == 5 then
            love.graphics.setColor(255, 0, 0, 200)
        else
            love.graphics.setColor(14, 66, 171, 200)
        end
        local vertices = getVertices(cycle)
        if convex then
            love.graphics.polygon('fill', vertices)
        else
            triangles = love.math.triangulate(vertices)
            for i, polygon_triangle in pairs(triangles) do
                love.graphics.polygon('fill', polygon_triangle)
            end
        end
    end

    love.graphics.setColor(0, 0, 0)

    shiftY = gFonts['medium']:getHeight()

    for i, line in pairs(self.graph.edges) do
        love.graphics.line(gPoints[line[1]][1], gPoints[line[1]][2], gPoints[line[2]][1], gPoints[line[2]][2])
    end

    for i, point in pairs(gPoints) do
        love.graphics.setFont(gFonts['small'])

        -- mark point numbers
        -- love.graphics.setColor(0, 0, 0, 255)
        -- love.graphics.print(tostring(i), point[1], point[2])

        love.graphics.setColor(self.pointData[i]['outline'])
        love.graphics.circle('fill', point[1], point[2], 5)

        love.graphics.setColor(self.pointData[i]['fill'])
        love.graphics.circle('fill', point[1], point[2], 4)
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(gFonts['medium-bigger'])
    if self.gameOver then
        love.graphics.printf("Game over.", 0, 0, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf("Player " .. tostring(self.currentPlayer) .. "'s turn!", 0, 0, VIRTUAL_WIDTH, 'center')
    end
    for i = 1, self.numPlayers do
        local h = (i - 1) * gFonts['medium']:getHeight() + (2 * (i - 1)) * gFonts['small']:getHeight()
        love.graphics.setFont(gFonts['medium'])
        love.graphics.printf("Player " .. tostring(i) .. (self.AI[i] and ' (AI)' or ''), 0, h, shiftX)

        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("Points: " .. tostring(self.players[i].points), 0, h + gFonts['medium']:getHeight(), shiftX)
        love.graphics.printf("Area: " .. tostring(math.floor(self.players[i].area, 0)), 0, h + gFonts['medium']:getHeight() + gFonts['small']:getHeight(), shiftX)
    end

    local y = self.numPlayers * gFonts['medium']:getHeight() + (2 * self.numPlayers) * gFonts['small']:getHeight() + 20
    love.graphics.setFont(gFonts['small'])
    headings = {'move', 'player', 'points'}
    headingsX = {}
    local x = 0
    for i, heading in pairs(headings) do
        love.graphics.printf(heading, x, y, VIRTUAL_WIDTH)
        headingsX[heading] = x
        x = x + gFonts['small']:getWidth(heading) + 10
    end

    y = y + gFonts['small']:getHeight()
    for i = #self.messageLog, 1, - 1 do
        message = self.messageLog[i]
        for i, heading in pairs(headings) do
            love.graphics.printf(message[heading], headingsX[heading], y, gFonts['small']:getWidth(heading), 'center')
        end
        y = y + gFonts['small']:getHeight()
    end

    for i, button in pairs(self.buttons) do
        button:render()
    end
end
