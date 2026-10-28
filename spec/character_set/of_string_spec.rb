shared_examples :character_set_of_string do |variant|
  it 'returns the CharacterSet used by the given String' do
    expect(variant.of_string('cccaaabbb')).to eq variant[97, 98, 99]
  end

  NON_ASCII_ENCODING_SAMPLES.each do |encoding, text|
    it "stores Unicode codepoints from non-ASCII #{encoding} input" do
      expect(variant.of_string(text.encode(encoding)).to_a).to eq text.codepoints.sort
    end
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant.of_string(false) }.to raise_error(ArgumentError)
    expect { variant.of_string(nil) }.to raise_error(ArgumentError)
    expect { variant.of_string(1) }.to raise_error(ArgumentError)
    expect { variant.of_string(Object.new) }.to raise_error(ArgumentError)
    expect { variant.of_string('a', nil, 'c') }.to raise_error(ArgumentError)
    expect { variant.of_string }.to raise_error(ArgumentError)
  end

  it 'rejects malformed UTF-8, including truncated characters and surrogates' do
    INVALID_UTF8_STRINGS.each do |invalid|
      expect { variant.of_string(invalid) }.to raise_error(ArgumentError)
    end
  end
end

describe "CharacterSet::of_string" do
  it_behaves_like :character_set_of_string, CharacterSet
end

describe "CharacterSet::Pure::of_string" do
  it_behaves_like :character_set_of_string, CharacterSet::Pure
end
