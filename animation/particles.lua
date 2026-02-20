-- particle system

-- enum for particle types
PARTICLE_TYPE = Enum(
    "DOT",
    "CIRCLE"
)

-- enum for particle composites
PARTICLE_COMPOSITE = Enum(
    "COMET",
    "RING",
    "EXPLOSION"
)

particle = entity:new({
    change_color = function(self, color)
        self.color = color
    end
})

particle_factory = {
    [PARTICLE_COMPOSITE.COMET] = function(origin_x, origin_y, radius)
        -- random point within a circle of given radius translated from the origin
        local angle = rnd()
        local offset_x = cos(angle) * radius
        local offset_y = sin(angle) * radius
        return {
            x = origin_x + offset_x,
            y = origin_y + offset_y
        }
    end,
    [PARTICLE_COMPOSITE.EXPLOSION] = function()
        -- random point within a circle of radius 1 around the origin
        local angle = rnd()
        return {
            x = cos(angle),
            y = sin(angle)
        }
    end
}

particle_composition = entity:new({
    particles = {},
    add_particle = function(self, p_config)
        -- p_config should contain type, x, y, and optionally color and other properties
        local p = particle:new({
            type = p_config.type,
            x = p_config.x,
            y = p_config.y,
            dx = p_config.dx or 0,
            dy = p_config.dy or 0,
            color = p_config.color,
            size = p_config.size or 1,
            max_frames = p_config.lifespan,
            frames = 0
        })
        add(self.particles, p)
    end,
    update = function(self)
        for p in all(self.particles) do
            p.frames += 1
            if p.frames >= p.max_frames then
                del(self.particles, p)
            end
        end
    end,
    draw = function(self)
        for p in all(self.particles) do
            if p.type == PARTICLE_TYPE.DOT then
                pset(p.x, p.y, p.color)
            elseif p.type == PARTICLE_TYPE.CIRCLE then
                circfill(p.x, p.y, p.size, p.color)
            end
        end
    end,
    flush = function(self)
        self.particles = {}
    end
})