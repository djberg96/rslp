########################################################################
# rslip_spec.rb
#
# Test suite for the rslip library.
########################################################################
require 'rspec/autorun'
require 'rslp'

describe "rslp" do
  before{
    @lang = 'en-us'
    @slp = OpenSLP::SLP.new(@lang)
  }

  context "constructor" do
    it "defaults to an empty string if no lang is provided" do
      expect(OpenSLP::SLP.new.lang).to eq('')
    end

    it "defaults to a false async value if no value is provided" do
      expect(OpenSLP::SLP.new.async).to be_false
    end
  end

  after{
    @slp.close if @slp
    @slp = nil
    @lang = nil
  }
end
