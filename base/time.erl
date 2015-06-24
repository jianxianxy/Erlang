-module(time).
-compile(export_all).

run(L) ->
    S = os:timestamp(),
    Sort=rand(L,[]),
    R = sort(Sort),
    %dump(R),
    E = os:timestamp(),
    {_,Tms,Ts} = S,
    {_,Tme,Te} = E,
    io:format("S:~p~nMs:~f~n",[Tme-Tms,(Te-Ts)/1000000]).

dump([]) -> [];
dump([H|B]) ->
    io:format("~p~n",[H]),
    dump(B).

rand(0,S) ->
    S;
rand(L,S) when L>0 ->
    Tmp=round(random:uniform()*100000000),
    %io:format("~p~n",[Tmp]),
    rand(L-1,[Tmp|S]).

sort([]) -> [];
sort([Privot|Rest]) ->
    {Smaller,Bigger}=split(Privot,Rest),
    lists:append(sort(Smaller),[Privot|sort(Bigger)]).

split(Privot,L) ->
    split(Privot,L,[],[]).
split(Privot,[],Smaller,Bigger) ->
    {Smaller,Bigger};
split(Privot,[H|T],Smaller,Bigger) when H<Privot ->
    split(Privot,T,[H|Smaller],Bigger);
split(Privot,[H|T],Smaller,Bigger) when H>=Privot ->
    split(Privot,T,Smaller,[H|Bigger]).
    
