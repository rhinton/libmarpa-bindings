# marpa.rb -- FFI wrapper for libmarpa, reworked from that library's "marpa.h".
#
# Ryan Hinton, Maple View Design, 11 Aug 2016.


=begin
Copyright notice from marpa.h:

/*
 * Copyright 2015 Jeffrey Kegler
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

=end

#/*
# * DO NOT EDIT DIRECTLY
# * This file is written by the Marpa build process
# * It is not intended to be modified directly
# */
#
#rhinton: It would be nice to automatically generate marpa.rb from marpa.h.
# Maybe once I have Ruby bindings, I can write a Marpa grammar for the C header
# file....

require 'ffi'

module LibMarpa

  MARPA_MAJOR_VERSION=8
  MARPA_MINOR_VERSION=4
  MARPA_MICRO_VERSION=0

  extend FFI::Library
  #ffi_lib "/usr/local/lib/libmarpa.dll.a"
  #ffi_lib "/usr/local/bin/cygmarpa-8-4-0.dll"
  begin
    # Linux library name
    ffi_lib "marpa-#{MARPA_MAJOR_VERSION}.#{MARPA_MINOR_VERSION}.#{MARPA_MICRO_VERSION}"
  rescue LoadError
    # Cygwin library name
    ffi_lib "marpa-#{MARPA_MAJOR_VERSION}-#{MARPA_MINOR_VERSION}-#{MARPA_MICRO_VERSION}"
  end

  #line 1 "./marpa.h-err"
  module Error
    COUNT=100
    NONE = 0
    AHFA_IX_NEGATIVE = 1
    AHFA_IX_OOB = 2
    ANDID_NEGATIVE = 3
    ANDID_NOT_IN_OR = 4
    ANDIX_NEGATIVE = 5
    BAD_SEPARATOR = 6
    BOCAGE_ITERATION_EXHAUSTED = 7
    COUNTED_NULLABLE = 8
    DEVELOPMENT = 9
    DUPLICATE_AND_NODE = 10
    DUPLICATE_RULE = 11
    DUPLICATE_TOKEN = 12
    YIM_COUNT = 13
    YIM_ID_INVALID = 14
    EVENT_IX_NEGATIVE = 15
    EVENT_IX_OOB = 16
    GRAMMAR_HAS_CYCLE = 17
    INACCESSIBLE_TOKEN = 18
    INTERNAL = 19
    INVALID_AHFA_ID = 20
    INVALID_AIMID = 21
    INVALID_BOOLEAN = 22
    INVALID_IRLID = 23
    INVALID_NSYID = 24
    INVALID_LOCATION = 25
    INVALID_RULE_ID = 26
    INVALID_START_SYMBOL = 27
    INVALID_SYMBOL_ID = 28
    I_AM_NOT_OK = 29
    MAJOR_VERSION_MISMATCH = 30
    MICRO_VERSION_MISMATCH = 31
    MINOR_VERSION_MISMATCH = 32
    NOOKID_NEGATIVE = 33
    NOT_PRECOMPUTED = 34
    NOT_TRACING_COMPLETION_LINKS = 35
    NOT_TRACING_LEO_LINKS = 36
    NOT_TRACING_TOKEN_LINKS = 37
    NO_AND_NODES = 38
    NO_EARLEY_SET_AT_LOCATION = 39
    NO_OR_NODES = 40
    NO_PARSE = 41
    NO_RULES = 42
    NO_START_SYMBOL = 43
    NO_TOKEN_EXPECTED_HERE = 44
    NO_TRACE_YIM = 45
    NO_TRACE_YS = 46
    NO_TRACE_PIM = 47
    NO_TRACE_SRCL = 48
    NULLING_TERMINAL = 49
    ORDER_FROZEN = 50
    ORID_NEGATIVE = 51
    OR_ALREADY_ORDERED = 52
    PARSE_EXHAUSTED = 53
    PARSE_TOO_LONG = 54
    PIM_IS_NOT_LIM = 55
    POINTER_ARG_NULL = 56
    PRECOMPUTED = 57
    PROGRESS_REPORT_EXHAUSTED = 58
    PROGRESS_REPORT_NOT_STARTED = 59
    RECCE_NOT_ACCEPTING_INPUT = 60
    RECCE_NOT_STARTED = 61
    RECCE_STARTED = 62
    RHS_IX_NEGATIVE = 63
    RHS_IX_OOB = 64
    RHS_TOO_LONG = 65
    SEQUENCE_LHS_NOT_UNIQUE = 66
    SOURCE_TYPE_IS_AMBIGUOUS = 67
    SOURCE_TYPE_IS_COMPLETION = 68
    SOURCE_TYPE_IS_LEO = 69
    SOURCE_TYPE_IS_NONE = 70
    SOURCE_TYPE_IS_TOKEN = 71
    SOURCE_TYPE_IS_UNKNOWN = 72
    START_NOT_LHS = 73
    SYMBOL_VALUED_CONFLICT = 74
    TERMINAL_IS_LOCKED = 75
    TOKEN_IS_NOT_TERMINAL = 76
    TOKEN_LENGTH_LE_ZERO = 77
    TOKEN_TOO_LONG = 78
    TREE_EXHAUSTED = 79
    TREE_PAUSED = 80
    UNEXPECTED_TOKEN_ID = 81
    UNPRODUCTIVE_START = 82
    VALUATOR_INACTIVE = 83
    VALUED_IS_LOCKED = 84
    RANK_TOO_LOW = 85
    RANK_TOO_HIGH = 86
    SYMBOL_IS_NULLING = 87
    SYMBOL_IS_UNUSED = 88
    NO_SUCH_RULE_ID = 89
    NO_SUCH_SYMBOL_ID = 90
    BEFORE_FIRST_TREE = 91
    SYMBOL_IS_NOT_COMPLETION_EVENT = 92
    SYMBOL_IS_NOT_NULLED_EVENT = 93
    SYMBOL_IS_NOT_PREDICTION_EVENT = 94
    RECCE_IS_INCONSISTENT = 95
    INVALID_ASSERTION_ID = 96
    NO_SUCH_ASSERTION_ID = 97
    HEADERS_DO_NOT_MATCH = 98
    NOT_A_SEQUENCE = 99

    Message = {
      NONE => 'No error', 
      AHFA_IX_NEGATIVE => 'code 1', 
      AHFA_IX_OOB => 'code 2', 
      ANDID_NEGATIVE => 'code 3', 
      ANDID_NOT_IN_OR => 'code 4', 
      ANDIX_NEGATIVE => 'code 5', 
      BAD_SEPARATOR => 'Separator has invalid symbol ID', 
      BOCAGE_ITERATION_EXHAUSTED => 'code 7', 
      COUNTED_NULLABLE => 'Nullable symbol on RHS of a sequence rule', 
      DEVELOPMENT => 'code 9', 
      DUPLICATE_AND_NODE => 'code 10', 
      DUPLICATE_RULE => 'Duplicate rule', 
      DUPLICATE_TOKEN => 'Duplicate token', 
      YIM_COUNT => 'Maximum number of Earley items exceeded', 
      YIM_ID_INVALID => 'code 14', 
      EVENT_IX_NEGATIVE => 'Negative event index', 
      EVENT_IX_OOB => 'No event at that index', 
      GRAMMAR_HAS_CYCLE => 'Grammar has cycle', 
      INACCESSIBLE_TOKEN => 'Token symbol is inaccessible', 
      INTERNAL => 'code 19', 
      INVALID_AHFA_ID => 'code 20', 
      INVALID_AIMID => 'code 21', 
      INVALID_BOOLEAN => 'Argument is not boolean', 
      INVALID_IRLID => 'code 23', 
      INVALID_NSYID => 'code 24', 
      INVALID_LOCATION => 'Location is not valid', 
      INVALID_RULE_ID => 'Rule ID is malformed', 
      INVALID_START_SYMBOL => 'Specified start symbol is not valid', 
      INVALID_SYMBOL_ID => 'Symbol ID is malformed', 
      I_AM_NOT_OK => 'Marpa is in a not OK state', 
      MAJOR_VERSION_MISMATCH => 'Libmarpa bindings major version number mismatch', 
      MICRO_VERSION_MISMATCH => 'Libmarpa bindings micro version number mismatch', 
      MINOR_VERSION_MISMATCH => 'Libmarpa bindings minor version number mismatch', 
      NOOKID_NEGATIVE => 'code 33', 
      NOT_PRECOMPUTED => 'This grammar is not precomputed', 
      NOT_TRACING_COMPLETION_LINKS => 'code 35', 
      NOT_TRACING_LEO_LINKS => 'code 36', 
      NOT_TRACING_TOKEN_LINKS => 'code 37', 
      NO_AND_NODES => 'code 38', 
      NO_EARLEY_SET_AT_LOCATION => 'Earley set ID is after latest Earley set', 
      NO_OR_NODES => 'code 40', 
      NO_PARSE => 'No parse', 
      NO_RULES => 'This grammar does not have any rules', 
      NO_START_SYMBOL => 'This grammar has no start symbol', 
      NO_TOKEN_EXPECTED_HERE => 'No token is expected at this earleme location', 
      NO_TRACE_YIM => 'code 45', 
      NO_TRACE_YS => 'code 46', 
      NO_TRACE_PIM => 'code 47', 
      NO_TRACE_SRCL => 'code 48', 
      NULLING_TERMINAL => 'A symbol is both terminal and nulling', 
      ORDER_FROZEN => 'The ordering is frozen', 
      ORID_NEGATIVE => 'code 51', 
      OR_ALREADY_ORDERED => 'code 52', 
      PARSE_EXHAUSTED => 'The parse is exhausted', 
      PARSE_TOO_LONG => 'This input would make the parse too long', 
      PIM_IS_NOT_LIM => 'code 55', 
      POINTER_ARG_NULL => 'An argument is null when it should not be', 
      PRECOMPUTED => 'This grammar is precomputed', 
      PROGRESS_REPORT_EXHAUSTED => 'The progress report is exhausted', 
      PROGRESS_REPORT_NOT_STARTED => 'No progress report has been started', 
      RECCE_NOT_ACCEPTING_INPUT => 'The recognizer is not accepting input', 
      RECCE_NOT_STARTED => 'The recognizer has not been started', 
      RECCE_STARTED => 'The recognizer has been started', 
      RHS_IX_NEGATIVE => 'RHS index cannot be negative', 
      RHS_IX_OOB => 'RHS index must be less than rule length', 
      RHS_TOO_LONG => 'The RHS is too long', 
      SEQUENCE_LHS_NOT_UNIQUE => 'LHS of sequence rule would not be unique', 
      SOURCE_TYPE_IS_AMBIGUOUS => 'code 67', 
      SOURCE_TYPE_IS_COMPLETION => 'code 68', 
      SOURCE_TYPE_IS_LEO => 'code 69', 
      SOURCE_TYPE_IS_NONE => 'code 70', 
      SOURCE_TYPE_IS_TOKEN => 'code 71', 
      SOURCE_TYPE_IS_UNKNOWN => 'code 72', 
      START_NOT_LHS => 'Start symbol not on LHS of any rule', 
      SYMBOL_VALUED_CONFLICT => 'Symbol is treated both as valued and unvalued', 
      TERMINAL_IS_LOCKED => 'The terminal status of the symbol is locked', 
      TOKEN_IS_NOT_TERMINAL => 'Token symbol must be a terminal', 
      TOKEN_LENGTH_LE_ZERO => 'Token length must be greater than zero', 
      TOKEN_TOO_LONG => 'Token is too long', 
      TREE_EXHAUSTED => 'Tree iterator is exhausted', 
      TREE_PAUSED => 'Tree iterator is paused', 
      UNEXPECTED_TOKEN_ID => 'Unexpected token', 
      UNPRODUCTIVE_START => 'Unproductive start symbol', 
      VALUATOR_INACTIVE => 'Valuator inactive', 
      VALUED_IS_LOCKED => 'The valued status of the symbol is locked', 
      RANK_TOO_LOW => 'Rule or symbol rank too low', 
      RANK_TOO_HIGH => 'Rule or symbol rank too high', 
      SYMBOL_IS_NULLING => 'code 87', 
      SYMBOL_IS_UNUSED => 'Symbol is not used', 
      NO_SUCH_RULE_ID => 'No rule with this ID exists', 
      NO_SUCH_SYMBOL_ID => 'No symbol with this ID exists', 
      BEFORE_FIRST_TREE => 'Tree iterator is before first tree', 
      SYMBOL_IS_NOT_COMPLETION_EVENT => 'Symbol is not seet up for completion events', 
      SYMBOL_IS_NOT_NULLED_EVENT => 'Symbol is not set up for nulled events', 
      SYMBOL_IS_NOT_PREDICTION_EVENT => 'Symbol is not set up for prediction events', 
      RECCE_IS_INCONSISTENT => 'The recognizer is inconsistent', 
      INVALID_ASSERTION_ID => 'Assertion ID is malformed', 
      NO_SUCH_ASSERTION_ID => 'No assertion with this ID exists', 
      HEADERS_DO_NOT_MATCH => 'Internal error: Libmarpa was built incorrectly', 
      NOT_A_SEQUENCE => 'Rule is not a sequence', 
    }
  end # module Error

  #line 1 "./marpa.h-event"
  module Event
    COUNT = 10
    NONE = 0
    COUNTED_NULLABLE = 1
    EARLEY_ITEM_THRESHOLD = 2
    EXHAUSTED = 3
    LOOP_RULES = 4
    NULLING_TERMINAL = 5
    SYMBOL_COMPLETED = 6
    SYMBOL_EXPECTED = 7
    SYMBOL_NULLED = 8
    SYMBOL_PREDICTED = 9

    Message = {
      NONE => 'No event', 
      COUNTED_NULLABLE => 'This symbols is a counted nullable', 
      EARLEY_ITEM_THRESHOLD => 'Too many Earley items', 
      EXHAUSTED => 'Recognizer is exhausted', 
      LOOP_RULES => 'Grammar contains an infinite loop', 
      NULLING_TERMINAL => 'This symbol is a nulling terminal', 
      SYMBOL_COMPLETED => 'Completed symbol', 
      SYMBOL_EXPECTED => 'Expecting symbol', 
      SYMBOL_NULLED => 'Symbol was nulled', 
      SYMBOL_PREDICTED => 'Symbol was predicted', 
    }
  end # module Event

  #line 1 "./marpa.h-step"
  module Step
    COUNT = 8
    INTERNAL1 = 0
    RULE = 1
    TOKEN = 2
    NULLING_SYMBOL = 3
    TRACE = 4
    INACTIVE = 5
    INTERNAL2 = 6
    INITIAL = 7
  end # module Step
#
#/*1344:*/
##line 16251 "./marpa.w"
#
#extern const int marpa_major_version;
#extern const int marpa_minor_version;
#extern const int marpa_micro_version;
#
#/*109:*/
##line 1026 "./marpa.w"
#
##define marpa_g_event_value(event) \
#    ((event)->t_value)
#/*:109*//*295:*/
##line 2708 "./marpa.w"
#
  KEEP_SEPARATION = 1
  PROPER_SEPARATION = 2
##define MARPA_KEEP_SEPARATION  0x1
#/*:295*//*299:*/
##line 2748 "./marpa.w"
#
##define MARPA_PROPER_SEPARATION  0x2
#/*:299*//*1046:*/
##line 12433 "./marpa.w"
#
##define marpa_v_step_type(v) ((v)->t_step_type)
##define marpa_v_token(v) \
#    ((v)->t_token_id)
##define marpa_v_symbol(v) marpa_v_token(v)
##define marpa_v_token_value(v) \
#    ((v)->t_token_value)
##define marpa_v_rule(v) \
#    ((v)->t_rule_id)
##define marpa_v_arg_0(v) \
#    ((v)->t_arg_0)
##define marpa_v_arg_n(v) \
#    ((v)->t_arg_n)
##define marpa_v_result(v) \
#    ((v)->t_result)
##define marpa_v_rule_start_es_id(v) ((v)->t_rule_start_ys_id)
##define marpa_v_token_start_es_id(v) ((v)->t_token_start_ys_id)
##define marpa_v_es_id(v) ((v)->t_ys_id)
#
#/*:1046*/
##line 16256 "./marpa.w"
#
#/*47:*/
##line 650 "./marpa.w"
#
  typedef :pointer, :Marpa_Grammar
  typedef :pointer, :Marpa_Recognizer
  typedef :pointer, :Marpa_Bocage
  typedef :pointer, :Marpa_Order
  typedef :pointer, :Marpa_Tree
  typedef :pointer, :Marpa_Value
#struct marpa_g;
#struct marpa_avl_table;
#typedef struct marpa_g* Marpa_Grammar;
#/*:47*//*544:*/
##line 5956 "./marpa.w"
#
#struct marpa_r;
#typedef struct marpa_r*Marpa_Recognizer;
#typedef Marpa_Recognizer Marpa_Recce;
#/*:544*//*928:*/
##line 11037 "./marpa.w"
#
#struct marpa_bocage;
#typedef struct marpa_bocage*Marpa_Bocage;
#/*:928*//*964:*/
##line 11359 "./marpa.w"
#
#struct marpa_order;
#typedef struct marpa_order*Marpa_Order;
#/*:964*//*965:*/
##line 11362 "./marpa.w"
#
#typedef Marpa_Order ORDER;
#/*:965*//*1002:*/
##line 11897 "./marpa.w"
#
#struct marpa_tree;
#typedef struct marpa_tree*Marpa_Tree;
#/*:1002*//*1041:*/
##line 12389 "./marpa.w"
#
#struct marpa_value;
#typedef struct marpa_value*Marpa_Value;
#/*:1041*/
##line 16257 "./marpa.w"
#
#/*91:*/
##line 919 "./marpa.w"
#
#/*:91*//*108:*/
##line 1023 "./marpa.w"
#
#struct marpa_event;

  typedef :int, :Marpa_Rank
  typedef :int, :Marpa_Event_Type
  typedef :int, :Marpa_Error_Code
  typedef :int, :Marpa_Symbol_ID
  typedef :int, :Marpa_NSY_ID
  typedef :int, :Marpa_Rule_ID
  typedef :int, :Marpa_IRL_ID
  typedef :int, :Marpa_AHM_ID
  typedef :int, :Marpa_Assertion_ID
  typedef :int, :Marpa_Earleme
  typedef :int, :Marpa_Earley_Set_ID
  typedef :int, :Marpa_Earley_Item_ID
  typedef :int, :Marpa_Step_Type


#typedef int Marpa_Or_Node_ID;
#/*:867*//*921:*/
##line 10972 "./marpa.w"
#
#typedef int Marpa_And_Node_ID;
#/*:921*//*1036:*/
##line 12342 "./marpa.w"
#
#typedef int Marpa_Nook_ID;
#/*:1036*//*1084:*/
##line 12833 "./marpa.w"
#
#/*:1084*//*1230:*/
##line 14798 "./marpa.w"
#
#typedef const char*Marpa_Message_ID;
#
#/*:1230*/
##line 16258 "./marpa.w"
#
#/*44:*/
##line 610 "./marpa.w"
#
#struct marpa_config{
#int t_is_ok;
#Marpa_Error_Code t_error;
#const char*t_error_string;
#};
#typedef struct marpa_config Marpa_Config;
  class Marpa_Config < FFI::Struct
    layout :t_is_ok, :int, 
           :t_error, :Marpa_Error_Code, 
           :t_error_string, :string
  end
#
#/*:44*//*110:*/
##line 1029 "./marpa.w"
#
#struct marpa_event{
#Marpa_Event_Type t_type;
#int t_value;
#};
#typedef struct marpa_event Marpa_Event;
  class Marpa_Event < FFI::Struct
    layout :t_type,  :Marpa_Event_Type, 
           :t_value, :int
  end
#/*:110*//*821:*/
##line 9563 "./marpa.w"
#
#struct marpa_progress_item{
#Marpa_Rule_ID t_rule_id;
#int t_position;
#int t_origin;
#};
#
#/*:821*//*1045:*/
##line 12419 "./marpa.w"
#
#struct marpa_value{
#Marpa_Step_Type t_step_type;
#Marpa_Symbol_ID t_token_id;
#int t_token_value;
#Marpa_Rule_ID t_rule_id;
#int t_arg_0;
#int t_arg_n;
#int t_result;
#Marpa_Earley_Set_ID t_token_start_ys_id;
#Marpa_Earley_Set_ID t_rule_start_ys_id;
#Marpa_Earley_Set_ID t_ys_id;
#};
  class Marpa_Value < FFI::Struct
    layout :t_step_type, :Marpa_Step_Type,
           :t_token_id, :Marpa_Symbol_ID,
           :t_token_value, :int,
           :t_rule_id, :Marpa_Rule_ID,
           :t_arg_0, :int,
           :t_arg_n, :int,
           :t_result, :int,
           :t_token_start_ys_id, :Marpa_Earley_Set_ID,
           :t_rule_start_ys_id, :Marpa_Earley_Set_ID,
           :t_ys_id, :Marpa_Earley_Set_ID
  end
#/*:1045*/
##line 16259 "./marpa.w"
#
#/*1229:*/
##line 14795 "./marpa.w"
#
#extern void*(*const marpa__out_of_memory)(void);
#
#/*:1229*//*1321:*/
##line 16056 "./marpa.w"
#
#extern int marpa__default_debug_handler(const char*format,...);
#extern int(*marpa__debug_handler)(const char*,...);
#extern int marpa__debug_level;
#
#/*:1321*/
##line 16260 "./marpa.w"
#


  #line 1 "./marpa.h.p80"
  attach_function :marpa_check_version, [ :int, :int, :int ], :Marpa_Error_Code
  attach_function :marpa_version, [ :pointer ], :Marpa_Error_Code 
  attach_function :marpa_c_init, [ :pointer ], :int 
  attach_function :marpa_c_error, [ :pointer, :pointer ], :Marpa_Error_Code 
  attach_function :marpa_g_new, [ :pointer ], :Marpa_Grammar 
  attach_function :marpa_g_force_valued, [ :Marpa_Grammar ], :int 
  attach_function :marpa_g_ref, [ :Marpa_Grammar ], :Marpa_Grammar 
  attach_function :marpa_g_unref, [ :Marpa_Grammar ], :void 
  attach_function :marpa_g_start_symbol, [ :Marpa_Grammar ], :Marpa_Symbol_ID 
  attach_function :marpa_g_start_symbol_set, [ :Marpa_Grammar, :Marpa_Symbol_ID ], :Marpa_Symbol_ID 
  attach_function :marpa_g_highest_symbol_id, [ :Marpa_Grammar ], :int
  attach_function :marpa_g_symbol_is_accessible, [ :Marpa_Grammar, :Marpa_Symbol_ID ], :int
  attach_function :marpa_g_symbol_is_nullable, [ :Marpa_Grammar, :Marpa_Symbol_ID], :int 
  attach_function :marpa_g_symbol_is_nulling, [ :Marpa_Grammar, :Marpa_Symbol_ID], :int 
  attach_function :marpa_g_symbol_is_productive, [ :Marpa_Grammar, :Marpa_Symbol_ID], :int 
  attach_function :marpa_g_symbol_is_start, [ :Marpa_Grammar, :Marpa_Symbol_ID], :int 
  attach_function :marpa_g_symbol_is_terminal_set, [ :Marpa_Grammar, :Marpa_Symbol_ID, :int ], :int 
  attach_function :marpa_g_symbol_is_terminal, [ :Marpa_Grammar, :Marpa_Symbol_ID], :int 
  attach_function :marpa_g_symbol_new, [ :Marpa_Grammar], :Marpa_Symbol_ID 
  attach_function :marpa_g_highest_rule_id, [ :Marpa_Grammar], :int 
  attach_function :marpa_g_rule_is_accessible, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  attach_function :marpa_g_rule_is_nullable, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  attach_function :marpa_g_rule_is_nulling, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  attach_function :marpa_g_rule_is_loop, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  attach_function :marpa_g_rule_is_productive, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  attach_function :marpa_g_rule_length, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  attach_function :marpa_g_rule_lhs, [ :Marpa_Grammar, :Marpa_Rule_ID], :Marpa_Symbol_ID 
  attach_function :marpa_g_rule_new, [ :Marpa_Grammar, :Marpa_Symbol_ID, :pointer, :int], :Marpa_Rule_ID 
  attach_function :marpa_g_rule_rhs, [ :Marpa_Grammar, :Marpa_Rule_ID, :int], :Marpa_Symbol_ID 
  attach_function :marpa_g_rule_is_proper_separation, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  attach_function :marpa_g_sequence_min, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  attach_function :marpa_g_sequence_new, [ :Marpa_Grammar, :Marpa_Symbol_ID, :Marpa_Symbol_ID, :Marpa_Symbol_ID, :int, :int ], :Marpa_Rule_ID 
  attach_function :marpa_g_sequence_separator, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  attach_function :marpa_g_symbol_is_counted, [ :Marpa_Grammar, :Marpa_Symbol_ID], :int 
  attach_function :marpa_g_rule_rank_set, [ :Marpa_Grammar, :Marpa_Rule_ID, :Marpa_Rank], :Marpa_Rank 
  attach_function :marpa_g_rule_rank, [ :Marpa_Grammar, :Marpa_Rule_ID], :Marpa_Rank 
  attach_function :marpa_g_rule_null_high_set, [ :Marpa_Grammar, :Marpa_Rule_ID, :int], :int 
  attach_function :marpa_g_rule_null_high, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  attach_function :marpa_g_completion_symbol_activate, [ :Marpa_Grammar, :Marpa_Symbol_ID, :int ], :int 
  attach_function :marpa_g_nulled_symbol_activate, [ :Marpa_Grammar, :Marpa_Symbol_ID, :int ], :int 
  attach_function :marpa_g_prediction_symbol_activate, [ :Marpa_Grammar, :Marpa_Symbol_ID, :int ], :int 
  attach_function :marpa_g_symbol_is_completion_event, [ :Marpa_Grammar, :Marpa_Symbol_ID], :int 
  attach_function :marpa_g_symbol_is_completion_event_set, [ :Marpa_Grammar, :Marpa_Symbol_ID, :int], :int 
  attach_function :marpa_g_symbol_is_nulled_event, [ :Marpa_Grammar, :Marpa_Symbol_ID], :int 
  attach_function :marpa_g_symbol_is_nulled_event_set, [ :Marpa_Grammar, :Marpa_Symbol_ID, :int], :int 
  attach_function :marpa_g_symbol_is_prediction_event, [ :Marpa_Grammar, :Marpa_Symbol_ID], :int 
  attach_function :marpa_g_symbol_is_prediction_event_set, [ :Marpa_Grammar, :Marpa_Symbol_ID, :int], :int 
  attach_function :marpa_g_precompute, [ :Marpa_Grammar], :int 
  attach_function :marpa_g_is_precomputed, [ :Marpa_Grammar], :int 
  attach_function :marpa_g_has_cycle, [ :Marpa_Grammar], :int 
  attach_function :marpa_r_new, [ :Marpa_Grammar ], :Marpa_Recognizer 
  attach_function :marpa_r_ref, [ :Marpa_Recognizer], :Marpa_Recognizer 
  attach_function :marpa_r_unref, [ :Marpa_Recognizer], :void 
  attach_function :marpa_r_start_input, [ :Marpa_Recognizer], :int 
  attach_function :marpa_r_alternative, [ :Marpa_Recognizer, :Marpa_Symbol_ID, :int, :int], :int 
  attach_function :marpa_r_earleme_complete, [ :Marpa_Recognizer], :int 
  attach_function :marpa_r_current_earleme, [ :Marpa_Recognizer], :Marpa_Earleme 
  attach_function :marpa_r_earleme, [ :Marpa_Recognizer, :Marpa_Earley_Set_ID], :Marpa_Earleme 
  attach_function :marpa_r_earley_set_value, [ :Marpa_Recognizer, :Marpa_Earley_Set_ID], :int 
  attach_function :marpa_r_earley_set_values, [ :Marpa_Recognizer, :Marpa_Earley_Set_ID, :pointer, :pointer ], :int 
  attach_function :marpa_r_furthest_earleme, [ :Marpa_Recognizer ], :uint
  attach_function :marpa_r_latest_earley_set, [ :Marpa_Recognizer ], :Marpa_Earley_Set_ID 
  attach_function :marpa_r_latest_earley_set_value_set, [ :Marpa_Recognizer, :int], :int 
  attach_function :marpa_r_latest_earley_set_values_set, [ :Marpa_Recognizer, :int, :pointer], :int 
  attach_function :marpa_r_completion_symbol_activate, [ :Marpa_Recognizer, :Marpa_Symbol_ID, :int ], :int 
  attach_function :marpa_r_earley_item_warning_threshold_set, [ :Marpa_Recognizer, :int], :int 
  attach_function :marpa_r_earley_item_warning_threshold, [ :Marpa_Recognizer], :int 
  attach_function :marpa_r_expected_symbol_event_set, [ :Marpa_Recognizer, :Marpa_Symbol_ID, :int], :int 
  attach_function :marpa_r_is_exhausted, [ :Marpa_Recognizer], :int 
  attach_function :marpa_r_nulled_symbol_activate, [ :Marpa_Recognizer, :Marpa_Symbol_ID, :int ], :int 
  attach_function :marpa_r_prediction_symbol_activate, [ :Marpa_Recognizer, :Marpa_Symbol_ID, :int ], :int 
  attach_function :marpa_r_terminals_expected, [ :Marpa_Recognizer, :pointer], :int 
  attach_function :marpa_r_terminal_is_expected, [ :Marpa_Recognizer, :Marpa_Symbol_ID], :int 
  attach_function :marpa_r_progress_report_reset, [ :Marpa_Recognizer], :int 
  attach_function :marpa_r_progress_report_start, [ :Marpa_Recognizer, :Marpa_Earley_Set_ID], :int 
  attach_function :marpa_r_progress_report_finish, [ :Marpa_Recognizer ], :int 
  attach_function :marpa_r_progress_item, [ :Marpa_Recognizer, :pointer, :pointer ], :Marpa_Rule_ID 
  attach_function :marpa_b_new, [ :Marpa_Recognizer, :Marpa_Earley_Set_ID], :Marpa_Bocage 
  attach_function :marpa_b_ref, [ :Marpa_Bocage], :Marpa_Bocage 
  attach_function :marpa_b_unref, [ :Marpa_Bocage], :void 
  attach_function :marpa_b_ambiguity_metric, [ :Marpa_Bocage], :int 
  attach_function :marpa_b_is_null, [ :Marpa_Bocage], :int 
  attach_function :marpa_o_new, [ :Marpa_Bocage], :Marpa_Order 
  attach_function :marpa_o_ref, [ :Marpa_Order], :Marpa_Order 
  attach_function :marpa_o_unref, [ :Marpa_Order], :void 
  attach_function :marpa_o_ambiguity_metric, [ :Marpa_Order], :int 
  attach_function :marpa_o_is_null, [ :Marpa_Order], :int 
  attach_function :marpa_o_high_rank_only_set, [ :Marpa_Order, :int], :int 
  attach_function :marpa_o_high_rank_only, [ :Marpa_Order], :int 
  attach_function :marpa_o_rank, [ :Marpa_Order ], :int 
  attach_function :marpa_t_new, [ :Marpa_Order], :Marpa_Tree 
  attach_function :marpa_t_ref, [ :Marpa_Tree], :Marpa_Tree 
  attach_function :marpa_t_unref, [ :Marpa_Tree], :void 
  attach_function :marpa_t_next, [ :Marpa_Tree], :int 
  attach_function :marpa_t_parse_count, [ :Marpa_Tree], :int 
  attach_function :marpa_v_new, [ :Marpa_Tree ], :Marpa_Value 
  attach_function :marpa_v_ref, [ :Marpa_Value], :Marpa_Value 
  attach_function :marpa_v_unref, [ :Marpa_Value], :void 
  attach_function :marpa_v_step, [ :Marpa_Value], :Marpa_Step_Type 
  attach_function :marpa_g_event, [ :Marpa_Grammar, :pointer, :int], :Marpa_Event_Type 
  attach_function :marpa_g_event_count, [ :Marpa_Grammar ], :int 
  attach_function :marpa_g_error, [ :Marpa_Grammar, :pointer ], :Marpa_Error_Code 
  attach_function :marpa_g_error_clear, [ :Marpa_Grammar ], :Marpa_Error_Code 
  attach_function :marpa_g_default_rank_set, [ :Marpa_Grammar, :Marpa_Rank], :Marpa_Rank 
  attach_function :marpa_g_default_rank, [ :Marpa_Grammar], :Marpa_Rank 
  attach_function :marpa_g_symbol_rank_set, [ :Marpa_Grammar, :Marpa_Symbol_ID, :Marpa_Rank], :Marpa_Rank #here
  attach_function :marpa_g_symbol_rank, [ :Marpa_Grammar, :Marpa_Symbol_ID], :Marpa_Rank 
  attach_function :marpa_g_zwa_new, [ :Marpa_Grammar, :int ], :Marpa_Assertion_ID 
  attach_function :marpa_g_zwa_place, [ :Marpa_Grammar, :Marpa_Assertion_ID, :Marpa_Rule_ID, :int ], :int 
  attach_function :marpa_r_zwa_default, [ :Marpa_Recognizer, :Marpa_Assertion_ID ], :int 
  attach_function :marpa_r_zwa_default_set, [ :Marpa_Recognizer, :Marpa_Assertion_ID, :int ], :int 
  attach_function :marpa_g_highest_zwa_id, [ :Marpa_Grammar ], :Marpa_Assertion_ID 
  attach_function :marpa_r_clean, [ :Marpa_Recognizer], :Marpa_Earleme 
  attach_function :marpa_g_symbol_is_valued_set, [ :Marpa_Grammar, :Marpa_Symbol_ID, :int ], :int 
  attach_function :marpa_g_symbol_is_valued, [ :Marpa_Grammar, :Marpa_Symbol_ID ], :int 
  attach_function :marpa_v_symbol_is_valued_set, [ :Marpa_Value, :Marpa_Symbol_ID, :int ], :int 
  attach_function :marpa_v_symbol_is_valued, [ :Marpa_Value, :Marpa_Symbol_ID ], :int 
  attach_function :marpa_v_rule_is_valued_set, [ :Marpa_Value, :Marpa_Rule_ID, :int ], :int 
  attach_function :marpa_v_rule_is_valued, [ :Marpa_Value, :Marpa_Rule_ID ], :int 
  attach_function :marpa_v_valued_force, [ :Marpa_Value], :int 

  #internal:attach_function :_marpa_g_nsy_is_start, [ :Marpa_Grammar, :Marpa_NSY_ID nsy_id], :int 
  #internal:attach_function :_marpa_g_nsy_is_nulling, [ :Marpa_Grammar, :Marpa_NSY_ID nsy_id], :int 
  #internal:attach_function :_marpa_g_nsy_is_lhs, [ :Marpa_Grammar, :Marpa_NSY_ID nsy_id], :int 
  #internal:attach_function :_marpa_g_xsy_nulling_nsy, [ :Marpa_Grammar, :Marpa_Symbol_ID symid], :Marpa_NSY_ID 
  #internal:attach_function :_marpa_g_xsy_nsy, [ :Marpa_Grammar, :Marpa_Symbol_ID symid], :Marpa_NSY_ID 
  #internal:attach_function :_marpa_g_nsy_is_semantic, [ :Marpa_Grammar, :Marpa_NSY_ID nsy_id], :int 
  #internal:attach_function :_marpa_g_source_xsy, [ :Marpa_Grammar, :Marpa_NSY_ID nsy_id], :Marpa_Rule_ID 
  #internal:attach_function :_marpa_g_nsy_lhs_xrl, [ :Marpa_Grammar, :Marpa_NSY_ID nsy_id], :Marpa_Rule_ID 
  #internal:attach_function :_marpa_g_nsy_xrl_offset, [ :Marpa_Grammar, :Marpa_NSY_ID nsy_id ], :int 
  #internal:attach_function :_marpa_g_rule_is_keep_separation, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  #internal:attach_function :_marpa_g_nsy_count, [ :Marpa_Grammar], :int 
  #internal:attach_function :_marpa_g_irl_count, [ :Marpa_Grammar], :int 
  #internal:attach_function :_marpa_g_irl_lhs, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_g_irl_length, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id], :int 
  #internal:attach_function :_marpa_g_irl_rhs, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id, int ix], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_g_rule_is_used, [ :Marpa_Grammar, :Marpa_Rule_ID], :int 
  #internal:attach_function :_marpa_g_irl_is_virtual_lhs, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id], :int 
  #internal:attach_function :_marpa_g_irl_is_virtual_rhs, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id], :int 
  #internal:attach_function :_marpa_g_virtual_start, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id], :int 
  #internal:attach_function :_marpa_g_virtual_end, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id], :int 
  #internal:attach_function :_marpa_g_source_xrl, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id], :Marpa_Rule_ID 
  #internal:attach_function :_marpa_g_real_symbol_count, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id], :int 
  #internal:attach_function :_marpa_g_irl_semantic_equivalent, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id], :Marpa_Rule_ID 
  #internal:attach_function :_marpa_g_irl_rank, [ :Marpa_Grammar, :Marpa_IRL_ID irl_id], :Marpa_Rank 
  #internal:attach_function :_marpa_g_nsy_rank, [ :Marpa_Grammar, :Marpa_IRL_ID nsy_id], :Marpa_Rank 
  #internal:attach_function :_marpa_g_ahm_count, [ :Marpa_Grammar], :int 
  #internal:attach_function :_marpa_g_ahm_irl, [ :Marpa_Grammar, :Marpa_AHM_ID item_id], :Marpa_Rule_ID 
  #internal:attach_function :_marpa_g_ahm_position, [ :Marpa_Grammar, :Marpa_AHM_ID item_id], :int 
  #internal:attach_function :_marpa_g_ahm_postdot, [ :Marpa_Grammar, :Marpa_AHM_ID item_id], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_is_use_leo, [ :Marpa_Recognizer], :int 
  #internal:attach_function :_marpa_r_is_use_leo_set, [ :Marpa_Recognizer, int value], :int 
  #internal:attach_function :_marpa_r_trace_earley_set, [ :Marpa_Recognizer], :Marpa_Earley_Set_ID 
  #internal:attach_function :_marpa_r_earley_set_size, [ :Marpa_Recognizer, :Marpa_Earley_Set_ID set_id], :int 
  #internal:attach_function :_marpa_r_earley_set_trace, [ :Marpa_Recognizer, :Marpa_Earley_Set_ID set_id], :Marpa_Earleme 
  #internal:attach_function :_marpa_r_earley_item_trace, [ :Marpa_Recognizer, :Marpa_Earley_Item_ID item_id], :Marpa_AHM_ID 
  #internal:attach_function :_marpa_r_earley_item_origin, [ :Marpa_Recognizer], :Marpa_Earley_Set_ID 
  #internal:attach_function :_marpa_r_leo_predecessor_symbol, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_leo_base_origin, [ :Marpa_Recognizer], :Marpa_Earley_Set_ID 
  #internal:attach_function :_marpa_r_leo_base_state, [ :Marpa_Recognizer], :Marpa_AHM_ID 
  #internal:attach_function :_marpa_r_postdot_symbol_trace, [ :Marpa_Recognizer, :Marpa_Symbol_ID symid], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_first_postdot_item_trace, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_next_postdot_item_trace, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_postdot_item_symbol, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_first_token_link_trace, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_next_token_link_trace, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_first_completion_link_trace, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_next_completion_link_trace, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_first_leo_link_trace, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_next_leo_link_trace, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_source_predecessor_state, [ :Marpa_Recognizer], :Marpa_AHM_ID 
  #internal:attach_function :_marpa_r_source_token, [ :Marpa_Recognizer, :pointer value_p], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_source_leo_transition_symbol, [ :Marpa_Recognizer], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_r_source_middle, [ :Marpa_Recognizer], :Marpa_Earley_Set_ID 
  #internal:attach_function :_marpa_b_and_node_count, [ :Marpa_Bocage], :int 
  #internal:attach_function :_marpa_b_and_node_middle, [ :Marpa_Bocage, :Marpa_And_Node_ID and_node_id], :Marpa_Earley_Set_ID 
  #internal:attach_function :_marpa_b_and_node_parent, [ :Marpa_Bocage, :Marpa_And_Node_ID and_node_id], :int 
  #internal:attach_function :_marpa_b_and_node_predecessor, [ :Marpa_Bocage, :Marpa_And_Node_ID and_node_id], :int 
  #internal:attach_function :_marpa_b_and_node_cause, [ :Marpa_Bocage, :Marpa_And_Node_ID and_node_id], :int 
  #internal:attach_function :_marpa_b_and_node_symbol, [ :Marpa_Bocage, :Marpa_And_Node_ID and_node_id], :int 
  #internal:attach_function :_marpa_b_and_node_token, [ :Marpa_Bocage, :Marpa_And_Node_ID and_node_id, :pointer value_p], :Marpa_Symbol_ID 
  #internal:attach_function :_marpa_b_top_or_node, [ :Marpa_Bocage], :Marpa_Or_Node_ID 
  #internal:attach_function :_marpa_b_or_node_set, [ :Marpa_Bocage, :Marpa_Or_Node_ID or_node_id], :int 
  #internal:attach_function :_marpa_b_or_node_origin, [ :Marpa_Bocage, :Marpa_Or_Node_ID or_node_id], :int 
  #internal:attach_function :_marpa_b_or_node_irl, [ :Marpa_Bocage, :Marpa_Or_Node_ID or_node_id], :Marpa_IRL_ID 
  #internal:attach_function :_marpa_b_or_node_position, [ :Marpa_Bocage, :Marpa_Or_Node_ID or_node_id], :int 
  #internal:attach_function :_marpa_b_or_node_is_whole, [ :Marpa_Bocage, :Marpa_Or_Node_ID or_node_id], :int 
  #internal:attach_function :_marpa_b_or_node_is_semantic, [ :Marpa_Bocage, :Marpa_Or_Node_ID or_node_id], :int 
  #internal:attach_function :_marpa_b_or_node_first_and, [ :Marpa_Bocage, :Marpa_Or_Node_ID or_node_id], :int 
  #internal:attach_function :_marpa_b_or_node_last_and, [ :Marpa_Bocage, :Marpa_Or_Node_ID or_node_id], :int 
  #internal:attach_function :_marpa_b_or_node_and_count, [ :Marpa_Bocage, :Marpa_Or_Node_ID or_node_id], :int 
  #internal:attach_function :_marpa_o_and_order_get, [ :Marpa_Order, :Marpa_Or_Node_ID or_node_id, int ix], :Marpa_And_Node_ID 
  #internal:attach_function :_marpa_o_or_node_and_node_count, [ :Marpa_Order, :Marpa_Or_Node_ID or_node_id], :int 
  #internal:attach_function :_marpa_o_or_node_and_node_id_by_ix, [ :Marpa_Order, :Marpa_Or_Node_ID or_node_id, int ix], :int 
  #internal:attach_function :_marpa_t_size, [ :Marpa_Tree], :int 
  #internal:attach_function :_marpa_t_nook_or_node, [ :Marpa_Tree, :Marpa_Nook_ID nook_id], :Marpa_Or_Node_ID 
  #internal:attach_function :_marpa_t_nook_choice, [ :Marpa_Tree, :Marpa_Nook_ID nook_id ], :int 
  #internal:attach_function :_marpa_t_nook_parent, [ :Marpa_Tree, :Marpa_Nook_ID nook_id ], :int 
  #internal:attach_function :_marpa_t_nook_cause_is_ready, [ :Marpa_Tree, :Marpa_Nook_ID nook_id ], :int 
  #internal:attach_function :_marpa_t_nook_predecessor_is_ready, [ :Marpa_Tree, :Marpa_Nook_ID nook_id ], :int 
  #internal:attach_function :_marpa_t_nook_is_cause, [ :Marpa_Tree, :Marpa_Nook_ID nook_id ], :int 
  #internal:attach_function :_marpa_t_nook_is_predecessor, [ :Marpa_Tree, :Marpa_Nook_ID nook_id ], :int 
  #internal:attach_function :_marpa_v_trace, [ :Marpa_Value, int flag], :int 
  #internal:attach_function :_marpa_v_nook, [ :Marpa_Value], :Marpa_Nook_ID 
  #internal:attach_function :_marpa_tag, [void], :pointer

  #debug:attach_function :marpa_debug_level_set, [ int level ], :int 
  #debug:attach_function :marpa_debug_handler_set, ( int (*debug_handler)[const char*, ...] ), :void 

  # version check before we declare success
  if Error::NONE != marpa_check_version(MARPA_MAJOR_VERSION, MARPA_MINOR_VERSION, MARPA_MICRO_VERSION)
    raise LoadError, "libmarpa version check failed."
  end

end  # module LibMarpa

