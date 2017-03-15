-module(werld).

-include_lib("kernel/src/inet_dns.hrl").

-export([net_adm_world/0]).
-export([inet_res_nslookup/0]).

net_adm_world() ->
    try
        net_adm:world()
    catch exit:{error, enoent} ->
            lager:info("No .hosts.erlang file found.")
    end.


inet_res_nslookup() ->
    {ok, CName} = application:get_env(werld, discovery_cname),
    try
        {ok, Msg} = inet_res:nslookup(CName, in, a),
        ExtractedHosts = extract_hosts(Msg),
        [begin
             lager:info("Attempting to connect to: ~p", [Host]),
             true = net_kernel:connect(Host),
             lager:info("Connected to: ~p", [Host]),
             Host
         end || Host <- ExtractedHosts],
        ok
    catch
        E:R ->
            lager:error("Error looking up hosts: ~p", [{E, R, erlang:get_stacktrace()}]),
            {error, {E, R}}
    end.

extract_hosts(#dns_rec{anlist=ANList}) ->
    [data_to_node_name(Data) || #dns_rr{data=Data} <- ANList].

data_to_node_name({A, B, C, D}) ->
    {ok, Release} = application:get_env(werld, expected_release_name),
    list_to_atom(lists:flatten(io_lib:format("~p@~b.~b.~b.~b", [Release, A, B, C, D]))).
