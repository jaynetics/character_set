shared_examples :character_set_keep_in_bang do |variant|
  it 'alters the given string, removing all Characters except those in self' do
    str = 'abc'
    variant[97, 98, 99].keep_in!(str)
    expect(str).to eq 'abc'

    str = 'abz'
    variant[97, 98, 99].keep_in!(str)
    expect(str).to eq 'ab'

    str = 'xy'
    variant[97, 98, 99].keep_in!(str)
    expect(str).to eq ''

    str = ''
    variant[1, 2, 3].keep_in!(str)
    expect(str).to eq ''

    str = 'abc'
    variant[].keep_in!(str)
    expect(str).to eq ''
  end

  it 'returns nil iff the original string is unchanged' do
    expect(variant[97, 98, 99].keep_in!('abc')).to eq nil
    expect(variant[97, 98, 99].keep_in!('abz')).to eq 'ab'
  end

  it 'preserves the taintedness of the original string' do
    tainted_string = 'bar'.taint
    untainted_string = 'bar'
    expect(variant[97].keep_in!(tainted_string).tainted?).to be true
    expect(variant[97].keep_in!(untainted_string).tainted?).to be false
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant[].keep_in!(false) }.to raise_error(ArgumentError)
    expect { variant[].keep_in!(nil) }.to raise_error(ArgumentError)
    expect { variant[].keep_in!(1) }.to raise_error(ArgumentError)
    expect { variant[].keep_in!(Object.new) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for broken strings' do
    expect { variant[].keep_in!("a\xC1\x80b") }.to raise_error(ArgumentError)
  end

  it 'raises FrozenError if passed a frozen String',
     if: ruby_version_is_at_least('2.5') do
    expect { variant[97].keep_in!('abc'.freeze) }.to raise_error(FrozenError)
  end
end

describe "CharacterSet#keep_in!" do
  it_behaves_like :character_set_keep_in_bang, CharacterSet

  it 'is memsafe' do
    set = CharacterSet[97, 98, 99]
    expect { set.keep_in!('abcd') }.to be_memsafe(runs: 1_000_000)
  end
end

describe "CharacterSet::Pure#keep_in!" do
  it_behaves_like :character_set_keep_in_bang, CharacterSet::Pure
end
