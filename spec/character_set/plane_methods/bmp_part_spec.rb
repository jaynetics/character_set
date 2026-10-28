shared_examples :character_set_bmp_part do |variant|
  it 'returns the basic monolingual plane part of a character set' do
    expect(variant[97, 98, 99, 70_000, 70_001].bmp_part)
      .to eq(variant[97, 98, 99])
  end

  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = set1.bmp_part
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end
end

describe "CharacterSet#bmp_part" do
  it_behaves_like :character_set_bmp_part, CharacterSet
end

describe "CharacterSet::Pure#bmp_part" do
  it_behaves_like :character_set_bmp_part, CharacterSet::Pure
end
