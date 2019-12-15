ScrollState = Class{__includes = BaseState}

function ScrollState:init(textData, exitButton)
    self.scrollable = true
    self.textData = textData
    self.buttons = {}

    if exitButton then
        exitButtonX = VIRTUAL_WIDTH - ICON_SIZE
        exitButtonY = 0
        buttonTexture = gTextures['buttons']['exit']
        table.insert(self.buttons, Button(
            buttonTexture,
            exitButtonX, exitButtonY, ICON_SIZE, ICON_SIZE, nil,
            function()
                Timer.tween(0.25, {
                    [self.colors['panel']] = {[4] = 0},
                    [self.colors['text']] = {[4] = 0},
                    [self.colors['background']] = {[4] = 0}
                }):finish(function() end)
            end
        ))
    end

    cameraX = 0
    cameraY = 0

    self.width = VIRTUAL_WIDTH * 5 / 8
    self.height = VIRTUAL_HEIGHT

    self.x = (VIRTUAL_WIDTH - self.width) / 2
    self.y = (VIRTUAL_HEIGHT - self.height) / 2

    self.colors = {
        ['panel'] = {245, 245, 245, 0},
        ['background'] = {245, 245, 245, 0},
        ['text'] = {0, 0, 0, 0},
        ['scrollbar'] = {0, 0, 0, 0}
    }

    self.fonts = {
        ['header'] = gFonts['medium-bigger'],
        ['body'] = gFonts['slightlybigger'],
        ['title'] = gFonts['titlefont']
    }

    Timer.tween(0.25, {
        [self.colors['panel']] = {[4] = 255},
        [self.colors['text']] = {[4] = 255},
        [self.colors['background']] = {[4] = 200},
        [self.colors['scrollbar']] = {[4] = 200}
    })

    self.bottomY = -VIRTUAL_WIDTH * 2
    self.scrollbar = ScrollBar(self.x + self.width + 50, 0, self.bottomY, 10, 2 * VIRTUAL_HEIGHT / 3)
end

function ScrollState:fadeOutAndPop()
    Timer.tween(0.25, {
        [self.colors['panel']] = {[4] = 0},
        [self.colors['text']] = {[4] = 0},
        [self.colors['background']] = {[4] = 0},
        [self.colors['scrollbar']] = {[4] = 0}
    }):finish(function() gStateStack:pop() end)
end

function ScrollState:update(dt)
    if gStateStack.states[1].background then
        gStateStack.states[1].background:update(dt)
    end
    if love.keyboard.wasPressed('escape') or love.keyboard.wasPressed('return') then
        self:fadeOutAndPop()
    end

    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    if self.scrollable then
        if love.keyboard.isDown('down') or love.mouse.scroll.y < 0 then
            cameraY = cameraY + 20 * math.abs(love.mouse.scroll.y < 0 and love.mouse.scroll.y or 1)
            cameraY = math.min(cameraY, self.bottomY - VIRTUAL_HEIGHT)
        end

        if love.keyboard.isDown('up') or love.mouse.scroll.y > 0 then
            cameraY = cameraY - 20 * (love.mouse.scroll.y > 0 and love.mouse.scroll.y or 1)
            cameraY = math.max(cameraY, 0)
        end

        if love.mouse.isDown(1) then
            if checkCollision(mouseX, mouseY, self.scrollbar) then
                self.scrollbar.dragging.active = true
                self.scrollbar.dragging.diffX = mouseX - self.scrollbar.x
                self.scrollbar.dragging.diffY = mouseY - self.scrollbar.y
            end
        else
            self.scrollbar.dragging.active = false
            self.scrollbar.dragging.diffX = nil
            self.scrollbar.dragging.diffY = nil
        end

        if self.scrollbar.dragging.active then
            self.scrollbar.y = math.max(0, math.min(mouseY - self.scrollbar.dragging.diffY, VIRTUAL_HEIGHT - self.scrollbar.height))
            cameraY = (self.scrollbar.y * self.scrollbar.range) / (VIRTUAL_HEIGHT - self.scrollbar.height)
        end
    end

    if love.mouse.keysPressed[1] and mouseX and mouseY then
        if not (checkCollision(mouseX, mouseY, self) or checkCollision(mouseX, mouseY, self.scrollbar)) then
            self:fadeOutAndPop()
        end
    end

    self.scrollbar:updateValue(cameraY)
    for i, button in pairs(self.buttons) do
        button:update()
    end
end

function ScrollState:render()
    local function getLines(text, font)
        a, b = font:getWrap(text, self.width)
        return #b
    end
    -- transluscent background
    love.graphics.setColor(self.colors['background'])
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    if self.scrollable then
        self.scrollbar:render(self.colors['scrollbar'])
    end

    -- panel
    love.graphics.setColor(self.colors['panel'])
    love.graphics.rectangle('fill', self.x, self.y, self.width + 20, self.height, 10)

    love.graphics.translate(-cameraX, - cameraY)

    love.graphics.setColor(self.colors['text'])

    local y = 0
    local x = self.x + 30

    love.graphics.setFont(self.fonts['title'])
    love.graphics.printf(self.textData['title'], x, y, self.width, 'center')
    y = y + self.fonts['title']:getHeight()
    for i, header in pairs(self.textData['headers']) do
        lines = self.textData['info'][header]
        love.graphics.setFont(self.fonts['header'])
        love.graphics.printf(header, x, y, self.width)
        y = y + self.fonts['header']:getHeight() * 1.5
        for i, rule in pairs(lines) do
            love.graphics.setFont(self.fonts['body'])
            -- love.graphics.printf(tostring(i) .. '. ' .. rule, x, y, self.width)
            love.graphics.printf(rule, x, y, self.width)
            y = y + self.fonts['body']:getHeight() * 1.5 * getLines(rule, self.fonts['body'])
            y = y + 10
        end
    end
    self.bottomY = y

    if self.bottomY < self.y + self.height then
        self.scrollable = false
        -- self.height = self.y - y
        -- self.y = (VIRTUAL_HEIGHT - self.height) / 2 - self.height / 2
    end

    self.scrollbar.range = y - self.height

    love.graphics.translate(cameraX, cameraY)

    for i, button in pairs(self.buttons) do
        button:render()
    end

end
