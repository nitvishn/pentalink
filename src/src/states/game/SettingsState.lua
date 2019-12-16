SettingsState = Class{__includes = BaseState}

function SettingsState:init()
    print_r(gSettings)
    --[[
        We need settings for:
        - Detailed score breakdown at the end
        - Whether undo is permitted
        - Volume sliders
    ]]
    self.width = 3 * VIRTUAL_WIDTH / 5
    self.height = 3 * VIRTUAL_HEIGHT / 4

    self.x = (VIRTUAL_WIDTH - self.width) / 2
    self.y = (VIRTUAL_HEIGHT - self.height) / 2
    self.leftMargin = 50
    self.rightMargin = 50
    self.sliderwidth = 250
    self.horizontalSpacing = 30

    -- color data
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

    self.fonts = {
        ['body'] = gFonts['medium'],
        ['title'] = gFonts['titlefont'],
        ['caption'] = gFonts['small']
    }

    self.objects = {
        Button(
            gTextures['buttons']['exit'],
            0, 0, ICON_SIZE, ICON_SIZE, nil,
            function() end
        )
    }

    self.toggles = {
        {
            ['text'] = "Enable undo move",
            ['setting'] = 'enableUndo',
        },
        {
            ['text'] = "Show vertex numbers",
            ['setting'] = 'displayVertex'
        },
        {
            ['text'] = "Display background animation",
            ['setting'] = 'showBackground'
        },
        {
            ['text'] = "Fullscreen",
            ['setting'] = 'fullscreen',
            ['onchange'] = function()
                -- love.window.setFullscreen(gSettings['fullscreen'])
                setupScreen()
            end
        }
    }

    self.selectors = {
        {
            ['text'] = "Display resolution",
            ['setting'] = 'displayResolution',
            ['values'] = DISPLAY_RESOLUTIONS,
            ['onchange'] = function()
                setupScreen()
            end
        },
    }

    self.sliders = {
        {
            ['text'] = "Sound Effects",
            ['setting'] = "sfxVolume",
            ['lower'] = 0,
            ['upper'] = 1,
        },
        {
            ['text'] = "Music (coming soon!)",
            ['setting'] = "musicVolume",
            ['lower'] = 0,
            ['upper'] = 1,
        }
    }

    local maxWidth = 0
    for i = 1, #self.toggles do
        maxWidth = math.max(self.fonts.body:getWidth(self.toggles[i].text), maxWidth)
    end
    local y = self.y + self.fonts.title:getHeight() + self.horizontalSpacing
    local size = self.fonts.body:getHeight()
    for i = 1, #self.toggles do
        self.toggles[i].toggle = Toggle(self.x + self.width - 2 * size - self.rightMargin, y, self.toggles[i].setting, gSettings[self.toggles[i].setting], size)
        y = y + size + self.horizontalSpacing
    end
    for i = 1, #self.selectors do
        local object = self.selectors[i]
        object.selector = ValueSelector(self.x, y, object.setting, object.values, gSettings[object.setting], self.fonts.body)
        object.selector.x = self.x + self.width - object.selector.width
        y = y + size + self.horizontalSpacing
    end
    for i = 1, #self.sliders do
        object = self.sliders[i]
        object.slider = Slider(
            self.x + self.width - self.sliderwidth - self.rightMargin,
            y + SLIDER_HEIGHT / 2, object.setting, self.sliderwidth, object.lower, object.upper, gSettings[object.setting]
        )
        y = y + size + self.horizontalSpacing
    end
end

function SettingsState:fadeOutAndPop()
    if not self.exited then
        self.exited = true
        Timer.tween(0.25, {
            [self.colors['panel']] = {[4] = 0},
            [self.colors['text']] = {[4] = 0},
            [self.colors['background']] = {[4] = 0}
        }):finish(function() gStateStack:pop() end)
    end
end

function SettingsState:update(dt)
    print_r(gSettings)
    for i, object in pairs(self.objects) do
        object:update(dt)
    end
    if love.keyboard.wasPressed('escape') or love.keyboard.wasPressed('return') then
        self:fadeOutAndPop()
    end

    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    if love.mouse.keysPressed[1] and mouseX and mouseY then
        if not checkCollision(mouseX, mouseY, self) then
            self:fadeOutAndPop()
        end
    end

    if gStateStack.states[1].background then
        gStateStack.states[1].background:update(dt)
    end

    for i = 1, #self.toggles do
        self.toggles[i].toggle:update(dt)
        if gSettings[self.toggles[i].toggle.id] ~= self.toggles[i].toggle.value then
            gSettings[self.toggles[i].toggle.id] = self.toggles[i].toggle.value
            if self.toggles[i].onchange then
                self.toggles[i].onchange()
            end
        end
    end
    for i = 1, #self.selectors do
        self.selectors[i].selector:update(dt)
        if gSettings[self.selectors[i].selector.id] ~= self.selectors[i].selector.current_index then
            gSettings[self.selectors[i].selector.id] = self.selectors[i].selector.current_index
            if self.selectors[i].onchange then
                self.selectors[i].onchange()
            end
        end
    end
    for i = 1, #self.sliders do
        self.sliders[i].slider:update(dt)
        gSettings[self.sliders[i].slider.id] = self.sliders[i].slider.value
    end
    setupVolume()
    writeSettings()
end

function SettingsState:render()
    -- transluscent background
    love.graphics.setColor(self.colors['background'])
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setColor(self.colors['panel'])
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 10)

    local y = self.y

    love.graphics.setColor(self.colors['text'])
    love.graphics.setFont(self.fonts['title'])
    love.graphics.printf("Settings", self.x, y, self.width, 'center')
    y = y + self.fonts['title']:getHeight() + self.horizontalSpacing

    love.graphics.setFont(self.fonts['body'])
    for i = 1, #self.toggles do
        love.graphics.setColor(self.colors['text'])
        love.graphics.printf(self.toggles[i].text, self.x + self.leftMargin, y, self.width - self.leftMargin, 'left')
        y = y + self.fonts['body']:getHeight() + self.horizontalSpacing
        self.toggles[i].toggle:render()
    end

    for i = 1, #self.selectors do
        love.graphics.setColor(self.colors['text'])
        love.graphics.printf(self.selectors[i].text, self.x + self.leftMargin, y, self.width - self.leftMargin, 'left')
        y = y + self.fonts['body']:getHeight() + self.horizontalSpacing
        self.selectors[i].selector:render()
    end

    for i = 1, #self.sliders do
        love.graphics.setColor(self.colors['text'])
        love.graphics.printf(self.sliders[i].text, self.x + self.leftMargin, y, self.width - self.leftMargin, 'left')
        y = y + self.fonts['body']:getHeight() + self.horizontalSpacing
        self.sliders[i].slider:render()
    end

    for i, object in pairs(self.objects) do
        object:render()
    end
end
