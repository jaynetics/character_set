shared_examples :character_set_assigned_part do |variant|
  it 'returns a new set including only assigned codepoints of the original set' do
    result = variant.new(0..0xFFF).assigned_part
    expect(result.include?(97)).to be true
    expect(result.include?(0x378)).to be false
    expect(result.include?(0x37A)).to be true
    expect(result.include?(0x1000)).to be false
  end
end

describe "CharacterSet#assigned_part" do
  it_behaves_like :character_set_assigned_part, CharacterSet
end

describe "CharacterSet::Pure#assigned_part" do
  it_behaves_like :character_set_assigned_part, CharacterSet::Pure
end
