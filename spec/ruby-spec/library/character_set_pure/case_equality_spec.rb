require_relative '../shared/include'

describe "CharacterSet::Pure#===" do
  it_behaves_like :sorted_set_include, CharacterSet::Pure, :===
end
