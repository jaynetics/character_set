shared_examples :character_set_assigned do |variant|
  it 'returns a new set including only assigned codepoints of the original set' do
    result = variant.new(0..0xFFF).assigned
    expect(result.include?(97)).to be true
    expect(result.include?(0x378)).to be false
    expect(result.include?(0x37A)).to be true
    expect(result.include?(0x1000)).to be false
  end
end

describe "CharacterSet#assigned" do
  it_behaves_like :character_set_assigned, CharacterSet
end

describe "CharacterSet::Pure#assigned" do
  it_behaves_like :character_set_assigned, CharacterSet::Pure
end
