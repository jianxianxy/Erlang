-module(abc).
-export([a/2,b/1,yy/1]).
a(X,Y) -> c(X)+a(Y).
a(X) -> 2*X.
b(X) -> X*X.
c(X) -> 3*X.

yy(X) -> 
	try shop:cost(X) of
		Val -> c(Val)
	catch
		_ -> exit(X)
	end.
