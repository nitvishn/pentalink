Slider = Class{}

function Slider:init(x, y, id, width, lower, upper, value)
    self.id = id
    self.x = x
    self.y = y
    self.width = width
    self.height = SLIDER_HEIGHT

    self.upper = upper
    self.lower = lower
    self.value = value

    -- self.colors
    self.dragging = false
    self.circleX = self.x + self.width * (self.value - self.lower) / (self.upper - self.lower)
end

function Slider:update(dt)
    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    if love.mouse.keysPressed[1] and mouseX and mouseY then
        if checkCollision(mouseX, mouseY, self) then
            self.dragging = true
        end
    end

    if not love.mouse.isDown(1) then
        self.dragging = false
    end

    if self.dragging and mouseX and mouseY then
        self.circleX = math.max(math.min(mouseX, self.x + self.width), self.x)
    end
    self.value = (((self.circleX - self.x) * (self.upper - self.lower)) / (self.x + self.width - self.x)) + self.lower
end

function Slider:render()
    -- love.graphics.setColor(100, 100, 0, 100)
    -- love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(150, 150, 150, a)
    love.graphics.rectangle('fill', self.x + self.height / 4, self.y + self.height / 4, self.width - self.height / 2, self.height / 2)
    love.graphics.circle('fill', self.x + self.height / 4, self.y + self.height / 4 + self.height / 4, self.height / 4)
    love.graphics.circle('fill', self.x + self.width - self.height / 4, self.y + self.height / 4 + self.height / 4, self.height / 4)

    love.graphics.setColor(0, 0, 0, a)
    love.graphics.circle('fill', self.circleX, self.y + self.height / 4 + self.height / 4, self.height / 2)
end
