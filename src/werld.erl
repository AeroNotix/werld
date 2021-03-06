-module(werld).

-include_lib("kernel/src/inet_dns.hrl").

-export([net_adm_world/0]).
-export([inet_res_nslookup/0]).
-export([expected_nodes/0]).


net_adm_world() ->
    try
        net_adm:world()
    catch exit:{error, enoent} ->
            lager:info("No .hosts.erlang file found.")
    end.


inet_res_nslookup() ->
    try
        ExpectedNodes = expected_nodes(),
        [begin
             lager:info("Attempting to connect to: ~p", [Host]),
             true = net_kernel:connect(Host),
             lager:info("Connected to: ~p", [Host]),
             Host
         end || Host <- ExpectedNodes],
        ok
    catch
        E:R:S ->
            lager:error("Error looking up hosts: ~p", [{E, R, S}]),
            {error, {E, R}, S}
    end.

expected_nodes() ->
    {ok, CName} = application:get_env(werld, discovery_cname),
    {ok, Msg} = inet_res:nslookup(CName, in, a),
    extract_hosts(Msg) -- [node()].

extract_hosts(#dns_rec{anlist=ANList}) ->
    [data_to_node_name(Data) || #dns_rr{data=Data} <- ANList].

data_to_node_name({A, B, C, D}) ->
    {ok, Release} = application:get_env(werld, expected_release_name),
    list_to_atom(lists:flatten(io_lib:format("~p@~b.~b.~b.~b", [Release, A, B, C, D]))).
