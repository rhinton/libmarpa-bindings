# This a piece of grammar definition and gives it a name. You don't normally
# use this directly, instead you should generate it by using the structuring
# method Marpa.rule.
#
class Marpa::Atoms::Entity < Marpa::Atoms::Base
  attr_reader :name, :block
  def initialize(name, label=nil, &block)
    super()
    
    @name = name
    @label = label
    @block = block
  end

#copy:  def try(source, context, consume_all)
#copy:    rule.apply(source, context, consume_all)
#copy:  end
  
  def rule
    return @rule unless @rule.nil?
    @rule = @block.call
    raise_not_implemented if @rule.nil?
    @rule.label = @label
    @rule
  end

  # Build the sub-grammar for this rule: just a named wrapper for whatever is
  # in the rule.
  def build(parser)
    if (id = parser.sym_id(self))
      return id
    end
    sym = parser.create_symbol(self)
    rsym = rule.build(parser)
    parser.create_rule(sym, rsym)
    return sym
  end

  def to_s_inner
    name.to_s.upcase
  end  

private 
  def raise_not_implemented
    trace = caller.reject {|l| l =~ %r{#{Regexp.escape(__FILE__)}}} # blatantly stolen from dependencies.rb in activesupport
    exception = NotImplementedError.new("rule(#{name.inspect}) { ... }  returns nil. Still not implemented, but already used?")
    exception.set_backtrace(trace)
    
    raise exception
  end
end
