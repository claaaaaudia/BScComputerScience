% Records para representar o estado do jogo
-record(player, {
    user,
    x, y,
    dir,                     %% direção em radianos
    vx = 0.0, vy = 0.0,      %% velocidade atual
    radius = 20,
    last_shot = 0,           %% timestamp em ms
    shot_interval = 500,
    active_mods = [],        %% [{Type, RemainingTicks}]
    score = 0,
    from_pid
}).

-record(projectile, {
    owner,
    x, y,
    vx, vy,
    radius = 5
}).

-record(modifier, {
    type,                   %% speed_up | speed_down | fire_rate_up | fire_rate_down
    x, y,
    radius = 15
}).

-record(state, {
    player1,
    player2, 
    projectiles = [],
    modifiers = [],
    start_time
}).