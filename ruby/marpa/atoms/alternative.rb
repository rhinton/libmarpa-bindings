
# Alternative during matching. Contains a list of symbols where each is tried.
# Since we are parsing a CFG, there is no precedence to the alternatives.  Only
# fails if all alternatives fail.
#
# Example: 
# 
#   str('a') | str('b')   # matches either 'a' or 'b'
#
class Marpa::Atoms::Alternative < Marpa::Atoms::Base
  attr_reader :alternatives
  
  # Constructs an Alternative instance using all given symbols in the order
  # given. This is what happens if you call '|' on existing symbols, like this:
  #
  #   lex(/a/) | lex(/b/)
  #
  def initialize(*alternatives)
    super()
    @alternatives = alternatives
  end

  # Build the sub-grammar for this rule: multiple productions for the same LHS
  # symbol.
  def build(parser)
    if (id = parser.sym_id(self))
      return id
    end
    sym = parser.create_symbol(self)
    @alternatives.each do |alt_atom|
      alt_sym = alt_atom.build(parser)
      parser.create_rule(sym, alt_sym)
    end
    return sym
  end

  # Don't construct a hanging tree of {Alternative} marpas, instead store them
  # all in one {Alternative} object. This reduces the number of symbols created
  # (though it creates a bunch of extra objects while building the DSL).
  def |(rule)
    self.class.new(*@alternatives + [rule])
  end
  
  def to_s_inner
    alternatives.map { |a| a.to_s }.join(' / ')
  end
end
