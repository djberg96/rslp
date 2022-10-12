require_relative 'functions'

module OpenSLP
  module Structs
    class SLPSrvURL < FFI::ManagedStruct
      extend OpenSLP::Functions

      layout(
        :s_pcSrvType, :string,
        :s_pcHost, :string,
        :s_iPort, :int,
        :s_pcNetFamily, :string,
        :s_pcSrvPart, :string
      )

      def self.release(pointer)
        SLPFree(pointer) unless pointer.null?
      end

      def service_type
        self[:s_pcSrvType]
      end

      def host
        self[:s_pcHost]
      end

      def port
        self[:s_iPort]
      end

      def net_family
        self[:s_pcNetFamily]
      end

      def url_remainder
        self[:s_pcSrvPart]
      end
    end
  end
end
