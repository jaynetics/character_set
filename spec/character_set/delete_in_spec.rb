shared_examples :character_set_delete_in do |variant|
  it 'returns a new String without the Characters in self' do
    expect(variant[97, 98, 99].delete_in('abc')).to eq ''
    expect(variant[97, 98, 99].delete_in('abz')).to eq 'z'
    expect(variant[97, 98, 99].delete_in('xy')).to eq 'xy'
    expect(variant[1, 2, 3].delete_in('abz')).to eq 'abz'
    expect(variant[1, 2, 3].delete_in('')).to eq ''
    expect(variant[].delete_in('abc')).to eq 'abc'
  end

  it 'does not alter the original string' do
    str = 'abc'
    variant[97, 98, 99].delete_in(str)
    expect(str).to eq 'abc'
  end

  it 'works with multibyte characters' do
    expect(variant[0x1F60B].delete_in("a\u{1F60B}c")).to eq "ac"
    expect(variant[97, 98, 99].delete_in("a\u{1F60B}c")).to eq "\u{1F60B}"
  end

  it 'works with long strings' do
    expect(variant['b'].delete_in('ab' * 54321)).to eq('a' * 54321)
  end

  it 'works with frozen strings' do
    expect(variant[97, 98, 99].delete_in('abz'.freeze)).to eq 'z'
  end

  it 'works with substrings' do
    expect(variant[97, 98, 99].delete_in(' abz '.strip)).to eq 'z'
  end

  TESTED_ENCODINGS.each do |enc|
    it "works with #{enc} strings, keeping the original encoding" do
      str = 'abz'.encode(enc)
      result = variant[97, 98, 99].delete_in(str)
      expect(result.encoding).to eq enc
      expect(result).to eq 'z'.encode(enc)
    end
  end

  NON_ASCII_ENCODING_SAMPLES.each do |encoding, text|
    it "filters non-ASCII #{encoding} strings, keeping the original encoding" do
      original = text.encode(encoding)
      result = variant[text[-1]].delete_in(original)
      expect(result.encoding).to eq original.encoding
      expect(result).to eq text[0].encode(encoding)
    end
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant[].delete_in(false) }.to raise_error(ArgumentError)
    expect { variant[].delete_in(nil) }.to raise_error(ArgumentError)
    expect { variant[].delete_in(1) }.to raise_error(ArgumentError)
    expect { variant[].delete_in(Object.new) }.to raise_error(ArgumentError)
  end

  it 'rejects malformed UTF-8, including truncated characters and surrogates' do
    INVALID_UTF8_STRINGS.each do |invalid|
      expect { variant[].delete_in(invalid) }.to raise_error(ArgumentError)
    end
  end
end

describe "CharacterSet#delete_in" do
  it_behaves_like :character_set_delete_in, CharacterSet

  it 'is memsafe' do
    set = CharacterSet[97, 98, 99]
    expect { set.delete_in('abcd') }.to be_memsafe
  end
end

describe "CharacterSet::Pure#delete_in" do
  it_behaves_like :character_set_delete_in, CharacterSet::Pure
end
