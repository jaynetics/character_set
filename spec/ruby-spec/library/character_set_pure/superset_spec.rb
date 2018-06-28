require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet::Pure#superset?" do
  before :each do
    @set = CharacterSet::Pure[1, 2, 3, 4]
  end

  it "returns true if passed a CharacterSet::Pure that equals self or self is a proper superset of" do
    @set.superset?(@set).should be true
    CharacterSet::Pure[].superset?(CharacterSet::Pure[]).should be true

    @set.superset?(CharacterSet::Pure[]).should be true
    CharacterSet::Pure[1, 2, 3].superset?(CharacterSet::Pure[]).should be true
    CharacterSet::Pure["a", "b", "c"].superset?(CharacterSet::Pure[]).should be true

    @set.superset?(CharacterSet::Pure[1, 2, 3]).should be true
    @set.superset?(CharacterSet::Pure[1, 3]).should be true
    @set.superset?(CharacterSet::Pure[1, 2]).should be true
    @set.superset?(CharacterSet::Pure[1]).should be true

    @set.superset?(CharacterSet::Pure[5]).should be false
    @set.superset?(CharacterSet::Pure[1, 5]).should be false
    @set.superset?(CharacterSet::Pure[0]).should be false
  end

  it "raises an ArgumentError when passed a non-CharacterSet::Pure" do
    lambda { CharacterSet::Pure[].superset?([]) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].superset?(1) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].superset?(0) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].superset?(Object.new) }.should raise_error(ArgumentError)
  end
end
