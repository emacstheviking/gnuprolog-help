
:- include('../gnuprolog-fastcgi/json.pl').

makehelp :-
	json_decode('predicates.json', obj(JSON)),
	json_find(pages, JSON, [obj(Pages)|_]),
	iterate_pages(Pages),
	!.


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
	(
	 list(PredList)
	->
	 maplist(catalog_item, PredList, PredText)
	;
	 catalog_item(PredList, PredText)
	),
	iterate_results(Results).

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
	phrase(scan_until(32), Label, Line),
	format("~s~n", [Line]).


scan_until(Chr) -->
	[C],
	{\+ C=Chr},
	scan_until(Chr).

scan_until(Chr) --> [Chr].



%%================ gphelp.pl ===============================
%% Check for an environment variable that tells us if we are using a
%% local copy or going out into cyberspace.
help_base(Base) :-
	\+ environ('GPHELP_BASE_URL', Base),
	Base = 'http://www.gprolog.org/manual/gprolog.html'.


%% Check for an environment variable that tells us how to launch the
%% help viewer URL.
help_launcher(Cmd) :-
	\+ environ('GPHELP_CMD', Cmd),
	Cmd = 'open'.


%% Physically launch the URL help viewer.
help_launch(Url) :-
	help_base(Base),
	help_launcher(Launcher),
	format_to_atom(Cmd, "~a ~a~s", [Launcher, Base, Url]),
	system(Cmd).


%% The king-pin command line helper predicate. This checks to see if
%% the help database is loaded into memory in which case it will use
%% that to satisfy the request otherwise it will fallback.
help(Predicate) :-
	current_predicate(gphelp_link/2),
	gphelp_link(Predicate, Url),
	help_launch(Url).

help(Predicate) :-
	format("?? no predicate database... parse and load JSON for ~a~n",[Predicate]).



gphelp_link(open, "#open%2F4").
gphelp_link(atom_length, "#sec198").
