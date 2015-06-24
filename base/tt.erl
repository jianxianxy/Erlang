-module(tt).
-compile(export_all).

test() ->
    spawn_link(tt,p,[1]),
    receive
        X ->
            X
    end.

p(N) ->
    N = 2.
