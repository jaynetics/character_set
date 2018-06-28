require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet::Pure#eql?" do
  it "returns true when the passed argument is a CharacterSet::Pure and contains the same elements" do
    CharacterSet::Pure[].should eql(CharacterSet::Pure[])
    CharacterSet::Pure[1, 2, 3].should eql(CharacterSet::Pure[1, 2, 3])
    CharacterSet::Pure[1, 2, 3].should eql(CharacterSet::Pure[3, 2, 1])

#    CharacterSet::Pure["a", :b, ?c].should eql(CharacterSet::Pure[?c, :b, "a"])

    CharacterSet::Pure[1, 2, 3].should_not eql(CharacterSet::Pure[0, 2, 3])
    CharacterSet::Pure[1, 2, 3].should_not eql(CharacterSet::Pure[2, 3])
    CharacterSet::Pure[1, 2, 3].should_not eql(CharacterSet::Pure[])
  end
end
