# Interface the Marpa parser.
#
# https://jeffreykegler.github.io/Marpa-web-site/
#
# Ryan Hinton, Maple View Design, 17 Aug 2016.


module Marpa
  # Extends classes that include Marpa with the module
  # {Marpa::ClassMethods}.
  #
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  # Raised when the parse failed to match. It contains the message that should
  # be presented to the user. More details can be extracted from the
  # exceptions #cause member: It contains an instance of {Marpa::Cause} that
  # stores all the details of your failed parse in a tree structure. 
  #
  #   begin
  #     marpa.parse(str)
  #   rescue Marpa::ParseFailed => failure
  #     puts failure.cause.ascii_tree
  #   end
  #
  # Alternatively, you can just require 'marpa/convenience' and call the
  # method #parse_with_debug instead of #parse. This method will never raise
  # and print error trees to stdout.
  #
  #   require 'marpa/convenience'
  #   marpa.parse_with_debug(str)
  #
  class ParseFailed < StandardError
    def initialize(message, cause=nil)
      super(message)
      @cause = cause
    end
    
    # Why the parse failed. 
    #
    # @return [Marpa::Cause]
    attr_reader :cause 
  end
  
  module ClassMethods
    # Define an entity for the parser. This generates a method of the same
    # name that can be used as part of other patterns. Those methods can be
    # freely mixed in your parser class with real ruby methods.
    # 
    #   class MyParser
    #     include Marpa
    #
    #     rule(:bar) { str('bar') }
    #     rule(:twobar) do
    #       bar >> bar
    #     end
    #
    #     root :twobar
    #   end
    #
    def rule(name, opts={}, &definition)
      define_method(name) do
        @rules ||= {}     # <name, rule> memoization
        return @rules[name] if @rules.has_key?(name)
        
        # Capture the self of the parser class along with the definition.
        definition_closure = proc {
          self.instance_eval(&definition)
        }
        
        @rules[name] = Atoms::Entity.new(name, opts[:label], &definition_closure)
        # @rules[name] = definition.call
      end
    end  # rule method (pulled in as a class method)

    # Add a definition (currently must be a lexer rule) to the list of patterns
    # to discard.
    def discard(re)
      #old:raise ArgumentError, "Only lexer rules accepted for discard." \
      #old:  unless atom.kind_of? Marpa::Atoms::Lex
      raise ArgumentError, "Only regular expressions accepted for discard." \
        unless re.kind_of? Regexp

      @discards ||= []
      @discards.push(Atoms::Lex.new(re))
    end  # discard method (pulled in as a class method)

  end  # module ClassMethods

  # Return the list of rules for patterns to discard.
  def discards
    self.class.instance_eval { @discards || [] }
  end

#copy:  # Allows for delayed construction of #match. See also Marpa.match.
#copy:  #
#copy:  # @api private
#copy:  class DelayedMatchConstructor
#copy:    def [](str)
#copy:      Atoms::Re.new("[" + str + "]")
#copy:    end
#copy:  end
#copy:  
#copy:  # Returns an atom matching a character class. All regular expressions can be
#copy:  # used, as long as they match only a single character at a time. 
#copy:  #
#copy:  #   match('[ab]')     # will match either 'a' or 'b'
#copy:  #   match('[\n\s]')   # will match newlines and spaces
#copy:  #
#copy:  # There is also another (convenience) form of this method: 
#copy:  #
#copy:  #   match['a-z']      # synonymous to match('[a-z]')
#copy:  #   match['\n']       # synonymous to match('[\n]')
#copy:  #
#copy:  # @overload match(str)
#copy:  #   @param str [String] character class to match (regexp syntax)
#copy:  #   @return [Marpa::Atoms::Re] a marpa atom
#copy:  #
#copy:  def match(str=nil)
#copy:    return DelayedMatchConstructor.new unless str
#copy:    
#copy:    return Atoms::Re.new(str)
#copy:  end
#copy:  module_function :match

  # Returns an atom matching a regular expression:
  #
  #   lex('[1-9][0-9]*')   # will match 16473
  #
  # @param re [Regexp] regular expression to match
  # @return [Marpa::Atoms::Lex] a grammar object
  def lex(re)
    Atoms::Lex.new(re)
  end
  module_function :lex
  
  # Returns an atom matching the +str+ given:
  #
  #   str('class')      # will match 'class' 
  #
  # @param str [String] string to match verbatim
  # @return [Marpa::Atoms::Str] a marpa atom
  # 
  def str(str)
    Atoms::Lex.new(Regexp.new(Regexp.escape(str)))
  end
  module_function :str
  
  # Returns an atom matching the +str+ (case insensitive) given:
  #
  #   stri('class')      # will match 'Class' 
  #
  # @param str [String] string to match case-insensitively
  # @return [Marpa::Atoms::Str] a Marpa atom
  # 
  def stri(str)
    Atoms::Lex.new(Regexp.new(Regexp.escape(str), Regexp::IGNORECASE))
  end
  module_function :stri
  
#copy:  # Returns an atom matching any character. It acts like the '.' (dot)
#copy:  # character in regular expressions.
#copy:  #
#copy:  #   any.parse('a')    # => 'a'
#copy:  #
#copy:  # @return [Marpa::Atoms::Re] a marpa atom
#copy:  #
#copy:  def any
#copy:    Atoms::Re.new('.')
#copy:  end
#copy:  module_function :any
#copy:  
#copy:  # Introduces a new capture scope. This means that all old captures stay
#copy:  # accessible, but new values stored will only be available during the block
#copy:  # given and the old values will be restored after the block. 
#copy:  #
#copy:  # Example: 
#copy:  #   # :a will be available until the end of the block. Afterwards, 
#copy:  #   # :a from the outer scope will be available again, if such a thing 
#copy:  #   # exists. 
#copy:  #   scope { str('a').capture(:a) }
#copy:  #
#copy:  def scope(&block)
#copy:    Marpa::Atoms::Scope.new(block)
#copy:  end
#copy:  module_function :scope
#copy:  
#copy:  # Designates a piece of the parser as being dynamic. Dynamic parsers can
#copy:  # either return a parser at runtime, which will be applied on the input, or
#copy:  # return a result from a parse. 
#copy:  # 
#copy:  # Dynamic parse pieces are never cached and can introduce performance
#copy:  # abnormalitites - use sparingly where other constructs fail. 
#copy:  # 
#copy:  # Example: 
#copy:  #   # Parses either 'a' or 'b', depending on the weather
#copy:  #   dynamic { rand() < 0.5 ? str('a') : str('b') }
#copy:  #   
#copy:  def dynamic(&block)
#copy:    Marpa::Atoms::Dynamic.new(block)
#copy:  end
#copy:  module_function :dynamic
#copy:
#copy:  # Returns a marpa atom that parses infix expressions. Operations are 
#copy:  # specified as a list of <atom, precedence, associativity> tuples, where 
#copy:  # atom is simply the marpa atom that matches an operator, precedence is 
#copy:  # a number and associativity is either :left or :right. 
#copy:  # 
#copy:  # Higher precedence indicates that the operation should bind tighter than
#copy:  # other operations with lower precedence. In common algebra, '+' has 
#copy:  # lower precedence than '*'. So you would have a precedence of 1 for '+' and
#copy:  # a precedence of 2 for '*'. Only the order relation between these two 
#copy:  # counts, so any number would work. 
#copy:  #
#copy:  # Associativity is what decides what interpretation to take for strings that
#copy:  # are ambiguous like '1 + 2 + 3'. If '+' is specified as left associative, 
#copy:  # the expression would be interpreted as '(1 + 2) + 3'. If right 
#copy:  # associativity is chosen, it would be interpreted as '1 + (2 + 3)'. Note 
#copy:  # that the hash trees output reflect that choice as well. 
#copy:  #
#copy:  # An optional block can be provided in order to manipulate the generated tree.
#copy:  # The block will be called on each operator and passed 3 arguments: the left
#copy:  # operand, the operator, and the right operand.
#copy:  #
#copy:  # Examples:
#copy:  #   infix_expression(integer, [add_op, 1, :left])
#copy:  #   # would parse things like '1 + 2'
#copy:  #
#copy:  #   infix_expression(integer, [add_op, 1, :left]) { |l,o,r| { :plus => [l, r] } }
#copy:  #   # would parse '1 + 2 + 3' as:
#copy:  #   # { :plus => [1, { :plus => [2, 3] }] }
#copy:  #
#copy:  # @param element [Marpa::Atoms::Base] elements that take the NUMBER position
#copy:  #    in the expression
#copy:  # @param operations [Array<(Marpa::Atoms::Base, Integer, {:left, :right})>]
#copy:  #  
#copy:  # @see Marpa::Atoms::Infix
#copy:  #
#copy:  def infix_expression(element, *operations, &reducer)
#copy:    Marpa::Atoms::Infix.new(element, operations, &reducer)
#copy:  end
#copy:  module_function :infix_expression
#copy:  
#copy:  # A special kind of atom that allows embedding whole treetop expressions
#copy:  # into marpa construction. 
#copy:  #
#copy:  #   # the same as str('a') >> str('b').maybe
#copy:  #   exp(%Q("a" "b"?))     
#copy:  #
#copy:  # @param str [String] a treetop expression
#copy:  # @return [Marpa::Atoms::Base] the corresponding marpa parser
#copy:  #
#copy:  def exp(str)
#copy:    Marpa::Expression.new(str).to_marpa
#copy:  end
#copy:  module_function :exp
#copy:  
#copy:  # Returns a placeholder for a tree transformation that will only match a
#copy:  # sequence of elements. The +symbol+ you specify will be the key for the
#copy:  # matched sequence in the returned dictionary.
#copy:  #
#copy:  #   # This would match a body element that contains several declarations.
#copy:  #   { :body => sequence(:declarations) }
#copy:  #
#copy:  # The above example would match <code>:body => ['a', 'b']</code>, but not
#copy:  # <code>:body => 'a'</code>. 
#copy:  #
#copy:  # see {Marpa::Transform}
#copy:  #
#copy:  def sequence(symbol)
#copy:    Pattern::SequenceBind.new(symbol)
#copy:  end
#copy:  module_function :sequence
#copy:  
#copy:  # Returns a placeholder for a tree transformation that will only match
#copy:  # simple elements. This matches everything that <code>#sequence</code>
#copy:  # doesn't match.
#copy:  #
#copy:  #   # Matches a single header. 
#copy:  #   { :header => simple(:header) }
#copy:  #
#copy:  # see {Marpa::Transform}
#copy:  #
#copy:  def simple(symbol)
#copy:    Pattern::SimpleBind.new(symbol)
#copy:  end
#copy:  module_function :simple
#copy:  
#copy:  # Returns a placeholder for tree transformation patterns that will match 
#copy:  # any kind of subtree. 
#copy:  #
#copy:  #   { :expression => subtree(:exp) }
#copy:  #
#copy:  def subtree(symbol)
#copy:    Pattern::SubtreeBind.new(symbol)
#copy:  end
#copy:  module_function :subtree
#copy:
#copy:  autoload :Expression, 'marpa/expression'
end  # module Marpa


#copy:require 'marpa/slice'
#copy:require 'marpa/cause'
#copy:require 'marpa/source'
require 'marpa/atoms'
#copy:require 'marpa/pattern'
#copy:require 'marpa/pattern/binding'
#copy:require 'marpa/transform'
require 'marpa/grammar'
require 'marpa/parser'
#copy:require 'marpa/error_reporter'
#copy:require 'marpa/scope'
