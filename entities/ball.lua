-- ball entity
ball = entity:new({
    dx = 1.5,
    dy = 2,
    size = 2,
    color = 7,

    init = function(self, x, y, direction_x, direction_y)
        self.x = x - (self.size / 2)
        self.y = y - (self.size / 2)
        self.dx = self.dx * direction_x
        self.dy = self.dy * direction_y
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