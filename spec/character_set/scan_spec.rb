shared_examples :character_set_scan do |variant|
  it 'returns a new String with only the Characters in self' do
    expect(variant[97, 98, 99].scan('abc')).to eq ['a', 'b', 'c']
    expect(variant[97, 98, 99].scan('abz')).to eq ['a', 'b']
    expect(variant[97, 98, 99].scan('xy')).to eq []
    expect(variant[1, 2, 3].scan('')).to eq []
    expect(variant[].scan('abc')).to eq []
  end

  it 'does not alter the original string' do
    str = 'abc'
    variant[1, 2, 3].scan(str)
    expect(str).to eq 'abc'
  end

  it 'works with multibyte characters' do
    expect(variant[0x1F60B].scan("a\u{1F60B}c")).to eq ["\u{1F60B}"]
  end

  it 'works with long strings' do
    expect(variant['b'].scan('ab' * 54321)).to eq(['b'] * 54321)
  end

  TESTED_ENCODINGS.each do |enc|
    it "works with #{enc} strings" do
      str = 'abz'.encode(enc)
      result = variant[97, 98, 99].scan(str)
      expect(result).to eq ['a', 'b']
    end
  end

  it 'works with Strings in non-utf8-compatible encodings' do
    str = 'äü'.encode('EUC-JP')
    result = variant['ü'].scan(str)
    expect(result).to eq ['ü']
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant[].scan(false) }.to raise_error(ArgumentError)
    expect { variant[].scan(nil) }.to raise_error(ArgumentError)
    expect { variant[].scan(1) }.to raise_error(ArgumentError)
    expect { variant[].scan(Object.new) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for broken strings' do
    expect { variant[].scan("a\xC1\x80b") }.to raise_error(ArgumentError)
  end
end

describe "CharacterSet#scan" do
  it_behaves_like :character_set_scan, CharacterSet

  it 'is memsafe' do
    set = CharacterSet[97, 98, 99]
    expect { set.scan('abcd') }.to be_memsafe
  end
end

describe "CharacterSet::Pure#scan" do
  it_behaves_like :character_set_scan, CharacterSet::Pure
end
