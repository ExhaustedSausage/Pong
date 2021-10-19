Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:update(dt)
    if self.dy < 0 then

        self.y = math.max(0, self.y + self.dy * dt)

    elseif self.dy > 0 then

        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

-- Bot functionality
function Paddle:left_track()
    if self.y > ball.y and ball.dx < 0 then
        if ball.x < VIRTUAL_WIDTH / 1.125 then
            self.dy = - PADDLE_SPEED
        end
    elseif self.y < ball.y and ball.dx < 0 then
        if ball.x < VIRTUAL_WIDTH / 1.125 then
            self.dy = PADDLE_SPEED
        end
    end
end

function Paddle:righttrack()
    if self.y > ball.y  and ball.dx > 0 then
        if ball.x > VIRTUAL_WIDTH / 3 then
                self.dy = - PADDLE_SPEED
        end
    elseif self.y < ball.y and ball.dx > 0 then
        if ball.x > VIRTUAL_WIDTH / 3 then
            self.dy = PADDLE_SPEED
        end
    end

end
