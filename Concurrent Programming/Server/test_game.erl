-module(test_game).
-export([start/0, test_connection/0, simulate_game/0, test_player/2]).

% Main test function
start() ->
    % First, stop any existing server
    catch server:stop(),
    % Wait a moment for port to be released
    timer:sleep(500),
    
    io:format("Compiling all modules...~n"),
    compile_all(),
    
    io:format("Starting server on port 8888...~n"),
    server:start(8888),
    
    io:format("Starting tests...~n"),
    spawn(fun() -> test_connection() end),
    
    io:format("Server is running. Use server:stop() to stop it.~n").

% Compile all modules
compile_all() ->
    compile:file(gamelogic),
    compile:file(game),
    compile:file(server).

% Test basic connection, login, and match joining
test_connection() ->
    % Wait for server to start
    timer:sleep(500),
    
    % Create two test clients
    {ok, Sock1} = gen_tcp:connect("localhost", 8888, [binary, {packet, line}]),
    {ok, Sock2} = gen_tcp:connect("localhost", 8888, [binary, {packet, line}]),
    
    io:format("Created test connections~n"),
    
    % Create accounts for both players
    gen_tcp:send(Sock1, "create_account:player1#password1\n"),
    gen_tcp:send(Sock2, "create_account:player2#password2\n"),
    
    % Wait for account creation response
    receive_response(Sock1, "Account 1"),
    receive_response(Sock2, "Account 2"),
    
    % Login both players
    gen_tcp:send(Sock1, "login:player1#password1\n"),
    gen_tcp:send(Sock2, "login:player2#password2\n"),
    
    % Wait for login response
    receive_response(Sock1, "Login 1"),
    receive_response(Sock2, "Login 2"),
    
    % Join the lobby
    io:format("Both players join the lobby...~n"),
    gen_tcp:send(Sock1, "join:player1\n"),
    gen_tcp:send(Sock2, "join:player2\n"),
    
    % Wait for join response
    receive_response(Sock1, "Join 1"),
    receive_response(Sock2, "Join 2"),
    
    % Now they should be in a match
    io:format("Match should be starting. Beginning simulation...~n"),
    simulate_game_actions(Sock1, Sock2).

% Simulate a full game between two players
simulate_game() ->
    % Create two players and start a game
    {ok, Sock1} = gen_tcp:connect("localhost", 8888, [binary, {packet, line}]),
    {ok, Sock2} = gen_tcp:connect("localhost", 8888, [binary, {packet, line}]),
    
    % Create and log in players
    gen_tcp:send(Sock1, "create_account:player1#password1\n"),
    gen_tcp:send(Sock2, "create_account:player2#password2\n"),
    
    receive_response(Sock1, ""),
    receive_response(Sock2, ""),
    
    gen_tcp:send(Sock1, "login:player1#password1\n"),
    gen_tcp:send(Sock2, "login:player2#password2\n"),
    
    receive_response(Sock1, ""),
    receive_response(Sock2, ""),
    
    % Join the lobby to start a match
    gen_tcp:send(Sock1, "join:player1\n"),
    gen_tcp:send(Sock2, "join:player2\n"),
    
    receive_response(Sock1, ""),
    receive_response(Sock2, ""),
    
    % Spawn processes for each player
    spawn(fun() -> test_player(Sock1, "player1") end),
    spawn(fun() -> test_player(Sock2, "player2") end),
    
    io:format("Game simulation started. Will run for 2 minutes.~n").

% Simulate game actions between two players
simulate_game_actions(Sock1, Sock2) ->
    % Simulate 30 seconds of gameplay (send a command every 500ms)
    simulate_commands(Sock1, Sock2, 60),
    
    % Close connections
    gen_tcp:close(Sock1),
    gen_tcp:close(Sock2),
    
    io:format("Test completed.~n").

% Send a series of commands to simulate gameplay
simulate_commands(_, _, 0) ->
    io:format("Simulation finished.~n");
simulate_commands(Sock1, Sock2, Count) ->
    % Player 1 movement and shooting
    case rand:uniform(5) of
        1 -> 
            io:format("Player 1 moves UP~n"),
            gen_tcp:send(Sock1, "move:up\n");
        2 -> 
            io:format("Player 1 moves DOWN~n"),
            gen_tcp:send(Sock1, "move:down\n");
        3 -> 
            io:format("Player 1 moves LEFT~n"),
            gen_tcp:send(Sock1, "move:left\n");
        4 -> 
            io:format("Player 1 moves RIGHT~n"),
            gen_tcp:send(Sock1, "move:right\n");
        5 -> 
            X1 = rand:uniform(800),
            Y1 = rand:uniform(800),
            io:format("Player 1 shoots at (~p,~p)~n", [X1, Y1]),
            gen_tcp:send(Sock1, io_lib:format("shoot:~p,~p\n", [X1, Y1]))
    end,
    
    % Player 2 movement and shooting
    case rand:uniform(5) of
        1 -> 
            io:format("Player 2 moves UP~n"),
            gen_tcp:send(Sock2, "move:up\n");
        2 -> 
            io:format("Player 2 moves DOWN~n"),
            gen_tcp:send(Sock2, "move:down\n");
        3 -> 
            io:format("Player 2 moves LEFT~n"),
            gen_tcp:send(Sock2, "move:left\n");
        4 -> 
            io:format("Player 2 moves RIGHT~n"),
            gen_tcp:send(Sock2, "move:right\n");
        5 -> 
            X2 = rand:uniform(800),
            Y2 = rand:uniform(800),
            io:format("Player 2 shoots at (~p,~p)~n", [X2, Y2]),
            gen_tcp:send(Sock2, io_lib:format("shoot:~p,~p\n", [X2, Y2]))
    end,
    
    % Receive game state updates and check for interesting events
    GameState1 = receive_game_state_with_feedback(Sock1, "Player 1"),
    GameState2 = receive_game_state_with_feedback(Sock2, "Player 2"),
    
    % Print score updates if available
    case {GameState1, GameState2} of
        {{game, P1Score, P2Score, _}, _} ->
            io:format("Current score: Player 1 (~w) - Player 2 (~w)~n", [P1Score, P2Score]);
        {_, {game, P1Score, P2Score, _}} ->
            io:format("Current score: Player 1 (~w) - Player 2 (~w)~n", [P1Score, P2Score]);
        _ -> 
            ok
    end,
    
    % Wait before next commands
    timer:sleep(500),
    
    % Continue simulation
    simulate_commands(Sock1, Sock2, Count - 1).

% Receive and process response from server
receive_response(Sock, Label) ->
    receive
        {tcp, Sock, Data} ->
            io:format("~s response: ~p~n", [Label, Data])
    after 2000 ->
        io:format("No response received for ~s~n", [Label])
    end.

% Receive and process game state updates with enhanced feedback
receive_game_state_with_feedback(Sock, PlayerLabel) ->
    receive
        {tcp, Sock, Data} ->
            case binary_to_list(Data) of
                "game:" ++ Rest ->
                    % Parse game state information
                    try
                        % Check if the game state starts with player data
                        Players = string:prefix(Rest, ""),
                        
                        % Split the first player's info and the rest
                        case string:split(Players, "#") of
                            [Player1Info, Rest2] ->
                                % Extract player info
                                P1Parts = string:split(Player1Info, ",", all),
                                
                                % Find the second player's info
                                case string:split(Rest2, "#") of
                                    [Player2Info | _] ->
                                        P2Parts = string:split(Player2Info, ",", all),
                                        
                                        % Extract scores (if available)
                                        P1Score = case length(P1Parts) >= 6 of
                                            true -> 
                                                try list_to_integer(lists:nth(6, P1Parts))
                                                catch _:_ -> 0 end;
                                            false -> 0
                                        end,
                                        
                                        P2Score = case length(P2Parts) >= 6 of
                                            true -> 
                                                try list_to_integer(lists:nth(6, P2Parts))
                                                catch _:_ -> 0 end;
                                            false -> 0
                                        end,
                                        
                                        % Look for interesting events
                                        detect_events(P1Score, P2Score, Rest),
                                        
                                        % Print player positions and scores
                                        io:format("~s: Player1(~s) at (~s,~s), Player2(~s) at (~s,~s) Score: ~w-~w~n", 
                                            [PlayerLabel, 
                                             lists:nth(1, P1Parts), lists:nth(2, P1Parts), lists:nth(3, P1Parts),
                                             lists:nth(1, P2Parts), lists:nth(2, P2Parts), lists:nth(3, P2Parts),
                                             P1Score, P2Score]),
                                        
                                        {game, P1Score, P2Score, Rest};
                                    _ ->
                                        io:format("~s received partial game state~n", [PlayerLabel]),
                                        {game, 0, 0, Rest}
                                end;
                            _ ->
                                io:format("~s received incomplete game state~n", [PlayerLabel]),
                                {game, 0, 0, Rest}
                        end
                    catch
                        _:Error ->
                            io:format("~s parsing error: ~p in state: ~p~n", [PlayerLabel, Error, Rest]),
                            none
                    end;
                "win" ++ _ ->
                    io:format("~s WON THE MATCH!~n", [PlayerLabel]),
                    win;
                "lose" ++ _ ->
                    io:format("~s lost the match~n", [PlayerLabel]),
                    lose;
                "draw" ++ _ ->
                    io:format("Match ended in draw for ~s~n", [PlayerLabel]),
                    draw;
                _ ->
                    io:format("~s received unexpected data: ~p~n", [PlayerLabel, Data]),
                    none
            end
    after 100 ->
        % No response in time, that's ok for game states
        none
    end.

% Detect interesting events in the game state
detect_events(_P1Score, _P2Score, GameState) ->
    % Look for modifiers in the game state
    case string:find(GameState, "#m,") of
        nomatch -> 
            ok;
        _ -> 
            % Count modifiers by type
            GreenCount = count_substrings(GameState, "#m,green"),
            RedCount = count_substrings(GameState, "#m,red"),
            BlueCount = count_substrings(GameState, "#m,blue"),
            OrangeCount = count_substrings(GameState, "#m,orange"),
            
            % Report if there are multiple modifiers
            Total = GreenCount + RedCount + BlueCount + OrangeCount,
            if Total > 0 ->
                   io:format("Modifiers on field: ~w green, ~w red, ~w blue, ~w orange~n", 
                             [GreenCount, RedCount, BlueCount, OrangeCount]);
               true -> ok
            end
    end,
    
    % Look for projectiles
    case string:find(GameState, "#p,") of
        nomatch -> 
            ok;
        _ -> 
            % Count projectiles by player
            P1Projectiles = count_substrings(GameState, "#p,player1"),
            P2Projectiles = count_substrings(GameState, "#p,player2"),
            
            % Report if there are multiple projectiles
            if (P1Projectiles + P2Projectiles) > 2 ->
                   io:format("Active projectiles: ~w from player1, ~w from player2~n", 
                             [P1Projectiles, P2Projectiles]);
               true -> ok
            end
    end.

% Helper function to count occurrences of a substring
count_substrings(String, SubStr) ->
    count_substrings(String, SubStr, 0).

count_substrings(String, SubStr, Count) ->
    case string:find(String, SubStr) of
        nomatch -> 
            Count;
        Rest -> 
            count_substrings(Rest, SubStr, Count + 1)
    end.

% Simulate a player in the game
test_player(Sock, PlayerName) ->
    test_player_loop(Sock, PlayerName, 0).

test_player_loop(Sock, PlayerName, Count) ->
    % Every 500ms, perform an action
    timer:sleep(500),
    
    % Perform random actions
    Action = rand:uniform(5),
    case Action of
        1 -> gen_tcp:send(Sock, "move:up\n");
        2 -> gen_tcp:send(Sock, "move:down\n");
        3 -> gen_tcp:send(Sock, "move:left\n");
        4 -> gen_tcp:send(Sock, "move:right\n");
        5 -> 
            % Shoot at a random position
            X = rand:uniform(800),
            Y = rand:uniform(800),
            gen_tcp:send(Sock, io_lib:format("shoot:~p,~p\n", [X, Y]))
    end,
    
    % Process any incoming messages
    process_messages(Sock, PlayerName),
    
    % Continue for 240 iterations (2 minutes at 500ms per action)
    if
        Count < 240 ->
            test_player_loop(Sock, PlayerName, Count + 1);
        true ->
            io:format("Player ~s finished simulation~n", [PlayerName]),
            gen_tcp:close(Sock)
    end.

% Process incoming messages for a player
process_messages(Sock, PlayerName) ->
    receive
        {tcp, Sock, Data} ->
            case binary_to_list(Data) of
                "win" ++ _ ->
                    io:format("Player ~s won!~n", [PlayerName]);
                "lose" ++ _ ->
                    io:format("Player ~s lost~n", [PlayerName]);
                "draw" ++ _ ->
                    io:format("Game ended in draw for ~s~n", [PlayerName]);
                "game:" ++ _ ->
                    % Received game state update, continue
                    process_messages(Sock, PlayerName);
                _ ->
                    io:format("Player ~s received: ~p~n", [PlayerName, Data]),
                    process_messages(Sock, PlayerName)
            end
    after 100 ->
        % No more messages
        ok
    end.