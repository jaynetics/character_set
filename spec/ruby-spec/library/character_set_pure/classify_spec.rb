require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet::Pure#classify" do
  before :each do
    @set = CharacterSet::Pure[1, 2, 3, 4]
  end

  it "yields each Object in self in sorted order" do
    res = []
    @set.classify { |x| res << x }
    res.should == [1, 2, 3, 4].sort
  end

  it "returns an Enumerator when passed no block" do
    enum = @set.classify
    enum.should be_an_instance_of(Enumerator)

    classified = enum.each(&:odd?)
    classified.should == { true => CharacterSet::Pure[1, 3], false => CharacterSet::Pure[2, 4] }
  end

  it "classifies the Objects in self based on the block's return value" do
    classified = @set.classify(&:odd?)
    classified.should == { true => CharacterSet::Pure[1, 3], false => CharacterSet::Pure[2, 4] }
  end
end
