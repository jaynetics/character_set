shared_examples :character_set_valid_part do |variant|
  it 'returns a new set including only valid codepoints of the original set' do
    result = variant.new(0..0xFFFF).valid_part
    expect(result.include?(97)).to be true
    expect(result.include?(0xD999)).to be false
    expect(result.include?(0xEEEE)).to be true
    expect(result.include?(0x10000)).to be false
  end
end

describe "CharacterSet#valid_part" do
  it_behaves_like :character_set_valid_part, CharacterSet
end

describe "CharacterSet::Pure#valid_part" do
  it_behaves_like :character_set_valid_part, CharacterSet::Pure
end
