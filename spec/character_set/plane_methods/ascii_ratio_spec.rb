shared_examples :character_set_ascii_ratio do |variant|
  it 'returns the ratio of ascii characters in the set' do
    expect(variant[97, 98, 99, 200].ascii_ratio).to eq 0.75
  end
end

describe "CharacterSet#ascii_ratio" do
  it_behaves_like :character_set_ascii_ratio, CharacterSet
end

describe "CharacterSet::Pure#ascii_ratio" do
  it_behaves_like :character_set_ascii_ratio, CharacterSet::Pure
end
