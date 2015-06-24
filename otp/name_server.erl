-module(name_server).
-export([init/0,add/3,find/2,handle/2]).
-import(server1,[rpc/2]).

add(RegPid,Name,Place) -> rpc(RegPid,{add,Name,Place}).
find(RegPid,Name) -> rpc(RegPid,{find,Name}).
init() -> dict:new().

handle({add,Name,Place},Dict) -> {ok,dict:store(Name,Place,Dict)};
handle({find,Name},Dict) -> {dict:find(Name,Dict),Dict}.
