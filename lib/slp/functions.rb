require 'ffi'

module OpenSLP
  module Functions
    extend FFI::Library
    ffi_lib :libslp

    typedef :uintptr_t, :handle

    callback :SLPSrvURLCallback, [:handle, :string, :ushort, :int, :pointer], :bool

    attach_function :SLPClose, [:handle], :void
    attach_function :SLPEscape, [:string, :pointer, :bool], :int
    attach_function :SLPFindScopes, [:handle, :pointer], :int

    attach_function :SLPFindSrvs,
      [:handle, :string, :string, :string, :SLPSrvURLCallback, :pointer], :int

    attach_function :SLPFree, [:pointer], :void
    attach_function :SLPGetProperty, [:string], :string
    attach_function :SLPGetRefreshInterval, [], :uint
    attach_function :SLPOpen, [:string, :bool, :pointer], :handle
    attach_function :SLPParseSrvURL, [:string, :pointer], :int
    attach_function :SLPSetProperty, [:string, :string], :void
  end
end
