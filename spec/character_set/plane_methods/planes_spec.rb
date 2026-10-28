shared_examples :character_set_planes do |variant|
  it 'returns the planes in use by the CharacterSet' do
    expect(variant[].planes).to eq []
    expect(variant[0].planes).to eq [0]
    expect(variant[97].planes).to eq [0]
    expect(variant[70_000, 70_001].planes).to eq [1]
    expect(variant[97, 70_000, 70_001].planes).to eq [0, 1]
    expect(variant[0, 0x10000, 0x10FFFF].planes).to eq [0, 1, 16]
  end
end

describe "CharacterSet#planes" do
  it_behaves_like :character_set_planes, CharacterSet
end

describe "CharacterSet::Pure#planes" do
  it_behaves_like :character_set_planes, CharacterSet::Pure
end
