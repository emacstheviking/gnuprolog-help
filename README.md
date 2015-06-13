# GNU Prolog Help System

This is a very simple lash up based upon the output from creating a
simple import rule from the amazing [import.io](http://import.io), a
very slick web scraping service that outputs in various formats.

SWI has a really good help system, but sometimes it is too helpful and
crowded and the content really doesn't look good at times. Despite
that, it does have a help system, and I wanted to do the same for GNU
Prolog, which I really love because it reminds be of the good old
frontier days (mid-80's onwards) when anything was possible through
hacking everything with a CPU inside it.

The end result of this project is a command line `help(foo).`
predicate that will open a web browser and locate the help text for
`foo` at the top of the page. That's the plan. It seems to work.


## The help source.

Is a JSON file extracted and saved by scraping the online GNU Prolog
documentation, sections 7, 8 and 9 to be precise.

Way back I started trying to parse the documentation sources but got
tired. Recently I wrote my own JSON decoder as DCG practice and then
somebody told me about import.io and the light bulb came on!


## The Code

Revolves around my own pure Prolog JSON decoder written from scratch
against the guidelines from (json.org)http://json.org.  Once I got
that to work the rest was relatively simple.

  - load the JSON, generated for GNU Prolog 1.4.4
  - extract the relevant JSON data
  - dynamically create database rules
  - query the new knowledge base to create the lookup
  - save the lookup as a simple key-value file


# Building It

Check out the project from GitHub and then do this little lot at the
command line:

    GNU Prolog 1.4.4 (64 bits)
    Compiled Apr 23 2013, 17:26:17 with /opt/local/bin/gcc-apple-4.2
    By Daniel Diaz
    Copyright (C) 1999-2013 Daniel Diaz

    | ?- [makehelp].

lots of output will ensue, once it is done, press RETURN to terminate
the query and quit the session. You will see a new file called
`help_links.pl`. This contains the necessary linkage between the
predicate and the web URL anchor tag.


# Running It

There are several options, the first is you can just include the file
"runhelp.pl" at the start of every session,

    GNU Prolog 1.4.4 (64 bits)
    Compiled Apr 23 2013, 17:26:17 with /opt/local/bin/gcc-apple-4.2
    By Daniel Diaz
    Copyright (C) 1999-2013 Daniel Diaz

    | ?- [runhelp].


or, if that gets too much to handle, and what I do a lot, is to use
"gplc" to build a new binary with the help/1 predicate already built
in:

    gplc runhelp.pl -o gprologh

When you want to use the predicate, for example to query the open/N
predicate, you would type this at the prompt:

    help(open).

## Emacs Prolog Mode

Emacs being the awesome superhuman piece of kit that it is, I find out that
it *already has a command sequence pre-programmed into the mode to launch
help for the predicate under point. Awesome. Normally it fails but if you
build a custom binary and use that as your main executable you will find the
keystroke to be:

    C-c ?

That is enough to prompot you, just hit RETURN and up it comes! Sweet. Thanks
to the author of the Prolog mode for putting that in there from day one, that
has saved me a job for sure.



## Environment Variables

Some environment variables can be set to modify the runtime operation
of the help system. *Please note that because of technical reasons
surrounding the use of #fragments in a URL this didn't work out how I
planned!* It's probably best to just leave them blank and accept the
need for a web connection to the live site.

 - I tried using `php -S localhost:10000`,
 - I tried `python -m SimpleHTTPServer 10000`
 - I tried `ruby -run -e httpd . -p 10000`

but all to no avail. The answer is obvious just not to me right
now. If anybody can get this to work from a local server and still
have the browser locate to the anchor tag then please tell me how you
did it!

### Settings for Linux

I have found that the default is not good enough and that, for most
distros you should probably do this:

    export GPHELP_CMD="xdg-open ~s"

If like me you use emacs for everything then help won't work unless you
also set that variable for emacs, the simplest way seems to be to put
this into your ~/.emacs configuration:

    (setenv "GPHELP_CMD" "xdg-open ~s")

This will ensure that the command still works when running from inside
the prolog shell.


### GPHELP_BASE_URL

The internals will then first check for an environment variable called
GPHELP_BASE_URL which if present, will be used as the base URL for the
help link. This means that if you, like me, have a local copy of the
GNU Prolog sources installed, you can use that instead of relying on
being online. If the environment cvariable is not set or is set but
empty then it will go out to the internet instead.


### GPHELP_CMD

If set, this command will be used to launch the help text. By default
a system command "open" is used which on OSX and *nix should trigger a
suitable browser to be opened. I can't vouch for what Windows will do
because I don't use it or have it.

Thus, this variable can be used to change the launch command, for
example:

    GPHELP_CMD="firefox ~s"

Will cause the help URL to be placed where the `~s` is located which
should hopefully do the trick.


# Feedback

Always welcome! If you have any suggestions for additions,
improvements, bug reports then please get in touch.

Hope you find it useful.
