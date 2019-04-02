require_relative '../shared/include'

describe "CharacterSet::Pure#member?" do
  it_behaves_like :sorted_set_include, CharacterSet::Pure, :member?
end
