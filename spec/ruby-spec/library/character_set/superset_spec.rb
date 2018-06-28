require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet#superset?" do
  before :each do
    @set = CharacterSet[1, 2, 3, 4]
  end

  it "returns true if passed a CharacterSet that equals self or self is a proper superset of" do
    @set.superset?(@set).should be true
    CharacterSet[].superset?(CharacterSet[]).should be true

    @set.superset?(CharacterSet[]).should be true
    CharacterSet[1, 2, 3].superset?(CharacterSet[]).should be true
    CharacterSet["a", "b", "c"].superset?(CharacterSet[]).should be true

    @set.superset?(CharacterSet[1, 2, 3]).should be true
    @set.superset?(CharacterSet[1, 3]).should be true
    @set.superset?(CharacterSet[1, 2]).should be true
    @set.superset?(CharacterSet[1]).should be true

    @set.superset?(CharacterSet[5]).should be false
    @set.superset?(CharacterSet[1, 5]).should be false
    @set.superset?(CharacterSet[0]).should be false
  end

  it "raises an ArgumentError when passed a non-CharacterSet" do
    lambda { CharacterSet[].superset?([]) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].superset?(1) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].superset?(0) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].superset?(Object.new) }.should raise_error(ArgumentError)
  end
end
