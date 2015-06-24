-module(lib_chan_cs).
%% 实现服务器端结构和机制的模块

-export([start_raw_server/4, start_raw_client/3]).
-export([stop/1]).
-export([children/1]).

%% 客户端调用，用来连接服务器
start_raw_client(Host, Port, PacketLength) ->
    gen_tcp:connect(Host, Port,
            [binary, {active, true}, {packet, PacketLength}]).

%%启动服务器
%%以给定端口创建名字，如果该端口已经注册则服务器已经启动
%%如果端口未注册，则新建进程启动服务器，如果成功启动，则注册端口为新建进程号
%%调用cold_start新建进程来启动服务器，需要传入当前进程以便能获取新建进程的消息
%%新建进程传回进程id以确保接收到的信息是由新建进程传回的。
start_raw_server(Port, Fun, Max, PacketLength) ->
    Name = port_name(Port),
    case whereis(Name) of
    undefined ->
        Self = self(),
        Pid = spawn_link(fun() ->
                 cold_start(Self,Port,Fun,Max,PacketLength)
                 end),
        receive
        {Pid, ok} ->
            register(Name, Pid),
            {ok, self()};
        {Pid, Error} ->
            Error
        end;
    _Pid ->
        {error, already_started}
    end.

stop(Port) when integer(Port) ->
    Name = port_name(Port),
    case whereis(Name) of
    undefined ->
        not_started;
    Pid ->
        exit(Pid, kill),
        (catch unregister(Name)),
        stopped
    end.


%%获取连接到某端口的socket
children(Port) when integer(Port) ->
    port_name(Port) ! {children, self()},
    receive
    {session_server, Reply} -> Reply
    end.


port_name(Port) when integer(Port) ->
    list_to_atom("portServer" ++ integer_to_list(Port)).

%%监听端口
%%开始新建进程接受客户端连接，如果接收到连接，则调用Fun(Socket)
%%如果一个进程已经接收了一个连接，则需要再次新建进程接收客户端连接
%%最多只能接受Max个连接，超过了后将不再新建进程接收客户端连接，直到有其他的连接结束
cold_start(Master, Port, Fun, Max, PacketLength) ->
    process_flag(trap_exit, true),
    %% io:format("Starting a port server on ~p...~n",[Port]),
    case gen_tcp:listen(Port, [binary,
                   %% {dontroute, true},
                   {nodelay,true},
                   {packet, PacketLength},
                   {reuseaddr, true}, 
                   {active, true}]) of
    {ok, Listen} ->
        %% io:format("Listening to:~p~n",[Listen]),
        Master ! {self(), ok},
        New = start_accept(Listen, Fun),
        %% Now we're ready to run
        socket_loop(Listen, New, [], Fun, Max);
    Error ->
        Master ! {self(), Error}
    end.


socket_loop(Listen, New, Active, Fun, Max) ->
    receive
    {istarted, New} ->
        Active1 = [New|Active],
        possibly_start_another(false,Listen,Active1,Fun,Max);
    {'EXIT', New, _Why} ->
        %% io:format("Child exit=~p~n",[Why]),
        possibly_start_another(false,Listen,Active,Fun,Max);
    {'EXIT', Pid, _Why} ->
        %% io:format("Child exit=~p~n",[Why]),
        Active1 = lists:delete(Pid, Active),
        possibly_start_another(New,Listen,Active1,Fun,Max);
    {children, From} ->
        From ! {session_server, Active},
        socket_loop(Listen,New,Active,Fun,Max);
    _Other ->
        socket_loop(Listen,New,Active,Fun,Max)
    end.


possibly_start_another(New, Listen, Active, Fun, Max) 
  when pid(New) ->
    socket_loop(Listen, New, Active, Fun, Max);
possibly_start_another(false, Listen, Active, Fun, Max) ->
    case length(Active) of
    N when N < Max ->
        New = start_accept(Listen, Fun),
        socket_loop(Listen, New, Active, Fun,Max);
    _ ->
        socket_loop(Listen, false, Active, Fun, Max)
    end.

start_accept(Listen, Fun) ->
    S = self(),
    spawn_link(fun() -> start_child(S, Listen, Fun) end).

start_child(Parent, Listen, Fun) ->
    case gen_tcp:accept(Listen) of
    {ok, Socket} ->
        Parent ! {istarted,self()},            % tell the controller
        inet:setopts(Socket, [{packet,4},
                  binary,
                  {nodelay,true},
                  {active, true}]), 
        %% before we activate socket
        %% io:format("running the child:~p Fun=~p~n", [Socket, Fun]),
        process_flag(trap_exit, true),
        case (catch Fun(Socket)) of
        {'EXIT', normal} ->
            true;
        {'EXIT', Why} ->
            io:format("Port process dies with exit:~p~n",[Why]),
            true;
        _ ->
            %% not an exit so everything's ok
            true
        end
    end.
