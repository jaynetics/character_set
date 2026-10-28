require_relative '../shared/select'

describe "CharacterSet::Pure#filter!" do
  it_behaves_like :sorted_set_select_bang, CharacterSet::Pure, :filter!
end
