-module(tst_utils).

-export([
    compare_maps/2,
    to_map/1,
    filter_null_values/1,
    compare_maps_extra_fields/2
]).

compare_maps(M1, M2) ->
    KL1 = maps:keys(M1),
    MR = lists:map(fun(Key) ->
        V1 = maps:get(Key, M1),
        V2 = filter_null_values(maps:get(Key, M2)),
        io:format("~p ~p ~p ~n", [Key, V1, V2]),
        V1 =:= V2
    end, KL1),
    lists:all(fun(true) -> true; (_) -> false end, MR).

to_map([{_,_}|_] = L) ->
    maps:from_list([{K, to_map(V)} || {K, V} <- L]);
to_map(V) -> V.

filter_null_values([{_,_}|_] = L) -> filter_null_values(maps:from_list(L));
filter_null_values(L) when is_list(L) -> [filter_null_values(E) || E <- L];
filter_null_values(#{} = V) ->
    M1 = maps:filter(fun(_, null) -> false; (_,_) -> true end, V),
    maps:map(fun(_, Val) -> filter_null_values(Val) end, M1);
filter_null_values(V) -> V.

%
% M1 - source map
% M2 - map after decoding
% M1 can contain fields not existing in schema
%
compare_maps_extra_fields(M1, M2) ->
    KL1 = maps:keys(M1),
    MR = lists:map(fun(Key) ->
        V1 = maps:get(Key, M1),
        V2 = filter_null_values(maps:get(Key, M2, notexists)),
        case V2 of
            notexists -> true;
            _ ->
                    io:format("~p ~p ~p ~n", [Key, V1, V2]),
                    case is_float(V2) of
                        true ->
                            round(V1) =:= round(V2)
                        ;_ -> V1 =:= V2
                    end
        end
    end, KL1),
    io:format("================================ ~n ~p ~n", [MR]),
    lists:all(fun(true) -> true; (_) -> false end, MR).
