require_relative '../shared/union'

describe "CharacterSet#union" do
  it_behaves_like :sorted_set_union, CharacterSet, :union
end

describe "CharacterSet#|" do
  it_behaves_like :sorted_set_union, CharacterSet, :|
end
