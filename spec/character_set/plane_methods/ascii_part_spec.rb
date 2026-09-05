shared_examples :character_set_ascii_part do |variant|
  it 'returns the ascii part of a character set' do
    expect(variant[97, 98, 99, 200].ascii_part).to eq(variant[97, 98, 99])
  end

  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = set1.ascii_part
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end
end

describe "CharacterSet#ascii_part" do
  it_behaves_like :character_set_ascii_part, CharacterSet
end

describe "CharacterSet::Pure#ascii_part" do
  it_behaves_like :character_set_ascii_part, CharacterSet::Pure
end
