
require 'libmarpa'

# The {Marpa::Parser} base class handles the mechanics of parsing.  The current
# interface is a SAX-style parser where the user should create a derived class
# and override +#symbol_start+ and +#symbol_end+ to implement the desired
# semantics.
#
# Write an example here.
module Marpa
  class Parser
  
    def initialize
      @pr = nil
    end
  
    def parse(io, grammar)
      # store off a pointer to the grammar
      @grammar = grammar
      pg = grammar.pg
  
      # precompute the grammar if needed
      grammar.ensure_precomputed
  
      # create the recognizer
      @pr = LibMarpa.marpa_r_new(pg)
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
  
      # primary lexing, parsing loop
      pos = 0
      while true
        num_terminals = LibMarpa.marpa_r_terminals_expected(@pr, pterms_buf)
        raise_unless(num_terminals >= 0, "Error calling marpa_r_terminals_expected")
  
        # try the discarded patterns to consume any unwanted stuff
        pre_discard_pos = pos
        active = true
        while active
          active = false
          @grammar.discards.each do |lex|
            result = lex.match(io)
            io.set_pos(pos += result.length) if result
            puts "  (discarded #{result.length} chars at pos #{pos} by rule #{lex.inspect})" if result #DEBUG::
            # intentional assignment on previous statement
          end
        end
        discard_len = pos - pre_discard_pos

        # try each of the expected terminals
        puts "  (finished discarding characters, trying terminals at pos #{pos})" #DEBUG::
        pterms_buf.read_array_of_int(num_terminals).each do |sidx|
          atom = @grammar.atom(sidx)
          puts "  (trying expected pattern #{atom.inspect})" #DEBUG::
          if mr = atom.match(io)  # intentional assignment
            puts " matched #{atom.inspect} at pos #{pos}, finished at pos #{pos+mr.length}" #DEBUG::
            rc = LibMarpa.marpa_r_alternative(@pr, sidx, 1+pos, discard_len + mr.length)
            # the value is 1+ the start of the non-discarded part of the token
            # (value of 0 is reserved, see Libmarpa docs)
            if rc != LibMarpa::Error::NONE
              LibMarpa.raise_error_code(rc, @pg, "Error calling marpa_r_alternative")
            end
          end  # true when terminal matches
        end  # each expected terminal

        # finish this earleme
        rc = LibMarpa.marpa_r_earleme_complete(@pr)
        raise_unless(@pr, "Error calling marpa_r_earleme_complete")
        
        # process events
        pevt = Marpa_Event.new.pointer
        num_events = rc
        num_events.times do |eidx|
          evt_id = marpa_g_event(@pg, pevt, eidx)
          puts "Earleme complete event #{evt_id}."
        end  # event processing loop

      end  # primary lexing, parsing loop

      # free the recognizer
      LibMarpa.marpa_r_unref(@pr)
      
    end  # parse method
    
    # Raise an exception if the given return value is negative.
    def raise_unless(tf, err_str)
      if ! tf
        pstr = FFI::MemoryPointer.new :string
        ec = LibMarpa.marpa_g_error(@grammar.pg, pstr)
        raise ParseFailed, "#{err_str}: #{pstr.read_string}"
      end
    end
    private :raise_unless
  
  end  # class Parser
end  # module Marpa
