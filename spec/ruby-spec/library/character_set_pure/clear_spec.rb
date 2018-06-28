require_relative '../../../spec_helper'
require 'set'

describe "CharacterSet::Pure#clear" do
  before :each do
    @set = CharacterSet::Pure[1, 2, 3, 4]
  end

  it "removes all elements from self" do
    @set.clear
    @set.should be_empty
  end

  it "returns self" do
    @set.clear.should equal(@set)
  end
end
