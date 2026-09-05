shared_examples :character_set_plane do |variant|
  it 'returns the given plane of the CharacterSet' do
    expect(variant[97, 98, 0x10000].plane(0)).to eq variant[97, 98]
    expect(variant[97, 98, 0x10000].plane(1)).to eq variant[0x10000]
    expect(variant[97, 98, 0x10000].plane(2)).to eq variant[]
  end

  it 'raises ArgumentError for invalid plane numbers' do
    expect { variant[].plane(-1) }.to raise_error(ArgumentError)
    expect { variant[].plane(17) }.to raise_error(ArgumentError)
  end

  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = set1.plane(0)
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end
end

describe "CharacterSet#plane" do
  it_behaves_like :character_set_plane, CharacterSet
end

describe "CharacterSet::Pure#plane" do
  it_behaves_like :character_set_plane, CharacterSet::Pure
end
