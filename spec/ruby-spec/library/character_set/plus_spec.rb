require_relative '../../../spec_helper'
require_relative 'shared/union'
require 'set'

describe "CharacterSet#+" do
  it_behaves_like :sorted_set_0_union, :+
end
