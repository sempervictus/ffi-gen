# Generated by ffi-gen. Please do not change this file by hand.

require 'ffi'

module CEF
  extend FFI::Library
  ffi_lib 'cef'
  
  def self.attach_function(name, *_)
    begin; super; rescue FFI::NotFoundError => e
      (class << self; self; end).class_eval { define_method(name) { |*_| raise e } }
    end
  end
  
  # (Not documented)
  class CefV8handlerT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  # 
  # @method register_extension(extension_name, javascript_code, handler)
  # @param [FFI::Pointer(*StringT)] extension_name 
  # @param [FFI::Pointer(*StringT)] javascript_code 
  # @param [CefV8handlerT] handler 
  # @return [Integer] 
  # @scope class
  attach_function :register_extension, :cef_register_extension, [:pointer, :pointer, CefV8handlerT], :int
  
  # (Not documented)
  class CefBrowserT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefFrameT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefV8exceptionT < FFI::Struct
    layout :dummy, :char
  end
  
  # ///
  # 
  # = Fields:
  # :base ::
  #   (unknown) ///
  # :get_browser ::
  #   (FFI::Pointer(*)) ///
  # :get_frame ::
  #   (FFI::Pointer(*)) ///
  # :get_global ::
  #   (FFI::Pointer(*)) ///
  # :enter ::
  #   (FFI::Pointer(*)) ///
  # :exit ::
  #   (FFI::Pointer(*)) ///
  # :is_same ::
  #   (FFI::Pointer(*)) ///
  # :eval ::
  #   (FFI::Pointer(*)) ///
  class CefV8contextT < FFI::Struct
    layout :base, :char,
           :get_browser, :pointer,
           :get_frame, :pointer,
           :get_global, :pointer,
           :enter, :pointer,
           :exit, :pointer,
           :is_same, :pointer,
           :eval, :pointer
  end
  
  # (Not documented)
  # 
  # @method v8context_get_current_context()
  # @return [CefV8contextT] 
  # @scope class
  attach_function :v8context_get_current_context, :cef_v8context_get_current_context, [], CefV8contextT
  
  # (Not documented)
  # 
  # @method v8context_get_entered_context()
  # @return [CefV8contextT] 
  # @scope class
  attach_function :v8context_get_entered_context, :cef_v8context_get_entered_context, [], CefV8contextT
  
  # (Not documented)
  # 
  # @method v8context_in_context()
  # @return [Integer] 
  # @scope class
  attach_function :v8context_in_context, :cef_v8context_in_context, [], :int
  
  # ///
  # 
  # = Fields:
  # :base ::
  #   (unknown) ///
  # :execute ::
  #   (FFI::Pointer(*)) ///
  class CefV8handlerT < FFI::Struct
    layout :base, :char,
           :execute, :pointer
  end
  
  # ///
  # 
  # = Fields:
  # :base ::
  #   (unknown) ///
  # :get ::
  #   (FFI::Pointer(*)) ///
  # :set ::
  #   (FFI::Pointer(*)) ///
  class CefV8accessorT < FFI::Struct
    layout :base, :char,
           :get, :pointer,
           :set, :pointer
  end
  
  # ///
  # 
  # = Fields:
  # :base ::
  #   (unknown) ///
  # :get_message ::
  #   (FFI::Pointer(*)) // The resulting string must be freed by calling cef_string_userfree_free().
  # :get_source_line ::
  #   (FFI::Pointer(*)) // The resulting string must be freed by calling cef_string_userfree_free().
  # :get_script_resource_name ::
  #   (FFI::Pointer(*)) // The resulting string must be freed by calling cef_string_userfree_free().
  # :get_line_number ::
  #   (FFI::Pointer(*)) ///
  # :get_start_position ::
  #   (FFI::Pointer(*)) ///
  # :get_end_position ::
  #   (FFI::Pointer(*)) ///
  # :get_start_column ::
  #   (FFI::Pointer(*)) ///
  # :get_end_column ::
  #   (FFI::Pointer(*)) ///
  class CefV8exceptionT < FFI::Struct
    layout :base, :char,
           :get_message, :pointer,
           :get_source_line, :pointer,
           :get_script_resource_name, :pointer,
           :get_line_number, :pointer,
           :get_start_position, :pointer,
           :get_end_position, :pointer,
           :get_start_column, :pointer,
           :get_end_column, :pointer
  end
  
  # ///
  # 
  # = Fields:
  # :base ::
  #   (unknown) ///
  # :is_undefined ::
  #   (FFI::Pointer(*)) ///
  # :is_null ::
  #   (FFI::Pointer(*)) ///
  # :is_bool ::
  #   (FFI::Pointer(*)) ///
  # :is_int ::
  #   (FFI::Pointer(*)) ///
  # :is_uint ::
  #   (FFI::Pointer(*)) ///
  # :is_double ::
  #   (FFI::Pointer(*)) ///
  # :is_date ::
  #   (FFI::Pointer(*)) ///
  # :is_string ::
  #   (FFI::Pointer(*)) ///
  # :is_object ::
  #   (FFI::Pointer(*)) ///
  # :is_array ::
  #   (FFI::Pointer(*)) ///
  # :is_function ::
  #   (FFI::Pointer(*)) ///
  # :is_same ::
  #   (FFI::Pointer(*)) ///
  # :get_bool_value ::
  #   (FFI::Pointer(*)) ///
  # :get_int_value ::
  #   (FFI::Pointer(*)) ///
  # :get_uint_value ::
  #   (FFI::Pointer(*)) ///
  # :get_double_value ::
  #   (FFI::Pointer(*)) ///
  # :get_date_value ::
  #   (FFI::Pointer(*)) ///
  # :get_string_value ::
  #   (FFI::Pointer(*)) // The resulting string must be freed by calling cef_string_userfree_free().
  # :is_user_created ::
  #   (FFI::Pointer(*)) ///
  # :has_exception ::
  #   (FFI::Pointer(*)) ///
  # :get_exception ::
  #   (FFI::Pointer(*)) ///
  # :clear_exception ::
  #   (FFI::Pointer(*)) ///
  # :will_rethrow_exceptions ::
  #   (FFI::Pointer(*)) ///
  # :set_rethrow_exceptions ::
  #   (FFI::Pointer(*)) ///
  # :has_value_bykey ::
  #   (FFI::Pointer(*)) ///
  # :has_value_byindex ::
  #   (FFI::Pointer(*)) ///
  # :delete_value_bykey ::
  #   (FFI::Pointer(*)) ///
  # :delete_value_byindex ::
  #   (FFI::Pointer(*)) ///
  # :get_value_bykey ::
  #   (FFI::Pointer(*)) ///
  # :get_value_byindex ::
  #   (FFI::Pointer(*)) ///
  # :set_value_bykey ::
  #   (FFI::Pointer(*)) ///
  # :set_value_byindex ::
  #   (FFI::Pointer(*)) ///
  # :set_value_byaccessor ::
  #   (FFI::Pointer(*)) ///
  # :get_keys ::
  #   (FFI::Pointer(*)) ///
  # :set_user_data ::
  #   (FFI::Pointer(*)) ///
  # :get_user_data ::
  #   (FFI::Pointer(*)) ///
  # :get_externally_allocated_memory ::
  #   (FFI::Pointer(*)) ///
  # :adjust_externally_allocated_memory ::
  #   (FFI::Pointer(*)) ///
  # :get_array_length ::
  #   (FFI::Pointer(*)) ///
  # :get_function_name ::
  #   (FFI::Pointer(*)) // The resulting string must be freed by calling cef_string_userfree_free().
  # :get_function_handler ::
  #   (FFI::Pointer(*)) ///
  # :execute_function ::
  #   (FFI::Pointer(*)) ///
  # :execute_function_with_context ::
  #   (FFI::Pointer(*)) ///
  class CefV8valueT < FFI::Struct
    layout :base, :char,
           :is_undefined, :pointer,
           :is_null, :pointer,
           :is_bool, :pointer,
           :is_int, :pointer,
           :is_uint, :pointer,
           :is_double, :pointer,
           :is_date, :pointer,
           :is_string, :pointer,
           :is_object, :pointer,
           :is_array, :pointer,
           :is_function, :pointer,
           :is_same, :pointer,
           :get_bool_value, :pointer,
           :get_int_value, :pointer,
           :get_uint_value, :pointer,
           :get_double_value, :pointer,
           :get_date_value, :pointer,
           :get_string_value, :pointer,
           :is_user_created, :pointer,
           :has_exception, :pointer,
           :get_exception, :pointer,
           :clear_exception, :pointer,
           :will_rethrow_exceptions, :pointer,
           :set_rethrow_exceptions, :pointer,
           :has_value_bykey, :pointer,
           :has_value_byindex, :pointer,
           :delete_value_bykey, :pointer,
           :delete_value_byindex, :pointer,
           :get_value_bykey, :pointer,
           :get_value_byindex, :pointer,
           :set_value_bykey, :pointer,
           :set_value_byindex, :pointer,
           :set_value_byaccessor, :pointer,
           :get_keys, :pointer,
           :set_user_data, :pointer,
           :get_user_data, :pointer,
           :get_externally_allocated_memory, :pointer,
           :adjust_externally_allocated_memory, :pointer,
           :get_array_length, :pointer,
           :get_function_name, :pointer,
           :get_function_handler, :pointer,
           :execute_function, :pointer,
           :execute_function_with_context, :pointer
  end
  
  # (Not documented)
  # 
  # @method v8value_create_undefined()
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_undefined, :cef_v8value_create_undefined, [], CefV8valueT
  
  # (Not documented)
  # 
  # @method v8value_create_null()
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_null, :cef_v8value_create_null, [], CefV8valueT
  
  # (Not documented)
  # 
  # @method v8value_create_bool(value)
  # @param [Integer] value 
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_bool, :cef_v8value_create_bool, [:int], CefV8valueT
  
  # (Not documented)
  # 
  # @method v8value_create_int(value)
  # @param [Integer] value 
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_int, :cef_v8value_create_int, [:int], CefV8valueT
  
  # (Not documented)
  # 
  # @method v8value_create_uint(value)
  # @param [Integer] value 
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_uint, :cef_v8value_create_uint, [:uint], CefV8valueT
  
  # (Not documented)
  # 
  # @method v8value_create_double(value)
  # @param [Float] value 
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_double, :cef_v8value_create_double, [:double], CefV8valueT
  
  # (Not documented)
  # 
  # @method v8value_create_date(date)
  # @param [FFI::Pointer(*TimeT)] date 
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_date, :cef_v8value_create_date, [:pointer], CefV8valueT
  
  # (Not documented)
  # 
  # @method v8value_create_string(value)
  # @param [FFI::Pointer(*StringT)] value 
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_string, :cef_v8value_create_string, [:pointer], CefV8valueT
  
  # (Not documented)
  # 
  # @method v8value_create_object(accessor)
  # @param [CefV8accessorT] accessor 
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_object, :cef_v8value_create_object, [CefV8accessorT], CefV8valueT
  
  # (Not documented)
  # 
  # @method v8value_create_array(length)
  # @param [Integer] length 
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_array, :cef_v8value_create_array, [:int], CefV8valueT
  
  # (Not documented)
  # 
  # @method v8value_create_function(name, handler)
  # @param [FFI::Pointer(*StringT)] name 
  # @param [CefV8handlerT] handler 
  # @return [CefV8valueT] 
  # @scope class
  attach_function :v8value_create_function, :cef_v8value_create_function, [:pointer, CefV8handlerT], CefV8valueT
  
end