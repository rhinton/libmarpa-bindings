# Matches a symbol repeatedly. 
#
# Example: 
#
#   str('a').repeat(1,3)  # matches 'a' at least once, but at most three times
#   str('a').maybe        # matches 'a' if it is present in the input (repeat(0,1))
#
class Marpa::Atoms::Repetition < Marpa::Atoms::Base  
  attr_reader :min, :symbol, :sep, :proper

  #old:def initialize(symbol, min, max=nil)
  def initialize(symbol, min=0, sep=nil, proper=true)
    super()

    #old:raise ArgumentError, 
    #old:  "Asking for zero repetitions of a symbol. (#{symbol.inspect} repeating #{min},#{max})" \
    #old:  if max == 0
    #old:raise ArgumentError, "Finite maximum not implemented yet." unless max.nil?

    @symbol = symbol
    # @min, @max = min, max
    @min = min
    @sep = sep
    @proper = proper
  end

  # Build the sub-grammar for this rule: use the optimized sequence production.
  def build(parser)
    if (id = parser.sym_id(self))
      return id
    end
    sym = parser.create_symbol(self)
    rsym = symbol.build(parser)
    if sep
      ssym = sep.build(parser)
      parser.create_repetition_rule(sym, rsym, min, ssym, proper)
    else
      parser.create_repetition_rule(sym, rsym, min)
    end
  end

  def to_s_inner
    #old:minmax = "{#{min}, #{max}}"
    #old:minmax = '?' if min == 0 && max == 1
    minmax = "{#{min},}"

    symbol.to_s + minmax
  end
end

