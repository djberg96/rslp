require_relative 'slp/functions'
require_relative 'slp/constants'
require_relative 'slp/structs'
require_relative 'slp/helper'

module OpenSLP
  class SLP
    include OpenSLP::Functions
    include OpenSLP::Constants
    extend OpenSLP::Functions

    def initialize(name, async = false)
      ptr = FFI::MemoryPointer.new(:uintptr_t)

      if SLPOpen(name, async, ptr) != SLP_OK
        raise SystemCallError.new('SLPOpen', FFI.errno)
      end

      @handle = ptr.read_ulong_long
    end

    def close
      SLPClose(@handle)
    end

    def find_scopes
      begin
        pptr = FFI::MemoryPointer.new(:pointer, 128)

        if SLPFindScopes(@handle, pptr) != SLP_OK
          raise SystemCallError.new('SLPOpen', FFI.errno)
        end

        arr = pptr.read_array_of_string
      ensure
        SLPFree(pptr.read_pointer)
        pptr.free
      end

      arr
    end

    # Singleton methods

    def self.refresh_interval
      SLPGetRefreshInterval()
    end

    def self.get_property(name)
      SLPGetProperty(name)
    end

    def self.set_property(prop, name)
      SLPSetProperty(prop, name)
    end
  end
end

if $0 == __FILE__
  #slp = OpenSLP::SLP.new('test')
  #p slp.find_scopes
  #slp.close

  p OpenSLP::SLP.get_property('net.slp.broadcastAddr')
end
