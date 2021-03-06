%%
%% Copyright (c) 2018 Dmitry Poroh
%% All rights reserved.
%% Distributed under the terms of the MIT License. See the LICENSE file.
%%
%% SIP method
%%

-module(ersip_method).

-export([options/0,
         invite/0,
         ack/0,
         bye/0,
         cancel/0,
         subscribe/0,
         notify/0,
         refer/0,
         register/0,
         parse/1,
         make/1,
         to_binary/1
        ]).
-export_type([method/0]).

%%%===================================================================
%%% Types
%%%===================================================================

-type method() :: {method, binary()}.

%%%===================================================================
%%% API
%%%===================================================================

-define(OPTIONS,  {method, <<"OPTIONS">>}).
-define(INVITE,   {method, <<"INVITE">>}).
-define(ACK,      {method, <<"ACK">>}).
-define(BYE,      {method, <<"BYE">>}).
-define(CANCEL,   {method, <<"CANCEL">>}).
-define(REGISTER, {method, <<"REGISTER">>}).

-define(SUBSCRIBE, {method, <<"SUBSCRIBE">>}).
-define(NOTIFY,    {method, <<"NOTIFY">>}).
-define(REFER,     {method, <<"REFER">>}).

options() ->
    ?OPTIONS.

invite() ->
    ?INVITE.

ack() ->
    ?ACK.

bye() ->
    ?BYE.

cancel() ->
    ?CANCEL.

register() ->
    ?REGISTER.

subscribe() ->
    ?SUBSCRIBE.

notify() ->
    ?NOTIFY.

refer() ->
    ?REFER.

-spec parse(binary()) ->  {ok, method()}
                              | {error, Error} when
      Error :: {invalid_method, binary()}.
parse(Bin) ->
    case ersip_parser_aux:check_token(Bin) of
        true ->
            {ok, {method, Bin}};
        false ->
            {error, {invalid_method, Bin}}
    end.

-spec to_binary(method()) -> binary().
to_binary({method, Bin}) ->
    Bin.

-spec make(binary()) -> method().
make(Bin) when is_binary(Bin) ->
    case parse(Bin) of
        {ok, M} ->
            M;
        {error, _} = Error ->
            error(Error)
    end.
