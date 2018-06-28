require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet::Pure#subtract" do
  before :each do
    @set = CharacterSet::Pure["a", "b", "c"]
  end

  it "deletes any elements contained in other and returns self" do
    @set.subtract(CharacterSet::Pure["b", "c"]).should == @set
    @set.should == CharacterSet::Pure["a"]
  end

  it "accepts any enumerable as other" do
    @set.subtract(["c"]).should == CharacterSet::Pure["a", "b"]
  end
end
