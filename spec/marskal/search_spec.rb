require 'spec_helper'
require 'active_support/all'  #nned for marskal search testing
require 'active_record'

describe MarskalSearch do
  class MyBaseClass; end  #initialize variables for testing

  it 'has a version number' do
    expect(MarskalSearch::VERSION).not_to be nil
  end


  it 'MarskalSearch intializes proper class object' do
    ms = MarskalSearch.new(MyBaseClass, "")
    expect(ms.klass).to eq(MyBaseClass)
  end

  it 'MarskalSearch intializes proper class object' do
    ms = MarskalSearch.new("my_base_class", "")
    expect(ms.klass).to eq(MyBaseClass)

    ms = MarskalSearch.new("MyBaseClass",  "")
    expect(ms.klass).to eq(MyBaseClass)
  end


end
