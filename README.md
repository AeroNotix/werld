werld
=====

An OTP application for helping discover Erlang nodes

Build
-----

    $ rebar3 compile

Configuration
-------------

sys.config:
```erlang
{werld, [
    %% Enables automatic discovery
    {automatically_discover_cluster, true},
    %% Which methods to use to learn about nodes
    {discovery_methods, [net_adm_world, inet_res_nslookup]},
    %% The CNAME record to use when looking up with inet_res_nslookup
    {discovery_cname, "foo.bar.com"}
]}
```
