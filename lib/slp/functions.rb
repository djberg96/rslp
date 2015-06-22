require 'ffi'

module OpenSLP
  module Functions
    extend FFI::Library

    # Look for either slp or libslip
    begin
      ffi_lib :libslp
    rescue LoadError
      begin
        ffi_lib :slp
      rescue LoadError
        if File::ALT_SEPARATOR
          ffi_lib "C:/Program Files (x86)/OpenSLP/slp"
        else
          raise
        end
      end
    end

    typedef :ulong, :handle

    callback :SLPSrvURLCallback, [:handle, :string, :ushort, :int, :pointer], :bool
    callback :SLPSrvTypeCallback, [:handle, :string, :int, :pointer], :bool
    callback :SLPAttrCallback, [:handle, :string, :int, :pointer], :bool

    attach_function :SLPClose, [:handle], :void
    attach_function :SLPEscape, [:string, :pointer, :bool], :int

    attach_function :SLPFindAttrs,
      [:handle, :string, :string, :string, :SLPAttrCallback, :pointer], :int

    attach_function :SLPFindScopes, [:handle, :pointer], :int

    attach_function :SLPFindSrvs,
      [:handle, :string, :string, :string, :SLPSrvURLCallback, :pointer], :int

    attach_function :SLPFindSrvTypes,
      [:handle, :string, :string, :SLPSrvTypeCallback, :pointer], :int

    attach_function :SLPFree, [:pointer], :void
    attach_function :SLPGetProperty, [:string], :string
    attach_function :SLPGetRefreshInterval, [], :uint
    attach_function :SLPOpen, [:string, :bool, :pointer], :handle
    attach_function :SLPParseSrvURL, [:string, :pointer], :int
    attach_function :SLPSetProperty, [:string, :string], :void
    attach_function :SLPUnescape, [:string, :pointer, :bool], :int
  end
end
