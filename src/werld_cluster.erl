-module(werld_cluster).

-behaviour(gen_server).

-export([start_link/0]).
-export([code_change/3]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([init/1]).
-export([terminate/2]).

-record(state, { interval :: non_neg_integer() }).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    Interval = application:get_env(werld, discover_interval, 1000 * 60 * 1),
    self() ! discover_nodes,
    {ok, #state{ interval = Interval }}.

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(_Request, State) ->
    {stop, unknown_cast, State}.

handle_info(discover_nodes, State) ->
    Interval = State#state.interval,
    {ok, DiscoMethods} = application:get_env(werld, discovery_methods),
    [werld:DiscoMethod() || DiscoMethod <- DiscoMethods],
    schedule_check(Interval),
    {noreply, State};
handle_info(_, State) ->
    {stop, unknown_info, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

schedule_check(Interval) ->
    erlang:send_after(Interval, self(), discover_nodes).
