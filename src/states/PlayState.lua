--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
    ]]
function PlayState:enter(params)

    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level

    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)

    -- init new powerup
    self.powerup = Powerup()
    self.powerup.x = math.random(self.powerup.width, VIRTUAL_WIDTH - self.powerup.width)
    self.powerup.y = math.random(0,50)

    -- init a variable to store the number of total balls that will be initiated 
    self.totalBallCount = 8

    -- init a variable to store the number of variable that have been reset
    self.lastBallCount = 0

    -- init balls which will be used after powerup hit
    -- table to store powerBalls
    self.powerBalls = {}
    for i = 1, 8 do

        --init balls
        self.powerBalls[i] = Ball()
        self.powerBalls[i].skin = math.random(7)

        -- new balls spawn location
        self.powerBalls[i].x = VIRTUAL_WIDTH / 2
        self.powerBalls[i].y = VIRTUAL_HEIGHT - 48

        -- give new balls random initial velocity
        if i % 2 == 0 then
            self.powerBalls[i].dx = math.random(-200, 100)
          else
            self.powerBalls[i].dx = math.random(-100, 200)
          end
          self.powerBalls[i].dy = math.random(-50, -60)
          
    end

    -- init a table to check if the paddle is incremented once
    hasIncremented = {false, false, false, false}

    -- init a variable to store the current level score
    levelScore = 0

    -- init a variable to store the last level score
    if self.level == 1 and self.score == 0 then
        lastLevelScore = 0
    end
    
    -- init new bricks
    self.brick = Brick()
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    self.ball:update(dt)


    -- update the Timer
    self.brick.timer = self.brick.timer + dt
    
    if self.brick.timer >= 3 then
        self.powerup.inPlay = true 
        self.powerup:update(dt)
        self.powerup.dy = 40;
    end

    -- Check for collision of balls with paddle
    self:checkCollision(self.ball, self.paddle)
    for i = 1, self.ball.ballCount do
        self:checkCollision(self.powerBalls[i], self.paddle)
    end

    -- detect collision of powerup with the paddle
    if self.powerup:collides(self.paddle) then
        gSounds['powerup']:play()

        -- If the powerup is hit then paddle has power
        self.ball.ballCount = self.ball.ballCount + 2

        -- if the ballCount goes beyond 8 then reset the 2 balls from earlier
        if self.ball.ballCount > 8 then
            -- total balls yet spawned
            self.totalBallCount = self.totalBallCount + 2
            -- if total balls are greater then 16 then reset it to 8
            print(self.totalBallCount)
            if self.totalBallCount > 16 then
                self.totalBallCount = 10
                self.lastBallCount = 0
            end
            -- if oldBallCount exist then last balls count will be that
            if oldBallCount then
                self.lastBallCount = oldBallCount
            end

            -- stores the number of balls that are the old ones and is reset
            oldBallCount = self.totalBallCount - 8
            -- reset ballcount to 8
            self.ball.ballCount = 8

            -- reset the old balls
            for i = self.lastBallCount + 1, oldBallCount do
                -- check if an old ball is already on the screen, don't reset
                if self.powerBalls[i].y < VIRTUAL_HEIGHT then
                    goto continue
                else
                    self.powerBalls[i].x = VIRTUAL_WIDTH / 2
                    self.powerBalls[i].y = VIRTUAL_HEIGHT - 48
            
                    -- give new balls random initial velocity
                    if i % 2 == 0 then
                        self.powerBalls[i].dx = math.random(-200, 100)
                    else
                        self.powerBalls[i].dx = math.random(-100, 200)
                    end
                    self.powerBalls[i].dy = math.random(-50, -60)
                end
                ::continue::
            end
        end

        self.brick.timer = 0
        self.powerup:reset()
    end

    if self.ball.ballCount >= 2 then
        for i = 1,self.ball.ballCount do
            self.powerBalls[i]:update(dt)
            print(i)
        end
    end

    -- if the player scores more than 500 then increase the paddle size
    -- check if particle has crossed the threshold and increment variable if it hasn't been incremented yet
    levelScore = self.score - lastLevelScore
    print("last:"..lastLevelScore)
    print("score: "..self.score)
    print("level:"..levelScore)
    for i = 1, 4 do
        if levelScore >= i * 500 and not hasIncremented[i] then
            if self.paddle.size < 4 then
                self.paddle.size = self.paddle.size + 1
                gSounds['paddle-grow']:play()
            end
            hasIncremented[i] = true
        end
        -- Width of the paddle according to its size
        self.paddle.width = self.paddle.size * 32
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    -- update: if every ball goes below bound then 

    -- check if any ball is on the screen
    local ballOnScreen = false
    for i = 1, self.ball.ballCount do
        if self.powerBalls[i].y < VIRTUAL_HEIGHT then
            ballOnScreen = true
        else
            self.powerBalls[i].y = VIRTUAL_HEIGHT + 40
            self.powerBalls[i].dy = 0
            self.powerBalls[i].dx = 0
        end
    end

    if self.ball.y >= VIRTUAL_HEIGHT and not ballOnScreen then  
        self.health = self.health - 1
        gSounds['hurt']:play()

        -- Decrease paddle size by one
        lastLevelScore = self.score
        -- for i = 1, 3 do
        --     hasIncremented[i] = false
        --     self.paddle.size = 2
        -- end
        if self.paddle.size > 1 then
            self.paddle.size = self.paddle.size - 1
        end
        hasIncremented[self.paddle.size - 1] = false

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    -- if powerup goes below bounds, reset it
    if self.powerup.y >= VIRTUAL_HEIGHT then
        self.brick.timer = 0 
        self.powerup:reset()
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    self.ball:render()

    
    -- check for collision and render
    if self.ball.ballCount >= 2 then
        for i = 1,self.ball.ballCount do
            self.powerBalls[i]:render()
        end
    end

    if self.brick.timer >= 3 then
        self.powerup:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end

function PlayState:checkCollision(ball, paddle)
    -- Check collision of ball with the paddle
    if ball:collides(paddle) then
            
        -- raise ball above paddle in case it goes below it, then reverse dy
        ball.y = paddle.y - 8
        ball.dy = -ball.dy

        --
        -- tweak angle of bounce based on where it hits the paddle
        --

        -- if we hit the paddle on its left side while moving left...
        if ball.x < paddle.x + (paddle.width / 2) and paddle.dx < 0 then
            ball.dx = -50 + -(8 * (paddle.x + paddle.width / 2 - ball.x))
        
        -- else if we hit the paddle on its right side while moving right...
        elseif ball.x > paddle.x + (paddle.width / 2) and paddle.dx > 0 then
            ball.dx = 50 + (8 * math.abs(paddle.x + paddle.width / 2 - ball.x))
        end

        gSounds['paddle-hit']:play()
    end

     -- detect collision across all bricks with the ball
     for k, brick in pairs(self.bricks) do

        -- only check collision if we're in play
        if brick.inPlay and ball:collides(brick) then

            -- add to score
            self.score = self.score + (brick.tier * 200 + brick.color * 25)

            -- reset the brick timer
            if not self.powerup.inPlay then
                self.brick.timer = 0
            end

            -- trigger the brick's hit function, which removes it from play
            brick:hit()

            -- if we have enough points, recover a point of health
            if self.score > self.recoverPoints then
                -- can't go above 3 health
                self.health = math.min(3, self.health + 1)

                -- multiply recover points by 2
                self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                -- play recover sound effect
                gSounds['recover']:play()
            end

            -- go to our victory screen if there are no more bricks left
            if self:checkVictory() then
                lastLevelScore = self.score
                for i = 1, 3 do
                    hasIncremented[i] = false
                    self.paddle.size = 2
                end
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
ball = ball,
                    recoverPoints = self.recoverPoints
                })
            end

            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            if ball.x + 2 < brick.x and ball.dx > 0 then
                
                -- flip x velocity and reset position outside of brick
                ball.dx = -ball.dx
                ball.x = brick.x - 8
            
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                
                -- flip x velocity and reset position outside of brick
                ball.dx = -ball.dx
                ball.x = brick.x + 32
            
            -- top edge if no X collisions, always check
            elseif ball.y < brick.y then
                
                -- flip y velocity and reset position outside of brick
                ball.dy = -ball.dy
                ball.y = brick.y - 8
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of brick
                ball.dy = -ball.dy
                ball.y = brick.y + 16
            end

            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(ball.dy) < 150 then
                ball.dy = ball.dy * 1.02
            end

            -- only allow colliding with one brick, for corners
            break
        end
    end
end