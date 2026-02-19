-- ball entity
ball = entity:new({
    dx = 1.5,
    dy = 2,
    size = block_size,
    trail = particle_trail,
    init = function(self, x, y, direction_x, direction_y)
        self.x = x - self.size
        self.y = y - (self.size / 2)
        self.dx = self.dx * direction_x
        self.dy = self.dy * direction_y
        self.trail:flush()
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
        self.dx = -self.dx
    end,
    bounce_y = function(self)
        self.dy = -self.dy
    end,
    draw = function(self)
        spr(23, self.x, self.y)
        self.trail:draw()
    end,
})