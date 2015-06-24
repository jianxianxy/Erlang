-module(mycached).
-export([start/2, server/1, loop/1, test/4, for/3, banch/6, banch_call/6]).

-define(CMD_GET, 1).
-define(CMD_SET, 2).
-define(CMD_DEL, 3).


start(LPort, Num) ->
    case gen_tcp:listen(LPort, [binary, {active, false}, {packet, 2}]) of
    
        {ok, LSock} ->
            start_servers(LSock, Num),
            
            {ok, Port} = inet:port(LSock),
            
            Port;
            
        {error, Reason} ->
            {error, Reason}
    end.


start_servers(_, 0) ->
    ok;
    
start_servers(LSock, Num) ->
    spawn(?MODULE, server, [LSock]),
    
    start_servers(LSock, Num - 1).


server(LSock) ->
    case gen_tcp:accept(LSock) of
    
        {ok, CSock} ->
            loop(CSock),
            server(LSock);
            
        Other ->
            io:format("accept returned ~w - goodbye!~n", [Other]),
            ok
    end.


loop(CSock) ->
    inet:setopts(CSock, [{active, once}]),
    
    receive
    
        {tcp, CSock, Request} ->
            Response = process(Request),
            
            Response_Bin = list_to_binary(Response),
            
            gen_tcp:send(CSock, Response_Bin),
            
            loop(CSock);
            
        {tcp_closed, CSock} ->
            io:format("socket ~w closed [~w]~n", [CSock, self()]),
            ok
    end.


process(Request) ->
    try
        {<<Type>>, Params} = split_binary(Request, 1),
        
        case Type of
            ?CMD_GET ->
                "Command: GET";
            ?CMD_SET ->
                "Command: SET";
            ?CMD_DEL ->
                "Command: DEL";
            _ ->
                "Unknow Command"
        end
    catch
        _:E -> io:format("process failed: ~w [~w]~n", [E, self()]),
        "Server Error"
    end.


test(Host, Port, Command, Params) ->
    test_call(Host, Port, Command, Params, 1).


banch(Host, Port, Command, Params, Times, RTimes) ->
    {M, _} = timer:tc(?MODULE, banch_call, [Host, Port, Command, Params, Times, RTimes]),
    
    io:format("Time: ~p micro seconds~n", [M]),
    
    ok.


banch_call(Host, Port, Command, Params, Times, RTimes) ->
    for (0, Times,
        fun() ->
            test_call(Host, Port, Command, Params, RTimes)
        end
    ),
    ok.


test_call(Host, Port, Command, Params, Times) ->
    {ok, Sock} = gen_tcp:connect(Host, Port, [binary, {active, false}, {packet, 2}]),
    
    Request = [Command, Params],
    
    Request_Bin = list_to_binary(Request),
    
    case Times of
        1 ->
            {ok, Bin} = test_send(Sock, Request_Bin),
    		
    		ok = gen_tcp:close(Sock),
			
    		Bin;

        _ ->
            for (0, Times,
                fun() ->
                    {ok, _} = test_send(Sock, Request_Bin)
                end
            ),
    		
    		ok = gen_tcp:close(Sock),
			
			ok
    end.


test_send(Sock, Request_Bin) ->
    ok = gen_tcp:send(Sock, Request_Bin),
    
    gen_tcp:recv(Sock, 0).


for (To, To, _) ->
    ok;

for (From, To, Callback) ->
    Callback(),
    for (From + 1, To, Callback).
