shared_examples :character_set_keep_in do |variant|
  it 'returns a new String with only the Characters in self' do
    expect(variant[97, 98, 99].keep_in('abc')).to eq 'abc'
    expect(variant[97, 98, 99].keep_in('abz')).to eq 'ab'
    expect(variant[97, 98, 99].keep_in('xy')).to eq ''
    expect(variant[1, 2, 3].keep_in('')).to eq ''
    expect(variant[].keep_in('abc')).to eq ''
  end

  it 'does not alter the original string' do
    str = 'abc'
    variant[1, 2, 3].keep_in(str)
    expect(str).to eq 'abc'
  end

  it 'works with multibyte characters' do
    expect(variant[0x1F60B].keep_in("a\u{1F60B}c")).to eq "\u{1F60B}"
  end

  it 'works with long strings' do
    expect(variant['b'].keep_in('ab' * 54321)).to eq('b' * 54321)
  end

  it 'works with frozen strings' do
    expect(variant[97, 98, 99].keep_in('abz'.freeze)).to eq 'ab'
  end

  it 'works with substrings' do
    expect(variant[97, 98, 99].keep_in(' abz '.strip)).to eq 'ab'
  end

  it 'works with non-terminated strings' do
    embedded_string = "abzefg"
    string = embedded_string.gsub("efg", "aby")
    {}[string] = 1
    non_terminated = "#{string}#{nil}"
    expect(variant[97, 98, 99].keep_in(non_terminated)).to eq 'abab'
  end

  TESTED_ENCODINGS.each do |enc|
    it "works with #{enc} strings, keeping the original encoding" do
      str = 'abz'.encode(enc)
      result = variant[97, 98, 99].keep_in(str)
      expect(result.encoding).to eq enc
      expect(result).to eq 'ab'.encode(enc)
    end
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant[].keep_in(false) }.to raise_error(ArgumentError)
    expect { variant[].keep_in(nil) }.to raise_error(ArgumentError)
    expect { variant[].keep_in(1) }.to raise_error(ArgumentError)
    expect { variant[].keep_in(Object.new) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for broken strings' do
    expect { variant[].keep_in("a\xC1\x80b") }.to raise_error(ArgumentError)
  end
end

describe "CharacterSet#keep_in" do
  it_behaves_like :character_set_keep_in, CharacterSet

  it 'is memsafe' do
    set = CharacterSet[97, 98, 99]
    expect { set.keep_in('abcd') }.to be_memsafe
  end
end

describe "CharacterSet::Pure#keep_in" do
  it_behaves_like :character_set_keep_in, CharacterSet::Pure
end
