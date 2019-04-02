require_relative '../shared/include'

describe "CharacterSet#include?" do
  it_behaves_like :sorted_set_include, CharacterSet, :include?
end
