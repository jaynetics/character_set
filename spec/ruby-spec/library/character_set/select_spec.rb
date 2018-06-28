require_relative '../../../spec_helper'
require_relative 'shared/select'
require 'set'

describe "CharacterSet#select!" do
  it_behaves_like :sorted_set_0_select_bang, :select!
end
