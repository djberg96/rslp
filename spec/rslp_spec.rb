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
      expect(described_class::VERSION).to eq('0.1.0')
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
  end

  describe "instance methods" do
    let(:url){ "service:ntp://time.windows.com" }
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

    context "registration" do
      example "registers a service successfully if url is provided" do
        expect(@slp.register(url: url)).to eq(url)
      end

      example "doesn't matter if service is already registered" do
        expect(@slp.register(url: url)).to eq(url)
      end

      example "accepts hash attributes option and registers them as expected" do
        expect(@slp.register(url: url, attributes: attributes)).to eq(url)
        expect(@slp.find_service_attributes(url, "foo")).to eq(["(foo=hello)"])
        expect(@slp.find_service_attributes(url, "foo,bar")).to eq(["(foo=hello),(bar=world)"])
      end

      example "raises an error if the :url option is not provided" do
        expect{ @slp.register }.to raise_error(ArgumentError, ":url must be provided")
      end
    end

    context "deregistration" do
      example "deregisters a service successfully if it exists" do
        expect(@slp.deregister(url)).to eq(url)
      end

      example "fails to deregister a service successfully if it does not exist" do
        expect{ @slp.deregister('bogus') }.to raise_error(OpenSLP::SLP::Error)
      end
    end
  end

  after do
    @slp.close if @slp
    @slp = nil
    @lang = nil
  end
end
