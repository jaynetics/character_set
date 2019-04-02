require_relative '../shared/select'

describe "CharacterSet::Pure#select!" do
  it_behaves_like :sorted_set_select_bang, CharacterSet::Pure, :select!
end
