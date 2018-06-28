require_relative '../../../spec_helper'
require 'set'
require_relative 'shared/difference'

describe "CharacterSet#difference" do
  it_behaves_like :sorted_set_0_difference, :difference
end
