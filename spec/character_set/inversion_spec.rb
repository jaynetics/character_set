shared_examples :character_set_inversion do |variant|
  it 'returns a new set with all codepoints not in the original set' do
    expect(variant[2, 4].inversion(upto: 5))
      .to eq variant[0, 1, 3, 5]
  end

  it 'does not insert surrogate codepoints by default' do
    result = variant.new.inversion(upto: 0xE000)
    expect(result).to eq variant.new((0..0xD7FF).to_a + [0xE000])
  end

  it 'inserts surrogate codepoints if told so' do
    result = variant.new.inversion(upto: 0xE000, include_surrogates: true)
    expect(result).to eq variant.new(0..0xE000)
  end
end

describe "CharacterSet#inversion" do
  it_behaves_like :character_set_inversion, CharacterSet
end

describe "CharacterSet::Pure#inversion" do
  it_behaves_like :character_set_inversion, CharacterSet::Pure
end
