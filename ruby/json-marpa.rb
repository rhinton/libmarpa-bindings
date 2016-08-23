# Higher-level JSON parser example.

# add current directory and subdirectory to our path
$:.push('.')

require 'marpa'

class JSONGrammar < Marpa::Grammar
  root(:value)

  rule(:value)  { lex(/\bfalse\b/) | 
                  lex(/\btrue\b/) | 
                  lex(/\bnull\b/) | 
                  object | array | number | string }
  rule(:array)  { str('[') >> value.repeat(0, str(',')) >> str(']') }
  rule(:object) { str('{') >> member.repeat(0, str(',')) >> str('}') }
  rule(:member) { string >> str(':') >> value }

  rule(:string) { lex(%r'"(([^"\\]|\\[\\"/bfnrt]|\\u\d{4})*)"') }
  rule(:number) { lex(%r'-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?') }
  # un-confuse Emacs Ruby mode with character '

  # discard whitespace
  discard(/\s+/)
end


# testing code if this is the top level
if $0 == __FILE__
  require 'byebug' ; debugger ; a=1
  grammar = JSONGrammar.new
  #tmp:puts "\n  == Grammar symbols =="
  #tmp:grammar.show_symbols
  #tmp:puts "\n  == Grammar rules =="
  #tmp:grammar.show_rules

  parser = Marpa::Parser.new
  parser.parse(" xasdfasdfasd ", grammar)
end

