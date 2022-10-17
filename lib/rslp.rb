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

    # The version of the rslp library.
    VERSION = '0.0.2'.freeze

    # Internal error raised whenever an openslp function fails.
    class Error < StandardError; end

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
    # the underlying handle is set to handle asynchronous operations or not. By
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

      ptr = FFI::MemoryPointer.new(:ulong)

      result = SLPOpen(lang, async, ptr)
      raise Error, "SLPOpen(): #{result}" if result != :SLP_OK

      @handle = ptr.read_ulong

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

    # Register a :url for the given :lifetime. You may also specify a hash
    # of :attributes, specify whether or not this is a :fresh service.
    #
    # The lifetime defaults to SLP_LIFETIME_DEFAULT.
    #
    # The attributes defaults to an empty string. Note that the has you provide
    # automatically converts the attributes into the appropriate format.
    #
    # By default it will be considered a fresh service.
    #
    # Returns the url if successful.
    #
    def register(options = {})
      options[:lifetime] ||= SLP_LIFETIME_DEFAULT
      options[:attributes] ||= ""
      options[:fresh] ||= true

      options[:callback] ||= Proc.new{ |hslp, err, cookie| }

      if options[:attributes] && options[:attributes] != ""
        attributes = options[:attributes].map{ |k,v| "(#{k}=#{v})" }.join(',')
      else
        attributes = ""
      end

      begin
        cookie = FFI::MemoryPointer.new(:void)

        result = SLPReg(
          @handle,
          options[:url],
          options[:lifetime],
          nil,
          attributes,
          options[:fresh],
          options[:callback],
          cookie
        )

        raise Error, "SLPReg(): #{result}" if result != :SLP_OK
      ensure
        cookie.free unless cookie.null?
      end

      options[:url]
    end

    # Deregisters the advertisement for +url+ in all scopes where the service
    # is registered and all language locales.
    #
    def deregister(url)
      callback = Proc.new{ |hslp, err, cookie| }

      begin
        cookie = FFI::MemoryPointer.new(:void)
        result = SLPDereg(@handle, url, callback, cookie)
        raise Error, "SLPDereg(): #{result}" if result != :SLP_OK
      ensure
        cookie.free unless cookie.null?
      end

      true
    end

    # Deletes specified attributes from a registered service. The attributes
    # argument should be a comma separated list (in string form) of attribute
    # ids.
    #
    # Returns the list of deleted attributes if successful.
    #
    def delete_service_attributes(url, attributes)
      callback = Proc.new{ |hslp, err, cookie| }

      begin
        cookie = FFI::MemoryPointer.new(:void)
        result = SLPDelAttrs(@handle, url, attributes, callback, cookie)
        raise Error, "SLPDelAttrs(): #{result}" if result != :SLP_OK
      ensure
        cookie.free unless cookie.null?
      end

      attributes
    end

    # Returns a list of scopes. The most desirable values are always first in
    # the list. There is always at least one value ("DEFAULT") in the list.
    #
    def find_scopes
      begin
        pptr = FFI::MemoryPointer.new(:pointer, 128)

        result = SLPFindScopes(@handle, pptr)
        raise Error, "SLPFindScopes(): #{result}" if result != :SLP_OK

        arr = pptr.read_array_of_string
      ensure
        SLPFree(pptr.read_pointer)
        pptr.free unless pptr.null?
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
        if err == SLP_OK
          arr << {url => life}
          true
        else
          false
        end
      }

      begin
        cookie = FFI::MemoryPointer.new(:void)
        result = SLPFindSrvs(@handle, type, scope, filter, callback, cookie)
        raise Error, "SLPFindSrvs(): #{result}" if result != :SLP_OK
      ensure
        cookie.free unless cookie.null?
      end

      arr
    end

    # The find_service_types method issues an SLP service type request for
    # service types indicated by the scope parameter, limited by the naming
    # authority +auth+.
    #
    # The default naming authority is '*', i.e. all naming authorities. A
    # blank string will result in the default naming authority of IANA.
    #
    # A blank +scope+ parameter will use scopes this machine is configured for.
    #
    # Returns an array of service type names.
    #
    def find_service_types(auth = '*', scope = '')
      arr = []

      callback = Proc.new{ |hslp, types, err, cookie|
        if err == SLP_OK
          arr << types
          true
        else
          false
        end
      }

      begin
        cookie = FFI::MemoryPointer.new(:void)
        result = SLPFindSrvTypes(@handle, auth, scope, callback, cookie)
        raise Error, "SLPFindSrvTypes(): #{result}" if result != :SLP_OK
      ensure
        cookie.free unless cookie.null?
      end

      arr
    end

    # Return a list of service attributes matching the +attrs+ for the
    # indicated service +url+ using the given +scope+.
    #
    # A blank +scope+ parameter will use scopes this machine is configured for.
    #
    def find_service_attributes(url, attrs = '', scope = '')
      arr = []

      callback = Proc.new{ |hslp, attrlist, err, cookie|
        if err == SLP_OK
          arr << attrlist
          true
        else
          false
        end
      }

      begin
        cookie = FFI::MemoryPointer.new(:void)
        result = SLPFindAttrs(@handle, url, scope, attrs, callback, cookie)
        raise Error, "SLPFindAttrs(): #{result}" if result != :SLP_OK
      ensure
        cookie.free unless cookie.null?
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

        result = SLPParseSrvURL(url, pptr)
        raise Error, "SLPParseSrvURL(): #{result}" if result != :SLP_OK

        ptr = pptr.read_pointer
        struct = SLPSrvURL.new(ptr)
      ensure
        pptr.free unless pptr.null?
      end

      struct
    end

    # Process the +string+ to escape any SLP reserved characters. If the
    # +istag_ parameter is true then it will look for bad tag characters.
    #
    def self.escape_reserved(string, istag = true)
      begin
        pptr = FFI::MemoryPointer.new(:pointer)

        result = SLPEscape(string, pptr, istag)
        raise Error, "SLPEscape(): #{result}" if result != :SLP_OK

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

        result = SLPUnescape(string, pptr, istag)
        raise Error, "SLPUnescape(): #{result}" if result != :SLP_OK

        str = pptr.read_pointer.read_string
      ensure
        SLPFree(pptr.read_pointer)
      end

      str
    end
  end
end
