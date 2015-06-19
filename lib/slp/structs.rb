require 'ffi'

module OpenSLP
  module Structs
    class SLPSrvURL < FFI::Struct
      layout(
        :s_pcSrvType, :string,
        :s_pcHost, :string,
        :s_iPort, :int,
        :s_pcNetFamily, :string,
        :s_pcSrvPart, :string
      )
    end
  end
end
