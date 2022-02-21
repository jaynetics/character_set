shared_examples :character_set_count_in do |variant|
  it 'returns the count of occurrences in the given String' do
    expect(variant[97, 98, 99].count_in('ab')).to eq 2
    expect(variant[97, 98, 99].count_in('abcd')).to eq 3
    expect(variant[97, 98, 99].count_in('xyz')).to eq 0
    expect(variant[97, 98, 99].count_in('')).to eq 0
  end

  it 'works with multibyte characters' do
    expect(variant[0x1F60B].count_in("a\u{1F60B}c")).to eq 1
  end

  it 'works with long strings' do
    expect(variant['b'].count_in('ab' * 54321)).to eq 54321
  end

  TESTED_ENCODINGS.each do |enc|
    it "works with #{enc} strings" do
      str = 'abz'.encode(enc)
      expect(variant[97, 98, 99].count_in(str)).to eq 2
    end
  end

  it 'works with Strings in non-utf8-compatible encodings' do
    str = 'äüäü'.encode('EUC-JP')
    result = variant['ü'].count_in(str)
    expect(result).to eq 2
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant[].count_in(false) }.to raise_error(ArgumentError)
    expect { variant[].count_in(nil) }.to raise_error(ArgumentError)
    expect { variant[].count_in(1) }.to raise_error(ArgumentError)
    expect { variant[].count_in(Object.new) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for broken strings' do
    expect { variant[].count_in("a\xC1\x80b") }.to raise_error(ArgumentError)
  end
end

describe "CharacterSet#count_in" do
  it_behaves_like :character_set_count_in, CharacterSet

  it 'is memsafe' do
    set = CharacterSet[97, 98, 99]
    expect { set.count_in('abcd') }.to be_memsafe
  end
end

describe "CharacterSet::Pure#count_in" do
  it_behaves_like :character_set_count_in, CharacterSet::Pure
end
