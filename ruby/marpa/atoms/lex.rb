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
    @re = re
  end

  # Match this terminal against the current input.
  def match(io)
    io.match(@re)
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
    @re.inspect
  end

end  # Marpa::Atoms::Lex
