ScrollBar = Class{}

function ScrollBar:init(x, value, range, width, height)
    self.x = x
    self.value = value
    self.width = width
    self.range = range
    self.y = (VIRTUAL_HEIGHT - height) * (value / range)
    self.height = height

    self.dragging = {
        ['active'] = false,
        ['diffX'] = nil,
        ['diffY'] = nil
    }
end

function ScrollBar:updateValue(value)
    self.value = value
    self.y = (VIRTUAL_HEIGHT - self.height) * (value / self.range)
end

function ScrollBar:render(color)
    color = color or {50, 50, 50}
    love.graphics.setColor(color)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 10)
end
