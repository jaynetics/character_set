require_relative '../../../spec_helper'
require 'set'
require_relative 'shared/add'

describe "CharacterSet::Pure#<<" do
  it_behaves_like :sorted_set_1_add, :<<
end
