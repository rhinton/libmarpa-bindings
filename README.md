libmarpa-bindings
=================

[libffi](https://sourceware.org/libffi/)- and
[Kollos](https://github.com/jeffreykegler/kollos)-based
bindings to
[libmarpa](https://github.com/jeffreykegler/libmarpa)
-- an ANSI C library, which implements
[Marpa parsing algorithm](http://savage.net.au/Marpa.html)
("[parse anything that can be written in BNF](
http://blogs.perl.org/users/jeffrey_kegler/2012/03/user-experiences-with-marpa-some-observations.html)",
[really](http://metacpan.org/source/JDDPAUSE/MarpaX-Languages-SQL2003-AST-0.005/lib/MarpaX/Languages/SQL2003/AST.pm#L299)
).

Status
======

libmarpa
--------

  [Version 7.5.0 releases](https://github.com/rns/libmarpa-bindings/releases) (source code)
  built by `make dists` as described in
  [libmarpa's INSTALL file](https://github.com/jeffreykegler/libmarpa/blob/master/INSTALL).

Lua
---

  libmarpa C functions can be called (and error-checked) from Lua via luajit FFI Library.

  Sample [JSON Parser](https://github.com/rns/libmarpa-bindings/blob/master/lua/test/json.t.lua),
  mostly a port of [json.c](https://github.com/jeffreykegler/libmarpa/blob/master/test/json.c)
  with libmarpa bindings and with a basic handwritten lexer based on PCRE regexes.

  An interface (grammar, recognizer/lexer, valuator) is being written.

Python
------

  libmarpa C functions can be called (and error-checked) from Python via cffi.

  Sample [JSON Parser](https://github.com/rns/libmarpa-bindings/blob/master/python/json-libmarpa.py),
  also a port of [json.c](https://github.com/jeffreykegler/libmarpa/blob/master/test/json.c)
  with a handwritten lexer based on Python regexes.

Ruby
----

  libmarpa C functions can be called from Ruby via
  [FFI](https://github.com/ffi/ffi).  Error checking handled manually.

  Sample [JSON Parser](ruby/json-libmarpa.rb), is a port of the [Python
  version](python/json-libmarpa.py), which includes a handwritten lexer based
  on Python regexes.

  A fairly usable higher-level interface is available through the provided
  `Grammar` and `Parser` classes.  It includes the lexing function.  The DSL is
  based on [Parslet](https://github.com/kschiess/parslet), though there are
  significant differences in assumptions and architecture.  And of course,
  Parslet is built for PEGs, not Marpa's CFGs.  The result is certainly not as
  mature as the `Marpa::R2` Perl bindings or its SLIF DSL, but it's a good
  first step.

  Another sample [JSON parser](ruby/json-marpa.rb) exhibits the higher-level
  bindings.

  A [custom matcher](ruby/marpa/rig.rb) provides a nice approach for testing
  grammars.  (Example coming soon.)

C#
--

  Just started: only version checking via P/Invoke, MSVC 2010 Express


