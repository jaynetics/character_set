require_relative '../../../spec_helper'
require_relative 'shared/include'
require 'set'

describe "CharacterSet#member?" do
  it_behaves_like :sorted_set_0_include, :member?
end
