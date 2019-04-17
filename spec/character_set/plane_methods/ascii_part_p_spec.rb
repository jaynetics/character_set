shared_examples :character_set_ascii_part_p do |variant|
  it 'returns true iff a part of the character set is ascii' do
    expect(variant[97, 98, 99].ascii_part?).to be true
    expect(variant[97, 98, 99, 200].ascii_part?).to be true
    expect(variant[200].ascii_part?).to be false
    expect(variant[].ascii_part?).to be false
  end
end

describe "CharacterSet#ascii_part?" do
  it_behaves_like :character_set_ascii_part_p, CharacterSet
end

describe "CharacterSet::Pure#ascii_part?" do
  it_behaves_like :character_set_ascii_part_p, CharacterSet::Pure
end
