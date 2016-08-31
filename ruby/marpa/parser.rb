
require 'libmarpa'
require 'stringio'

# The {Marpa::Parser} base class handles the mechanics of parsing.  The current
# interface is a SAX-style parser where the user should create a derived class
# and override +#symbol_start+ and +#symbol_end+ to implement the desired
# semantics.
#
# Write an example here.
module Marpa
  class Parser
    attr_reader :grammar
  
    def initialize(grammar)
      @pr = nil
      @grammar = grammar
    end
  
    def parse(io)
      # store off a pointer to the grammar

      # for convenience, wrap string inputs
      @str = (io.kind_of? String) ? io : io.read
      #dbg:puts "recognizing [#{@str}]"#DEBUG::
  
      # precompute the grammar if needed
      grammar.ensure_precomputed

      recognize
      value = evaluate

      return value
    end  # parse method

    # Determine whether the given string is a member of the grammar for this
    # parser.  Raises a +ParseFailed+ exception on failure.
    def recognize
      # convenience
      pg = grammar.pg
      str = @str

      # create the recognizer, free the last one if extant
      @pr = FFI::AutoPointer.new(LibMarpa.marpa_r_new(pg), 
                                 LibMarpa.method(:marpa_r_unref))
      raise_unless(@pr, "Error creating recognizer")
  
      # start the input
      rc = LibMarpa.marpa_r_start_input(@pr)
      raise_unless(rc >= 0, "Error in marpa_r_start_input")
  
      # prepare buffer for expected terminals
      highest_symbol_id = LibMarpa.marpa_g_highest_symbol_id(pg)
      terminals = (0..highest_symbol_id).find_all do |sidx|
        LibMarpa.marpa_g_symbol_is_terminal(pg, sidx)
      end
      max_terminals = terminals.length
      pterms_buf = FFI::MemoryPointer.new(:int, max_terminals)
  
      # primary lexing, recognizing loop
      pos = 0
      max_pos = 0
      while true
        # get the expected terminals
        num_terminals = LibMarpa.marpa_r_terminals_expected(@pr, pterms_buf)
        raise_unless(num_terminals >= 0, "Error calling marpa_r_terminals_expected")

        #DEBUG::
        pos = LibMarpa.marpa_r_current_earleme(@pr)
        #dbg:puts "(=== current earleme (pos) #{pos}, #{num_terminals} terminals expected)"
        
        # exit if we're done
        if pos >= str.length
          #dbg:puts "(Input consumed, recognizer succeeded!)"
          break
        end

        # work if there is work to be done
        if num_terminals > 0
          # try the discarded patterns to consume any unwanted stuff
          discard_len = discard_length(str, pos)
          pos += discard_len
          break if pos >= str.length
  
          # try each of the expected terminals
          terminal_matches = 0
          #dbg:puts " (finished discarding characters, trying terminals at pos #{pos})" #DEBUG::
          #dbg:puts "  (expected terminals #{pterms_buf.read_array_of_int(num_terminals)})" #DEBUG::
          pterms_buf.read_array_of_int(num_terminals).each do |sidx|
            atom = grammar.atom(sidx)
            #dbg:puts "  (trying expected pattern S#{sidx}=#{atom.inspect})" #DEBUG::
            if mr = atom.match(str, pos)  # intentional assignment
              match_len = mr[0].length
              #dbg:puts "  (matched #{atom.inspect} at pos #{pos}...#{pos+match_len}, adding alt length #{discard_len + match_len})" #DEBUG::
              terminal_matches += 1
              max_pos = [max_pos, pos + discard_len + match_len].max
              rc = LibMarpa.marpa_r_alternative(@pr, sidx, 1+pos, discard_len + match_len)
              # the value is 1+ the start of the non-discarded part of the token
              # (value of 0 is reserved per Libmarpa docs)
              if rc != LibMarpa::Error::NONE
                LibMarpa.raise_error_code(rc, pg, "Error calling marpa_r_alternative")
              end
            end  # true when terminal matches
          end  # each expected terminal
  
          # check for progress
          last_pos = LibMarpa.marpa_r_furthest_earleme(@pr)  # always succeeds
          if (last_pos <= pos) && (0 == terminal_matches)
            #DEBUG::
            last_pos.times do |idx|
              #dbg:puts "  == Progress report for input position #{idx} =="
              show_progress(idx)
            end
            require 'byebug' ; debugger ; a=1 
            #END DEBUG::
            raise ParseFailed,"Failed to match any expected terminals at position #{pos}."
          end
        else  #DEBUG::
          #dbg:puts " (no work at position #{pos})" #DEBUG:
        end  # if num_terminals > 0

        # finish this earleme
        rc = LibMarpa.marpa_r_earleme_complete(@pr)
        raise_unless(@pr, "Error calling marpa_r_earleme_complete")
        
        # process events
        pevt = FFI::MemoryPointer.new(LibMarpa::Marpa_Event)
        num_events = rc
        evts = Array.new(num_events) do |eidx|
          evt_id = LibMarpa.marpa_g_event(pg, pevt, eidx)
          #dbg:puts "(Earleme complete event #{evt_id}: #{LibMarpa::Event::Message[evt_id]}.)"
          evt_id
        end  # event processing loop
        exhausted = evts.index(LibMarpa::Event::EXHAUSTED)
        if exhausted
          #dbg:puts "(Recognizer exhausted, exiting)"
          break
        end

      end  # primary lexing, recognizing loop

      # check for recognizer completion
      if max_pos < str.length
        pos += 1
        pos += (dlen = discard_length(str, pos))  # intentional assignment
        if pos < str.length
          raise ParseFailed, "Recognizer recognized only first #{pos} characters of input."
        end
        #dbg:puts "(Remainder #{dlen} chars of string discarded.  Recognizer successful.)"
      end

      # recognizer done, must have succeeded
      return true
    end  # recognize method
    #private :recognize

    # Determine how much of the input can be discarded according to the
    # grammar's discard rules.
    def discard_length(str, pos)
      # try the discarded patterns to consume any unwanted stuff
      #dbg:puts " (trying discard patterns starting at pos #{pos})" #DEBUG::
      pre_discard_pos = pos
      active = true
      while active
        active = false
        grammar.discards.each do |lex|
          result = lex.match(str, pos)
          next unless result
          pos += (match_len = result[0].length)  # intentional assignment
          #dbg:puts "  (discarded #{match_len} chars to pos #{pos} by rule #{lex.inspect})" #DEBUG::
        end
      end
      discard_len = pos - pre_discard_pos
    end
    #private :discard_length
    
    # Iterate over the recognizer result and "evaluate" to implement the parser
    # semantics.  The derived class must implement a +value+ method to evaluate
    # the recognizer results.
    def evaluate
      # allocate the support objects for traversing the parse tree(s)
      pb = FFI::AutoPointer.new(LibMarpa.marpa_b_new(@pr, -1), 
                                LibMarpa.method(:marpa_b_unref))
      raise_unless(pb, "Failed to allocate bocage.")
      po = FFI::AutoPointer.new(LibMarpa.marpa_o_new(pb), 
                                LibMarpa.method(:marpa_o_unref))
      raise_unless(po, "Failed to allocate ordering.")
      pt = FFI::AutoPointer.new(LibMarpa.marpa_t_new(po), 
                                LibMarpa.method(:marpa_t_unref))
      raise_unless(pt, "Failed to allocate parse tree iterator.")

      parse_result = nil
      while true
        rc = LibMarpa.marpa_t_next(pt) 
        break if -1 == rc  # -1 return indicates no more trees
        raise_unless(rc >= 0, "Error calling marpa_t_next")
        parse_result = tree_iterate(pt)
      end

      #dbg:puts "(Tree iteration done, evaluation complete.)"#DEBUG::
      return parse_result
    end  # evaluate method
    #private :evaluate

    # Iterate over the tree, evaluating the recognizer results.
    def tree_iterate(pt)
      # create the valuator pointer
      pv = FFI::AutoPointer.new(LibMarpa.marpa_v_new(pt), 
                                LibMarpa.method(:marpa_v_unref))
      raise_unless(pv, "Error creating valuator")
      value = LibMarpa::Marpa_Value.new(pv)

      # step through the recognizer results
      stack = []
      while true
        # get the next step
        step_type = LibMarpa.marpa_v_step(pv)
        raise_unless(step_type >= 0, "Error in marpa_v_step")

        case step_type
        when LibMarpa::Step::RULE 
          stack[value[:t_result]] = rule_value(value[:t_rule_id], stack[value[:t_arg_0]..value[:t_arg_n]])
        when LibMarpa::Step::TOKEN
          tok_str = get_token_string(value[:t_token_id], value[:t_token_value])
          stack[value[:t_result]] = token_value(value[:t_token_id], tok_str)
        when LibMarpa::Step::NULLING_SYMBOL
          stack[value[:t_result]] = null_symbol_value(value[:t_token_id])
        when LibMarpa::Step::INACTIVE
          # "The valuator has gone through all its steps and is now inactive.
          # The value of the parse will be in stack location 0."
          break  
        when LibMarpa::Step::INITIAL
          # "The valueator is new and has yet to go through any steps"
          next  
        end
      end

      pv.free  # force free of valuator so tree can advance
      return stack[0]
    end

    # Default +rule_value+ implementation: "scons" of the name of the rule and
    # the arguments.
    def rule_value(rule_id, args)
      #[grammar.atom(rule_id).name, *args]
      syms, atoms = grammar.get_rule(rule_id)
      [atoms[0].name, *args]
    end

    # Default +token_value+ implementation: pass through the string.
    def token_value(sym_id, str)
      str
    end

    # Translate a symbol ID and "value" into the string for that token.  The
    # parser stores '1 + pos', the position where the token lexer matched, as
    # the value for the token.
    def get_token_string(sym_id, tok_val)
      mr = grammar.atom(sym_id).match(@str, tok_val-1)
      raise_unless(mr, "Failed to get token string: lexer failed to match at previous location.")
      return mr[0]
    end

    # Default null symbol value evaluator: +nil+.
    def null_symbol_value(sid)
    end

    # Raise an exception if the given return value is negative.
    def raise_unless(tf, err_str)
      if ! tf
        pstr = FFI::MemoryPointer.new :string
        ec = LibMarpa.marpa_g_error(grammar.pg, pstr)
        #old:raise ParseFailed, "#{err_str}: #{pstr.read_string}"
        #segfault:ec = LibMarpa.marpa_g_error(pg, nil)
        raise ParseFailed, "#{err_str}: #{LibMarpa::Error::Message[ec]}"
      end
    end
    private :raise_unless

    # Show progress of the parser (Earley items) at the given index ('earleme',
    # may be character or byte or lexer token, depending on the lexer).
    def show_progress(pos)
      pg = grammar.pg  # convenience

      rc = LibMarpa.marpa_r_progress_report_start(@pr, pos)
      raise_unless(rc >= 0, "Error in marpa_r_progress_report_start")

      num_items = rc
      ppos = FFI::MemoryPointer.new(:int)
      porigin = FFI::MemoryPointer.new(:int)#LibMarpa::Marpa_Earley_Set_ID)
      num_items.times do |idx|
        rule_id = LibMarpa.marpa_r_progress_item(@pr, ppos, porigin)
        raise_unless(rule_id >= 0, "Error calling marpa_r_progress_item")
        pos = ppos.read_int
        origin = porigin.read_int

        sequence_min = LibMarpa.marpa_g_sequence_min(pg, rule_id)
        seq_str = (sequence_min >= 0) ? '*' : ''

        syms, atoms = grammar.get_rule(rule_id)
        lhs_id, rhs_id = syms;  lhs, rhs = atoms
        pos = pos % (rhs.length + 1)  # handle -1 == pos case
        prefix = case pos
                 when 0 then "P"
                 when rhs.length then "F"
                 else "R"
                 end
        rhs_sid = rhs_id.map {|id| "S#{id}"}
        rule_str = rhs_sid[0...pos].join(' ') + ' . ' + rhs_sid[pos..-1].join(' ')
        puts "#{prefix}#{rule_id}: @#{origin}-#{pos} S#{lhs_id} -> #{rule_str} #{seq_str}"
      end
      
      rc = LibMarpa.marpa_r_progress_report_finish(@pr)
      raise_unless(rc >= 0, "Error in marpa_r_progress_report_finish")
    end  # show_progress

    def inspect
      "#<#{self.class} for #{grammar.inspect}>"
    end

  end  # class Parser
end  # module Marpa
