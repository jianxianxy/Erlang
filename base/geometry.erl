-module(geometry).
-export([area/1]).
area({rectangle,Width,Ht})->Width*Ht;
area({zhouc,Wint,Hint})->2*(Wint+Hint);
area({circle,R})->3.14*R*R.
