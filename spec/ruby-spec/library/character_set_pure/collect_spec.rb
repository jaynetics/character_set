require_relative '../shared/collect'

describe "CharacterSet::Pure#collect!" do
  it_behaves_like :sorted_set_collect_bang, CharacterSet::Pure, :collect!
end
