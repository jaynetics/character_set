require_relative '../shared/intersection'

describe "CharacterSet#intersection" do
  it_behaves_like :sorted_set_intersection, CharacterSet, :intersection
end

describe "CharacterSet#&" do
  it_behaves_like :sorted_set_intersection, CharacterSet, :&
end
