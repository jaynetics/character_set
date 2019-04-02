require_relative '../shared/length'

describe "CharacterSet#size" do
  it_behaves_like :sorted_set_length, CharacterSet, :size
end
