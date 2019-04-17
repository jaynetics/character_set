shared_examples :character_set_inspect do |variant|
  it 'is not-to-verbose' do
    expect(variant[97, 98, 99].inspect)
      .to eq "#<#{variant.name}: {97, 98, 99} (size: 3)>"

    expect(variant.new(1..100).inspect)
      .to eq "#<#{variant.name}: {1, 2, 3, 4, 5...} (size: 100)>"
  end
end

describe "CharacterSet#inspect" do
  it_behaves_like :character_set_inspect, CharacterSet
end

describe "CharacterSet::Pure#inspect" do
  it_behaves_like :character_set_inspect, CharacterSet::Pure
end
