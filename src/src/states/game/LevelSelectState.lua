LevelSelectState = Class{__includes = BaseState}

function LevelSelectState:init(data, exitButton)
    self.buttons = {}

    if exitButton then
        exitButtonX = 0
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

    -- object data
    self.colors = {
        ['panel'] = {245, 245, 245, 0},
        ['background'] = {255, 255, 255, 0},
        ['text'] = {0, 0, 0, 0}
    }

    Timer.tween(0.25, {
        [self.colors['panel']] = {[4] = 255},
        [self.colors['text']] = {[4] = 255},
        [self.colors['background']] = {[4] = 100}
    })

    -- data about game
    self.data = data

    self.highlighted = 0

    self.height = 0

    for i, object in pairs(self.data) do
        love.graphics.setFont(object.font)
        if object.value then
            self.height = self.height + object.font:getHeight()
        end
        self.height = self.height + object.font:getHeight() * 1.5
    end

    self.width = VIRTUAL_WIDTH / 4

    self.x = (VIRTUAL_WIDTH - self.width) / 2
    self.y = (VIRTUAL_HEIGHT - self.height) / 2
end

function LevelSelectState:postInit()
    -- store object widths
    for i, object in pairs(self.data) do
        if object.value then
            local initial = object.value
            object.arrowFunction(1)
            local next = object.value

            local maxWidth = math.max(object.font:getWidth(initial), object.font:getWidth(next))
            while next ~= initial do
                object.arrowFunction(1)
                next = object.value
                maxWidth = math.max(maxWidth, object.font:getWidth(next))
            end
            object.width = maxWidth + 20
        end
    end
end

function LevelSelectState:update(dt)
    for i, button in pairs(self.buttons) do
        button:update()
    end
    if gStateStack.states[1].background then
        gStateStack.states[1].background:update(dt)
    end
    if love.keyboard.wasPressed('escape') then
        Timer.tween(0.25, {
            [self.colors['panel']] = {[4] = 0},
            [self.colors['text']] = {[4] = 0},
            [self.colors['background']] = {[4] = 0}
        }):finish(function() gStateStack:pop() end)
    end

    if love.keyboard.wasPressed('up') then
        self.highlighted = (self.highlighted - 1)%#self.data
    end

    if love.keyboard.wasPressed('down') then
        self.highlighted = (self.highlighted + 1)%#self.data
    end

    if love.keyboard.wasPressed('return') then
        self.data[self.highlighted + 1].enter()
    end

    if love.keyboard.wasPressed('right') and self.data[self.highlighted + 1].value then
        self.data[self.highlighted + 1].arrowFunction(1)
    end

    if love.keyboard.wasPressed('left') and self.data[self.highlighted + 1].value then
        self.data[self.highlighted + 1].arrowFunction(-1)
    end

    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    if love.mouse.keysPressed[1] and mouseX and mouseY then
        if mouseX < self.x or mouseX > self.x + self.width or mouseY < self.y or mouseY > self.y + self.height then
            Timer.tween(0.25, {
                [self.colors['panel']] = {[4] = 0},
                [self.colors['text']] = {[4] = 0},
                [self.colors['background']] = {[4] = 0}
            }):finish(function() gStateStack:pop() end)
        end
        local y = self.y + 10
        for i, object in pairs(self.data) do

            if object.value then
                y = y + object.font:getHeight()
                love.graphics.printf(object.value, self.x, y, self.width, 'center')

                object.value = object.value == object.randomval and 'random' or object.value
                local objectStringLength = object.width
                object.value = object.value == 'random' and NUM_LEVELS or object.value

                local width = 20

                local x = self.x + (self.width - objectStringLength) / 2 - 3 * width
                local v = {x, y + object.font:getHeight() / 2, x + width, y, x + width, y + object.font:getHeight()}
                if pointInPolygon({mouseX, mouseY}, v) then
                    object.arrowFunction(-1)
                    break
                end

                local x = self.x + (self.width + objectStringLength) / 2 + 2 * width
                local v = {x + width, y + object.font:getHeight() / 2, x, y, x, y + object.font:getHeight()}
                if pointInPolygon({mouseX, mouseY}, v) then
                    object.arrowFunction(1)
                    break
                end
            else
                local object_width = object.font:getWidth(object.text)
                local object_x = self.x + self.width / 2 - object_width / 2
                local object_height = object.font:getHeight()
                local v = {object_x, y, object_x + object_width, y, object_x + object_width, y + object_height, object_x, y + object_height}
                if pointInPolygon({mouseX, mouseY}, v) then
                    object.enter()
                    break
                end
            end

            y = y + object.font:getHeight() * 1.5
        end
    end
end

function LevelSelectState:render()
    -- transluscent background
    love.graphics.setColor(self.colors['background'])
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setColor(self.colors['panel'])
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 10)

    local y = self.y + 10

    for i, object in pairs(self.data) do
        if i == self.highlighted + 1 then
            love.graphics.setColor(200, 0, 0, self.colors['text'][4])
        else
            love.graphics.setColor(self.colors['text'])
        end
        love.graphics.setFont(object.font)
        love.graphics.printf(object.text, self.x, y, self.width, 'center')
        if object.value then
            object.value = object.value == object.randomval and 'random' or object.value
            y = y + object.font:getHeight()
            love.graphics.printf(object.value, self.x, y, self.width, 'center')

            local width = 20

            local x = self.x + (self.width - object.width) / 2 - 3 * width
            local v = {x, y + object.font:getHeight() / 2, x + width, y, x + width, y + object.font:getHeight()}
            love.graphics.polygon('fill', v)

            local x = self.x + (self.width + object.width) / 2 + 2 * width
            local v = {x + width, y + object.font:getHeight() / 2, x, y, x, y + object.font:getHeight()}
            love.graphics.polygon('fill', v)

            object.value = object.value == 'random' and NUM_LEVELS or object.value
        end

        y = y + object.font:getHeight() * 1.5
    end

    for i, button in pairs(self.buttons) do
        button:render()
    end
end
