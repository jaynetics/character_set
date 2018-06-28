require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet::Pure#merge" do
  it "adds the elements of the passed Enumerable to self" do
    CharacterSet::Pure["a", "b"].merge(CharacterSet::Pure["b", "c", "d"]).should == CharacterSet::Pure["a", "b", "c", "d"]
    CharacterSet::Pure[1, 2].merge([3, 4]).should == CharacterSet::Pure[1, 2, 3, 4]
  end

  it "returns self" do
    set = CharacterSet::Pure[1, 2]
    set.merge([3, 4]).should equal(set)
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { CharacterSet::Pure[1, 2].merge(1) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[1, 2].merge(Object.new) }.should raise_error(ArgumentError)
  end
end
