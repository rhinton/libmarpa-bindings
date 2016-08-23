# A sequence of symbols, matched from left to right. Denoted by '>>'.  The
# class name is a holdover from the Parslet DSL.  Instead, a Marpa sequence
# corresponds to a Parslet repetition.  
#
# Example: 
#
#   str('a') >> str('b')  # matches 'a', then 'b'
#
class Marpa::Atoms::Sequence < Marpa::Atoms::Base
  attr_reader :symbols

  def initialize(*symbols)
    super()
    @symbols = symbols
  end
  
  def >>(marpa)
    self.class.new(* @symbols+[marpa])
  end

  # Build the sub-grammar for this rule: a single rule with the sequence
  # symbols (in order) on the right-hand side.
  def build(parser)
    if (id = parser.sym_id(self))
      return id
    end
    sym = parser.create_symbol(self)
    seq_syms = @symbols.map {|a| a.build(parser)}
    parser.create_rule(sym, seq_syms)
    return sym
  end
  
  def to_s_inner
    symbols.map {|a| a.to_s }.join(' ')
  end
end
