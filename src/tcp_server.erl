
-module(tcp_server).

-define(POOL_SIZE, (1 * erlang:system_info(schedulers_online))).

%% API
-export([start_listeners/0]).

-spec start_listeners() -> ok.
start_listeners() ->
    DefaultPort = application:get_env(ranch_test, tcp_port, 7878),
    {ok, _} = ranch:start_listener(tcp_conn,
                                   ranch_tcp,
                                    #{num_acceptors => ?POOL_SIZE, max_connections => infinity, socket_opts => [{port, DefaultPort}]},
                                    tcp_server_worker,
                                   []),
    ok.

