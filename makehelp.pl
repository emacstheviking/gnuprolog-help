%%====================================================================
%%
%%     GNU Prolog console level help facility.
%%
%%     @author Sean James Charles <sean at objitsu dot com>
%%
%% This builds a database of links from GNU Prolog predicates to web
%% anchor tags to effect a very simple (and probably flaky) command
%% line help facility.
%%
%% It "works". YMMV.
%%
%% All you need to do is start a session, then consult the makehelp.pl
%% file and then execute the makehelp/0 predicate. Once it is done a
%% file called "help_links.pl" should have been created. Then you can
%% either consult the file "runhelp.pl" at session start or, as I do,
%% build a binary with it precompiled. See runhelp.pl for details.
%%
%%     $ gprolog runhelp.pl -o gprologh
%%
%% That's it. it seems to work. If you find a predicate that doesn't
%% work let me know and I will dig some more at it.
%%
%%====================================================================

:- include('../gnuprolog-json/json.pl').

%% The above file is available at:
%%         https://github.com/emacstheviking/gnuprolog-json
%%
%% You will have to check that out first and make it a sibling of this
%% folder. That's how I manage my dependencies these days for my
%% common code.

makehelp :-
	json_decode('predicates.json', obj(JSON)),
	json_find(pages, JSON, [obj(Pages)|_]),
	open('help_links.pl', write, F, [alias(helplinks)]),
	iterate_pages(Pages),
	close(F).


iterate_pages([]).

iterate_pages(Pages) :-
	json_find(results, Pages, Results),
	iterate_results(Results).


iterate_results([]).

iterate_results([obj(R)|Results]) :-
	json_find('predicate/_source', R, PredList),
	json_find('predicate/_text', R, PredText),
	%% We could have str() values for a single entry or we could have []
	%% values for sections with multiple predicate entries. Lists are
	%% mapped through the single entry processor.
	( list(PredList)
	->
	  maplist(catalog_item, PredList, PredText)
	;
	  catalog_item(PredList, PredText)
	),
	iterate_results(Results).


%%--------------------------------------------------------------------
%% Catalog a single item into the database. Once we have cataloged all
%% of the predicates from the source JSON we can then do something
%% useful with it.
%%
%% http://www.gprolog.org/manual/gprolog.html
%%
%%  - skip section number, basically consume until space.
%%  - split Label by comma, each term MAY be a predicate
%%  -  for each candidate predicate:
%%       - is it of the form atom '/' number ?
%%          => N, skip it
%%          => Y, create a database rule. gphelp(P,U)
%%                where P = predicate name
%%                      U = URL anchor tag
%%
catalog_item(str(Url), str(Label)) :-
	phrase(next_token(_SectionNumber), Label, Line),
	process_item(Line, Url).


%% Process all tokens on a line, if it looks like a predicate/arity
%% shape then take a chance of assert that it is a help link at this
%% point.

process_item([], _) :- !.

process_item(Line, Url) :-
	phrase(next_token(T), Line, Line2),
	format("TOKEN: ~s~n", [T]),
	( phrase(predicate_form(P), T, _)
	->
	  format("PREDICATE: ~s ~w~n", [P, P]),
	  write_rule(P, Url),
	  process_item(Line2, Url)
	;
	  process_item(Line2, Url)
	).


%% Edge-case #1: This one breaks us!
%% .â€™ [46,195,162,226,130,172,226,132,162]
write_rule([46,195,162,226,130,172,226,132,162], _).

write_rule(P, Url) :-
	format(helplinks, "gphelp_link('~s', \"~s\").~n", [P, Url]).


%% DCG rules to check a predicate/arity form
predicate_form(P) --> next_token(P), "/", digits.
digits --> digit, digits ; digit.
digit --> [C], { "0" =< C, C =< "9" }.


%% DCG rules for token extraction from a help entry line
scan_until(Chr) --> [C], {\+ C=Chr}, scan_until(Chr).
scan_until(Chr) --> [Chr].

next_token(T) --> skipws, next_token([], T).
next_token(Acc, Out) --> " ", {reverse(Acc, Out)}.
next_token(Acc, Out) --> [C], next_token([C|Acc], Out).
next_token(Acc, Out) --> [], {reverse(Acc, Out)}.

skipws --> (skipws1, skipws, !) ; (skipws1, !) ; [].
skipws1 --> [C], { C=<32 ; C>=127}.
