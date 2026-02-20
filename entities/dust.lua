-- dust entity
dust = particle_composition:new({
    strength = 3,
    min_frames = 10,
    min_size = 1,
    get_particle_velocity = particle_factory[PARTICLE_COMPOSITE.EXPLOSION],
    spawn = function(self, origin_x, origin_y)
        -- add new particles to the collection
        for i = 1, self.strength do
            -- get velocity for the new particle based on the origin and spread
            local particle_velocity = self.get_particle_velocity()

            -- add particle to the collection
            local size_offset = rnd(2)
            self:add_particle({
                type = PARTICLE_TYPE.CIRCLE,
                x = origin_x,
                y = origin_y,
                dx = particle_velocity.x,
                dy = particle_velocity.y,
                size = self.min_size + size_offset,
                color = 6,
                lifespan = self.min_frames + rnd(self.min_frames)
            })
        end
    end,
    tick = function(self)
        for p in all(self.particles) do
            p.x += p.dx
            p.y += p.dy
        end

        -- update particle collection (remove expired particles)
        self:update()
    end
})