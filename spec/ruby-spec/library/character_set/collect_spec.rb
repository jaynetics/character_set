require_relative '../shared/collect'

describe "CharacterSet#collect!" do
  it_behaves_like :sorted_set_collect_bang, CharacterSet, :collect!
end
