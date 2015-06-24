-module(chat_client).
-import(io_widget,[get_state/1,insert_str/2,set_prompt/2,set_state/2,set_title/2,set_handler/2,update_state/3]).
-export([start/0,test/0,connect/5]).

start() ->
    connect("localhost",2223,"AsD123T","general","joe").

connect(Host,Port,HostPsw,Group,Nick) ->
    spawn(fun() -> handler(Host,Port,HostPsw,Group,Nick) end).

handler(Host,Port,HostPsw,Group,Nick) ->
    process_flag(trap_exit,true),
    Widget = io_widget:start(self()),
    set_title(Widget,Nick),
    set_state(Widget,Nick),
    set_prompt(Widget,[Nick," > "]),
    set_handle(Widget,fun parse_command/1),
    start_connector(Widget,Group,Nick),
    disconnected(Widget,Group,Nick).

disconnected(Width,Group,Nick) ->
    receive
	{connected,MM} ->
	    insert_str(Widget,"connected to server.")
