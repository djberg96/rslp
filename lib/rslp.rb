require_relative 'slp/functions'
require_relative 'slp/constants'
require_relative 'slp/structs'
require_relative 'slp/helper'

module OpenSLP
  class SLP
    include OpenSLP::Functions
    include OpenSLP::Constants
    include OpenSLP::Structs
    extend OpenSLP::Functions

    def initialize(name, async = false)
      ptr = FFI::MemoryPointer.new(:uintptr_t)

      if SLPOpen(name, async, ptr) != SLP_OK
        raise SystemCallError.new('SLPOpen', FFI.errno)
      end

      @handle = ptr.read_ulong_long

      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
    end

    def close
      SLPClose(@handle)
    end

    def find_scopes
      begin
        pptr = FFI::MemoryPointer.new(:pointer, 128)

        rv = SLPFindScopes(@handle, pptr)

        if rv != SLP_OK
          raise SystemCallError.new('SLPFindScopes', rv)
        end

        arr = pptr.read_array_of_string
      ensure
        SLPFree(pptr.read_pointer)
        pptr.free
      end

      arr
    end

    # Issue a query for services.
    #
    # The +type+ argument is the service type string, including the authority
    # string, for the request. It may not be nil or empty.
    #
    # The +scope+ argument is a comma separated list of scope names. May be an
    # empty string if you wish to use scopes this machine is configured for.
    #
    # A query formulated of attribute pattern matching expressions in the
    # form of an LDAP search filter. Pass an empty string for all services
    # of the requested type.
    #
    def find_services(type, scope, filter)
      arr = []

      callback = Proc.new{ |hslp, url, life, err, cook|
        arr << url if err == SLP_OK
        return SLP_FALSE if err == SLP_LAST_CALL
        return SLP_TRUE
      }

      cookie = FFI::MemoryPointer.new(:void)

      rv = SLPFindSrvs(@handle, type, scope, filter, callback, cookie)

      if rv != SLP_OK
        raise SystemCallError.new('SLPFindSrvs', rv)
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
  OpenSLP::SLP.new('test') do |o|
  end

  #p OpenSLP::SLP.get_property('net.slp.broadcastAddr')
end
