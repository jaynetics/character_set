require_relative '../../../spec_helper'
require 'set'
require_relative 'shared/collect'

describe "CharacterSet#collect!" do
  it_behaves_like :sorted_set_0_collect_bang, :collect!
end
