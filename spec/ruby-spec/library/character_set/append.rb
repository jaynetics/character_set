require_relative '../../../spec_helper'
require 'set'
require_relative 'shared/add'

describe "CharacterSet#<<" do
  it_behaves_like :sorted_set_0_add, :<<
end
