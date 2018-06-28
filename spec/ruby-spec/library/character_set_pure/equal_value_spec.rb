require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet::Pure#==" do
  it "returns true when the passed Object is a CharacterSet::Pure and self and the Object contain the same elements" do
    CharacterSet::Pure[].should == CharacterSet::Pure[]
    CharacterSet::Pure[1, 2, 3].should == CharacterSet::Pure[1, 2, 3]
    CharacterSet::Pure["1", "2", "3"].should == CharacterSet::Pure["1", "2", "3"]

    CharacterSet::Pure[1, 2, 3].should_not == CharacterSet::Pure[0, 2, 3]
    CharacterSet::Pure[1, 2, 3].should_not == [1, 2, 3]
  end
end
