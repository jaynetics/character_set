require_relative '../shared/select'

describe "CharacterSet#select!" do
  it_behaves_like :sorted_set_select_bang, CharacterSet, :select!
end
