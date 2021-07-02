########################################################################
# rslp_spec.rb
#
# Test suite for the rslp library.
########################################################################
require 'rspec'
require 'rslp'

describe OpenSLP::SLP do
  before do
    @lang = 'en-us'
    @slp = OpenSLP::SLP.new(@lang, false)
  end

  context "constructor" do
    example "defaults to an empty string if no lang is provided" do
      expect(OpenSLP::SLP.new.lang).to eq('')
    end

    example "defaults to a false async value if no value is provided" do
      expect(OpenSLP::SLP.new.async).to be false
    end

    example "sets attributes to expected values" do
      expect(@slp.lang).to eq(@lang)
      expect(@slp.async).to be false
    end
  end

  context "singleton methods" do
    example "defines a refresh_interval method" do
      expect(OpenSLP::SLP).to respond_to(:refresh_interval)
    end

    example "returns the expected value for refresh_interval" do
      expect(OpenSLP::SLP.refresh_interval).to eq(0)
    end

    example "defines a get_property method" do
      expect(OpenSLP::SLP).to respond_to(:get_property)
    end

    example "defines a set_property method" do
      expect(OpenSLP::SLP).to respond_to(:set_property)
    end

    example "defines a parse_service_url method" do
      expect(OpenSLP::SLP).to respond_to(:parse_service_url)
    end

    example "defines a escape_reserved method" do
      expect(OpenSLP::SLP).to respond_to(:escape_reserved)
    end

    example "returns the expected value for the escape_reserved method" do
      expected = "\\2Ctag-example\\2C"
      expect(OpenSLP::SLP.escape_reserved(",tag-example,")).to eq(expected)
    end

    example "defines a unescape_reserved method" do
      expect(OpenSLP::SLP).to respond_to(:unescape_reserved)
    end
  end

  after do
    @slp.close if @slp
    @slp = nil
    @lang = nil
  end
end
