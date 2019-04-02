require_relative '../shared/union'

describe "CharacterSet::Pure#+" do
  it_behaves_like :sorted_set_union, CharacterSet::Pure, :+
end
