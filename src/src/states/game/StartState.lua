StartState = Class{__includes = BaseState}

function StartState:init()
    self.positions = {
        ['title'] = {x = 0, y = -gFonts['large']:getHeight()},
        ['background'] = {x = 0, y = VIRTUAL_HEIGHT},
        ['menu'] = {x = 0, y = VIRTUAL_HEIGHT}
    }
    Timer.tween(1, {
        [self.positions['title']] = {y = VIRTUAL_HEIGHT / 2 - gFonts['large']:getHeight()},
        [self.positions['background']] = {y = 0},
        [self.positions['menu']] = {y = 0}
    })
    -- self.positions['title'] = {y = VIRTUAL_HEIGHT / 2 - gFonts['large']:getHeight()}
    self.background = gBackgroundState
    self.background.rotation = 0
    self.highlighted = 3
    self.options = {
        {
            ["text"] = "Play",
            ["enter"] = function() gStateStack:push(LevelSelectState(
                {
                {
                    ["text"] = "Start",
                    ["font"] = gFonts['medium-bigger'],
                    ["arrowFunction"] = function(incr) end,
                    ["enter"] = function()
                        local numPlayers = gStateStack.states[#gStateStack.states].data[2].value
                        local level = gStateStack.states[#gStateStack.states].data[3].value

                        local enterPlayState = function()
                            AI = {}
                            for i = 1, numPlayers do
                                table.insert(AI, gStateStack.states[#gStateStack.states].data[i + 1].value == 'AI')
                            end

                            gStateStack:pop()
                            gStateStack:pop()
                            gStateStack:pop()
                            gStateStack:push(PlayState(numPlayers, level, AI))
                            gStateStack:push(FadeOutState({r = 255, g = 255, b = 255}, 0.2, function() end))
                        end

                        local stateOptions = {
                            {
                                ['text'] = "Play",
                                ['enter'] = function() enterPlayState() end,
                                ["font"] = gFonts['medium-bigger'],
                            }
                        }

                        for i = 1, numPlayers do
                            stateOptions[i + 1] = {
                                ['text'] = "Player " .. tostring(i),
                                ['value'] = 'User',
                                ['arrowFunction'] = function(incr)
                                    local k = gStateStack.states[#gStateStack.states].data[1 + i].value
                                    gStateStack.states[#gStateStack.states].data[1 + i].value = k == 'AI' and 'User' or 'AI'
                                end,
                                ['enter'] = function() enterPlayState() end,
                                ["font"] = gFonts['medium-smaller'],
                            }
                        end

                        gStateStack:push(LevelSelectState(stateOptions, true))
                    end,
                },
                {
                    ["text"] = "Number of players",
                    ["arrowFunction"] = function(incr)
                        gStateStack.states[#gStateStack.states].data[2].value = scaleIncrement(gStateStack.states[#gStateStack.states].data[2].value, 2, MAX_PLAYERS, incr)
                    end,
                    ["enter"] = function() gStateStack.states[#gStateStack.states].data[1]['enter']() end,
                    ["font"] = gFonts['medium-smaller'],
                    ["value"] = 2
                },
                {
                    ["text"] = "Level",
                    ["arrowFunction"] = function(incr)
                        gStateStack.states[#gStateStack.states].data[3].value = scaleIncrement(gStateStack.states[#gStateStack.states].data[3].value, 1, NUM_LEVELS, incr)
                    end,
                    ["enter"] = function() gStateStack.states[#gStateStack.states].data[1]['enter']() end,
                    ["font"] = gFonts['medium-smaller'],
                    ["randomval"] = NUM_LEVELS,
                    ["value"] = 1
                }
            }, true)) end
        },
        {
            ["text"] = "Rules",
            ["enter"] = function() gStateStack:push(ScrollState(HELP_DATA, true)) end
        },
        {
            ["text"] = "Credits",
            ["enter"] = function() gStateStack:push(ScrollState(CREDITS_DATA, true)) end
        },
        {
            ["text"] = "Settings",
            ["enter"] = function() gStateStack:push(SettingsState()) end
        }
    }
end

function StartState:update(dt)
    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())

    self.background:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if love.keyboard.wasPressed('up') then
        self.highlighted = (self.highlighted - 1) % #self.options
        gSoundEffects['menu-select']:play()
    end

    if love.keyboard.wasPressed('down') then
        self.highlighted = (self.highlighted + 1) % #self.options
        gSoundEffects['menu-select']:play()
    end

    if love.keyboard.wasPressed('return') then
        self.options[self.highlighted + 1].enter()
    end
    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    if love.mouse.keysPressed[1] then
        for i, object in pairs(self.options) do
            font = object.font or gFonts['medium']

            local object_y = VIRTUAL_HEIGHT / 2 + (i - 1) * 1.5 * font:getHeight()
            local object_width = font:getWidth(object.text)
            local object_height = font:getHeight()
            local object_x = 0 + VIRTUAL_WIDTH / 2 - object_width / 2
            local v = {object_x, object_y, object_x + object_width, object_y, object_x + object_width, object_y + object_height, object_x, object_y + object_height}

            if pointInPolygon({mouseX, mouseY}, v) then
                object.enter()
                break
            end
        end
    end
end

function StartState:render()
    love.graphics.clear(255, 255, 255, 50)

    self.background:render(self.positions['background'])
    love.graphics.setColor(255, 255, 255, 150)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 200)

    love.graphics.translate(self.positions['menu'].x, self.positions['menu'].y)
    for i, object in pairs(self.options) do
        font = object.font or gFonts['medium']
        if self.highlighted + 1 == i then
            love.graphics.setColor(255, 0, 0, 200)
        else
            love.graphics.setColor(0, 0, 0, 200)
        end
        love.graphics.setFont(font)
        love.graphics.printf(object.text, 0, VIRTUAL_HEIGHT / 2 + (i - 1) * 1.5 * font:getHeight(), VIRTUAL_WIDTH, 'center')
    end
    love.graphics.translate(-self.positions['menu'].x, - self.positions['menu'].y)

    love.graphics.setFont(gFonts['large'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.printf("PENTALINK", 0, self.positions['title'].y, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("Version "..tostring(VERSION_NUMBER), 0, VIRTUAL_HEIGHT - gFonts['small']:getHeight(), VIRTUAL_WIDTH)
end
