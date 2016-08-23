
# A mixin module that defines operations that can be called on any subclass
# of Marpa::Atoms::Base. These operations make marpas atoms chainable and 
# allow combination of marpa atoms to form bigger parsers.
#
# Example: 
#
#   str('foo') >> str('bar')
#   str('f').repeat
#   any.absent?               # also called The Epsilon
#
module Marpa::Atoms::DSL
  # Construct a new atom that repeats the current atom min times at least and
  # at most max times. max can be nil to indicate that no maximum is present. 
  #
  # Example: 
  #   # match any number of 'a's
  #   str('a').repeat     
  #
  #   # match between 1 and 3 'a's
  #   str('a').repeat(1,3)
  #
  def repeat(min=0, max=nil)
    Marpa::Atoms::Repetition.new(self, min, max)
  end
  
  # Returns a new marpa atom that is only maybe present in the input. This
  # is synonymous to calling #repeat(0,1). Generated tree value will be 
  # either nil (if atom is not present in the input) or the matched subtree. 
  #
  # Example: 
  #   str('foo').maybe
  #
  def maybe
    #Marpa::Atoms::Repetition.new(self, 0, 1, :maybe)
    Marpa::Atoms::Maybe.new(self)
  end

  # Returns a new marpa atom that will not show up in the output. This
  # is synonymous to calling #repeat(0,1). Generated tree value will always be 
  # nil.
  #
  # Example: 
  #   str('foo').ignore
  #
  def ignore
    Marpa::Atoms::Ignored.new(self)
  end

  # Chains two marpa atoms together as a sequence. 
  #
  # Example: 
  #   str('a') >> str('b')
  #
  def >>(marpa)
    Marpa::Atoms::Sequence.new(self, marpa)
  end

  # Chains two marpa atoms together to express alternation. A match will
  # always be attempted with the marpa on the left side first. If it doesn't
  # match, the right side will be tried. 
  #
  # Example:
  #   # matches either 'a' OR 'b'
  #   str('a') | str('b')
  #
  def |(marpa)
    Marpa::Atoms::Alternative.new(self, marpa)
  end
  
#copy:  # Tests for absence of a marpa atom in the input stream without consuming
#copy:  # it. 
#copy:  # 
#copy:  # Example: 
#copy:  #   # Only proceed the parse if 'a' is absent.
#copy:  #   str('a').absent?
#copy:  #
#copy:  def absent?
#copy:    Marpa::Atoms::Lookahead.new(self, false)
#copy:  end
#copy:
#copy:  # Tests for presence of a marpa atom in the input stream without consuming
#copy:  # it. 
#copy:  # 
#copy:  # Example: 
#copy:  #   # Only proceed the parse if 'a' is present.
#copy:  #   str('a').present?
#copy:  #
#copy:  def present?
#copy:    Marpa::Atoms::Lookahead.new(self, true)
#copy:  end
#copy:  
#copy:  # Alias for present? that will disappear in 2.0 (deprecated)
#copy:  #
#copy:  alias prsnt? present?
#copy:
#copy:  # Alias for absent? that will disappear in 2.0 (deprecated)
#copy:  #
#copy:  alias absnt? absent?
#copy:
#copy:  # Marks a marpa atom as important for the tree output. This must be used 
#copy:  # to achieve meaningful output from the #parse method. 
#copy:  #
#copy:  # Example:
#copy:  #   str('a').as(:b) # will produce {:b => 'a'}
#copy:  #
#copy:  def as(name)
#copy:    Marpa::Atoms::Named.new(self, name)
#copy:  end
#copy:
#copy:  # Captures a part of the input and stores it under the name given. This 
#copy:  # is very useful to create self-referential parses. A capture stores
#copy:  # the result of its parse (may be complex) on a successful parse action.
#copy:  # 
#copy:  # Example: 
#copy:  #   str('a').capture(:b)  # will store captures[:b] == 'a'
#copy:  # 
#copy:  def capture(name)
#copy:    Marpa::Atoms::Capture.new(self, name)
#copy:  end
end
