%%====================================================================
%%
%%     GNU Prolog console level help facility.
%%
%%     @author Sean James Charles <sean at objitsu dot com>
%%
%% This is s *very simple* facility to allow the following predicate
%% to provide a link to the relevant predicate:
%%
%%    help(predicate_without_arity_specifier).
%%
%% for example:
%%
%%    help(open).
%%    help(socket_accept).
%%
%% It currently ONLY covers predicates in section 8 and for various
%% reasons it may break i.e. my parsing is a little sketchy and some
%% predicates were missed. If you find a hole, let me know and I will
%% try to fix it.
%%
%%====================================================================

%% The king-pin command line helper predicate. This checks to see if
%% the help database is loaded into memory in which case it will use
%% that to satisfy the request otherwise it will fallback.

help(Predicate) :-
	current_predicate(gphelp_link/2),
	gphelp_link(Predicate, Url),
	help_launch(Url),
	!.

help(Predicate) :-
	format("No help for ~a, is help loaded?~n", [Predicate]).


%% Check for an environment variable that tells us if we are using a
%% local copy or going out into cyberspace.

help_base(Base) :-
	environ('GPHELP_BASE_URL', Base).

help_base('http://www.gprolog.org/manual/gprolog.html').


%% Check for an environment variable that tells us how to launch the
%% help viewer URL. NOTE: If you change GPHELP_BASE_URL to be a file:///
%% URL then you MAY have to change this one to explicitly launch a browser
%% if your system cannot work out how ot launch a file:/// URL.

help_launcher(Cmd) :-
	environ('GPHELP_CMD', Cmd).

help_launcher('open ~s').


%% Physically launch the URL help viewer. Well, try to!

help_launch(Url) :-
	help_base(Base),
	help_launcher(Launcher),
	format_to_codes(Link, "%s~s", [Base, Url]),
	format_to_atom(Cmd, Launcher, [Link]),
	system(Cmd).


%% You MUST have run the makehelp.pl from another gprolog session to
%% have created the following file, the GitHub project contains
%% pre-generated data for GNU Prolog version 1.4.4 only.

:- include(help_links_789).


%% If you subsequently run this command:
%%
%%    gplc runhelp.pl -o gprologh
%%
%% and then use that instead of the standard gprolog you will always
%% have access to the command line help facility.
%%
%% Happy hacking.
