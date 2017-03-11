-module(werld).

-include_lib("kernel/src/inet_dns.hrl").

-export([net_adm_world/0]).
-export([inet_res_nslookup/1]).

net_adm_world() ->
    try
        net_adm:world()
    catch exit:{error, enoent} ->
            lager:info("No .hosts.erlang file found.")
    end.


inet_res_nslookup(CName) ->
    try
        {ok, Msg} = inet_res:nslookup(CName, in, a),
        ExtractedHosts = extract_hosts(Msg),
        [begin
             true = net_kernel:connect(Host),
             Host
         end || Host <- ExtractedHosts]
    catch
        E:R ->
            lager:error("Error looking up hosts: ~p", [{E, R, erlang:get_stacktrace()}])
    end.

extract_hosts(#dns_rec{anlist=ANList}) ->
    [data_to_node_name(Data) || #dns_rr{data=Data} <- ANList].

data_to_node_name({A, B, C, D}) ->
    list_to_atom(lists:flatten(io_lib:format("derl@~b.~b.~b.~b", [A, B, C, D]))).