-- paddle definition
local block_size = 8

paddle = entity:new({
    width = block_size / 2,
    height = block_size * 3,
    velocity = 0,
    brake_rate = 0.6,
    damage_flash_frames = 10,
    move_up = function(self)
        self.velocity = self.speed * -1
    end,
    move_down = function(self)
        self.velocity = self.speed
    end,
    animate_hit = function(self)
        async(function()
            local original_x = self.x
            local jitter_distance = 2

            -- jitter the paddle in the x-axis (ease-out)
            for i = 1, self.damage_flash_frames do
                local jitter_strength = 1 - i/self.damage_flash_frames
                local jitter_offset = flr(rnd(jitter_distance) - 1) * jitter_strength
                self.x = original_x + jitter_offset
                yield()
            end

            self.x = original_x
        end)
    end,
    decel = function(self)
        local displacement = self.y + self.velocity
        self.y = mid(0, displacement, game.screen_boundary_y - self.height)
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
    width = block_size,
    speed = 3,
    color = 2,
    health = 3,
    sprite_index = 2,
    init = function(self)
        self.y = block_size * 6.5
    end,
    decrease_health = function(self)
        self.health -= 1
    end,
    draw=function (self)
        spr(self.sprite_index, self.x, self.y, 2, 3)
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
    width = block_size,
    sprite_index = 1,
    speed = 1,
    color = 4,
    health = 5,
    init = function(self)
        self.x = game.screen_boundary_x - self.width
        self.y = block_size * 6.5

        -- set a random initial velocity for the enemy paddle
        if rnd() > 0.5 then
            self.velocity = self.speed
        else
            self.velocity = self.speed * -1
        end
    end,
    draw = function(self)
        -- offset the sprite y axis boundaries by one block size
        -- to render the glow sprites without needing to change the collision boundaries of the paddle
        local sprite_start_y = self.y - block_size
        local sprite_end_y = self.height + block_size

        -- use width to determine how many sprites to draw in x and y axis
        local sprite_width = self.width / block_size
        local sprite_height = 5
        spr(self.sprite_index, self.x, sprite_start_y, sprite_width, sprite_height)
    end,
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
        elseif (self.y + self.height) >= game.screen_boundary_y then
            self.velocity = self.speed * -1
        end
    end
})