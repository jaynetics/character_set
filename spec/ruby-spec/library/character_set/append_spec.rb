require_relative '../shared/add'

describe "CharacterSet#<<" do
  it_behaves_like :sorted_set_add, CharacterSet, :<<
end
