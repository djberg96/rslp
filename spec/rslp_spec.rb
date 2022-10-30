##############################################################################
# rslp_spec.rb
#
# Test suite for the rslp library. Note that these specs assume that you
# have an OpenSLP server running on localhost. If not, install Docker and
# run the following command:
#
#   docker run -d -p 427:427/tcp -p 427:427/udp vcrhonek/openslp
#
# Once complete, simply stop the docker container and delete the image.
##############################################################################
require 'rspec'
require 'rslp'

RSpec.describe OpenSLP::SLP do
  before do
    @lang = 'en-us'
    @slp = described_class.new(lang: @lang, async: false, host: 'localhost')
  end

  context "version" do
    example "version is set to the expected value" do
      expect(described_class::VERSION).to eq('0.1.1')
    end
  end

  context "constructor" do
    example "defaults to an empty string if no lang is provided" do
      expect(described_class.new.lang).to eq('')
    end

    example "defaults to a false async value if no value is provided" do
      expect(described_class.new.async).to be false
    end

    example "sets attributes to expected values" do
      expect(@slp.lang).to eq(@lang)
      expect(@slp.async).to be false
    end
  end

  describe "singleton methods" do
    context "refresh_interval" do
      example "defines a refresh_interval method" do
        expect(described_class).to respond_to(:refresh_interval)
      end

      example "returns the expected value for refresh_interval" do
        expect(described_class.refresh_interval).to eq(0)
      end
    end

    example "defines a get_property method" do
      expect(described_class).to respond_to(:get_property)
    end

    example "defines a set_property method" do
      expect(described_class).to respond_to(:set_property)
    end

    context "parse_service_url" do
      let(:valid_url) { "service:test.openslp://192.168.100.1:3003,en,65535" }

      before do
        @struct = described_class.parse_service_url(valid_url)
      end

      example "defines a parse_service_url method" do
        expect(described_class).to respond_to(:parse_service_url)
      end

      example "does not raise an error if the url is valid" do
        expect{ described_class.parse_service_url(valid_url) }.not_to raise_error
      end

      example "returns a struct with the expected service type" do
        expect(@struct.service_type).to eq("service:test.openslp")
      end

      example "returns a struct with the expected host" do
        expect(@struct.host).to eq("192.168.100.1")
      end

      example "returns a struct with the expected port" do
        expect(@struct.port).to eq(3003)
      end

      example "returns a struct with the expected net family" do
        expect(@struct.net_family).to eq("")
      end

      example "returns a struct with the expected url remainder" do
        expect(@struct.url_remainder).to eq("")
      end
    end

    context "escape_reserved" do
      example "defines a escape_reserved method" do
        expect(described_class).to respond_to(:escape_reserved)
      end

      example "returns the expected value for the escape_reserved method" do
        expected = "\\2Ctag-example\\2C"
        expect(described_class.escape_reserved(",tag-example,")).to eq(expected)
      end
    end

    context "unescape_reserved" do
      example "defines a unescape_reserved method" do
        expect(described_class).to respond_to(:unescape_reserved)
      end

      example "returns the expected value for the unescape_reserved method" do
        expected = ",tag-example,"
        expect(described_class.unescape_reserved("\\2Ctag-example\\2C")).to eq(expected)
      end
    end

    context "set_app_property_file" do
      example "defines a set_app_property_file method" do
        expect(described_class).to respond_to(:set_app_property_file)
      end
    end
  end

  describe "instance methods" do
    let(:service){ "service:ntp" }
    let(:url){ "#{service}://time.windows.com" }
    let(:attributes){ {"foo" => "hello", "bar" => "world"} }

    context "close" do
      example "has a close method that returns the expected value" do
        expect(@slp).to respond_to(:close)
        expect(@slp.close).to be_nil
      end

      example "calling close multiple times has no effect" do
        expect(@slp.close).to be_nil
        expect(@slp.close).to be_nil
      end
    end

    context "find_scopes" do
      example "has a find_scopes method" do
        expect(@slp).to respond_to(:find_scopes)
      end

      example "the find_scopes method returns the expected value" do
        expect(@slp.find_scopes).to eq(['DEFAULT'])
      end
    end

    context "find_services" do
      before do
        sleep 1
        @slp.register(url: url, attributes: attributes)
      end

      example "has a find_services method" do
        expect(@slp).to respond_to(:find_services)
      end

      example "the find_services method returns the expected types" do
        results = @slp.find_services(service)
        expect(results).to be_a(Array)
        expect(results.first).to be_a(Hash)
      end

      example "the find_services method returns the expected values" do
        results = @slp.find_services(service)
        expect(results.first.keys).to include(url)
        expect(results.first.values.first).to be_a(Numeric)
      end

      example "the find_services method with valid scope returns the expected values" do
        results = @slp.find_services(service, 'DEFAULT')
        expect(results.first.keys).to include(url)
        expect(results.first.values.first).to be_a(Numeric)
      end

=begin
      # These specs appear to cause a segfault in the OpenSLP daemon.
      example "the find_services method with invalid scope returns an empty value" do
        results = @slp.find_services(service, 'bogus')
        expect(results).to be_empty
      end

      example "the find_services method with filter on existing attribute returns the expected values" do
        results = @slp.find_services(service, '', "(foo=hello)")
        expect(results).to eq(1)
      end
=end
    end

    context "find_service_types" do
      example "has a find_services method" do
        expect(@slp).to respond_to(:find_service_types)
      end

      example "the find_service_types method returns the expected results" do
        results = @slp.find_service_types
        expect(results).to be_a(Array)
        expect(results.first).to eq(service)
      end
    end

    context "registration" do
      example "registers a service successfully if url is provided" do
        expect(@slp.register(url: url)).to eq(url)
      end

      example "doesn't matter if service is already registered" do
        expect(@slp.register(url: url)).to eq(url)
        expect{ @slp.register(url: url) }.not_to raise_error
      end

      example "accepts hash attributes option and registers them as expected" do
        expect(@slp.register(url: url, attributes: attributes)).to eq(url)
      end

      example "raises an error if the :url option is not provided" do
        expect{ @slp.register }.to raise_error(ArgumentError, ":url must be provided")
      end

      example "registers a service successfully with a lifetime value" do
        expect(@slp.register(url: url, lifetime: OpenSLP::SLP::SLP_LIFETIME_MAXIMUM)).to eq(url)
        expect(@slp.find_services(service).first.values.first).to be_within(1).of(OpenSLP::SLP::SLP_LIFETIME_MAXIMUM)
      end
    end

    context "deregistration" do
      example "deregisters a service successfully if it exists" do
        expect(@slp.deregister(url)).to eq(url)
        expect(@slp.find_services(url)).to be_empty
      end

      example "fails to deregister a service successfully if it does not exist" do
        expect{ @slp.deregister('bogus') }.to raise_error(OpenSLP::SLP::Error)
      end
    end

    context "find service attributes" do
      before do
        @slp.register(url: url, attributes: attributes)
      end

      example "successfully finds service attribute when they exist" do
        expect(@slp.find_service_attributes(url)).to eq(["(foo=hello),(bar=world)"])
        expect(@slp.find_service_attributes(url, "foo")).to eq(["(foo=hello)"])
        expect(@slp.find_service_attributes(url, "foo,bar")).to eq(["(foo=hello),(bar=world)"])
      end

      example "returns an empty array if the service attribute does not exist" do
        expect(@slp.find_service_attributes(url, "bogus")).to eq([])
      end
    end
  end

  after do
    @slp.close if @slp
    @slp = nil
    @lang = nil
  end
end
