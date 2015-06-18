require 'ffi'

module OpenSLP
  module Functions
    extend FFI::Library
    ffi_lib :libslp

    typedef :uintptr_t, :handle

    attach_function :SLPClose, [:handle], :void
    attach_function :SLPFindScopes, [:handle, :pointer], :int
    attach_function :SLPFree, [:pointer], :void
    attach_function :SLPGetProperty, [:string], :string
    attach_function :SLPGetRefreshInterval, [], :uint
    attach_function :SLPOpen, [:string, :bool, :pointer], :handle
    attach_function :SLPSetProperty, [:string, :string], :void
  end
end
