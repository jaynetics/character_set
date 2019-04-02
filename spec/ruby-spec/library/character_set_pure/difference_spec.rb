require_relative '../shared/difference'

describe "CharacterSet::Pure#difference" do
  it_behaves_like :sorted_set_difference, CharacterSet::Pure, :difference
end
