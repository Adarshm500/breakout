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

function Powerup:init(x,y)
    self.x = x
    self.y = y
    self.height = 16
    self.width = 16
    self.power = 9

    self.dy = 0

    self.inPlay = false
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

    self.x = math.random(self.width, VIRTUAL_WIDTH - self.width)
    self.y = math.random(0, 50)
    self.dy = 0
    print("reset")

    self.inPlay = false
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
end

function Powerup:render()
    -- print(gFrames['powerups'][9])
    if self.inPlay then
        love.graphics.draw(gTextures['main'],gFrames['powerups'][self.power], self.x, self.y)
    end
end

--[[
The ball spawn
    1.Objective: *To spawn two balls when the powerup is hit with the paddle

    2.Method: * Make a table to contain new balls to initiate and store 8 balls there to initiate
        * initiate a variable named ballCount to 0
        * Once the powerup hits the paddle then increment the ball count by 2
        * Then using a for loop update as many balls as the ballCount
        * Do same thing with the render

        when total ball count was 10 then
            last ball count = 1
            oldBallCount = 2
        end
        when total ball count is 16 then
            last ball count = 7
            oldBallCount = 8
        end
        when total ball count is 18 then 
            total ball count is 8
            last ball count = 1
            oldBallCount = 2
]]