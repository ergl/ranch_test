
-module(tcp_server_worker).

-behaviour(gen_server).
-behavior(ranch_protocol).

-record(state, { socket, transport }).

%% ranch_protocol callback
-export([start_link/4]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).


%% Ranch workaround for gen_server
start_link(Ref, _Socket, Transport, Opts) ->
    {ok, proc_lib:spawn_link(?MODULE, init, [{Ref, Transport, Opts}])}.

init({Ref, Transport, _Opts}) ->
    {ok, Socket} = ranch:handshake(Ref),
    ok = Transport:setopts(Socket, [{active, once}, {packet, 2}]),
    gen_server:enter_loop(?MODULE, [], #state{socket = Socket, transport = Transport}).

handle_call(E, _From, S) ->
    io:format("unexpected call: ~p~n", [E]),
    {reply, ok, S}.

handle_cast(E, S) ->
    io:format("unexpected cast: ~p~n", [E]),
    {noreply, S}.

handle_info({tcp, Socket, Data}, State = #state{socket=Socket, transport=Transport}) ->
    Transport:send(Socket, Data),
    Transport:setopts(Socket, [{active, once}]),
    {noreply, State};

handle_info({tcp_closed, _Socket}, S) ->
    {stop, normal, S};

handle_info({tcp_error, _Socket, Reason}, S) ->
    {stop, Reason, S};

handle_info(timeout, State) ->
    {stop, normal, State};

handle_info(E, S) ->
    io:format("unexpected info: ~p~n", [E]),
    {noreply, S}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_, #state{socket=undefined, transport=undefined}) ->
    ok;

terminate(_Reason, #state{socket=Socket, transport=Transport}) ->
    catch Transport:close(Socket),
    ok.
