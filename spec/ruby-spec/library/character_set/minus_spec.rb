require_relative '../../../spec_helper'
require 'set'
require_relative 'shared/difference'

describe "CharacterSet#-" do
  it_behaves_like :sorted_set_0_difference, :-
end
