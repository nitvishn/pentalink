GameOverState = Class{__includes = BaseState}

function GameOverState:init(winningPlayer, bestPlayersArea, players)
    self.winningPlayer = winningPlayer
    self.bestPlayersArea = bestPlayersArea
    self.players = players

    self.width = gFonts['medium']:getWidth("Player 1 Wins!") * 1.5

    local y = 10 + gFonts['medium-bigger']:getHeight() + 90
    for i, player in pairs(self.players) do
        y = y + 10 + gFonts['medium']:getHeight() + gFonts['small']:getHeight() + 20
    end

    self.height = y

    self.x = (VIRTUAL_WIDTH - self.width) / 2
    self.y = -self.height
    self.exitable = false

    self.scrollable = self.height > VIRTUAL_HEIGHT
    self.scrollbar = ScrollBar(self.x - 20, 0, self.height - VIRTUAL_HEIGHT, 10, 2 * VIRTUAL_HEIGHT - self.height)

    self.scrollbar.y = -self.scrollbar.height

    Timer.tween(1, {
        [self] = {y = math.max(0, (VIRTUAL_HEIGHT - self.height) / 2)},
        [self.scrollbar] = {y = 0}
    }):finish(function() self.exitable = true end)

    cameraX = 0
    cameraY = 0

    self.title = self.winningPlayer and 'Player ' .. tostring(self.winningPlayer) .. ' wins!' or 'Draw.'
end

function GameOverState:update(dt)
    if self.scrollable then
        if love.keyboard.isDown('down') or love.mouse.scroll.y < 0 then
            cameraY = cameraY + 10 * math.abs(love.mouse.scroll.y < 0 and love.mouse.scroll.y or 1)
            cameraY = math.min(cameraY, self.height - VIRTUAL_HEIGHT)
            self.scrollbar:updateValue(cameraY)
        end

        if love.keyboard.isDown('up') or love.mouse.scroll.y > 0 then
            cameraY = cameraY - 10 * (love.mouse.scroll.y > 0 and love.mouse.scroll.y or 1)
            cameraY = math.max(cameraY, 0)
            self.scrollbar:updateValue(cameraY)
        end
    end

    if self.exitable and (love.keyboard.wasPressed('return') or love.mouse.keysPressed[1]) then
        gStateStack:push(FadeInState({r = 255, g = 255, b = 255}, 0.25, function()
            gStateStack:pop()
            gStateStack:pop()
            gStateStack:push(StartState())
            gStateStack:push(FadeOutState({r = 255, g = 255, b = 255}, 0.5, function() end))
        end))
    end
end

function GameOverState:render()

    love.graphics.setColor(255, 255, 255, 100)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.translate(-cameraX, - cameraY)
    love.graphics.setColor(245, 245, 245, 255)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 10)

    self.x = self.x + 10

    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.setFont(gFonts['medium-bigger'])
    love.graphics.printf(self.title, self.x, self.y + 10, self.width, 'left')

    local y = self.y + 10 + gFonts['medium-bigger']:getHeight() + 20
    local points = #self.bestPlayersArea == 1 and MOST_AREA_POINTS or TIED_AREA_POINTS
    for i, player in pairs(self.players) do
        love.graphics.setFont(gFonts['medium'])
        love.graphics.printf('Player ' .. tostring(i), self.x, y + 10, self.width, 'left')

        love.graphics.setFont(gFonts['small'])
        if table.contains(bestPlayersArea, i) then
            love.graphics.printf('Points: ' .. tostring(self.players[i].points - points), self.x, y + 10 + gFonts['medium']:getHeight(), self.width, 'left')
            love.graphics.setColor(0, 166, 6)
            xoffset = gFonts['small']:getWidth('Points: ' .. tostring(self.players[i].points - points))
            love.graphics.printf(' + ' .. tostring(points), self.x + xoffset, y + 10 + gFonts['medium']:getHeight(), self.width, 'left')

            love.graphics.setColor(0, 0, 0)
            xoffset = xoffset + gFonts['small']:getWidth(' + ' .. tostring(points))
            love.graphics.printf(' = ' .. tostring(self.players[i].points), self.x + xoffset, y + 10 + gFonts['medium']:getHeight(), self.width, 'left')
        else
            love.graphics.printf('Points: ' .. tostring(self.players[i].points), self.x, y + 10 + gFonts['medium']:getHeight(), self.width, 'left')
        end
        love.graphics.printf('Area: ' .. tostring(self.players[i].area), self.x, y + 10 + gFonts['medium']:getHeight() + gFonts['small']:getHeight(), self.width, 'left')
        y = y + 10 + gFonts['medium']:getHeight() + gFonts['small']:getHeight() + 20
    end

    y = y + 20
    love.graphics.printf("Press 'Enter' to return to menu", self.x, y + 20, self.width, 'center')

    self.x = self.x - 10

    love.graphics.translate(cameraX, cameraY)

    if self.scrollable then
        self.scrollbar:render()
    end
end
