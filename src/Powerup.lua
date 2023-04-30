--[[
    Add powerup class
    Add a Powerup class to the game that spawns a powerup (images located at the bottom of the sprite sheet in the distribution code). This Powerup should spawn randomly, be it on a timer or when the Ball hits a Block enough times, and gradually descend toward the player. Once collided with the Paddle, two more Balls should spawn and behave identically to the original, including all collision and scoring points for the player. Once the player wins and proceeds to the VictoryState for their current level, the Balls should reset so that there is only one active again.
]]

--[[
    what do i want:
        --the powerup is activated when any brick has not been hit for 10 seconds
    the problem:


]]

Powerup = Class{}

local GRAVITY = 1

function Powerup:init(x,y)
    self.x = x
    self.y = y
    self.height = 16
    self.width = 16

    self.dy = 0

    self.inPlay = true
    self.PowerupInPlay = false
end

function Powerup:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    return true
end

function Powerup:reset()
    self.x = math.random(0, VIRTUAL_WIDTH)
    self.y = math.random(0, 50)
    self.dy = 0
    print("reset")

    self.inPlay = false
    self.PowerupInPlay = false
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
    print("powerup:" ..self.y)
end

function Powerup:render()
    -- print(gFrames['powerups'][9])
    if self.inPlay then
        love.graphics.draw(gTextures['main'],gFrames['powerups'][9], self.x, self.y)
    end
end

--[[
1. the powerup should be triggered if no brick is hit till 4 seconds
2. the powerup should be on the screen untill it collides with the paddle or is beyond the screen
3. if the powerup collides with the paddle or goes beyond the screen then it should reset

The problem:
1. the powerup is not visible when the ball hits the brick after it is on screen
2. It is because the timer gets reset to 0

The Solution:
1. the timer should stop until the powerup is off the screen
    1.1 more option in the timeElapsed function

2. the timer should not be triggered if the Powerup is on the screen
    2.1 we can go to brick collision for this in the update function

Note :
1. first make sure that the powerupInPlay variable is true when the powerup is on screen that is it has been triggered and has not yet touched the paddle 
        1.1 if it touches the paddle then it should wait for timer to again go beyond 4 seconds to be true

]]