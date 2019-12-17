require 'src/Dependencies'

function love.load()
    love.physics.setMeter(METRE_LENGTH)
    love.window.setTitle('Pentalink')
    -- love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    readSettings()

    setupScreen()
    setupVolume()
    -- love.window.setFullscreen(true, "desktop")

    gStateStack = StateStack()
    gBackgroundState = BackgroundState(NUM_LEVELS)
    gStateStack:push(StartState(1, 3))

    love.keyboard.keysPressed = {}
    love.mouse.keysPressed = {}
    love.mouse.scroll = {x = 0, y = 0}
    love.mouse.dragging = false
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.mousepressed(x, y, button, istouch)
    love.mouse.keysPressed[button] = true
    love.mouse.dragging = true
end

function love.wheelmoved(x, y)
    love.mouse.scroll.y = y
    love.mouse.scroll.x = x
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    Timer.update(dt)
    gStateStack:update(dt)

    love.keyboard.keysPressed = {}
    love.mouse.keysPressed = {}
    love.mouse.scroll = {x = 0, y = 0}
end

function love.draw()
    push:start()
    gStateStack:render()
    push:finish()
end
