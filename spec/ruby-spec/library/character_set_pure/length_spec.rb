require_relative '../../../spec_helper'
require_relative 'shared/length'
require 'set'

describe "CharacterSet::Pure#length" do
  it_behaves_like :sorted_set_1_length, :length
end
