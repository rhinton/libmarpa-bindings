# Matches a symbol absent or present (exactly once).
#
# Example: 
#
#   lex(/a/).maybe        # matches 'a' present or absent (repeat(0,1))
#
class Marpa::Atoms::Maybe < Marpa::Atoms::Base  
  attr_reader :symbol

  def initialize(symbol)
    super()
    @symbol = symbol
  end

  # Build the sub-grammar for this rule: two productions (alternative), one
  # with the given symbol, and one a null production.
  def build(parser)
    if (id = parser.sym_id(self))
      return id
    end
    sym = parser.create_symbol(self)
    ssym = symbol.build(parser)
    parser.create_rule(sym, [])
    parser.create_rule(sym, ssym)
    return sym
  end

#copy:  def try(source, context, consume_all)
#copy:    occ = 0
#copy:    accum = [@tag]   # initialize the result array with the tag (for flattening)
#copy:    start_pos = source.pos
#copy:    
#copy:    break_on = nil
#copy:    loop do
#copy:      success, value = symbol.apply(source, context, false)
#copy:
#copy:      break_on = value
#copy:      break unless success
#copy:
#copy:      occ += 1
#copy:      accum << value
#copy:      
#copy:      # If we're not greedy (max is defined), check if that has been reached. 
#copy:      return succ(accum) if max && occ>=max
#copy:    end
#copy:    
#copy:    # Last attempt to match symbol was a failure, failure reason in break_on.
#copy:    
#copy:    # Greedy matcher has produced a failure. Check if occ (which will
#copy:    # contain the number of successes) is >= min.
#copy:    return context.err_at(
#copy:      self, 
#copy:      source, 
#copy:      @error_msgs[:minrep], 
#copy:      start_pos, 
#copy:      [break_on]) if occ < min
#copy:      
#copy:    # consume_all is true, that means that we're inside the part of the parser
#copy:    # that should consume the input completely. Repetition failing here means
#copy:    # probably that we didn't. 
#copy:    #
#copy:    # We have a special clause to create an error here because otherwise
#copy:    # break_on would get thrown away. It turns out, that contains very
#copy:    # interesting information in a lot of cases. 
#copy:    #
#copy:    return context.err(
#copy:      self, 
#copy:      source, 
#copy:      @error_msgs[:unconsumed], 
#copy:      [break_on]) if consume_all && source.chars_left>0
#copy:      
#copy:    return succ(accum)
#copy:  end
#copy:  
#copy:  precedence REPETITION
  def to_s_inner
    symbol.to_s + '?'
  end
end

