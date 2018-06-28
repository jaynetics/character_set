require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet#hash" do
  it "is static" do
    CharacterSet[].hash.should == CharacterSet[].hash
    CharacterSet[1, 2, 3].hash.should == CharacterSet[1, 2, 3].hash
    CharacterSet["a", "b", "c"].hash.should == CharacterSet["c", "b", "a"].hash

    CharacterSet[].hash.should_not == CharacterSet[1, 2, 3].hash
    CharacterSet[1, 2, 3].hash.should_not == CharacterSet["a", "b", "c"].hash
  end
end
