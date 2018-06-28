require_relative '../../../spec_helper'
require_relative 'shared/intersection'
require 'set'

describe "CharacterSet#intersection" do
  it_behaves_like :sorted_set_0_intersection, :intersection
end

describe "CharacterSet#&" do
  it_behaves_like :sorted_set_0_intersection, :&
end
