require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet#==" do
  it "returns true when the passed Object is a CharacterSet and self and the Object contain the same elements" do
    CharacterSet[].should == CharacterSet[]
    CharacterSet[1, 2, 3].should == CharacterSet[1, 2, 3]
    CharacterSet["1", "2", "3"].should == CharacterSet["1", "2", "3"]

    CharacterSet[1, 2, 3].should_not == CharacterSet[0, 2, 3]
    CharacterSet[1, 2, 3].should_not == [1, 2, 3]
  end
end
