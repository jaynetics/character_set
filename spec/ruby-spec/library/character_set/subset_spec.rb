require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet#subset?" do
  before :each do
    @set = CharacterSet[1, 2, 3, 4]
  end

  it "returns true if passed a CharacterSet that is equal to self or self is a subset of" do
    @set.subset?(@set).should be true
    CharacterSet[].subset?(CharacterSet[]).should be true

    CharacterSet[].subset?(@set).should be true
    CharacterSet[].subset?(CharacterSet[1, 2, 3]).should be true
    CharacterSet[].subset?(CharacterSet["a", "b", "c"]).should be true

    CharacterSet[1, 2, 3].subset?(@set).should be true
    CharacterSet[1, 3].subset?(@set).should be true
    CharacterSet[1, 2].subset?(@set).should be true
    CharacterSet[1].subset?(@set).should be true

    CharacterSet[5].subset?(@set).should be false
    CharacterSet[1, 5].subset?(@set).should be false
    CharacterSet[0].subset?(@set).should be false
  end

  it "raises an ArgumentError when passed a non-CharacterSet" do
    lambda { CharacterSet[].subset?([]) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].subset?(1) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].subset?(0) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].subset?(Object.new) }.should raise_error(ArgumentError)
  end
end
