# The Grammar class is a usable interface to the Marpa grammar definition via
# the libmarpa FFI bindings.
#
# Ryan Hinton, Maple View Design, 17 Aug 2016.

require 'libmarpa'


module Marpa
  # The base class for all your grammars. Use as follows: 
  #
  #   require 'marpa'
  #        
  #   class MyGrammar < Marpa::Grammar
  #     rule(:a) { str('a').repeat }
  #     root(:a)        
  #   end
  #        
  #   pp MyGrammar.new.parse('aaaa')   # => 'aaaa'
  #   pp MyGrammar.new.parse('bbbb')   # => Marpa::Atoms::ParseFailed: 
  #                                    #    Don't know what to do with bbbb at line 1 char 1.
  #
  # Marpa::Grammar is also a grammar atom. This means that you can mix full 
  # fledged grammars freely with small parts of a different grammar. 
  #
  # Example: 
  #   class GrammarA < Marpa::Grammar
  #     root :aaa
  #     rule(:aaa) { str('a').repeat(3,3) }
  #   end
  #   class GrammarB < Marpa::Grammar
  #     root :expression
  #     rule(:expression) { str('b') >> GrammarA.new >> str('b') }
  #   end
  #
  # In the above example, GrammarB would parse something like 'baaab'. 
  #
  class Grammar
    include Marpa

    class << self # class methods
      # Define the grammar's #root function. This is the place where you start
      # parsing; if you have a rule for 'file' that describes what should be in
      # a file, this would be your root declaration:
      #
      #   class Grammar
      #     root :file
      #     rule(:file) { ... }
      #   end
      #
      # #root declares a 'parse' function that works just like the parse function
      # that you can call on a simple production, taking a string as input and
      # producing parse output.
      #
      # In a way, #root is a shorthand for: 
      #
      #   def parse(str)
      #     your_grammar_root.parse(str)
      #   end
      #
      def root(name)
        define_method(:root) do
          self.send(name)
        end
      end
    end
    
    def to_s_inner
      root.to_s
    end


    # Parslet leftovers above
    ########################################
    # Marpa new stuff below


    # Debug access to Marpa "time" objects.
    attr_reader :pg, :pr
    # Debug access to mapping from symbol IDs to DSL atoms and back
    attr_reader :id_to_atom, :atom_to_id

    # root rule for this instance of the grammar
    attr_reader :inst_root

    # Initialize a grammar for the given root rule.  Consists of creating an
    # initializing the grammar.
    def initialize(temp_root=nil)
      # create a config object so we can create a grammar; will be freed when
      # pconfig is GC'ed
      pconfig = FFI::MemoryPointer.new LibMarpa::Marpa_Config
      LibMarpa.marpa_c_init(pconfig)

      # create a new, empty grammar
      @pg = LibMarpa.marpa_g_new(pconfig)
      pmsg = FFI::MemoryPointer.new :pointer
      if LibMarpa::Error::NONE != LibMarpa.marpa_c_error(pconfig, pmsg)
        raise RuntimeError, "Error creating grammar: #{pmsg.read_string}"
      end
      rc = LibMarpa.marpa_g_force_valued(pg)
      if rc < 0
        raise RuntimeError, "Error forcing valued grammar: code #{rc}."
      end

      # initialize id => atom mapping
      @id_to_atom = {}
      @atom_to_id = {}

      # call rules to build the grammar
      @inst_root = root
      @inst_root = self.class.send(temp_root) if temp_root
      @inst_root.build(self)

      # set the starting rule for this grammar
      rc = LibMarpa.marpa_g_start_symbol_set(@pg, @atom_to_id[@inst_root])
      raise_if_negative(rc, "Error setting desired starting symbol")

      # precompute the grammar
      self.ensure_precomputed
      
    end  # initialize method

    # Return the symbol ID for the given atom, or +nil+ if this atom has not
    # yet had a symbol created for it.
    def sym_id(atom)
      @atom_to_id[atom]
    end

    # Return the atom for the given symbol ID, or +nil+ if the symbol ID is
    # somehow invalid.
    def atom(sym_id)
      @id_to_atom[sym_id]
    end

    # Raise an exception if the given return value is negative.
    def raise_if_negative(rc, err_str)
      if rc < 0
        #old:pstr = FFI::MemoryPointer.new :string
        #old:ec = LibMarpa.marpa_g_error(@pg, pstr)
        ec = LibMarpa.marpa_g_error(@pg, nil)
        raise ParseFailed, "#{err_str}: #{LibMarpa::Error::Message[ec]}"
      end
    end
    private :raise_if_negative

    # Create a symbol in the grammar and return its ID.  If the symbol creation
    # fails, a {Marpa::ParseFailed} exception will be thrown.
    def create_symbol(atom)
      # don't allow repeated symbols since they're likely to lead to repeated
      # rules
      raise ArgumentError, "Tried to create duplicate symbol for atom #{atom.to_s}." \
        if @atom_to_id[atom]

      # create the LibMarpa symbol
      id = LibMarpa.marpa_g_symbol_new(@pg)
      raise_if_negative(id, "Error creating symbol for atom [#{atom.to_s}]")
      @id_to_atom[id] = atom
      @atom_to_id[atom] = id
      return id
    end

    # Create a rule in the grammar (BNF production).  
    # 
    # @param lhs_id [Fixnum] Grammar symbol ID for left-hand side of this BNF
    #   production.  Must be a valid symbol ID, currently only available through
    #   the :create_symbol method.
    # @param rhs [Fixnum or Array] If a Fixnum, it is the grammar symbol ID for
    #   the right-hand side of this BNF production.  Or it may be an array of
    #   grammar symbols for the RHS of the production.
    # @return [Fixnum] Integer ID for the new rule.
    #
    # If the rule creation fails, a {Marpa::ParseFailed} exception will be
    # thrown.
    # 
    # A sequence (Parslet terminology) will call :create_rule once with an
    # array.  An {Alternative} will call :create_rule once for each
    # alternative, each time with a {Fixnum} for the RHS.  Repetitions (Marpa
    # sequences) will call :create_sequence instead.
    def create_rule(lhs_id, rhs)
      rhs = [rhs] unless rhs.respond_to? :each
      len_rhs = rhs.size
      prhs = FFI::MemoryPointer.new(:int, len_rhs)
      prhs.write_array_of_int(rhs)
      rule_id = LibMarpa.marpa_g_rule_new(@pg, lhs_id, prhs, len_rhs)
      raise_if_negative(rule_id, "Error creating rule for atom [#{@id_to_atom[lhs_id].to_s}]")
      return rule_id
    end

    # Create a repetition rule in the grammar (BNF production, aka Marpa
    # 'sequence').
    # 
    # @param lhs_id [Fixnum] Grammar symbol ID for left-hand side of this BNF
    #   production.  Must be a valid symbol ID, currently only available through
    #   the :create_symbol method.
    # @param rep_id [Fixnum] Grammar symbol ID to be repeated.
    # @param sep_id [Fixnum, default +nil+] Grammar symbol ID that separates
    #   the repeated symbol (if any).
    # @param proper_sep [TrueClass or FalseClass, default +true+] True if this
    #   is a "proper separation."  A proper separation does not accept
    #   +sep_id+ after the last occurrence of +rep_id+.
    # @return [Fixnum] Integer ID for the new rule.
    #
    # If the rule creation fails, a {Marpa::ParseFailed} exception will be
    # thrown.
    # 
    # This method name uses the Parslet term of "repetition" and creates the
    # Marpa equivalent "sequence".
    def create_repetition_rule(lhs_id, rep_id, min_reps=0, sep_id=-1, proper_sep=true)
      flags = (proper_sep) ? (LibMarpa::PROPER_SEPARATION) : 0
      seq_id = LibMarpa.marpa_g_sequence_new(@pg, lhs_id, rep_id, sep_id, min_reps, flags)
      raise_if_negative(seq_id, "Error creating sequence rule for atom [#{@id_to_atom[lhs_id].to_s}]")
      return seq_id
    end

    # Print the symbols in the grammar.
    def show_symbols
      highest_symbol_id = LibMarpa.marpa_g_highest_symbol_id(@pg)
      (0..highest_symbol_id).each do |sidx|
        puts "S#{sidx}:#{@id_to_atom[sidx].to_s}"
      end
    end

    # Helper method to get the information about the rule.  Returns a pair of
    # arrays.  The first array has a list of symbols.  The LHS symbol is in
    # position 0, and the RHS symbols are in positions 1..N.  The second array
    # has the same format, but with parser atoms instead of symbols.
    def get_rule(rule_id)
      lhs_id = LibMarpa.marpa_g_rule_lhs(pg, rule_id)
      rule_length = LibMarpa.marpa_g_rule_length(pg, rule_id)
      rhs_id = Array.new(rule_length) do |ix|
        LibMarpa.marpa_g_rule_rhs(pg, rule_id, ix)
      end
      lhs = @id_to_atom[lhs_id]
      rhs = rhs_id.map {|id| @id_to_atom[id]}
      return [[lhs_id, rhs_id], [lhs, rhs]]
    end  # get_rule method

    # Print the rules in the grammar.
    def show_rules
      highest_rule_id = LibMarpa.marpa_g_highest_rule_id(pg)
      (0..highest_rule_id).each do |rule_id|
        syms, atoms = get_rule(rule_id)
        lhs_id, rhs_id = syms;  lhs, rhs = atoms
        sequence_min = LibMarpa.marpa_g_sequence_min(pg, rule_id)
        if sequence_min < 0
          puts "R#{rule_id}: S#{lhs_id} ::= S#{rhs_id.join(' S')}"
          puts "     #{lhs.name} ::= #{rhs.join(' ')}"
        else
          puts "R#{rule_id}: S#{lhs_id} ::= sequence ( S#{rhs_id.join(' S')} ) "
          puts "     #{lhs.name} ::= sequence ( #{rhs.join(' ')} )"
          sep_id = LibMarpa.marpa_g_sequence_separator(pg, rule_id)
          is_proper_separation = LibMarpa.marpa_g_rule_is_proper_separation(pg, rule_id)
          puts "    separation: S#{sep_id} proper: #{is_proper_separation}, sequence min: #{sequence_min}"
        end
      end
    end  # show_rules method

    # asdf
    def ensure_precomputed
      # check to see if already precomputed
      rc = LibMarpa.marpa_g_is_precomputed(pg)
      raise_if_negative(rc, "Error calling marpa_g_is_precomputed")

      # short-circuit if already precomputed
      return if 1 == rc

      # precompute
      rc = LibMarpa.marpa_g_precompute(pg)
      raise_if_negative(rc, "Error calling marpa_g_precompute")

      # check for events
      num_events = LibMarpa.marpa_g_event_count(@pg)
      raise_if_negative(num_events, "Error calling marpa_g_event_count")

      # process events
      pevt = LibMarpa::Marpa_Event.new.pointer
      num_events.times do |eidx|
        evt_id = marpa_g_event(@pg, pevt, eidx)
        puts "Grammar precompute event #{evt_id}."
      end  # event processing loop

      #TODO: decide what to do
      if num_events > 0
        raise ParseFailed, "Unexpected event while precomputing grammar." 
      end
    end  # ensure_precomputed method

  end  # class Grammar

end  # module Marpa
