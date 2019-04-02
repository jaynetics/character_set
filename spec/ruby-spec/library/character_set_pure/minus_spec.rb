require_relative '../shared/difference'

describe "CharacterSet::Pure#-" do
  it_behaves_like :sorted_set_difference, CharacterSet::Pure, :-
end
