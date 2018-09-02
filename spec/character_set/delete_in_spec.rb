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
  end

  it 'preserves the taintedness of the original string' do
    tainted_string = 'bar'.taint
    untainted_string = 'bar'
    expect(variant[97].delete_in(tainted_string).tainted?).to be true
    expect(variant[97].delete_in(untainted_string).tainted?).to be false
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant[].delete_in(false) }.to raise_error(ArgumentError)
    expect { variant[].delete_in(nil) }.to raise_error(ArgumentError)
    expect { variant[].delete_in(1) }.to raise_error(ArgumentError)
    expect { variant[].delete_in(Object.new) }.to raise_error(ArgumentError)
  end
end

describe "CharacterSet#delete_in" do
  it_behaves_like :character_set_delete_in, CharacterSet
end

describe "CharacterSet::Pure#delete_in" do
  it_behaves_like :character_set_delete_in, CharacterSet::Pure
end