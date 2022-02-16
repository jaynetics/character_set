shared_examples :character_set_of do |variant|
  it 'calls ::of_string if given a String' do
    expect(variant).to receive(:of_string).and_return(variant[97])
    expect(variant.of('foo')).to eq variant[97]
  end

  it 'calls ::of_regexp if given a Regexp' do
    expect(variant).to receive(:of_regexp).and_return(variant[98])
    expect(variant.of(/bar/)).to eq variant[98]
  end

  it 'works with multiple and mixed arguments' do
    expect(variant).to receive(:of_string).with('foo').and_return(variant[97])
    expect(variant).to receive(:of_string).with('baz').and_return(variant[98])
    expect(variant).to receive(:of_regexp).with(/bar/).and_return(variant[98])
    expect(variant).to receive(:of_regexp).with(/qux/).and_return(variant[99])

    expect(variant.of('foo', /bar/, 'baz', /qux/)).to eq variant[97, 98, 99]
  end

  it 'returns an empty CharacterSet if called without arguments' do
    expect(variant.of).to eq variant[]
  end

  it 'raises an ArgumentError if passed a non-String/Regexp' do
    expect { variant.of(false) }.to raise_error(ArgumentError)
    expect { variant.of(nil) }.to raise_error(ArgumentError)
    expect { variant.of(1) }.to raise_error(ArgumentError)
    expect { variant.of(Object.new) }.to raise_error(ArgumentError)
    expect { variant.of('a', nil, 'c') }.to raise_error(ArgumentError)
  end
end

describe "CharacterSet::of" do
  it_behaves_like :character_set_of, CharacterSet
end

describe "CharacterSet::Pure::of" do
  it_behaves_like :character_set_of, CharacterSet::Pure
end
