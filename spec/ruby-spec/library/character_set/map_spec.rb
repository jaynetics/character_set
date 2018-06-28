require_relative '../../../spec_helper'
require 'set'
require_relative 'shared/collect'

describe "CharacterSet#map!" do
  it_behaves_like :sorted_set_0_collect_bang, :map!
end
