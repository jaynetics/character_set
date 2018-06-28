require_relative '../../../spec_helper'
require 'set'
require_relative 'shared/collect'

describe "CharacterSet::Pure#map!" do
  it_behaves_like :sorted_set_1_collect_bang, :map!
end
