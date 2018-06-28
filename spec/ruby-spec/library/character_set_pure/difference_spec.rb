require_relative '../../../spec_helper'
require 'set'
require_relative 'shared/difference'

describe "CharacterSet::Pure#difference" do
  it_behaves_like :sorted_set_1_difference, :difference
end
