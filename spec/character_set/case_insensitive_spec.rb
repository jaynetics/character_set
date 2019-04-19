shared_examples :character_set_case_insensitive do |variant|
  it 'returns a case-insensitive version of the character set' do
    expect(variant['a', 'B'].case_insensitive).to eq variant['A', 'a', 'B', 'b']
  end

  it 'keeps handle non-casefoldable codepoints' do
    expect(variant['1', '2'].case_insensitive).to eq variant['1', '2']
  end

  if Gem::Version.new(RUBY_VERSION.dup) >= (Gem::Version.new('2.4.0'))
    it 'works for non-ascii codepoints' do
      expect(variant['Ⓜ'].case_insensitive).to eq variant['Ⓜ', 'ⓜ']
    end

    it 'ignores mappings to multiple codepoints' do
      # "ﬃ".swapcase # => "FFI" # 3 codepoints
      expect(variant['ﬃ']).to eq variant['ﬃ']
    end
  end
end

describe "CharacterSet#case_insensitive" do
  it_behaves_like :character_set_case_insensitive, CharacterSet

  it 'is memsafe' do
    set = CharacterSet['a', 'b', 'c']
    expect { set.case_insensitive }.to be_memsafe
  end
end

describe "CharacterSet::Pure#case_insensitive" do
  it_behaves_like :character_set_case_insensitive, CharacterSet::Pure
end
