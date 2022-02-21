shared_examples :character_set_cover_p do |variant|
  it 'returns true iff the CharacterSet covers the given string' do
    expect(variant[97, 98, 99].cover?('abc')).to be true
    expect(variant[97, 98, 99].cover?('abz')).to be false
    expect(variant[97, 98, 99].cover?('')).to be true
  end

  TESTED_ENCODINGS.each do |enc|
    it "works with #{enc} strings" do
      expect(variant[97, 98, 99].cover?('abc'.encode(enc))).to be true
      expect(variant[97, 98, 99].cover?('abz'.encode(enc))).to be false
    end
  end

  it 'works with Strings in non-utf8-compatible encodings' do
    expect(variant['ü'].cover?('üü'.encode('EUC-JP'))).to be true
    expect(variant['ü'].cover?('äü'.encode('EUC-JP'))).to be false
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant[].cover?(false) }.to raise_error(ArgumentError)
    expect { variant[].cover?(nil) }.to raise_error(ArgumentError)
    expect { variant[].cover?(1) }.to raise_error(ArgumentError)
    expect { variant[].cover?(Object.new) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for broken strings' do
    expect { variant[97].cover?("a\xC1\x80b") }.to raise_error(ArgumentError)
  end
end

describe "CharacterSet#cover?" do
  it_behaves_like :character_set_cover_p, CharacterSet
end

describe "CharacterSet::Pure#cover?" do
  it_behaves_like :character_set_cover_p, CharacterSet::Pure
end
