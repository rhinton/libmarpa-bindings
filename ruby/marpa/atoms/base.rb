# Base class for all parsing atoms, handles orchestration of calls and
# implements a lot of the operator and chaining methods.
#
# Also see Marpa::Atoms::DSL chaining marpa atoms together.
#
class Marpa::Atoms::Base
  include Marpa::Atoms::DSL
#copy:  include Marpa::Atoms::Precedence
#copy:  include Marpa::Atoms::CanFlatten

  # Marpa label as provided in grammar
  attr_accessor :label

  # Cached parser to parse this rule as the root.
  attr_reader :parser

  # Production priority, only used by {Alternative}.  Default is 0.
  attr_writer :priority
  def priority
    @priority ||= 0
  end

  # Given a string or an IO object, this will attempt a parse of its contents
  # and return a result. If the parse fails, a {Marpa::ParseFailed} exception
  # will be thrown. 
  #
  # @param io [String, Source] input for the parse process
#copy:  # @option options [Marpa::ErrorReporter] :reporter error reporter to use, 
#copy:  #   defaults to Marpa::ErrorReporter::Tree 
#copy:  # @option options [Boolean] :prefix Should a prefix match be accepted? 
#copy:  #   (default: false)
#copy:  # @return [Hash, Array, Marpa::Slice] PORO (Plain old Ruby object) result
#copy:  #   tree
  #
  def parse(io, options={})
    @parser = Marpa::Parser.new(self) unless defined? @parser
    @parser.parse(io, options)
  end

#copy:    source = io.respond_to?(:line_and_column) ? 
#copy:      io : 
#copy:      Marpa::Source.new(io)
#copy:
#copy:    # Try to cheat. Assuming that we'll be able to parse the input, don't 
#copy:    # run error reporting code. 
#copy:    success, value = setup_and_apply(source, nil, !options[:prefix])
#copy:    
#copy:    # If we didn't succeed the parse, raise an exception for the user. 
#copy:    # Stack trace will be off, but the error tree should explain the reason
#copy:    # it failed.
#copy:    unless success
#copy:      # Cheating has not paid off. Now pay the cost: Rerun the parse,
#copy:      # gathering error information in the process.
#copy:      reporter = options[:reporter] || Marpa::ErrorReporter::Tree.new
#copy:      source.bytepos = 0
#copy:      success, value = setup_and_apply(source, reporter, !options[:prefix])
#copy:      
#copy:      fail "Assertion failed: success was true when parsing with reporter" \
#copy:        if success
#copy:      
#copy:      # Value is a Marpa::Cause, which can be turned into an exception:
#copy:      value.raise
#copy:      
#copy:      fail "NEVER REACHED"
#copy:    end
#copy:    
#copy:    # assert: success is true
#copy:
#copy:    # Extra input is now handled inline with the rest of the parsing. If 
#copy:    # really we have success == true, prefix: false and still some input 
#copy:    # is left dangling, that is a BUG.
#copy:    if !options[:prefix] && source.chars_left > 0
#copy:      fail "BUG: New error strategy should not reach this point."
#copy:    end
#copy:    
#copy:    return flatten(value)
#copy:  end
#copy:  
#copy:  # Creates a context for parsing and applies the current atom to the input. 
#copy:  # Returns the parse result. 
#copy:  #
#copy:  # @return [<Boolean, Object>] Result of the parse. If the first member is 
#copy:  #   true, the parse has succeeded. 
#copy:  def setup_and_apply(source, error_reporter, consume_all)
#copy:    context = Marpa::Atoms::Context.new(error_reporter)
#copy:    apply(source, context, consume_all)
#copy:  end
#copy:
#copy:  # Calls the #try method of this marpa. Success consumes input, error will 
#copy:  # rewind the input. 
#copy:  #
#copy:  # @param source [Marpa::Source] source to read input from
#copy:  # @param context [Marpa::Atoms::Context] context to use for the parsing
#copy:  # @param consume_all [Boolean] true if the current parse must consume
#copy:  #   all input by itself.
#copy:  def apply(source, context, consume_all=false)
#copy:    old_pos = source.bytepos
#copy:    
#copy:    success, value = result = context.try_with_cache(self, source, consume_all)
#copy:
#copy:    if success
#copy:      # Notify context
#copy:      context.succ(source)
#copy:      # If a consume_all parse was made and doesn't result in the consumption
#copy:      # of all the input, that is considered an error. 
#copy:      if consume_all && source.chars_left>0
#copy:        # Read 10 characters ahead. Why ten? I don't know. 
#copy:        offending_pos   = source.pos
#copy:        offending_input = source.consume(10)
#copy:        
#copy:        # Rewind input (as happens always in error case)
#copy:        source.bytepos  = old_pos
#copy:        
#copy:        return context.err_at(
#copy:          self, 
#copy:          source, 
#copy:          "Don't know what to do with #{offending_input.to_s.inspect}", 
#copy:          offending_pos
#copy:        ) 
#copy:      end
#copy:      
#copy:      # Looks like the parse was successful after all. Don't rewind the input.
#copy:      return result
#copy:    end
#copy:    
#copy:    # We only reach this point if the parse has failed. Rewind the input.
#copy:    source.bytepos = old_pos
#copy:    return result
#copy:  end
#copy:  
#copy:  # Override this in your Atoms::Base subclasses to implement parsing
#copy:  # behaviour. 
#copy:  #
#copy:  def try(source, context, consume_all)
#copy:    raise NotImplementedError, \
#copy:      "Atoms::Base doesn't have behaviour, please implement #try(source, context)."
#copy:  end
#copy:
#copy:  # Returns true if this atom can be cached in the packrat cache. Most marpa
#copy:  # atoms are cached, so this always returns true, unless overridden.
#copy:  #
#copy:  def cached?
#copy:    true
#copy:  end
#copy:
#copy:  # Debug printing - in Treetop syntax. 
#copy:  #
#copy:  def self.precedence(prec)
#copy:    define_method(:precedence) { prec }
#copy:  end
#copy:  precedence BASE
#copy:  def to_s(outer_prec=OUTER)
#copy:    str = @label || to_s_inner(precedence)
#copy:    if outer_prec < precedence
#copy:      "(#{str})"
#copy:    else
#copy:      str
#copy:    end
#copy:  end
#copy:  def inspect
#copy:    to_s(OUTER)
#copy:  end

  def to_s
    @label || to_s_inner
  end
  def inspect
    to_s
  end
  def name
    to_s #"sym#{self.object_id}"
  end

#copy:private
#copy:
#copy:  # Produces an instance of Success and returns it. 
#copy:  #
#copy:  def succ(result)
#copy:    [true, result]
#copy:  end
end
