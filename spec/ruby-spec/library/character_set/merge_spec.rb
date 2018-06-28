require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet#merge" do
  it "adds the elements of the passed Enumerable to self" do
    CharacterSet["a", "b"].merge(CharacterSet["b", "c", "d"]).should == CharacterSet["a", "b", "c", "d"]
    CharacterSet[1, 2].merge([3, 4]).should == CharacterSet[1, 2, 3, 4]
  end

  it "returns self" do
    set = CharacterSet[1, 2]
    set.merge([3, 4]).should equal(set)
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { CharacterSet[1, 2].merge(1) }.should raise_error(ArgumentError)
    lambda { CharacterSet[1, 2].merge(Object.new) }.should raise_error(ArgumentError)
  end
end
