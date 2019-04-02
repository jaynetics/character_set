require_relative '../shared/length'

describe "CharacterSet#length" do
  it_behaves_like :sorted_set_length, CharacterSet, :length
end
