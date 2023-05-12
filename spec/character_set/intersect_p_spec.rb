shared_examples :character_set_intersect_p do |variant|
  it 'is true iff both sets intersect' do
    expect(variant[97, 98, 99].intersect?(variant[])).to eq false
    expect(variant[97, 98, 99].intersect?(variant[96])).to eq false
    expect(variant[97, 98, 99].intersect?(variant[96, 101])).to eq false
    expect(variant[97, 98, 99].intersect?(variant[98])).to eq true
    expect(variant[97, 98, 99].intersect?(variant[98, 101])).to eq true
    expect(variant[97, 98, 99].intersect?(variant[97, 99])).to eq true
    expect(variant[97, 98, 99].intersect?(variant[97, 99, 101])).to eq true
  end

  it 'supports passing any Enumerable' do
    expect(variant[97, 98, 99].intersect?([])).to eq false
    expect(variant[97, 98, 99].intersect?([96])).to eq false
    expect(variant[97, 98, 99].intersect?([98])).to eq true
    expect(variant[97, 98, 99].intersect?(sorted_set_class[98])).to eq true
    expect(variant[97, 98, 99].intersect?(Class.new(sorted_set_class)[98])).to eq true
  end
end

describe "CharacterSet#intersect?" do
  it_behaves_like :character_set_intersect_p, CharacterSet
end

describe "CharacterSet::Pure#intersect?" do
  it_behaves_like :character_set_intersect_p, CharacterSet::Pure
end
