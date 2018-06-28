require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet::Pure#proper_subset?" do
  before :each do
    @set = CharacterSet::Pure[1, 2, 3, 4]
  end

  it "returns true if passed a CharacterSet::Pure that self is a proper subset of" do
    CharacterSet::Pure[].proper_subset?(@set).should be true
    CharacterSet::Pure[].proper_subset?(CharacterSet::Pure[1, 2, 3]).should be true
    CharacterSet::Pure[].proper_subset?(CharacterSet::Pure["a", "b", "c"]).should be true

    CharacterSet::Pure[1, 2, 3].proper_subset?(@set).should be true
    CharacterSet::Pure[1, 3].proper_subset?(@set).should be true
    CharacterSet::Pure[1, 2].proper_subset?(@set).should be true
    CharacterSet::Pure[1].proper_subset?(@set).should be true

    CharacterSet::Pure[5].proper_subset?(@set).should be false
    CharacterSet::Pure[1, 5].proper_subset?(@set).should be false
    CharacterSet::Pure[0].proper_subset?(@set).should be false

    @set.proper_subset?(@set).should be false
    CharacterSet::Pure[].proper_subset?(CharacterSet::Pure[]).should be false
  end

  it "raises an ArgumentError when passed a non-CharacterSet::Pure" do
    lambda { CharacterSet::Pure[].proper_subset?([]) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].proper_subset?(1) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].proper_subset?(0) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].proper_subset?(Object.new) }.should raise_error(ArgumentError)
  end
end
