-module(tut16).
-export([start/0,ping/1,pong/0]).
ping(0)->
    pong ! finished,
    io:format("ping finished ~n",[]);
ping(N)->
    pong ! {ping,self()},
    receive
        Rc ->
            [A|_] = Rc,
            io:format("ping received pong ~p~n",[A])
   end,
   ping(N-1).

pong() -> 
    receive
        finished->
            io:format("Pong finished ~n",[]);
        {ping,Ping_PID}->
            io:format("Pong recevie ping ~n"),
            Ping_PID ! [ok,pong],
            pong()
    end.

start()->
    register(pong,spawn(tut16,pong,[])),
    spawn(tut16,ping,[3]).
