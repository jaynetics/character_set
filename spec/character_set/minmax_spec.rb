shared_examples :character_set_minmax do |variant|
  it 'returns the min and max codepoints of the set' do
    expect(variant[97, 98, 99].minmax).to eq [97, 99]
    expect(variant[97, 98, 1000].minmax).to eq [97, 1000]
    expect(variant[97].minmax).to eq [97, 97]
    expect(variant[].minmax).to eq [nil, nil]
  end
end

describe "CharacterSet#minmax" do
  it_behaves_like :character_set_minmax, CharacterSet
end

describe "CharacterSet::Pure#minmax" do
  it_behaves_like :character_set_minmax, CharacterSet::Pure
end
