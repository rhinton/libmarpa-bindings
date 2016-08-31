# Matches a regular expression, implementing lexing functionality.  This is
# distinct from the {Parslet::Atoms::Re} class in that this implementation
# allows regular expressions of any length or complexity.
#
# Example: 
# 
#   lex(/foo/i) # matches 'foo', 'Foo', 'fOo', etc.
#
class Marpa::Atoms::Lex < Marpa::Atoms::Base
  def initialize(re)
    @re_orig = re  # used for inspect, easier to read
    @re = Regexp.new('\G' + re.to_s)
    # Modify Regexp to force match to begin at the current location -- not any
    # old spot in the string.  Note that ^ is the beginning of line (fails on
    # anything besides begin of string of after NL/CR) and \A is the beginning
    # of string (fails for pos > 0).  \G is "where the last match finished",
    # which works as intended with pos > 0.
  end

  # Match this terminal against the current input.
  def match(str, pos=0)
    @re.match(str, pos)
  end

  # Build the sub-grammar for this rule: a terminal, so just a symbol with no
  # productions.
  def build(parser)
    if (id = parser.sym_id(self))
      return id
    end
    sym = parser.create_symbol(self)
  end

  def to_s_inner
    @re_orig.inspect
  end
  def source
    @re_orig
  end

end  # Marpa::Atoms::Lex
