-module(ch1).
-compile(export_all).

start()->
    spawn(ch1,init,[]).
init()->
    register(ch1,self()),
    Chs = channels(),
    loop(Chs).
channels()->
    {_Allocated = [],_Free = lists:seq(1,100)}.
alloc()->
    ch1 ! {self(),alloc},
    receive
        {ch1,Res} ->
            Res
    end.
alloc({Allocated,[H|T]=_Free})->
    {H,{[H|Allocated],T}}.
free(Ch)->
    ch1 ! {free,Ch},
    ok.
free(Ch,{Alloc,Free}=Channels)->
    case lists:member(Ch,Alloc) of
        true ->
            {lists:delete(Ch,Alloc),[Ch|Free]};
        false ->
            Channels    
    end.
loop(Chs)->
    io:format("~p~n",[Chs]),
    receive
        {From,alloc} ->
            {Ch,Chs2} = alloc(Chs),
            From ! {ch1,Ch},
            loop(Chs2);
        {free,Ch} ->
            Chs2 = free(Ch,Chs),
            loop(Chs2)
    end.
