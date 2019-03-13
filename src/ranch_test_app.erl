%%%-------------------------------------------------------------------
%% @doc ranch_test public API
%% @end
%%%-------------------------------------------------------------------

-module(ranch_test_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    case ranch_test_sup:start_link() of
        {error, Reason} ->
            {error, Reason};
        {ok, Pid} ->
            ok = tcp_server:start_listeners(),
            {ok, Pid}
    end.

stop(_State) ->
    ok.
