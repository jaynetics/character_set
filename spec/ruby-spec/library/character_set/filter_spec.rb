require_relative '../shared/select'

describe "CharacterSet#filter!" do
  it_behaves_like :sorted_set_select_bang, CharacterSet, :filter!
end
