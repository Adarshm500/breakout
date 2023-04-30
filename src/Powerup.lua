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
    self.y = math.random(0, 50)
    self.dy = 0

    self.inPlay = false
    self.PowerupInPlay = false
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
    print("powerup.y:" ..self.y)
end

function Powerup:render()
    -- print(gFrames['powerups'][9])
    if self.inPlay then
        love.graphics.draw(gTextures['main'],gFrames['powerups'][9], self.x, self.y)
    end
end