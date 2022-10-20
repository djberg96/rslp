########################################################################
# rslp_spec.rb
#
# Test suite for the rslp library.
########################################################################
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

  after do
    @slp.close if @slp
    @slp = nil
    @lang = nil
  end
end
