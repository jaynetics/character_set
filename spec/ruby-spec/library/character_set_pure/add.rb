require_relative '../../../spec_helper'
require 'set'
require_relative 'shared/add'

describe "CharacterSet::Pure#add" do
  it_behaves_like :sorted_set_1_add, :add
end

describe "CharacterSet::Pure#add?" do
  before :each do
    @set = CharacterSet::Pure.new
  end

  it "adds the passed Object to self" do
    @set.add?(0)
    @set.should include(0)
  end

  it "returns self when the Object has not yet been added to self" do
    @set.add?(0).should equal(@set)
  end

  it "returns nil when the Object has already been added to self" do
    @set.add?(0)
    @set.add?(0).should be_nil
  end
end
