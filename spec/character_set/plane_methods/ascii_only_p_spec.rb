shared_examples :character_set_ascii_only_p do |variant|
  it 'returns true for ascii-only sets' do
    expect(variant[].ascii_only?).to be true
    expect(variant[97].ascii_only?).to be true
    expect(variant[97, 128].ascii_only?).to be false
    expect(variant[0x10FFFF].ascii_only?).to be false
  end
end

describe "CharacterSet#ascii_only?" do
  it_behaves_like :character_set_ascii_only_p, CharacterSet
end

describe "CharacterSet::Pure#ascii_only?" do
  it_behaves_like :character_set_ascii_only_p, CharacterSet::Pure
end
