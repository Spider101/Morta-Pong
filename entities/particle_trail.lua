-- particle trail entity
particle_trail = particle_composition:new({
    strength = 5,
    min_frames = 10,
    get_particle_coords = particle_factory[PARTICLE_COMPOSITE.TRAIL],
    color_gradient = { 9, 15 },
    get_color_from_age = function(self, age)
        -- simple color fading logic based on particle age
        local color_index = flr((age / self.min_frames) * (#self.color_gradient - 1)) + 1
        return self.color_gradient[color_index] or self.color_gradient[#self.color_gradient]
    end,
    spawn = function(self, origin_x, origin_y, spread)
        -- add new particles to the collection
        for i = 1, self.strength do
            -- get coordinates for the new particle based on the origin and spread
            local scale_factor = 0.6
            local particle_coords = self.get_particle_coords(
                origin_x,
                origin_y,
                spread * scale_factor
            )

            local frame_offset = rnd(self.min_frames)
            self:add_particle({
                type = PARTICLE_TYPE.DOT, -- type can be used to determine how to draw the particle in the composition's draw method
                x = particle_coords.x,
                y = particle_coords.y,
                color = self:get_color_from_age(0),
                lifespan = self.min_frames + frame_offset
            })
        end
    end,
    tick = function(self)
        for p in all(self.particles) do
            -- update particle color based on its age (frames)
            local color = self:get_color_from_age(p.frames)
            p:change_color(color)
        end

        -- update particle collection (remove expired particles)
        self:update()
    end
})