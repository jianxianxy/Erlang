-module(usr_db).
-include("usr.hrl").
-compile(export_all).

init()->
    create_tables("UsrTabFile"),
    Seq = lists:seq(1,1000),
    Add = fun(Id)->add_usr(#usr{msisdn=1000000+Id,id=Id,plan=prepay,services=[data,sms]}) end,
    lists:foreach(Add,Seq),
    io:format("Begin ~p End ~p~n",[1000000+1,1000000+1000]).
start()->
    create_tables("UsrTabFile").
create_tables(FileName)->
    ets:new(usrRam,[named_table,{keypos,#usr.msisdn}]),
    ets:new(usrIndex,[named_table]),
    dets:open_file(usrDisk,[{file,FileName},{keypos,#usr.msisdn}]).
close_tables()->
    ets:delete(usrRam),
    ets:delete(usrIndex),
    dets:close(usrDisk).
add_usr(#usr{msisdn=PhoneNo,id=CustId}=Usr)->
    ets:insert(usrIndex,{CustId,PhoneNo}),
    update_usr(Usr).
update_usr(Usr)->
    ets:insert(usrRam,Usr),
    dets:insert(usrDisk,Usr),
    ok.
lookup_id(CustId)->
    case get_index(CustId) of
        {ok,PhoneNo}->lookup_msisdn(PhoneNo);
        {error,instance}->{error,instance}
    end.
lookup_msisdn(PhoneNo)->
    case ets:lookup(usrRam,PhoneNo) of
        [Usr]->{ok,Usr};
        [] ->{error,instance}
    end.
get_index(CustId)->
    case ets:lookup(usrIndex,CustId) of
        [{CustId,PhoneNo}]->{ok,PhoneNo};
        []->{error,instance}
    end.
delete_disable()->
    ets:safe_fixtable(usrRam,true),
    catch loop_delete_disable(ets:first(usrRam)),
    ets:safe_fixtable(usrRam,false),
    ok.
loop_delete_disable('$end_of_table')->
    ok;
loop_delete_disable(PhoneNo)->
    case ets:lookup(usrRam,PhoneNo) of
        [#usr{status=disable,id=CustId}]->
            delete_usr(PhoneNo,CustId);
        _->ok
    end,
    loop_delete_disable(ets:next(usrRam,PhoneNo)).
delete_usr(PhoneNo,CustId)->
    io:format("Del ~p~p~n",[PhoneNo,CustId]).
restore_backup()->
    Insert=fun(#usr{msisdn=PhoneNo,id=Id}=Usr)->
        ets:insert(usrRam,Usr),
        ets:insert(usrIndex,{Id,PhoneNo}),
        continue
        end,
    dets:traverse(usrDisk,Insert).
restore()->
    Ins = fun(X) -> io:format("~p~n", [X]), continue end,
    dets:traverse(usrDisk,Ins).
