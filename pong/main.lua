WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 350

MAX_SCORE = 3

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

--[[
    Runs when the game starts up, only once; used to initialize the game.
]]
function love.load()
    math.randomseed(os.time())

    love.window.setTitle("Pong")

    font = love.graphics.newFont('04B_03__.TTF', 8)

    scoreFont = love.graphics.newFont('04B_03__.TTF', 32)

    victoryFont = love.graphics.newFont('04B_03__.TTF', 24)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sfx/paddle_hit.wav', 'static'),
        ['serve'] = love.audio.newSource('sfx/tennisserve.wav', 'static'),
        ['edge_hit'] = love.audio.newSource('sfx/edge_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sfx/score.wav', 'static'),
    }

    p1Score = 0
    p2Score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2

    player1 = Paddle(10, 30, 5, 40)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 40)
    ball = Ball(VIRTUAL_WIDTH / 2 - 3, VIRTUAL_HEIGHT / 2 - 3, 6, 6)

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = - 100
    end

    gameState = 'start'

    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH,
    VIRTUAL_HEIGHT,
    WINDOW_WIDTH,
    WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
    })
end

function love.resize(w, h)
    push:resize(w, h) 
end

function love.update(dt)

    if gameState == 'start' then
        p1Score = 0
        p2Score = 0
    end

    if gameState == 'serve' then

        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        elseif servingPlayer == 2 then
            ball.dx = - math.random(140, 200)
        end
    end

    if ball.x <= 0 then
        p2Score = p2Score + 1
        sounds['score']:setVolume(.35)
        sounds['score']:play()
        ball:reset()
        servingPlayer = 1

        if p2Score == MAX_SCORE then
            gameState = 'victory'
            winningPlayer = 2
        else
            gameState = "serve"
        end
    
    elseif ball.x >= VIRTUAL_WIDTH - ball.width then
        p1Score = p1Score + 1
        sounds['score']:setVolume(.35)
        sounds['score']:play()
        ball:reset()
        servingPlayer = 2

        if p1Score == MAX_SCORE then
            gameState = 'victory'
            winningPlayer = 1
        else
            gameState = "serve"
        end
    end

    if ball:collides(player1) then

        sounds['paddle_hit']:play()
        ball.dx = -ball.dx * ( 1 + math.random(15)/100)
        ball.x = player1.x + 6

        if ball.dy < 0 then
            ball.dy = - math.random(30, 300)
        else
            ball.dy = math.random(30, 300)
        end

    elseif ball:collides(player2) then
        
        sounds['paddle_hit']:play()
        ball.dx = - ball.dx * (1 + math.random(15)/100)
        ball.dy = math.random()
        ball.x = player2.x - 6

        if ball.dy < 0 then
            ball.dy = - math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

    end

    if ball.y <= 0 then
        ball.y = 0
        ball.dy = - ball.dy
        sounds['edge_hit']:play()
        

    elseif ball.y >= VIRTUAL_HEIGHT - ball.height then
        sounds['edge_hit']:play()
        ball.dy = - ball.dy
        ball.y = VIRTUAL_HEIGHT - ball.height
    end

    if love.keyboard.isDown("w") then

        player1.dy = -PADDLE_SPEED
        
    elseif love.keyboard.isDown("s") then

        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown("up") then

        player2.dy = -PADDLE_SPEED

    elseif love.keyboard.isDown("down") then

        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
        player2:righttrack()
    end
    
    -- UNCOMMENT TO MAKE CPU player
    --player1:left_track()
    --player2:righttrack()

    player1:update(dt)
    player2:update(dt)
end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
            sounds['serve']:setVolume(0.8)
            sounds['serve']:play()
        elseif gameState == 'victory' then
            gameState = 'start'
        end
    end
end

--[[
    Called after update by LOVE, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    
    love.graphics.setFont(font)

    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Play", 0, 32, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'serve' then
        if (servingPlayer == 1) then
            love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn", 0, 20, VIRTUAL_WIDTH, 'center')
            love.graphics.printf("Press Enter to Serve", 0, 32, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.printf("CPU's turn", 0, 20, VIRTUAL_WIDTH, 'center')
            love.graphics.printf("Press Enter to Serve", 0, 32, VIRTUAL_WIDTH, 'center')
        end
    
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        if winningPlayer == 1 then
            love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.printf("CPU wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        end

        love.graphics.setFont(font)
        love.graphics.printf("Press Enter to Play Again", 0, 42, VIRTUAL_WIDTH, 'center')
    end

    displayScore()

    player1:render()
    player2:render()

    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(font)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end

function displayScore()

    love.graphics.setFont(scoreFont)
    love.graphics.print(p1Score, VIRTUAL_WIDTH / 2 -50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(p2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end
