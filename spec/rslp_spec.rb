########################################################################
# rslp_spec.rb
#
# Test suite for the rslp library.
########################################################################
require 'rspec'
require 'rslp'

describe "rslp" do
  before{
    @lang = 'en-us'
    @slp = OpenSLP::SLP.new(@lang, false)
  }

  context "constructor" do
    it "defaults to an empty string if no lang is provided" do
      expect(OpenSLP::SLP.new.lang).to eq('')
    end

    it "defaults to a false async value if no value is provided" do
      expect(OpenSLP::SLP.new.async).to be false
    end

    it "sets attributes to expected values" do
      expect(@slp.lang).to eq(@lang)
      expect(@slp.async).to be false
    end
  end

  context "singleton methods" do
    it "defines a refresh_interval method" do
      expect(OpenSLP::SLP).to respond_to(:refresh_interval)
    end

    it "returns the expected value for refresh_interval" do
      expect(OpenSLP::SLP.refresh_interval).to eq(0)
    end

    it "defines a get_property method" do
      expect(OpenSLP::SLP).to respond_to(:get_property)
    end

    it "defines a set_property method" do
      expect(OpenSLP::SLP).to respond_to(:set_property)
    end

    it "defines a parse_service_url method" do
      expect(OpenSLP::SLP).to respond_to(:parse_service_url)
    end

    it "defines a escape_reserved method" do
      expect(OpenSLP::SLP).to respond_to(:escape_reserved)
    end

    it "returns the expected value for the escape_reserved method" do
      expected = "\\2Ctag-example\\2C"
      expect(OpenSLP::SLP.escape_reserved(",tag-example,")).to eq(expected)
    end

    it "defines a unescape_reserved method" do
      expect(OpenSLP::SLP).to respond_to(:unescape_reserved)
    end
  end

  after{
    @slp.close if @slp
    @slp = nil
    @lang = nil
  }
end
