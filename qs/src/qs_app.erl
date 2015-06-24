%% @author Mochi Media <dev@mochimedia.com>
%% @copyright qs Mochi Media <dev@mochimedia.com>

%% @doc Callbacks for the qs application.

-module(qs_app).
-author("Mochi Media <dev@mochimedia.com>").

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for qs.
start(_Type, _StartArgs) ->
    qs_deps:ensure(),
    qs_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for qs.
stop(_State) ->
    ok.
