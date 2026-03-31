%%%-------------------------------------------------------------------
%%% Game Logic for Functional Multiplayer Game
%%%-------------------------------------------------------------------

-module(gamelogic).

-export([
    find_collisions/2, check_game_end/2,
    handle_player_movement/4, update_player_velocity/2, create_projectile/2,
    update_active_modifiers/1, update_projectiles/2, spawn_modifier/0,
    get_fire_rate_modifier/1, update_projectiles/1,
    norm/1, crossProduct/2
]).

%%%-------------------------------------------------------------------
%%% Record Definitions
-record(player, {
    user,
    x, y,
    dir,                     %% direction in radians
    vx = 0.0, vy = 0.0,      %% current velocity
    radius = 20,
    last_shot = 0,
    shot_interval = 700,
    active_mods = [],
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
    type,  %% speed_up | speed_down | fire_rate_up | fire_rate_down
    x, y,
    radius = 15
}).

-record(state, {
    player1, player2,
    projectiles = [],
    modifiers = [],
    start_time = 0  %% timestamp in ms
}).

%%%-------------------------------------------------------------------
%%% Constants
-define(PLAYER_RADIUS,      20).
-define(PROJECTILE_RADIUS,   5).
-define(MODIFIER_RADIUS,    15).

-define(LINEAR_ACCEL,      100).
-define(MAX_SPEED,         400).
-define(BASE_SHOT_INT,     500).

-define(ARENA_W, 800).
-define(ARENA_H, 800).
-define(MAX_MODS_PER_TYPE, 2).
-define(MOD_DECAY_TICKS, 400).
-define(PROJECTILE_SPEED, 150).
-define(MODIFIER_SPAWN_CHANCE, 5).

%%%-------------------------------------------------------------------
%%% Player Movement
-spec handle_player_movement(#player{}, string(), integer(), integer()) -> #player{}.
handle_player_movement(Player = #player{x = X, y = Y, dir = Dir, vx = Vx, vy = Vy}, Direction, _Now, DeltaTime) ->
    SpeedMod = get_speed_modifier(Player#player.active_mods),
    MaxSpeed = ?MAX_SPEED * SpeedMod,
    DeltaSec = DeltaTime / 1000,

    % Updated movement according to requirements - inertia-based movement
    % Acceleration in 4 directions (up, down, left, right)
    {AccelX, AccelY} = 
        case Direction of
            "up" ->
                {0, -?LINEAR_ACCEL * DeltaSec};
            "down" ->
                {0, ?LINEAR_ACCEL * DeltaSec};
            "left" ->
                {-?LINEAR_ACCEL * DeltaSec, 0};
            "right" ->
                {?LINEAR_ACCEL * DeltaSec, 0};
            "up#left" ->
                {-?LINEAR_ACCEL * DeltaSec, -?LINEAR_ACCEL * DeltaSec};
            "up#right" ->
                {?LINEAR_ACCEL * DeltaSec, -?LINEAR_ACCEL * DeltaSec};
            "down#left" ->
                {-?LINEAR_ACCEL * DeltaSec, ?LINEAR_ACCEL * DeltaSec};
            "down#right" ->
                {?LINEAR_ACCEL * DeltaSec, ?LINEAR_ACCEL * DeltaSec};
            _ ->
                {0, 0}
        end,
    
    % Calculate look direction based on velocity
    NewDir = case {Vx + AccelX, Vy + AccelY} of
                {0, 0} -> Dir; % Keep current direction if not moving
                {NX, NY} -> math:atan2(NY, NX)
            end,
    
    % Apply acceleration to velocity
    NewVx = Vx + AccelX,
    NewVy = Vy + AccelY,

    {ClampedVx, ClampedVy} = cap_velocity(NewVx, NewVy, MaxSpeed),

    Player#player{
        x = X + ClampedVx * DeltaSec,
        y = Y + ClampedVy * DeltaSec,
        dir = normalize_angle(NewDir),
        vx = ClampedVx,
        vy = ClampedVy
    }.

cap_velocity(Vx, Vy, MaxSpeed) ->
    Speed = math:sqrt(Vx*Vx + Vy*Vy),
    if Speed > MaxSpeed ->
           Factor = MaxSpeed / Speed,
           {Vx * Factor, Vy * Factor};
       true -> {Vx, Vy}
    end.

normalize_angle(A) ->
    Pi2 = 2 * math:pi(),
    case A < 0 of
        true -> normalize_angle(A + Pi2);
        false when A >= Pi2 -> normalize_angle(A - Pi2);
        false -> A
    end.

%%%-------------------------------------------------------------------
%%% Player State Updates
update_player_velocity(P = #player{vx = Vx, vy = Vy}, _DeltaTime) ->
    F = 0.98,
    P#player{vx = Vx * F, vy = Vy * F}.

update_active_modifiers(P = #player{active_mods = Mods}) ->
    NewMods = [{Type, T - 1} || {Type, T} <- Mods],
    ValidMods = [{Type, T} || {Type, T} <- NewMods, T > 0],
    P#player{active_mods = ValidMods}.

%%%-------------------------------------------------------------------
%%% Modifier Effect Strength
% Green (increase projectile speed) and Red (decrease projectile speed)
get_speed_modifier(Mods) ->
    G = length([T || {T, _} <- Mods, T =:= speed_up]),    % Green modifiers (speed_up)
    R = length([T || {T, _} <- Mods, T =:= speed_down]),  % Red modifiers (speed_down)
    1.0 + 0.2 * G - 0.2 * R.

% Blue (decrease fire interval) and Orange (increase fire interval)
get_fire_rate_modifier(Mods) ->
    B = length([T || {T, _} <- Mods, T =:= fire_rate_up]),    % Blue modifiers (fire_rate_up)
    O = length([T || {T, _} <- Mods, T =:= fire_rate_down]),  % Orange modifiers (fire_rate_down)
    1.0 + 0.2 * B - 0.2 * O.

%%%-------------------------------------------------------------------
%%% Projectile Logic
create_projectile(#player{user = U, x = X, y = Y, radius = R, active_mods = Mods}, {CX, CY}) ->
    % Direction is controlled by the position of the cursor in relation to the player
    % Calculate direction vector from player to cursor position
    DX = CX - X, DY = CY - Y,
    Mag = math:sqrt(DX*DX + DY*DY),
    NX = DX / Mag, NY = DY / Mag,
    
    % Apply speed modifier from player's active modifiers
    SpeedMod = get_speed_modifier(Mods),
    VX = NX * ?PROJECTILE_SPEED * SpeedMod,
    VY = NY * ?PROJECTILE_SPEED * SpeedMod,
    
    % Create projectile slightly outside player radius to prevent immediate collision
    #projectile{
        owner = U,
        x = X + NX * (R + ?PROJECTILE_RADIUS + 1),
        y = Y + NY * (R + ?PROJECTILE_RADIUS + 1),
        vx = VX,
        vy = VY
    }.

update_projectiles(ProjList, DeltaTime) ->
    [update_projectile(P, DeltaTime) || P <- ProjList].

update_projectiles(Projs) -> update_projectiles(Projs, 16.67).

update_projectile(P = #projectile{x = X, y = Y, vx = VX, vy = VY}, DeltaTime) ->
    S = DeltaTime / 1000,
    P#projectile{x = X + VX * S, y = Y + VY * S}.

%%%-------------------------------------------------------------------
%%% Modifiers
spawn_modifier() ->
    X = ?MODIFIER_RADIUS + rand:uniform(?ARENA_W - 2 * ?MODIFIER_RADIUS),
    Y = ?MODIFIER_RADIUS + rand:uniform(?ARENA_H - 2 * ?MODIFIER_RADIUS),
    % According to requirements:
    % Green: Increases projectile speed (speed_up)
    % Orange: Increases interval between shots (fire_rate_down)
    % Blue: Decreases interval between shots (fire_rate_up)
    % Red: Decreases projectile speed (speed_down)
    Type = case rand:uniform(4) of
               1 -> speed_up;      % Green
               2 -> speed_down;    % Red
               3 -> fire_rate_up;  % Blue
               4 -> fire_rate_down % Orange
           end,
    #modifier{type = Type, x = X, y = Y}.

%%%-------------------------------------------------------------------
%%% Collision System
find_collisions(State = #state{player1 = P1, player2 = P2, projectiles = Projs, modifiers = Mods}, _Now) ->
    %% 1. Projectiles vs Players
    {P1a, P2a, RemainingProjs} =
        lists:foldl(fun(Proj, {A1, A2, Ps}) ->
            case {calc_collision(A1, Proj), calc_collision(A2, Proj), Proj#projectile.owner} of
                {true, _, Owner} when Owner =:= P2#player.user -> 
                    % P1 hit by P2's projectile - add 1 point to P2's score
                    {A1, A2#player{score = A2#player.score + 1}, Ps};
                {_, true, Owner} when Owner =:= P1#player.user -> 
                    % P2 hit by P1's projectile - add 1 point to P1's score
                    {A1#player{score = A1#player.score + 1}, A2, Ps};
                _ -> {A1, A2, [Proj | Ps]}
            end
        end, {P1, P2, []}, Projs),

    %% NOTE: Player vs Player collisions are ignored as per requirements
    
    %% 2. Players vs Wall - add 2 points to other player and reset positions
    case {on_player_wall_collision(P1a), on_player_wall_collision(P2a)} of
        {{NP1, true}, {NP2, false}} ->
            {RP1, RP2} = reset_players_positions(NP1, NP2),
            P1b = RP1, P2b = RP2#player{score = RP2#player.score + 2};
        {{NP1, false}, {NP2, true}} ->
            {RP1, RP2} = reset_players_positions(NP1, NP2),
            P1b = RP1#player{score = RP1#player.score + 2}, P2b = RP2;
        _ -> P1b = P1a, P2b = P2a
    end,    %% 3. Projectiles vs Walls
    CleanProjs = [P || P <- lists:reverse(RemainingProjs), not on_proj_wall_collision(P)],
    
    %% NOTE: Projectile vs Modifier collisions are ignored as per requirements

    %% 4. Players vs Modifiers
    {P1c, P2c, NewMods} =
        lists:foldl(fun(Mod, {A1, A2, Ms}) ->
            case {calc_collision(A1, Mod), calc_collision(A2, Mod)} of
                {true, _} -> {on_player_mod_collision(A1, Mod), A2, Ms};
                {_, true} -> {A1, on_player_mod_collision(A2, Mod), Ms};
                _ -> {A1, A2, [Mod | Ms]}
            end
        end, {P1b, P2b, []}, Mods),

    State#state{
        player1 = P1c,
        player2 = P2c,
        projectiles = CleanProjs,
        modifiers = lists:reverse(NewMods)
    }.

calc_collision(#player{x = X1, y = Y1, radius = R1}, #projectile{x = X2, y = Y2, radius = R2}) ->
    DX = X1 - X2, DY = Y1 - Y2,
    DX*DX + DY*DY < (R1 + R2)*(R1 + R2);
calc_collision(#player{x = X1, y = Y1, radius = R1}, #modifier{x = X2, y = Y2, radius = R2}) ->
    DX = X1 - X2, DY = Y1 - Y2,
    DX*DX + DY*DY < (R1 + R2)*(R1 + R2).

on_proj_wall_collision(#projectile{x = X, y = Y, radius = R}) ->
    X - R < 0 orelse X + R > ?ARENA_W orelse Y - R < 0 orelse Y + R > ?ARENA_H.

on_player_wall_collision(P = #player{x = X, y = Y, radius = R}) ->
    Hit = X - R < 0 orelse X + R > ?ARENA_W orelse Y - R < 0 orelse Y + R > ?ARENA_H,
    {P, Hit}.

on_player_mod_collision(P = #player{active_mods = Mods}, #modifier{type = Type}) ->
    % Apply modifier effect to player
    % - Green (speed_up): Increases projectile speed
    % - Red (speed_down): Decreases projectile speed
    % - Blue (fire_rate_up): Decreases interval between shots
    % - Orange (fire_rate_down): Increases interval between shots
    %
    % Modifier effects will decay progressively over time
    Count = length([T || {T, _} <- Mods, T =:= Type]),
    if Count < ?MAX_MODS_PER_TYPE ->
           P#player{active_mods = [{Type, ?MOD_DECAY_TICKS} | Mods]};
       true -> P
    end.

reset_players_positions(P1, P2) ->
    % Reset players to their initial positions on opposite sides of the arena
    % Also reset their velocity to zero
    RP1 = P1#player{
        x = ?PLAYER_RADIUS + 10,         % Left side
        y = ?ARENA_H div 2,              % Middle height
        vx = 0.0, 
        vy = 0.0
    },
    RP2 = P2#player{
        x = ?ARENA_W - ?PLAYER_RADIUS - 10, % Right side
        y = ?ARENA_H div 2,                 % Middle height
        vx = 0.0, 
        vy = 0.0
    },
    {RP1, RP2}.

%%%-------------------------------------------------------------------
%%% Game Time
-spec check_game_end(#state{}, integer()) -> continue | finished.
check_game_end(#state{start_time = Start}, Now) ->
    % Game duration set to exactly 2 minutes (120000 milliseconds)
    if Now - Start >= 120000 -> finished;
       true -> continue
    end.

%%%-------------------------------------------------------------------
%%% Utilities
norm({X, Y}) -> math:sqrt(X*X + Y*Y).
crossProduct({X1, Y1}, {X2, Y2}) -> X1*X2 + Y1*Y2.
