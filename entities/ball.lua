-- ball entity
ball = entity:new({
    dx = 2,
    dy = 3,
    size = 2,
    color = 7,

    init = function(self, screen_center)
        self.x = screen_center - (self.size / 2)
        self.y = screen_center - (self.size / 2)
    end,
    move = function(self)
        self.x += self.dx
        self.y += self.dy
    end,
    bounce_x = function(self)
        self.dx = -self.dx
    end,
    bounce_y = function(self)
        self.dy = -self.dy
    end,
    draw = function(self)
        circfill(
            self.x,
            self.y,
            self.size,
            self.color
        )
    end
})