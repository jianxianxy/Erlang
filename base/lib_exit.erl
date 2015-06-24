-module(lib_exit).
-export([start/0]).
on_exit(Pid,Fun) ->
    spawn(fun()->
	Ref = monitor(process,Pid),
	receive
	    {'DOWN',Ref,process,Pid,Why} ->
		Fun(Why)
	end
    end).
start() ->
    Pid = spawn(fun() -> test() end),
    on_exit(Pid,fun(Why)->
	io:format("Pid: ~p ~nWhy: ~p ~nOther:",[Pid,Why])	
    end),
    Pid ! hello.
test() ->
    receive
	X -> list_to_atom(X)
    end.	
