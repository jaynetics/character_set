require_relative '../shared/union'

describe "CharacterSet::Pure#union" do
  it_behaves_like :sorted_set_union, CharacterSet::Pure, :union
end

describe "CharacterSet::Pure#|" do
  it_behaves_like :sorted_set_union, CharacterSet::Pure, :|
end
