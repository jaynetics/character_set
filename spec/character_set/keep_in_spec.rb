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

  it 'preserves the taintedness of the original string' do
    tainted_string = 'bar'.taint
    untainted_string = 'bar'
    expect(variant[97].keep_in(tainted_string).tainted?).to be true
    expect(variant[97].keep_in(untainted_string).tainted?).to be false
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant[].keep_in(false) }.to raise_error(ArgumentError)
    expect { variant[].keep_in(nil) }.to raise_error(ArgumentError)
    expect { variant[].keep_in(1) }.to raise_error(ArgumentError)
    expect { variant[].keep_in(Object.new) }.to raise_error(ArgumentError)
  end
end

describe "CharacterSet#keep_in" do
  it_behaves_like :character_set_keep_in, CharacterSet
end

describe "CharacterSet::Pure#keep_in" do
  it_behaves_like :character_set_keep_in, CharacterSet::Pure
end
