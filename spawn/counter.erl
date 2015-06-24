-module(counter).
-compile(export_all).

start() ->
    spawn(counter,loop,[0]).

increment(Counter) ->
    Counter ! increment.

value(Counter) ->
    Counter ! {self(),value},
    receive
        {Counter,Value} ->
            Value
    end.

stop(Counter) ->
    Counter ! stop.

loop(Val) ->
    receive
        increment ->
            loop(Val + 1);
        {From,value} ->
            From ! {self(),Val},
            loop(Val);
        stop ->
            true;
        Other ->
            loop(Val)
    end.
