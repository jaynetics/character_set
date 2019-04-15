shared_examples :character_set_bmp_only_p do |variant|
  it 'returns true for bmp-only sets' do
    expect(variant[].bmp_only?).to be true
    expect(variant[97].bmp_only?).to be true
    expect(variant[97, 0x12345].bmp_only?).to be false
    expect(variant[0x10FFFF].bmp_only?).to be false
  end
end

describe "CharacterSet#bmp_only?" do
  it_behaves_like :character_set_bmp_only_p, CharacterSet
end

describe "CharacterSet::Pure#bmp_only?" do
  it_behaves_like :character_set_bmp_only_p, CharacterSet::Pure
end
