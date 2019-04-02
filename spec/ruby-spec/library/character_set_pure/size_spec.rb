require_relative '../shared/length'

describe "CharacterSet::Pure#size" do
  it_behaves_like :sorted_set_length, CharacterSet::Pure, :size
end
