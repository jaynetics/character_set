require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet#subtract" do
  before :each do
    @set = CharacterSet["a", "b", "c"]
  end

  it "deletes any elements contained in other and returns self" do
    @set.subtract(CharacterSet["b", "c"]).should == @set
    @set.should == CharacterSet["a"]
  end

  it "accepts any enumerable as other" do
    @set.subtract(["c"]).should == CharacterSet["a", "b"]
  end
end
