require_relative '../shared/union'

describe "CharacterSet#+" do
  it_behaves_like :sorted_set_union, CharacterSet, :+
end
