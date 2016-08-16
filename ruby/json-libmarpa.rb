# json-libmarpa.rb -- Initial test for Ruby bindings to libmarpa.
#
# Ryan Hinton, Maple View Design, 12 Aug 2016.


require 'ffi'
require_relative 'libmarpa'


# environment
ver = FFI::MemoryPointer.new(:int, 3)
LibMarpa.marpa_version(ver)
uname = `uname -a`.split
puts "os: #{uname[0]} #{uname[2]} #{uname[3]} #{uname[4]}"
puts "Ruby version #{RUBY_VERSION}"
puts "libmarpa version #{ver.read_array_of_int(3).join('.')}"
#?:puts "FFI version "
puts "-" * 19

# initialize Marpa system
pconfig = FFI::MemoryPointer.new LibMarpa::Marpa_Config
LibMarpa.marpa_c_init(pconfig)
#config = LibMarpa::Marpa_Config.new(pconfig)

# create an empty grammar, turn off deprecated feature
pg = LibMarpa.marpa_g_new(pconfig)
pmsg = FFI::MemoryPointer.new :pointer
if LibMarpa::Error::NONE != LibMarpa.marpa_c_error(pconfig, pmsg)
  raise RuntimeError, "Error creating grammar: #{pmsg.read_string}"
end
# can deallocate pconfig now
rc = LibMarpa.marpa_g_force_valued(pg)
if rc < 0
  raise RuntimeError, "Error forcing valued grammar: code #{rc}."
end

# grammar symbols from RFC7159
s_begin_array     = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_begin_object    = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_end_array       = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_end_object      = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_name_separator  = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_value_separator = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_member          = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_value           = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_false           = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_null            = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_true            = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_object          = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_array           = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_number          = LibMarpa.marpa_g_symbol_new(pg) # check g error
s_string          = LibMarpa.marpa_g_symbol_new(pg) # check g error

# additional symbols
s_object_contents = LibMarpa.marpa_g_symbol_new (pg) # check g error
s_array_contents  = LibMarpa.marpa_g_symbol_new (pg) # check g error

# map numbers to names
SYM_NAMES = Hash.new('S_start')
SYM_NAMES[s_begin_array    ] = 's_begin_array'
SYM_NAMES[s_begin_object   ] = 's_begin_object'
SYM_NAMES[s_end_array      ] = 's_end_array'
SYM_NAMES[s_end_object     ] = 's_end_object'
SYM_NAMES[s_name_separator ] = 's_name_separator'
SYM_NAMES[s_value_separator] = 's_value_separator'
SYM_NAMES[s_member         ] = 's_member'
SYM_NAMES[s_value          ] = 's_value'
SYM_NAMES[s_false          ] = 's_false'
SYM_NAMES[s_null           ] = 's_null'
SYM_NAMES[s_true           ] = 's_true'
SYM_NAMES[s_object         ] = 's_object'
SYM_NAMES[s_array          ] = 's_array'
SYM_NAMES[s_number         ] = 's_number'
SYM_NAMES[s_string         ] = 's_string'
SYM_NAMES[s_object_contents] = 's_object_contents'
SYM_NAMES[s_array_contents ] = 's_array_contents'

# rules for value
rhs = [0] * 4
rc = [0] * 98
prhs = FFI::MemoryPointer.new(:int, rhs.size)
rhs[0] = s_false;  prhs.write_array_of_int(rhs)
rc[0] = LibMarpa.marpa_g_rule_new(pg, s_value, prhs, 1)
rhs[0] = s_null;  prhs.write_array_of_int(rhs)
rc[1] = LibMarpa.marpa_g_rule_new(pg, s_value, prhs, 1)
rhs[0] = s_true;  prhs.write_array_of_int(rhs)
rc[2] = LibMarpa.marpa_g_rule_new(pg, s_value, prhs, 1)
rhs[0] = s_object;  prhs.write_array_of_int(rhs)
rc[3] = LibMarpa.marpa_g_rule_new(pg, s_value, prhs, 1)
rhs[0] = s_array;  prhs.write_array_of_int(rhs)
rc[4] = LibMarpa.marpa_g_rule_new(pg, s_value, prhs, 1)
rhs[0] = s_number;  prhs.write_array_of_int(rhs)
rc[5] = LibMarpa.marpa_g_rule_new(pg, s_value, prhs, 1)
rhs[0] = s_string;  prhs.write_array_of_int(rhs)
rc[6] = LibMarpa.marpa_g_rule_new(pg, s_value, prhs, 1)

rhs[0] = s_begin_array
rhs[1] = s_array_contents
rhs[2] = s_end_array
prhs.write_array_of_int(rhs)
rc[7] = LibMarpa.marpa_g_rule_new(pg, s_array, prhs, 3)

rhs[0] = s_begin_object
rhs[1] = s_object_contents
rhs[2] = s_end_object
prhs.write_array_of_int(rhs)
rc[8] = LibMarpa.marpa_g_rule_new(pg, s_object, prhs, 3)

rc[9] = LibMarpa.marpa_g_sequence_new(pg, s_array_contents, s_value, s_value_separator, 0, 
                                      LibMarpa::PROPER_SEPARATION)
rc[10] = LibMarpa.marpa_g_sequence_new(pg, s_object_contents, s_member, s_value_separator, 0,
                                       LibMarpa::PROPER_SEPARATION)

rhs[0] = s_string;
rhs[1] = s_name_separator;
rhs[2] = s_value;
prhs.write_array_of_int(rhs)
rc[11] = LibMarpa.marpa_g_rule_new(pg, s_member, prhs, 3)
rc[12] = LibMarpa.marpa_g_start_symbol_set(pg, s_value)

# check creation statements
rc.each_with_index {|c,i| puts "call #{i} failed" if c < 0}

rc[13] = LibMarpa.marpa_g_precompute(pg)
if rc[13] < 0
  pstr = FFI::MemoryPointer.new :string
  e = LibMarpa.marpa_g_error(pg, pstr)
  puts "Error precomputing grammar: #{pstr.read_string}"
  #puts(codes.errors[e])
  exit(1)
end

def show_symbols(pg)
  highest_symbol_id = LibMarpa.marpa_g_highest_symbol_id(pg)
  puts "  highest symbol id #{highest_symbol_id}"
  (0..highest_symbol_id).each do |sidx|
    puts "S#{sidx}:#{SYM_NAMES[sidx]}"
  end
end

#DEBUG::
puts "Grammar symbols: "
show_symbols(pg)
puts ''

def show_rules(pg)
  highest_rule_id = LibMarpa.marpa_g_highest_rule_id(pg)
  puts "  highest rule id #{highest_rule_id}"
  (0..highest_rule_id).each do |rule_id|
    lhs_id = LibMarpa.marpa_g_rule_lhs(pg, rule_id)
    rule_length = LibMarpa.marpa_g_rule_length(pg, rule_id)
    rhs = Array.new(rule_length) do |ix|
      SYM_NAMES[LibMarpa.marpa_g_rule_rhs(pg, rule_id, ix)]
    end
    puts "R#{rule_id}: #{SYM_NAMES[lhs_id]} ::= #{rhs.join(' ')}"
    sequence_min = LibMarpa.marpa_g_sequence_min(pg, rule_id)
    if sequence_min != -1
      is_proper_separation = LibMarpa.marpa_g_rule_is_proper_separation(pg, rule_id)
      puts "    proper separation: #{is_proper_separation}, sequence min: #{sequence_min}"
    end
  end
end

#DEBUG::
puts "Grammar rules: "
show_rules(pg)
puts ''
    
pr = LibMarpa.marpa_r_new(pg)

if pr.nil?
  pstr = FFI::MemoryPointer.new :string
  e = LibMarpa.marpa_g_error(pg, pstr)
  puts "Error creating recognizer: #{pstr.read_string}"
  #puts(codes.errors[e])
  exit(1)
end

rc[14] = LibMarpa.marpa_r_start_input(pr)
if rc[14] < 0
  pstr = FFI::MemoryPointer.new :string
  e = LibMarpa.marpa_g_error(pg, pstr)
  puts "Error in marpa_r_start_input: #{pstr.read_string}"
  #puts(codes.errors[e])
  exit(1)
end

input = ''
if ARGV.length > 0 and File.exist? ARGV[0]
  puts "Reading file [#{ARGV[0]}]."
  input = IO.read(ARGV[0])
else
  input = '[ 1, "abc\ndef", -2.3, null, [], true, false, [1,2,3], {}, {"a":1,"b":2} ]'
end
#print "\nJSON Input:\n", input


# lexing
s_none = -1
token_spec = [
  [%r"\{", 'S_begin_object',     s_begin_object],
  [%r"\}", 'S_end_object',       s_end_object],
  [%r"\[", 'S_begin_array',      s_begin_array],
  [%r"\]", 'S_end_array',        s_end_array],
  [%r",",  'S_value_separator',  s_value_separator],
  [%r":",  'S_name_separator',   s_name_separator],

  [%r'"(([^"\\]|\\[\\"/bfnrt]|\\u\d{4})*)"',         'S_string', s_string],
  [%r'-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?',  'S_number', s_number],
  # un-confuse Emacs Ruby mode ']

  [%r'\btrue\b',  'S_true',  s_true],
  [%r'\bfalse\b', 'S_false', s_false],
  [%r'\bnull\b',  'S_null',  s_null],

  [%r'[ \t]+', 'SKIP',     s_none],  # Skip over spaces and tabs
  [%r'[\r\n]', 'NEWLINE',  s_none],  # Line endings
  [%r'.',      'MISMATCH', s_none],  # Any other character
]

token_id    = {}
token_names = []
token_regex = []
token_spec.each do |re, name, sym|
  token_id[name.to_sym] = sym if sym != s_none
  #token_regex.push("(?P<#{name}>#{re})")
  token_regex.push("(?<#{name}>#{re})")
  #token_regex.push("(#{re})")
  token_names.push(name)
end
token_regex = Regexp.new(token_regex.join('|'))

puts "Lexing token regex:"
puts "  #{token_regex.to_s}"

pos = 0
line_num = 1
line_start = 0
token_values = {}
while md = input.match(token_regex, pos)
  len = md[0].length

  if md[:NEWLINE]
    line_start = md.end(:NEWLINE)
    line_num += 1
  elsif md[:SKIP]
    nil  # do nothing
  elsif md[:MISMATCH]
    raise RuntimeError, "#{md[:MISMATCH]} unexpected on line #{line_num}"
  else
    token_symbol = md.names.find {|nm| md[nm]}
    token_value  = md[token_symbol]
    column = md.begin(0) - pos

    token_symbol_id = token_id[token_symbol]
    token_start     = md.begin(0)
    token_length    = token_value.length

    status = LibMarpa.marpa_r_alternative(pr, token_symbol_id, token_start+1, 1)
    if status != LibMarpa::Error::NONE
      raise RuntimeError, 'parse error'
    end

    status = LibMarpa.marpa_r_earleme_complete(pr)
    if status < 0
      raise RuntimeError, 'erleme_complete'
    end

    token_values[token_start] = token_value
    
  end  # case token_symbol

  pos += md[0].length
end  # loop over lexing input
#for mo in re.finditer(token_regex, input):
#
#  token_symbol    = mo.lastgroup
#  token_value     = mo.group(token_symbol)
#  
#  if token_symbol == 'NEWLINE':
#      line_start = mo.end()
#      line_num += 1
#  elif token_symbol == 'SKIP':
#      pass
#  elif token_symbol == 'MISMATCH':
#      raise RuntimeError('%r unexpected on line %d' % (value, line_num))
#  else:
#      column = mo.start() - line_start
#      
#      token_symbol_id = token_id[token_symbol]
#      token_start     = mo.start()
#      token_length    = len(token_value)
#
##     print token_symbol, token_symbol_id, "'%s'" % token_value, "%s:%s" % (token_start, token_length), '@%s:%s' % (line_num, column)
#      
#      status = lib.marpa_r_alternative (r, token_symbol_id, token_start + 1, 1)
#      if status != lib.MARPA_ERR_NONE:
#        expected = ffi.new("Marpa_Symbol_ID*")
#        count_of_expected = lib.marpa_r_terminals_expected (r, expected)
#        # todo: list expected terminals
#        print('marpa_r_alternative: ' + ', '.join(codes.errors[status]))
#        sys.exit (1)
#      
#      status = lib.marpa_r_earleme_complete (r)
#      if status < 0:
#        e = lib.marpa_g_error (g, ffi.new("char**"))
#        print ('marpa_r_earleme_complete:' + e)
#        sys.exit (1)
#      
#      token_values[token_start] = token_value
#
## valuate
#      
#bocage = lib.marpa_b_new (r, -1)
#if bocage == ffi.NULL:
#  e = lib.marpa_g_error (g, ffi.new("char**"))
#  print(codes.errors[e])
#  sys.exit (1)
#
#order = lib.marpa_o_new (bocage)
#if order == ffi.NULL:
#  e = lib.marpa_g_error (g, ffi.new("char**"))
#  print(codes.errors[e])
#  sys.exit (1)
#
#tree = lib.marpa_t_new (order)
#if tree == ffi.NULL:
#  e = lib.marpa_g_error (g, ffi.new("char**"))
#  print(codes.errors[e])
#  sys.exit (1)
#
#tree_status = lib.marpa_t_next (tree)
#if tree_status <= -1:
#  e = lib.marpa_g_error (g, ffi.new("char**"))
#  print("marpa_t_next returned:", e, codes.errors[e])
#  sys.exit (1)
#
#value = lib.marpa_v_new (tree)
#if value == ffi.NULL:
#  e = lib.marpa_g_error (g, ffi.new("char**"))
#  print("marpa_v_new returned:", e, codes.errors[e])
#  sys.exit (1)
#
#column = 0
#
##print "Parser Output:"
#
#while 1:
#  step_type = lib.marpa_v_step (value)
#  if step_type < 0:
#    e = lib.marpa_g_error (g, ffi.new("char**"))
#    print("marpa_v_event returned:", e, codes.errors[e])
#    sys.exit (1)
#  if step_type == lib.MARPA_STEP_INACTIVE:
#    if 0: print ("No more events\n")
#    break
#  if step_type != lib.MARPA_STEP_TOKEN:
#    continue
#  token = value.t_token_id
#  if column > 60:
#    sys.stdout.write ("\n")
#    column = 0
#  if token == S_begin_array:
#    sys.stdout.write ('[')
#    column += 1
#    continue
#  if token == S_end_array:
#    sys.stdout.write (']')
#    column += 1
#    continue
#  if token == S_begin_object:
#    sys.stdout.write ('{')
#    column += 1
#    continue
#  if token == S_end_object:
#    sys.stdout.write ('}')
#    column += 1
#    continue
#  if token == S_name_separator:
#    sys.stdout.write (':')
#    column += 1
#    continue
#  if token == S_value_separator:
#    sys.stdout.write (',')
#    column += 1
#    continue
#  if token == S_null:
#    sys.stdout.write( "null" )
#    column += 4
#    continue
#  if token == S_true:
#    sys.stdout.write ('true')
#    column += 1
#    continue
#  if token == S_false:
#    sys.stdout.write ('false')
#    column += 1
#    continue
#  if token == S_number:
#    start_of_number = value.t_token_value - 1
#    sys.stdout.write( token_values[start_of_number] )
#    column += 1
#  if token == S_string:
#    start_of_string = value.t_token_value - 1
#    sys.stdout.write( token_values[start_of_string] )
#    
#sys.stdout.write("\n")

puts "Ran to completion."
