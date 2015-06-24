-module(tut12).
-export([start/0,say/2]).

say(What,0) ->
    done;
say(What,Times) ->
    io:format("~p~n",[What]),
    say(What,Times-1).
start() ->
    spawn(tut12,say,[hellow,3]),
    spawn(tut12,say,[goodbuy,3]).
