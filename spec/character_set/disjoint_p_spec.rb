shared_examples :character_set_disjoint_p do |variant|
  it 'is true iff both sets are disjoint' do
    expect(variant[97, 98, 99].disjoint?(variant[])).to eq true
    expect(variant[97, 98, 99].disjoint?(variant[96])).to eq true
    expect(variant[97, 98, 99].disjoint?(variant[96, 101])).to eq true
    expect(variant[97, 98, 99].disjoint?(variant[98])).to eq false
    expect(variant[97, 98, 99].disjoint?(variant[98, 101])).to eq false
    expect(variant[97, 98, 99].disjoint?(variant[97, 99])).to eq false
    expect(variant[97, 98, 99].disjoint?(variant[97, 99, 101])).to eq false
  end

  it 'supports passing any Enumerable' do
    expect(variant[97, 98, 99].disjoint?([])).to eq true
    expect(variant[97, 98, 99].disjoint?([96])).to eq true
    expect(variant[97, 98, 99].disjoint?([98])).to eq false
    expect(variant[97, 98, 99].intersect?(Set[98])).to eq true
    expect(variant[97, 98, 99].intersect?(Class.new(Set)[98])).to eq true
  end

  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = variant[97, 98]
    set1.disjoint?(set2)
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end
end

describe "CharacterSet#disjoint?" do
  it_behaves_like :character_set_disjoint_p, CharacterSet
end

describe "CharacterSet::Pure#disjoint?" do
  it_behaves_like :character_set_disjoint_p, CharacterSet::Pure
end
