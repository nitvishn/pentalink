Toggle = Class{}

function Toggle:init(x, y, id, value, size)
    self.id = id
    self.x = x
    self.y = y
    self.size = size or TOGGLE_SIZE

    self.width = 2 * self.size
    self.height = self.size

    self.value = value
    self.colorLibrary = {
        ['green'] = {48, 209, 88},
        ['red'] = {255, 149, 0}
    }

    self.colors = {
        ['circle'] = {255, 255, 255},
        ['toggleBackground'] = {0, 255, 0}
    }

    if self.value then
        self.circle = {x = self.x + self.size / 2 + self.size, y = self.y + self.size / 2}
        self.colors['toggleBackground'][1] = self.colorLibrary['green'][1]
        self.colors['toggleBackground'][2] = self.colorLibrary['green'][2]
        self.colors['toggleBackground'][3] = self.colorLibrary['green'][3]
    else
        self.circle = {x = self.x + self.size / 2, y = self.y + self.size / 2}
        self.colors['toggleBackground'][1] = self.colorLibrary['red'][1]
        self.colors['toggleBackground'][2] = self.colorLibrary['red'][2]
        self.colors['toggleBackground'][3] = self.colorLibrary['red'][3]
    end
end

function Toggle:update(dt)
    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    if love.mouse.keysPressed[1] and mouseX and mouseY then
        if checkCollision(mouseX, mouseY, self) then
            self:click()
        end
    end
end

function Toggle:click()
    self.value = not self.value
    if self.value then
        Timer.tween(0.3, {
            [self.colors['toggleBackground']] = {[1] = self.colorLibrary['green'][1], [2] = self.colorLibrary['green'][2], [3] = self.colorLibrary['green'][3]},
            [self.circle] = {x = self.x + self.size + self.size / 2}
        })
    else
        Timer.tween(0.3, {
            [self.colors['toggleBackground']] = {[1] = self.colorLibrary['red'][1], [2] = self.colorLibrary['red'][2], [3] = self.colorLibrary['red'][3]},
            [self.circle] = {x = self.x + self.size / 2}
        })
    end
end

function Toggle:render()
    r, g, b = getColorComponents(self.colors['toggleBackground'])
    x, q, c, a = love.graphics.getColor()
    love.graphics.setColor(r, g, b, a)

    love.graphics.stencil(function()
        love.graphics.circle('fill', self.x + self.size / 2, self.y + self.size / 2, self.size / 2)
        love.graphics.circle('fill', self.x + self.size + self.size / 2, self.y + self.size / 2, self.size / 2)
    end, "replace", 1)
    love.graphics.setStencilTest("notequal", 1)
    love.graphics.rectangle('fill', self.x + self.size / 2, self.y, self.size, self.size)
    love.graphics.setStencilTest()
    love.graphics.circle('fill', self.x + self.size / 2, self.y + self.size / 2, self.size / 2)
    love.graphics.circle('fill', self.x + self.size + self.size / 2, self.y + self.size / 2, self.size / 2)

    r, g, b = getColorComponents(self.colors['circle'])
    love.graphics.setColor(r, g, b, a)
    love.graphics.circle('fill', self.circle.x, self.circle.y, self.size / 2 - 5)
end
