-module(harmonious_ffi).

-export([open/1, read/1, is_eof/1]).

open(Path) ->
    file:open(Path, [read, raw, binary]).

read(Device) ->
    case file:read(Device, 24) of 
        {ok, Data} -> {ok, Data};
        {error, Reason} -> {error, Reason};
        eof -> {error, eof}
    end.

is_eof(Reason) ->
    Reason == eof.
