require_relative '../shared/include'

describe "CharacterSet#===" do
  it_behaves_like :sorted_set_include, CharacterSet, :===
end
