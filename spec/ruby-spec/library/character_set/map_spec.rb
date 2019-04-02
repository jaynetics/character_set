require_relative '../shared/collect'

describe "CharacterSet#map!" do
  it_behaves_like :sorted_set_collect_bang, CharacterSet, :map!
end
