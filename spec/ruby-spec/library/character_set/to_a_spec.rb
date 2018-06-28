require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet#to_a" do
  it "returns an array containing elements" do
    set = CharacterSet.new [1, 2, 3]
    set.to_a.should == [1, 2, 3]
  end

  it "returns a sorted array containing elements" do
    set = CharacterSet[2, 3, 1]
    set.to_a.should == [1, 2, 3]

    set = CharacterSet.new [5, 6, 4, 4]
    set.to_a.should == [4, 5, 6]
  end
end
