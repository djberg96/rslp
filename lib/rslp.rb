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

    # The language tag for requests.
    attr_reader :lang

    # Returns whether or not the SLP instance is asynchronous.
    attr_reader :async

    # Creates and returns an OpenSLP::SLP object. This establishes a handle
    # that is used for the life of the object.
    #
    # The +lang+ argument may be an RFC 1766 language tag, e.g. 'en-us', that
    # sets the natural language local for requests. By default it uses your
    # machine's locale.
    #
    # The +async+ argument may be set to true or false and establishes whether
    # the underlying handle is set to handl asynchronous operations or not. By
    # default this value is false.
    #
    # If a block is given, then the object itself is yielded to the block, and
    # it is automatically closed at the end of the block.
    #
    # Examples:
    #
    #   OpenSLP::SLP.new('en-us') do |slp|
    #     # ... do stuff
    #   end
    #
    #   slp = OpenSLP::SLP.new('en-us')
    #   # Do stuff
    #   slp.close
    #
    def initialize(lang = '', async = false)
      @lang = lang
      @async = async

      ptr = FFI::MemoryPointer.new(:uintptr_t)

      if SLPOpen(lang, async, ptr) != SLP_OK
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

    # Close the OpenSLP::SLP object. The block form of the constructor will
    # automatically call this for you.
    #
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
    # form of an LDAP search filter. The default is an empty string, which
    # will gather all services of the requested type.
    #
    def find_services(type, scope = '', filter = '')
      arr = []

      callback = Proc.new{ |hslp, url, life, err, cook|
        if err == SLP_OK && url
          arr << {url => life}
          true
        else
          false
        end
      }

      cookie = FFI::MemoryPointer.new(:void)

      rv = SLPFindSrvs(@handle, type, scope, filter, callback, cookie)

      if rv != SLP_OK
        raise SystemCallError.new('SLPFindSrvs', rv)
      end

      arr
    end

    def find_service_types(auth = '*', scope = '')
      arr = []

      callback = Proc.new{ |hslp, types, err, cookie|
        if err == SLP_OK && types
          arr << types
          true
        else
          false
        end
      }

      cookie = FFI::MemoryPointer.new(:void)

      rv = SLPFindSrvTypes(@handle, auth, scope, callback, cookie)

      if rv != SLP_OK
        raise SystemCallError.new('SLPFindSrvs', rv)
      end

      arr
    end

    # Singleton methods

    # Returns the minimum refresh interval that will be accepted by all SLP
    # agents on the network. If no agents advertise a minimum refresh interval
    # then zero is returned, though that is not a valid lifetime parameter to
    # other methods.
    #
    def self.refresh_interval
      SLPGetRefreshInterval()
    end

    # Returns the value of the SLP property +name+.
    #
    def self.get_property(name)
      SLPGetProperty(name)
    end

    # Sets the value of the SLP property +prop+ to +name+.
    #
    def self.set_property(prop, name)
      SLPSetProperty(prop, name)
      name
    end

    # Parses a Service URL string and returns SLPSrvURL struct.
    #
    def self.parse_service_url(url)
      begin
        pptr = FFI::MemoryPointer.new(SLPSrvURL)

        if SLPParseSrvURL(url, pptr) != SLP_OK
          raise SystemCallError.new('SLPParseSrvURL', FFI.errno)
        end

        ptr = pptr.read_pointer
        struct = SLPSrvURL.new(ptr)
      ensure
        SLPFree(ptr)
      end

      struct
    end

    # Process the +string+ to escape any SLP reserved characters. If the
    # +istag_ parameter is true then it will look for bad tag characters.
    #
    def self.escape_reserved(string, istag = true)
      begin
        pptr = FFI::MemoryPointer.new(:pointer)

        if SLPEscape(string, pptr, istag) != SLP_OK
          raise SystemCallError.new('SLPEscape', FFI.errno)
        end

        str = pptr.read_pointer.read_string
      ensure
        SLPFree(pptr.read_pointer)
      end

      str
    end

    # Process the +string+ to unescape any SLP reserved characters. If the
    # +istag_ parameter is true then it will look for bad tag characters.
    #
    def self.unescape_reserved(string, istag = true)
      begin
        pptr = FFI::MemoryPointer.new(:pointer)

        if SLPUnescape(string, pptr, istag) != SLP_OK
          raise SystemCallError.new('SLPEscape', FFI.errno)
        end

        str = pptr.read_pointer.read_string
      ensure
        SLPFree(pptr.read_pointer)
      end

      str
    end
  end
end
