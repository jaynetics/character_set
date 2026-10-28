shared_examples :character_set_case_insensitive do |variant|
  it 'returns a case-insensitive version of the character set' do
    expect(variant['a', 'B'].case_insensitive).to eq variant['A', 'a', 'B', 'b']
  end

  it 'keeps handle non-casefoldable codepoints' do
    expect(variant['1', '2'].case_insensitive).to eq variant['1', '2']
  end

  it 'works for non-ascii codepoints' do
    expect(variant['Ⓜ'].case_insensitive).to eq variant['Ⓜ', 'ⓜ']
  end

  it 'ignores mappings to multiple codepoints' do
    # "ﬃ".swapcase # => "FFI" # 3 codepoints
    expect(variant['ﬃ'].case_insensitive).to eq variant['ﬃ']
  end

  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = set1.case_insensitive
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end

  it 'preserves the subclass and isolates result mutations' do
    subclass = Class.new(variant)
    source = subclass[1, 2]
    result = source.case_insensitive
    expect(result).to be_a subclass
    result.add(99)
    expect(source.to_a).to eq [1, 2]
  end
end

describe "CharacterSet#case_insensitive" do
  it_behaves_like :character_set_case_insensitive, CharacterSet

  it 'includes the complete single-codepoint casefold equivalence group' do
    [%w[K k K], %w[Σ ς σ], %w[Μ μ µ]].each do |group|
      group.each do |char|
        source = CharacterSet[char].freeze
        expect(source.case_insensitive.to_a).to eq group.map(&:ord).sort
        expect(source.to_a).to eq [char.ord]
      end
    end
  end

  it 'excludes characters that fold to strings of multiple codepoints' do
    %w[ß ẞ ﬃ].each do |char|
      expect(CharacterSet[char].case_insensitive).to eq CharacterSet[char]
    end
  end

  it 'supports casefold mappings outside the BMP and preserves surrogate codepoints' do
    source = CharacterSet[0x10400, 0xD800, 0xDFFF, 0x10FFFF]
    expect(source.case_insensitive).to eq CharacterSet[0x10400, 0x10428, 0xD800, 0xDFFF, 0x10FFFF]
  end

  it 'is memsafe' do
    set = CharacterSet['K', 'µ', 'Σ']
    expect { set.case_insensitive }.to be_memsafe
  end
end

describe "CharacterSet::Pure#case_insensitive" do
  it_behaves_like :character_set_case_insensitive, CharacterSet::Pure
end
