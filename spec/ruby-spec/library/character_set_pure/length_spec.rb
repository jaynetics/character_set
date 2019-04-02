require_relative '../shared/length'

describe "CharacterSet::Pure#length" do
  it_behaves_like :sorted_set_length, CharacterSet::Pure, :length
end
