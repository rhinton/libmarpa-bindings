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
  require 'byebug'
  #dbg:require 'byebug' ; debugger ; a=1
  grammar = JSONGrammar.new
  #verbose:puts "\n  == Grammar symbols =="
  #verbose:grammar.show_symbols
  #verbose:puts "\n  == Grammar rules =="
  #verbose:grammar.show_rules
  #verbose:puts " "

  parser = Marpa::Parser.new
  def parser.rule_value(rule_id, args)
    puts "Evaluate rule R#{rule_id} with arguments #{args.inspect}"
  end
  def parser.token_value(sym_id, str)
    str
  end

  #tmp:parser.parse(" xasdfasdfasd ", grammar) rescue nil
  parser.parse('[ 1, "abc\ndef", -2.3, null, [], true, false, [1,2,3], {}, {"a":1,"b":2} ]', grammar)
  #tmp:parser.parse(' 319  ', grammar)
  #tmp:parser.show_progress(0)
  #tmp:parser.show_progress(1)

  #tmp:# Create method to "evaluate" a 
  #tmp:def parser.evaluate(??)
  #tmp:end
  #tmp:
  #tmp:# add SAX-like methods to turn bocage into a parse
  #tmp:def parser.start_sym(sid, pos)
  #tmp:end
  #tmp:def parser.end_sym(sid, pos)
  #tmp:end
end

