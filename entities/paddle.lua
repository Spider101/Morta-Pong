-- paddle definition
local block_size = 8

paddle = entity:new({
    width = block_size / 2,
    height = block_size * 3,
    velocity = 0,
    brake_rate = 0.6,
    move_up = function(self)
        self.velocity = self.speed * -1
    end,
    move_down = function(self)
        self.velocity = self.speed
    end,
    decel = function(self)
        local displacement = self.y + self.velocity
        self.y = mid(0, displacement, game.screen_boundary - self.height)
        if self.velocity > 0 then
            self.velocity = max(0, self.velocity - self.brake_rate)
        elseif self.velocity < 0 then
            self.velocity = min(0, self.velocity + self.brake_rate)
        end
    end,
    draw = function(self)
        rectfill(
            self.x,
            self.y,
            self.x + self.width,
            self.y + self.height,
            self.color
        )
    end
})

-- specialized paddle entities for player and enemy
player_paddle = paddle:new({
    speed = 3,
    color = 2,
    health = 3,
    init = function(self)
        self.y = block_size * 6.5
    end,
    decrease_health = function(self)
        self.health -= 1
    end,
    move = function(self)
        if btn(2) then
            -- d-pad up
            self:move_up()
        elseif btn(3) then
            -- d-pad down
            self:move_down()
        end
        self:decel()
    end
})

enemy_paddle = paddle:new({
    init = function(self)
        self.x = game.screen_boundary - (block_size / 2)
        self.y = block_size * 6.5

        -- set a random initial velocity for the enemy paddle
        if rnd() > 0.5 then
            self.velocity = self.speed
        else
            self.velocity = self.speed * -1
        end
    end,
    speed = 1,
    color = 4,
    move = function(self)
        -- move the enemy paddle up and down depending on its current velocity
        if self.velocity > 0 then
            self:move_down()
        else
            self:move_up()
        end
        self:decel()

        -- reverse enemy paddle direction if it hits the screen boundaries
        if self.y <= 0 then
            self.velocity = self.speed
        elseif (self.y + self.height) >= game.screen_boundary then
            self.velocity = self.speed * -1
        end
    end
})