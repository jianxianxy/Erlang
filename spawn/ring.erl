-module(ring).
-compile(export_all).

start(N) ->
    spawn(?MODULE,loop,[N,self(),N]).

loop(N,Pid,M) when N > 1 ->
    io:format("***Create Curr:~p From:~p Make:~p~n",[N,Pid,self()]),
    spawn(?MODULE,loop,[N-1,self(),M]),
    receive
        {Msg,Pif} ->
            if
            Msg > N ->
                io:format("***Curr:~p Begin:~p To:~p With:~p~n",[N,self(),Pid,{Pif,Msg}]),
                Pid ! {Msg,Pif};
            Msg == N ->
                io:format("***Curr:~p Begin:~p To:~p With:~p~n",[N,self(),Pif,{Pif,Msg}]),
                Pif ! {Msg,self()}
            end;
        Other ->
            io:format("***Other:~p~n",[Other])
    end;

loop(N,Pid,M) when N == 1 ->
    io:format("***Create Curr:~p From:~p Make:~p~n",[N,Pid,self()]),
    io:format("***Create Succ Begin Sending~n",[]),
    io:format("***Curr:~p Begin:~p To:~p With:~p~n",[N,self(),Pid,{self(),M}]),
    Pid ! {M,self()},
    receive
        {Msg,Pif} ->
            io:format("***Curr:~p From:~p End:~p With:~p~n",[N,Pif,self(),{Pif,Msg}]);
        Other ->
            io:format("***Other:~p~n",[Other])
    end.

