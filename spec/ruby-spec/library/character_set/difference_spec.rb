require_relative '../shared/difference'

describe "CharacterSet#difference" do
  it_behaves_like :sorted_set_difference, CharacterSet, :difference
end
