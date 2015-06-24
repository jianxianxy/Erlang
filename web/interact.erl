-module(interact).
-export([start/1]).

start(Browser) -> running(Browser).

running(Browser) ->
    receive
        {Browser,#{entry => <<"input">>,txt => Bin}}
            Time = 
