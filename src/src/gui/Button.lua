Button = Class{}

function Button:init(image, x, y, width, height, color, onclick)
    self.image = image
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.onclick = onclick
    self.color = color
end

function Button:update()
    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    local v = {self.x, self.y, self.x + self.width, self.y, self.x + self.width, self.y + self.height, self.x, self.y + self.height}
    if mouseX and mouseY and love.mouse.keysPressed[1] and pointInPolygon({mouseX, mouseY}, v) then
        self.onclick()
    end
end

function Button:render()
    if self.color then
        love.graphics.setColor(self.color)
    else
        r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(255, 255, 255, a)
    end
    love.graphics.draw(self.image, self.x, self.y, 0, self.width / self.image:getWidth(), self.height / self.image:getHeight())
end
