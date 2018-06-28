require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet::Pure#subset?" do
  before :each do
    @set = CharacterSet::Pure[1, 2, 3, 4]
  end

  it "returns true if passed a CharacterSet::Pure that is equal to self or self is a subset of" do
    @set.subset?(@set).should be true
    CharacterSet::Pure[].subset?(CharacterSet::Pure[]).should be true

    CharacterSet::Pure[].subset?(@set).should be true
    CharacterSet::Pure[].subset?(CharacterSet::Pure[1, 2, 3]).should be true
    CharacterSet::Pure[].subset?(CharacterSet::Pure["a", "b", "c"]).should be true

    CharacterSet::Pure[1, 2, 3].subset?(@set).should be true
    CharacterSet::Pure[1, 3].subset?(@set).should be true
    CharacterSet::Pure[1, 2].subset?(@set).should be true
    CharacterSet::Pure[1].subset?(@set).should be true

    CharacterSet::Pure[5].subset?(@set).should be false
    CharacterSet::Pure[1, 5].subset?(@set).should be false
    CharacterSet::Pure[0].subset?(@set).should be false
  end

  it "raises an ArgumentError when passed a non-CharacterSet::Pure" do
    lambda { CharacterSet::Pure[].subset?([]) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].subset?(1) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].subset?(0) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].subset?(Object.new) }.should raise_error(ArgumentError)
  end
end
