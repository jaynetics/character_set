require_relative '../../../spec_helper'
require_relative 'shared/length'
require 'set'

describe "CharacterSet#length" do
  it_behaves_like :sorted_set_0_length, :length
end
