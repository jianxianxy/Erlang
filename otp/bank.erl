-module(bank).
-behaviou(rgen_server).
-export([init/1,handle_call/3,handle_case/2,handle_info/2,
        terminate/2,code_change/3]).
-compile(export_all).
start()->
    gen_server:start_link({local,?MODULE},?MODULE,{init,3},[]).
stop()->
    gen_server:call(?MODULE,stop).
account(Who)->
    gen_server:call(?MODULE,{new,Who}).
add(Who,Amount)->
    gen_server:call(?MODULE,{add,Who,Amount}).
pay(Who,Amount)->
    gen_server:call(?MODULE,{pay,Who,Amount}).

init(Init)->
    io:format("Init:~p~n",[Init]),
    {ok,ets:new(?MODULE,[])}.
config(Init)->
    io:format("Config:~p~n",[Init]),
    {ok,ets:new(?MODULE,[])}.
handle_call({new,Who},_From,Tab)->
    Reply = case ets:lookup(Tab,Who) of
        [] -> ets:insert(Tab,{Who,0}),
            {welcome,Who};
        [_] ->{Who,"Already Exists."}
    end,
    {reply,Reply,Tab};
handle_call({add,Who,X},_From,Tab)->
    Reply = case ets:lookup(Tab,Who) of
        [] -> io:format("Not hava ~p~n",[Who]);
    [{Who,Balance}] ->
        NewBalance = Balance+X,
        ets:insert(Tab,{Who,NewBalance}),
        {thanks,Who,balance,NewBalance}
    end,
    {reply,Reply,Tab};
handle_call({pay,Who,X},_From,Tab)->
    Reply = case ets:lookup(Tab,Who) of
        [] -> {sorry,"not have",Who,users};
        [{Who,Balance}] when X =< Balance ->
            NewBalance  = Balance-X,
            ets:insert(Tab,{Who,NewBalance}),
            {thanks,Who,balance,NewBalance};
        [{Who,Balance}] ->
            {sorry,Who,only,Balance}
    end,
    {reply,Reply,Tab};
handle_call(stop,_From,Tab) ->
    {stop,mormal,stopped,Tab}.

handle_case(_Msg,State)->
    {norreply,State}.
handle_info(_Info,State)->
    {noreply,State}.
terminate(_Reason,_State)->ok.
code_change(_OldVsn,State,Extra)->
    io:format("change ~p~n",[Extra]),
    {ok,State}.
