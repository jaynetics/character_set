shared_examples :character_set_ranges do |variant|
  it 'returns an Array of Ranges, split based on contiguity' do
    expect(variant[].ranges)
      .to eq []

    expect(variant[1, 2, 3].ranges)
      .to eq [1..3]

    expect(variant[1, 3].ranges)
      .to eq [1..1, 3..3]

    expect(variant[0, 2, 3, 4, 6, 8, 11, 12].ranges)
      .to eq [0..0, 2..4, 6..6, 8..8, 11..12]
  end
end

describe "CharacterSet#ranges" do
  it_behaves_like :character_set_ranges, CharacterSet

  it 'is memsafe' do
    set = CharacterSet[97, 98, 99]
    expect { set.ranges }.to be_memsafe
  end
end

describe "CharacterSet::Pure#ranges" do
  it_behaves_like :character_set_ranges, CharacterSet::Pure
end
