%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc qs.

-module(qs).
-author("Mochi Media <dev@mochimedia.com>").
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.


%% @spec start() -> ok
%% @doc Start the qs server.
start() ->
    qs_deps:ensure(),
    ensure_started(crypto),
    application:start(qs).


%% @spec stop() -> ok
%% @doc Stop the qs server.
stop() ->
    application:stop(qs).
