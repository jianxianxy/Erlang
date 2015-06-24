-module(area_server0).
-export([loop/0]).
loop() ->
    receive
	{From,{rectangle,Width,Ht}} ->
	    From ! Width * Ht,
		loop();
	{circle,R} ->
	    io:format("Area of circle is ~p~n",[3.14*R*R]),
		loop();
	Other ->
	    io:format("I don't kown what the area ~p id ~n",[Other]),
		loop()
end.
