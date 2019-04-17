shared_examples :character_set_ascii_part do |variant|
  it 'returns the ascii part of a character set' do
    expect(variant[97, 98, 99, 200].ascii_part).to eq(variant[97, 98, 99])
  end
end

describe "CharacterSet#ascii_part" do
  it_behaves_like :character_set_ascii_part, CharacterSet
end

describe "CharacterSet::Pure#ascii_part" do
  it_behaves_like :character_set_ascii_part, CharacterSet::Pure
end
