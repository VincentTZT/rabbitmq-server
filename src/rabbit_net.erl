%%   The contents of this file are subject to the Mozilla Public License
%%   Version 1.1 (the "License"); you may not use this file except in
%%   compliance with the License. You may obtain a copy of the License at
%%   http://www.mozilla.org/MPL/
%%
%%   Software distributed under the License is distributed on an "AS IS"
%%   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%%   License for the specific language governing rights and limitations
%%   under the License.
%%
%%   The Original Code is RabbitMQ.
%%
%%   The Initial Developers of the Original Code are LShift Ltd,
%%   Cohesive Financial Technologies LLC, and Rabbit Technologies Ltd.
%%
%%   Portions created before 22-Nov-2008 00:00:00 GMT by LShift Ltd,
%%   Cohesive Financial Technologies LLC, or Rabbit Technologies Ltd
%%   are Copyright (C) 2007-2008 LShift Ltd, Cohesive Financial
%%   Technologies LLC, and Rabbit Technologies Ltd.
%%
%%   Portions created by LShift Ltd are Copyright (C) 2007-2009 LShift
%%   Ltd. Portions created by Cohesive Financial Technologies LLC are
%%   Copyright (C) 2007-2009 Cohesive Financial Technologies
%%   LLC. Portions created by Rabbit Technologies Ltd are Copyright
%%   (C) 2007-2009 Rabbit Technologies Ltd.
%%
%%   All Rights Reserved.
%%
%%   Contributor(s): ______________________________________.
%%

-module(rabbit_net).
-export([
        async_recv/3,
        close/1,
        controlling_process/2,
        getstat/2,
        peername/1,
        port_command/2,
        send/2,
        sockname/1
    ]).

-include("rabbit.hrl").


async_recv(Sock, Length, Timeout) when is_record(Sock, rabbit_ssl_socket) ->
    Pid = self(),
    Ref = make_ref(),

    Fun = fun() ->
            case ssl:recv(Sock#rabbit_ssl_socket.ssl, Length, Timeout) of
                {ok, Data} ->
                    Pid ! {inet_async, Sock, Ref, {ok, Data}};
                {error, Reason} ->
                    Pid ! {inet_async, Sock, Ref, {error, Reason}}
            end
    end,

    spawn(Fun),
    {ok, Ref};

async_recv(Sock, Length, Timeout) when is_port(Sock) ->
    prim_inet:async_recv(Sock, Length, Timeout).

close(Sock) when is_record(Sock, rabbit_ssl_socket) ->
    ssl:close(Sock#rabbit_ssl_socket.ssl);

close(Sock) when is_port(Sock) ->
    gen_tcp:close(Sock).


controlling_process(Sock, Pid) when is_record(Sock, rabbit_ssl_socket) ->
    ssl:controlling_process(Sock#rabbit_ssl_socket.ssl, Pid);

controlling_process(Sock, Pid) when is_port(Sock) ->
    gen_tcp:controlling_process(Sock, Pid).


getstat(Sock, Stats) when is_record(Sock, rabbit_ssl_socket) ->
    inet:getstat(Sock#rabbit_ssl_socket.tcp, Stats);

getstat(Sock, Stats) when is_port(Sock) ->
    inet:getstat(Sock, Stats).


peername(Sock) when is_record(Sock, rabbit_ssl_socket) ->
    ssl:peername(Sock#rabbit_ssl_socket.ssl);

peername(Sock) when is_port(Sock) ->
    inet:peername(Sock).


port_command(Sock, Data) when is_record(Sock, rabbit_ssl_socket) ->
    ssl:send(Sock#rabbit_ssl_socket.ssl, Data);

port_command(Sock, Data) when is_port(Sock) ->
    erlang:port_command(Sock, Data).

send(Sock, Data) when is_record(Sock, rabbit_ssl_socket) ->
    ssl:send(Sock#rabbit_ssl_socket.ssl, Data);

send(Sock, Data) when is_port(Sock) ->
    gen_tcp:send(Sock, Data).


sockname(Sock) when is_record(Sock, rabbit_ssl_socket) ->
    ssl:sockname(Sock#rabbit_ssl_socket.ssl);

sockname(Sock) when is_port(Sock) ->
    inet:sockname(Sock).
