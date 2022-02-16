shared_examples :character_set_of_string do |variant|
  it 'returns the CharacterSet used by the given String' do
    expect(variant.of_string('cccaaabbb')).to eq variant[97, 98, 99]
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant.of_string(false) }.to raise_error(ArgumentError)
    expect { variant.of_string(nil) }.to raise_error(ArgumentError)
    expect { variant.of_string(1) }.to raise_error(ArgumentError)
    expect { variant.of_string(Object.new) }.to raise_error(ArgumentError)
    expect { variant.of_string('a', nil, 'c') }.to raise_error(ArgumentError)
    expect { variant.of_string }.to raise_error(ArgumentError)
  end
end

describe "CharacterSet::of_string" do
  it_behaves_like :character_set_of, CharacterSet
end

describe "CharacterSet::Pure::of_string" do
  it_behaves_like :character_set_of, CharacterSet::Pure
end
