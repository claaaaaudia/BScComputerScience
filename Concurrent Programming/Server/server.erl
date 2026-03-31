-module(server).
-export([start/1, stop/0, debug_users/0, set_all_offline/1]).
-import(game, [match/2, client_match_loop/3]).

-define(MAX_ACTIVE_MATCHES, 20).

% Debug function to print all users
debug_users() ->
    Users = load_accounts(),
    io:format("All users in the database:~n"),
    maps:fold(
        fun(User, Data, _) ->
            io:format("User: ~p, Data: ~p~n", [User, Data])
        end,
        ok,
        Users
    ).

start(Port) -> 
    register(?MODULE, spawn(fun() -> server(Port) end)).

stop() -> 
    ?MODULE ! stop.

server(Port) -> 
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}, {reuseaddr, true}]),
    io:format("Server started on port ~p~n", [Port]),
    
    Users = load_accounts(),
    % Print loaded users for debugging
    io:format("Loaded users: ~p~n", [maps:keys(Users)]),
    
    % Set all accounts to offline status on server start
    OfflineUsers = set_all_offline(Users),
    save_accounts(OfflineUsers),
    io:format("All users set to offline status on server start~n"),
    
    Lobby = spawn(fun() -> lobby([]) end),
    register(lobby, Lobby),
    spawn(fun() -> acceptor(LSock, Lobby) end),
    
    server_loop(Lobby, OfflineUsers, []),
    
    gen_tcp:close(LSock),
    ok.

server_loop(Lobby, Users, ActiveMatches) -> 
    receive        
        {login, User, Pwd, FromPid} -> 
            io:format("Login request for user '~s' (hex: ~w)~n", [User, [C || C <- User]]),
            io:format("Available users: ~p~n", [maps:keys(Users)]),
            case maps:find(User, Users) of
                {ok, {StoredPwd, false, Level, Streak}} -> 
                    io:format("User found, checking password~n"),

                    case Pwd =:= StoredPwd of
                        true -> 
                            FromPid ! done_login,
                            UpdatedUsers = maps:update(User, {StoredPwd, true, Level, Streak}, Users),
                            save_accounts(UpdatedUsers),
                            io:format("Updated account status for user ~p (logged in)~n", [User]),
                            server_loop(Lobby, UpdatedUsers, ActiveMatches);
                        false -> 
                            io:format("Password mismatch for user ~p~n", [User]),
                            %debug
                            io:format("Stored password: ~p, Provided password: ~p~n", [StoredPwd, Pwd]),
                            FromPid ! invalid_password,
                            server_loop(Lobby, Users, ActiveMatches)
                    end;
                {ok, {_StoredPwd, true, _Level, _Streak}} -> 
                    io:format("User ~p is already logged in~n", [User]),
                    FromPid ! already_login,
                    server_loop(Lobby, Users, ActiveMatches);
                error -> 
                    io:format("User '~s' not found in database~n", [User]),
                    FromPid ! invalid_user,
                    server_loop(Lobby, Users, ActiveMatches)
            end;
        
        {logout, User, FromPid} -> 
            io:format("Logout request for user ~p~n", [User]),
            case maps:find(User, Users) of
                {ok, {StoredPwd, true, Level, Streak}} -> 
                    FromPid ! done_logout,
                    UpdatedUsers = maps:update(User, {StoredPwd, false, Level, Streak}, Users),
                    save_accounts(UpdatedUsers),
                    io:format("Updated account status for user ~p (logged out)~n", [User]),
                    server_loop(Lobby, UpdatedUsers, ActiveMatches);
                {ok, {_StoredPwd, false, _Level, _Streak}} -> 
                    FromPid ! already_logout,
                    server_loop(Lobby, Users, ActiveMatches);
                error -> 
                    FromPid ! invalid_user,
                    server_loop(Lobby, Users, ActiveMatches)
            end;
              
        {create_account, User, Pwd, FromPid} -> 
            io:format("Create account request for user ~p~n", [User]),
            case maps:find(User, Users) of
                {ok, _} -> 
                    FromPid ! user_exists,
                    server_loop(Lobby, Users, ActiveMatches);
                error -> 
                    FromPid ! done_acc,
                    UpdatedUsers = maps:put(User, {Pwd, false, 1, 0}, Users),
                    save_accounts(UpdatedUsers),
                    server_loop(Lobby, UpdatedUsers, ActiveMatches)
            end;
              
        {remove_account, User, Pwd, FromPid} -> 
            io:format("Remove account request for user ~p~n", [User]),
            case maps:find(User, Users) of
                {ok, {StoredPwd, _, _, _}} -> 
                    case Pwd =:= StoredPwd of
                        true -> 
                            FromPid ! done_remove,
                            UpdatedUsers = maps:remove(User, Users),
                            save_accounts(UpdatedUsers),
                            server_loop(Lobby, UpdatedUsers, ActiveMatches);
                        false -> 
                            FromPid ! invalid_password,
                            server_loop(Lobby, Users, ActiveMatches)
                    end;
                error -> 
                    FromPid ! invalid_user,
                    server_loop(Lobby, Users, ActiveMatches)
            end;

        {top_ten, FromPid} -> 
            TopTen = topTen(Users),
            Usernames = [User || {User, _Level, _Streak} <- TopTen],
            FromPid ! {top_ten, string:join(Usernames, ",")},
            server_loop(Lobby, Users, ActiveMatches);
        
        {join, User, FromPid} -> 
            io:format("Join request from user ~p~n", [User]),
            case maps:find(User, Users) of
                {ok, {_, true, _, _}} -> 
                    io:format("User ~p is logged in, joining lobby~n", [User]),
                    Lobby ! {joinLobby, User, FromPid},
                    server_loop(Lobby, Users, ActiveMatches);
                _ -> 
                    io:format("User ~p is NOT logged in, sending error~n", [User]),
                    FromPid ! {error, "not_logged_in"},
                    server_loop(Lobby, Users, ActiveMatches)
            end;

        {start, MatchPid} -> 
            io:format("Match started: ~p~n", [MatchPid]),
            server_loop(Lobby, Users, [MatchPid | ActiveMatches]);
            
        {matchover, Winner, Loser, WinnerPid, LoserPid} -> 
            io:format("Match over. Winner: ~p, Loser: ~p~n", [Winner, Loser]),
            
            WinnerPid ! winner,
            LoserPid ! loser,
            
            UpdatedUsersStreak1 = updateStreak(Winner, "win", Users),
            UpdatedUsersStreak = updateStreak(Loser, "lose", UpdatedUsersStreak1),
            UpdatedUsers1 = updateLevel(Winner, UpdatedUsersStreak),
            UpdatedUsers = updateLevel(Loser, UpdatedUsers1),
            
            NewActiveMatches = lists:delete(hd(ActiveMatches), ActiveMatches),
            save_accounts(UpdatedUsers),
            
            io:format("Updated accounts after match between ~p and ~p~n", [Winner, Loser]),
            server_loop(Lobby, UpdatedUsers, NewActiveMatches);
              
        {matchdraw, User1, User2, Pid1, Pid2} -> 
            io:format("Match draw between ~p and ~p~n", [User1, User2]),
            
            Pid1 ! draw,
            Pid2 ! draw,
            
            UpdatedUsers1 = updateStreak(User1, "draw", Users),
            UpdatedUsers = updateStreak(User2, "draw", UpdatedUsers1),
            
            NewActiveMatches = lists:delete(hd(ActiveMatches), ActiveMatches),
            save_accounts(UpdatedUsers),
            
            io:format("Updated accounts after draw match between ~p and ~p~n", [User1, User2]),
            server_loop(Lobby, UpdatedUsers, NewActiveMatches);
        
        {get_level, Username, FromPid} -> 
            Level = case maps:find(Username, Users) of
                       {ok, {_, _, PlayerLevel, _}} -> PlayerLevel;
                       _ -> 1
                   end,
            FromPid ! {level, Level},
            server_loop(Lobby, Users, ActiveMatches);
              
        stop -> 
            io:format("Server stopping~n"),
            % Set all accounts to offline status on server stop
            OfflineUsers = set_all_offline(Users),
            save_accounts(OfflineUsers),
            io:format("All users set to offline status on server stop~n"),
            Lobby ! stop,
            unregister(lobby),
            [MatchPid ! stop || MatchPid <- ActiveMatches],
            ok
        end.
    

acceptor(LSock, Lobby) -> 
    {ok, Sock} = gen_tcp:accept(LSock),
    spawn(fun() -> acceptor(LSock, Lobby) end),
    client(Sock, Lobby).

client(Sock, Lobby) -> 
    receive
        {tcp_closed, _} -> 
            io:format("Client connection closed~n"),
            Lobby ! {leave, self()};
        {tcp_error, _, Reason} -> 
            io:format("Client connection error: ~p~n", [Reason]),
            Lobby ! {error, self()};
        {tcp, _, Data} -> 
            parse_client_input(Data, Sock),
            client(Sock, Lobby)
    end.

clean_input(Data) ->
    % Convert binary to string
    Str = binary_to_list(Data),
    % Remove trailing \r and \n explicitly
    Str2 = strip_crlf(Str),
    % Then trim spaces and tabs
    string:trim(Str2, both, " \t\n\r").

strip_crlf(Str) ->
    case lists:reverse(Str) of
        [$\n, $\r | RestRev] -> lists:reverse(RestRev);
        [$\n | RestRev] -> lists:reverse(RestRev);
        [$\r | RestRev] -> lists:reverse(RestRev);
        _ -> Str
    end.


parse_client_input(Data, Sock) ->
CleanData = clean_input(Data),
Parts = lists:map(fun(S) -> string:trim(S, both, " \t\n\r") end,
                  string:split(CleanData, ":", all)),


io:format("Raw input: ~p~n", [Data]),
io:format("Parsed parts: ~p~n", [Parts]),

    case Parts of
        ["login", Message] ->
            TrimmedMessage = string:trim(Message, both, " \t"),
            [User, Pwd] = string:split(TrimmedMessage, "#"),
            CleanUser = string:trim(User, both, " \t"),
            CleanPwd = string:trim(Pwd, both, " \t"),
            ?MODULE ! {login, CleanUser, CleanPwd, self()},
            receive
                done_login -> gen_tcp:send(Sock, "login:done\n");
                invalid_user -> gen_tcp:send(Sock, "login:invalid_user\n");
                invalid_password -> gen_tcp:send(Sock, "login:invalid_password\n");
                already_login -> gen_tcp:send(Sock, "login:already_login\n")
            end;
        
        ["logout", Username] ->
            CleanUsername = string:trim(Username, both, "\s\t\n\r"),
            ?MODULE ! {logout, CleanUsername, self()},
            receive 
                done_logout -> gen_tcp:send(Sock, "logout:done\n");
                invalid_user -> gen_tcp:send(Sock, "logout:invalid_user\n");
                already_logout -> gen_tcp:send(Sock, "logout:already_logout\n")
            end;
        
        ["create_account", Message] ->
            case string:split(Message, "#") of
                [User, Pwd] ->
                    CleanUser = string:trim(User, both, "\s\t\n\r"),
                    CleanPwd = string:trim(Pwd, both, "\s\t\n\r"),
                    ?MODULE ! {create_account, CleanUser, CleanPwd, self()},
                    receive 
                        done_acc -> gen_tcp:send(Sock, "create_account:done\n");
                        user_exists -> gen_tcp:send(Sock, "create_account:user_exists\n");
                        invalid_password -> gen_tcp:send(Sock, "create_account:invalid_password\n")
                    after 5000 ->
                        gen_tcp:send(Sock, "create_account:timeout\n")
                    end;
                _ ->
                    gen_tcp:send(Sock, "create_account:invalid_format\n")
            end;

        ["remove_account", Message] ->
            [User, Pwd] = string:split(Message, "#"),
            CleanUser = string:trim(User, both, "\s\t\n\r"),
            CleanPwd = string:trim(Pwd, both, "\s\t\n\r"),
            ?MODULE ! {remove_account, CleanUser, CleanPwd, self()},
            receive 
                done_remove -> gen_tcp:send(Sock, "remove_account:done\n");
                invalid_user -> gen_tcp:send(Sock, "remove_account:invalid_user\n");
                invalid_password -> gen_tcp:send(Sock, "remove_account:invalid_password\n")
            end;

        ["join", Username] ->
            CleanUsername = string:trim(Username, both, "\s\t\n\r"),
            ?MODULE ! {join, CleanUsername, self()},
            receive
                done ->
                    gen_tcp:send(Sock, "join:done\n"),
                    wait_for_match_start(Sock, CleanUsername);
                {error, Reason} ->
                    gen_tcp:send(Sock, io_lib:format("join:error:~s\n", [Reason]))
            after 20000 ->
                gen_tcp:send(Sock, "join:timeout\n")
            end;        
        ["leave", Username] ->
            CleanUsername = string:trim(Username, both, "\s\t\n\r"),
            io:format("Received leave request for user: ~p~n", [CleanUsername]),
            case whereis(lobby) of
                undefined ->
                    io:format("Lobby process not found, sending error to client~n"),
                    case gen_tcp:send(Sock, "leave:error:lobby_not_found\n") of
                        ok -> io:format("Sent leave:error:lobby_not_found successfully~n");
                        {error, Reason} -> io:format("Failed to send leave:error:lobby_not_found: ~p~n", [Reason])
                    end;
                LobbyPid ->
                    io:format("Sending leave_by_username to lobby: ~p~n", [LobbyPid]),
                    LobbyPid ! {leave_by_username, CleanUsername, self()},
                    io:format("Waiting for response from lobby...~n"),
                    receive
                        done ->
                            io:format("Received 'done' from lobby, sending leave:done~n"),
                            case gen_tcp:send(Sock, "leave:done\n") of
                                ok -> io:format("Sent leave:done successfully~n");
                                {error, Reason} -> io:format("Failed to send leave:done: ~p~n", [Reason])
                            end;
                        not_in_lobby ->
                            io:format("Received 'not_in_lobby' from lobby, sending response~n"),
                            case gen_tcp:send(Sock, "leave:not_in_lobby\n") of
                                ok -> io:format("Sent leave:not_in_lobby successfully~n");
                                {error, Reason} -> io:format("Failed to send leave:not_in_lobby: ~p~n", [Reason])
                            end
                    after 5000 ->
                        io:format("Timeout waiting for response from lobby~n"),
                        case gen_tcp:send(Sock, "leave:timeout\n") of
                            ok -> io:format("Sent leave:timeout successfully~n");
                            {error, Reason} -> io:format("Failed to send leave:timeout: ~p~n", [Reason])
                        end
                    end
            end;


            ["top_ten"] ->
                ?MODULE ! {top_ten, self()},
                receive
                    {top_ten, TopTen} -> gen_tcp:send(Sock, io_lib:format("top_ten:done:~s\n", [TopTen]));
                    {error, Reason} -> gen_tcp:send(Sock, io_lib:format("top_ten:error:~s\n", [Reason]))
                end;

            ["stop"] ->
                ?MODULE ! stop,
                gen_tcp:close(Sock);

            [_, Message] ->
                io:format("Unknown request: ~p~n", [Message])
        end.

wait_for_match_start(Sock, Username) ->
    receive
        {match_started, MatchPid} ->
            gen_tcp:send(Sock, "match:starting\n"),
            client_match_loop(Sock, MatchPid, Username);
        {error, Reason} ->
            gen_tcp:send(Sock, io_lib:format("match:error:~s\n", [Reason]))
    after 30000 ->
        gen_tcp:send(Sock, "match:timeout\n")
    end.


lobby(Queue) -> 
    receive 
        {joinLobby, User, FromPid} -> 
            io:format("User ~p joined lobby~n", [User]),
            NewQueue = Queue ++ [{User, FromPid}],
            FromPid ! done,
            form_matches(NewQueue, []);   
             
        {leave, User, FromPid} ->
            case lists:keyfind(FromPid, 2, Queue) of
                false ->
                    FromPid ! not_in_lobby,
                    lobby(Queue);
                _ ->
                    io:format("User ~p left the lobby~n", [User]),
                    NewQueue = lists:keydelete(FromPid, 2, Queue),
                    FromPid ! done,
                    lobby(NewQueue)
            end;
            
        {leave_by_username, Username, FromPid} ->
            case lists:keyfind(Username, 1, Queue) of
                false ->
                    FromPid ! not_in_lobby,
                    lobby(Queue);
                {Username, _} ->
                    io:format("User ~p left the lobby (by username)~n", [Username]),
                    NewQueue = lists:keydelete(Username, 1, Queue),
                    FromPid ! done,
                    lobby(NewQueue)
            end;
            
        stop -> 
            io:format("Lobby stopping~n"),
            ok
    end.

form_matches([], RemainingQueue) -> 
    lobby(lists:reverse(RemainingQueue));
form_matches([Player1 = {User1, Pid1} | Rest], RemainingQueue) -> 
    Level1 = get_player_level(User1),
    case find_compatible_opponent(Rest, Level1) of
        {found, Player2 = {_, Pid2}, RemainingPlayers} -> 
            MatchPid = spawn(fun() -> match(?MODULE, [Player1, Player2]) end),
            ?MODULE ! {start, MatchPid},
            Pid1 ! {match_started, MatchPid},
            Pid2 ! {match_started, MatchPid},
            form_matches(RemainingPlayers, RemainingQueue);
        not_found -> 
            form_matches(Rest, [Player1 | RemainingQueue])
    end.

find_compatible_opponent(Players, Level1) -> 
    find_compatible_opponent(Players, Level1, []).

find_compatible_opponent([], _, _) -> 
    not_found;
find_compatible_opponent([Player2 = {User2, _} | Rest], Level1, Acc) -> 
    Level2 = get_player_level(User2),
    case abs(Level1 - Level2) =< 1 of
        true -> 
            {found, Player2, Acc ++ Rest};
        false -> 
            find_compatible_opponent(Rest, Level1, [Player2 | Acc])
    end.

get_player_level(Username) -> 
    case whereis(?MODULE) of
        undefined -> 
            1;
        ServerPid -> 
            ServerPid ! {get_level, Username, self()},
            receive
                {level, Level} -> Level
            after 1000 -> 
                1
            end
    end.

save_accounts(Users) -> 
    FilePath = filename:join(filename:dirname(code:which(?MODULE)), "accounts.dat"),
    io:format("Saving accounts to: ~p~n", [FilePath]),
    case file:open(FilePath, [write]) of
        {ok, File} -> 
            try
                maps:fold(
                    fun(User, {Pwd, LoggedIn, Level, Streak}, _) -> 
                        CleanUser = string:trim(User),
                        CleanPwd = string:trim(Pwd),
                        io:format(File, "~s,~s,~w,~w,~w~n", [CleanUser, CleanPwd, LoggedIn, Level, Streak])
                    end,
                    ok,
                    Users
                ),
                file:sync(File)
            after
                file:close(File)
            end,
            io:format("Accounts saved successfully~n");
        {error, Reason} -> 
            io:format("Error saving accounts: ~p~n", [Reason])
    end.

load_accounts() -> 
    FilePath = filename:join(filename:dirname(code:which(?MODULE)), "accounts.dat"),
    io:format("Loading accounts from: ~p~n", [FilePath]),
    case file:open(FilePath, [read]) of
        {ok, File} -> 
            try
                Users = read_accounts(File, #{}),
                io:format("Accounts loaded successfully~n"),
                Users
            after
                file:close(File)
            end;
        {error, enoent} -> 
            io:format("Accounts file does not exist, creating new database~n"),
            #{}; 
        {error, Reason} -> 
            io:format("Error loading accounts: ~p~n", [Reason]),
            #{}
    end.

read_accounts(File, Users) -> 
    case file:read_line(File) of
        {ok, Line} -> 
            TrimmedLine = string:trim(Line, trailing, "\r\n"),
            case string:prefix(string:trim(TrimmedLine), "//") of
                nomatch ->
                    case string:trim(TrimmedLine) of
                        "" -> 
                            read_accounts(File, Users);
                        ValidLine ->
                            try
                                Tokens = string:tokens(ValidLine, ","),
                                case length(Tokens) of
                                    5 ->
                                        [User, Pwd, LoggedInStr, LevelStr, StreakStr] = Tokens,
                                        CleanUser = string:trim(User),
                                        CleanPwd = string:trim(Pwd),
                                        
                                        LoggedIn = case LoggedInStr of
                                            "true" -> true;
                                            _ -> false
                                        end,
                                        
                                        {Level, _} = string:to_integer(LevelStr),
                                        {Streak, _} = string:to_integer(StreakStr),
                                        
                                        UpdatedUsers = maps:put(CleanUser, {CleanPwd, LoggedIn, Level, Streak}, Users),
                                        read_accounts(File, UpdatedUsers);
                                    _ ->
                                        io:format("Skipping malformed line (wrong field count): ~p~n", [ValidLine]),
                                        read_accounts(File, Users)
                                end
                            catch
                                _:Error -> 
                                    io:format("Error parsing line: ~p - Error: ~p~n", [ValidLine, Error]),
                                    read_accounts(File, Users)
                            end
                    end;
                _ ->
                    read_accounts(File, Users)
            end;
        eof -> 
            Users;
        {error, Reason} -> 
            io:format("Error reading accounts: ~p~n", [Reason]),
            Users
    end.

topTen(Map) -> 
    Users = maps:to_list(Map),
    
    F = fun({Username, {_, _, Level, Streak}}) -> 
        {Username, Level, Streak}
    end,

    UserStats = lists:map(F, Users),

    SortedUsers = lists:sort(
        fun({_, L1, S1}, {_, L2, S2}) -> 
            if 
                L1 == L2 -> 
                    S1 >= S2;
                true -> 
                    L1 >= L2
            end
        end, 
        UserStats),
    
    lists:sublist(SortedUsers, 10).

updateLevel(User, Map) -> 
    case maps:find(User, Map) of
        {ok, {Password, Status, Level, Streak}} ->       
                if
                    Streak > 0 andalso Streak rem Level == 0-> 
                        NewLevel = Level + 1,
                        NewMap = maps:update(User, {Password, Status, NewLevel, 0}, Map),
                        io:format("Congratulations! You are now level~p~n" , [NewLevel]),
                        NewMap;
                    Streak < 0 andalso Streak rem -ceil(Level/2) == 0 -> 
                        case Level of
                            1 -> 
                                io:format("Minimum possible level reached~n"),
                                Map;
                            _ -> 
                                NewLevel = Level - 1,
                                NewMap = maps:update(User, {Password, Status, NewLevel, 0}, Map),
                                io:format("Try harder next time. You are now level~p~n" , [NewLevel]),
                                NewMap
                        end;
                    true -> 
                        Map
                end;
        _ -> 
            Map
    end.

updateStreak(User, What, Map) ->
    case maps:find(User, Map) of
        {ok, {Password, Status, Level, Streak}} ->
            NewStreak = case What of
                "win" ->
                    if Streak > 0 -> Streak + 1; true -> 1 end;
                "lose" ->
                    if Streak > 0 -> -1; true -> Streak - 1 end;
                "draw" ->
                    0
            end,
            maps:update(User, {Password, Status, Level, NewStreak}, Map);
        _ ->
            Map
    end.

% Set all accounts to offline status
set_all_offline(Users) ->
    io:format("Setting all accounts to offline status~n"),
    maps:map(
        fun(_User, {Pwd, _, Level, Streak}) ->
            {Pwd, false, Level, Streak}
        end,
        Users
    ).