require_relative '../shared/difference'

describe "CharacterSet#-" do
  it_behaves_like :sorted_set_difference, CharacterSet, :-
end
