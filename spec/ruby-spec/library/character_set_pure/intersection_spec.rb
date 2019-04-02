require_relative '../shared/intersection'

describe "CharacterSet::Pure#intersection" do
  it_behaves_like :sorted_set_intersection, CharacterSet::Pure, :intersection
end

describe "CharacterSet::Pure#&" do
  it_behaves_like :sorted_set_intersection, CharacterSet::Pure, :&
end
