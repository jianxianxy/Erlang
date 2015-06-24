-module(attrs).
-vsn(12.26).
-author({747,nick}).
-purpose("example of attr").
-export([fac/1]).
fac(1) -> 1;
fac(N) -> N * fac(N-1).
