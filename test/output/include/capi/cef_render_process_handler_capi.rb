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
  class CefBrowserT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefBrowserT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefBrowserT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefFrameT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefV8contextT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefBrowserT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefFrameT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefV8contextT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefBrowserT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefFrameT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefDomnodeT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefBrowserT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class CefProcessMessageT < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  # 
  # = Fields:
  # :base ::
  #   (unknown) ///
  # :on_render_thread_created ::
  #   (FFI::Pointer(*)) ///
  # :on_web_kit_initialized ::
  #   (FFI::Pointer(*)) ///
  # :on_browser_created ::
  #   (FFI::Pointer(*)) ///
  # :on_browser_destroyed ::
  #   (FFI::Pointer(*)) ///
  # :on_context_created ::
  #   (FFI::Pointer(*)) ///
  # :on_context_released ::
  #   (FFI::Pointer(*)) ///
  # :on_focused_node_changed ::
  #   (FFI::Pointer(*)) ///
  # :on_process_message_received ::
  #   (FFI::Pointer(*)) ///
  class CefRenderProcessHandlerT < FFI::Struct
    layout :base, :char,
           :on_render_thread_created, :pointer,
           :on_web_kit_initialized, :pointer,
           :on_browser_created, :pointer,
           :on_browser_destroyed, :pointer,
           :on_context_created, :pointer,
           :on_context_released, :pointer,
           :on_focused_node_changed, :pointer,
           :on_process_message_received, :pointer
  end
  
end