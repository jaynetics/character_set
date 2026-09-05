# ruby-spec covers other cases

shared_examples :character_set_equal_value do |variant|
  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = variant[96, 97]
    _dummy = set1 == set2
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end
end

describe "CharacterSet#==" do
  it_behaves_like :character_set_equal_value, CharacterSet
end

describe "CharacterSet::Pure#==" do
  it_behaves_like :character_set_equal_value, CharacterSet::Pure

  it 'works with descendant classes' do
    descendant = Class.new(CharacterSet::Pure)
    expect(CharacterSet::Pure[97, 98, 99]).to eq descendant[97, 98, 99]
  end

  it 'works with CharacterSet' do
    expect(CharacterSet::Pure[97, 98, 99]).to eq CharacterSet[97, 98, 99]
  end
end
