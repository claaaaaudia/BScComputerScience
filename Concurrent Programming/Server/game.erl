-module(game).

-export([
    match/2,
    init_match/1,
    client_match_loop/3,
    state_to_string/1,
    handle_player_action/4,
    game_timer/3
]).

-include("gamelogic.hrl").

-import(gamelogic, [
    find_collisions/2,
    handle_player_movement/4,
    update_player_velocity/2,
    create_projectile/2,
    update_active_modifiers/1,
    update_projectiles/2,
    spawn_modifier/0,
    on_player_wall_collision/1,
    get_fire_rate_modifier/1,
    check_game_end/2
]).

-define(GAME_TICK, 50).
-define(GAME_DURATION, 120000). % exactly 2 minutes (120 seconds * 1000ms) as per requirements
-define(MODIFIER_SPAWN_CHANCE, 5).
-define(ARENA_W, 800).
-define(ARENA_H, 800).
-define(PLAYER_RADIUS, 20).

%% Inicia uma partida com dois jogadores
match(ServerPid, Players) ->
    io:format("Starting match~n"),
    ServerPid ! {start, self()},
    [FromPid ! {done, self()} || {_User, FromPid} <- Players],
    State = init_match(Players),
    game_timer(ServerPid, State, erlang:system_time(millisecond)).

%% Inicializa o estado da partida
init_match([{User1, FromPid1}, {User2, FromPid2}]) ->
    % Place players at opposite sides of the arena
    P1 = #player{
        user = User1,
        x = ?PLAYER_RADIUS + 10, 
        y = ?ARENA_H div 2,
        dir = 0.0,
        radius = ?PLAYER_RADIUS,
        from_pid = FromPid1
    },
    P2 = #player{
        user = User2,
        x = ?ARENA_W - ?PLAYER_RADIUS - 10,
        y = ?ARENA_H div 2,
        dir = math:pi(),
        radius = ?PLAYER_RADIUS,
        from_pid = FromPid2
    },
    #state{
        player1 = P1,
        player2 = P2,
        projectiles = [],
        modifiers = [],
        start_time = erlang:system_time(millisecond)
    }.

%% Loop de temporização do jogo
game_timer(ServerPid, State, StartTime) ->
    CurrentTime = erlang:system_time(millisecond),
    case check_game_end(State, CurrentTime) of
        finished ->
            endgame(ServerPid, State);
        continue ->
            Self = self(),
            spawn(fun() ->
                timer:sleep(?GAME_TICK),
                Self ! {tick, CurrentTime}
            end),
            UpdatedState = update_game_state(State, CurrentTime, ?GAME_TICK),
            send_state_to_clients(UpdatedState),
            game_loop(ServerPid, UpdatedState, StartTime)
    end.

%% Loop principal que escuta eventos do cliente
game_loop(ServerPid, State, StartTime) ->
    receive
        {tick, _} ->
            game_timer(ServerPid, State, StartTime);

        {action, User, Action, Data} ->
            NewState = handle_player_action(State, User, Action, Data),
            game_loop(ServerPid, NewState, StartTime);

        {leave, User, _FromPid} ->
            handle_player_leave(ServerPid, State, User);

        endgame ->
            endgame(ServerPid, State);

        stop ->
            ok
    end.

%% Atualiza estado a cada tick
update_game_state(State, CurrentTime, DeltaTime) ->
    P1 = update_player_velocity(State#state.player1, DeltaTime),
    P2 = update_player_velocity(State#state.player2, DeltaTime),
    P1a = update_active_modifiers(P1),
    P2a = update_active_modifiers(P2),
    Projectiles = update_projectiles(State#state.projectiles, DeltaTime),
    Modifiers = maybe_spawn_modifier(State#state.modifiers),
    IntermediateState = State#state{
        player1 = P1a,
        player2 = P2a,
        projectiles = Projectiles,
        modifiers = Modifiers
    },
    find_collisions(IntermediateState, CurrentTime).

%% Spawna modificadores aleatoriamente até um dado máximo (por tipo)
maybe_spawn_modifier(Modifiers) ->
    % Count modifiers of each type
    Count = fun(Type) ->
        length([M || M <- Modifiers, M#modifier.type =:= Type])
    end,
    
    % Check if all modifier types have reached their maximum (2 per type)
    % Green (speed_up), Red (speed_down), Blue (fire_rate_up), Orange (fire_rate_down)
    AllFull = Count(speed_up) >= 2 andalso Count(speed_down) >= 2 andalso
              Count(fire_rate_up) >= 2 andalso Count(fire_rate_down) >= 2,
              
    % Random chance to spawn a modifier if not all types are full
    case rand:uniform(100) =< ?MODIFIER_SPAWN_CHANCE andalso not AllFull of
        true ->
            [spawn_modifier() | Modifiers];
        false ->
            Modifiers
    end.

%% Trata ações dos jogadores (movimento e disparo)
handle_player_action(State, User, Action, Data) ->
    {Player, IsPlayer1} = case User of
        U when U =:= (State#state.player1)#player.user -> {State#state.player1, true};
        U when U =:= (State#state.player2)#player.user -> {State#state.player2, false};
        _ -> {undefined, false}
    end,
    case Player of
        undefined -> State;
        _ ->
            case Action of
                "move" ->
                    Direction = Data,
                    Now = erlang:system_time(millisecond),
                    UpdatedPlayer = handle_player_movement(Player, Direction, Now, ?GAME_TICK),
                    if IsPlayer1 -> State#state{player1 = UpdatedPlayer};
                       true -> State#state{player2 = UpdatedPlayer}
                    end;                "shoot" ->
                    Now = erlang:system_time(millisecond),
                    % Apply fire rate modifier effect (Blue increases/Orange decreases rate)
                    RateMod = get_fire_rate_modifier(Player#player.active_mods),
                    Interval = Player#player.shot_interval / RateMod,
                    TimeSinceLast = Now - Player#player.last_shot,
                    % Check if enough time has passed since last shot
                    case TimeSinceLast >= Interval of
                        true ->
                            % Direction is controlled by cursor position relative to player
                            {X, Y} = Data, % Cursor position
                            % Create projectile in the direction of cursor
                            Proj = create_projectile(Player, {X, Y}),
                            UpdatedPlayer = Player#player{last_shot = Now},
                            if IsPlayer1 ->
                                   State#state{
                                       player1 = UpdatedPlayer,
                                       projectiles = [Proj | State#state.projectiles]
                                   };
                               true ->
                                   State#state{
                                       player2 = UpdatedPlayer,
                                       projectiles = [Proj | State#state.projectiles]
                                   }
                            end;
                        false ->
                            State
                    end;
                _ ->
                    State
            end
    end.

%% Trata quando um jogador sai
handle_player_leave(ServerPid, State, User) ->
    case User of
        U when U =:= (State#state.player1)#player.user ->
            ServerPid ! {matchover,
                (State#state.player2)#player.user, U,
                (State#state.player2)#player.from_pid,
                (State#state.player1)#player.from_pid};
        U when U =:= (State#state.player2)#player.user ->
            ServerPid ! {matchover,
                (State#state.player1)#player.user, U,
                (State#state.player1)#player.from_pid,
                (State#state.player2)#player.from_pid};
        _ ->
            game_loop(ServerPid, State, erlang:system_time(millisecond))
    end.

%% Finaliza a partida e informa o resultado
%% Em caso de empate, a partida é ignorada para efeitos de nível e top (como se não tivesse ocorrido)
endgame(ServerPid, State) ->
    P1 = State#state.player1,
    P2 = State#state.player2,
    U1 = P1#player.user,
    S1 = P1#player.score,
    FromPid1 = P1#player.from_pid,
    U2 = P2#player.user,
    S2 = P2#player.score,
    FromPid2 = P2#player.from_pid,
    
    case S1 > S2 of
        true -> ServerPid ! {matchover, U1, U2, FromPid1, FromPid2};
        false when S2 > S1 -> ServerPid ! {matchover, U2, U1, FromPid2, FromPid1};
        % Draw case - Game is ignored according to requirements
        false -> ServerPid ! {matchdraw, U1, U2, FromPid1, FromPid2}
    end.

%% Envia o estado atual aos jogadores
send_state_to_clients(State) ->
    P1 = State#state.player1,
    P2 = State#state.player2,
    StateStr = state_to_string(State),
    P1#player.from_pid ! {toClient, StateStr},
    P2#player.from_pid ! {toClient, StateStr}.

%% Loop para receber mensagens do cliente
client_match_loop(Sock, MatchPid, Username) ->
    receive
        winner -> gen_tcp:send(Sock, "win\n");
        loser -> gen_tcp:send(Sock, "lose\n");
        draw -> gen_tcp:send(Sock, "draw\n");
        match_started ->
            gen_tcp:send(Sock, "match:started\n"),
            client_match_loop(Sock, MatchPid, Username);
        {tcp_closed, _} ->
            MatchPid ! {leave, Username, self()};
        {tcp_error, _} ->
            MatchPid ! {leave, Username, self()};
        {tcp, _, Data} ->
            Str = binary_to_list(string:trim(Data, trailing, "\r\n")),
            case string:split(Str, ":") of
                ["move", Dir] ->
                    MatchPid ! {action, Username, "move", Dir};
                ["shoot", Coords] ->
                    [XStr, YStr] = string:split(Coords, ","),
                    {X, _} = string:to_integer(XStr),
                    {Y, _} = string:to_integer(YStr),
                    MatchPid ! {action, Username, "shoot", {X, Y}};
                ["leave", _] ->
                    MatchPid ! {leave, Username, self()}
            end,
            client_match_loop(Sock, MatchPid, Username);
        {toClient, StateStr} ->
            gen_tcp:send(Sock, StateStr),
            client_match_loop(Sock, MatchPid, Username)
    end.

%% Converte o estado para string a ser enviada ao cliente
state_to_string(State) ->
    P1 = State#state.player1,
    P2 = State#state.player2,
    Projectiles = State#state.projectiles,
    Modifiers = State#state.modifiers,

    PlayersStr = io_lib:format("game:~s,~f,~f,~f,~w,~w#~s,~f,~f,~f,~w,~w",
        [P1#player.user, float(P1#player.x), float(P1#player.y), float(P1#player.dir),
         P1#player.radius, P1#player.score,
         P2#player.user, float(P2#player.x), float(P2#player.y), float(P2#player.dir),
         P2#player.radius, P2#player.score]),

    ProjStrs = lists:map(
        fun(P) -> io_lib:format("#p,~s,~f,~f", [P#projectile.owner, float(P#projectile.x), float(P#projectile.y)]) end,
        Projectiles),    ModStrs = lists:map(
        fun(M) ->
            % Color coding as per requirements:
            % - Green: Increases projectile speed
            % - Red: Decreases projectile speed
            % - Blue: Decreases interval between shots
            % - Orange: Increases interval between shots
            Color = case M#modifier.type of
                speed_up -> "green";      % Increases projectile speed
                speed_down -> "red";      % Decreases projectile speed
                fire_rate_up -> "blue";   % Decreases interval between shots
                fire_rate_down -> "orange" % Increases interval between shots
            end,
            io_lib:format("#m,~s,~f,~f", [Color, float(M#modifier.x), float(M#modifier.y)])
        end, Modifiers),

    lists:flatten([PlayersStr, ProjStrs, ModStrs, "\n"]).
