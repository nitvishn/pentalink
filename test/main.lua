Timer = require 'knife.timer'
Class = require 'class'

require 'Toggle'
require 'ValueSelector'
require 'Slider'

gFonts = {
    ['small'] = love.graphics.newFont('fonts/Antaro.ttf', 20),
    ['slightlybigger'] = love.graphics.newFont('fonts/Antaro.ttf', 25),
    ['medium-smaller'] = love.graphics.newFont('fonts/Antaro.ttf', 30),
    ['medium'] = love.graphics.newFont('fonts/Antaro.ttf', 40),
    ['medium-bigger'] = love.graphics.newFont('fonts/Antaro.ttf', 50),
    ['titlefont'] = love.graphics.newFont('fonts/Antaro.ttf', 60),
    ['large'] = love.graphics.newFont('fonts/Antaro.ttf', LARGE_FONT_SIZE)
}

function love.load()
    push = require 'push'

    VIRTUAL_WIDTH = 1440
    VIRTUAL_HEIGHT = 900

    push:setupScreen(1440, 900, 0, 0, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    objects = {
        Toggle(500, 82, 'undo_permitted', true, 50),
        ValueSelector(50, 50, 'numbers', {1, 2, 3, 4, 5}, 1, gFonts['medium'], 200),
        Slider(200, 200, 'volume', 250, 0, 100, 50)
    }

    love.mouse.wasPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    Timer.update(dt)

    for i = 1, #objects do
        objects[i]:update(dt)
    end

    love.mouse.wasPressed = {}
end

function love.mousepressed(x, y, button)
    love.mouse.wasPressed[button] = true
end

function love.draw()
    push:start()

    love.graphics.clear(255, 255, 255, 255)

    for i = 1, #objects do
        objects[i]:render()
    end

    push:finish()
end

function checkCollision(x, y, object)
    if x > object.x and x < object.x + object.width and y > object.y and y < object.y + object.height then
        return true
    end
    return false
end

function print_r ( t )
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val, indent..string.rep(" ", string.len(pos) + 8))
                        print(indent..string.rep(" ", string.len(pos) + 6).."}")
                    elseif (type(val) == "string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t) == "table") then
        print(tostring(t).." {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end

function pointInPolygon(point, vertices)
    poly = {}

    for i = 1, #vertices, 2 do
        if point[1] == vertices[i] and point[2] == vertices[i + 1] then
            return false
        end
    end

    for i = 1, #vertices - 1, 2 do
        table.insert(poly, {vertices[i], vertices[i + 1]})
    end

    n = #poly
    inside = false
    x = point[1]
    y = point[2]
    p1x = poly[1][1]
    p1y = poly[1][2]
    for i = 0, n do
        p2x = poly[(i % n) + 1][1]
        p2y = poly[(i % n) + 1][2]
        -- print((i % n) + 1)
        if y > math.min(p1y, p2y) then
            if y <= math.max(p1y, p2y) then
                if x <= math.max(p1x, p2x) then
                    if p1y ~= p2y then
                        xints = (y - p1y) * (p2x - p1x) / (p2y - p1y) + p1x
                    end
                    if p1x == p2x or x <= xints then
                        inside = not inside
                    end
                end
            end
        end
        p1x = p2x
        p1y = p2y
    end

    return inside
end

function scaleIncrement(value, lower, upper, incr)
    if incr > 0 then
        while incr > 0 do
            value = value + 1
            incr = incr - 1
            if value > upper then
                value = lower
            end
        end
    elseif incr < 0 then
        while incr < 0 do
            value = value - 1
            incr = incr + 1
            if value < lower then
                value = upper
            end
        end
    end
    return value
end
