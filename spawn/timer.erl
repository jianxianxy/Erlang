-module(timer).
-compile(export_all).

timeout(Time,Alarm) ->
    spawn(timer,timer,[self(),Time,Alarm]).

cancel(Timer) ->
    Timer ! {self(),cancel}.

timer(Pid,Time,Alarm) ->
    receive
        {Pid,cancel} ->
%            io:format("Cancel ~n",[]),
            true
    after Time ->
        Pid ! Alarm
    end.
