-module(server1).
-export([start/2,rpc/2]).

start(Name,Mod) ->
    io:format("Server ~p~n",[self()]),
    register(Name,spawn(fun() -> loop(Name,Mod,Mod:init()) end)).

rpc(Name,Request) ->
    io:format("Rpc ~p Name ~p~n",[self(),Name]),
    Name ! {self(),Request},
    receive
        {Name,Response} -> Response
    end.

loop(Name,Mod,State) ->
    receive
        {From,Request} ->
            {Response,State1} = Mod:handle(Request,State),
            From ! {Name,Response},
            loop(Name,Mod,State1)
    end.
