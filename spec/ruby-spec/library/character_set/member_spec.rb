require_relative '../shared/include'

describe "CharacterSet#member?" do
  it_behaves_like :sorted_set_include, CharacterSet, :member?
end
