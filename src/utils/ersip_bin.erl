%%
%% Copyright (c) 2017 Dmitry Poroh
%% All rights reserved.
%% Distributed under the terms of the MIT License. See the LICENSE file.
%%
%% Binary routines helpers
%%

-module(ersip_bin).
-include("ersip_sip_abnf.hrl").

-export([to_lower/1,
         to_lower_utf8/1,
         to_upper/1,
         trim_lws/1,
         trim_head_lws/1,
         trim_tail_lws/1,
         unquote_rfc_2396/1
        ]).

%%%===================================================================
%%% API
%%%===================================================================

-spec to_lower( binary() ) -> binary().
to_lower_utf8(Binary) when is_binary(Binary) ->
    << <<(unicode_to_lower(C))/utf8>> || <<C/utf8>> <= Binary >>;
to_lower_utf8(Binary) -> erlang:error(badarg, [Binary]).

to_lower(Binary) when is_binary(Binary) ->
    << <<(if
              C >= $A andalso C =< $Z -> C - $A + $a;
              true -> C
          end)>> || <<C>> <= Binary >>;
to_lower(V) -> erlang:error(badarg, [V]).

-spec to_upper( binary() ) -> binary().
to_upper(Binary) when is_binary(Binary) ->
    << <<(unicode_to_upper(C))/utf8>> || <<C/utf8>> <= Binary >>;
to_upper(Binary) -> erlang:error(badarg, [Binary]).

-spec trim_lws( binary() ) -> binary().
trim_lws(Bin0) ->
    Bin1 = trim_head_lws(Bin0),
    Bin2 = trim_tail_lws(Bin1),
    Bin2.

-spec trim_head_lws( binary() ) -> binary().
trim_head_lws(<<>>) ->
    <<>>;
trim_head_lws(<<$ , Rest/binary>>) ->
    trim_head_lws(Rest);
trim_head_lws(<<$\t, Rest/binary>>) ->
    trim_head_lws(Rest);
trim_head_lws(Binary) when is_binary(Binary) ->
    Binary.

-spec trim_tail_lws( binary() ) -> binary().
trim_tail_lws(<<>>) ->
    <<>>;
trim_tail_lws(Bin) ->
    Len = byte_size(Bin),
    LastChar = binary:at(Bin, Len-1),
    case LastChar of
        Char when ?is_LWS_char(Char)->
            trim_tail_lws(binary:part(Bin, {0, Len-1}));
        _ ->
            Bin
    end.

%% @doc unqoute % HEX HEX format from RFC 2396
-spec unquote_rfc_2396(binary()) -> binary().
unquote_rfc_2396(String) when is_binary(String) ->
    unquote_rfc_2396_iter(String, []).

%%%===================================================================
%%% internal implementation
%%%===================================================================

-spec unicode_to_lower( byte() ) -> byte().
unicode_to_lower(C) ->
    hd(string:to_lower([C])).

-spec unicode_to_upper( byte() ) -> byte().
unicode_to_upper(C) ->
    hd(string:to_upper([C])).

unquote_rfc_2396_iter(<<>>, Acc) ->
    list_to_binary(lists:reverse(Acc));
unquote_rfc_2396_iter(<<$%, Hex1/utf8, Hex2/utf8, Rest/binary>>, Acc)
  when ((Hex1 >= $0 andalso Hex1 =< $9)
        orelse (Hex1 >= $A andalso Hex1 =< $F)
        orelse (Hex1 >= $a andalso Hex1 =< $f))
       andalso
       ((Hex2 >= $0 andalso Hex2 =< $9)
        orelse (Hex2 >= $A andalso Hex2 =< $F)
        orelse (Hex2 >= $a andalso Hex2 =< $f)) ->
    unquote_rfc_2396_iter(Rest, [update_hex(update_hex(0, Hex1), Hex2) | Acc]);
unquote_rfc_2396_iter(<<C/utf8, Rest/binary>>, Acc) ->
    unquote_rfc_2396_iter(Rest, [C | Acc]).

%% @private
%% @doc Helper for makeing HEX HEX to the character value
-spec update_hex(char(), char()) -> char().

update_hex(Val, Char) when Char >= $0 andalso Char =< $9 ->
    Val * 16 + Char - $0;
update_hex(Val, Char) when Char >= $A andalso Char =< $F ->
    Val * 16 + Char - $A + 10;
update_hex(Val, Char) when Char >= $a andalso Char =< $f ->
    Val * 16 + Char - $a + 10.
