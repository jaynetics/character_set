require_relative '../../../spec_helper'
require_relative 'shared/intersection'
require 'set'

describe "CharacterSet::Pure#intersection" do
  it_behaves_like :sorted_set_1_intersection, :intersection
end

describe "CharacterSet::Pure#&" do
  it_behaves_like :sorted_set_1_intersection, :&
end
