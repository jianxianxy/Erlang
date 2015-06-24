-module(lib_trigrams).
-export([for_trigram/2]).

for_trigram(F,A0) ->
    {ok,Bin0} = file:read_file("123.ng1.gz"),
    Bin = zlib:gunzip(Bin0),
    scan_word_list(binary_to_list(Bin),F,A0).

scan_word_list([],_,A) -> 
    A;
scan_word_list(L,F,A) ->
    {Word,L1} = get_nest_word(L,[]),
    A1 = scan_trigrams([$\s|Word],F,A),
    scan_word_list(L1,F,A).

get_next_word([$\r,$\n|T],L) -> {reverse([$\s|L]),T};
get_next_word([H|T],L) -> get_next_word(T,[H|L]);
get_next_word([],L) -> {reverse([$\s|L]),[]}.

scan_trigrams([X,Y,Z],F,A) ->
    F([X,Y,Z],A);
scan_trigrams([X,Y,Z|T],F,A) ->
    A1 = F([X,Y,Z],A),
    scan_trigrams([Y,Z|T],F,A1);
scan_trigrams(_,_,A) ->
    A.

make_ets_ordered_set() -> make_a_set(ordered_set,"trigramsOS.tab").
make_ets_set() -> make_a_set(set,"trigramsS.tab").

make_a_set(Type,FileName) ->
    Tab = ets:new(table,[Type]),
    F = fun(Str,_) -> ets:insert(Tab,{list_to_binary(Str)}) end,
    for_trigram(F,0),
    ets:tab2file(Tab,FileName),
    Size = ets:info(Tab,Size),
    ets:delete(Tab),
    Size.

make_mod_set() ->
    D = sets:new(),
    F = fun(Str,Set) -> sets:add_element(list_to_binary(Str),Set) end,
    D1 = for_trigram(F,D),
    file:write_file("trigrams.set",[term_to_binary(D1)]).
