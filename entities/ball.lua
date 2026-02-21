-- ball entity
ball = entity:new({
    dx = 1.5,
    dy = 2,
    -- block_size is a local variable in paddle.lua, not sure how this is working
    -- TODO: make it global constant
    size = block_size,
    sprite_index = 16,
    trail = particle_trail:new({}),
    dust_cloud = dust:new({}),
    init = function(self, ref_x, ref_y, direction_x, direction_y)
        self.x = ref_x - self.size
        self.y = ref_y - (self.size / 2)
        self.dx = self.dx * direction_x
        self.dy = self.dy * direction_y
        self.trail:flush()
        self.dust_cloud:flush()
    end,
    move = function(self)
        self.x += self.dx
        self.y += self.dy

        -- spawn trail particles
        local ball_radius = self.size / 2
        local center_x = self.x + ball_radius
        local center_y = self.y + ball_radius
        self.trail:spawn(center_x, center_y, ball_radius)
    end,
    bounce_x = function(self)
        -- spawn dust particles on bounce
        local dust_x = self.dx > 0 and self.x + self.size or self.x
        local dust_y = self.y + (self.size / 2)
        self.dust_cloud:spawn(dust_x, dust_y)

        -- reverse horizontal direction
        self.dx = -self.dx
    end,
    bounce_y = function(self)
        -- spawn dust particles on bounce
        local dust_x = self.x + (self.size / 2)
        local dust_y = self.dy > 0 and self.y + self.size or self.y
        self.dust_cloud:spawn(dust_x, dust_y)

        -- reverse vertical direction
        self.dy = -self.dy
    end,
    draw = function(self)
        spr(self.sprite_index, self.x, self.y)
        self.trail:draw()
        self.dust_cloud:draw()
    end,
})