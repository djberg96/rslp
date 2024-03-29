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
          ffi_lib 'C:/Program Files (x86)/OpenSLP/slp'
        else
          raise
        end
      end
    end

    SLPError = enum(
      :SLP_LAST_CALL, 1,
      :SLP_OK, 0,
      :SLP_LANGUAGE_NOT_SUPPORTED, -1,
      :SLP_PARSE_ERROR, -2,
      :SLP_INVALID_REGISTRATION, -3,
      :SLP_SCOPE_NOT_SUPPORTED, -4,
      :SLP_AUTHENTICATION_ABSENT, -6,
      :SLP_AUTHENTICATION_FAILED, -7,
      :SLP_INVALID_UPDATE, -13,
      :SLP_REFRESH_REJECTED, -15,
      :SLP_NOT_IMPLEMENTED, -17,
      :SLP_BUFFER_OVERFLOW, -18,
      :SLP_NETWORK_TIMED_OUT, -19,
      :SLP_NETWORK_INIT_FAILED, -20,
      :SLP_MEMORY_ALLOC_FAILED, -21,
      :SLP_PARAMETER_BAD, -22,
      :SLP_NETWORK_ERROR, -23,
      :SLP_INTERNAL_SYSTEM_ERROR, -24,
      :SLP_HANDLE_IN_USE, -25,
      :SLP_TYPE_ERROR, -26
    )

    typedef :ulong, :handle

    callback :SLPSrvURLCallback, %i[handle string ushort int pointer], :bool
    callback :SLPSrvTypeCallback, %i[handle string int pointer], :bool
    callback :SLPAttrCallback, %i[handle string int pointer], :bool
    callback :SLPRegReportCallback, %i[handle int pointer], :void

    attach_function :SLPAssociateIFList, %i[handle string], SLPError
    attach_function :SLPAssociateIP, %i[handle string], SLPError
    attach_function :SLPClose, [:handle], :void
    attach_function :SLPDelAttrs, %i[handle string string SLPRegReportCallback pointer], SLPError
    attach_function :SLPDereg, %i[handle string SLPRegReportCallback pointer], SLPError
    attach_function :SLPEscape, %i[string pointer bool], SLPError

    attach_function :SLPFindAttrs,
      %i[handle string string string SLPAttrCallback pointer], SLPError

    attach_function :SLPFindScopes, %i[handle pointer], SLPError

    attach_function :SLPFindSrvs,
      %i[handle string string string SLPSrvURLCallback pointer], SLPError

    attach_function :SLPFindSrvTypes,
      %i[handle string string SLPSrvTypeCallback pointer], SLPError

    attach_function :SLPFree, [:pointer], :void
    attach_function :SLPGetProperty, [:string], :string
    attach_function :SLPGetRefreshInterval, [], :uint
    attach_function :SLPOpen, %i[string bool pointer], SLPError
    attach_function :SLPParseSrvURL, %i[string pointer], SLPError

    attach_function :SLPReg,
      %i[handle string ushort string string bool SLPRegReportCallback pointer], SLPError

    attach_function :SLPSetAppPropertyFile, [:string], SLPError
    attach_function :SLPSetProperty, %i[string string], :void
    attach_function :SLPUnescape, %i[string pointer bool], SLPError
  end
end
