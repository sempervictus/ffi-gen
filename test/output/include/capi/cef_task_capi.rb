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
  # 
  # @method currently_on(thread_id)
  # @param [unknown] thread_id 
  # @return [Integer] 
  # @scope class
  attach_function :currently_on, :cef_currently_on, [:char], :int
  
  # ///
  class CefTaskT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  # 
  # @method post_task(thread_id, task)
  # @param [unknown] thread_id 
  # @param [CefTaskT] task 
  # @return [Integer] 
  # @scope class
  attach_function :post_task, :cef_post_task, [:char, CefTaskT], :int
  
  # ///
  class CefTaskT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  # 
  # @method post_delayed_task(thread_id, task, delay_ms)
  # @param [unknown] thread_id 
  # @param [CefTaskT] task 
  # @param [Integer] delay_ms 
  # @return [Integer] 
  # @scope class
  attach_function :post_delayed_task, :cef_post_delayed_task, [:char, CefTaskT, :long], :int
  
  # ///
  # 
  # = Fields:
  # :base ::
  #   (unknown) ///
  # :execute ::
  #   (FFI::Pointer(*)) ///
  class CefTaskT < FFI::Struct
    layout :base, :char,
           :execute, :pointer
  end
  
end