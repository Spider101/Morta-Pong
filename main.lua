-- game state
game_states = {
    start = "start",
    serve = "serve",
    play = "play",
    done = "done"
}
game = entity:new({
    score = 0,
    screen_boundary_x = 128,
    screen_boundary_y = 128,
    frames_after_serve = 0,
    collision_frame_threshold = 2,
    build = function(self, ball, player, enemy)
        self.ball = ball
        self.player = player
        self.enemy = enemy

        self.state = game_states.start
        self.player:init()
        self.enemy:init()
    end,
    update = function(self)
        -- rudimentary FSM for game state management
        if self.state == game_states.start then
            -- z button to start the game
            if btn(4) then
                self.state = game_states.serve
            end

            -- early return to avoid updating anything else in the start state
            return
        end

        if self.state == game_states.done then
            -- z button to reset the game
            if btn(4) then
                self.score = 0
                self.player.health = 3
                self.enemy.health = 5
                self.state = game_states.start
            end

            -- early return to avoid updating anything else in the done state
            return
         end

         -- both serve and play move paddles
        self.enemy:move()
        self.player:move()

        if self.state == game_states.serve then
            self.frames_after_serve = 0
            self:reset_ball()

            -- check for win/lose conditions
            if self.player.health <= 0 then
                self.finish_reason = "lose"
                self.state = game_states.done
            end
            if self.score >= self.enemy.health then
                self.finish_reason = "win"
                self.state = game_states.done
            end

            -- x button to serve the ball
            if btn(5) then
                self.state = game_states.play
            end
        elseif self.state == game_states.play then
            self.ball:move()
            self.ball.trail:tick()
            self.ball.dust_cloud:tick()

            if self.frames_after_serve <= self.collision_frame_threshold then
                self.frames_after_serve += 1
            end

            self:check_collisions()
        end
    end,
    check_collisions = function(self)
        -- adding the speed in order to check for collisions in the next frame,
        -- otherwise the ball can clip through objects if it's moving fast enough
        local ball_boundaries = {
            left = self.ball.x + self.ball.dx,
            right = self.ball.x + self.ball.dx + self.ball.size,
            top = self.ball.y + self.ball.dy,
            bottom = self.ball.y + self.ball.dy + self.ball.size
        }

        local player_paddle_boundaries = {
            right = self.player.x + self.player.width,
            top = self.player.y,
            bottom = self.player.y + self.player.height
        }

        local enemy_paddle_boundaries = {
            left = self.enemy.x,
            top = self.enemy.y,
            bottom = self.enemy.y + self.enemy.height
        }

        local function paddle_intersect(pad, is_player)
            if is_player then
                return ball_boundaries.left <= pad.right
                    and ball_boundaries.bottom >= pad.top
                    and ball_boundaries.top <= pad.bottom
            else
                return ball_boundaries.right >= pad.left
                    and ball_boundaries.bottom >= pad.top
                    and ball_boundaries.top <= pad.bottom
            end
        end

        -- use enemy paddle width as proxy for the right wall thickness since they use the same sprite
        local right_wall_x = self.screen_boundary_x - self.enemy.width

        -- bounce ball in x axis if it collides with player paddle or right wall
        if paddle_intersect(player_paddle_boundaries, true)
            or ball_boundaries.right >= right_wall_x then
            self.ball:bounce_x()
        end

        -- ball collision with top and bottom screen boundaries
        if ball_boundaries.top <= 0
                or ball_boundaries.bottom >= self.screen_boundary_y then
            self.ball:bounce_y()
        end

        -- serve reset conditions below --

        -- ball collision with enemy paddle
        if paddle_intersect(enemy_paddle_boundaries, false)
            and self.frames_after_serve > self.collision_frame_threshold then
            self.score += 1
            self.enemy:animate_hit()
            self.state = game_states.serve
        end

        -- ball goes past left screen boundary
        if ball_boundaries.left <= 0 then
            self.player:decrease_health()
            self.player:animate_hit()
            self.state = game_states.serve
        end
    end,
    reset_ball = function(self)
        -- reset ball position to be in front of enemy paddle
        local starting_x = self.enemy.x
        local starting_y = self.enemy.y + (self.enemy.height / 2)

        -- TODO: ensure the velocity logic happens only in the play -> serve transition when the FSM is fleshed out
        -- set the ball's initial direction to be towards the player and a random direction in the y axis
        local direction_x = self.ball.dx > 0 and -1 or 1
        local direction_y = rnd(2) > 1 and 1 or -1

        self.ball:init(starting_x, starting_y, direction_x, direction_y)
    end,
    draw_elements = function(self)
        self.ball:draw()
        self.player:draw()
        self.enemy:draw()

        -- draw score in top right corner of screen
        print("score: " .. self.score, self.screen_boundary_x - 40, 5, 7)

        -- draw player health in top left corner of screen
        print("health: " .. self.player.health, 5, 5, 7)
    -- end
    end,
    draw_start_screen = function(self)
        print("press ▥ to start", 32, 56, 7)
    end,
    draw_game_over_screen = function(self)
        if self.finish_reason == "win" then
            print("you win!", 44, 56, 7)
        else
            print("you lose!", 40, 56, 7)
        end
    end
})