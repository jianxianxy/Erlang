-module(try_test).
-export([demo/1]).

demo(N)->
	try ct(N) of 
		Val->{N,Val}
	catch
		throw:X	->{N,X};
		exit:X	->{N,X};
		error:X	->{N,X}
	end.
ct(N) when N < 1 -> 'Val < 0';
ct(1)->return_ok;
ct(2)->throw(throw);
ct(3)->exit(exit);
ct(4)->erlang:error(error);
ct(N) when N > 4 -> 'Val > 4'.
