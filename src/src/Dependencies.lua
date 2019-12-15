Class = require 'lib/class'
push = require 'lib/push'
Event = require 'lib/knife.event'
Timer = require 'lib/knife.timer'
-- requests = require 'lib/requests'


require 'src/constants'
require 'src/TextData'
require 'src/Util'
require 'src/Graph'
require 'src/Level'
require 'src/entities/Player'
require 'src/entities/Triangle'

require 'src/states/BaseState'
require 'src/states/StateStack'

require 'src/states/game/StartState'
require 'src/states/game/PlayState'
require 'src/states/game/PlayStateDataFrame'
require 'src/states/game/GameOverState'
require 'src/states/game/LevelSelectState'
require 'src/states/game/TextBoxState'
require 'src/states/game/ScrollState'
require 'src/states/game/FadeInState'
require 'src/states/game/FadeOutState'
require 'src/states/game/BackgroundState'
require 'src/states/game/LevelCreateState'

require 'src/gui/Textbox'
require 'src/gui/Panel'
require 'src/gui/ScrollBar'
require 'src/gui/Button'

gFonts = {
    ['small'] = love.graphics.newFont('fonts/Antaro.ttf', 20),
    ['slightlybigger'] = love.graphics.newFont('fonts/Antaro.ttf', 25),
    ['medium-smaller'] = love.graphics.newFont('fonts/Antaro.ttf', 30),
    ['medium'] = love.graphics.newFont('fonts/Antaro.ttf', 40),
    ['medium-bigger'] = love.graphics.newFont('fonts/Antaro.ttf', 50),
    ['titlefont'] = love.graphics.newFont('fonts/Antaro.ttf', 60),
    ['large'] = love.graphics.newFont('fonts/Antaro.ttf', LARGE_FONT_SIZE)
}

gSounds = {
    ['menu-select'] = love.audio.newSource('sounds/menu_select.wav'),
    ['deny-connection'] = love.audio.newSource('sounds/deny_connection.wav')
}

gTextures = {
    ['buttons'] = {
        ['exit'] = love.graphics.newImage('graphics/buttons/exit.png'),
        ['home'] = love.graphics.newImage('graphics/buttons/home.png'),
        ['undo'] = love.graphics.newImage('graphics/buttons/undo.png'),
        ['redo'] = love.graphics.newImage('graphics/buttons/redo.png'),
        ['hamburger'] = love.graphics.newImage('graphics/buttons/hamburger.png')
    }
}
