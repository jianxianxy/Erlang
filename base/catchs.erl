-module(catchs).
-export([go/0]).

go() ->
    eval(io:parse_exprs('=>')), %% '=>' is the prompt
    go().

eval({from,Exprs}) ->
    case catch eval:exprs(Exprs,[]) of
        {'EXIT',What} ->
            io:format("Error ~w!~n",[What]);
        {value,What,_} ->
            io:format("Result ~w~n",[What])
    end;

eval(_) ->
    io:format("Syntax Error ~n",[]).
