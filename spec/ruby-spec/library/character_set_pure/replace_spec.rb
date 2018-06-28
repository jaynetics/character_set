require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet::Pure#replace" do
  before :each do
    @set = CharacterSet::Pure["a", "b", "c"]
  end

  it "replaces the contents with other and returns self" do
    @set.replace(CharacterSet::Pure[1, 2, 3]).should == @set
    @set.should == CharacterSet::Pure[1, 2, 3]
  end

  it "accepts any enumerable as other" do
    @set.replace([1, 2, 3]).should == CharacterSet::Pure[1, 2, 3]
  end
end
