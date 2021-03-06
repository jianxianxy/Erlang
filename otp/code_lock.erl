-module(code_lock).
-behaviour(gen_fsm).
-compile(export_all).

start(Code)->
    gen_fsm:start_link({local,code_lock},code_lock,lists:reverse(Code),[]).

button(Digit)->
    gen_fsm:send_event(code_lock,{button,Digit}).

init(Code)->
    {ok,locked,{[],Code}}.

locked({button,Digit},{SoFar,Code})->
    case [Digit|SoFar] of
        Code ->
            io:format("Matching success"),
            {next_state,open,{[],Code},3000};
        Inc when length(Inc)<length(Code) ->
            io:format("Curr ~p~n",[Inc]),
            {next_state,locked,{Inc,Code}};
        _Wrong ->
            io:format("Why ~p~n",[_Wrong]),
            {next_state,locked,{[],Code}}
    end.

open(timeout,State)->
    io:format("Lock is opened~n"),
    {next_state,locked,State}.

stop()->
    gen_fsm:send_all_state_event(code_lock,stop).

handle_event(stop,_StateMame,StateData)->
    {stop,normal,StateData}.

handle_info({'EXIT',Pid,Reason},StateName,StateData)->
    io:format("~p ~p ~n",[Pid,Reason]),
    {next_state,StateName,StateData}.

terminate(normal,_StateName,_StateData)->
    ok.
