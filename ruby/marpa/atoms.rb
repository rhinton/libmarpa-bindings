# Require the source code for different parser atoms.

module Marpa::Atoms
  require 'marpa/atoms/dsl'
  require 'marpa/atoms/base'
  require 'marpa/atoms/alternative'
  require 'marpa/atoms/entity'
  require 'marpa/atoms/lex'
  require 'marpa/atoms/maybe'
  require 'marpa/atoms/repetition'
  require 'marpa/atoms/sequence'
end  # module Marpa::Atoms
