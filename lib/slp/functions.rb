require 'ffi'

module OpenSLP
  module Functions
    extend FFI::Library
    ffi_lib :libslp

    typedef :uintptr_t, :handle

    attach_function :SLPOpen, [:string, :bool, :pointer], :handle
    attach_function :SLPClose, [:handle], :void
  end
end
