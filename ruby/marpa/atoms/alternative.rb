
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
    finish_priorities
    sym = parser.create_symbol(self)
    alt_pairs = alternatives.map {|aa| [aa, asym = aa.build(parser)]}
    alt_pairs.each do |alt_atom, alt_sym|
      parser.create_rule(sym, alt_sym, alt_atom.priority)
    end
    # two-stage construction groups the alternative rules together; doesn't
    # affect machine operation, but easier for people to debug
    return sym
  end

  # Finish calculating the alternative priorities.  The DSL marks
  # lower-priority alternatives with a priority of -1.  This method accumulates
  # and shifts these values to a non-negative, monotone decreasing sequence of
  # priorities.
  def finish_priorities
    #old:hi_pri = - alternatives.inject(0) {|s,alt| s + alt.priority}
    #old:alternatives.inject(hi_pri) {|s,alt| alt.priority += s}
    #old:# this last inject has significant, intended side-effects
    hi_pri = -alternatives.map(&:priority).min
    alternatives.each {|alt| alt.priority += hi_pri}

    # sanity check
    pri = nil
    alternatives.each do |alt|
      if pri
        raise ArgumentError, "Unexpected priority sequence." \
          unless (pri == alt.priority) || (pri-1 == alt.priority)
      end
      pri = alt.priority
    end
  end

  # Don't construct a hanging tree of {Alternative} atoms, instead store them
  # all in one {Alternative} object. This reduces the number of symbols in the
  # grammar (though it creates a bunch of extra objects while building the
  # DSL).
  def |(rule)
    # may have higher-priority alternatives buried in rule
    new_rules = rule.alternatives rescue [rule]
    pri = alternatives.last.priority
    new_rules.each {|alt| alt.priority += pri}
    new_rule = self.class.new(*@alternatives + new_rules)
    new_rule
  end

  # Similar to the previous, override prioritized alternative DSL operator to
  # collect the options in a single object instead of a dangling tree.
  def /(rule)
    rule.priority = alternatives.last.priority - 1
    new_rule = self.class.new(*@alternatives + [rule])
    new_rule
  end
  
  def to_s_inner
    pri = nil
    alternatives.map do |alt| 
      #tmp:str = alt.to_s
      str = "#{alt} p#{alt.priority}"
      if pri.nil?
        str  # first item, no separator
      elsif pri == alt.priority
        str = ' | ' + str
      elsif pri > alt.priority
        str = ' / ' + str
      else
        raise RuntimeError, 'Unexpected priority increase'
      end
      pri = alt.priority
      str
    end.join('')  # alternatives.map
  end  # to_s_inner method

end  # class Marpa::Atoms::Alternative
