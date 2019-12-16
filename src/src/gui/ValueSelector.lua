ValueSelector = Class{}

function ValueSelector:init(x, y, id, values, selected_index, font, minwidth)
    self.x = x
    self.y = y

    self.id = id
    self.values = values
    self.current_index = selected_index

    self.font = font
    self.height = font:getHeight()
    self.width = minwidth or 0
    self.trianglewidth = self.height / 1.5

    for i = 1, #self.values do
        self.width = math.max(self.width, self.font:getWidth(self.values[i]) + 3 * self.trianglewidth)
    end

    self.valueTween = {
        ['prev'] = {value = nil, x = nil},
        ['next'] = {value = nil, x = nil}
    }
    self.tweening = false
    self.tweenTime = 0.25
end

function ValueSelector:update(dt)
    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    if love.mouse.keysPressed[1] and mouseX and mouseY then
        local v = {self.x, self.y + self.height / 2, self.x + self.trianglewidth, self.y, self.x + self.trianglewidth, self.y + self.height}
        if pointInPolygon({mouseX, mouseY}, v) then
            self.valueTween.prev.value = self.values[self.current_index]
            self.valueTween.prev.x = self.x
            self:increment(-1)
            self.valueTween.next.value = self.values[self.current_index]
            self.valueTween.next.x = self.x - self.width
            self.tweening = true
            Timer.tween(self.tweenTime, {
                [self.valueTween['next']] = {x = self.x},
                [self.valueTween['prev']] = {x = self.x + self.width}
            }):finish(function() self.tweening = false end)
        end

        local v = {self.x + self.width, self.y + self.height / 2, self.x + self.width - self.trianglewidth, self.y, self.x + self.width - self.trianglewidth, self.y + self.height}
        if pointInPolygon({mouseX, mouseY}, v) then
            if pointInPolygon({mouseX, mouseY}, v) then
                self.valueTween.prev.value = self.values[self.current_index]
                self.valueTween.prev.x = self.x
                self:increment(1)
                self.valueTween.next.value = self.values[self.current_index]
                self.valueTween.next.x = self.x + self.width
                self.tweening = true
                Timer.tween(self.tweenTime, {
                    [self.valueTween['next']] = {x = self.x},
                    [self.valueTween['prev']] = {x = self.x - self.width}
                }):finish(function() self.tweening = false end)
            end
        end
    end
end

function ValueSelector:increment(num)
    self.current_index = scaleIncrement(self.current_index, 1, #self.values, num)
end

function ValueSelector:render()
    r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0, a)

    love.graphics.setFont(self.font)

    if self.tweening then
        love.graphics.stencil(function() love.graphics.rectangle('fill', self.x + self.trianglewidth, self.y, self.width - 2 * self.trianglewidth, self.height) end, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.printf(self.valueTween.prev.value, self.valueTween.prev.x, self.y, self.width, 'center')
        love.graphics.printf(self.valueTween.next.value, self.valueTween.next.x, self.y, self.width, 'center')
        love.graphics.setStencilTest()
    else
        love.graphics.printf(self.values[self.current_index], self.x, self.y, self.width, 'center')
    end

    love.graphics.setColor(0, 0, 0, a)
    local v = {self.x, self.y + self.height / 2, self.x + self.trianglewidth, self.y, self.x + self.trianglewidth, self.y + self.height}
    love.graphics.polygon('fill', v)

    local v = {self.x + self.width, self.y + self.height / 2, self.x + self.width - self.trianglewidth, self.y, self.x + self.width - self.trianglewidth, self.y + self.height}
    love.graphics.polygon('fill', v)
end
