%%%-------------------------------------------------------------------
%% @doc werld top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module('werld_sup').

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    Workers = case application:get_env(werld, automatically_discover_cluster, false) of
                  false ->
                      [];
                  true ->
                      [?CHILD(werld_cluster, worker)]
              end,
    {ok, { {one_for_all, 5, 10}, Workers} }.
