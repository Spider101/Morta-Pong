-- game state
game_states = {
    start = "start", -- TODO: implement game start logic
    serve = "serve",
    play = "play",
    done = "done"
}
game = entity:new({
    score = 0,
    screen_boundary = 128,
    build = function(self, ball, player, enemy)
        self.ball = ball
        self.player = player
        self.enemy = enemy

        self.state = game_states.serve
        self.ball:init(self.screen_boundary / 2)
        self.player:init()
        self.enemy:init()
    end,
    update = function(self)
        self.player:move()

        if self.state == game_states.play then
            self.enemy:move()
            self.ball:move()
            self:check_collisions()
        elseif self.state == game_states.serve then
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
        end
    end,
    check_collisions = function(self)
        local ball_boundaries = {
            left = self.ball.x + self.ball.dx - self.ball.size,
            right = self.ball.x + self.ball.dx + self.ball.size,
            top = self.ball.y + self.ball.dy - self.ball.size,
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

        -- ball collision with player paddle
        if ball_boundaries.left <= player_paddle_boundaries.right
                and ball_boundaries.bottom >= player_paddle_boundaries.top
                and ball_boundaries.top <= player_paddle_boundaries.bottom then
            self.ball:bounce_x()
        end

        -- ball collision with enemy paddle
        if ball_boundaries.right >= enemy_paddle_boundaries.left
                and ball_boundaries.bottom >= enemy_paddle_boundaries.top
                and ball_boundaries.top <= enemy_paddle_boundaries.bottom then
            self.score += 1
            self:reset_elements()
        end

        -- ball collision with top and bottom screen boundaries
        if ball_boundaries.top <= 0
                or ball_boundaries.bottom >= self.screen_boundary then
            self.ball:bounce_y()
        end

        -- ball collision with right screen boundary only
        if ball_boundaries.right >= self.screen_boundary then
            self.ball:bounce_x()
        end

        -- ball goes past left screen boundary
        if ball_boundaries.left <= 0 then
            self.player:decrease_health()
            self:reset_elements()
        end
    end,
    reset_ball = function(self)
        -- reset ball position to be in front of enemy paddle
        local starting_x = self.enemy.x - self.ball.size
        local starting_y = self.enemy.y + (self.enemy.height / 2)

        -- set the ball's initial direction to be towards the player and a random direction in the y axis
        local direction_x = -1
        local direction_y = rnd(2) > 1 and 1 or -1

        self.ball:init(starting_x, starting_y, direction_x, direction_y)
    end,
    draw_elements = function(self)
        if self.state == game_states.done then
            self:draw_game_over_screen()
        else
            self.player:draw()
            self.enemy:draw()
            self.ball:draw()

            -- draw score in top right corner of screen
            print("score: " .. self.score, self.screen_boundary - 40, 5, 7)

            -- draw player health in top left corner of screen
            print("health: " .. self.player.health, 5, 5, 7)
        end
    end,
    draw_game_over_screen = function(self)
        cls()
        if self.finish_reason == "win" then
            print("you win!", 44, 56, 7)
        else
            print("you lose!", 40, 56, 7)
        end
    end
})