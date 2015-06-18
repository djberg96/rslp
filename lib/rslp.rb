require_relative 'slp/functions'
require_relative 'slp/constants'
require_relative 'slp/structs'

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
  end
end

if $0 == __FILE__
  slp = OpenSLP::SLP.new('test')
  slp.close
end
