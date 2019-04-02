require_relative '../shared/add'

describe "CharacterSet::Pure#<<" do
  it_behaves_like :sorted_set_add, CharacterSet::Pure, :<<
end
